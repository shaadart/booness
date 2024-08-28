import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/streak_services.dart';

class MySliderScreen extends StatefulWidget {
  const MySliderScreen({super.key});

  @override
  _MySliderScreenState createState() => _MySliderScreenState();
}

class _MySliderScreenState extends State<MySliderScreen> {
  List<String> moods = [
    "😡",
    "😭",
    "😨",
    "😲",
    "😄",
    "🥰",
  ]; // Initial value

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        // color: Color.fromARGB(255, 18, 55, 17),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          // remove the const here
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //     Text(
              //   "Lives",
              //   style: GoogleFonts.silkscreen(
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: moods
                    .map((mood) => GestureDetector(
                          onTap: () {
                            setState(() {
                              print(mood);
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                mood,
                                style: const TextStyle(fontSize: 34),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

class YourLives extends StatefulWidget {
  const YourLives({super.key});

  @override
  State<YourLives> createState() => _YourLivesState();
}

class _YourLivesState extends State<YourLives> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: streakRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
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
          List<dynamic> livesList = map.values.toList();

          int totalLives = 5;
          int remainingLives = livesList[1];

          return Center(
            child: Card(
              // color: Theme.of(context).colorScheme.inversePrimary.withGreen(55),
            color: AdaptiveTheme.of(context).mode.isDark
                ? Theme.of(context).colorScheme.primary.withGreen(5)
                : Theme.of(context).colorScheme.primary.withGreen(89),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(totalLives, (index) {
                        return Icon(
                          PhosphorIcons.lightning_fill,
                          color: index < remainingLives
                              ? Colors.green
                              : const Color.fromARGB(255, 31, 0, 98),
                          size: 48,
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$remainingLives lives left for this month',
                      style: GoogleFonts.silkscreen(
                        color: Theme.of(context).indicatorColor.withGreen(144),
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class TreesPlanted extends StatefulWidget {
  const TreesPlanted({super.key});

  @override
  State<TreesPlanted> createState() => _TreesPlantedState();
}

class _TreesPlantedState extends State<TreesPlanted> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        // color: Color.fromARGB(255, 18, 55, 17),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Row(),
              Icon(PhosphorIcons.tree,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  size: 48),
              const SizedBox(height: 16),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
