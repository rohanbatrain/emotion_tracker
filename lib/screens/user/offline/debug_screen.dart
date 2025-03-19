import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _isDebugEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadDebugSettings();
  }

  Future<void> _loadDebugSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDebugEnabled = prefs.getBool('is_debug_enabled') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Screen'),
      ),
      body: Center(
        child: _isDebugEnabled
            ? const Text(
                'Hello, this is Debug!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )
            : const Text(
                'Please enable debug mode in settings to continue.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }
}
