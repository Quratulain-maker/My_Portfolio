import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool showIntro = true;

  @override
  void initState() {
    super.initState();
    _loadToggle();
  }

  Future<void> _loadToggle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showIntro = prefs.getBool('showIntro') ?? true;
    });
  }

  Future<void> _saveToggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showIntro', value);
    setState(() {
      showIntro = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Settings",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E754C),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(9.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              height: 70,
              width: 400,
              child: Card(
                elevation: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Introduction Screen",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Switch(
                      value: showIntro,
                      onChanged: (value) {
                        _saveToggle(value);
                      },
                      activeColor: Color(0xFF1E754C),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
