import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';  // Importing logger for logging instead of print
import 'menu.dart'; // Import the Menu widget

class EmotionService {
  final logger = Logger();  // Fix the logger initialization

  // Function to send emotion data to the backend
  Future<void> sendEmotionData(
    String backendUrl,
    String authToken,
    String emotionFelt,
    int emotionIntensity,
    String note,
  ) async {
    final url = Uri.parse('$backendUrl/user/v1/emotion_tracker/add');
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };

    final body = json.encode({
      'emotion_felt': emotionFelt,
      'emotion_intensity': emotionIntensity,
      'note': note,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Handle success
        logger.i('Emotion data sent successfully!');
      } else {
        // Handle error
        logger.e('Failed to send emotion data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error sending emotion data: $e');
    }
  }

  // Function to fetch all emotions from the backend
  Future<List<Map<String, dynamic>>> fetchEmotions(
    String backendUrl,
    String authToken,
  ) async {
    final url = Uri.parse('$backendUrl/user/v1/emotion_tracker/get');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Parse the response body into a list of emotions
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((emotion) => emotion as Map<String, dynamic>).toList();
      } else {
        // Handle error
        logger.e('Failed to fetch emotions. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      logger.e('Error fetching emotions: $e');
      return [];
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final EmotionService _emotionService = EmotionService();

  // Controllers for the form fields
  final TextEditingController _emotionController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  double _intensity = 5.0;  // Default intensity value
  final logger = Logger();

  List<Map<String, dynamic>> _emotions = []; // Store the fetched emotions

  // Function for handling item tap on the bottom nav
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 1) {
      // Fetch emotions when "View Emotion" tab is selected
      _fetchEmotions();
    }
  }

  // Function to log emotion with user input
  void _logEmotion() async {
    final String emotionFelt = _emotionController.text;
    final int emotionIntensity = _intensity.toInt();
    final String note = _noteController.text;

    if (emotionFelt.isEmpty || emotionIntensity == 0 || note.isEmpty) {
      // Show a message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields correctly!'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final backendUrl = prefs.getString('backend_url') ?? '';
    final authToken = prefs.getString('auth_token') ?? '';

    if (backendUrl.isNotEmpty && authToken.isNotEmpty) {
      await _emotionService.sendEmotionData(
        backendUrl,
        authToken,
        emotionFelt,
        emotionIntensity,
        note,
      );
      // Clear fields after submission
      _emotionController.clear();
      _noteController.clear();
      setState(() {
        _intensity = 5.0;  // Reset slider to default
      });
    } else {
      logger.e('No backend URL or auth token found');
    }
  }

  // Function to fetch emotions from the backend
  void _fetchEmotions() async {
    final prefs = await SharedPreferences.getInstance();
    final backendUrl = prefs.getString('backend_url') ?? '';
    final authToken = prefs.getString('auth_token') ?? '';

    if (backendUrl.isNotEmpty && authToken.isNotEmpty) {
      final emotions = await _emotionService.fetchEmotions(backendUrl, authToken);
      setState(() {
        _emotions = emotions; // Update the list of emotions
      });
    } else {
      logger.e('No backend URL or auth token found');
    }
  }

  // Logout function
  void _logout(BuildContext context) {
    Navigator.pushNamed(context, '/logout');
  }

  // Reset backend URL function
  void _resetBackendUrl(BuildContext context) {
    // You can put any other code needed for resetting the backend URL here.
  }

  @override
  Widget build(BuildContext context) {
    // Prevent back navigation by overriding the WillPopScope
    return WillPopScope(
      onWillPop: () async {
        // Return false to prevent back navigation
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Log Your Emotion'),
          automaticallyImplyLeading: false,
          actions: [
            Menu(
              onLogout: () => _logout(context),
              onResetBackendUrl: () => _resetBackendUrl(context),
            ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.add_reaction),
              label: 'Log Emotion',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_list),
              label: 'View Emotion',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    // List of pages for bottom navigation
    final List<Widget> pages = [
      // Log Emotion Page UI
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emotion Felt Input Field (Dropdown)
                Text(
                  'Emotion Felt',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _emotionController.text.isNotEmpty ? _emotionController.text : null,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[50],
                    labelText: 'Select Emotion',
                    labelStyle: TextStyle(color: Colors.blueGrey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                  ),
                  items: ['Anxiety', 'Happy', 'Sad', 'Panic']
                      .map((emotion) => DropdownMenuItem<String>(
                            value: emotion,
                            child: Text(emotion),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _emotionController.text = value ?? '';
                    });
                  },
                ),
                SizedBox(height: 20),

                // Note Input Field
                Text(
                  'Note',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[50],
                    labelText: 'Write your thoughts...',
                    labelStyle: TextStyle(color: Colors.blueGrey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: 4,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),

                // Emotion Intensity Slider
                Text(
                  'Emotion Intensity: ${_intensity.toInt()}',
                  style: TextStyle(fontSize: 18, color: Colors.blueGrey[800]),
                ),
                Slider(
                  value: _intensity,
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  label: _intensity.toStringAsFixed(0),
                  onChanged: (double value) {
                    setState(() {
                      _intensity = value;
                    });
                  },
                ),
                SizedBox(height: 30),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _logEmotion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Button color
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('Log Emotion', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // View Emotion Page
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: _emotions.isEmpty
              ? Text('No emotions logged yet.')
              : ListView.builder(
                  itemCount: _emotions.length,
                  itemBuilder: (context, index) {
                    final emotion = _emotions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text('${emotion['emotion_felt']}'),
                        subtitle: Text(
                            'Intensity: ${emotion['emotion_intensity']} - Note: ${emotion['note']}'),
                      ),
                    );
                  },
                ),
        ),
      ),
      // Placeholder pages for other sections
      Center(child: Text('Analytics Page')),
    ];

    return pages[_selectedIndex]; // Show selected page content
  }
}
