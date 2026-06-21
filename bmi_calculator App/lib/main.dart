
import 'package:bmi_calculator/splashscreen.dart';
import 'package:flutter/material.dart';

import 'Optionscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        textTheme: TextTheme(
          headlineSmall: TextStyle(fontSize: 26,fontWeight:FontWeight.w400)
        )
      ),
      home:SplashScreen(),
    );
  }
}
