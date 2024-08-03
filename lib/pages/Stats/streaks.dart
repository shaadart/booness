import 'package:booness/services/streak_services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Streaks extends StatefulWidget {
  const Streaks({super.key});

  @override
  State<Streaks> createState() => _StreaksState();
}

class _StreaksState extends State<Streaks> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: streakRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        Map<dynamic, dynamic> map =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        List<dynamic> streakList = map.values.toList();
        final streak = streakList[2];
        final lives = streakList[1];
        final lastRecordedDate = streakList[0];

        print(
            "streak : $streak, lives: $lives Last recorded date: $lastRecordedDate");

        String streakString = streak.toString().padLeft(3, '0');
        String hundreds = streakString.length > 2 ? streakString[0] : '0';
        String tens = streakString.length > 1 ? streakString[1] : '0';
        String units = streakString.isNotEmpty ? streakString[2] : '0';

        return Center(
          child: Card(
            color: const Color.fromARGB(255, 242, 158, 255),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: hundreds,
                              style: GoogleFonts.silkscreen(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryFixedVariant
                                    .withOpacity(hundreds == '0' ? 0.5 : 0.8),
                              ),
                            ),
                            TextSpan(
                              text: tens,
                              style: GoogleFonts.silkscreen(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryFixedVariant
                                    .withOpacity(tens == '0' ? 0.5 : 0.8),
                              ),
                            ),
                            TextSpan(
                              text: units,
                              style: GoogleFonts.silkscreen(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryFixedVariant
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        textScaler: const TextScaler.linear(3),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          "Days",
                          style: GoogleFonts.silkscreen(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryFixedVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
