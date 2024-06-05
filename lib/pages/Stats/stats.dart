

import 'package:booness/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/realtime_database.dart';

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
              child:  Text(
              "Hey ${currentUser?.displayName}, ",
              style: GoogleFonts.cedarvilleCursive(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
              ),
          
      Text("❤️ ❤️ ❤️ ❤️ ❌")
            
          ],
        ),
      ),
    );
  }
}