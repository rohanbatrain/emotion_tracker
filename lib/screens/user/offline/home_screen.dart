import 'package:flutter/material.dart';
import 'log_emotion_screen.dart';
import 'view_emotions_screen.dart';
import 'menu.dart'; // Import OfflineMenu

class OfflineHomeScreen extends StatefulWidget {
  const OfflineHomeScreen({super.key});

  @override
  OfflineHomeScreenState createState() => OfflineHomeScreenState();
}

class OfflineHomeScreenState extends State<OfflineHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    OfflineLogEmotionScreen(),
    OfflineViewEmotionsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Tracker'),
        actions: const [
          OfflineMenu(), // Add the OfflineMenu here
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_reaction),
            label: 'Log Emotion',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'View Emotion',
          ),
        ],
      ),
    );
  }
}
