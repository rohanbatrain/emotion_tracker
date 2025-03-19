import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class OfflineSettingsScreen extends StatefulWidget {
  const OfflineSettingsScreen({super.key});

  @override
  _OfflineSettingsScreenState createState() => _OfflineSettingsScreenState();
}

class _OfflineSettingsScreenState extends State<OfflineSettingsScreen> {
  bool _isEncryptionEnabled = false;
  TextEditingController _encryptionKeyController = TextEditingController();
  bool _isKeyVisible = false;

  // Debug mode flag
  bool _isDebugEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadEncryptionSettings();
  }

  Future<void> _loadEncryptionSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEncryptionEnabled = prefs.getBool('is_encryption_enabled') ?? false;
      _encryptionKeyController.text = prefs.getString('encryption_key') ?? '';
      _isDebugEnabled = prefs.getBool('is_debug_enabled') ?? false; // Load debug setting
    });
  }

  void _toggleEncryption(bool value) async {
    if (!value) {
      bool? shouldDisable = await _showEncryptionWarningDialog();
      if (shouldDisable == true) {
        setState(() {
          _isEncryptionEnabled = value;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_encryption_enabled', value);
        _clearEncryptionKey();
        await prefs.remove('encryption_key');
      }
    } else {
      setState(() {
        _isEncryptionEnabled = value;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_encryption_enabled', value);
      if (_isEncryptionEnabled) {
        _saveEncryptionKey();
      }
    }
  }

  Future<bool?> _showEncryptionWarningDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Important Warning!'),
          content: const Text(
            'Disabling encryption will remove the current encryption key and make your data unencrypted. Proceed with caution.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    );
  }

  void _clearEncryptionKey() {
    _encryptionKeyController.clear();
  }

  Future<void> _saveEncryptionKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('encryption_key', _encryptionKeyController.text);
  }

  String _generateRandomKey() {
    const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      32,
      (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
    ));
  }

  @override
  void dispose() {
    _encryptionKeyController.dispose();
    super.dispose();
  }

  Future<void> _clearAllData() async {
    final prefs = await SharedPreferences.getInstance();

    // List of keys to keep (e.g., 'encryption_key')
    const List<String> keysToKeep = ['encryption_key', 'is_encryption_enabled', 'is_debug_enabled'];

    // Get all keys stored in SharedPreferences
    final keys = prefs.getKeys();

    // Loop through all keys and remove those that are not in the keysToKeep list
    for (String key in keys) {
      if (!keysToKeep.contains(key)) {
        await prefs.remove(key);
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data cleared successfully, except encryption settings!')),
    );
  }

  Future<void> _showClearDataConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data Confirmation'),
          content: const Text('Are you sure you want to clear all data? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Clear Data'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _clearAllData();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleDebugMode(bool value) async {
    setState(() {
      _isDebugEnabled = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_debug_enabled', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Debug Mode
            SwitchListTile(
              title: const Text(
                'Enable Debug Mode',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              value: _isDebugEnabled,
              onChanged: (bool value) {
                _toggleDebugMode(value);
              },
            ),
            if (_isDebugEnabled)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  color: Colors.yellow[200],
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Warning: Debug mode is enabled. This can leak sensitive information. Proceed with caution!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Toggle Encryption
            SwitchListTile(
              title: const Text(
                'Enable Encryption',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              value: _isEncryptionEnabled,
              onChanged: (bool value) {
                _toggleEncryption(value);
              },
            ),
            const SizedBox(height: 20),

            // Encryption key input field
            if (_isEncryptionEnabled)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Enter Encryption Key (max 32 chars):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _encryptionKeyController,
                    decoration: InputDecoration(
                      hintText: 'Enter a strong encryption key',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isKeyVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isKeyVisible = !_isKeyVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isKeyVisible,
                    onChanged: (text) {
                      if (text.length > 32) {
                        _encryptionKeyController.text = text.substring(0, 32);
                        _encryptionKeyController.selection = TextSelection.collapsed(offset: 32);
                      }
                      _saveEncryptionKey();
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      String randomKey = _generateRandomKey();
                      _encryptionKeyController.text = randomKey;
                      _saveEncryptionKey();
                    },
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Generate Random Key'),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Clear All Data
            ListTile(
              title: const Text('Clear All Data'),
              subtitle: const Text('Remove all stored data from the app.'),
              trailing: const Icon(Icons.delete),
              onTap: _showClearDataConfirmationDialog,
            ),
          ],
        ),
      ),
    );
  }
}
