import 'package:agro_eye/widget/HistoryCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'history_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final data = await HistoryStorage.getHistory();
    setState(() {
      history = data;
    });
  }

  Future<void> clearHistory() async {
    await HistoryStorage.clearHistory();
    await loadHistory();
  }

  String formatDate(String date) {
    final parsed = DateTime.parse(date);

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  String getImagePath(String crop) {
    if (crop == 'Apple') {
      return 'assets/images/apple_card.png';
    } else {
      return 'assets/images/grapes_card.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan History',
          style: TextStyle(
            color: Color(0xFF0C3B2E),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: clearHistory,
            ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: history.isEmpty
            ? const Center(
          child: Text(
            'No scan history yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        )
            : ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];

            final String crop = item['crop'] ?? '';
            final String disease = item['label'] ?? '';
            final String date = item['date'] ?? '';
            final bool isHealthy = item['isHealthy'] == true;

            return Column(
              children: [
                HistoryCard(
                  cropName: crop,
                  disease: disease,
                  date: date.isNotEmpty ? formatDate(date) : '',
                  status: isHealthy ? 'Healthy' : 'Infected',
                  imagePath: getImagePath(crop),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}