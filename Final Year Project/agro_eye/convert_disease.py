"""
Convert the retrained disease ONNX model to TFLite for the Flutter app.
Run in the `py311_ml` env (has onnx2tf).
Produces assets/ml/plant_disease_model.tflite + refreshes model_metadata.json.
Class order matches assets/ml/labels.txt.
"""

import json
import shutil
from pathlib import Path

import onnx2tf

ROOT = Path(__file__).resolve().parent
ONNX_PATH = ROOT / "output_disease" / "best_disease.onnx"
TF_OUT_DIR = ROOT / "output_disease" / "best_disease_tf"
ASSET_MODEL_PATH = ROOT / "assets" / "ml" / "plant_disease_model.tflite"
ASSET_METADATA_PATH = ROOT / "assets" / "ml" / "model_metadata.json"

CLASS_NAMES = [
    "Apple Scab", "Apple Black Rot", "Apple Cedar Rust", "Apple Healthy",
    "Grape Black Rot", "Grape Esca", "Grape Leaf Blight", "Grape Healthy",
]


def convert(onnx_path, tf_out_dir):
    if tf_out_dir.exists():
        shutil.rmtree(tf_out_dir)
    onnx2tf.convert(input_onnx_file_path=str(onnx_path),
                    output_folder_path=str(tf_out_dir), non_verbose=False)
    cands = sorted(tf_out_dir.glob("*_float32.tflite"))
    if not cands:
        raise RuntimeError("Could not find generated *_float32.tflite file")
    return cands[0]


def write_metadata():
    meta = {
        "model_name": "mobilenet_v3_small_disease_v2",
        "source_checkpoint": "best_disease.pth",
        "num_classes": len(CLASS_NAMES),
        "class_names": CLASS_NAMES,
        "input_size": [224, 224],
        "input_tensor_format": "NHWC",
        "normalization": {"mean": [0.485, 0.456, 0.406], "std": [0.229, 0.224, 0.225]},
        "note": "Retrained on PlantVillage + PlantDoc (real-world) for apple/grape.",
    }
    ASSET_METADATA_PATH.write_text(json.dumps(meta, indent=2), encoding="utf-8")


def main():
    if not ONNX_PATH.exists():
        raise SystemExit(f"ONNX not found: {ONNX_PATH}\nRun train_disease_v2.py first.")
    print("Converting ONNX -> TFLite")
    gen = convert(ONNX_PATH, TF_OUT_DIR)
    ASSET_MODEL_PATH.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(gen, ASSET_MODEL_PATH)
    write_metadata()
    print("\nDone")
    print("TFLite model:", ASSET_MODEL_PATH, f"({ASSET_MODEL_PATH.stat().st_size/1e6:.2f} MB)")
    print("Metadata:", ASSET_METADATA_PATH)


if __name__ == "__main__":
    main()
