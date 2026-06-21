import 'package:flutter/material.dart';

class ScreenSharingScreen extends StatelessWidget {
  const ScreenSharingScreen({super.key});

  static const Color kBlue = Color(0xFF6DA9FF);
  static const Color kGrey = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Screen Sharing'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Icon(Icons.cast_connected, size: 80, color: kBlue),
          const SizedBox(height: 16),
          const Text(
            'Start Screen Sharing',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kBlue,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Make sure your phone and TV are on the same Wi-Fi.\nPick a device and tap Start.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kGrey, height: 1.4),
          ),
          const SizedBox(height: 20),

          // Simple dummy device list (no packages, no errors)
          _deviceTile('Living Room TV'),
          const SizedBox(height: 10),
          _deviceTile('Bedroom Chromecast'),
          const SizedBox(height: 10),
          _deviceTile('Office Display'),
          const SizedBox(height: 24),

          // Start button (no real sharing yet — just a placeholder action)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing started (demo)')),
                );
              },
              child: const Text('Start Sharing'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceTile(String name) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEDEDED)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.tv_outlined, color: kBlue),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.radio_button_unchecked, color: Colors.black54),
        onTap: () {
          // selection logic can be added later
        },
      ),
    );
  }
}
