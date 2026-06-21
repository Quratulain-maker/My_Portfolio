import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scientific_calculator/SavedNotes.dart';

class Notes extends StatefulWidget{
  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  var titleController=TextEditingController();
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(title: Center(child: Text("NotePad")),),
     body: Column(

       children: [
         SizedBox(height: 8,),
         Padding(
           padding: const EdgeInsets.only(left: 20,right: 20),
           child:

    Container(
      decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(20)
      ),
      child:Card(
        child:Row(
            children: [
            Text("  Title:",style: TextStyle(
          fontWeight: FontWeight.w800,fontSize: 22,
        )),



SizedBox(height: 15,),


         Container(
           height:60,
           width: 340,


             child: Row(

              children: [
                ElevatedButton(onPressed: (){

                },
                  style :ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder()
                  ) ,child:Image.asset('assets/images/Group (2).png'), ),


              ],
             ),
           ),






     ]
     ),
      ),
    ),
         ),
   ]
     )
   );
  }
}