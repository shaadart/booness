import 'package:booness/pages/Set%20up%20and%20sign%20up/setUsername.dart';
import 'package:booness/services/realtime_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:page_transition/page_transition.dart';

import '../../main.dart';

// void main() => runApp(MyApp());

//All of the Details of the Person

// retreive user data from cloud firestore

class Authentication_Screen extends StatefulWidget {
  const Authentication_Screen({super.key});

  @override
  State<Authentication_Screen> createState() => _Authentication_ScreenState();
}

class _Authentication_ScreenState extends State<Authentication_Screen> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Authentication Screen',
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    Future signInWithGoogle() async {
      // Trigger the authentication flow
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);
      final isNewUser = userCredential.additionalUserInfo?.isNewUser;

      if (isNewUser == true) {
        // Navigate to SetUsernameScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SetUsernameScreen()),
        );
      } else {
        // Navigate to MyApp
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      }

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }

    handleGoogleBtnClick() {
      signInWithGoogle().then((value) {
        print(value.additionalUserInfo);
        print(value.user);
      });
    }

    return Scaffold(
      backgroundColor: Color.fromRGBO(89, 89, 255, 100),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            handleGoogleBtnClick();

            // If sign in was successful, navigate to the home page
            Navigator.push(
                context,
                PageTransition(
                  curve: Curves.fastEaseInToSlowEaseOut,
                  duration: const Duration(milliseconds: 200),
                  type: PageTransitionType.bottomToTop,
                  child: const MyApp(),
                ));
          },
          child: const Text("Sign In"),
        ),
      ),
    );
  }
}
