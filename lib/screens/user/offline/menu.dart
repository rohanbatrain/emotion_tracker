import 'package:flutter/material.dart';
import 'settings_screen.dart'; // Import the OfflineSettingsScreen

class OfflineMenu extends StatelessWidget {
  const OfflineMenu({super.key});

  void _navigateToSettingsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OfflineSettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      onSelected: (String result) {
        if (result == 'settings') {
          _navigateToSettingsScreen(context); // Navigate to Offline Settings screen
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'settings',
          child: Text('Settings'),
        ),
      ],
    );
  }
}
