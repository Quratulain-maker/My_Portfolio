import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var WeightController = TextEditingController();
  var HeightController = TextEditingController();
  var result = "";
var bgColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text("BMI Calculator"),
      ),
      body: Container(
        color: bgColor,
        child: Center(
          child: Container(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text(
                  "Enter Your Management",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 22),
                TextField(
                  controller: WeightController,
                  decoration: InputDecoration(
                    label: Text("Enter Your Weight (lbs)"),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 11),
                TextField(
                  controller: HeightController,
                  decoration: InputDecoration(
                    label: Text("Enter Your Height (in.)"),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    var Weight = WeightController.text.toString();
                    var Height = HeightController.text.toString();

                    if (Weight != "" && Height != "") {
                      double weightInPounds = double.parse(Weight);
                      double heightInInches = double.parse(Height);
                      double BMI = (weightInPounds * 703) / (heightInInches * heightInInches);
                      var msg ="";
                     if(BMI>25){
                      msg="You are Over Weight!!";
                      bgColor=Colors.primaries;
                     }
                     else if(BMI < 18){
                       msg ="You are underWeight!!";
                       bgColor=Colors.pink;

                     }
                     else{
                      msg = " You are Healthy!!";
                      bgColor=Colors.lightBlue;
                     }
                      setState(() {result = "$msg /n Your BMI is :${BMI.toStringAsFixed(3)}";
                      });

                    }
                    else {
                      setState(() {
                        result = "Please fill all the required blanks";
                      });
                    }
                  },
                  child: Text("Calculate"),
                ),
                 SizedBox(height:15),
                Text (result,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
