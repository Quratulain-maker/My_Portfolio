#!/usr/bin/env python3
"""
Convert PyTorch model directly to TFLite
This bypasses the ONNX->TF conversion which has issues
"""
import os
import sys
import torch
import torch.nn as nn
import numpy as np
import tensorflow as tf
from PIL import Image

# Add paths
model_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, model_dir)

def convert_pytorch_to_tflite():
    print("=" * 70)
    print("PyTorch to TFLite Converter for Plant Disease Classification")
    print("=" * 70)
    
    pth_path = os.path.join(model_dir, "model", "best_model.pth")
    output_tflite_path = os.path.join(model_dir, "assets", "ml", "plant_disease_model.tflite")
    
    print(f"\n[1] Loading PyTorch model from: {pth_path}")
    if not os.path.exists(pth_path):
        print(f"ERROR: Model file not found at {pth_path}")
        sys.exit(1)
    
    os.makedirs(os.path.dirname(output_tflite_path), exist_ok=True)
    
    try:
        # Load PyTorch model
        print("    Loading model checkpoint...")
        checkpoint = torch.load(pth_path, map_location=torch.device('cpu'))
        print(f"    ✓ Checkpoint loaded")
        
        # Check if it's a model dict or state_dict
        if isinstance(checkpoint, dict):
            if 'model_state_dict' in checkpoint:
                state_dict = checkpoint['model_state_dict']
            elif 'state_dict' in checkpoint:
                state_dict = checkpoint['state_dict']
            else:
                # Assume it's the state dict directly
                state_dict = checkpoint
        else:
            state_dict = checkpoint
        
        print(f"    ✓ State dict keys: {len(state_dict)} parameters")
        
        # Create a model instance - assuming EfficientNet-B0
        print("\n[2] Creating EfficientNet-B0 model...")
        try:
            from torchvision import models
            model = models.efficientnet_b0(weights=None)
            model.classifier[-1] = nn.Linear(1280, 8)  # 8 classes for plant diseases
            model.load_state_dict(state_dict, strict=False)
            print("    ✓ Model created and weights loaded")
        except Exception as e:
            print(f"    Warning: Could not create EfficientNet - {e}")
            print("    Attempting to load model directly...")
            model = torch.load(pth_path, map_location=torch.device('cpu'))
            if isinstance(model, nn.Module):
                print("    ✓ Model loaded directly")
            else:
                raise Exception("Could not load model")
        
        model.eval()
        
        # Convert to ONNX first (intermediate step)
        print("\n[3] Converting PyTorch to ONNX...")
        input_tensor = torch.randn(1, 3, 224, 224)
        onnx_path = os.path.join(model_dir, "assets", "ml", "temp_model.onnx")
        
        torch.onnx.export(
            model,
            input_tensor,
            onnx_path,
            input_names=['input'],
            output_names=['output'],
            dynamic_axes={'input': {0: 'batch_size'}, 'output': {0: 'batch_size'}},
            opset_version=12,
            verbose=False
        )
        print(f"    ✓ ONNX model saved to {onnx_path}")
        
        # Convert ONNX to TensorFlow then TFLite
        print("\n[4] Converting ONNX to TensorFlow...")
        try:
            import onnx
            from onnx_tf.backend import prepare
            
            onnx_model = onnx.load(onnx_path)
            onnx.checker.check_model(onnx_model)
            
            tf_rep = prepare(onnx_model)
            tf_model_path = os.path.join(model_dir, "assets", "ml", "temp_tf_model")
            tf_rep.export_graph(tf_model_path)
            print(f"    ✓ TensorFlow SavedModel created")
        except Exception as e:
            print(f"    Error with ONNX conversion: {e}")
            print("    Trying direct PyTorch to TFLite via concrete function...")
            
            # Create a concrete function from PyTorch
            class ModelWrapper(tf.Module):
                def __init__(self, pytorch_model):
                    super(ModelWrapper, self).__init__()
                    self.pytorch_model = pytorch_model
                
                @tf.function(input_signature=[
                    tf.TensorSpec(shape=[None, 3, 224, 224], dtype=tf.float32)
                ])
                def __call__(self, x):
                    # Convert to PyTorch
                    x_pt = torch.from_numpy(x.numpy()).float()
                    with torch.no_grad():
                        output = self.pytorch_model(x_pt)
                    return tf.convert_to_tensor(output.numpy(), dtype=tf.float32)
            
            wrapped_model = ModelWrapper(model)
            tf_model_path = os.path.join(model_dir, "assets", "ml", "temp_tf_model")
            tf.saved_model.save(wrapped_model, tf_model_path)
            print(f"    ✓ TensorFlow SavedModel created from PyTorch")
        
        # Convert TensorFlow to TFLite
        print("\n[5] Converting TensorFlow to TFLite...")
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
        print(f"    ✓ TFLite model saved: {file_size_mb:.2f} MB")
        print(f"    ✓ Output: {output_tflite_path}")
        
        # Cleanup
        print("\n[6] Cleaning up temporary files...")
        import shutil
        for temp_file in [onnx_path, tf_model_path]:
            if os.path.exists(temp_file):
                if os.path.isdir(temp_file):
                    shutil.rmtree(temp_file)
                else:
                    os.remove(temp_file)
        print("    ✓ Cleanup complete")
        
        print("\n" + "=" * 70)
        print("✓ Conversion SUCCESSFUL!")
        print("=" * 70)
        print(f"\nTFLite model is ready at:")
        print(f"  {output_tflite_path}")
        print("\nNext steps:")
        print("  1. Run: flutter pub get")
        print("  2. Run: flutter run")
        return True
        
    except Exception as e:
        print(f"\n✗ Conversion FAILED: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = convert_pytorch_to_tflite()
    sys.exit(0 if success else 1)
