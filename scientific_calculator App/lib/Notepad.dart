import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Notepad extends StatefulWidget {
  @override
  State<Notepad> createState() => _NotepadState();
}

class _NotepadState extends State<Notepad> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  Future<void> saveNote() async {
    var prefs = await SharedPreferences.getInstance();
    List<String> notes = prefs.getStringList("notes") ?? [];

    Map<String, dynamic> note = {
      "title": titleController.text,
      "content": contentController.text,
      "date": DateTime.now().toString(),
    };

    notes.add(jsonEncode(note));
    await prefs.setStringList("notes", notes);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NotePad"),
        actions: [
          TextButton(
            onPressed: saveNote,
            child: Text("Save", style: TextStyle(fontSize: 20, color: Colors.grey)),
          ),
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text("Close", style: TextStyle(fontSize: 20, color: Colors.grey)),
          ),
        ],

      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Enter Title...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    hintText: "Write your note here...",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 27,

                ),
            ),

          ],
        ),
      ),
    );
  }
}
