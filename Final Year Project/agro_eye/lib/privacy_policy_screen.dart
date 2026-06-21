import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
            Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.lock_shield_fill,
                  size: 46,
                  color: darkGreen,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Your Privacy Matters',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Agro Eye is designed to help users scan crop leaves and detect possible plant diseases. We respect your privacy and aim to keep your data safe.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 28),

            _section(
              icon: CupertinoIcons.photo_fill,
              title: 'Image Usage',
              text:
              'Images selected from your camera or gallery are used only for plant disease detection inside the app.',
            ),
            _section(
              icon: CupertinoIcons.doc_text_fill,
              title: 'Scan History',
              text:
              'Your scan history may be saved locally on your device so you can view previous crop results later.',
            ),
            _section(
              icon: CupertinoIcons.lock_fill,
              title: 'Data Protection',
              text:
              'We do not sell or share your personal information. Stored scan records are used only to improve your app experience.',
            ),
            _section(
              icon: CupertinoIcons.trash_fill,
              title: 'Clear History',
              text:
              'You can clear your scan history anytime from the History screen using the delete option.',
            ),
            _section(
              icon: CupertinoIcons.info_circle_fill,
              title: 'App Purpose',
              text:
              'Agro Eye provides helpful detection results, but it should not replace professional agricultural advice.',
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