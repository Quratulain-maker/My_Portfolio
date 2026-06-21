import 'package:flutter/material.dart';
import 'services/plant_classifier_service.dart';

class ResultScreen extends StatelessWidget {
  final ClassificationResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final bool isHealthy = result.isHealthy;

    // Decide how to present the result based on which cascade stage it came from.
    IconData icon;
    Color color;
    String title;
    String message;
    bool showConfidence;

    if (!result.isLeaf) {
      icon = Icons.eco_outlined;
      color = Colors.orange;
      title = 'No leaf detected';
      message =
          "This doesn't look like a plant leaf. Please capture a clear, "
          "well-lit photo of a single Apple or Grape leaf.";
      showConfidence = false;
    } else if (!result.inScope) {
      icon = Icons.info_outline;
      color = Colors.blue;
      title = 'Not an Apple or Grape leaf';
      message =
          'This looks like a leaf, but AgroEye can currently only diagnose '
          'Apple and Grape leaves. Please scan an Apple or Grape leaf.';
      showConfidence = false;
    } else if (!result.isConfident) {
      icon = Icons.help_outline;
      color = Colors.blueGrey;
      title = 'Uncertain';
      message =
          'The image is unclear. Please retake a sharp, well-lit close-up of '
          'the leaf.';
      showConfidence = true;
    } else {
      icon = isHealthy ? Icons.check_circle : Icons.warning_amber_rounded;
      color = isHealthy ? Colors.green : Colors.orange;
      title = isHealthy ? 'Healthy' : 'Disease Detected';
      message = result.label;
      showConfidence = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('Result'),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        foregroundColor: const Color(0xFF0D2D1D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              if (showConfidence) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Confidence',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Text(
                      result.confidencePercentage,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: result.confidence,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      result.confidence > 0.7
                          ? Colors.green
                          : (result.confidence > 0.4
                                ? Colors.orange
                                : Colors.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}