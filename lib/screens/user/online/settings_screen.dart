import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isEncryptionEnabled = false;
  TextEditingController _encryptionKeyController = TextEditingController();
  bool _isKeyVisible = false; // Tracks whether the encryption key is visible

  @override
  void initState() {
    super.initState();
    _loadEncryptionSettings();
  }

  // Load the encryption status and key from SharedPreferences
  Future<void> _loadEncryptionSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEncryptionEnabled = prefs.getBool('is_encryption_enabled') ?? false;
      _encryptionKeyController.text = prefs.getString('encryption_key') ?? '';
    });
  }

  // Handle the switch toggle for encryption
  void _toggleEncryption(bool value) async {
    if (!value) {
      // Show warning dialog before disabling encryption
      bool? shouldDisable = await _showEncryptionWarningDialog();
      if (shouldDisable == true) {
        setState(() {
          _isEncryptionEnabled = value;
        });
        // Save the encryption status to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_encryption_enabled', value);

        // Clear the encryption key if encryption is turned off
        _clearEncryptionKey();
        await prefs.remove('encryption_key'); // Remove the key from SharedPreferences
      }
    } else {
      // If the encryption is being enabled, just toggle it
      setState(() {
        _isEncryptionEnabled = value;
      });
      // Save the encryption status to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_encryption_enabled', value);

      // If encryption is enabled, make sure the key is saved
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
        title: const Text(
          'Important Warning!',
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            SizedBox(height: 16),
            Text(
              'By disabling encryption, you are risking permanent loss of access to your encrypted data.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 12),
            Text(
              'If you do not have the encryption key, you will not be able to decrypt your notes in the future.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 12),
            Text(
              'Make sure to keep your encryption key in a safe place. If you lose it, there is no way to recover your data.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 12),
            Text(
              'Disabling encryption will also remove the current encryption key from the app storage.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User cancels the action
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User confirms the action
            },
            child: const Text('Proceed'),
          ),
        ],
      );
    },
  );
}


  // Clear encryption key when encryption is disabled
  void _clearEncryptionKey() {
    _encryptionKeyController.clear();
  }

  // Save the encryption key to SharedPreferences
  Future<void> _saveEncryptionKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('encryption_key', _encryptionKeyController.text);
  }

  // Generate a random 32-character key
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Toggle Encryption
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enable Encryption',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Switch(
                  value: _isEncryptionEnabled,
                  onChanged: (bool value) {
                    _toggleEncryption(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Encryption key input field with the eye icon
            if (_isEncryptionEnabled)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      const Text(
                        'Enter Encryption Key (max 32 chars):',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          // Show a dialog with encryption key info
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Encryption Key Information'),
                                content: const Text(
                                  'If you forget your encryption key, there is no way for us (or anyone) to recover your data, even if we have access to the database. Please keep it safe.',
                                  style: TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _encryptionKeyController,
                    decoration: InputDecoration(
                      hintText: 'Enter a strong encryption key',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blueAccent, width: 1),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isKeyVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isKeyVisible = !_isKeyVisible; // Toggle visibility
                          });
                        },
                      ),
                    ),
                    obscureText: !_isKeyVisible,  // Show/hide the text based on _isKeyVisible
                    onChanged: (text) {
                      // Limit the key to 32 characters
                      if (text.length > 32) {
                        _encryptionKeyController.text = text.substring(0, 32);
                        _encryptionKeyController.selection = TextSelection.collapsed(offset: 32);
                      }
                      // Save the encryption key when it's entered
                      _saveEncryptionKey();
                    },
                  ),
                  const SizedBox(height: 20),

                  // Random key generator button
                  ElevatedButton.icon(
                    onPressed: () {
                      String randomKey = _generateRandomKey();
                      _encryptionKeyController.text = randomKey;
                      _saveEncryptionKey();
                    },
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Generate Random Key'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Save the encryption setting and encryption key when the Save button is pressed
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_encryption_enabled', _isEncryptionEnabled);
                  if (_isEncryptionEnabled) {
                    await prefs.setString('encryption_key', _encryptionKeyController.text);
                  } else {
                    await prefs.remove('encryption_key');
                  }

                  // Show a confirmation message or navigate away
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved successfully!')),
                  );
                },
                child: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
