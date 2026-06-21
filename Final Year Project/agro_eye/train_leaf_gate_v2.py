"""
Train an IMPROVED binary "leaf vs not-leaf" gate (MobileNetV3-Small).

v1 was trained only on clean PlantVillage lab images, so real-world phone photos
of leaves got rejected ("leaf detected as not-leaf"). v2 fixes that by adding
REAL-WORLD field leaves (PlantDoc) to the positive set, plus a diverse sample
across all PlantVillage species, with stronger augmentation.

  class 0 = leaf      (PlantDoc field leaves + PlantVillage, all species)
  class 1 = not_leaf  (Natural Images: person/car/cat/dog/flower/fruit/...)

Run in the `torch_cuda` env (GPU). Exports best_leaf_gate.pth + ONNX.
Convert with convert_leaf_gate.py (in the py311_ml env).
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
PV_COLOR = Path(
    r"C:/Users/atyab/.cache/kagglehub/datasets/abdallahalidev/plantvillage-dataset"
    r"/versions/3/plantvillage dataset/color"
)
PLANTDOC = Path(
    r"C:/Users/atyab/.cache/kagglehub/datasets/nirmalsankalana/plantdoc-dataset/versions/7"
)
NATURAL = Path(
    r"C:/Users/atyab/.cache/kagglehub/datasets/prasunroy/natural-images"
)

OUT_DIR = ROOT / "output_leaf"
CKPT_PATH = OUT_DIR / "best_leaf_gate.pth"
ONNX_PATH = OUT_DIR / "best_leaf_gate.onnx"

IMG_SIZE = 224
BATCH_SIZE = 32
EPOCHS = 10
LR = 1e-3
WEIGHT_DECAY = 1e-4
VAL_SPLIT = 0.15
PV_SAMPLE = 1500  # clean PlantVillage leaves to mix in (PlantDoc carries the rest)

IMAGENET_MEAN = [0.485, 0.456, 0.406]
IMAGENET_STD = [0.229, 0.224, 0.225]
CLASS_NAMES = ["leaf", "not_leaf"]
IMG_EXTS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def set_seed(seed=42):
    random.seed(seed); np.random.seed(seed)
    torch.manual_seed(seed); torch.cuda.manual_seed_all(seed)


def list_images(root: Path):
    return [p for p in root.rglob("*") if p.suffix.lower() in IMG_EXTS]


def gather():
    # --- positives: real-world field leaves (PlantDoc) ---
    plantdoc = list_images(PLANTDOC)
    random.shuffle(plantdoc)
    # --- positives: clean PlantVillage, sampled evenly across all species ---
    pv_dirs = [d for d in PV_COLOR.iterdir() if d.is_dir()]
    per = max(1, PV_SAMPLE // len(pv_dirs))
    pv = []
    for d in pv_dirs:
        imgs = [p for p in d.glob("*") if p.suffix.lower() in IMG_EXTS]
        random.shuffle(imgs)
        pv.extend(imgs[:per])
    random.shuffle(pv)
    positives = plantdoc + pv

    # --- negatives: real-world non-leaf objects ---
    nat_base = next(iter(NATURAL.rglob("natural_images")), NATURAL)
    negatives = list_images(nat_base)
    random.shuffle(negatives)

    # Balance the two sides
    n = min(len(positives), len(negatives))
    positives, negatives = positives[:n], negatives[:n]
    print(f"PlantDoc field leaves: {len(plantdoc)} | PlantVillage sample: {len(pv)}")
    print(f"Balanced -> leaf: {len(positives)}  not_leaf: {len(negatives)}")
    return positives, negatives


class LeafDataset(Dataset):
    def __init__(self, samples, transform):
        self.samples = samples; self.transform = transform
    def __len__(self): return len(self.samples)
    def __getitem__(self, idx):
        path, label = self.samples[idx]
        try:
            img = Image.open(path).convert("RGB")
        except Exception:
            img = Image.new("RGB", (IMG_SIZE, IMG_SIZE))
        return self.transform(img), label


def build_loaders():
    pos, neg = gather()
    samples = [(p, 0) for p in pos] + [(p, 1) for p in neg]
    random.shuffle(samples)
    split = int(len(samples) * (1 - VAL_SPLIT))
    train_s, val_s = samples[:split], samples[split:]

    # Stronger augmentation so real-world framing/lighting/backgrounds generalize.
    train_tf = transforms.Compose([
        transforms.RandomResizedCrop(IMG_SIZE, scale=(0.55, 1.0)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomVerticalFlip(p=0.3),
        transforms.RandomRotation(35),
        transforms.RandomPerspective(distortion_scale=0.3, p=0.4),
        transforms.ColorJitter(0.3, 0.3, 0.3, 0.08),
        transforms.RandomApply([transforms.GaussianBlur(3, (0.1, 2.0))], p=0.2),
        transforms.ToTensor(),
        transforms.Normalize(IMAGENET_MEAN, IMAGENET_STD),
        transforms.RandomErasing(p=0.2),
    ])
    val_tf = transforms.Compose([
        transforms.Resize((IMG_SIZE, IMG_SIZE)),
        transforms.ToTensor(),
        transforms.Normalize(IMAGENET_MEAN, IMAGENET_STD),
    ])
    train_loader = DataLoader(LeafDataset(train_s, train_tf), batch_size=BATCH_SIZE,
                              shuffle=True, num_workers=4, pin_memory=True)
    val_loader = DataLoader(LeafDataset(val_s, val_tf), batch_size=BATCH_SIZE,
                            shuffle=False, num_workers=4, pin_memory=True)
    return train_loader, val_loader


def build_model():
    m = models.mobilenet_v3_small(weights=MobileNet_V3_Small_Weights.IMAGENET1K_V1)
    m.classifier[-1] = nn.Linear(m.classifier[-1].in_features, len(CLASS_NAMES))
    return m


@torch.no_grad()
def evaluate(model, loader, device):
    model.eval()
    correct = total = 0
    tp = [0, 0]; cnt = [0, 0]
    for x, y in loader:
        x, y = x.to(device), y.to(device)
        pred = model(x).argmax(1)
        correct += (pred == y).sum().item(); total += y.size(0)
        for c in (0, 1):
            m = y == c; cnt[c] += m.sum().item()
            tp[c] += ((pred == y) & m).sum().item()
    acc = 100.0 * correct / max(total, 1)
    rec = [100.0 * tp[c] / max(cnt[c], 1) for c in (0, 1)]
    return acc, rec


def export_onnx(model):
    model.eval().cpu()
    dummy = torch.randn(1, 3, IMG_SIZE, IMG_SIZE, dtype=torch.float32)
    torch.onnx.export(model, dummy, str(ONNX_PATH),
                      input_names=["input"], output_names=["output"],
                      dynamic_axes={"input": {0: "batch_size"}, "output": {0: "batch_size"}},
                      opset_version=13, do_constant_folding=True, dynamo=False)
    print("ONNX exported:", ONNX_PATH)


def main():
    set_seed(42)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print("Device:", device)

    train_loader, val_loader = build_loaders()
    model = build_model().to(device)
    criterion = nn.CrossEntropyLoss(label_smoothing=0.05)
    optimizer = optim.AdamW(model.parameters(), lr=LR, weight_decay=WEIGHT_DECAY)
    scheduler = optim.lr_scheduler.OneCycleLR(
        optimizer, max_lr=LR, epochs=EPOCHS, steps_per_epoch=len(train_loader),
        pct_start=0.1, anneal_strategy="cos")

    best_acc = 0.0
    for epoch in range(EPOCHS):
        model.train()
        running = correct = total = 0
        for x, y in train_loader:
            x, y = x.to(device), y.to(device)
            optimizer.zero_grad()
            out = model(x); loss = criterion(out, y)
            loss.backward(); optimizer.step(); scheduler.step()
            running += loss.item() * x.size(0)
            correct += (out.argmax(1) == y).sum().item(); total += y.size(0)
        val_acc, rec = evaluate(model, val_loader, device)
        print(f"Epoch {epoch+1}/{EPOCHS}  loss={running/total:.4f}  "
              f"train_acc={100.0*correct/total:.2f}%  val_acc={val_acc:.2f}%  "
              f"recall[leaf]={rec[0]:.2f}%  recall[not_leaf]={rec[1]:.2f}%")
        if val_acc >= best_acc:
            best_acc = val_acc
            torch.save({"model_state_dict": model.state_dict(),
                        "class_names": CLASS_NAMES, "val_acc": val_acc,
                        "epoch": epoch, "model_name": "mobilenetv3_small_leaf_gate_v2"},
                       CKPT_PATH)
            print(f"  saved best ({val_acc:.2f}%)")

    print(f"\nBest val acc: {best_acc:.2f}%")
    ckpt = torch.load(CKPT_PATH, map_location="cpu")
    model.load_state_dict(ckpt["model_state_dict"])
    export_onnx(model)
    print("Done. Next: run convert_leaf_gate.py in the py311_ml env.")


if __name__ == "__main__":
    main()
