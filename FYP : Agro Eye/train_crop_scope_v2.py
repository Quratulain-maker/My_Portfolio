"""
Train an IMPROVED stage-2 "crop scope" gate (MobileNetV3-Small).

v1 was trained only on clean PlantVillage, so REAL-WORLD apple/grape leaves got
misrouted as "other". v2 adds PlantDoc field images (real-world apple & grape on
the in-scope side, real-world other species on the out side) so the gate learns
apple/grape features under real conditions.

  class 0 = apple_grape   (PlantVillage Apple/Grape  + PlantDoc apple/grape)
  class 1 = other         (PlantVillage other species + PlantDoc other species)

Run in `torch_cuda`. Exports best_crop_scope.pth + ONNX -> convert_crop_scope.py.
"""

import random
from pathlib import Path

import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from PIL import Image
from torch.utils.data import Dataset, DataLoader
from torchvision import models, transforms
from torchvision.models import MobileNet_V3_Small_Weights

ROOT = Path(__file__).resolve().parent
PV_COLOR = Path(r"C:/Users/atyab/.cache/kagglehub/datasets/abdallahalidev/plantvillage-dataset/versions/3/plantvillage dataset/color")
PLANTDOC = Path(r"C:/Users/atyab/.cache/kagglehub/datasets/nirmalsankalana/plantdoc-dataset/versions/7")

OUT_DIR = ROOT / "output_crop_scope"
CKPT_PATH = OUT_DIR / "best_crop_scope.pth"
ONNX_PATH = OUT_DIR / "best_crop_scope.onnx"

IMG_SIZE = 224
BATCH_SIZE = 32
EPOCHS = 12
LR = 1e-3
WEIGHT_DECAY = 1e-4
VAL_SPLIT = 0.15
PV_AG_SAMPLE = 2500       # clean apple/grape to mix in
PD_AG_OVERSAMPLE = 4      # repeat the (smaller) real-world apple/grape set
TARGET_PER_SIDE = 4500

IMAGENET_MEAN = [0.485, 0.456, 0.406]
IMAGENET_STD = [0.229, 0.224, 0.225]
CLASS_NAMES = ["apple_grape", "other"]
IMG_EXTS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def set_seed(s=42):
    random.seed(s); np.random.seed(s); torch.manual_seed(s); torch.cuda.manual_seed_all(s)


def imgs(d):
    return [p for p in d.glob("*") if p.suffix.lower() in IMG_EXTS]


def is_ag(name):
    n = name.lower()
    return "apple" in n or "grape" in n


def gather():
    # PlantVillage (clean)
    pv_ag, pv_other = [], []
    for d in PV_COLOR.iterdir():
        if not d.is_dir():
            continue
        (pv_ag if (d.name.startswith("Apple___") or d.name.startswith("Grape___")) else pv_other).extend(imgs(d))

    # PlantDoc (real-world) — classify each image by its parent folder name
    pd_ag, pd_other = [], []
    for p in PLANTDOC.rglob("*"):
        if p.suffix.lower() not in IMG_EXTS:
            continue
        (pd_ag if is_ag(p.parent.name) else pd_other).append(p)

    random.shuffle(pv_ag); random.shuffle(pv_other)
    random.shuffle(pd_ag); random.shuffle(pd_other)

    # In-scope: clean apple/grape (sampled) + real-world apple/grape (oversampled)
    positives = pv_ag[:PV_AG_SAMPLE] + pd_ag * PD_AG_OVERSAMPLE
    # Out-of-scope: real-world other species + clean other species (evenly)
    other_pool = pd_other + pv_other
    random.shuffle(other_pool)
    negatives = other_pool

    random.shuffle(positives)
    n = min(len(positives), len(negatives), TARGET_PER_SIDE)
    positives, negatives = positives[:n], negatives[:n]
    print(f"PV apple/grape: {len(pv_ag)} | PlantDoc apple/grape: {len(pd_ag)} (x{PD_AG_OVERSAMPLE})")
    print(f"PV other: {len(pv_other)} | PlantDoc other: {len(pd_other)}")
    print(f"Balanced -> apple_grape: {len(positives)}  other: {len(negatives)}")
    return positives, negatives


class DS(Dataset):
    def __init__(self, samples, tf): self.s = samples; self.tf = tf
    def __len__(self): return len(self.s)
    def __getitem__(self, i):
        path, label = self.s[i]
        try: im = Image.open(path).convert("RGB")
        except Exception: im = Image.new("RGB", (IMG_SIZE, IMG_SIZE))
        return self.tf(im), label


def build_loaders():
    pos, neg = gather()
    samples = [(p, 0) for p in pos] + [(p, 1) for p in neg]
    random.shuffle(samples)
    split = int(len(samples) * (1 - VAL_SPLIT))
    tr, va = samples[:split], samples[split:]
    train_tf = transforms.Compose([
        transforms.RandomResizedCrop(IMG_SIZE, scale=(0.55, 1.0)),
        transforms.RandomHorizontalFlip(), transforms.RandomVerticalFlip(p=0.3),
        transforms.RandomRotation(35),
        transforms.RandomPerspective(distortion_scale=0.3, p=0.4),
        transforms.ColorJitter(0.3, 0.3, 0.3, 0.08),
        transforms.RandomApply([transforms.GaussianBlur(3, (0.1, 2.0))], p=0.2),
        transforms.ToTensor(), transforms.Normalize(IMAGENET_MEAN, IMAGENET_STD),
        transforms.RandomErasing(p=0.2),
    ])
    val_tf = transforms.Compose([
        transforms.Resize((IMG_SIZE, IMG_SIZE)), transforms.ToTensor(),
        transforms.Normalize(IMAGENET_MEAN, IMAGENET_STD)])
    return (DataLoader(DS(tr, train_tf), BATCH_SIZE, shuffle=True, num_workers=4, pin_memory=True),
            DataLoader(DS(va, val_tf), BATCH_SIZE, shuffle=False, num_workers=4, pin_memory=True))


def build_model():
    m = models.mobilenet_v3_small(weights=MobileNet_V3_Small_Weights.IMAGENET1K_V1)
    m.classifier[-1] = nn.Linear(m.classifier[-1].in_features, len(CLASS_NAMES))
    return m


@torch.no_grad()
def evaluate(model, loader, device):
    model.eval(); correct = total = 0; tp = [0, 0]; cnt = [0, 0]
    for x, y in loader:
        x, y = x.to(device), y.to(device)
        pred = model(x).argmax(1)
        correct += (pred == y).sum().item(); total += y.size(0)
        for c in (0, 1):
            m = y == c; cnt[c] += m.sum().item(); tp[c] += ((pred == y) & m).sum().item()
    return 100.0*correct/max(total,1), [100.0*tp[c]/max(cnt[c],1) for c in (0,1)]


def export_onnx(model):
    model.eval().cpu()
    torch.onnx.export(model, torch.randn(1, 3, IMG_SIZE, IMG_SIZE), str(ONNX_PATH),
                      input_names=["input"], output_names=["output"],
                      dynamic_axes={"input": {0: "batch_size"}, "output": {0: "batch_size"}},
                      opset_version=13, do_constant_folding=True, dynamo=False)
    print("ONNX exported:", ONNX_PATH)


def main():
    set_seed(42); OUT_DIR.mkdir(parents=True, exist_ok=True)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu"); print("Device:", device)
    train_loader, val_loader = build_loaders()
    model = build_model().to(device)
    criterion = nn.CrossEntropyLoss(label_smoothing=0.05)
    optimizer = optim.AdamW(model.parameters(), lr=LR, weight_decay=WEIGHT_DECAY)
    scheduler = optim.lr_scheduler.OneCycleLR(optimizer, max_lr=LR, epochs=EPOCHS,
        steps_per_epoch=len(train_loader), pct_start=0.1, anneal_strategy="cos")
    best = 0.0
    for ep in range(EPOCHS):
        model.train(); run = correct = total = 0
        for x, y in train_loader:
            x, y = x.to(device), y.to(device)
            optimizer.zero_grad(); out = model(x); loss = criterion(out, y)
            loss.backward(); optimizer.step(); scheduler.step()
            run += loss.item()*x.size(0); correct += (out.argmax(1)==y).sum().item(); total += y.size(0)
        acc, rec = evaluate(model, val_loader, device)
        print(f"Epoch {ep+1}/{EPOCHS}  loss={run/total:.4f}  train_acc={100.0*correct/total:.2f}%  "
              f"val_acc={acc:.2f}%  recall[apple_grape]={rec[0]:.2f}%  recall[other]={rec[1]:.2f}%")
        if acc >= best:
            best = acc
            torch.save({"model_state_dict": model.state_dict(), "class_names": CLASS_NAMES,
                        "val_acc": acc, "epoch": ep, "model_name": "mobilenetv3_small_crop_scope_v2"}, CKPT_PATH)
            print(f"  saved best ({acc:.2f}%)")
    print(f"\nBest val acc: {best:.2f}%")
    ckpt = torch.load(CKPT_PATH, map_location="cpu"); model.load_state_dict(ckpt["model_state_dict"])
    export_onnx(model)
    print("Done. Next: run convert_crop_scope.py in the py311_ml env.")


if __name__ == "__main__":
    main()
