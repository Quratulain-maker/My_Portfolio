"""
Run the app's full 3-stage cascade over a folder of photos, offline.

Mirrors plant_classifier_service.dart exactly -- same models, same
preprocessing, same thresholds -- so a verdict here is what the phone shows.
Use it to check a retrained model against the real-world photos in Images/
before rebuilding the APK.

Run in `py311_ml` (needs tensorflow + pillow):
    python test_cascade.py [folder]
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image
import tensorflow as tf

ROOT = Path(__file__).resolve().parent
ML = ROOT / "assets" / "ml"
IMG_DIR = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("F:/Work/Abasyn Project/Images")

MEAN = np.array([0.485, 0.456, 0.406], np.float32)
STD = np.array([0.229, 0.224, 0.225], np.float32)
SIZE = 224

# --- thresholds, mirroring plant_classifier_service.dart ---
LEAF_THRESHOLD = 0.5
LEAF_CLASS_INDEX = 0
HEALTHY_CONFIDENCE = 0.70
DISEASE_MASS_CONFIDENCE = 0.60
DISEASE_NAME_CONFIDENCE = 0.55
APPLE_IDX = list(range(0, 6))
GRAPE_IDX = list(range(6, 16))
SCOPE = ["apple", "grape", "other"]


def load(name):
    it = tf.lite.Interpreter(model_path=str(ML / name))
    it.allocate_tensors()
    return it


def run(it, x):
    it.set_tensor(it.get_input_details()[0]["index"], x)
    it.invoke()
    return it.get_tensor(it.get_output_details()[0]["index"])[0]


def softmax(v):
    e = np.exp(v - v.max())
    return e / e.sum()


def _tensor(im):
    a = np.asarray(im.convert("RGB"), np.float32) / 255.0
    return ((a - MEAN) / STD)[None].astype(np.float32)   # NHWC


def squashed(img):
    """Whole frame -> 224x224. Keeps every pixel; no lesion cropped away."""
    # PIL BOX == the app's image.Interpolation.average (area-averaging).
    return _tensor(img.resize((SIZE, SIZE), Image.BOX))


def squared(img):
    """Centre-crop to 1:1 first, so the leaf keeps its true shape (see the Dart
    _squareCrop comment). Used for the leaf and crop-scope gates."""
    w, h = img.size
    s = min(w, h)
    box = ((w - s) // 2, (h - s) // 2, (w + s) // 2, (h + s) // 2)
    return _tensor(img.crop(box).resize((SIZE, SIZE), Image.BOX))


def classify(img, leaf, scope, disease, labels):
    xg, xd = squared(img), squashed(img)      # gates vs disease
    p_leaf = softmax(run(leaf, xg))[LEAF_CLASS_INDEX]
    if p_leaf < LEAF_THRESHOLD:
        return f"NOT A LEAF (p_leaf={p_leaf:.2f})"

    sp = softmax(run(scope, xg))
    si = int(sp.argmax())
    if si == 2:
        return f"OUT OF SCOPE -> other ({sp[2]:.2f}) [apple={sp[0]:.2f} grape={sp[1]:.2f}]"

    crop = "Apple" if si == 0 else "Grape"
    allowed = APPLE_IDX if si == 0 else GRAPE_IDX
    dp = softmax(run(disease, xd))
    masked = np.zeros_like(dp)
    masked[allowed] = dp[allowed]
    masked = masked / masked.sum()
    mi = int(masked.argmax()); mp = float(masked[mi])
    top = labels[mi]
    healthy = "healthy" in top.lower()

    # Mirror the Dart: judge on probability MASS, not the top class.
    healthy_prob = float(sum(masked[i] for i in allowed if "healthy" in labels[i].lower()))
    disease_prob = 1.0 - healthy_prob

    if healthy_prob >= HEALTHY_CONFIDENCE:
        verdict = f"{top} ({healthy_prob:.2f})"
    elif disease_prob >= DISEASE_MASS_CONFIDENCE:
        if not healthy and mp >= DISEASE_NAME_CONFIDENCE:
            verdict = f"{top} ({mp:.2f})"
        else:
            verdict = f"{crop} leaf -- DISEASED, type unknown (P_disease={disease_prob:.2f}, top={top} {mp:.2f})"
    else:
        verdict = f"UNCERTAIN -- retake (P_healthy={healthy_prob:.2f})"
    return f"{crop} [scope {sp[si]:.2f}] -> {verdict}"


def main():
    labels = (ML / "labels.txt").read_text(encoding="utf-8").strip().splitlines()
    leaf, scope, disease = load("leaf_detector.tflite"), load("crop_scope.tflite"), load("plant_disease_model.tflite")
    files = sorted(p for p in IMG_DIR.iterdir()
                   if p.suffix.lower() in {".jpg", ".jpeg", ".png", ".webp"})
    print(f"{len(files)} images from {IMG_DIR}\n")
    for p in files:
        print(f"{p.name}\n   {classify(Image.open(p), leaf, scope, disease, labels)}")


if __name__ == "__main__":
    main()
