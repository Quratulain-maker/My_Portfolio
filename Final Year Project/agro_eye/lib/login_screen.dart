import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; //✅ ADDED

const Color _lightCenterColor = Color(0xFFF0FFF0);
const Color _lightEdgeColor = Color(0xFF4C9A40);
const Color _primaryGreen = Color(0xFF1E5B20);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ✅ ADDED: Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ ADDED: Firebase login function
  Future<void> _loginUser() async {
    try {
      // Uses email & password entered by user
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If login is successful, go to HomeScreen
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      // Shows Firebase error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    }
  }

  final bool _rememberMe = false;
  bool _isPasswordVisible = false;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variables to track if fields are empty for custom red borders
  bool _emailHasError = false;
  bool _passwordHasError = false;

  void _guestLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  void _handleLogin() {
    setState(() {
      // Check if fields are empty
      _emailHasError = _emailController.text.isEmpty;
      _passwordHasError = _passwordController.text.isEmpty;
    });

    if (!_emailHasError && !_passwordHasError) {
      //success login
      _loginUser();
    } else {
      // **Requirement: Message at bottom of screen**
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid email and password'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 87),
              Image.asset(
                'assets/images/agro_eye_logo.png',
                width: size.width * 0.35,
                height: size.height * 0.15,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 19),
              Text(
                'WELCOME To\nAgro Eye',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.1,
                ),
              ),
              SizedBox(height: size.height * 0.05),

              // --- Email Field with Dynamic Red Border ---
              _buildCustomTextField(
                controller: _emailController,
                hint: 'Email',
                hasError: _emailHasError,
              ),

              SizedBox(height: size.height * 0.03),

              // --- Password Field with Dynamic Red Border ---
              _buildCustomTextField(
                controller: _passwordController,
                hint: 'Password',
                isPassword: true,
                hasError: _passwordHasError,
              ),

              // SizedBox(height: size.height * 0.01),
              // _buildRememberMeRow(size),
              SizedBox(height: size.height * 0.05),

              // Log In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              GestureDetector(
                onTap: () {
                  _guestLogin();
                },
                child: Text(
                  'Login in as Guest',
                  style: TextStyle(
                    fontSize: size.width * 0.035,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              _buildSignUpLink(context, size),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build fields with custom red borders
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hint,
    required bool hasError,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        // **This border highlights red if the field is empty**
        border: Border.all(
          color: hasError ? Colors.red : Colors.transparent,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        onChanged: (_) {
          // Remove red border as user starts typing
          if (hasError) {
            setState(() {
              if (isPassword) {
                _passwordHasError = false;
              } else {
                _emailHasError = false;
              }
            });
          }
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 25.0,
          ),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.black54,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildRememberMeRow(Size size) {
    return Row(
      children: [
        // Row(
        //   children: [
        //     Checkbox(
        //       value: _rememberMe,
        //       onChanged: (val) => setState(() => _rememberMe = val!),
        //       activeColor: _primaryGreen,
        //     ),
        //     Text(
        //       'Remember Me',
        //       style: TextStyle(
        //         fontSize: size.width * 0.035,
        //         color: Colors.black87,
        //       ),
        //     ),
        //   ],
        // ),
        GestureDetector(
          onTap: () {
            _guestLogin();
          },
          child: Text(
            'Login in as Guest',
            style: TextStyle(
              fontSize: size.width * 0.035,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink(BuildContext context, Size size) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      ),
      child: Text.rich(
        TextSpan(
          text: 'New To Agro Eye? ',
          style: TextStyle(fontSize: size.width * 0.04, color: Colors.black54),
          children: [
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
