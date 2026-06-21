import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scientific_calculator/Notepad.dart';
import 'package:scientific_calculator/SavedNotes.dart';

import 'Calculator_screen.dart';

class Homescreen extends StatefulWidget {
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 13, right: 13),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/Logo.png', height: 130, width: 130),

            SizedBox(height: 12),
            Text(
              "Scientific Calculator",
              style: TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                color: Color(0xFF6F8794),
              ),
            ),
            SizedBox(height: 20,),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Calculator()),
                );
              },
              child: Card(
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/calculator 1.png',
                      height: 130,
                      width: 130,
                    ),

                    Text(
                      "Scientific Calculator",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        color: Color(0xFF6F8794),
                      ),
                    ),
                  ],
                ),
              ),

            ),
            SizedBox(height: 10,),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Notepad()),
            );
          },
          child:
            Card(
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/notepad 1.png',
                    height: 130,
                    width: 130,
                  ),

                  Text(
                    "NotePad",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      color: Color(0xFF6F8794),
                    ),
                  ),
                ],
              ),
            ),
        ),
            SizedBox(height: 10,),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Savednotes()),
            );
          },
          child:
            Card(
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/add-file 1.png",
                    height: 130,
                    width: 130,
                  ),

                  Text(
                    "Saved Notes",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      color: Color(0xFF6F8794),
                    ),
                  ),
                ],
              ),
            ),
        ),
        ]
        ),
      ),

      drawer: Drawer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 13),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 70),
                  Image.asset(
                    'assets/images/Logo.png',
                    height: 140,
                    width: 150,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Scientific Calculator",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Color(0xFF6F8794),
                    ),
                  ),
                  SizedBox(height: 30),

                  Row(
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/abc.png'),
                        color: Color(0xFF6F8794),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Home",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Roboto',
                          color: Color(0xFF6F8794),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 13),

                  Row(
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/cal.png'),
                        color: Color(0xFF6F8794),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Scientific Calculator",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Roboto',
                          color: Color(0xFF6F8794),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 13),
                  Row(
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/notepad.png'),
                        color: Color(0xFF6F8794),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Notepad",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Roboto',
                          color: Color(0xFF6F8794),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 13),
                  Row(
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/about.png'),
                        color: Color(0xFF6F8794),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "About us",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Roboto',
                          color: Color(0xFF6F8794),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 13),
                  Row(
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/privacy.png'),
                        color: Color(0xFF6F8794),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Privacy Policy",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Roboto',
                          color: Color(0xFF6F8794),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 190),
            Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Homescreen()),
                      );
                    },
                    label: Text("Exit", style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6F8794),
                      shadowColor: Colors.grey,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),

                    icon: Icon(Icons.exit_to_app, size: 25),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
