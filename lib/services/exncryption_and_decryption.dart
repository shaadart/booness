import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionService {
  final String uid;

  EncryptionService(this.uid);

  // Generate a 32-byte key from the uid
  Key _generateKey() {
    final keyBytes = utf8.encode(uid);
    final hash = sha256.convert(keyBytes).bytes;
    return Key(Uint8List.fromList(hash));
  }

  // Encrypt text using the uid as the encryption key
  String encryptText(String text) {
    final key = _generateKey();
    final iv = IV.fromLength(16); // Use a random IV for each encryption

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(text, iv: iv);

    // Encode IV and encrypted data as base64 and concatenate them
    final result = base64.encode(iv.bytes) + ':' + encrypted.base64;
    return result;
  }

  // Decrypt text using the uid as the decryption key
  String decryptText(String encryptedText) {
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
      return '';
    }
  }
}
