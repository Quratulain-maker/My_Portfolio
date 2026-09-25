"""
Crop-scope v3 (EfficientNet-B0, 3 classes: apple / grape / other).

The 3-way gate tells the app apple vs grape so it can mask the disease output to
the right crop (kills grape->apple errors). "other" includes PlantCity's extra
crops (apricot, bean, cherry, corn, fig, loquat, pear, walnut, persimmon,
tomato) so unseen species get rejected.

Two changes over the previous run, both aimed at real-world grape photos that
were being read as apple or rejected as "other" when backlit / dark / autumn-red:

  * backbone MobileNetV3-Small -> EfficientNet-B0. The small net had the least
    capacity of the three models and was the only one still un-upgraded; it
    latched onto the well-lit, plain-background look of the lab datasets.
  * the strong photometric augs in augmentations.py, so those lighting
    conditions actually appear in training. Stronger augs need longer to
    converge, hence 25 epochs rather than 12.

Known gap: purple/autumn-red grape leaves (leafroll virus) are still read as
"other" -- the training data is essentially all green leaves. Forcing colour
invariance via augmentation was tried and made things worse; see
augmentations.py. Real purple-leaf photos are what this needs.

  0 = apple, 1 = grape, 2 = other
Runs on the dev box (cuda) or the Ascend 910B server (npu) -- see device.py.
Exports best_crop_scope.pth + ONNX -> convert_crop_scope.py
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
PC = PC_DIRS[0]                      # PlantCity train split

OUT_DIR = ROOT / "output_crop_scope"
CKPT_PATH = OUT_DIR / "best_crop_scope.pth"
ONNX_PATH = OUT_DIR / "best_crop_scope.onnx"

IMG_SIZE, BATCH, LR, WD, VAL_SPLIT = 224, 32, 1e-3, 1e-4, 0.15
EPOCHS = int(os.environ.get("AGROEYE_EPOCHS", "25"))
TARGET = 5000  # per class cap
IMAGENET_MEAN = [0.485, 0.456, 0.406]; IMAGENET_STD = [0.229, 0.224, 0.225]
CLASS_NAMES = ["apple", "grape", "other"]


def is_apple(n): return "apple" in n.lower()
def is_grape(n): return "grape" in n.lower()
def imgs(d): return [p for p in d.glob("*") if p.suffix.lower() in IMG_EXTS]


def collect():
    apple, grape = [], []
    other_groups = []  # list of lists, for even sampling

    # PlantVillage
    for d in PV.iterdir():
        if not d.is_dir(): continue
        fs = imgs(d)
        if d.name.startswith("Apple___"): apple += fs
        elif d.name.startswith("Grape___"): grape += fs
        else: other_groups.append(fs)
    # PlantDoc (parent-folder based)
    pd_apple, pd_grape, pd_other = [], [], {}
    for p in PD.rglob("*"):
        if p.suffix.lower() not in IMG_EXTS: continue
        nm = p.parent.name
        if is_apple(nm): pd_apple.append(p)
        elif is_grape(nm): pd_grape.append(p)
        else: pd_other.setdefault(nm, []).append(p)
    apple += pd_apple; grape += pd_grape
    other_groups += list(pd_other.values())
    # PlantCity train
    for d in PC.iterdir():
        if not d.is_dir(): continue
        fs = imgs(d)
        if is_apple(d.name): apple += fs
        elif is_grape(d.name): grape += fs
        else: other_groups.append(fs)

    # + real-world Kaggle data (Niphad field grape + Plant Pathology apple)
    from newdata_sources import cropscope_extra
    ce = cropscope_extra()
    apple += [Path(p) for p in ce["apple"]]
    grape += [Path(p) for p in ce["grape"]]

    # Even sampling for "other" across all its sub-groups
    random.shuffle(apple); random.shuffle(grape)
    for g in other_groups: random.shuffle(g)
    other = []
    per_group = max(1, TARGET // max(len(other_groups), 1))
    for g in other_groups: other += g[:per_group]
    random.shuffle(other)

    apple, grape, other = apple[:TARGET], grape[:TARGET], other[:TARGET]
    print(f"apple={len(apple)} grape={len(grape)} other={len(other)} (other groups={len(other_groups)})")
    return apple, grape, other


class DS(Dataset):
    def __init__(self, s, tf): self.s = s; self.tf = tf
    def __len__(self): return len(self.s)
    def __getitem__(self, i):
        p, y = self.s[i]
        try: im = load_rgb(p, IMG_SIZE)
        except Exception: im = Image.new("RGB", (IMG_SIZE, IMG_SIZE))
        return self.tf(im), y


def loaders(kind):
    a, g, o = collect()
    samples = [(p, 0) for p in a] + [(p, 1) for p in g] + [(p, 2) for p in o]
    random.shuffle(samples)
    sp = int(len(samples) * (1 - VAL_SPLIT)); tr, va = samples[:sp], samples[sp:]
    # colour_invariant=True was tried here and reverted -- it regressed the
    # backlit grape leaf and didn't fix the purple vine. See augmentations.py.
    train_tf = strong_train_transforms(IMG_SIZE, IMAGENET_MEAN, IMAGENET_STD)
    val_tf = val_transforms(IMG_SIZE, IMAGENET_MEAN, IMAGENET_STD)
    labels = [y for _, y in tr]; cc = np.bincount(labels, minlength=3); w = 1.0 / np.maximum(cc, 1)
    sw = [w[y] for y in labels]; sampler = WeightedRandomSampler(sw, len(sw), replacement=True)
    opts = loader_opts(kind)
    return (DataLoader(DS(tr, train_tf), BATCH, sampler=sampler, **opts),
            DataLoader(DS(va, val_tf), BATCH, shuffle=False, **opts))


def build():
    m = efficientnet_b0(weights=EfficientNet_B0_Weights.IMAGENET1K_V1)
    in_f = m.classifier[1].in_features
    m.classifier = nn.Sequential(nn.Dropout(p=0.3, inplace=True), nn.Linear(in_f, 3))
    return m


@torch.no_grad()
def evaluate(m, loader, dev):
    m.eval(); correct = total = 0; cm = np.zeros((3, 3), int)
    for x, y in loader:
        x, y = x.to(dev), y.to(dev); pred = m(x).argmax(1)
        correct += (pred == y).sum().item(); total += y.size(0)
        for t, p in zip(y.cpu().numpy(), pred.cpu().numpy()): cm[t, p] += 1
    rec = [100.0 * cm[i, i] / max(cm[i].sum(), 1) for i in range(3)]
    return 100.0 * correct / max(total, 1), rec


def export_onnx(m):
    m.eval().cpu()   # export from CPU on every backend
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
    crit = nn.CrossEntropyLoss(label_smoothing=0.05)
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
        acc, rec = evaluate(m, vl, dev)
        print(f"Epoch {ep+1}/{EPOCHS} loss={run/t:.3f} train={100.0*c/t:.1f}% val={acc:.2f}% "
              f"recall[apple/grape/other]={rec[0]:.1f}/{rec[1]:.1f}/{rec[2]:.1f}", flush=True)
        if acc >= best:
            best = acc
            torch.save({"model_state_dict": m.state_dict(), "class_names": CLASS_NAMES,
                "val_acc": acc, "epoch": ep, "model_name": "efficientnet_b0_crop_scope_v3"}, CKPT_PATH)
            print(f"  saved best ({acc:.2f}%)", flush=True)
    print(f"\nBest val acc: {best:.2f}%")
    ck = torch.load(CKPT_PATH, map_location="cpu"); m.load_state_dict(ck["model_state_dict"]); export_onnx(m)
    print("Done -> convert_crop_scope.py")


if __name__ == "__main__":
    main()
