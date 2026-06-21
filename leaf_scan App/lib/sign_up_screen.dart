// lib/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:leaf_scan/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ ADDED


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Custom colors for LeafScan branding
  static const primaryGreen = Color(0xFF4C843F);
  static const lightBackground = Color(0xFFF3F7EF);

  // ✅ ADDED: Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ ADDED: Controllers to get user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ✅ ADDED: Firebase signup function
  Future<void> _registerUser() async {
    try {
      // Creates a new Firebase user
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If signup is successful, go to HomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Shows Firebase error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed')),
      );
    }
  }


  // State variables to manage password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Helper method to build the standardized white input field
  Widget _buildInputField({
    required String hintText,
    required bool isPassword,
    bool isConfirmPassword = false,
    TextEditingController? controller,
  }) {
    bool shouldObscure;

    if (isPassword && isConfirmPassword) {
      shouldObscure = !_isConfirmPasswordVisible;
    } else if (isPassword) {
      shouldObscure = !_isPasswordVisible;
    } else {
      shouldObscure = false;
    }

    return TextField(
      controller: controller,
      scrollPadding: const EdgeInsets.only(bottom: 120),
      obscureText: shouldObscure,
      style: const TextStyle(color: primaryGreen),
      cursorColor: primaryGreen,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: primaryGreen, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: primaryGreen, width: 2.0),
        ),

        // ---- PASSWORD VISIBILITY TOGGLE (EYE ICON) ----
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            (isConfirmPassword ? _isConfirmPasswordVisible : _isPasswordVisible)
                ? Icons.visibility : Icons.visibility_off,
            color: primaryGreen,
          ),
          onPressed: () {
            setState(() {
              if (isConfirmPassword) {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              } else {
                _isPasswordVisible = !_isPasswordVisible;
              }
            });
          },
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Title color is WHITE
        ),
        centerTitle: true,

        // --- CHANGES FOR DARK GREEN BACKGROUND ---
        backgroundColor: primaryGreen, // App Bar background is now dark green
        elevation: 0, // Keep elevation low for modern look
        iconTheme: const IconThemeData(color: Colors.white), // Back button color is WHITE
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Full-screen background image (Re-added)



          // 2. White Gradient Overlay
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
                  stops: const [0.001, 0.2, 1.40], // Reverting stops to safer defaults
                ),
              ),
            ),
          ),

          // 3. Sign Up Content
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: size.height * 0.15,
              left: 40.0,
              right: 40.0,
              bottom: 400.0, // Reverting bottom padding to a safer value
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                // Title (Simplified for Registration)
                const Text(
                  'Create Your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),

                // Full Name Input
                _buildInputField(
                  hintText: 'Full Name',
                  isPassword: false,
                ),
                const SizedBox(height: 15),

                // Email/Username Input
                _buildInputField(
                  hintText: 'Email Address',
                  isPassword: false,
                  controller: _emailController, // Linked controller
                ),
                const SizedBox(height: 15),

                // Password Input
                _buildInputField(
                  hintText: 'Password',
                  isPassword: true,
                  controller: _passwordController, // Linked controller
                ),
                const SizedBox(height: 15),

                // Confirm Password Input
                _buildInputField(
                  hintText: 'Confirm Password',
                  isPassword: true,
                  isConfirmPassword: true,
                ),
                const SizedBox(height: 30),

                // Sign Up Button
                ElevatedButton(
                  // onPressed: () {
                  //   // Navigate back to LoginScreen after successful registration
                  //   Navigator.of(context).pushReplacement(
                  //     MaterialPageRoute(builder: (context) => const HomeScreen()),
                  //   );
                  // },
                  onPressed: _registerUser, // ✅ Firebase signup
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(55),
                    backgroundColor: primaryGreen,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Back to Login Link
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back to the Login Screen
                  },
                  child: Text(
                    'Already have an account? Login.',
                    style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
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
}