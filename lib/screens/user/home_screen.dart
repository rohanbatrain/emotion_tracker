import 'package:flutter/material.dart';
import 'log_emotion_screen.dart';
import 'view_emotions_screen.dart';
import 'analytics_screen.dart';
import '../menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    LogEmotionScreen(),
    ViewEmotionsScreen(),
    AnalyticsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    // Implement logout functionality
  }

  void _resetBackendUrl() {
    // Implement reset backend URL functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emotion Tracker'),
        actions: [
          Menu(
            onLogout: _logout,
            onResetBackendUrl: _resetBackendUrl,
          ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
