# ============================================
# FLUTTER INTEGRATION SETUP GUIDE
# Plant Disease Classifier for agro_eye
# ============================================

## OVERVIEW

This guide helps you integrate the plant disease classifier model
into your Flutter app. The app will be able to:
- Take photos or select from gallery
- Classify Apple and Grape leaf diseases
- Show confidence scores and recommendations

## STEP 1: CONVERT MODEL TO TFLITE

Run this on your PC where you have the trained model:

```bash
cd F:\Work\PlantDisease
python convert_to_tflite.py
```

This creates:
- `output/plant_disease_model.tflite` (~8MB)
- `output/labels.txt`

## STEP 2: ADD MODEL FILES TO FLUTTER PROJECT

Create the assets folder and copy files:

```
agro_eye/
├── assets/
│   └── ml/
│       ├── plant_disease_model.tflite   <-- Copy from output/
│       ├── labels.txt                    <-- Copy from output/
│       └── model_metadata.json           <-- Copy from output/
├── lib/
│   ├── services/
│   │   └── plant_classifier_service.dart <-- NEW FILE
│   ├── screens/
│   │   └── scan_screen.dart              <-- NEW FILE
│   └── main.dart
└── pubspec.yaml
```

## STEP 3: UPDATE PUBSPEC.YAML

Open `pubspec.yaml` and add:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # ADD THESE:
  tflite_flutter: ^0.11.0
  image_picker: ^1.0.7
  image: ^4.1.7
  permission_handler: ^11.3.0

# At the end, add assets:
flutter:
  uses-material-design: true
  
  assets:
    - assets/ml/plant_disease_model.tflite
    - assets/ml/labels.txt
    - assets/ml/model_metadata.json
```

Then run:
```bash
flutter pub get
```

## STEP 4: ANDROID SETUP

### 4a. Update android/app/build.gradle

Add inside `android { }` block:

```gradle
android {
    // ... existing code ...
    
    aaptOptions {
        noCompress 'tflite'
    }
    
    defaultConfig {
        // ... existing code ...
        ndk {
            abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'
        }
    }
}
```

### 4b. Update android/app/src/main/AndroidManifest.xml

Add permissions inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

<uses-feature android:name="android.hardware.camera" android:required="false"/>
```

## STEP 5: iOS SETUP

### 5a. Update ios/Runner/Info.plist

Add inside `<dict>`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan plant leaves</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select leaf images</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for camera</string>
```

### 5b. Update ios/Podfile

At the top, set minimum iOS version:
```ruby
platform :ios, '12.0'
```

Then run:
```bash
cd ios
pod install
cd ..
```

## STEP 6: COPY DART FILES

1. Create folder: `lib/services/`
2. Copy `plant_classifier_service.dart` to `lib/services/`
3. Create folder: `lib/screens/` (if not exists)
4. Copy `scan_screen.dart` to `lib/screens/`

## STEP 7: UPDATE MAIN.DART

Option A: Make ScanScreen your home screen:

```dart
import 'package:flutter/material.dart';
import 'screens/scan_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroEye',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ScanScreen(),
    );
  }
}
```

Option B: Add navigation button to existing screen:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanScreen()),
    );
  },
  child: const Text('Scan Leaf'),
)
```

## STEP 8: BUILD AND TEST

```bash
# For Android
flutter build apk --debug
flutter install

# For iOS (on Mac)
flutter build ios --debug
```

## TROUBLESHOOTING

### Error: "Failed to load model"
- Check that tflite file is in `assets/ml/`
- Verify pubspec.yaml has correct asset paths
- Run `flutter clean && flutter pub get`

### Error: "Conversion failed" (onnx-tf)
If ONNX to TFLite conversion fails, you can use the ONNX model directly:
- Install `onnx_flutter` package instead
- Modify classifier service to use ONNX runtime

### Error: "Permission denied"
- Ensure AndroidManifest.xml has camera permissions
- For Android 13+, add READ_MEDIA_IMAGES permission

### Model outputs wrong results
- Verify image preprocessing matches training:
  - Size: 224x224
  - Normalization: ImageNet mean/std
  - Channel order: RGB

## FILE CHECKSUMS

After setup, verify these files exist:
- [ ] assets/ml/plant_disease_model.tflite
- [ ] assets/ml/labels.txt
- [ ] lib/services/plant_classifier_service.dart
- [ ] lib/screens/scan_screen.dart

## SUPPORT

If you encounter issues:
1. Check Flutter version: `flutter --version`
2. Update packages: `flutter pub upgrade`
3. Clean build: `flutter clean`
4. Check device logs: `flutter logs`
