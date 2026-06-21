import 'bmi_calculator_screen.dart' show BMI_Calculatorscreen;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Optionscreen extends StatelessWidget{
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
    SizedBox(height: 40),
         Text("Choose Option", style: TextStyle(fontSize: 25,fontWeight: FontWeight.w200),),

        ElevatedButton(onPressed: (){
          Navigator.push(context,
              MaterialPageRoute(builder : (context) => BMI_Calculatorscreen(),
              ));
        }, child: Text("Matric")),
         ElevatedButton(onPressed: (){

         }, child: Text("Imperial"))
         ]
    ),
),
   ),
   );
  }

}