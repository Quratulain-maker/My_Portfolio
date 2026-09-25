"""
Disease model v4 (MobileNetV3-Small, 16 classes) — SUPERSET taxonomy.

Combines PlantVillage (original diseases) + PlantCity (new diseases incl. Grape
Downy Mildew) + PlantDoc (real-world). So it detects BOTH disease sets.

Source-bias mitigation:
  - "Healthy" classes merge images from all sources (so the model can't use
    image style as a shortcut for healthy).
  - Shared diseases (Apple Scab/Cedar Rust, Grape Black Rot) are enriched with
    PlantDoc real-world images.
  - Heavy augmentation reduces lab-vs-field style cues.
Single-source disease classes remain single-source (unavoidable).

Apple = indices 0-5, Grape = 6-15 (so the app masks output by crop).
Run in `torch_cuda`. Exports best_disease.pth + ONNX -> convert_disease.py.
"""
import random
from pathlib import Path
import numpy as np
import torch, torch.nn as nn, torch.optim as optim
from PIL import Image
from torch.utils.data import Dataset, DataLoader, WeightedRandomSampler
from torchvision import models, transforms
from torchvision.models import MobileNet_V3_Small_Weights

ROOT = Path(__file__).resolve().parent
PV = Path(r"C:/Users/atyab/.cache/kagglehub/datasets/abdallahalidev/plantvillage-dataset/versions/3/plantvillage dataset/color")
PD = Path(r"C:/Users/atyab/.cache/kagglehub/datasets/nirmalsankalana/plantdoc-dataset/versions/7")
PC_DIRS = [Path(r"F:/Work/Abasyn Project/plantcity_data/train/train"),
           Path(r"F:/Work/Abasyn Project/plantcity_data/test/test")]

OUT_DIR = ROOT / "output_disease"
CKPT_PATH = OUT_DIR / "best_disease.pth"
ONNX_PATH = OUT_DIR / "best_disease.onnx"

IMG_SIZE, BATCH, EPOCHS, LR, WD, VAL_SPLIT = 224, 32, 18, 1e-3, 1e-4, 0.15
MAX_PER_SOURCE = 1200  # cap each source folder so big classes don't dominate
IMAGENET_MEAN = [0.485, 0.456, 0.406]; IMAGENET_STD = [0.229, 0.224, 0.225]
IMG_EXTS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}

# (display name, PV folders, PlantDoc folders, PlantCity folders)
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
CLASS_NAMES = [c[0] for c in CLASS_DEF]
NUM = len(CLASS_DEF)


def set_seed(s=42):
    random.seed(s); np.random.seed(s); torch.manual_seed(s); torch.cuda.manual_seed_all(s)


def imgs_in(d):
    return [p for p in d.glob("*") if p.suffix.lower() in IMG_EXTS] if d.exists() else []


def pd_imgs(folder):
    out = []
    for p in PD.rglob("*"):
        if p.suffix.lower() in IMG_EXTS and p.parent.name == folder:
            out.append(p)
    return out


def gather():
    samples, counts = [], []
    # pre-index PlantDoc once
    pd_index = {}
    for p in PD.rglob("*"):
        if p.suffix.lower() in IMG_EXTS:
            pd_index.setdefault(p.parent.name, []).append(p)
    for idx, (name, pvs, pds, pcs) in enumerate(CLASS_DEF):
        pool = []
        for f in pvs:
            g = imgs_in(PV / f); random.shuffle(g); pool += g[:MAX_PER_SOURCE]
        for f in pds:
            g = pd_index.get(f, [])[:]; random.shuffle(g); pool += g  # PlantDoc small, take all
        for f in pcs:
            g = []
            for base in PC_DIRS:
                g += imgs_in(base / f)
            random.shuffle(g); pool += g[:MAX_PER_SOURCE]
        samples += [(p, idx) for p in pool]
        counts.append((name, len(pool)))
    print("Per class:")
    for n, c in counts: print(f"  {c:>5}  {n}")
    print(f"Total: {len(samples)}")
    return samples


class DS(Dataset):
    def __init__(self, s, tf): self.s = s; self.tf = tf
    def __len__(self): return len(self.s)
    def __getitem__(self, i):
        p, y = self.s[i]
        try: im = Image.open(p).convert("RGB")
        except Exception: im = Image.new("RGB", (IMG_SIZE, IMG_SIZE))
        return self.tf(im), y


def loaders():
    samples = gather(); random.shuffle(samples)
    sp = int(len(samples) * (1 - VAL_SPLIT)); tr, va = samples[:sp], samples[sp:]
    train_tf = transforms.Compose([
        transforms.RandomResizedCrop(IMG_SIZE, scale=(0.55, 1.0)),
        transforms.RandomHorizontalFlip(), transforms.RandomVerticalFlip(p=0.3),
        transforms.RandomRotation(35), transforms.RandomPerspective(0.3, p=0.4),
        transforms.ColorJitter(0.3, 0.3, 0.3, 0.08),
        transforms.RandomApply([transforms.GaussianBlur(3, (0.1, 2.0))], p=0.2),
        transforms.ToTensor(), transforms.Normalize(IMAGENET_MEAN, IMAGENET_STD),
        transforms.RandomErasing(p=0.2)])
    val_tf = transforms.Compose([transforms.Resize((IMG_SIZE, IMG_SIZE)), transforms.ToTensor(),
        transforms.Normalize(IMAGENET_MEAN, IMAGENET_STD)])
    labels = [y for _, y in tr]; cc = np.bincount(labels, minlength=NUM); w = 1.0 / np.maximum(cc, 1)
    sw = [w[y] for y in labels]; sampler = WeightedRandomSampler(sw, len(sw), replacement=True)
    return (DataLoader(DS(tr, train_tf), BATCH, sampler=sampler, num_workers=4, pin_memory=True),
            DataLoader(DS(va, val_tf), BATCH, shuffle=False, num_workers=4, pin_memory=True))


def build():
    m = models.mobilenet_v3_small(weights=MobileNet_V3_Small_Weights.IMAGENET1K_V1)
    m.classifier[-1] = nn.Linear(m.classifier[-1].in_features, NUM); return m


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
    set_seed(); OUT_DIR.mkdir(parents=True, exist_ok=True)
    dev = torch.device("cuda" if torch.cuda.is_available() else "cpu"); print("Device:", dev)
    tl, vl = loaders(); m = build().to(dev)
    crit = nn.CrossEntropyLoss(label_smoothing=0.1)
    opt = optim.AdamW(m.parameters(), lr=LR, weight_decay=WD)
    sch = optim.lr_scheduler.OneCycleLR(opt, max_lr=LR, epochs=EPOCHS, steps_per_epoch=len(tl), pct_start=0.1, anneal_strategy="cos")
    best = 0.0
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
                "val_acc": acc, "epoch": ep, "model_name": "mobilenetv3_small_disease_v4"}, CKPT_PATH)
            print("  saved; per-class: " + " ".join(f"{per[i]:.0f}" for i in range(NUM)))
    print(f"\nBest val acc: {best:.2f}%")
    ck = torch.load(CKPT_PATH, map_location="cpu"); m.load_state_dict(ck["model_state_dict"]); export_onnx(m)
    print("Done -> convert_disease.py")


if __name__ == "__main__":
    main()
