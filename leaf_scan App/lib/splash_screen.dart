// lib/splash_screen.dart
import 'package:flutter/material.dart';
// NOTE: Assuming file renamed to login_screen.dart
import 'login screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
// ... (class definition remains the same) ...
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // ... (initState, dispose, _buildLoadingDot remain the same) ...

  // Custom colors derived from your design
  static const primaryGreen = Color(0xFF4C843F);
  static const lightBackground = Color(0xFFF3F7EF);

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _startTimer();
  }

  _startTimer() {
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLoadingDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      body: Stack(
        children: [
          // 1. Full-screen background image
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/corn_bg.jpg'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // 2. White gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    lightBackground.withOpacity(0.9),
                    lightBackground,
                  ],
                  stops: const [0.5, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // 3. Centered Content (Logo and Text)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO BLOCK - Aggressively translated upwards
                Transform.translate(
                  offset: const Offset(0, 60),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      'assets/images/leaf_logo.png',
                      height: 220,
                    ),
                  ),
                ),

                // "LeafScan" Title
                const Text(
                  'LeafScan',
                  style: TextStyle(
                    fontSize: 58,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),

                // "Protecting your harvest." Tagline
                const Text(
                  'Protecting your harvest.',
                  style: TextStyle(
                    fontSize: 20,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 175),
              ],
            ),
          ),

          // 4. Bottom Loading Indicator
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Loading resources...',
                    style: TextStyle(fontSize: 20, color: primaryGreen),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLoadingDot(primaryGreen),
                      const SizedBox(width: 8),
                      _buildLoadingDot(primaryGreen.withOpacity(0.6)),
                      const SizedBox(width: 8),
                      _buildLoadingDot(primaryGreen.withOpacity(0.3)),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}