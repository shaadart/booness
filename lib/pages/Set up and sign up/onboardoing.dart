import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:restart_app/restart_app.dart';

import '../../main.dart';
import '../../services/realtime_database.dart';
import '../../services/streak_services.dart';
import 'setUsername.dart'; // Import your setUsername screen here

class OnBoardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnBoardingScreen({Key? key, required this.onFinish}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
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

    // Sign in with Firebase Auth
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Check if the user is new
    final isNewUser = userCredential.additionalUserInfo?.isNewUser;

    if (isNewUser == true) {
      // New user setup
      await setUpUser();
      await fetchUserData(); // Fetch user data after setup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SetUsernameScreen()),
      );
    } else {
      // Existing user setup
      await fetchUserData(); // Fetch user data for existing users
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    }

    // Return the UserCredential
    return userCredential;
  }

  Future<void> setUpUser() async {
    // Initialize user data in Realtime Database
    await streakRef.set({
      "streak": 0,
      "lives": 5,
      "lastUpdated": DateTime.now().subtract(Duration(days: 1)).toString(),
    });
  }

  Future<void> fetchUserData() async {
    // Restart.restartApp();
    try {
      // Example: Fetch user's streak data
      DataSnapshot snapshot = (await streakRef.once()) as DataSnapshot;
      Object? userData = snapshot.value;
      print('Fetched user data: $userData');

      // Process userData as needed
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  handleGoogleBtnClick() {
    // Handle Google sign-in button click
    signInWithGoogle().then((value) {
      print(value.additionalUserInfo);
      print(value.user);

      // Navigate based on additional conditions if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the device's width and height
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Image.asset(
                  "assets/onboarding/login.png",
                  width: constraints.maxWidth,
                  height:
                      constraints.maxHeight * 0.4, // 40% of the screen height
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: ElevatedButton.icon(
                    icon: Icon(
                      PhosphorIcons.google_logo_fill,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Continue with Google',
                      style: GoogleFonts.silkscreen(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: handleGoogleBtnClick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffff00bf),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            size.shortestSide * 0.1, // 10% of the screen width
                        vertical:
                            size.longestSide * 0.02, // 2% of the screen height
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Implement your logic for replaying video
                  },
                  child: Text(
                    'Replay the video again',
                    style: GoogleFonts.workSans(
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.pinkAccent,
                      color: Color(0xffff00bf),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
