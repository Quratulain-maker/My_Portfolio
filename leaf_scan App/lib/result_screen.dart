// lib/result_screen.dart
import 'package:flutter/material.dart';
import 'dart:io'; // Crucial for the File type

class ResultScreen extends StatelessWidget {
  // These final variables must be defined to match the navigation call
  final File capturedImage;
  final String cropType;

  const ResultScreen({
    super.key,
    required this.capturedImage,
    required this.cropType,
  });

  static const primaryGreen = Color(0xFF4C843F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Results', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Text('Placeholder for results.'),
      ),
    );
  }
}