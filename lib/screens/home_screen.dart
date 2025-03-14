import 'package:flutter/material.dart';
import 'menu.dart'; // Import the Menu widget

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushNamed(context, '/logout');
  }

  void _resetBackendUrl(BuildContext context) {
    // You can put any other code needed for resetting the backend URL here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          Menu(
            onLogout: () => _logout(context),
            onResetBackendUrl: () => _resetBackendUrl(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🌞 Good Evening!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'What do you want to do today?',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
