import 'package:booness/pages/Set%20up%20and%20sign%20up/setUsername.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';

import '../../main.dart';
import '../../services/realtime_database.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
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
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    }

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  handleGoogleBtnClick() {
    signInWithGoogle().then((value) {
      print(value.additionalUserInfo);
      print(value.user);
      Navigator.push(
        context,
        PageTransition(
          curve: Curves.fastEaseInToSlowEaseOut,
          duration: const Duration(milliseconds: 200),
          type: PageTransitionType.rightToLeft,
          child: const HomeScreen(
            title: '',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnBoardingSlider(
        onFinish: () {
          handleGoogleBtnClick();
        },
        headerBackgroundColor: Colors.white,
        finishButtonText: 'Register',
        finishButtonStyle: const FinishButtonStyle(
          backgroundColor: Colors.black,
        ),
        skipTextButton: const Text('Skip'),
        trailing: TextButton(
          onPressed: () {
            handleGoogleBtnClick();
          },
          child: const Text('Sign in with Google'),
        ),
        background: [
          Image.network(
              "https://cdn.dribbble.com/userupload/6958155/file/original-17e8a1864e2f95938e1a204a015312b9.jpg?resize=1504x1118"),
          Image.network(
              "https://cdn.dribbble.com/userupload/6958155/file/original-17e8a1864e2f95938e1a204a015312b9.jpg?resize=1504x1118"),
        ],
        totalPage: 2,
        speed: 1.8,
        pageBodies: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text('tHIS IS THE DESCRIPTION OIF THE SSHIT'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: const Column(
              children: <Widget>[
                SizedBox(
                  height: 480,
                ),
                Text('Description Text 2'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
