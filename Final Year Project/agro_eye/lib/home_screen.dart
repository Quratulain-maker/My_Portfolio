import 'package:agro_eye/my_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import 'login_screen.dart';
import 'services/plant_classifier_service.dart';
import 'result_screen.dart';
import 'history_storage.dart';

const Color _darkForestGreen = Color(0xFF0D2D1D);
const Color _blobGreen = Color(0xFF4C9A40);
const Color _backgroundWhite = Color(0xFFFFFFFF);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedCrop = 'Apple';
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final PlantClassifierService _classifier = PlantClassifierService();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeClassifier();
  }

  Future<void> _initializeClassifier() async {
    try {
      await _classifier.initialize();
    } catch (e) {
      setState(() {
        _error = 'Failed to load model: $e';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _error = null;
        });

        await _classifyImage();
        _showSuccessMessage();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      setState(() {
        _error = 'Error picking image: $e';
      });
    }
  }
  Future<void> _classifyImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _classifier.classifyImage(_image!);

      // Only save real diagnoses to history (skip "no leaf" / "not Apple-Grape").
      if (result.isLeaf && result.inScope) {
        await HistoryStorage.addHistory(
          crop: _selectedCrop,
          label: result.label,
          confidence: result.confidencePercentage,
          isHealthy: result.isHealthy,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: result),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Classification failed: $e';
        _isLoading = false;
      });
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Selected $_selectedCrop leaf image successfully."),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Dialog(
            backgroundColor: Colors.white.withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 30),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _darkForestGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: _darkForestGreen,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Log out?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _darkForestGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Are you sure you want to leave the Agro Eye home screen?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _darkForestGreen,
                            side: BorderSide(
                              color: _darkForestGreen.withOpacity(0.4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _darkForestGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 3,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundWhite,
      key: _scaffoldKey,
      drawer: const MyDrawer(),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(
                CupertinoIcons.line_horizontal_3,
                color: Colors.green,
                size: 30,
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: Size(size.width * 0.45, size.height * 0.22),
              painter: CornerBlobPainter(isTopRight: true),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: CustomPaint(
              size: Size(size.width * 0.45, size.height * 0.22),
              painter: CornerBlobPainter(isTopRight: false),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.05),
                Image.asset(
                  'assets/images/agro_eye_logo.png',
                  height: size.height * 0.18,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Agro Eye!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _darkForestGreen,
                  ),
                ),
                const Text(
                  'Scan • Protect • Grow',
                  style: TextStyle(fontSize: 22, color: Colors.black87),
                ),
                SizedBox(height: size.height * 0.06),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCropCard(
                        'Apple',
                        'assets/images/apple_card.png',
                        size,
                      ),
                      _buildCropCard(
                        'Grapes',
                        'assets/images/grapes_card.png',
                        size,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Image.asset(
                            'assets/images/gallery_icon.png',
                            height: 28,
                          ),
                          const SizedBox(width: 20),
                          const Text(
                            'Scan From Gallery',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isLoading) ...[
                  SizedBox(height: size.height * 0.03),
                  _buildLoadingCard(),
                ],
                if (_error != null) ...[
                  SizedBox(height: size.height * 0.03),
                  _buildErrorCard(),
                ],
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 30, bottom: 30),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: _showLogoutDialog,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                          color: _darkForestGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(String label, String imagePath, Size size) {
    bool isSelected = _selectedCrop == label;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCrop = label);
        _pickImage(ImageSource.camera);
      },
      child: Container(
        width: size.width * 0.39,
        height: size.height * 0.20,
        decoration: BoxDecoration(
          color: isSelected ? _darkForestGreen : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 13),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            SizedBox(width: 12),
            Text('Analyzing leaf...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red[100]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _error ?? 'Unknown error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }
}

class CornerBlobPainter extends CustomPainter {
  final bool isTopRight;

  CornerBlobPainter({required this.isTopRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _blobGreen;
    final path = Path();

    if (isTopRight) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width * 0.2, 0);
      path.quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.8,
        size.width,
        size.height,
      );
      path.close();
    } else {
      path.moveTo(0, size.height);
      path.lineTo(0, size.height * 0.2);
      path.quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.1,
        size.width,
        size.height,
      );
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}