// ============================================
// lib/services/plant_classifier_service.dart
// Plant Disease Classification Service
// 3-stage cascade: leaf gate -> crop scope -> disease
// Uses TFLite for inference
// ============================================

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class PlantClassifierService {
  static const String modelPath = 'assets/ml/plant_disease_model.tflite';
  static const String labelsPath = 'assets/ml/labels.txt';
  // Stage-1 leaf detector (binary: leaf vs not_leaf). Run before disease model.
  static const String leafModelPath = 'assets/ml/leaf_detector.tflite';
  // Stage-2 crop-scope check (binary: apple_grape vs other species).
  static const String cropScopeModelPath = 'assets/ml/crop_scope.tflite';

  // ImageNet normalization values
  static const List<double> mean = [0.485, 0.456, 0.406];
  static const List<double> std = [0.229, 0.224, 0.225];

  static const int inputSize = 224;
  static const int numClasses = 8;

  // ---- Leaf gate thresholds (tunable) ----
  // Used only by the color-heuristic fallback when the leaf model is missing.
  static const double _minGreenRatio = 0.15;
  static const double _minGreenWithLesions = 0.05;
  static const double _minLeafRatioWithLesions = 0.35;
  // Min disease-model confidence to trust a prediction; below this -> "uncertain".
  static const double _minModelConfidence = 0.45;
  // Min P(leaf) from the stage-1 detector to proceed.
  static const double _leafModelThreshold = 0.5;
  static const int _leafClassIndex = 0;
  // Min P(apple/grape) from the stage-2 check to proceed to disease detection.
  static const double _inScopeThreshold = 0.5;
  static const int _inScopeIndex = 0;

  Interpreter? _interpreter;
  Interpreter? _leafInterpreter;
  Interpreter? _cropScopeInterpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  // Singleton pattern
  static final PlantClassifierService _instance =
      PlantClassifierService._internal();
  factory PlantClassifierService() => _instance;
  PlantClassifierService._internal();

  bool get isInitialized => _isInitialized;

  /// Initialize the models and labels
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final labelsData = await rootBundle.loadString(labelsPath);
      _labels = labelsData.split('\n').where((l) => l.isNotEmpty).toList();

      // Disease model (may fail if not present -> demo mode)
      try {
        _interpreter = await Interpreter.fromAsset(modelPath);
      } catch (e) {
        print('Warning: TFLite model not loaded - $e');
        print('App will use demo mode with random predictions');
      }

      // Stage-1 leaf detector. If absent, fall back to the color heuristic.
      try {
        _leafInterpreter = await Interpreter.fromAsset(leafModelPath);
      } catch (e) {
        print('Warning: leaf detector not loaded, using color heuristic - $e');
      }

      // Stage-2 crop-scope check. If absent, skip the scope gate.
      try {
        _cropScopeInterpreter = await Interpreter.fromAsset(cropScopeModelPath);
      } catch (e) {
        print('Warning: crop-scope model not loaded, scope check skipped - $e');
      }

      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Classify an image file through the 3-stage cascade.
  Future<ClassificationResult> classifyImage(File imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }

    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize once; reused by the gates and the model preprocessing.
    final resized = img.copyResize(image, width: inputSize, height: inputSize);

    // ---- Stage 1: leaf gate -------------------------------------------------
    final leaf = _detectLeaf(resized);
    if (!leaf.isLeaf) {
      return ClassificationResult(
        label: 'No leaf detected',
        confidence: leaf.score,
        allProbabilities: const {},
        isHealthy: false,
        isLeaf: false,
        leafScore: leaf.score,
      );
    }

    // ---- Stage 2: crop-scope gate ------------------------------------------
    // It's a leaf, but the disease model only knows Apple & Grape.
    final scope = _detectScope(resized);
    if (scope != null && !scope.inScope) {
      return ClassificationResult(
        label: 'Not an Apple or Grape leaf',
        confidence: scope.score,
        allProbabilities: const {},
        isHealthy: false,
        isLeaf: true,
        leafScore: leaf.score,
        inScope: false,
      );
    }

    // ---- Stage 3: disease classification -----------------------------------
    List<double> probabilities;
    if (_interpreter != null) {
      final input = _preprocessImage(resized);
      final output = List.filled(numClasses, 0.0).reshape([1, numClasses]);
      _interpreter!.run(input, output);
      probabilities = _softmax(output[0].cast<double>());
    } else {
      // Demo mode - generate semi-realistic probabilities
      final random = DateTime.now().millisecondsSinceEpoch % 100;
      if (random < 40) {
        probabilities = [0.05, 0.05, 0.05, 0.70, 0.05, 0.05, 0.02, 0.03];
      } else {
        final diseaseIdx = random % 6;
        probabilities = List.generate(8, (i) {
          if (i == diseaseIdx && i != 3 && i != 7) return 0.75;
          return 0.05;
        });
        final sum = probabilities.reduce((a, b) => a + b);
        probabilities = probabilities.map((p) => p / sum).toList();
      }
    }

    int maxIndex = 0;
    double maxProb = probabilities[0];
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }

    final bool isConfident = maxProb >= _minModelConfidence;

    return ClassificationResult(
      label: isConfident ? _labels[maxIndex] : 'Uncertain — unclear leaf image',
      confidence: maxProb,
      allProbabilities: Map.fromIterables(_labels, probabilities),
      isHealthy:
          isConfident && _labels[maxIndex].toLowerCase().contains('healthy'),
      isLeaf: true,
      leafScore: leaf.score,
      isConfident: isConfident,
      inScope: true,
    );
  }

  /// Stage-2 crop-scope check. Returns null when the model isn't loaded.
  _ScopeAnalysis? _detectScope(img.Image resized) {
    if (_cropScopeInterpreter == null) return null;
    try {
      final input = _preprocessImage(resized);
      final output = List.filled(2, 0.0).reshape([1, 2]);
      _cropScopeInterpreter!.run(input, output);
      final probs = _softmax(output[0].cast<double>());
      final inScopeProb = probs[_inScopeIndex];
      return _ScopeAnalysis(
        inScope: inScopeProb >= _inScopeThreshold,
        score: inScopeProb,
      );
    } catch (e) {
      print('Crop-scope inference failed, skipping scope check - $e');
      return null;
    }
  }

  /// Stage-1 leaf gate. Uses the trained binary leaf detector when it loaded,
  /// otherwise falls back to the color heuristic.
  _LeafAnalysis _detectLeaf(img.Image resized) {
    if (_leafInterpreter != null) {
      try {
        final input = _preprocessImage(resized);
        final output = List.filled(2, 0.0).reshape([1, 2]);
        _leafInterpreter!.run(input, output);
        final probs = _softmax(output[0].cast<double>());
        final leafProb = probs[_leafClassIndex];
        return _LeafAnalysis(
          isLeaf: leafProb >= _leafModelThreshold,
          score: leafProb,
        );
      } catch (e) {
        print('Leaf detector inference failed, using heuristic - $e');
      }
    }
    return _analyzeLeaf(resized);
  }

  /// Heuristic leaf detector (fallback when the trained model is unavailable).
  _LeafAnalysis _analyzeLeaf(img.Image image) {
    int green = 0;
    int lesion = 0;
    int total = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;

        final mx = math.max(r, math.max(g, b));
        final mn = math.min(r, math.min(g, b));
        final delta = mx - mn;

        double h;
        if (delta == 0) {
          h = 0;
        } else if (mx == r) {
          h = 60 * ((((g - b) / delta) % 6) + 6) % 360;
        } else if (mx == g) {
          h = 60 * (((b - r) / delta) + 2);
        } else {
          h = 60 * (((r - g) / delta) + 4);
        }
        final s = mx == 0 ? 0.0 : delta / mx;
        final v = mx;

        total++;
        if (h >= 60 && h <= 170 && s >= 0.15 && v >= 0.12) {
          green++;
        } else if (h >= 20 && h < 60 && s >= 0.25 && v >= 0.12 && v <= 0.95) {
          lesion++;
        }
      }
    }

    final greenRatio = total == 0 ? 0.0 : green / total;
    final lesionRatio = total == 0 ? 0.0 : lesion / total;
    final isLeaf = greenRatio >= _minGreenRatio ||
        (greenRatio >= _minGreenWithLesions &&
            (greenRatio + lesionRatio) >= _minLeafRatioWithLesions);
    final score = (greenRatio + 0.4 * lesionRatio).clamp(0.0, 1.0);
    return _LeafAnalysis(isLeaf: isLeaf, score: score);
  }

  /// Preprocess image for model input.
  /// Expects an image already resized to [inputSize] x [inputSize].
  /// Returns [1, 224, 224, 3] for TFLite (NHWC format - channels last)
  List<List<List<List<double>>>> _preprocessImage(img.Image resized) {
    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) => List.generate(3, (c) {
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
            return (value - mean[c]) / std[c];
          }),
        ),
      ),
    );
    return input;
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
    _interpreter?.close();
    _leafInterpreter?.close();
    _cropScopeInterpreter?.close();
    _isInitialized = false;
  }
}

/// Result of the leaf gate.
class _LeafAnalysis {
  final bool isLeaf;
  final double score;
  _LeafAnalysis({required this.isLeaf, required this.score});
}

/// Result of the crop-scope gate.
class _ScopeAnalysis {
  final bool inScope;
  final double score;
  _ScopeAnalysis({required this.inScope, required this.score});
}

/// Classification result
class ClassificationResult {
  final String label;
  final double confidence;
  final Map<String, double> allProbabilities;
  final bool isHealthy;

  /// Whether the image passed the leaf gate. If false, [label] is
  /// "No leaf detected" and no disease detection was performed.
  final bool isLeaf;

  /// How leaf-like the image looked (0..1), from the leaf gate.
  final double leafScore;

  /// Whether the disease model was confident enough to commit to a class.
  final bool isConfident;

  /// Whether the leaf is an Apple/Grape leaf (in scope for the disease model).
  /// If false, no disease detection was performed.
  final bool inScope;

  ClassificationResult({
    required this.label,
    required this.confidence,
    required this.allProbabilities,
    required this.isHealthy,
    this.isLeaf = true,
    this.leafScore = 1.0,
    this.isConfident = true,
    this.inScope = true,
  });

  String get confidencePercentage =>
      '${(confidence * 100).toStringAsFixed(1)}%';

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
