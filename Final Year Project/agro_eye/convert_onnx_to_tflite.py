#!/usr/bin/env python3
"""
Convert ONNX model to TensorFlow Lite format
"""
import os
import sys
import numpy as np

def convert_onnx_to_tflite():
    try:
        import onnx
        import onnx_tf
        from onnx_tf.backend import prepare
        import tensorflow as tf
    except ImportError as e:
        print(f"Error: Missing required package - {e}")
        print("Please install: pip install onnx onnx_tf tensorflow")
        sys.exit(1)

    # Paths
    model_dir = os.path.dirname(os.path.abspath(__file__))
    onnx_model_path = os.path.join(model_dir, "model", "plant_disease_model.onnx")
    output_tflite_path = os.path.join(model_dir, "assets", "ml", "plant_disease_model.tflite")
    
    print(f"ONNX Model Path: {onnx_model_path}")
    print(f"Output TFLite Path: {output_tflite_path}")
    
    if not os.path.exists(onnx_model_path):
        print(f"Error: ONNX model not found at {onnx_model_path}")
        sys.exit(1)
    
    # Create output directory if it doesn't exist
    os.makedirs(os.path.dirname(output_tflite_path), exist_ok=True)
    
    print("\n[Step 1] Loading ONNX model...")
    onnx_model = onnx.load(onnx_model_path)
    onnx.checker.check_model(onnx_model)
    print("✓ ONNX model loaded and validated")
    
    print("\n[Step 2] Converting ONNX to TensorFlow...")
    tf_rep = prepare(onnx_model)
    print("✓ ONNX to TensorFlow conversion successful")
    
    print("\n[Step 3] Exporting to TensorFlow SavedModel format...")
    tf_model_path = os.path.join(model_dir, "assets", "ml", "tf_model")
    tf_rep.export_graph(tf_model_path)
    print(f"✓ TensorFlow model exported to {tf_model_path}")
    
    print("\n[Step 4] Converting TensorFlow to TFLite...")
    converter = tf.lite.TFLiteConverter.from_saved_model(tf_model_path)
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS,
        tf.lite.OpsSet.SELECT_TF_OPS
    ]
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    tflite_model = converter.convert()
    
    with open(output_tflite_path, 'wb') as f:
        f.write(tflite_model)
    
    file_size_mb = os.path.getsize(output_tflite_path) / (1024 * 1024)
    print(f"✓ TFLite model saved to {output_tflite_path}")
    print(f"  Model size: {file_size_mb:.2f} MB")
    
    print("\n[Step 5] Cleaning up temporary files...")
    import shutil
    if os.path.exists(tf_model_path):
        shutil.rmtree(tf_model_path)
    print("✓ Cleanup complete")
    
    print("\n" + "="*60)
    print("✓ Conversion Complete!")
    print("="*60)
    print(f"TFLite model ready at: {output_tflite_path}")
    print("\nNext steps:")
    print("1. Run: flutter pub get")
    print("2. Build/run the app: flutter run")
    return True

if __name__ == "__main__":
    convert_onnx_to_tflite()
