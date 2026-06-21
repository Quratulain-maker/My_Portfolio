"""
Convert ONNX model to TFLite format for Flutter app
"""
import onnx
import tensorflow as tf
import numpy as np
from onnx_tf.backend import prepare

# Load ONNX model
print("Loading ONNX model...")
onnx_model = onnx.load("model/plant_disease_model.onnx")

# Convert to TensorFlow
print("Converting to TensorFlow...")
tf_rep = prepare(onnx_model)

# Export as TensorFlow saved model
print("Exporting to TensorFlow SavedModel...")
tf_rep.export_graph("temp_tf_model")

# Convert to TFLite
print("Converting to TFLite...")
converter = tf.lite.TFLiteConverter.from_saved_model("temp_tf_model")
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float32]

tflite_model = converter.convert()

# Save TFLite model
output_path = "assets/ml/plant_disease_model.tflite"
print(f"Saving TFLite model to {output_path}...")
with open(output_path, 'wb') as f:
    f.write(tflite_model)

print(f"✓ Conversion complete! Model saved to {output_path}")
print(f"✓ Model size: {len(tflite_model) / 1024 / 1024:.2f} MB")
