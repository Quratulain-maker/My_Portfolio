import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

const Color _pureWhite = Colors.white;
const Color _glowGreen = Color(0xFFF0FFF0);
const Color _edgeGreen = Color(0xFF4C9A40);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late Animation<double> _breathAnimation;
  late Animation<double> _shadowOpacity;
  late Animation<double> _shadowWidth;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -15.0,
      end: 15.0,
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _breathAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _shadowOpacity = Tween<double>(
      begin: 0.12,
      end: 0.04,
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _shadowWidth = Tween<double>(
      begin: 0.35,
      end: 0.45,
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    Timer(
      const Duration(seconds: 4),
          () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [_pureWhite, _glowGreen, _edgeGreen],
            stops: [0.2, 0.4, 1.0],
          ),
        ),
        // Wrapping in a Center to prevent RenderFlex overflow
        child: Center(
          child: SingleChildScrollView( // Added to handle any overflow on smaller devices
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // 1. Logo and Dynamic Ground Reflection
                AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    return Column(
                      children: [
                        Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: Transform.scale(
                            scale: _breathAnimation.value,
                            child: Image.asset(
                              'assets/images/agro_eye_logo.png',
                              width: size.width * 0.53,
                              height: size.height * 0.45, // Reduced height slightly to fit screen
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Container(
                          width: size.width * _shadowWidth.value,
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E5B20).withOpacity(_shadowOpacity.value),
                                blurRadius: 15,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: size.height * 0.05),

                // 2. Title Text: AgroEye
                Text(
                  'AgroEye',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.8),
                    fontSize: size.width * 0.12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                  ),
                ),

                // 3. Subtitle Text
                Text(
                  'AI-Powered Crop Disease Detection',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}