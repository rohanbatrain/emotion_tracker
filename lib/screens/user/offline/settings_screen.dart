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

  @override
  void initState() {
    super.initState();
    _loadEncryptionSettings();
  }

  Future<void> _loadEncryptionSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEncryptionEnabled = prefs.getBool('offline_is_encryption_enabled') ?? false;
      _encryptionKeyController.text = prefs.getString('offline_encryption_key') ?? '';
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
        await prefs.setBool('offline_is_encryption_enabled', value);
        _clearEncryptionKey();
        await prefs.remove('offline_encryption_key');
      }
    } else {
      setState(() {
        _isEncryptionEnabled = value;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('offline_is_encryption_enabled', value);
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
    await prefs.setString('offline_encryption_key', _encryptionKeyController.text);
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
    await prefs.clear();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data cleared successfully!')),
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
