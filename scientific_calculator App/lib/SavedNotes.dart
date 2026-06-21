import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'Notepad.dart';

class Savednotes extends StatefulWidget {
  @override
  State<Savednotes> createState() => _SavednotesState();
}

class _SavednotesState extends State<Savednotes> {
  List<Map<String, dynamic>> savedNotes = [];

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  Future<void> getNotes() async {
    var prefs = await SharedPreferences.getInstance();
    List<String> notesList = prefs.getStringList("notes") ?? [];
    savedNotes = notesList
        .map((noteStr) => jsonDecode(noteStr) as Map<String, dynamic>)
        .toList();
    setState(() {});
  }

  Future<void> deleteNote(int index) async {
    var prefs = await SharedPreferences.getInstance();
    List<String> notesList = prefs.getStringList("notes") ?? [];
    notesList.removeAt(index);
    await prefs.setStringList("notes", notesList);
    getNotes(); // Refresh list
  }

  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Saved Notes")),
      body: savedNotes.isEmpty
          ? Center(child: Text("No saved notes yet."))
          : ListView.builder(
        itemCount: savedNotes.length,
        itemBuilder: (context, index) {
          var note = savedNotes[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(note["title"] ?? "Untitled"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note["content"] ?? ""),
                  SizedBox(height: 5),
                  Text(formatDate(note["date"]),
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteNote(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Notepad()),
          ).then((_) => getNotes());
        },
      ),
    );
  }
}
