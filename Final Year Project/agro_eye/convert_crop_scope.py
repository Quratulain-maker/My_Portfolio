"""
Convert the trained crop-scope ONNX model to TFLite for the Flutter app.
Run in the `py311_ml` env (has onnx2tf).
Produces assets/ml/crop_scope.tflite + assets/ml/crop_scope_metadata.json.
"""

import json
import shutil
from pathlib import Path

import onnx2tf

ROOT = Path(__file__).resolve().parent
ONNX_PATH = ROOT / "output_crop_scope" / "best_crop_scope.onnx"
TF_OUT_DIR = ROOT / "output_crop_scope" / "best_crop_scope_tf"
ASSET_MODEL_PATH = ROOT / "assets" / "ml" / "crop_scope.tflite"
ASSET_METADATA_PATH = ROOT / "assets" / "ml" / "crop_scope_metadata.json"

CLASS_NAMES = ["apple_grape", "other"]


def convert_onnx_to_tflite(onnx_path: Path, tf_out_dir: Path):
    if tf_out_dir.exists():
        shutil.rmtree(tf_out_dir)
    onnx2tf.convert(
        input_onnx_file_path=str(onnx_path),
        output_folder_path=str(tf_out_dir),
        non_verbose=False,
    )
    candidates = sorted(tf_out_dir.glob("*_float32.tflite"))
    if not candidates:
        raise RuntimeError("Could not find generated *_float32.tflite file")
    return candidates[0]


def write_metadata():
    metadata = {
        "model_name": "mobilenet_v3_small_crop_scope",
        "source_checkpoint": "best_crop_scope.pth",
        "num_classes": len(CLASS_NAMES),
        "class_names": CLASS_NAMES,
        "in_scope_index": 0,
        "input_size": [224, 224],
        "input_tensor_format": "NHWC",
        "normalization": {
            "mean": [0.485, 0.456, 0.406],
            "std": [0.229, 0.224, 0.225],
        },
    }
    ASSET_METADATA_PATH.write_text(json.dumps(metadata, indent=2), encoding="utf-8")


def main():
    if not ONNX_PATH.exists():
        raise SystemExit(f"ONNX not found: {ONNX_PATH}\nRun train_crop_scope.py first.")
    print("Converting ONNX -> TFLite")
    generated = convert_onnx_to_tflite(ONNX_PATH, TF_OUT_DIR)
    ASSET_MODEL_PATH.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(generated, ASSET_MODEL_PATH)
    write_metadata()
    size_mb = ASSET_MODEL_PATH.stat().st_size / (1024 * 1024)
    print("\nDone")
    print("TFLite model:", ASSET_MODEL_PATH, f"({size_mb:.2f} MB)")
    print("Metadata:", ASSET_METADATA_PATH)


if __name__ == "__main__":
    main()
