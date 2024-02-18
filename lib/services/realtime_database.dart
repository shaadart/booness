import 'package:booness/models/userData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';



final auth = FirebaseAuth.instance;
final ref =
    FirebaseDatabase.instance.ref().child('USERS').child(uid!).child('Post');


final usersRef = FirebaseDatabase.instance.ref('Users');
final usernamesRef = usersRef.child('usernames');
final postsRef = usernamesRef.child('Post');
final specificUserRef = usersRef.child('specificUserId');
