import 'dart:collection';

import 'package:booness/services/realtime_database.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'Stats/writeDiary.dart';
import 'DiaryCard.dart';

TextEditingController searchController = TextEditingController();

class DiaryUI extends StatefulWidget {
  const DiaryUI({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DiaryUIState createState() => _DiaryUIState();
}

class _DiaryUIState extends State<DiaryUI> {
  String currentMonthYear = DateFormat('yyyy-MM').format(DateTime.now());

  Map<String, List<dynamic>> _groupByMonth(List<dynamic> entries) {
    SplayTreeMap<String, List<dynamic>> groupedEntries =
        SplayTreeMap<String, List<dynamic>>((a, b) => b.compareTo(a));

    for (var entry in entries) {
      String dateString = entry['date'];
      String monthYearKey = dateString.substring(0, 7);

      groupedEntries.putIfAbsent(monthYearKey, () => []).add(entry);

      // Sort each month's entries in descending order by date
      groupedEntries[monthYearKey]!.sort((a, b) {
        DateTime dateA = DateTime.parse(a['date']);
        DateTime dateB = DateTime.parse(b['date']);
        return dateB.compareTo(dateA);
      });
    }

    return groupedEntries;
  }

  @override
  void initState() {
    super.initState();
    controllerBottomCenter =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    controllerBottomCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: controllerBottomCenter,
      blastDirectionality: BlastDirectionality
          .explosive, // don't specify a direction, blast randomly
      shouldLoop: false, // start again as soon as the animation is finished
      colors: const [
        Colors.green,
        Colors.blue,
        Colors.pink,
        Colors.orange,
        Colors.purple,
        Colors.yellow,
        Colors.blueAccent,
        Colors.redAccent,
        Colors.greenAccent,
        Colors.purpleAccent,
        Colors.white,
        Colors.cyan,
        Colors.indigo,
        Colors.lime,
        Colors.indigoAccent
      ], // manual
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: StreamBuilder<DatabaseEvent>(
            stream: ref.onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              Map<dynamic, dynamic> map = snapshot.data!.snapshot.value != null
                  ? snapshot.data!.snapshot.value as Map<dynamic, dynamic>
                  : {};
              List<dynamic> list = map.values.toList();
              Map<String, List<dynamic>> groupedEntries = _groupByMonth(list);

              // Filter grouped entries based on search criteria
              Map<String, List<dynamic>> filteredGroupedEntries = {};
              String searchText = searchController.text.toLowerCase();
              groupedEntries.forEach((monthYear, entries) {
                List<dynamic> filteredEntries = entries.where((entry) {
                  return entry['title'].toLowerCase().contains(searchText) ||
                      entry['entry'].toLowerCase().contains(searchText);
                }).toList();

                if (filteredEntries.isNotEmpty) {
                  filteredGroupedEntries[monthYear] = filteredEntries;
                }
              });

              return (filteredGroupedEntries.isNotEmpty)
                  ? ListView.builder(
                      itemCount: filteredGroupedEntries.length,
                      itemBuilder: (context, monthIndex) {
                        String monthYear =
                            filteredGroupedEntries.keys.elementAt(monthIndex);
                        List<dynamic> monthEntries =
                            filteredGroupedEntries[monthYear]!;

                        // Get Month Name and Year
                        String formattedMonthYear = _formatMonthYear(monthYear);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.065),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedMonthYear.substring(
                                        0, formattedMonthYear.length - 4),
                                    style: GoogleFonts.cedarvilleCursive(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    formattedMonthYear.substring(
                                        formattedMonthYear.indexOf(' ') + 1),
                                    style: GoogleFonts.cedarvilleCursive(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StaggeredGridView.countBuilder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              itemCount: monthEntries.length,
                              itemBuilder: (context, entryIndex) {

                                return GestureDetector(
                                  onDoubleTap: () async {
                                    if (controllerBottomCenter.hasListeners) {
                                      controllerBottomCenter.play();
                                    }

                                    print(monthEntries[entryIndex]['images']);
                                  },
                                  child: DiaryCard(
                                    entry: monthEntries[entryIndex]['entry'],
                                    title: monthEntries[entryIndex]['title'],
                                    date: monthEntries[entryIndex]['date']
                                        .toString()
                                        .substring(0, 10),
                                    id: monthEntries[entryIndex]['id'],
                                    imageUrls: monthEntries[entryIndex]
                                                    ['images'] ==
                                                null ||
                                            monthEntries[entryIndex]['images']
                                                .isEmpty
                                        ? []
                                        : List<String>.from(
                                            monthEntries[entryIndex]['images']),
                                  ),
                                );
                              },
                              staggeredTileBuilder: (int index) =>
                                  const StaggeredTile.fit(1),
                            ),
                          ],
                        );
                      },
                    )
                  : const Center(child: Text("Don't forget your days! \n ever again \t\t\t\t\t\t tap +"));
            },
          ),
        ),
      ),
    );
  }

  String _formatMonthYear(String monthYearKey) {
    DateTime date = DateFormat('yyyy-MM').parse(monthYearKey);
    return '${DateFormat('MMMM').format(date)} ${date.year}';
  }
}