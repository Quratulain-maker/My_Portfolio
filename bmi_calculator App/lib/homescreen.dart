import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Optionscreen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
var result = "";
class _MyHomePageState extends State<MyHomePage> {
  var WeightController = TextEditingController();
  var HeightController = TextEditingController();

  Color? bgColor;


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:   Center(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/img.png',
                  height: 200,
                  width: 200,),
                Text("WELCOME TO!" , style: TextStyle(fontSize: 40,fontWeight: FontWeight.w700),),
                Text(
                  "BMI CALCULATOR",
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.w400,color: Colors.lightBlueAccent),
                ),
                  SizedBox(height: 250,),

                    ElevatedButton(

                      style: ElevatedButton.styleFrom(backgroundColor:Color(0xFF21B89A),
                        shape: RoundedRectangleBorder(

                          borderRadius: BorderRadius.circular(15),
                        ),
                      minimumSize: const Size(248,62 ), ),

                      onPressed: () {  Navigator.push(context,
                          MaterialPageRoute(builder : (context) => Optionscreen(),
                          ));
                      }, child: Text("Calculate BMI",
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),)),

                  SizedBox(height: 20,),

                ElevatedButton(

                    style: ElevatedButton.styleFrom(backgroundColor:Color(0xFF000000),
                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(248,62 ), ),
                    onPressed: () {

                }, child: Text("Rate Us",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),))
              ]
          ),
        ),
      ),
    );
  }

}