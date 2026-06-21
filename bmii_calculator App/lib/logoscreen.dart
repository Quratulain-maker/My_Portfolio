import 'package:bmii_calculator/Splash_screen.dart';
import 'package:bmii_calculator/homescreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Logoscreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
   return Scaffold(
 body: Center(
   child: Center(
     child: Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         Image.asset('assets/images/img.png'),

         SizedBox(height: 20,),

         ElevatedButton(onPressed: (){
            Navigator.push(context,
            MaterialPageRoute(builder : (context) => SplashScreen(),
            ));
         },
             child: Text("BMI CALCULATOR",
                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),),
         ),
     ],
   ),
 )
 ),
   );
  }

}