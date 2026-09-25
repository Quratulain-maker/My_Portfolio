"""
Retrain the 8-class disease model (MobileNetV3-Small) to be real-world robust.

v1 (deployed) was trained only on clean PlantVillage, so real-world apple/grape
photos got low-confidence / shaky predictions. v2 mixes PlantDoc field images
into the 5 classes PlantDoc covers (Apple Scab/Cedar Rust/Healthy, Grape Black
Rot/Healthy); the other 3 classes stay PlantVillage-only.

CLASS ORDER MUST MATCH assets/ml/labels.txt exactly:
  0 Apple Scab   1 Apple Black Rot   2 Apple Cedar Rust   3 Apple Healthy
  4 Grape Black Rot   5 Grape Esca   6 Grape Leaf Blight   7 Grape Healthy

Run in `torch_cuda`. Exports best_disease.pth + ONNX -> convert_disease.py.
"""

import random
from pathlib import Path

import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from PIL import Image
from torch.utils.data import Dataset, DataLoader, WeightedRandomSampler
from torchvision import models, transforms
from torchvision.models import MobileNet_V3_Small_Weights

ROOT = Path(__file__).resolve().parent
PV = Path(r"C:/Users/atyab/.cache/kagglehub/datasets/abdallahalidev/plantvillage-dataset/versions/3/plantvillage dataset/color")
PD = Path(r"C:/Users/atyab/.cache/kagglehub/datasets/nirmalsankalana/plantdoc-dataset/versions/7")

OUT_DIR = ROOT / "output_disease"
CKPT_PATH = OUT_DIR / "best_disease.pth"
ONNX_PATH = OUT_DIR / "best_disease.onnx"

IMG_SIZE = 224
BATCH_SIZE = 32
EPOCHS = 15
LR = 1e-3
WEIGHT_DECAY = 1e-4
VAL_SPLIT = 0.15
MAX_PV_PER_CLASS = 1200   # cap clean images so big classes don't dominate
PD_OVERSAMPLE = 5         # repeat the (small) real-world sets

IMAGENET_MEAN = [0.485, 0.456, 0.406]
IMAGENET_STD = [0.229, 0.224, 0.225]
IMG_EXTS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}

# index -> (display name, PlantVillage folder, [PlantDoc folder names])
CLASS_DEF = [
    ("Apple Scab",        "Apple___Apple_scab",                          ["Apple_Scab_Leaf"]),
    ("Apple Black Rot",   "Apple___Black_rot",                           []),
    ("Apple Cedar Rust",  "Apple___Cedar_apple_rust",                    ["Apple_rust_leaf"]),
    ("Apple Healthy",     "Apple___healthy",                             ["Apple_leaf"]),
    ("Grape Black Rot",   "Grape___Black_rot",                           ["grape_leaf_black_rot"]),
    ("Grape Esca",        "Grape___Esca_(Black_Measles)",                []),
    ("Grape Leaf Blight", "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)",  []),
    ("Grape Healthy",     "Grape___healthy",                             ["grape_leaf"]),
]
CLASS_NAMES = [c[0] for c in CLASS_DEF]
NUM_CLASSES = len(CLASS_DEF)


def set_seed(s=42):
    random.seed(s); np.random.seed(s); torch.manual_seed(s); torch.cuda.manual_seed_all(s)


def imgs(d):
    return [p for p in d.glob("*") if p.suffix.lower() in IMG_EXTS]


def gather():
    # Map PlantDoc folder name -> class index
    pd_map = {}
    for idx, (_, _, pd_folders) in enumerate(CLASS_DEF):
        for f in pd_folders:
            pd_map[f] = idx
    pd_by_class = {i: [] for i in range(NUM_CLASSES)}
    for p in PD.rglob("*"):
        if p.suffix.lower() in IMG_EXTS and p.parent.name in pd_map:
            pd_by_class[pd_map[p.parent.name]].append(p)

    samples = []
    counts = []
    for idx, (name, pv_folder, _) in enumerate(CLASS_DEF):
        pv_imgs = imgs(PV / pv_folder)
        random.shuffle(pv_imgs)
        pv_imgs = pv_imgs[:MAX_PV_PER_CLASS]
        pd_imgs = pd_by_class[idx] * PD_OVERSAMPLE
        cls = [(p, idx) for p in pv_imgs] + [(p, idx) for p in pd_imgs]
        samples.extend(cls)
        counts.append((name, len(pv_imgs), len(pd_by_class[idx]), len(cls)))
    print("class                         PV   PD(unique)  total")
    for name, pv, pd, tot in counts:
        print(f"  {name:<22}{pv:>6}{pd:>10}{tot:>9}")
    return samples


class DS(Dataset):
    def __init__(self, samples, tf): self.s = samples; self.tf = tf
    def __len__(self): return len(self.s)
    def __getitem__(self, i):
        path, label = self.s[i]
        try: im = Image.open(path).convert("RGB")
        except Exception: im = Image.new("RGB", (IMG_SIZE, IMG_SIZE))
        return self.tf(im), label


def build_loaders():
    samples = gather()
    random.shuffle(samples)
    split = int(len(samples) * (1 - VAL_SPLIT))
    tr, va = samples[:split], samples[split:]

    train_tf = transforms.Compose([
        transforms.RandomResizedCrop(IMG_SIZE, scale=(0.6, 1.0)),
        transforms.RandomHorizontalFlip(), transforms.RandomVerticalFlip(p=0.3),
        transforms.RandomRotation(30),
        transforms.RandomPerspective(distortion_scale=0.25, p=0.3),
        transforms.ColorJitter(0.25, 0.25, 0.25, 0.06),
        transforms.RandomApply([transforms.GaussianBlur(3, (0.1, 1.5))], p=0.15),
        transforms.ToTensor(), transforms.Normalize(IMAGENET_MEAN, IMAGENET_STD),
        transforms.RandomErasing(p=0.2),
    ])
    val_tf = transforms.Compose([
        transforms.Resize((IMG_SIZE, IMG_SIZE)), transforms.ToTensor(),
        transforms.Normalize(IMAGENET_MEAN, IMAGENET_STD)])

    # Weighted sampler to balance the 8 classes (inverse frequency).
    labels = [l for _, l in tr]
    class_count = np.bincount(labels, minlength=NUM_CLASSES)
    class_w = 1.0 / np.maximum(class_count, 1)
    sample_w = [class_w[l] for l in labels]
    sampler = WeightedRandomSampler(sample_w, num_samples=len(sample_w), replacement=True)

    return (DataLoader(DS(tr, train_tf), BATCH_SIZE, sampler=sampler, num_workers=4, pin_memory=True),
            DataLoader(DS(va, val_tf), BATCH_SIZE, shuffle=False, num_workers=4, pin_memory=True))


def build_model():
    m = models.mobilenet_v3_small(weights=MobileNet_V3_Small_Weights.IMAGENET1K_V1)
    m.classifier[-1] = nn.Linear(m.classifier[-1].in_features, NUM_CLASSES)
    return m


@torch.no_grad()
def evaluate(model, loader, device):
    model.eval(); correct = total = 0
    cm = np.zeros((NUM_CLASSES, NUM_CLASSES), int)
    for x, y in loader:
        x, y = x.to(device), y.to(device)
        pred = model(x).argmax(1)
        correct += (pred == y).sum().item(); total += y.size(0)
        for t, p in zip(y.cpu().numpy(), pred.cpu().numpy()):
            cm[t, p] += 1
    per_class = [100.0 * cm[i, i] / max(cm[i].sum(), 1) for i in range(NUM_CLASSES)]
    return 100.0 * correct / max(total, 1), per_class


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
    criterion = nn.CrossEntropyLoss(label_smoothing=0.1)
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
        acc, per = evaluate(model, val_loader, device)
        print(f"Epoch {ep+1}/{EPOCHS}  loss={run/total:.4f}  train_acc={100.0*correct/total:.2f}%  val_acc={acc:.2f}%")
        if acc >= best:
            best = acc
            torch.save({"model_state_dict": model.state_dict(), "class_names": CLASS_NAMES,
                        "val_acc": acc, "epoch": ep, "model_name": "mobilenetv3_small_disease_v2"}, CKPT_PATH)
            print(f"  saved best ({acc:.2f}%)  per-class: " +
                  " ".join(f"{CLASS_NAMES[i].split()[-1][:4]}={per[i]:.0f}" for i in range(NUM_CLASSES)))
    print(f"\nBest val acc: {best:.2f}%")
    ckpt = torch.load(CKPT_PATH, map_location="cpu"); model.load_state_dict(ckpt["model_state_dict"])
    export_onnx(model)
    print("Done. Next: run convert_disease.py in the py311_ml env.")


if __name__ == "__main__":
    main()
