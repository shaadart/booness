import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:booness/main.dart';
import 'package:booness/models/userData.dart';
import 'package:booness/pages/editDiary.dart';
import 'package:booness/pages/writeDiary.dart';
import 'package:booness/services/realtime_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlightable/highlightable.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../models/diaryentry.dart';
import '../services/storageServices.dart';

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
            Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: StreamBuilder<DatabaseEvent>(
                stream: ref.onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  Map<dynamic, dynamic> map = snapshot.data!.snapshot.value !=
                          null
                      ? snapshot.data!.snapshot.value as Map<dynamic, dynamic>
                      : {};
                  List<dynamic> list = map.values.toList();
                  Map<String, List<dynamic>> groupedEntries =
                      _groupByMonth(list);

                  return (map.isNotEmpty == true)
                      ? ListView.builder(
                          itemCount: groupedEntries.length,
                          itemBuilder: (context, monthIndex) {
                            String monthYear =
                                groupedEntries.keys.elementAt(monthIndex);
                            List<dynamic> monthEntries =
                                groupedEntries[monthYear]!;

                            // Get Month Name and Year
                            String formattedMonthYear =
                                _formatMonthYear(monthYear);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  // Add Month Header
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width *
                                          0.065),
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
                                              formattedMonthYear.indexOf(' ') +
                                                  1),
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
                                    final title =
                                        monthEntries[entryIndex]['title'];

                                    if (searchController.text
                                        .toLowerCase()
                                        .isEmpty) {
                                      return GestureDetector(
                                        onDoubleTap: () async {
                                          String entryId =
                                              monthEntries[entryIndex]['id'];

                                          String userId =
                                              '104072055207218763590';
                                          String folderName = '1711278135473';

                                          removeFolder(userId, folderName)
                                              .then((_) {
                                            print(
                                                'Folder deletion completed (if applicable).');
                                          });

                                          print("successfully deleted files");

                                          print(monthEntries[
                                              entryIndex]); // Inspect the entire entry
                                          print(monthEntries[entryIndex]
                                              ['images']);
                                        },
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
                                            monthEntries[entryIndex]['images']),
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
                                          monthEntries[entryIndex]['images']);
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
                        )
                      : const Center(child: Text("dr. Tenma"));
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

// Your existing _buildCard Widget - No modifications needed (assumed)
  Widget DiaryCard(
      String entry, String title, String date, String id, List? imageUrls) {
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
        print(imageUrls);

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
              images: (imageUrls == null || imageUrls.isEmpty)
                  ? ["404"]
                  : imageUrls,
            ),
          ),
        );

        print(DateTime.parse(date).toString());
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(width: 1.2),
        ),
        elevation: 0,
        child: Column(
          children: [
            ListTile(
              title: HighlightText(
                // list[index]['title'],
                title,
                highlight: Highlight(
                    words: searchController.text.isNotEmpty
                        ? searchController.text.split(' ')
                        : []),
                caseSensitive: false, // Turn on case-sensitive.
                detectWords: true, // Turn on full-word-detection.
      
                highlightStyle: TextStyle(
                  fontSize: const TextStyle().fontSize,
                  color: const Color.fromARGB(255, 253, 253, 253),
                  backgroundColor: const Color.fromARGB(164, 12, 249, 0),
                  fontWeight: FontWeight.w900,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            //  Text(""),
            ListTile(
              subtitle: HighlightText(
                plainText.length > 144
                    ? plainText.substring(0, 89) + ' ... '
                    : plainText,
                highlight: Highlight(
                    words: searchController.text.isNotEmpty
                        ? searchController.text.split(' ')
                        : []),
                caseSensitive: false, // Turn on case-sensitive.
                detectWords: true, // Turn on full-word-detection.
      
                highlightStyle: TextStyle(
                  fontSize: const TextStyle().fontSize,
                  color: const Color.fromARGB(255, 253, 253, 253),
                  backgroundColor: const Color.fromARGB(164, 12, 249, 0),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ListTile(
              subtitle: Text(
                date,
                //  list[index]['date'].toString().substring(0, 10),
                style: const TextStyle(fontSize: 8),
              ),
            ),
      
            if (imageUrls != null && imageUrls.isNotEmpty)
              SizedBox(
                   height: 100,
                child: ListView.builder(
                  scrollDirection:
                      Axis.horizontal, // Make images scrollable horizontally
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                   
                      
                      child: Image.network(imageUrls[index]),
                    );
                  },
                ),
              )
            // : Container()
          ],
        ),
      ),
    );
    // Replace `Container()` with the appropriate widget you want to return.
  }
  // ... Your existing Card building code
}
