// ============================================
// lib/screens/scan_screen.dart
// Plant Disease Scanner Screen
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/plant_classifier_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final PlantClassifierService _classifier = PlantClassifierService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  ClassificationResult? _result;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeClassifier();
  }

  Future<void> _initializeClassifier() async {
    try {
      await _classifier.initialize();
    } catch (e) {
      setState(() {
        _error = 'Failed to load model: $e';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _result = null;
          _error = null;
        });
        await _classifyImage();
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking image: $e';
      });
    }
  }

  Future<void> _classifyImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _classifier.classifyImage(_selectedImage!);
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Classification failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Plant Disease Scanner',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview Card
            _buildImageCard(),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            _buildActionButtons(),
            
            const SizedBox(height: 24),
            
            // Results Section
            if (_isLoading) _buildLoadingIndicator(),
            if (_error != null) _buildErrorCard(),
            if (_result != null && !_isLoading) _buildResultsCard(),
            
            const SizedBox(height: 16),
            
            // Instructions
            if (_selectedImage == null && _result == null) _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1,
          child: _selectedImage != null
              ? Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.eco,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select a leaf image',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Apple or Grape leaves only',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
            SizedBox(height: 16),
            Text(
              'Analyzing leaf...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 2,
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    final result = _result!;
    final isHealthy = result.isHealthy;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHealthy ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isHealthy ? Icons.check_circle : Icons.warning,
                    color: isHealthy ? Colors.green[700] : Colors.red[700],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHealthy ? 'Healthy' : 'Disease Detected',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isHealthy ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                      Text(
                        result.label,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Confidence Bar
            _buildConfidenceBar(result.confidence),
            
            const SizedBox(height: 20),
            
            // Top Predictions
            const Text(
              'All Predictions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...result.getTopPredictions(8).map((entry) {
              final isTopPrediction = entry.key == result.label;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildPredictionRow(
                  entry.key,
                  entry.value,
                  isTopPrediction,
                ),
              );
            }),
            
            // Recommendations
            if (!isHealthy) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildRecommendations(result.label),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBar(double confidence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Confidence',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '${(confidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: confidence,
            minHeight: 10,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              confidence > 0.7 ? Colors.green : (confidence > 0.4 ? Colors.orange : Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionRow(String label, double probability, bool isTop) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTop ? FontWeight.w600 : FontWeight.normal,
              color: isTop ? Colors.black : Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: probability,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isTop ? const Color(0xFF2E7D32) : Colors.grey[400]!,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            '${(probability * 100).toStringAsFixed(1)}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(String disease) {
    final recommendations = _getRecommendations(disease);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(rec)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getRecommendations(String disease) {
    final recommendations = {
      'Apple Scab': [
        'Remove and destroy fallen infected leaves',
        'Apply fungicides during early spring',
        'Improve air circulation by pruning',
        'Consider resistant apple varieties',
      ],
      'Apple Black Rot': [
        'Prune out dead or diseased branches',
        'Remove mummified fruits from trees',
        'Apply fungicide sprays during growing season',
        'Maintain good orchard sanitation',
      ],
      'Apple Cedar Rust': [
        'Remove nearby cedar/juniper trees if possible',
        'Apply fungicides in spring',
        'Plant resistant apple varieties',
        'Monitor for early signs of infection',
      ],
      'Grape Black Rot': [
        'Remove and destroy infected plant material',
        'Apply fungicides before and after bloom',
        'Ensure good air circulation in vineyard',
        'Prune vines properly to reduce humidity',
      ],
      'Grape Esca': [
        'Prune during dry weather',
        'Remove and burn affected wood',
        'Avoid large pruning wounds',
        'Consider trunk renewal for severely affected vines',
      ],
      'Grape Leaf Blight': [
        'Apply fungicides preventatively',
        'Improve vineyard drainage',
        'Remove infected leaves promptly',
        'Avoid overhead irrigation',
      ],
    };
    
    return recommendations[disease] ?? [
      'Consult with a local agricultural expert',
      'Take samples for laboratory analysis',
      'Monitor plant health regularly',
    ];
  }

  Widget _buildInstructions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'How to use',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(1, 'Take a clear photo of a leaf'),
            _buildInstructionStep(2, 'Ensure good lighting'),
            _buildInstructionStep(3, 'Focus on a single leaf'),
            _buildInstructionStep(4, 'Get results instantly'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.eco, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Supports Apple and Grape leaf detection',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }
}
