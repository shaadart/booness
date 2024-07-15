import 'package:booness/main.dart';
import 'package:booness/pages/Set%20up%20and%20sign%20up/onboardoing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:restart_app/restart_app.dart';

class AuthService {
  Widget handleAuth() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return const MyApp();
          } else {
            return OnBoardingScreen(
              onFinish: () {},
            );
          }
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

Future<void> signOut(BuildContext context) async {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  await GoogleSignIn().signOut(); // sign out with Google

  await firebaseAuth.signOut(); // firebase signout
  FirebaseFirestore.instance
      .clearPersistence(); // Clear any cached data or local storage here if necessary

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => OnBoardingScreen(
        onFinish: () {},
      ),
    ),
  );
  // Restart.restartApp();
}
