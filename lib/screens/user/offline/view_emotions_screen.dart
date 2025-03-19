import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineViewEmotionsScreen extends StatefulWidget {
  const OfflineViewEmotionsScreen({super.key});

  @override
  _OfflineViewEmotionsScreenState createState() =>
      _OfflineViewEmotionsScreenState();
}

class _OfflineViewEmotionsScreenState extends State<OfflineViewEmotionsScreen> {
  List<Map<String, dynamic>> _emotions = []; // List to hold emotions data

  @override
  void initState() {
    super.initState();
    _fetchEmotions();
  }

  // Fetch the emotions from SharedPreferences
  Future<void> _fetchEmotions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> emotions = prefs.getStringList('offline_emotions') ?? [];

    // Decode the emotions and store them in _emotions list
    List<Map<String, dynamic>> tempEmotions = [];

    for (String emotion in emotions) {
      try {
        // Attempt to decode the emotion
        var decodedEmotion = jsonDecode(emotion);

        // Check if the decoded data is a Map<String, dynamic>
        if (decodedEmotion is Map<String, dynamic>) {
          tempEmotions.add(decodedEmotion);
        }
      } catch (error) {
        // Handle the error if decoding fails
        print('Error decoding emotion: $error');
      }
    }

    setState(() {
      _emotions = tempEmotions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Emotions')),
      body: _emotions.isEmpty
          ? Center(child: Text('No emotions logged yet.'))
          : ListView.builder(
              itemCount: _emotions.length,
              itemBuilder: (context, index) {
                final emotion = _emotions[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(emotion['emotion_felt'] ?? 'No emotion'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Intensity: ${emotion['emotion_intensity'] ?? 'N/A'}'),
                        Text('Note: ${emotion['note'] ?? 'No notes'}'),
                        Text('Timestamp: ${emotion['timestamp'] ?? 'N/A'}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
