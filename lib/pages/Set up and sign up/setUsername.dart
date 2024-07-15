import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../main.dart';

class SetUsernameScreen extends StatefulWidget {
  @override
  _SetUsernameScreenState createState() => _SetUsernameScreenState();
}

class _SetUsernameScreenState extends State<SetUsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final DatabaseReference usernamesRef =
      FirebaseDatabase.instance.reference().child('usernames');

  bool isUsernameAvailable = true;
  bool isChecking = false;
  String? errorMessage;

  Future<void> checkUsernameAvailability(String username) async {
    setState(() {
      isChecking = true;
      errorMessage = null;
    });

    final DataSnapshot snapshot = (await usernamesRef.once()) as DataSnapshot;
    final Map<dynamic, dynamic> usernames =
        snapshot.value as Map<dynamic, dynamic>;

    setState(() {
      isUsernameAvailable = !usernames.containsValue(username);
      isChecking = false;
      if (!isUsernameAvailable) {
        errorMessage =
            'Username is not available. Please choose another username.';
      }
    });
  }

  Future<void> saveUsername(String username) async {
    await usernamesRef.push().set(username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Username'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
              onChanged: (value) {
                if (!isChecking && errorMessage != null) {
                  setState(() {
                    errorMessage = null;
                  });
                }
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => MyApp()));
              },
              // isChecking
              //     ? null
              //     : () async {
              //         final String username = _usernameController.text.trim();
              //         if (username.isNotEmpty) {
              //           await checkUsernameAvailability(username);
              //           if (isUsernameAvailable) {
              //             await saveUsername(username);
              //             Navigator.pushReplacement(
              //               context,
              //               MaterialPageRoute(builder: (context) => MyApp()),
              //             );
              //           }
              //         }
              //       },
              child: isChecking
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text('Save'),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
