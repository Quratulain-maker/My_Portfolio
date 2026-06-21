
import 'package:flutter/material.dart';
import 'package:xls_file_viewr/Introduction_page1.dart';


class Splash_screen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

     return Scaffold(

       backgroundColor: Color(0xFF1E754C),
       body:
       Column(

         children: [
           SizedBox(height: 70,),
           Center(child: Text("EXCEL",
             style: TextStyle(fontSize: 80,fontFamily: 'FontMain', color: Colors.white),)),
           Center(child: Text("FILE VIEWER",
             style: TextStyle(fontSize: 60,fontFamily: 'FontMain', color: Colors.white),)),
           Center(child: Text("View XLS File Easily & Securely",
             style: TextStyle(fontSize: 20 ,color: Colors.white),)),
           SizedBox(
             height: 370,
           ),
           Align(
             alignment: Alignment.bottomCenter,
           ),
           Container(
             width: 190,
             child: ElevatedButton(
               onPressed: (){
                 Navigator.push(context, MaterialPageRoute(builder:
                     (context) => Introduction_page1(),));
               },

               style: ElevatedButton.styleFrom(

                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(10),

                 ),
               ),

               child:Row(

                 children: [

                   Text(
                     "Continue",
                     style: TextStyle(fontSize: 24, color: Colors.black),
                   ),
                  SizedBox(width: 10,),
                  Image.asset("assets/images/Group (9).png")
                 ],
               )

             ),
           )

         ],
       )


     
   );
  }

}