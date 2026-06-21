// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Core Application Imports (Ensure these files exist in your lib/ directory)
import 'login screen.dart';
import 'result_screen.dart';


// ----------------------------------------------------
// COLORS AND CONSTANTS
// ----------------------------------------------------
const Color primaryGreen = Color(0xFF4C843F);
const Color lightBackground = Color(0xFFF3F7EF);


// ------------------------------------------------------------------
// GLOBAL HELPER FUNCTION: buildCropCard (For consistent UI styling)
// ------------------------------------------------------------------
Widget buildCropCard({
  required String crop,
  required String imagePath,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Crop Image
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              imagePath,
              height: 140,
              width: 140,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 25),

          // Crop Text and Arrow
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  crop,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: primaryGreen,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


// ------------------------------------------------------------------
// HOME SCREEN WIDGET (Manages state and tab navigation)
// ------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  // Bottom Nav State
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreenContent(),
    const PrivacyPolicyScreen(),
    const AboutUsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // CORE CAMERA/DETECTION LOGIC (Called via HomeScreenContent)
  Future<void> _handleCameraCapture(String crop) async {
    await _handleImageSelection(source: ImageSource.camera, crop: crop);
  }

  Future<void> _handleGallerySelection() async {
    await _handleImageSelection(source: ImageSource.gallery, crop: 'Unknown');
  }

  Future<void> _handleImageSelection({
    required ImageSource source,
    required String crop
  }) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      // Placeholder validation logic
      bool isLeafDetected = true;
      if (isLeafDetected) {
        _navigateToResults(imageFile, crop);
      } else {
        _showInvalidInputMessage();
      }
    }
  }

  void _navigateToResults(File image, String crop) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          capturedImage: image,
          cropType: crop,
        ),
      ),
    );
  }

  void _showInvalidInputMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'You have to capture a leaf. Please ensure the leaf is clearly visible.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  // LOGOUT HELPER
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to the LoginScreen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // BOTTOM NAVIGATION BAR IMPLEMENTATION
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.privacy_tip_outlined), label: 'Privacy Policy'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'About Us'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        onTap: _onItemTapped,
      ),
    );
  }
}


// ------------------------------------------------------------------
// WIDGET: HomeScreenContent (The actual UI for the HOME tab)
// ------------------------------------------------------------------
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the state object to call its methods (handle capture, logout)
    final _homeState = context.findAncestorStateOfType<_HomeScreenState>();

    if (_homeState == null) {
      return const Center(child: Text("Initialization Error: Home State Missing"));
    }

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        title: const Text(
          'LeafScan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        actions: [
          // Logout Action Icon
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _homeState._showLogoutDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Select a crop to scan:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 1. Corn Card
            buildCropCard(
              crop: 'CORN',
              imagePath: 'assets/images/corn_plant.jpg',
              onTap: () => _homeState._handleCameraCapture('Corn'),
            ),
            const SizedBox(height: 20),

            // 2. Tomato Card
            buildCropCard(
              crop: 'TOMATO',
              imagePath: 'assets/images/tomato_plant.jpg',
              onTap: () => _homeState._handleCameraCapture('Tomato'),
            ),
            const SizedBox(height: 40),

            // 3. Dedicated Gallery Button
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library, size: 28, color: primaryGreen),
              label: const Text(
                'Scan from Gallery',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen),
              ),
              onPressed: () => _homeState._handleGallerySelection(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                backgroundColor: lightBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: primaryGreen, width: 2),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ------------------------------------------------------------------
// WIDGET: PrivacyPolicyScreen (Placeholder Tab Content)
// ------------------------------------------------------------------
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: const Center(child: Text('Details of the Privacy Policy.')),
    );
  }
}

// ------------------------------------------------------------------
// WIDGET: AboutUsScreen (Placeholder Tab Content)
// ------------------------------------------------------------------
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: const Center(child: Text('Information about LeafScan and the team.')),
    );
  }
}