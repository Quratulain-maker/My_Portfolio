
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
                 style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
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
                       bgColor=Colors.yellow;
                     }
                     else if(BMI < 18){
                       msg ="You are underWeight!!";
                       bgColor=Colors.pink;

                     }
                     else{
                       msg = " You are Healthy!!";
                       bgColor=Colors.lightBlue;
                     }
                     setState(() {result = "$msg  Your BMI is :${BMI.toStringAsFixed(3)}";
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



