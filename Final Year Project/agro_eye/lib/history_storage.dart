import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryStorage {
  static const String _key = 'scan_history';

  static Future<void> addHistory({
    required String crop,
    required String label,
    required String confidence,
    required bool isHealthy,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];

    final item = {
      'crop': crop,
      'label': label,
      'confidence': confidence,
      'isHealthy': isHealthy,
      'date': DateTime.now().toString(),
    };

    history.insert(0, jsonEncode(item));
    await prefs.setStringList(_key, history);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];

    return history
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}