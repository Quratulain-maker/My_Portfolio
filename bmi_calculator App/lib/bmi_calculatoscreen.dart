import 'package:flutter/material.dart';

class BMI_Calculatorscreen extends StatefulWidget{
  @override
  State<BMI_Calculatorscreen> createState() => _BMI_CalculatorscreenState();
}

var result = "";

var WeightController = TextEditingController();
var HeightController = TextEditingController();

Color? bgColor;


class _BMI_CalculatorscreenState extends State<BMI_Calculatorscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Center(child: Text("BMI Calculator")),
      ),
      body: Container(
        color: bgColor,
        child: Center(
          child: Container(
            width: 300,
            child: Column(
           mainAxisAlignment: MainAxisAlignment.start,

              children: [

                Text(
                  "Enter Your Management",
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
                ),

                SizedBox(height: 27),
                TextField(
                  textAlign:TextAlign.end,
                  controller: WeightController,
                  decoration: InputDecoration(
                   focusedBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(15),
                       borderSide: BorderSide(color: Color(0xFF21B89A))
                   ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Color(0xFF21B89A))
                    ),
                    disabledBorder:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Color(0xFF21B89A))
                    ) ,
                    prefixText: " Weight (kg)",
                      prefixStyle:TextStyle(fontSize: 25,fontWeight: FontWeight.w600,color: Color(0xFF21B89A)),),

                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 25),
                TextField(
                  textAlign:TextAlign.end,
                  controller: HeightController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)
                    ),
                    prefixText: " Height (feet)",
                    prefixStyle:TextStyle(fontSize: 25,fontWeight: FontWeight.w600,color: Color(0xFF21B89A)),
                  ),

                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor:Color(0xFF21B89A),
                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: const Size(200,62 ), ),
                  onPressed: () {
                    var Weight = WeightController.text.toString();
                    var Height = HeightController.text.toString();

                    if (Weight != "" && Height != "") {
                      final weight = double.tryParse(WeightController.text);
                      final heightFeet = double.tryParse(HeightController.text);
                      final heightMeters = heightFeet! * 0.3048;
                      final bmi = weight! / (heightMeters * heightMeters);
                      var msg ="";
                      if(bmi>25){
                        msg="You are Over Weight!!";
                        bgColor=Colors.yellow;
                      }
                      else if(bmi < 18){
                        msg ="You are underWeight!!";
                        bgColor=Colors.blueGrey;

                      }
                      else{
                        msg = " You are Healthy!!";
                        bgColor=Colors.lightBlue;
                      }
                      setState(() {result = "$msg  Your BMI is :${bmi.toStringAsFixed(3)}";
                      });

                    }
                    else {
                      setState(() {
                        result = "Please fill all the required blanks";
                      });
                    }
                  },
                  child: Text("Calculate",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),),
                ),
                SizedBox(height:15),
                Text (result,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}