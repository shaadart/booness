import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EncryptionService {
  // Retrieve the UID of the current user
  static final String? uid =
      FirebaseAuth.instance.currentUser?.providerData[0].uid;

  // Generate a 32-byte key from the static uid
  static Key _generateKey() {
    if (uid == null || uid!.isEmpty) {
      throw ArgumentError('UID cannot be null or empty');
    }
    final keyBytes = utf8.encode(uid!);
    final hash = sha256.convert(keyBytes).bytes;
    return Key(Uint8List.fromList(hash));
  }

  // Encrypt text using AES encryption
  static String encryptText(String text) {
    if (text.isEmpty) {
      print("Error: Text cannot be empty");
      throw ArgumentError('Text cannot be empty');
    }

    try {
      final key = _generateKey();
      final iv = IV.fromLength(16); // Generate a 16-byte IV

      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      print("Key: ${key.bytes}");
      print("IV: ${iv.bytes}");
      print("Text: $text");

      // Encrypt the text
      final encrypted = encrypter.encrypt(text, iv: iv);
      print("Encrypted: ${encrypted.base64}");

      // Encode IV and encrypted data as base64 and concatenate them
      final result = '${base64.encode(iv.bytes)}:${encrypted.base64}';
      return result;
    } catch (e) {
      print("Encryption error: $e");
      throw e;
    }
  }

  // Decrypt text using AES encryption
  static String decryptText(String encryptedText) {
    if (encryptedText.isEmpty) {
      print("Error: Encrypted text cannot be empty");
      return ''; // Handle empty encrypted text
    }

    try {
      final key = _generateKey();
      final parts = encryptedText.split(':');
      if (parts.length != 2) {
        throw FormatException('Invalid encrypted text format');
      }

      final iv = IV.fromBase64(parts[0]);
      final encryptedData = Encrypted.fromBase64(parts[1]);

      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final decrypted = encrypter.decrypt(encryptedData, iv: iv);

      return decrypted;
    } catch (e) {
      print("Decryption error: $e");
      return ''; // Handle decryption failure gracefully
    }
  }

  // Static instance getter for EncryptionService
  static EncryptionService get instance => EncryptionService._internal();

  // Private constructor for singleton pattern
  EncryptionService._internal();
}
