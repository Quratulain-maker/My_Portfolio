import 'dart:async';

import 'package:flutter/material.dart';

import 'homescreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<SplashScreen> {
  @override
   void initState() {
    super.initState();
     Timer(Duration(seconds: 5), () {
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
                Image.asset('assets/images/img.png',
                height: 200,
                width: 200,),
                Text("WELCOME TO!" , style: TextStyle(fontSize: 40,fontWeight: FontWeight.w800),),
                Text(
                  "BMI CALCULATOR",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700,color: Colors.lightBlueAccent),
                ),
                SizedBox(height: 300),
                Text(
                  "Calculate Your BMI ",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400,color: Colors.lightBlueAccent),
                ),
                Text(
                  "On The Go!! ",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                ),
              ]
          ),




        ),
      ),

    );
  }
}