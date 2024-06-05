import 'package:booness/main.dart';
import 'package:booness/pages/Set%20up%20and%20sign%20up/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  handleAuth() {
    return StreamBuilder(
      // ...

      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return const MyApp();
        } else {
          return const LoginScreen();
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
        builder: (context) => LoginScreen(),
      ));
  await firebaseAuth.signOut(); //firebase signout. 
  await GoogleSignIn().signOut(); //sign out with google 
}
