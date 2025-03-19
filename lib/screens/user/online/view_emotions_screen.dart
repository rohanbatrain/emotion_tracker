import 'package:flutter/material.dart';
import 'emotion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewEmotionsScreen extends StatefulWidget {
  const ViewEmotionsScreen({super.key});

  @override
  _ViewEmotionsScreenState createState() => _ViewEmotionsScreenState();
}

class _ViewEmotionsScreenState extends State<ViewEmotionsScreen> {
  final EmotionService _emotionService = EmotionService();
  List<Map<String, dynamic>> _emotions = [];

  @override
  void initState() {
    super.initState();
    _fetchEmotions();
  }

  void _fetchEmotions() async {
    final prefs = await SharedPreferences.getInstance();
    final backendUrl = prefs.getString('backend_url') ?? '';
    final authToken = prefs.getString('auth_token') ?? '';

    if (backendUrl.isNotEmpty && authToken.isNotEmpty) {
      final emotions = await _emotionService.fetchEmotions(backendUrl, authToken);

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _emotions = emotions.reversed.toList();  // Reverse to show the latest first
        });
      }
    }
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
                  child: ListTile(
                    title: Text(emotion['emotion_felt']),
                    subtitle: Text('Intensity: ${emotion['emotion_intensity']}'),
                    onTap: () {
                      // Navigate to a new screen with emotion details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewEmotionDetailsScreen(
                            emotion: emotion,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class ViewEmotionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> emotion;

  const ViewEmotionDetailsScreen({super.key, required this.emotion});

  @override
  Widget build(BuildContext context) {
    // Extract the details from the emotion map
    final String emotionFelt = emotion['emotion_felt'] ?? 'Unknown';
    final int intensity = emotion['emotion_intensity'] ?? 'Unknown';
    final String date = emotion['timestamp'] ?? 'Unknown'; // Assume you have 'date' key in your data
    final String note = emotion['note'] ?? 'No note available'; // Assume you have 'note' key in your data

    return Scaffold(
      appBar: AppBar(
        title: Text('Emotion Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emotion Felt: $emotionFelt',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Intensity: $intensity',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Date: $date',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Note: $note',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
