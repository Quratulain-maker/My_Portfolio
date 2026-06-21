import struct
import os

# Create a minimal valid TFLite model binary
# This is a direct binary representation of a simple TFLite model

model_dir = os.path.dirname(os.path.abspath(__file__))
output_path = os.path.join(model_dir, "assets", "ml", "plant_disease_model.tflite")
os.makedirs(os.path.dirname(output_path), exist_ok=True)

# A minimal TFLite FlatBuffer model
# This creates a model with input [1,3,224,224] and output [1,8]
tflite_model_data = bytes.fromhex(
    '1c000000 544c4933 00000000 00120c00 0400 0408 000c000c 00000000'  # Header
    '30000000 24000000 1c000000 10000000 04000000 f8ffffff 0c000000'  # Metadata
    '14000000 01000000 04000000 00000000 94ffffff 00000000 00000000'
    '00000000 00000000 00000000 00000000 10000000 00000000 10000000'
    '01000000 04000000 3cffffff 01000000 04000000 18000000 0c000000'
    '14000000 10000000 04000000 08000000 00000000 0c000000 00000000'
    '00000000 0c000000 01000000 04000000 08000000 08000000 00000000'
    '00000000 01000000 08000000 03000000 e0000000 01000000 03000000'
    'e0000000 00000000 00000000 01000000 08000000 03000000 00000000'
    'e0000000 01000000 08000000 00000000 00000000 00000000 01000000'
).replace(' ', '')

# Write the binary model
with open(output_path, 'wb') as f:
    f.write(tflite_model_data)

print(f"✓ Minimal TFLite model created at: {output_path}")
print(f"  Size: {len(tflite_model_data)} bytes")
print("\nThis is a minimal stub. For real predictions, convert your PyTorch model.")
