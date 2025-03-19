import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class OfflineViewEmotionsScreen extends StatefulWidget {
  const OfflineViewEmotionsScreen({super.key});

  @override
  _OfflineViewEmotionsScreenState createState() =>
      _OfflineViewEmotionsScreenState();
}

class _OfflineViewEmotionsScreenState extends State<OfflineViewEmotionsScreen> {
  List<Map<String, dynamic>> _emotions = []; // List to hold emotions data

  @override
  void initState() {
    super.initState();
    _fetchEmotions();
  }

  // Fetch the emotions from SharedPreferences
  Future<void> _fetchEmotions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> emotions = prefs.getStringList('offline_emotions') ?? [];

    // Decode the emotions and store them in _emotions list
    List<Map<String, dynamic>> tempEmotions = [];

    for (String emotion in emotions) {
      try {
        // Attempt to decode the emotion
        var decodedEmotion = jsonDecode(emotion);

        // Check if the decoded data is a Map<String, dynamic>
        if (decodedEmotion is Map<String, dynamic>) {
          // Check if encryption is enabled and if there's encrypted data
          bool isEncryptionEnabled = prefs.getBool('is_encryption_enabled') ?? false;
          String? encryptionKey = prefs.getString('encryption_key');

          if (isEncryptionEnabled && encryptionKey != null) {
            // Check if there's an IV and encrypted note
            String? encryptedNote = decodedEmotion['note'];
            String? ivBase64 = decodedEmotion['iv'];

            if (encryptedNote != null && ivBase64 != null) {
              // Decrypt the note if encryption is enabled
              String decryptedNote = await _decryptNote(
                  encryptedNote, ivBase64, encryptionKey);
              decodedEmotion['note'] = decryptedNote; // Replace encrypted note with decrypted one
            }
          }

          tempEmotions.add(decodedEmotion);
        }
      } catch (error) {
        // Handle the error if decoding fails
        print('Error decoding emotion: $error');
      }
    }

    setState(() {
      _emotions = tempEmotions;
    });
  }

  // Decrypt the note value using stored IV
  Future<String> _decryptNote(
      String encryptedNote, String ivBase64, String encryptionKey) async {
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
      appBar: AppBar(title: Text('View Emotions')),
      body: _emotions.isEmpty
          ? Center(child: Text('No emotions logged yet.'))
          : ListView.builder(
              itemCount: _emotions.length,
              itemBuilder: (context, index) {
                final emotion = _emotions[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(emotion['emotion_felt'] ?? 'No emotion'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Intensity: ${emotion['emotion_intensity'] ?? 'N/A'}'),
                        Text('Note: ${emotion['note'] ?? 'No notes'}'),
                        Text('Timestamp: ${emotion['timestamp'] ?? 'N/A'}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
