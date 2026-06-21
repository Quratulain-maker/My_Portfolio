import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Privacy Policy",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E754C),
            ),
          ),
        ),
      ),

    );
  }
}
