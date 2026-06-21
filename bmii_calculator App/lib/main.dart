import 'package:bmii_calculator/logoscreen.dart';

import 'Optionscreen.dart';

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
      home:Logoscreen(),
    );
  }
}

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
                Image.asset('assets/images/img.png'),
                Text("WELCOME TO!" , style: TextStyle(fontSize: 40,fontWeight: FontWeight.w900),),
                Text(
                  "BMI CALCULATOR",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 300),
                ElevatedButton(onPressed: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder : (context) => Optionscreen(),
                      ));
                }, child: Text("Calculate BMI")),
                ElevatedButton(onPressed: (){

                }, child: Text("Rate Us"))
              ]
          ),
        ),
      ),
    );
  }

}