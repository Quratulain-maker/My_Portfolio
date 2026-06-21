import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'Home_screen.dart';

class Introduction_page1 extends StatefulWidget {
  @override
  State<Introduction_page1> createState() => _Introduction_page1State();
}

class _Introduction_page1State extends State<Introduction_page1> {
  final PageController _controller = PageController();

  // Save intro preference when user skips
  Future<void> _skipIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showIntro', false); // turn off intro
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home_screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E754C),
      body: PageView(
        controller: _controller,
        children: [
          // Page 1
          Container(
            child: Column(
              children: [
                const SizedBox(height: 70),
                const Center(
                  child: Text(
                    "EXCEL",
                    style: TextStyle(
                      fontSize: 80,
                      fontFamily: 'FontMain',
                      color: Colors.white,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    "FILE VIEWER",
                    style: TextStyle(
                      fontSize: 60,
                      fontFamily: 'FontMain',
                      color: Colors.white,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    "XLS File viewer allows you to view",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                const Center(
                  child: Text(
                    "XLS and read PDF file.",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 2,
                  effect: JumpingDotEffect(
                    activeDotColor: Colors.white,
                    dotColor: Colors.grey,
                    dotHeight: 13,
                    dotWidth: 13,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _skipIntro,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Skip",
                    style: TextStyle(fontSize: 23, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Page 2
          Container(
            child: Column(
              children: [
                const SizedBox(height: 70),
                const Center(
                  child: Text(
                    "EXCEL",
                    style: TextStyle(
                      fontSize: 80,
                      fontFamily: 'FontMain',
                      color: Colors.white,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    "FILE VIEWER",
                    style: TextStyle(
                      fontSize: 60,
                      fontFamily: 'FontMain',
                      color: Colors.white,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    "XLS File viewer allows you to view",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                const Center(
                  child: Text(
                    "all files Easily & Securely",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 2,
                  effect: JumpingDotEffect(
                    activeDotColor: Colors.grey,
                    dotColor: Colors.white,
                    dotHeight: 13,
                    dotWidth: 13,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _skipIntro,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Skip",
                    style: TextStyle(fontSize: 23, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
