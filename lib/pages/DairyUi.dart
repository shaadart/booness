import 'package:booness/services/realtime_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

class DiaryUI extends StatefulWidget {
  const DiaryUI({super.key});
  @override
  _DiaryUIState createState() => _DiaryUIState();
}

class _DiaryUIState extends State<DiaryUI> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      child: Column(
        children: [
          Text("Today",
              style: GoogleFonts.cedarvilleCursive(
                  fontSize: 21, fontWeight: FontWeight.bold)),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(color: Colors.black, width: 1.2)),
            elevation: 0,
            child: Container(
              height: MediaQuery.of(context).size.width / 2,
              width: MediaQuery.of(context).size.width / 1.15,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't forget Your Days"),
                    Icon(
                        color: Colors.grey,
                        PhosphorIcons.plus_circle,
                        size: 89),
                    Text("Tap to Add Your day"),
                  ],
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
                Map<String, List<dynamic>> groupedEntries = _groupByMonth(list);

                return ListView.builder(
                  itemCount: groupedEntries.length,
                  itemBuilder: (context, monthIndex) {
                    String monthYear =
                        groupedEntries.keys.elementAt(monthIndex);
                    List<dynamic> monthEntries = groupedEntries[monthYear]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          // Add Month Header
                          padding: const EdgeInsets.all(8.0),
                          child: Text(monthYear,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        StaggeredGridView.countBuilder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          itemCount: monthEntries.length,
                          itemBuilder: (context, entryIndex) => DiaryCard(
                            monthEntries[entryIndex]['entry'],
                            monthEntries[entryIndex]['title'],
                            monthEntries[entryIndex]['date']
                                .toString()
                                .substring(0, 10),
                          ),
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
    );
  }

  // Helper to Group by Month
  Map<String, List<dynamic>> _groupByMonth(List<dynamic> entries) {
    Map<String, List<dynamic>> groupedEntries = {};
    for (var entry in entries) {
      String dateString = entry['date'];
      String monthYearKey = dateString.substring(0, 7);
      groupedEntries.putIfAbsent(monthYearKey, () => []).add(entry);
    }
    return groupedEntries;
  }

// Your existing _buildCard Widget - No modifications needed (assumed)
  Widget DiaryCard(String entry, String title, String date) {
    // ... Your existing Card building code

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.black, width: 1.2),
      ),
      elevation: 0,
      child: Column(
        children: [
          ListTile(
            title: Text(
              // list[index]['title'],
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(entry
                // list[index]['entry']

                ),
          ),
          ListTile(
            subtitle: Text(
              date,
              //  list[index]['date'].toString().substring(0, 10),
              style: const TextStyle(fontSize: 8),
            ),
            // trailing: IconButton(
            //   icon: Icon(PhosphorIcons.download),
            //   onPressed: () {
            //     String desiredTitle = list[index]['title'];

            //     // Ensure accurate matching of titles
            //     DatabaseReference? itemRef = null;
            //     snapshot.data!.snapshot.children
            //         .forEach((childSnapshot) {
            //       if ((childSnapshot.value as Map<dynamic,
            //               dynamic>)['title'] ==
            //           desiredTitle) {
            //         itemRef = ref.child(childSnapshot.key!);
            //         return; // Exit loop after finding the match
            //       }
            //     });

            //     if (itemRef != null) {
            //       itemRef?.remove().then((_) {
            //         print('Item removed successfully');
            //         setState(
            //             () {}); // Refresh UI to reflect deletion
            //       }).catchError((error) {
            //         print('Error removing item: $error');
            //       });
            //     } else {
            //       print(
            //           'Item with title "$desiredTitle" not found');
            //     }
            //   },
            // ),
          ),
        ],
      ),
    );
    // Replace `Container()` with the appropriate widget you want to return.
  }
  // ... Your existing Card building code
}
