import 'dart:ui'; // for ImageFilter.blur
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF6C63FF); // violet-indigo vibe
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
          ),
          headlineSmall: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      home: const MyHomePage(title: 'Counter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;

  void _incrementCounter() {
    setState(() => _counter++);
  }

  void _decrementCounter() {
    setState(() => _counter = (_counter > 0) ? _counter - 1 : 0);
  }

  void _resetCounter() {
    setState(() => _counter = 0);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.title,
          style: TextStyle(
            color: cs.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.9, -1),
                end: Alignment(1, 1),
                colors: [
                  Color(0xFF0F1025), // deep navy
                  Color(0xFF1C1F4A), // indigo
                  Color(0xFF2B2E68), // soft purple-blue
                ],
              ),
            ),
          ),

          // Glowing blurred circles (neon orbs)
          Positioned(
            top: -60,
            left: -40,
            child: _GlowCircle(color: const Color(0xFF7C4DFF).withOpacity(0.45), size: 220),
          ),
          Positioned(
            bottom: -50,
            right: -30,
            child: _GlowCircle(color: const Color(0xFF00E5FF).withOpacity(0.35), size: 200),
          ),
          Positioned(
            bottom: 160,
            left: -20,
            child: _GlowCircle(color: const Color(0xFFFF4081).withOpacity(0.28), size: 160),
          ),

          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12),
              child: _GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Current Count',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Animated count
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                        child: child,
                      ),
                      child: Text(
                        '$_counter',
                        key: ValueKey(_counter),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 90,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _RoundButton(
                          icon: Icons.remove_rounded,
                          label: 'Minus',
                          onTap: _decrementCounter,
                        ),
                        const SizedBox(width: 14),
                        _RoundButton(
                          icon: Icons.add_rounded,
                          label: 'Plus',
                          primary: true,
                          onTap: _incrementCounter,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _resetCounter,
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      label: const Text(
                        'Reset',
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft glowing circle using blur + opacity
class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// Glassmorphism card
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Rounded elevated button with subtle shine
class _RoundButton extends StatefulWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  State<_RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<_RoundButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.primary ? const Color(0xFF7C4DFF) : Colors.white24;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: _pressed ? baseColor.withOpacity(widget.primary ? 0.85 : 0.28) : baseColor,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: Colors.white.withOpacity(widget.primary ? 0.35 : 0.16),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: widget.primary
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8E66FF),
              Color(0xFF6241F2),
            ],
          )
              : null,
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: widget.primary ? Colors.white : Colors.white, size: 26),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
