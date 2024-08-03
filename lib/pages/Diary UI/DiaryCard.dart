import 'package:booness/pages/Read%20Write%20Edit/readDiary.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlightable/highlightable.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../../models/userData.dart';
import '../../provider/search_controller_provider.dart';
import '../../services/realtime_database.dart';
// Import the vibration package

class DiaryCard extends StatefulWidget {
  final String entry;
  final String title;
  final String date;
  final String id;
  final List<String> imageUrls;
  final Function(BuildContext, String, String, String, String, List<String>) onTap;
  final ValueNotifier<String?> highlightedId;

  const DiaryCard({
    super.key,
    required this.entry,
    required this.title,
    required this.date,
    required this.id,
    required this.imageUrls,
    required this.onTap,
    required this.highlightedId,
  });

  @override
  _DiaryCardState createState() => _DiaryCardState();
}

class _DiaryCardState extends State<DiaryCard> {
  late Map<int, Offset> imageOffsets;
  late double leftPosition = 0.0;
  late double topPosition = 0.0;

  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width <= 600;
  bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width > 600;

  @override
  void initState() {
    super.initState();
    // Initialize offsets for each image
    imageOffsets = {};
    for (int i = 0; i < widget.imageUrls.length; i++) {
      imageOffsets[i] = Offset(20.0 * i, 0.0); // Initial offsets set to (0, 0)
    }
    widget.highlightedId.addListener(_highlightListener);
  }

  @override
  void dispose() {
    widget.highlightedId.removeListener(_highlightListener);
    super.dispose();
  }

  void _highlightListener() {
    if (mounted) {
      setState(() {});
    }
  }

  Stream<DatabaseEvent> _imagePositionStream() {
    return FirebaseDatabase.instance
        .ref()
        .child('USERS')
        .child(uid!)
        .child('Post')
        .child(widget.id)
        .onValue;
  }

  Widget _buildSingleImage(BoxConstraints constraints, AsyncSnapshot<DatabaseEvent> snapshot) {
    if (widget.imageUrls.isEmpty) return Container();

    if (snapshot.hasData && snapshot.data != null && snapshot.data!.snapshot.value != null) {
      final data = snapshot.data!.snapshot.value as Map;
      leftPosition = (data["image_position"][0]).toDouble();
      topPosition = (data["image_position"][1]).toDouble();
    }

    String imageUrl = widget.imageUrls.first;
    return Positioned(
      left: leftPosition,
      top: topPosition,
      child: Draggable(
        onDragEnd: (details) async {
          setState(() {
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset localOffset = box.globalToLocal(details.offset);

            double maxDx = box.size.shortestSide - 55.0 + 25.0;
            double maxDy = box.size.longestSide - 55.0 + 25;

            double dx = localOffset.dx.clamp(-10.0, maxDx);
            double dy = localOffset.dy.clamp(-10.0, maxDy);

            imageOffsets[0] = Offset(dx, dy);

            ref.child(widget.id).update({
              'image_position': [dx, dy],
            });
          });
          // Trigger a small vibration when the image position is updated
          if (await Vibration.hasVibrator() ?? false) {
            Vibration.vibrate(duration: 50); // 50 milliseconds vibration
          }
        },
        feedback: imageUrl == "404"
            ? Container()
            : ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // Adjust the border radius here
                child: Image.network(
                  imageUrl,
                  width: 55,
                  height: 55,
                ),
              ),
        childWhenDragging: Container(),
        child: imageUrl == "404"
            ? Container()
            : ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // Adjust the border radius here
                child: Image.network(
                  imageUrl,
                  width: 55,
                  height: 55,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     final searchController = Provider.of<SearchControllerProvider>(context).searchController;
    final formattedDate = formatDate(widget.date);
    final document = Document.fromDelta(Delta.fromJson(jsonDecode(widget.entry)));
    final plainText = document.toPlainText();
    bool isHighlighted = widget.highlightedId.value == widget.id;

    return GestureDetector(
      onTap: () {
        widget.highlightedId.value = widget.id;
        if (isDesktop(context)) {
          widget.onTap(context, widget.title, widget.entry, widget.date, widget.id, widget.imageUrls);
        } else {
          Navigator.push(
            context,
            PageTransition(
              curve: Curves.fastEaseInToSlowEaseOut,
              duration: const Duration(milliseconds: 200),
              type: PageTransitionType.rightToLeft,
              child: ReadDiary(
                title: widget.title,
                entry: widget.entry,
                date: widget.date,
                id: widget.id,
                images: widget.imageUrls.isEmpty ? ["404"] : widget.imageUrls,
              ),
            ),
          );
        }
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return StreamBuilder<DatabaseEvent>(
            stream: _imagePositionStream(),
            builder: (context, snapshot) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Card(
                    color: isHighlighted
                        ? Theme.of(context).cardColor.withOpacity(0.5)
                        : Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                    child: Column(
                      children: [
                        ListTile(
                          title: HighlightText(
                            widget.title,
                            highlight: Highlight(
                              words: searchController.text.isNotEmpty
                                  ? searchController.text.split(' ')
                                  : [],
                            ),
                            caseSensitive: false,
                            detectWords: true,
                            highlightStyle: GoogleFonts.silkscreen(
                              color: Theme.of(context).indicatorColor.withGreen(144),
                            ),
                            style: GoogleFonts.silkscreen(
                              color: Theme.of(context).colorScheme.inverseSurface,
                            ),
                          ),
                        ),
                        ListTile(
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HighlightText(
                                plainText.length > 144
                                    ? '${plainText.substring(0, 89)} ... '
                                    : plainText,
                                highlight: Highlight(
                                  words: searchController.text.isNotEmpty
                                      ? searchController.text.split(' ')
                                      : [],
                                ),
                                caseSensitive: false,
                                detectWords: true,
                                highlightStyle: GoogleFonts.silkscreen(
                                  color: Theme.of(context).indicatorColor.withGreen(144),
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: GoogleFonts.silkscreen(fontSize: 8),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    Center(child: Container()),
                  if (snapshot.hasError)
                    const Center(child: Text('Error loading image positions')),
                  if (snapshot.hasData)
                    _buildSingleImage(constraints, snapshot),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

String formatDate(String date) {
  DateTime dateTime = DateTime.parse(date);
  String daySuffix;

  switch (dateTime.day % 10) {
    case 1:
      daySuffix = (dateTime.day == 11) ? 'th' : 'st';
      break;
    case 2:
      daySuffix = (dateTime.day == 12) ? 'th' : 'nd';
      break;
    case 3:
      daySuffix = (dateTime.day == 13) ? 'th' : 'rd';
      break;
    default:
      daySuffix = 'th';
  }

  String formattedDate = '${dateTime.day}$daySuffix ${DateFormat.MMMM().format(dateTime)}';
  return formattedDate;
}
