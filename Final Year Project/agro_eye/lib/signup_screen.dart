import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ ADDED
import 'home_screen.dart';

// Using the consistent color palette
const Color _lightCenterColor = Color(0xFFF0FFF0);
const Color _lightEdgeColor = Color(0xFF4C9A40);
const Color _primaryGreen = Color(0xFF1E5B20);

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // ✅ ADDED: Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ ADDED: Firebase signup function
  Future<void> _registerUser() async {
    try {
      // Creates a new Firebase user
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException {
      // Shows Firebase error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup failed')));
    }
  }

  // Controllers for all requested fields
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // Error tracking variables for red borders
  bool _fNameError = false;
  bool _lNameError = false;
  bool _emailError = false;
  bool _passError = false;
  bool _confirmPassError = false;

  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  void _handleSignup() {
    setState(() {
      // Check for empty fields
      _fNameError = _fNameController.text.isEmpty;
      _lNameError = _lNameController.text.isEmpty;
      _emailError = _emailController.text.isEmpty;
      _passError = _passwordController.text.isEmpty;
      _confirmPassError = _confirmPassController.text.isEmpty;
    });

    if (!_fNameError &&
        !_lNameError &&
        !_emailError &&
        !_passError &&
        !_confirmPassError) {
      // Logic for password matching
      if (_passwordController.text != _confirmPassController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Success - Navigate to Login or Home
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account Created Successfully!'),
          backgroundColor: _primaryGreen,
        ),
      );
      _registerUser();
      Navigator.pop(context); // Go back to Login
    } else {
      // Show error message at bottom
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid information in all fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            radius: 1.5,
            colors: [Colors.white, _lightCenterColor, _lightEdgeColor],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.08),

              // App Logo
              Image.asset(
                'assets/images/agro_eye_logo.png',
                width: size.width * 0.25,
                height: size.height * 0.15,
                fit: BoxFit.contain,
              ),

              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: size.width * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: size.height * 0.03),

              // Form Fields
              _buildField(_fNameController, 'First Name', _fNameError),
              SizedBox(height: size.height * 0.02),
              _buildField(_lNameController, 'Last Name', _lNameError),
              SizedBox(height: size.height * 0.02),
              _buildField(_emailController, 'Email', _emailError),
              SizedBox(height: size.height * 0.02),

              // Password Field
              _buildField(
                _passwordController,
                'Password',
                _passError,
                isPass: true,
                visible: _isPasswordVisible,
                onToggle: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              SizedBox(height: size.height * 0.02),

              // Confirm Password Field
              _buildField(
                _confirmPassController,
                'Confirm Password',
                _confirmPassError,
                isPass: true,
                visible: _isConfirmVisible,
                onToggle: () =>
                    setState(() => _isConfirmVisible = !_isConfirmVisible),
              ),

              SizedBox(height: size.height * 0.05),

              // Signup Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.03),

              // Back to Login
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: Colors.black54),
                    children: [
                      TextSpan(
                        text: 'Log In',
                        style: TextStyle(
                          color: _primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to maintain consistency across all fields
  Widget _buildField(
    TextEditingController controller,
    String hint,
    bool hasError, {
    bool isPass = false,
    bool? visible,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: hasError ? Colors.red : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass ? !visible! : false,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 20,
          ),
          border: InputBorder.none,
          suffixIcon: isPass
              ? IconButton(
                  icon: Icon(
                    visible! ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black54,
                  ),
                  onPressed: onToggle,
                )
              : null,
        ),
      ),
    );
  }
}
