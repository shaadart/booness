import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';



class EncryptionService {
  static final String? uid =
      FirebaseAuth.instance.currentUser!.providerData[0].uid;

  // Generate a 32-byte key from the static uid
  static Key _generateKey() {
    final keyBytes = utf8.encode(uid!);
    final hash = sha256.convert(keyBytes).bytes;
    return Key(Uint8List.fromList(hash));
  }

  // Encrypt text using the static uid as the encryption key
  static String encryptText(String text) {
    final key = _generateKey();
    final iv = IV.fromLength(16); // Use a random IV for each encryption

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(text, iv: iv);

    // Encode IV and encrypted data as base64 and concatenate them
    final result = base64.encode(iv.bytes) + ':' + encrypted.base64;
    return result;
  }

  // Decrypt text using the static uid as the decryption key
  static String decryptText(String encryptedText) {
    if (encryptedText.isEmpty) {
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
