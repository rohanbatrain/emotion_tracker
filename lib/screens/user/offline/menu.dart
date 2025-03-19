import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart'; // Import the OfflineSettingsScreen
import 'debug_screen.dart'; // Import the DebugScreen

class OfflineMenu extends StatelessWidget {
  const OfflineMenu({super.key});

  // Navigate to Offline Settings Screen
  void _navigateToSettingsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OfflineSettingsScreen()),
    );
  }

  // Navigate to Debug Screen
  void _navigateToDebugScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DebugScreen()),
    );
  }

  Future<bool> _isDebugEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_debug_enabled') ?? false; // Check if Debug Mode is enabled
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isDebugEnabled(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator while checking debug flag
        }

        bool isDebugEnabled = snapshot.data ?? false;

        return PopupMenuButton<String>(
          icon: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          onSelected: (String result) {
            if (result == 'settings') {
              _navigateToSettingsScreen(context); // Navigate to Offline Settings screen
            } else if (result == 'debug') {
              _navigateToDebugScreen(context); // Navigate to Debug Screen
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'settings',
              child: Text('Settings'),
            ),
            // Conditionally show Debug menu item
            if (isDebugEnabled)
              const PopupMenuItem<String>(
                value: 'debug',
                child: Text('Debug Screen'),
              ),
          ],
        );
      },
    );
  }
}
