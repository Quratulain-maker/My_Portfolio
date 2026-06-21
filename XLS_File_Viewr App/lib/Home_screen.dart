import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Costum_Button.dart';
import 'PrivacyPolicy.dart';
import 'About_us.dart';
import 'Settings.dart';

class Home_screen extends StatefulWidget {
  @override
  State<Home_screen> createState() => _Home_screenState();
}

class _Home_screenState extends State<Home_screen> {
  bool isGrid = true;
  int _selectedIndex = 0;

  final List<String> fileNames = [
    "XLS Files", "PPT Files", "PDF Files", "HTML Files",
    "DOC Files", "TXT Files", "RTF Files", "CSV Files", "XML Files",
  ];

  final List<String> fileImages = [
    "assets/images/XLS.png", "assets/images/PPT.png", "assets/images/PDF.png",
    "assets/images/HTML.png", "assets/images/DOC.png", "assets/images/TXT.png",
    "assets/images/RTF.png", "assets/images/CSV.png", "assets/images/XML.png",
  ];

  List<String> recentFiles = [];

  @override
  void initState() {
    super.initState();
    _loadRecents();
  }

  Future<void> _loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentFiles = prefs.getStringList("recents") ?? [];
    });
  }

  Future<void> _saveRecents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("recents", recentFiles);
  }

  Future<void> _pickAndOpenFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _getExtensions(type),
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      OpenFile.open(filePath);

      setState(() {
        recentFiles.remove(filePath);
        recentFiles.insert(0, filePath);
        if (recentFiles.length > 10) {
          recentFiles.removeLast();
        }
      });

      _saveRecents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No file selected for $type")),
      );
    }
  }

  List<String> _getExtensions(String type) {
    switch (type) {
      case "XLS Files": return ["xls", "xlsx"];
      case "PPT Files": return ["ppt", "pptx"];
      case "PDF Files": return ["pdf"];
      case "HTML Files": return ["html", "htm"];
      case "DOC Files": return ["doc", "docx"];
      case "TXT Files": return ["txt"];
      case "RTF Files": return ["rtf"];
      case "CSV Files": return ["csv"];
      case "XML Files": return ["xml"];
      default: return ["*"];
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0: break; // Home
      case 1: Navigator.push(context, MaterialPageRoute(builder: (_) => PrivacyPolicy())); break;
      case 2: Navigator.push(context, MaterialPageRoute(builder: (_) => About_us())); break;
      case 3: Navigator.push(context, MaterialPageRoute(builder: (_) => Settings())); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "XLS FILE VIEWER",
            style: TextStyle(fontSize: 23, color: Color(0xFF1E754C)),
          ),
        ),
        automaticallyImplyLeading: false,
      ),

      body: Column(
        children: [
          // Toggle Row
          Row(
            children: [
              SizedBox(width: 20, height: 20),
              Text("All Files", style: TextStyle(fontSize: 25)),
              Spacer(),
              IconButton(
                icon: Image.asset(
                  "assets/images/grid.png",
                  color: isGrid ? Colors.green : Colors.grey,
                  width: 28, height: 28,
                ),
                onPressed: () => setState(() => isGrid = true),
              ),
              IconButton(
                icon: Image.asset(
                  "assets/images/list.png",
                  color: !isGrid ? Colors.green : Colors.grey,
                  width: 28, height: 28,
                ),
                onPressed: () => setState(() => isGrid = false),
              ),
              SizedBox(width: 10),
            ],
          ),

          // Grid or List
          Expanded(
            child: isGrid
                ? GridView.builder(
              padding: EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 25,
                mainAxisSpacing: 20,
                childAspectRatio: 0.9,
              ),
              itemCount: fileNames.length,
              itemBuilder: (context, index) {
                return Costum_Button(
                  btnName: fileNames[index],
                  image: Image.asset(fileImages[index]),
                  callBack: () => _pickAndOpenFile(fileNames[index]),
                );
              },
            )
                : ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: fileNames.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Image.asset(fileImages[index], width: 47, height: 45),
                    title: Text(
                      fileNames[index],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _pickAndOpenFile(fileNames[index]),
                  ),
                );
              },
            ),
          ),

          // 🆕 Recents "Folder"
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RecentsScreen(recentFiles: recentFiles)),
              );
            },

            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder, color: Colors.green, size: 40),
                  SizedBox(width: 10),
                  Text(
                    "Recents",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, color: Colors.black54),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Color(0xFF1E754C),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        iconSize: 35,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.privacy_tip), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
        ],
      ),
    );
  }
}

// 🆕 Separate Recents Screen
class RecentsScreen extends StatefulWidget {
  final List<String> recentFiles;
  const RecentsScreen({super.key, required this.recentFiles});

  @override
  State<RecentsScreen> createState() => _RecentsScreenState();
}

class _RecentsScreenState extends State<RecentsScreen> {
  late List<String> recents;

  @override
  void initState() {
    super.initState();
    recents = List.from(widget.recentFiles);
  }

  Future<void> _removeFile(int index) async {
    setState(() {
      recents.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("recents", recents);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recents", style: TextStyle(color: Color(0xFF1E754C))),
      ),
      body: recents.isEmpty
          ? Center(child: Text("No recent files"))
          : ListView.builder(
        padding: EdgeInsets.all(15),
        itemCount: recents.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Icon(Icons.insert_drive_file, color: Colors.green, size: 40),
              title: Text(
                recents[index].split("/").last,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(recents[index]),
              onTap: () => OpenFile.open(recents[index]),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFile(index),
              ),
            ),
          );
        },
      ),
    );
  }
}