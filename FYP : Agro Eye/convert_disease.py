"""
Convert the retrained disease ONNX model (EfficientNet-B0, 16 classes) to TFLite.
Run in the `py311_ml` env. Writes:
  assets/ml/plant_disease_model.tflite
  assets/ml/labels.txt          (the app reads this for class names)
  assets/ml/model_metadata.json
Class order: Apple 0-5, Grape 6-15 (so the app can mask by crop).

Same two EfficientNet-B0 fixes as convert_crop_scope.py: a static input shape
(without it the converter emits Flex ops that tflite_flutter cannot run) and a
bypass of onnx2tf's sample-image download (numpy-2.x pickle bug). The result is
verified Flex-free before it goes into assets/.
"""
import json, shutil
from pathlib import Path

import numpy as np
import onnx2tf.onnx2tf as _o2

# Must be patched before onnx2tf.convert runs.
_o2.download_test_image_data = lambda: np.random.rand(20, 128, 128, 3).astype(np.float32)

import onnx2tf  # noqa: E402

ROOT = Path(__file__).resolve().parent
ONNX_PATH = ROOT / "output_effb0" / "best_disease.onnx"
TF_OUT_DIR = ROOT / "output_effb0" / "best_disease_tf"
ASSET_MODEL = ROOT / "assets" / "ml" / "plant_disease_model.tflite"
ASSET_LABELS = ROOT / "assets" / "ml" / "labels.txt"
ASSET_META = ROOT / "assets" / "ml" / "model_metadata.json"

CLASS_NAMES = [
    # Apple 0-5
    "Apple Scab", "Apple Black Rot", "Apple Cedar Rust",
    "Apple Black Spot", "Apple Brown Spot", "Apple Healthy",
    # Grape 6-15
    "Grape Black Rot", "Grape Esca", "Grape Leaf Blight", "Grape Anthracnose",
    "Grape Brown Spot", "Grape Downy Mildew", "Grape Mites", "Grape Powdery Mildew",
    "Grape Shot Hole", "Grape Healthy",
]
APPLE_INDICES = [0, 1, 2, 3, 4, 5]
GRAPE_INDICES = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15]


def convert(onnx_path, tf_out_dir):
    if tf_out_dir.exists(): shutil.rmtree(tf_out_dir)
    onnx2tf.convert(input_onnx_file_path=str(onnx_path), output_folder_path=str(tf_out_dir),
                    overwrite_input_shape=["input:1,3,224,224"],   # static -> no Flex ops
                    non_verbose=True)
    cands = sorted(tf_out_dir.glob("*_float32.tflite"))
    if not cands: raise RuntimeError("no *_float32.tflite generated")
    return cands[0]


def verify_runnable(tflite_path):
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
    if out.shape[-1] != len(CLASS_NAMES):
        raise RuntimeError(f"expected {len(CLASS_NAMES)} classes, got {out.shape}")
    print(f"  verified: output {out.shape}, {len(ops)} op types, no Flex ops")


def main():
    if not ONNX_PATH.exists(): raise SystemExit(f"ONNX not found: {ONNX_PATH}")
    print("Converting ONNX -> TFLite")
    gen = convert(ONNX_PATH, TF_OUT_DIR)
    verify_runnable(gen)
    ASSET_MODEL.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(gen, ASSET_MODEL)
    ASSET_LABELS.write_text("\n".join(CLASS_NAMES) + "\n", encoding="utf-8")
    ASSET_META.write_text(json.dumps({
        "model_name": "efficientnet_b0_disease",
        "num_classes": len(CLASS_NAMES), "class_names": CLASS_NAMES,
        "apple_indices": APPLE_INDICES, "grape_indices": GRAPE_INDICES,
        "input_size": [224, 224], "input_tensor_format": "NHWC",
        "normalization": {"mean": [0.485, 0.456, 0.406], "std": [0.229, 0.224, 0.225]},
        "source": "PlantCity (codewithsk) apple+grape classes",
    }, indent=2), encoding="utf-8")
    print("\nDone")
    print("TFLite:", ASSET_MODEL, f"({ASSET_MODEL.stat().st_size/1e6:.2f} MB)")
    print("labels.txt + model_metadata.json updated")


if __name__ == "__main__":
    main()
