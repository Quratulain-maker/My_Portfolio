import 'package:flutter/material.dart';

/// ---- Figma-style colors (tweak here if needed) ----
const kFigmaBlue = Color(0xFF6DA9FF);     // heading blue
const kFigmaGrey = Color(0xFF8E8E93);     // subtitle grey
const kDotInactive = Color(0xFFBFC3CA);   // pager dots inactive

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final _pages = const [
    (
    'assets/images/Intro 01.png',
    'Screen Sharing',
    'Seamless Screen Sharing for                 Smarter Collaboration'
    ),
    (
    'assets/images/Intro 02.png',
    'Screen Casting',
    'Seamless Casting, Limitless          Collaboration'
    ),
  ];

  void _finish() => Navigator.pushReplacementNamed(context, '/home');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // subtle Figma-like decorations (very simple)
            const _CornerLines(topLeft: true),
            const _CornerLines(topLeft: false),
            const _SoftCircle(offset: Offset(40, 80), size: 22),
            const _SoftCircle(offset: Offset(22, 760), size: 110),

            // content
            Column(
              children: [
                const SizedBox(height: 12),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) {
                      final (img, title, subtitle) = _pages[i];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(img, width: 280, height: 280, fit: BoxFit.contain),
                          const SizedBox(height: 30),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: kFigmaBlue,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28.0),
                            child: Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: kFigmaGrey,
                                fontSize: 25,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 16),
                      width: active ? 12 : 8,
                      height: active ? 12 : 8,
                      decoration: BoxDecoration(
                        color: active ? kFigmaBlue : kDotInactive,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),

                // bottom padding to keep like Figma spacing
                const SizedBox(height: 36),
              ],
            ),

            // Skip bottom-right
            Positioned(
              right: 18,
              bottom: 18,
              child: TextButton(
                onPressed: _page == _pages.length - 1
                    ? _finish
                    : () {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// --- tiny decoration widgets to mimic your Figma background ---
class _CornerLines extends StatelessWidget {
  final bool topLeft;
  const _CornerLines({required this.topLeft});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topLeft ? 10 : null,
      left: topLeft ? 14 : null,
      bottom: topLeft ? null : 28,
      right: topLeft ? null : 18,
      child: Opacity(
        opacity: 0.25,
        child: Row(
          children: List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.only(right: 6),
              width: 34,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFB7D1FF),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final Offset offset;
  final double size;
  const _SoftCircle({required this.offset, required this.size});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFEAF3FF),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
