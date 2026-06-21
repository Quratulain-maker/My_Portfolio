"""
Convert ONNX model to TFLite using onnx2tf
"""
import onnx2tf
import os

# Input and output paths
input_path = "model/plant_disease_model.onnx"
output_dir = "temp_tf_model"
tflite_output = "assets/ml/plant_disease_model.tflite"

# Ensure output directory exists
os.makedirs("assets/ml", exist_ok=True)

print("Converting ONNX to TFLite...")
print(f"Input: {input_path}")

# Convert directly to TFLite
onnx2tf.convert(
    input_onnx_file_path=input_path,
    output_folder_path=output_dir,
    non_verbose=False,
)

# Find the generated tflite file
import shutil
tflite_file = f"{output_dir}/plant_disease_model_float32.tflite"
if os.path.exists(tflite_file):
    shutil.copy(tflite_file, tflite_output)
    print(f"\n✓ Conversion complete!")
    print(f"✓ Model saved to: {tflite_output}")
    
    # Get file size
    size_mb = os.path.getsize(tflite_output) / (1024 * 1024)
    print(f"✓ Model size: {size_mb:.2f} MB")
else:
    print(f"Error: TFLite file not found at {tflite_file}")
    print("Available files in output dir:")
    for f in os.listdir(output_dir):
        print(f"  - {f}")
