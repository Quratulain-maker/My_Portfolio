import 'dart:async';
import 'package:flutter/material.dart';

/// Splash Screen
/// - Shows image + text below (as in Figma)
/// - After 5 seconds, automatically moves to Intro Screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 5 second delay before navigating to intro
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/intro');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _SplashContent(),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    const Color blueText = Color(0xFF6DA9FF);
    const Color greyText = Color(0xFF8E8E93);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // IMAGE
        Center(
          child: Image.asset(
            'assets/images/Splash.png', // <-- your Figma image
            width: 366,
            height: 217,
            fit: BoxFit.contain,
          ),
        ),

const  SizedBox(height: 40),
        // TITLE
        const Text(
          'Screen Sharing',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: blueText,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 9),

        // SUBTITLE
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            'Share your mobile phone screen with smart tv',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: greyText,
              fontSize: 25,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
