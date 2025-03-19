import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class OfflineLogEmotionScreen extends StatefulWidget {
  const OfflineLogEmotionScreen({super.key});

  @override
  _OfflineLogEmotionScreenState createState() =>
      _OfflineLogEmotionScreenState();
}

class _OfflineLogEmotionScreenState extends State<OfflineLogEmotionScreen> {
  final TextEditingController _emotionController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  double _intensity = 5.0;

  // Encrypt note using AES with random IV
  Future<Map<String, String>> _encryptNote(String note, String encryptionKey) async {
    final key = encrypt.Key.fromUtf8(encryptionKey.padRight(32, ' ')); // AES key needs to be 32 bytes
    final iv = encrypt.IV.fromLength(16); // Random 16-byte IV for AES
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    // Encrypt the note value
    final encrypted = encrypter.encrypt(note, iv: iv);

    // Encode IV and encrypted note as base64
    final ivBase64 = base64.encode(iv.bytes); // base64 encode the IV
    final encryptedNoteBase64 = encrypted.base64; // base64 encode the encrypted note

    // Return both IV and encrypted note as a map
    return {
      'encryptedNote': encryptedNoteBase64,
      'iv': ivBase64,
    };
  }

  // Log emotion and store encrypted note with random IV
  Future<void> _logEmotion() async {
    final String emotionFelt = _emotionController.text;
    final int emotionIntensity = _intensity.toInt();
    final String note = _noteController.text;

    if (emotionFelt.isEmpty || note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields correctly!')),
      );
      return;
    }

    // Retrieve the encryption key and encryption status from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final bool isEncryptionEnabled = prefs.getBool('is_encryption_enabled') ?? false;
    final String? encryptionKey = prefs.getString('encryption_key');

    String encryptedNote = note;
    String? iv;

    if (isEncryptionEnabled && encryptionKey != null) {
      // Encrypt the note with AES (random IV)
      final encryptedData = await _encryptNote(note, encryptionKey);
      encryptedNote = encryptedData['encryptedNote']!;
      iv = encryptedData['iv'];
    }

    // Create the emotion data
    final newEmotion = {
      'emotion_felt': emotionFelt,
      'emotion_intensity': emotionIntensity,
      'note': encryptedNote, // Store encrypted or plain note
      if (iv != null) 'iv': iv, // Include IV only if encryption is used
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Store the emotion data in SharedPreferences
    final List<String> emotions = prefs.getStringList('offline_emotions') ?? [];
    emotions.add(jsonEncode(newEmotion)); // Add new emotion data
    await prefs.setStringList('offline_emotions', emotions);

    // Clear the input fields
    _emotionController.clear();
    _noteController.clear();
    setState(() {
      _intensity = 5.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Emotion logged successfully!')),
    );
  }

  // Decrypt the note value using stored IV
  Future<String> _decryptNote(String encryptedNote, String ivBase64, String encryptionKey) async {
    final key = encrypt.Key.fromUtf8(encryptionKey.padRight(32, ' ')); // AES key needs to be 32 bytes
    final iv = encrypt.IV.fromBase64(ivBase64); // Decode the base64 IV

    // Decode the encrypted note from base64
    final encryptedData = encrypt.Encrypted.fromBase64(encryptedNote); // Decode the encrypted note

    // Decrypt the note using AES
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt(encryptedData, iv: iv);

    return decrypted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log Emotion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _emotionController.text.isNotEmpty ? _emotionController.text : null,
              decoration: InputDecoration(labelText: 'Select Emotion'),
              items: ['Anxiety', 'Happy', 'Sad', 'Stressed'].map((emotion) {
                return DropdownMenuItem(value: emotion, child: Text(emotion));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _emotionController.text = value ?? '';
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: 'Note'),
            ),
            SizedBox(height: 20),
            Text('Intensity: ${_intensity.toInt()}'),
            Slider(
              value: _intensity,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _intensity = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logEmotion,
              child: Text('Log Emotion'),
            ),
          ],
        ),
      ),
    );
  }
}
