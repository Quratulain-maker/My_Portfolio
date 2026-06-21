import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scientific_calculator/home_screen.dart';

class Splash_screen extends StatefulWidget{
  @override
  State<Splash_screen> createState() => _Splash_screenState();
}

class _Splash_screenState extends State<Splash_screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Padding(
        padding: const EdgeInsets.only(left: 13),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 80,),

               Image.asset('assets/images/Logo.png',
              height: 150,
              width: 150,),

               SizedBox(height: 17,),
            Text("WELCOME!                                 Scientific Calculator",
              style: TextStyle(fontSize: 31,fontWeight: FontWeight.bold,fontFamily:'Roboto',color: Color(0xFF6F8794)),),
             SizedBox(height: 360,),
            Center(
              child: ElevatedButton.icon(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen(),));

              },
                  icon: const Icon(Icons.power_settings_new_rounded,color:Color(0xFF6F8794) ,),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                    )
                ),
                  label:Text("Get Started",style: TextStyle(color: Color(0xFF6F8794)) )


            )

        ),
        ]
      ),
      )
    );
  }
}