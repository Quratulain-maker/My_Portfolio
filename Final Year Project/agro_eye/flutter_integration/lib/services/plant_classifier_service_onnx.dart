// ============================================
// lib/services/plant_classifier_service_onnx.dart
// Alternative: Uses ONNX model directly
// Use this if TFLite conversion fails
// ============================================

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:image/image.dart' as img;

class PlantClassifierService {
  static const String modelPath = 'assets/ml/plant_disease_model.onnx';
  static const String labelsPath = 'assets/ml/labels.txt';
  
  // ImageNet normalization values
  static const List<double> mean = [0.485, 0.456, 0.406];
  static const List<double> std = [0.229, 0.224, 0.225];
  
  static const int inputSize = 224;
  static const int numClasses = 8;
  
  OrtSession? _session;
  List<String> _labels = [];
  bool _isInitialized = false;

  // Singleton pattern
  static final PlantClassifierService _instance = PlantClassifierService._internal();
  factory PlantClassifierService() => _instance;
  PlantClassifierService._internal();

  bool get isInitialized => _isInitialized;

  /// Initialize the model and labels
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize ONNX Runtime
      OrtEnv.instance.init();
      
      // Load model from assets
      final modelData = await rootBundle.load(modelPath);
      final bytes = modelData.buffer.asUint8List();
      
      // Create session options
      final sessionOptions = OrtSessionOptions();
      
      // Create session
      _session = OrtSession.fromBuffer(bytes, sessionOptions);
      print('✓ ONNX Model loaded successfully');
      
      // Load labels
      final labelsData = await rootBundle.loadString(labelsPath);
      _labels = labelsData.split('\n').where((l) => l.isNotEmpty).toList();
      print('✓ Labels loaded: ${_labels.length} classes');
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing classifier: $e');
      rethrow;
    }
  }

  /// Classify an image file
  Future<ClassificationResult> classifyImage(File imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Read and preprocess image
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    
    // Preprocess - model expects [1, 3, 224, 224]
    final inputData = _preprocessImage(image);
    
    // Create input tensor
    final inputTensor = OrtValueTensor.createTensorWithDataList(
      inputData,
      [1, 3, inputSize, inputSize],
    );
    
    // Run inference
    final inputs = {'input': inputTensor};
    final outputs = await _session!.runAsync(inputs);
    
    // Get output
    final outputTensor = outputs?['output'];
    if (outputTensor == null) {
      throw Exception('No output from model');
    }
    
    final outputData = outputTensor.value as List<List<double>>;
    final logits = outputData[0];
    
    // Release tensors
    inputTensor.release();
    outputs?.forEach((key, value) => value.release());
    
    // Apply softmax
    final probabilities = _softmax(logits);
    
    // Find top prediction
    int maxIndex = 0;
    double maxProb = probabilities[0];
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }
    
    return ClassificationResult(
      label: _labels[maxIndex],
      confidence: maxProb,
      allProbabilities: Map.fromIterables(_labels, probabilities),
      isHealthy: _labels[maxIndex].toLowerCase().contains('healthy'),
    );
  }

  /// Preprocess image for model input
  /// Returns flat Float32List for ONNX [1, 3, 224, 224]
  Float32List _preprocessImage(img.Image image) {
    // Resize image
    final resized = img.copyResize(image, width: inputSize, height: inputSize);
    
    // Create flat array for [1, 3, 224, 224] - NCHW format
    final data = Float32List(1 * 3 * inputSize * inputSize);
    
    int idx = 0;
    for (int c = 0; c < 3; c++) {
      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          double value;
          
          switch (c) {
            case 0:
              value = pixel.r / 255.0;
              break;
            case 1:
              value = pixel.g / 255.0;
              break;
            case 2:
              value = pixel.b / 255.0;
              break;
            default:
              value = 0.0;
          }
          
          // Apply ImageNet normalization
          data[idx++] = (value - mean[c]) / std[c];
        }
      }
    }
    
    return data;
  }

  /// Apply softmax to convert logits to probabilities
  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);
    final exps = logits.map((l) => _exp(l - maxLogit)).toList();
    final sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }
  
  double _exp(double x) {
    if (x.isNaN) return 0;
    if (x > 700) return double.maxFinite;
    if (x < -700) return 0;
    
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 100; i++) {
      term *= x / i;
      result += term;
      if (term.abs() < 1e-10) break;
    }
    return result;
  }

  /// Dispose resources
  void dispose() {
    _session?.release();
    OrtEnv.instance.release();
    _isInitialized = false;
  }
}

/// Classification result
class ClassificationResult {
  final String label;
  final double confidence;
  final Map<String, double> allProbabilities;
  final bool isHealthy;

  ClassificationResult({
    required this.label,
    required this.confidence,
    required this.allProbabilities,
    required this.isHealthy,
  });

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';
  
  List<MapEntry<String, double>> getTopPredictions(int n) {
    final sorted = allProbabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).toList();
  }
  
  @override
  String toString() {
    return 'ClassificationResult(label: $label, confidence: $confidencePercentage, isHealthy: $isHealthy)';
  }
}


// ============================================
// PUBSPEC.YAML for ONNX version:
// ============================================
// dependencies:
//   onnxruntime: ^1.17.0
//   image_picker: ^1.0.7
//   image: ^4.1.7
//   permission_handler: ^11.3.0
//
// flutter:
//   assets:
//     - assets/ml/plant_disease_model.onnx
//     - assets/ml/labels.txt
// ============================================
