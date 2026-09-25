"""
Convert the trained crop-scope ONNX model to TFLite for the Flutter app.
Run in the `py311_ml` env (has onnx2tf + tensorflow).
Produces assets/ml/crop_scope.tflite + assets/ml/crop_scope_metadata.json.

Two fixes are needed for the EfficientNet-B0 backbone (both proven on the
disease model):
  * a static input shape -- without it the converter emits Flex ops, which
    tflite_flutter cannot run on-device.
  * bypassing onnx2tf's sample-image download, which trips a numpy-2.x pickle
    bug (the data is only used for accuracy checks we don't need).
The result is verified Flex-free before it's copied into assets/.
"""

import json
import shutil
from pathlib import Path

import numpy as np
import onnx2tf.onnx2tf as _o2

# Must be patched before onnx2tf.convert runs.
_o2.download_test_image_data = lambda: np.random.rand(20, 128, 128, 3).astype(np.float32)

import onnx2tf  # noqa: E402

ROOT = Path(__file__).resolve().parent
ONNX_PATH = ROOT / "output_crop_scope" / "best_crop_scope.onnx"
TF_OUT_DIR = ROOT / "output_crop_scope" / "best_crop_scope_tf"
ASSET_MODEL_PATH = ROOT / "assets" / "ml" / "crop_scope.tflite"
ASSET_METADATA_PATH = ROOT / "assets" / "ml" / "crop_scope_metadata.json"

CLASS_NAMES = ["apple", "grape", "other"]  # 0, 1, 2


def convert_onnx_to_tflite(onnx_path: Path, tf_out_dir: Path):
    if tf_out_dir.exists():
        shutil.rmtree(tf_out_dir)
    onnx2tf.convert(
        input_onnx_file_path=str(onnx_path),
        output_folder_path=str(tf_out_dir),
        overwrite_input_shape=["input:1,3,224,224"],   # static -> no Flex ops
        non_verbose=True,
    )
    candidates = sorted(tf_out_dir.glob("*_float32.tflite"))
    if not candidates:
        raise RuntimeError("Could not find generated *_float32.tflite file")
    return candidates[0]


def verify_runnable(tflite_path: Path):
    """A model with Flex ops loads here but dies on the phone -- catch it now."""
    import tensorflow as tf
    it = tf.lite.Interpreter(model_path=str(tflite_path))
    it.allocate_tensors()
    inp = it.get_input_details()[0]
    it.set_tensor(inp["index"], np.zeros(inp["shape"], np.float32))
    it.invoke()
    out = it.get_tensor(it.get_output_details()[0]["index"])
    ops = {d.get("op_name", "") for d in (it._get_ops_details() or [])}
    flex = sorted(o for o in ops if o.startswith("Flex"))
    if flex:
        raise RuntimeError(f"model uses Flex ops, unusable on-device: {flex}")
    print(f"  verified: output {out.shape}, {len(ops)} op types, no Flex ops")


def write_metadata():
    metadata = {
        "model_name": "efficientnet_b0_crop_scope_v3",
        "source_checkpoint": "best_crop_scope.pth",
        "num_classes": len(CLASS_NAMES),
        "class_names": CLASS_NAMES,
        "apple_index": 0,
        "grape_index": 1,
        "other_index": 2,
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
        raise SystemExit(f"ONNX not found: {ONNX_PATH}\nRun train_crop_scope_v3.py first.")
    print("Converting ONNX -> TFLite")
    generated = convert_onnx_to_tflite(ONNX_PATH, TF_OUT_DIR)
    verify_runnable(generated)
    ASSET_MODEL_PATH.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(generated, ASSET_MODEL_PATH)
    write_metadata()
    size_mb = ASSET_MODEL_PATH.stat().st_size / (1024 * 1024)
    print("\nDone")
    print("TFLite model:", ASSET_MODEL_PATH, f"({size_mb:.2f} MB)")
    print("Metadata:", ASSET_METADATA_PATH)


if __name__ == "__main__":
    main()
