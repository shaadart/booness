import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'dart:typed_data';

// Generate a secure key and IV (Example keys, these should be securely generated and stored)
final keyValue = utf8.encode("1234567890123456"); // 16-byte key
final ivValue = utf8.encode("1234567890123456"); // 16-byte IV

Uint8List _convertStringToUint8List(String input) {
  return Uint8List.fromList(utf8.encode(input));
}

String encrypt(String plainText) {
  final key = Key(_convertStringToUint8List(utf8.decode(keyValue)));
  final iv = IV(_convertStringToUint8List(utf8.decode(ivValue)));
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  return encrypted.base64; // Returns a String
}


String decrypt(String encryptedData) {
  final key = Key(_convertStringToUint8List(utf8.decode(keyValue)));
  final iv = IV(_convertStringToUint8List(utf8.decode(ivValue)));
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  
  final decrypted = encrypter.decrypt64(encryptedData, iv: iv);
  return decrypted; // Returns a String
}
