import 'dart:collection';
import 'dart:convert';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:booness/services/realtime_database.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import '../../provider/search_controller_provider.dart';
import '../../services/exncryption_and_decryption.dart';
import '../Read Write Edit/readDiary.dart';
import '../Stats/stats.dart';
import 'DiaryCard.dart';

//TextEditingController searchController = TextEditingController();

class DiaryUI extends StatefulWidget {
  final ScrollController scrollController; // Add this
  const DiaryUI(
      {super.key, required this.scrollController}); // Modify constructor

  @override
  _DiaryUIState createState() => _DiaryUIState();
}

class _DiaryUIState extends State<DiaryUI> {
  String currentMonthYear = DateFormat('yyyy-MM').format(DateTime.now());
  late ConfettiController confettiController;
  Map<String, dynamic>? _selectedEntry; // Initialize as null or empty map
  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= 600;
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 600;
  @override
  void initState() {
    super.initState();

    confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    confettiController.dispose();

    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleDiaryCardTap(BuildContext context, String title, String entry,
      String date, String id, List<String> imageUrls) {
    // Check if the current entry is the same as the tapped entry
    if (_selectedEntry != null && _selectedEntry!['id'] == id) {
      // If the tapped entry is the currently selected entry, deselect it
      setState(() {
        _selectedEntry = null;
      });
    } else {
      // Otherwise, select the new entry
      setState(() {
        _selectedEntry = {
          'title': title,
          'entry': entry,
          'date': date,
          'id': id,
          'images':
              imageUrls.isNotEmpty ? imageUrls : [], // Ensure non-null images
        };
      });
    }
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

  Map<String, List<dynamic>> _decryptEntries(Map<dynamic, dynamic> entries) {
    Map<String, List<dynamic>> decryptedEntries = {};

    entries.forEach((key, value) {
      List<dynamic> decryptedList = value.map((entry) {
        String decryptedTitle = EncryptionService.decryptText(entry['title']);
        String decryptedEntry = EncryptionService.decryptText(entry['entry']);
        return {
          'title': decryptedTitle,
          'entry': decryptedEntry,
          'date': entry['date'],
          'id': entry['id'],
          'images': entry['images']
        };
      }).toList();

      decryptedEntries[key] = decryptedList;
    });

    return decryptedEntries;
  }

  Map<String, List<dynamic>> _filterEntries(
      Map<String, List<dynamic>> groupedEntries) {
    Map<String, List<dynamic>> filteredGroupedEntries = {};
    final searchController =
        Provider.of<SearchControllerProvider>(context).searchController;
    String searchText = searchController.text.toLowerCase();

    groupedEntries.forEach((monthYear, entries) {
      List<dynamic> filteredEntries = entries.where((entry) {
        // Perform the search on decrypted text
        bool titleMatches = entry['title'].toLowerCase().contains(searchText);
        bool entryMatches = entry['entry'].toLowerCase().contains(searchText);

        return titleMatches || entryMatches;
      }).toList();

      if (filteredEntries.isNotEmpty) {
        filteredGroupedEntries[monthYear] = filteredEntries;
      }
    });

    return filteredGroupedEntries;
  }

  String _formatMonthYear(String monthYearKey) {
    DateTime date = DateFormat('yyyy-MM').parse(monthYearKey);
    return '${DateFormat('MMMM').format(date)} ${date.year}';
  }

  ValueNotifier<String?> highlightedId = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    final searchController =
        Provider.of<SearchControllerProvider>(context).searchController;
    searchController.addListener(_onSearchChanged);
    return OrientationBuilder(
      builder: (context, orientation) {
        
        return ListView(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: StreamBuilder<DatabaseEvent>(
                    stream: ref.onValue,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      Map<dynamic, dynamic> map =
                          snapshot.data!.snapshot.value != null
                              ? snapshot.data!.snapshot.value
                                  as Map<dynamic, dynamic>
                              : {};
                      List<dynamic> list = map.values.toList();

                      if (list.isEmpty) {
                        return const Center(
                          child: Column(
                            children: [
                              Stats(),
                              SizedBox(height: 20),
                              Text(
                                "Don't forget your days! \n ever again, tap +",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      Map<String, List<dynamic>> groupedEntries =
                          _groupByMonth(list);

                      // Decrypt entries before filtering and displaying
                      Map<String, List<dynamic>> decryptedGroupedEntries =
                          _decryptEntries(groupedEntries);
                      Map<String, List<dynamic>> filteredGroupedEntries =
                          _filterEntries(decryptedGroupedEntries);

                      if (filteredGroupedEntries.isEmpty) {
                        return const Center(
                          child: Column(
                            children: [
                              Stats(),
                              SizedBox(height: 20),
                              Text(
                                "Don't forget your days! \n ever again, tap +",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return CustomScrollView(
                        controller: widget.scrollController,
                        slivers: [
                          const SliverToBoxAdapter(
                            child: Stats(),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, monthIndex) {
                                String monthYear = filteredGroupedEntries.keys
                                    .elementAt(monthIndex);
                                List<dynamic> monthEntries =
                                    filteredGroupedEntries[monthYear]!;

                                String formattedMonthYear =
                                    _formatMonthYear(monthYear);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(isDesktop(context)
                                          ? 0
                                          : MediaQuery.of(context).size.width *
                                              0.025),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            " " +
                                                formattedMonthYear.substring(
                                                    0,
                                                    formattedMonthYear.length -
                                                        4),
                                            style: GoogleFonts.silkscreen(
                                              fontSize: 21,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            formattedMonthYear.substring(
                                                formattedMonthYear
                                                        .indexOf(' ') +
                                                    1),
                                            style: GoogleFonts.silkscreen(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: StaggeredGridView.countBuilder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        itemCount: monthEntries.length,
                                        itemBuilder: (context, entryIndex) {
                                          return DiaryCard(
                                            entry: monthEntries[entryIndex]
                                                ['entry'],
                                            title: monthEntries[entryIndex]
                                                ['title'],
                                            date: monthEntries[entryIndex]
                                                    ['date']
                                                .toString()
                                                .substring(0, 10),
                                            id: monthEntries[entryIndex]['id'],
                                            imageUrls: (monthEntries[entryIndex]
                                                                ['images']
                                                            as List<dynamic>?)
                                                        ?.isEmpty ??
                                                    true
                                                ? []
                                                : List<String>.from(
                                                    monthEntries[entryIndex]
                                                            ['images']
                                                        as List<dynamic>),
                                            onTap: (BuildContext context,
                                                String title,
                                                String entry,
                                                String date,
                                                String id,
                                                List<String> imageUrls) {
                                              _handleDiaryCardTap(
                                                  context,
                                                  title,
                                                  entry,
                                                  date,
                                                  id,
                                                  imageUrls);
                                            },
                                            highlightedId: highlightedId,
                                          );
                                        },
                                        staggeredTileBuilder: (index) =>
                                            const StaggeredTile.fit(1),
                                        mainAxisSpacing: 8.0,
                                        crossAxisSpacing: 8.0,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              childCount: filteredGroupedEntries.keys.length,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              isDesktop(context)
                  ? Expanded(
                      flex: 9,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: _selectedEntry != null
                            ? Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.9,
                                decoration: BoxDecoration(
                                  color: AdaptiveTheme.of(context)
                                     
                                      .theme
                                      .cardColor
                                      .withOpacity(0.5), // Background color
                                  borderRadius: BorderRadius.circular(
                                      12.0), // Border radius
                                ),
                                child: buildReadingWidget(
                                  context,
                                  FocusNode(),
                                  QuillController(
                                    document: Document.fromDelta(
                                      Delta.fromJson(
                                        jsonDecode(_selectedEntry!['entry']),
                                      ),
                                    ),
                                    selection: const TextSelection.collapsed(
                                        offset: 0),
                                  ),
                                  _selectedEntry!['title'],
                                  _selectedEntry!['id'],
                                  _selectedEntry!['images'] != null &&
                                          _selectedEntry!['images'] is List
                                      ? List<String>.from(
                                          _selectedEntry!['images'] as List)
                                      : [], // Handle null or incorrectly typed images
                                ))
                            : Card(
                                color: AdaptiveTheme.of(context)
                                    .theme
                                    .shadowColor
                                    .withOpacity(0.5),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.9,
                                  child: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "📝🎨🖌️",
                                          style: TextStyle(fontSize: 55),
                                        ),
                                        Text(
                                          'Select a Diary to read',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ]);
      },
    );
  }
}
