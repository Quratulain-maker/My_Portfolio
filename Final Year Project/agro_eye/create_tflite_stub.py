#!/usr/bin/env python3
"""
Create a functional TFLite stub model for testing
This creates a valid TFLite model that matches the expected input/output format
"""
import os
import sys
import numpy as np

try:
    import tensorflow as tf
except ImportError:
    print("Installing TensorFlow...")
    os.system(f"{sys.executable} -m pip install tensorflow-cpu --quiet")
    import tensorflow as tf

def create_tflite_stub():
    print("=" * 70)
    print("Creating TFLite Stub Model for Testing")
    print("=" * 70)
    
    model_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(model_dir, "assets", "ml", "plant_disease_model.tflite")
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    print("\n[1] Creating a simple neural network model...")
    print("    Input: [1, 3, 224, 224] - batch, channels, height, width")
    print("    Output: [1, 8] - batch, 8 disease classes")
    
    # Create a simple model that matches expected I/O
    inputs = tf.keras.Input(shape=(3, 224, 224), batch_size=1, name='input')
    
    #Permute to NHWC for processing
    x = tf.keras.layers.Permute((2, 3, 1))(inputs)  # (1, 3, 224, 224) -> (1, 224, 224, 3)
    
    # Simple CNN
    x = tf.keras.layers.Conv2D(16, 3, activation='relu', padding='same')(x)
    x = tf.keras.layers.MaxPooling2D()(x)
    x = tf.keras.layers.Conv2D(32, 3, activation='relu', padding='same')(x)
    x = tf.keras.layers.GlobalAveragePooling2D()(x)
    x = tf.keras.layers.Dense(64, activation='relu')(x)
    outputs = tf.keras.layers.Dense(8, activation='softmax', name='output')(x)
    
    model = tf.keras.Model(inputs=inputs, outputs=outputs)
    
    print(f"    ✓ Model created with {model.count_params():,} parameters")
    model.summary()
    
    print("\n[2] Converting to TFLite...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS]
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    tflite_model = converter.convert()
    
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    file_size = os.path.getsize(output_path) / 1024
    print(f"    ✓ TFLite model saved: {file_size:.1f} KB")
    
    print("\n[3] Testing the TFLite model...")
    interpreter = tf.lite.Interpreter(model_path=output_path)
    interpreter.allocate_tensors()
    
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"    Input: {input_details[0]['shape']}, dtype: {input_details[0]['dtype']}")
    print(f"    Output: {output_details[0]['shape']}, dtype: {output_details[0]['dtype']}")
    
    # Test with random input
    test_input = np.random.rand(1, 3, 224, 224).astype(np.float32)
    interpreter.set_tensor(input_details[0]['index'], test_input)
    interpreter.invoke()
    test_output = interpreter.get_tensor(output_details[0]['index'])
    
    print(f"    ✓ Test inference successful")
    print(f"    ✓ Output shape: {test_output.shape}, sum: {test_output.sum():.3f}")
    
    print("\n" + "=" * 70)
    print("✓ STUB MODEL CREATED SUCCESSFULLY!")
    print("=" * 70)
    print(f"\nModel location: {output_path}")
    print("\n⚠️  NOTE: This is a STUB model for testing the app.")
    print("   It will return random predictions.")
    print("   Replace it with the real converted model for actual disease detection.")
    print("\nNext steps:")
    print("  1. Run: flutter pub get")
    print("  2. Run: flutter run")
    print("  3. Test the app - it should work but with random results")
    print("  4. Convert the real PyTorch model later for accurate predictions")
    
if __name__ == "__main__":
    create_tflite_stub()
