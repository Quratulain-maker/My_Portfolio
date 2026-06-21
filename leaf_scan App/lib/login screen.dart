// lib/login_screen.dart
import 'package:firebase_auth/firebase_auth.dart'; //✅ ADDED
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Correct and single import
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- ADDED: Form Key and Controllers for Validation ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // ----------------------------------------------------

  // ✅ ADDED: Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // ✅ ADDED: Firebase login function
  Future<void> _loginUser() async {
    try {
      // Uses email & password entered by user
      await _auth.signInWithEmailAndPassword(
        email: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If login is successful, go to HomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Shows Firebase error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    }
  }

  // Custom colors for LeafScan branding
  static const primaryGreen = Color(0xFF4C843F);
  static const lightBackground = Color(0xFFF3F7EF);

  // State variable to manage password visibility
  bool _isPasswordVisible = false;

  // Validator function
  String? _validateRequiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty.';
    }
    return null;
  }

  // Helper method to build the standardized white input field
  Widget _buildInputField({
    required String hintText,
    required bool isPassword,
    required TextEditingController controller, // Added controller
  }) {
    bool shouldObscure = isPassword && !_isPasswordVisible;

    return TextFormField( // Changed from TextField to TextFormField
      controller: controller, // Linked controller
      validator: _validateRequiredField, // Added validator
      scrollPadding: const EdgeInsets.only(bottom: 120),
      obscureText: shouldObscure,
      style: const TextStyle(color: primaryGreen),
      cursorColor: primaryGreen,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        errorStyle: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold), // Style for error text
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
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: primaryGreen,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-screen background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/corn_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

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
                  stops: const [0.5, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // 3. Login Content
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: size.height * 0.15,
              left: 40.0,
              right: 40.0,
              bottom: 170.0,
            ),
            // --- ADDED: Form Widget ---
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  // Logo
                  Transform.translate(
                    offset: const Offset(0, 70),
                    child: Image.asset(
                      'assets/images/leaf_logo.png',
                      height: 220,
                    ),
                  ),

                  // Title and Tagline
                  const Text(
                    'LeafScan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize: 58,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Protecting your harvest.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize: 20,
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),

                  // Username Input
                  _buildInputField(
                    hintText: 'Username',
                    isPassword: false,
                    controller: _usernameController, // Linked controller
                  ),
                  const SizedBox(height: 15),

                  // Password Input
                  _buildInputField(
                    hintText: 'Password',
                    isPassword: true,
                    controller: _passwordController, // Linked controller
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  ElevatedButton(
                    onPressed: () {
                      // --- VALIDATION LOGIC ADDED ---
                      if (_formKey.currentState!.validate()) {
                        _loginUser(); // ✅ Firebase login
                      } else {
                        // Optional: Show a general error message if needed,
                        // though field validators will show errors automatically.
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(55),
                      backgroundColor: primaryGreen,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Guest Login Button
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    child: const Text(
                      'Login in as a Guest',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign Up.",
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
          ),
        ],
      ),
    );
  }
}