import '../main.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;


String? name = currentUser!.displayName;
String? email = currentUser!.email;
String? photoUrl = currentUser!.photoURL;
String? uid =
    currentUser!.providerData[0].uid; //new and final and permannet uid


