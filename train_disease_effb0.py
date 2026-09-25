"""
Disease model — EfficientNet-B0 backbone, 16-class SUPERSET taxonomy.

Same data/classes as train_disease_v4.py (PlantVillage + PlantCity + PlantDoc,
Apple 0-5 / Grape 6-15) but a larger backbone (~16-20 MB TFLite vs ~6 MB) to
test whether more capacity improves real-world disease recognition.

CAUTION: retraining this with the strong photometric augs in augmentations.py
was TRIED AND REVERTED (2026-07). It reached a higher val (99.33%) and was more
decisive -- Black Rot 0.83->0.98, Scab 0.75->0.88, and it correctly resolved a
dark healthy leaf that used to abstain. But it also turned a visibly diseased
leaf (Images/...12.53.49 PM (1), covered in yellow rust-like spots) from a safe
"disease unknown" into a confident "Grape Healthy 0.93", and dropped two real
Powdery Mildew diagnoses to "unknown".

That trade is unacceptable: a false "healthy" on a diseased vine is this app's
worst failure mode. The augs made the model more decisive, and decisiveness on
a disease that is NOT in the 16-class taxonomy (grape rust) collapses into
"healthy" instead of abstaining. Note val accuracy went UP while real-world
safety went DOWN -- val cannot see this.

Fix the taxonomy gap (real grape-rust data) before touching the augs here.

Runs on the dev box (cuda) or the Ascend 910B server (npu) -- see device.py.
Exports best_disease.pth + ONNX -> convert_disease.py.
"""
import os
import random
from pathlib import Path
import numpy as np
import torch, torch.nn as nn, torch.optim as optim
from PIL import Image
from torch.utils.data import Dataset, DataLoader, WeightedRandomSampler
from torchvision.models import efficientnet_b0, EfficientNet_B0_Weights

from augmentations import strong_train_transforms, val_transforms, load_rgb
from device import pick_device, seed_all, tune_backend, loader_opts
from paths import PV, PD, PC_DIRS, IMG_EXTS

ROOT = Path(__file__).resolve().parent

OUT_DIR = ROOT / "output_effb0"
CKPT_PATH = OUT_DIR / "best_disease.pth"
ONNX_PATH = OUT_DIR / "best_disease.onnx"

IMG_SIZE, BATCH, LR, WD, VAL_SPLIT = 224, 24, 1e-3, 1e-4, 0.15
EPOCHS = int(os.environ.get("AGROEYE_EPOCHS", "25"))   # strong augs need longer to converge
MAX_PER_SOURCE = 1200
IMAGENET_MEAN = [0.485, 0.456, 0.406]; IMAGENET_STD = [0.229, 0.224, 0.225]

CLASS_DEF = [
    ("Apple Scab",          ["Apple___Apple_scab"],                       ["Apple_Scab_Leaf"], []),
    ("Apple Black Rot",     ["Apple___Black_rot"],                        [],                  []),
    ("Apple Cedar Rust",    ["Apple___Cedar_apple_rust"],                 ["Apple_rust_leaf"], []),
    ("Apple Black Spot",    [],                                           [],                  ["Apple black_spot"]),
    ("Apple Brown Spot",    [],                                           [],                  ["Apple Brown_spot"]),
    ("Apple Healthy",       ["Apple___healthy"],                          ["Apple_leaf"],      ["Apple Normal"]),
    ("Grape Black Rot",     ["Grape___Black_rot"],                        ["grape_leaf_black_rot"], []),
    ("Grape Esca",          ["Grape___Esca_(Black_Measles)"],             [],                  []),
    ("Grape Leaf Blight",   ["Grape___Leaf_blight_(Isariopsis_Leaf_Spot)"], [],               []),
    ("Grape Anthracnose",   [],                                           [],                  ["Grape Anthracnose leaf"]),
    ("Grape Brown Spot",    [],                                           [],                  ["Grape Brown spot leaf"]),
    ("Grape Downy Mildew",  [],                                           [],                  ["Grape Downy mildew leaf"]),
    ("Grape Mites",         [],                                           [],                  ["Grape Mites_leaf disease"]),
    ("Grape Powdery Mildew",[],                                           [],                  ["Grape Powdery_mildew leaf"]),
    ("Grape Shot Hole",     [],                                           [],                  ["Grape shot hole leaf disease"]),
    ("Grape Healthy",       ["Grape___healthy"],                          ["grape_leaf"],      ["Grape Normal_leaf"]),
]
CLASS_NAMES = [c[0] for c in CLASS_DEF]; NUM = len(CLASS_DEF)


def imgs_in(d):
    return [p for p in d.glob("*") if p.suffix.lower() in IMG_EXTS] if d.exists() else []


def gather():
    from newdata_sources import disease_extra
    extra = disease_extra()   # real-world Kaggle data (Niphad grape + Plant Pathology apple)
    samples, counts = [], []
    pd_index = {}
    for p in PD.rglob("*"):
        if p.suffix.lower() in IMG_EXTS:
            pd_index.setdefault(p.parent.name, []).append(p)
    for idx, (name, pvs, pds, pcs) in enumerate(CLASS_DEF):
        pool = []
        for f in pvs:
            g = imgs_in(PV / f); random.shuffle(g); pool += g[:MAX_PER_SOURCE]
        for f in pds:
            g = pd_index.get(f, [])[:]; random.shuffle(g); pool += g
        for f in pcs:
            g = []
            for base in PC_DIRS: g += imgs_in(base / f)
            random.shuffle(g); pool += g[:MAX_PER_SOURCE]
        pool += [Path(p) for p in extra.get(name, [])]   # + new real-world data
        samples += [(p, idx) for p in pool]; counts.append((name, len(pool)))
    print("Per class:"); [print(f"  {c:>5}  {n}") for n, c in counts]
    print(f"Total: {len(samples)}")
    return samples


class DS(Dataset):
    def __init__(self, s, tf): self.s = s; self.tf = tf
    def __len__(self): return len(self.s)
    def __getitem__(self, i):
        p, y = self.s[i]
        try: im = load_rgb(p, IMG_SIZE)
        except Exception: im = Image.new("RGB", (IMG_SIZE, IMG_SIZE))
        return self.tf(im), y


def loaders(kind):
    samples = gather(); random.shuffle(samples)
    sp = int(len(samples) * (1 - VAL_SPLIT)); tr, va = samples[:sp], samples[sp:]
    # NOTE: the deployed model was trained with the older, milder augs. Re-running
    # this script retrains with the strong ones -- read the CAUTION at the top and
    # re-test against Images/ before deploying the result.
    train_tf = strong_train_transforms(IMG_SIZE, IMAGENET_MEAN, IMAGENET_STD)
    val_tf = val_transforms(IMG_SIZE, IMAGENET_MEAN, IMAGENET_STD)
    labels = [y for _, y in tr]; cc = np.bincount(labels, minlength=NUM); w = 1.0 / np.maximum(cc, 1)
    sw = [w[y] for y in labels]; sampler = WeightedRandomSampler(sw, len(sw), replacement=True)
    opts = loader_opts(kind)
    return (DataLoader(DS(tr, train_tf), BATCH, sampler=sampler, **opts),
            DataLoader(DS(va, val_tf), BATCH, shuffle=False, **opts))


def build():
    m = efficientnet_b0(weights=EfficientNet_B0_Weights.IMAGENET1K_V1)
    in_f = m.classifier[1].in_features
    m.classifier = nn.Sequential(nn.Dropout(p=0.3, inplace=True), nn.Linear(in_f, NUM))
    return m


@torch.no_grad()
def evaluate(m, loader, dev):
    m.eval(); correct = total = 0; cm = np.zeros((NUM, NUM), int)
    for x, y in loader:
        x, y = x.to(dev), y.to(dev); pred = m(x).argmax(1)
        correct += (pred == y).sum().item(); total += y.size(0)
        for t, p in zip(y.cpu().numpy(), pred.cpu().numpy()): cm[t, p] += 1
    per = [100.0 * cm[i, i] / max(cm[i].sum(), 1) for i in range(NUM)]
    return 100.0 * correct / max(total, 1), per


def export_onnx(m):
    m.eval().cpu()
    torch.onnx.export(m, torch.randn(1, 3, IMG_SIZE, IMG_SIZE), str(ONNX_PATH),
        input_names=["input"], output_names=["output"],
        dynamic_axes={"input": {0: "batch_size"}, "output": {0: "batch_size"}},
        opset_version=13, do_constant_folding=True, dynamo=False)
    print("ONNX exported:", ONNX_PATH)


def main():
    dev, kind = pick_device()
    seed_all(42, kind); tune_backend(kind)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Device: {dev} ({kind}) | Backbone: EfficientNet-B0 | epochs={EPOCHS}")
    tl, vl = loaders(kind); m = build().to(dev)
    crit = nn.CrossEntropyLoss(label_smoothing=0.1)
    opt = optim.AdamW(m.parameters(), lr=LR, weight_decay=WD)
    sch = optim.lr_scheduler.OneCycleLR(opt, max_lr=LR, epochs=EPOCHS, steps_per_epoch=len(tl), pct_start=0.1, anneal_strategy="cos")
    best = 0.0
    # Resume from a prior (crashed) run so re-running continues instead of restarting.
    if CKPT_PATH.exists():
        ck = torch.load(CKPT_PATH, map_location=dev, weights_only=False)
        m.load_state_dict(ck["model_state_dict"]); best = ck.get("val_acc", 0.0)
        print(f"Resumed from checkpoint (val {best:.2f}%)")
    for ep in range(EPOCHS):
        m.train(); run = c = t = 0
        for x, y in tl:
            x, y = x.to(dev), y.to(dev); opt.zero_grad()
            o = m(x); loss = crit(o, y); loss.backward(); opt.step(); sch.step()
            run += loss.item() * x.size(0); c += (o.argmax(1) == y).sum().item(); t += y.size(0)
        acc, per = evaluate(m, vl, dev)
        print(f"Epoch {ep+1}/{EPOCHS} loss={run/t:.3f} train={100.0*c/t:.1f}% val={acc:.2f}%")
        if acc >= best:
            best = acc
            torch.save({"model_state_dict": m.state_dict(), "class_names": CLASS_NAMES,
                "val_acc": acc, "epoch": ep, "model_name": "efficientnet_b0_disease"}, CKPT_PATH)
            print("  saved; per-class: " + " ".join(f"{per[i]:.0f}" for i in range(NUM)))
    print(f"\nBest val acc: {best:.2f}%")
    ck = torch.load(CKPT_PATH, map_location="cpu"); m.load_state_dict(ck["model_state_dict"]); export_onnx(m)
    print("Done -> convert_disease.py")


if __name__ == "__main__":
    main()
