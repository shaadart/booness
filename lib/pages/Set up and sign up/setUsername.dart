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
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final String username = _usernameController.text.trim();
                if (username.isNotEmpty) {
                  usernamesRef.once().then((DataSnapshot snapshot) {
                        Object? usernames = snapshot.value;
                        if ((usernames as Map<dynamic, dynamic>)
                            .containsValue(username)) {
                          setState(() {
                            isUsernameAvailable = false;
                          });
                        } else {
                          usernamesRef.push().set(username);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => MyApp()));
                          // Add any additional logic here
                        }
                      } as FutureOr Function(DatabaseEvent value));
                }
              },
              child: Text('Save'),
            ),
            if (!isUsernameAvailable)
              Text(
                'Username is not available. Please choose another username.',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
