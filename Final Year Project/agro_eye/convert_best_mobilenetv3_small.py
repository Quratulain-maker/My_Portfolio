import json
import shutil
from pathlib import Path

import torch
import torch.nn as nn
from torchvision import models
import onnx2tf

ROOT = Path(__file__).resolve().parent
CHECKPOINT_PATH = ROOT / "output_comparison" / "best_mobilenetv3_small.pth"
ONNX_PATH = ROOT / "output_comparison" / "best_mobilenetv3_small.onnx"
TF_OUT_DIR = ROOT / "output_comparison" / "best_mobilenetv3_small_tf"
ASSET_MODEL_PATH = ROOT / "assets" / "ml" / "plant_disease_model.tflite"
ASSET_METADATA_PATH = ROOT / "assets" / "ml" / "model_metadata.json"


def load_checkpoint(checkpoint_path: Path):
    checkpoint = torch.load(checkpoint_path, map_location="cpu")
    if not isinstance(checkpoint, dict):
        raise RuntimeError("Checkpoint is not a dictionary")

    state_dict = checkpoint.get("model_state_dict") or checkpoint.get("state_dict")
    if state_dict is None:
        raise RuntimeError("Could not find model_state_dict/state_dict in checkpoint")

    class_names = checkpoint.get("class_names")
    if not isinstance(class_names, list) or not class_names:
        raise RuntimeError("Checkpoint is missing class_names")

    return checkpoint, state_dict, class_names


def build_model(num_classes: int):
    model = models.mobilenet_v3_small(weights=None)
    in_features = model.classifier[-1].in_features
    model.classifier[-1] = nn.Linear(in_features, num_classes)
    return model


def export_onnx(model, onnx_path: Path):
    dummy_input = torch.randn(1, 3, 224, 224, dtype=torch.float32)
    torch.onnx.export(
        model,
        dummy_input,
        str(onnx_path),
        input_names=["input"],
        output_names=["output"],
        dynamic_axes={"input": {0: "batch_size"}, "output": {0: "batch_size"}},
        opset_version=13,
        do_constant_folding=True,
        dynamo=False,
    )


def convert_onnx_to_tflite(onnx_path: Path, tf_out_dir: Path):
    if tf_out_dir.exists():
        shutil.rmtree(tf_out_dir)

    onnx2tf.convert(
        input_onnx_file_path=str(onnx_path),
        output_folder_path=str(tf_out_dir),
        non_verbose=False,
    )

    float32_candidates = sorted(tf_out_dir.glob("*_float32.tflite"))
    if not float32_candidates:
        raise RuntimeError("Could not find generated *_float32.tflite file")

    return float32_candidates[0]


def write_metadata(class_names, checkpoint):
    metadata = {
        "model_name": "mobilenet_v3_small",
        "source_checkpoint": str(CHECKPOINT_PATH.name),
        "num_classes": len(class_names),
        "class_names": class_names,
        "input_size": [224, 224],
        "input_tensor_format": "NHWC",
        "normalization": {
            "mean": [0.485, 0.456, 0.406],
            "std": [0.229, 0.224, 0.225],
        },
        "checkpoint_info": {
            "model_name": checkpoint.get("model_name"),
            "val_acc": checkpoint.get("val_acc"),
            "epoch": checkpoint.get("epoch"),
        },
    }
    ASSET_METADATA_PATH.write_text(json.dumps(metadata, indent=2), encoding="utf-8")


def main():
    print("Loading checkpoint:", CHECKPOINT_PATH)
    checkpoint, state_dict, class_names = load_checkpoint(CHECKPOINT_PATH)

    print("Building MobileNetV3-Small with", len(class_names), "classes")
    model = build_model(len(class_names))

    missing, unexpected = model.load_state_dict(state_dict, strict=False)
    if missing:
        print("Missing keys:", len(missing))
    if unexpected:
        print("Unexpected keys:", len(unexpected))

    model.eval()

    print("Exporting ONNX:", ONNX_PATH)
    export_onnx(model, ONNX_PATH)

    print("Converting ONNX -> TFLite")
    generated_tflite = convert_onnx_to_tflite(ONNX_PATH, TF_OUT_DIR)

    ASSET_MODEL_PATH.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(generated_tflite, ASSET_MODEL_PATH)

    write_metadata(class_names, checkpoint)

    size_mb = ASSET_MODEL_PATH.stat().st_size / (1024 * 1024)
    print("\nDone")
    print("TFLite model:", ASSET_MODEL_PATH)
    print(f"Size: {size_mb:.2f} MB")
    print("Metadata updated:", ASSET_METADATA_PATH)


if __name__ == "__main__":
    main()
