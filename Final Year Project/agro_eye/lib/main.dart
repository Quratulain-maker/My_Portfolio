import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import the new splash screen


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AgroEyeApp());
}

class AgroEyeApp extends StatelessWidget {
  const AgroEyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroEye',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // ... (your existing theme)
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const SplashScreen(), // **START with the SplashScreen**
    );
  }
}