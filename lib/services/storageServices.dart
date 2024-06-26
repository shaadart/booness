
import 'package:firebase_storage/firebase_storage.dart';

Future<void> removeFolder(String userId, String folderName) async {
  // Get a reference to the user's storage location
  final storage = FirebaseStorage.instance;
  final userRef = storage.ref().child(userId);

  // List all items (files) within the user's storage
  final listResult = await userRef.listAll();

  // Iterate through each item and delete if its path starts with the folder name
  for (var item in listResult.items) {
    if (item.fullPath.startsWith(folderName)) {
      await item.delete();
    }
  }

  print(
      'Folder contents likely deleted for user $userId and folder name $folderName.');
}
