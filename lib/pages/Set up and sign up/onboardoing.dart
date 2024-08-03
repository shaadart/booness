import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../main.dart';
import '../../services/realtime_database.dart';
import '../../services/streak_services.dart';
import 'setUsername.dart'; // Import your setUsername screen here

class OnBoardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnBoardingScreen({super.key, required this.onFinish});

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
        MaterialPageRoute(builder: (context) => const SetUsernameScreen()),
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
    await streakRef.set({
      "streak": 0,
      "lives": 5,
      "lastUpdated":
          DateTime.now().subtract(const Duration(days: 1)).toString(),
    });
  }

  Future<void> fetchUserData() async {
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

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 600;

  @override
  Widget build(BuildContext context) {
    // Get the device's width and height
    final size = MediaQuery.of(context).size;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: OverflowBox(
                  maxHeight: size.height,
                  maxWidth: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    "assets/onboarding/login.png",
                    fit: BoxFit.cover,
                    width: size.width,
                    height: size.height,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16.0, // Adjust the top padding as needed
              left: 16.0, // Adjust the left padding as needed
              child: IconButton.filled(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // Navigate back
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(
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
                backgroundColor: const Color(0xffff00bf),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        color: Colors.white,
      ),
    );
  }
}
