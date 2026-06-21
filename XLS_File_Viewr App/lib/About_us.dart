import 'package:flutter/material.dart';

class About_us extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "About",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E754C),
            ),
          ),
        ),
      ),
      body: Column(
        children: [

          Center(
            child: Text("EXCEL",
                style: TextStyle(
                    fontSize: 80,
                    fontFamily: 'FontMain',
                    color: Color(0xFF1E754C))),
          ),
          Center(
            child: Text("FILE VIEWER",
                style: TextStyle(
                    fontSize: 60,
                    fontFamily: 'FontMain',
                    color: Color(0xFF1E754C))),
          ),
          SizedBox(height: 10),
          Center(
            child: Text("Version 2.17.7",
                style: TextStyle(
                    fontSize: 25,
                    color: Color(0xFF1E754C),
                    fontWeight: FontWeight.bold)),
          ),
          Center(
            child: Text("Running On",
                style: TextStyle(
                    fontSize: 25,
                    color: Color(0xFF1E754C),
                    fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 10),
          Center(
            child: Text("Xiaomi M2003J15SC",
                style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF767676),
                    fontWeight: FontWeight.bold)),
          ),
          Center(
            child: Text("Android 12",
                style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF767676),
                    fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 300,),
          Center(
            child: Text("@ 2024 XLS FILE VIEWER INC.",
                style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF1E754C),
                    fontWeight: FontWeight.bold)),
          ),

        ],
      ),
    );
  }
}
