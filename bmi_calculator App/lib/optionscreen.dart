import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bmi_calculatoscreen.dart';

class Optionscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/img.png',
          height: 200,
            width: 200,),
              Text("WELCOME TO!" , style: TextStyle(fontSize: 40,fontWeight: FontWeight.w900),),
              Text(
                "BMI CALCULATOR",
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800,color: Colors.lightBlueAccent),
              ),
              SizedBox(height: 40),
              Text(
                "Choose Option",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 25,),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor:Color(0xFF21B89A),
                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: const Size(248,62 ), ),

                  onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BMI_Calculatorscreen(),
                    ),
                  );
                },
                child: Text("Matric",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),)),
              SizedBox(height: 20,),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor:Color(0xFF000000),
                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: const Size(248,62 ), ),
                  onPressed: () {}, child: Text("Imperial",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white), )),
            ],
          ),
        ),
      ),
    );
  }
}
