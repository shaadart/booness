import 'package:booness/main.dart';

String? name = currentUser!.displayName;
String? email = currentUser!.email;
String? photoUrl = currentUser!.photoURL;
String? uid =
    currentUser!.providerData[0].uid; //new and final and permannet uid
