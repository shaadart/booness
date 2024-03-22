import 'dart:convert';

import 'package:booness/pages/editDiary.dart';
import 'package:booness/pages/writeDiary.dart';
import 'package:booness/services/realtime_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../models/diaryentry.dart';

TextEditingController searchController = TextEditingController();

class DiaryUI extends StatefulWidget {
  const DiaryUI({super.key});
  @override
  _DiaryUIState createState() => _DiaryUIState();
}

class _DiaryUIState extends State<DiaryUI> {
  String currentMonthYear = DateFormat('yyyy-MM').format(DateTime.now());

  void _deleteEntry(String entryId) {
    // Assuming 'ref' is your Firebase Database reference
    ref.child(entryId).remove().then((_) {
      print('Item removed successfully');
      setState(() {}); // Refresh the UI
    }).catchError((error) {
      print('Error removing item: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
        child: Column(
          children: [
            // Text("Today",
            //     style: GoogleFonts.cedarvilleCursive(
            //         fontSize: 21, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                      curve: Curves.fastEaseInToSlowEaseOut,
                      duration: const Duration(milliseconds: 200),
                      type: PageTransitionType.bottomToTop,
                      child: const WriteDiary(),
                    ));
              },
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                        // color: Colors.black,
                        width: 1.2)),
                elevation: 0,
                child: Container(
                  height: MediaQuery.of(context).size.width / 2,
                  width: MediaQuery.of(context).size.width / 1.15,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: 0.7,
                          child: Text("Don't forget Your Days"),
                        ),
                        Opacity(
                          opacity: 0.6,
                          child: Icon(
                              //  color: Colors.grey,
                              PhosphorIcons.plus_circle,
                              size: 80),
                        ),
                        Opacity(
                            opacity: 0.7, child: Text("Tap to Add Your day")),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: StreamBuilder<DatabaseEvent>(
                stream: ref.onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  Map<dynamic, dynamic> map =
                      snapshot.data!.snapshot.value as dynamic;
                  List<dynamic> list = map.values.toList();
                  Map<String, List<dynamic>> groupedEntries =
                      _groupByMonth(list);

                  return ListView.builder(
                    itemCount: groupedEntries.length,
                    itemBuilder: (context, monthIndex) {
                      String monthYear =
                          groupedEntries.keys.elementAt(monthIndex);
                      List<dynamic> monthEntries = groupedEntries[monthYear]!;

                      // Get Month Name and Year
                      String formattedMonthYear = _formatMonthYear(monthYear);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            // Add Month Header
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
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    formattedMonthYear.substring(
                                        formattedMonthYear.indexOf(' ') + 1),
                                    style: GoogleFonts.cedarvilleCursive(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                          ),
                          StaggeredGridView.countBuilder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            itemCount: monthEntries.length,
                            itemBuilder: (context, entryIndex) {
                              final title = monthEntries[entryIndex]['title'];

                              if (searchController.text.toLowerCase().isEmpty) {
                                return GestureDetector(
                                  onLongPress: () {
                                    _deleteEntry(
                                        monthEntries[entryIndex]['id']);
                                  },
                                  child: DiaryCard(
                                    monthEntries[entryIndex]['entry'],
                                    monthEntries[entryIndex]['title'],
                                    monthEntries[entryIndex]['date']
                                        .toString()
                                        .substring(0, 10),
                                    monthEntries[entryIndex]['id'],
                                  ),
                                );
                              } else if (title.toLowerCase().contains(
                                      searchController.text.toLowerCase()
                                        ..toLowerCase()) ||
                                  monthEntries[entryIndex]['entry']
                                      .toLowerCase()
                                      .contains(searchController.text
                                          .toLowerCase()
                                          .toLowerCase())) {
                                return DiaryCard(
                                  monthEntries[entryIndex]['entry'],
                                  monthEntries[entryIndex]['title'],
                                  monthEntries[entryIndex]['date']
                                      .toString()
                                      .substring(0, 10),
                                  monthEntries[entryIndex]['id'],
                                );
                                // Add your code here
                              } else {
                                // Add a return statement at the end
                                return Container();
                              }
                            },
                            staggeredTileBuilder: (int index) =>
                                const StaggeredTile.fit(1),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to Format Month and Year
  String _formatMonthYear(String monthYearKey) {
    DateTime date = DateFormat('yyyy-MM').parse(monthYearKey);
    return '${DateFormat('MMMM').format(date)} ${date.year}';
  }

  Map<String, List<dynamic>> _groupByMonth(List<dynamic> entries) {
    Map<String, List<dynamic>> groupedEntries = {};

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

// Your existing _buildCard Widget - No modifications needed (assumed)
  Widget DiaryCard(String entry, String title, String date, String id) {
    final document = Document.fromDelta(Delta.fromJson(jsonDecode(entry)));
    final plainText = document.toPlainText();
    // ... Your existing Card building code

    return GestureDetector(
      onTap: () {
        print("Title: ${title}");
        print("Entry: ${entry}");
        print("Id: ${id}");
        print("Plain Entry: ${plainText}");
        print("date: ${date}");

        Navigator.push(
          context,
          PageTransition(
            curve: Curves.fastEaseInToSlowEaseOut,
            duration: const Duration(milliseconds: 200),
            type: PageTransitionType.leftToRight,
            child: EditDiary(
              title: title,
              entry: entry,
              date: DateTime.parse(date).toString(),
              id: id,
            ),
          ),
        );

        print(DateTime.parse(date).toString());
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(width: 1.2),
        ),
        elevation: 0,
        child: Column(
          children: [
            ListTile(
              title: Text(
                // list[index]['title'],
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            //  Text(""),
            ListTile(
              subtitle: Text(
                plainText.length > 144
                    ? plainText.substring(0, 89) + ' ... '
                    : plainText,
              ),
            ),
            ListTile(
              subtitle: Text(
                date,
                //  list[index]['date'].toString().substring(0, 10),
                style: const TextStyle(fontSize: 8),
              ),
            ),
          ],
        ),
      ),
    );
    // Replace `Container()` with the appropriate widget you want to return.
  }
  // ... Your existing Card building code
}
