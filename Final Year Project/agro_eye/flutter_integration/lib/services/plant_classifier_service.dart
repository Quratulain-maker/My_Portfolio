// ============================================
// lib/services/plant_classifier_service.dart
// Plant Disease Classification Service
// ============================================

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class PlantClassifierService {
  static const String modelPath = 'assets/ml/plant_disease_model.tflite';
  static const String labelsPath = 'assets/ml/labels.txt';
  
  // ImageNet normalization values
  static const List<double> mean = [0.485, 0.456, 0.406];
  static const List<double> std = [0.229, 0.224, 0.225];
  
  static const int inputSize = 224;
  static const int numClasses = 8;
  
  Interpreter? _interpreter;
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
      // Load model
      _interpreter = await Interpreter.fromAsset(modelPath);
      print('✓ Model loaded successfully');
      
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
    
    // Preprocess
    final input = _preprocessImage(image);
    
    // Run inference
    final output = List.filled(numClasses, 0.0).reshape([1, numClasses]);
    _interpreter!.run(input, output);
    
    // Get probabilities with softmax
    final probabilities = _softmax(output[0].cast<double>());
    
    // Find top prediction
    int maxIndex = 0;
    double maxProb = probabilities[0];
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }
    
    // Create result
    return ClassificationResult(
      label: _labels[maxIndex],
      confidence: maxProb,
      allProbabilities: Map.fromIterables(_labels, probabilities),
      isHealthy: _labels[maxIndex].toLowerCase().contains('healthy'),
    );
  }

  /// Preprocess image for model input
  /// Model expects: [1, 3, 224, 224] with ImageNet normalization
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resize image
    final resized = img.copyResize(image, width: inputSize, height: inputSize);
    
    // Create input tensor [1, 3, 224, 224] - channels first (NCHW format)
    final input = List.generate(
      1,
      (_) => List.generate(
        3,
        (c) => List.generate(
          inputSize,
          (y) => List.generate(
            inputSize,
            (x) {
              final pixel = resized.getPixel(x, y);
              double value;
              
              // Get RGB values (0-255) and normalize
              switch (c) {
                case 0: // Red channel
                  value = pixel.r / 255.0;
                  break;
                case 1: // Green channel
                  value = pixel.g / 255.0;
                  break;
                case 2: // Blue channel
                  value = pixel.b / 255.0;
                  break;
                default:
                  value = 0.0;
              }
              
              // Apply ImageNet normalization
              return (value - mean[c]) / std[c];
            },
          ),
        ),
      ),
    );
    
    return input;
  }

  /// Apply softmax to convert logits to probabilities
  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);
    final exps = logits.map((l) => exp(l - maxLogit)).toList();
    final sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }
  
  double exp(double x) {
    // Simple exp implementation
    return x.isNaN ? 0 : (x > 700 ? double.maxFinite : (x < -700 ? 0 : _exp(x)));
  }
  
  double _exp(double x) {
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
    _interpreter?.close();
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
  
  /// Get top N predictions
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
