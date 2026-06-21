import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'homescreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(title: '',)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/img.png'),
              Text("WELCOME TO!" , style: TextStyle(fontSize: 40,fontWeight: FontWeight.w900),),
              Text(
                "BMI CALCULATOR",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 100),
              Text(
                "Calculate Your BMI ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Text(
                "ON THE GO!! ",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
        ]
                    ),




    ),
      ),

    );
  }
}
