
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:image/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

 // Import for path handling


Future<List<File>?> pickImages() async {
  // Use FilePicker to pick multiple images
  final result = await FilePicker.platform.pickFiles(allowMultiple: true);

  if (result != null) {
    return result.files.map((file) => File(file.path!)).toList();
  } else {
    return null;
  }
}

Future<List<String>> storeImagePaths(List<String> paths) async {
  final appDir = await getApplicationDocumentsDirectory();

  final imagePaths = <String>[];

  for (var path in paths) {
    final imagePath = join(appDir.path, path);
    final imageFile = File(imagePath);
    await imageFile.create(recursive: true);
    imagePaths.add(imagePath);
  }

  return imagePaths;
}
Future<String?> retrieveImagePath(String date) async {
  // Implement your retrieval logic based on date or other criteria

  final appDir = await getApplicationDocumentsDirectory();
  final storedImages = await Directory(appDir.path)
      .list()
      .where((entity) => entity is File)
      .toList();
  // Find the image that matches the given date (implement your logic)
  if (storedImages.isNotEmpty) {
    return storedImages.first.path;
  } else {
    return null;
  }
}
