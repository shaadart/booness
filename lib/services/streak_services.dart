import 'package:firebase_database/firebase_database.dart';

import '../models/userData.dart';

final streakRef = FirebaseDatabase.instance.ref('USERS/${uid!}/Streak');

