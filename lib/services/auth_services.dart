import 'package:booness/main.dart';
import 'package:booness/pages/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  handleAuth() {
    return StreamBuilder(
      // ...

      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return const MyApp();
        } else {
          return const GoogleSignIn();
        }
      },
    );
  }
}

void signOut(context) async {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //await googleSignIn.signOut();
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleSignIn(),
      ));
  await firebaseAuth.signOut();
}
