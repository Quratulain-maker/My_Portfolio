import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scientific_calculator/Square_Buttons.dart';

class Calculator extends StatefulWidget {
  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  late double firstNum;
  late double SecondNum;
  late String History = "";
  late String textToDisplay = "";
  late String res = "";
  late String Operation;
  bool isDegree = true; // DEG/RAD toggle

  void btnOnclick(String btnVal) {
    print(btnVal);
    setState(() {
      if (btnVal == "C") {
        textToDisplay = "";
        firstNum = 0;
        SecondNum = 0;
        res = "";
      } else if (btnVal == "+/-") {
        if (textToDisplay.isNotEmpty && textToDisplay[0] != "-") {
          res = "-" + textToDisplay;
        } else if (textToDisplay.isNotEmpty) {
          res = textToDisplay.substring(1);
        }
      } else if (btnVal == "←") {
        if (textToDisplay.isNotEmpty) {
          res = textToDisplay.substring(0, textToDisplay.length - 1);
        }
      } else if (btnVal == "+" || btnVal == "-" || btnVal == "×" || btnVal == "/") {
        firstNum = double.tryParse(textToDisplay) ?? 0;
        res = "";
        Operation = btnVal;
      } else if (btnVal == "=" || btnVal == "Ans") {
        SecondNum = double.tryParse(textToDisplay) ?? 0;
        if (Operation == "+") res = (firstNum + SecondNum).toString();
        if (Operation == "-") res = (firstNum - SecondNum).toString();
        if (Operation == "×") res = (firstNum * SecondNum).toString();
        if (Operation == "/") res = (firstNum / SecondNum).toString();
        History = "$firstNum $Operation $SecondNum";
      } else if (btnVal == "(" || btnVal == ")") {
        res = textToDisplay + btnVal;
        History = res;
      } else if (btnVal == "%") {
        double? val = double.tryParse(textToDisplay);
        res = (val! / 100).toString();
        History = "$val% = $res";
      } else if (btnVal == "sin") {
        double? val = double.tryParse(textToDisplay);
        if (isDegree) val = val! * pi / 180;
        res = sin(val!).toString();
        History = "sin($textToDisplay)";
      } else if (btnVal == "cos") {
        double? val = double.tryParse(textToDisplay);
        if (isDegree) val = val! * pi / 180;
        res = cos(val!).toString();
        History = "cos($textToDisplay)";
      } else if (btnVal == "tan") {
        double? val = double.tryParse(textToDisplay);
        if (isDegree) val = val! * pi / 180;
        res = tan(val!).toString();
        History = "tan($textToDisplay)";
      } else if (btnVal == "√") {
        double? val = double.tryParse(textToDisplay);
        res = sqrt(val!).toString();
        History = "√($val)";
      } else if (btnVal == "x²") {
        double? val = double.tryParse(textToDisplay);
        res = pow(val!, 2).toString();
        History = "$val²";
      } else if (btnVal == "x³") {
        double? val = double.tryParse(textToDisplay);
        res = pow(val!, 3).toString();
        History = "$val³";
      } else if (btnVal == "1/x") {
        double? val = double.tryParse(textToDisplay);
        res = (1 / val!).toString();
        History = "1/($val)";
      } else if (btnVal == "π") {
        res = pi.toString();
        History = "π = $res";
      } else if (btnVal == "ln") {
        double? val = double.tryParse(textToDisplay);
        res = log(val!).toString();
        History = "ln($val)";
      } else if (btnVal == "log") {
        double? val = double.tryParse(textToDisplay);
        res = (log(val!) / ln10).toString();
        History = "log($val)";
      } else if (btnVal == "Deg") {
        isDegree = !isDegree;
        History = isDegree ? "Mode: Degrees" : "Mode: Radians";
      } else {
        res = textToDisplay + btnVal;
      }
      textToDisplay = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Calculator"))),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(alignment: Alignment.topRight),
                          Expanded(
                            child: Container(
                              alignment: Alignment(1.0, 1.0),
                              child: Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Text(
                                  History,
                                  style: TextStyle(fontSize: 24, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          Align(alignment: Alignment.topRight),
                          Text(
                            textToDisplay,
                            style: TextStyle(fontSize: 48, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    alignment: Alignment(1.0, 1.0),
                    height: 238,
                    width: 380,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 7,
                          spreadRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 11),
          Expanded(
            flex: 6,
            child: Row(

              children: [
                Column(

                  children: [
                    SquareButton(
                      btnName: "2nd",
                      bgColor: Colors.red,
                      callBack: () => btnOnclick("2nd"),
                    ),
                    SquareButton(btnName: "π", callBack: () => btnOnclick("π")),
                    SquareButton(
                        btnName: "sin",
                        bgColor: Colors.grey,
                        callBack: () => btnOnclick("sin")),
                    SquareButton(btnName: "7", callBack: () => btnOnclick("7")),
                    SquareButton(btnName: "4", callBack: () => btnOnclick("4")),
                    SquareButton(btnName: "1", callBack: () => btnOnclick("1")),
                    SquareButton(btnName: "0", callBack: () => btnOnclick("0")),
                  ],
                ),
                Column(
                  children: [
                    SquareButton(
                      btnName: isDegree ? "Deg" : "Rad",
                      bgColor: Color(0xFF2E7AE2),
                      callBack: () => btnOnclick("Deg"),
                    ),
                    SquareButton(btnName: "√", callBack: () => btnOnclick("√")),
                    SquareButton(
                        btnName: "cos",
                        bgColor: Colors.grey,
                        callBack: () => btnOnclick("cos")),
                    SquareButton(btnName: "8", callBack: () => btnOnclick("8")),
                    SquareButton(btnName: "5", callBack: () => btnOnclick("5")),
                    SquareButton(btnName: "2", callBack: () => btnOnclick("2")),
                    SquareButton(btnName: ".", callBack: () => btnOnclick(".")),
                  ],
                ),
                Column(
                  children: [
                    SquareButton(
                      btnName: "%",
                      bgColor: Color(0xFF2E7AE2),
                      callBack: () => btnOnclick("%"),
                    ),
                    SquareButton(btnName: "(", callBack: () => btnOnclick("(")),
                    SquareButton(
                        btnName: "tan",
                        bgColor: Colors.grey,
                        callBack: () => btnOnclick("tan")),
                    SquareButton(btnName: "9", callBack: () => btnOnclick("9")),
                    SquareButton(btnName: "6", callBack: () => btnOnclick("6")),
                    SquareButton(btnName: "3", callBack: () => btnOnclick("3")),
                    SquareButton(btnName: "=", callBack: () => btnOnclick("=")),
                  ],
                ),
                Column(
                  children: [
                    SquareButton(
                      btnName: "←",
                      bgColor: Color(0xFF2E7AE2),
                      callBack: () => btnOnclick("←"),
                    ),
                    SquareButton(btnName: ")", callBack: () => btnOnclick(")")),
                    SquareButton(
                        btnName: "+/-",
                        bgColor: Colors.grey,
                        callBack: () => btnOnclick("+/-")),
                    SquareButton(
                        btnName: "/",
                        bgColor: Colors.grey,
                        callBack: () => btnOnclick("/")),
                    SquareButton(
                        btnName: "×",
                        bgColor: Colors.grey,
                        callBack: () => btnOnclick("×")),
                    SquareButton(
                        btnName: "-",
                        bgColor: Colors.grey,
                        callBack: () => btnOnclick("-")),
                    SquareButton(
                        btnName: "+",
                        bgColor: Colors.grey,
                        callBack: () => btnOnclick("+")),
                  ],
                ),
                Column(
                  children: [
                    SquareButton(
                      btnName: "C",
                      bgColor: Color(0xFF2E7AE2),
                      callBack: () => btnOnclick("C"),
                    ),
                    SquareButton(
                        btnName: "1/x",
                        bgColor: Color(0xFF2E7AE2),
                        callBack: () => btnOnclick("1/x")),
                    SquareButton(
                        btnName: "x²",
                        bgColor: Color(0xFF2E7AE2),
                        callBack: () => btnOnclick("x²")),
                    SquareButton(
                        btnName: "x³",
                        bgColor: Color(0xFF2E7AE2),
                        callBack: () => btnOnclick("x³")),
                    SquareButton(
                        btnName: "ln",
                        bgColor: Color(0xFF2E7AE2),
                        callBack: () => btnOnclick("ln")),
                    SquareButton(
                        btnName: "log",
                        bgColor: Color(0xFF2E7AE2),
                        callBack: () => btnOnclick("log")),
                    SquareButton(
                        btnName: "Ans",
                        bgColor: Color(0xFF2E7AE2),
                        callBack: () => btnOnclick("Ans")),
                  ],

                ),
              ],

            ),
          ),
        ],
      ),
    );
  }
}
