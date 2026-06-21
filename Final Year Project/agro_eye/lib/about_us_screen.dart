import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const Color darkGreen = Color(0xFF0C3B2E);
  static const Color lightGreen = Color(0xFFEAF6EA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About Us',
          style: TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔹 Logo + Title
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/agro_eye_logo.png',
                    height: 90,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Agro Eye',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Scan • Protect • Grow',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Description
            const Text(
              'Agro Eye is an intelligent plant disease detection application designed to help farmers, gardeners, and agriculture enthusiasts identify crop diseases quickly and easily.',
              style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
            ),

            const SizedBox(height: 24),

            // 🔹 Sections
            _section(
              icon: CupertinoIcons.camera_fill,
              title: 'Smart Scanning',
              text:
              'Capture or upload leaf images and let AI analyze plant health instantly.',
            ),

            _section(
              icon: CupertinoIcons.leaf_arrow_circlepath,
              title: 'Accurate Detection',
              text:
              'Our system identifies diseases and provides confidence scores to help you understand results.',
            ),

            _section(
              icon: CupertinoIcons.clock_fill,
              title: 'Scan History',
              text:
              'Easily track your past scans and monitor plant health over time.',
            ),

            _section(
              icon: CupertinoIcons.sparkles,
              title: 'Our Vision',
              text:
              'To empower agriculture with AI technology and make plant disease detection accessible to everyone.',
            ),

            const SizedBox(height: 30),

            // 🔹 Footer
            Center(
              child: Column(
                children: const [
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.black45),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '© 2025 Agro Eye',
                    style: TextStyle(color: Colors.black45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0EFE0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: darkGreen, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}