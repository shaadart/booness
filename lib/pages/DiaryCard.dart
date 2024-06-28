import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlightable/highlightable.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:page_transition/page_transition.dart';
import 'package:vibration/vibration.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import '../models/userData.dart';
import '../services/exncryption_and_decryption.dart';
import '../services/realtime_database.dart';
import 'DairyUi.dart';
import 'Write and Edit/editDiary.dart';

class DiaryCard extends StatefulWidget {
  final String entry;
  final String title;
  final String date;
  final String id;
  final List<String> imageUrls;

  const DiaryCard({
    super.key,
    required this.entry,
    required this.title,
    required this.date,
    required this.id,
    required this.imageUrls,
  });

  @override
  _DiaryCardState createState() => _DiaryCardState();
}

class _DiaryCardState extends State<DiaryCard> {
  late Map<int, Offset> imageOffsets;
  late double leftPosition = 0.0;
  late double topPosition = 0.0;
  late String decryptedTitle = ''; // Initialize with empty string
  late String decryptedEntry = ''; // Initialize with empty string

  @override
  void initState() {
    super.initState();
    imageOffsets = {};
    for (int i = 0; i < widget.imageUrls.length; i++) {
      imageOffsets[i] = Offset(20.0 * i, 0.0);
    }
    _decryptData();
  }

  void _decryptData() {
    try {
      EncryptionService encryptionService = EncryptionService(uid!);
      String decryptedTitleTemp = encryptionService.decryptText(widget.title);
      String decryptedEntryTemp = encryptionService.decryptText(widget.entry);

      // Print statements for debugging
      print("This is the widget.title: ${widget.title}");
      print("This is the decrypted title: $decryptedTitleTemp");
      print("This is the widget.entry: ${widget.entry}");
      print("This is the decrypted entry: $decryptedEntryTemp");

      setState(() {
        decryptedTitle = decryptedTitleTemp; // Update decryptedTitle
        decryptedEntry = decryptedEntryTemp; // Update decryptedEntry
      });
    } catch (e) {
      print("Decryption error: $e");
      setState(() {
        decryptedTitle = "Text Decryption Error";
        decryptedEntry = "Text Decryption Error";
      });
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

  Widget _buildSingleImage(
      BoxConstraints constraints, AsyncSnapshot<DatabaseEvent> snapshot) {
    if (widget.imageUrls.isEmpty) return Container();

    if (snapshot.hasData &&
        snapshot.data != null &&
        snapshot.data!.snapshot.value != null) {
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

            double maxDx = box.size.width - 55.0 + 25.0;
            double maxDy = box.size.height - 55.0 + 25;

            double dx = localOffset.dx.clamp(-10.0, maxDx);
            double dy = localOffset.dy.clamp(-10.0, maxDy);

            imageOffsets[0] = Offset(dx, dy);

            ref.child(widget.id).update({
              'image_position': [dx, dy],
            });
          });
          if (await Vibration.hasVibrator() ?? false) {
            Vibration.vibrate(duration: 50);
          }
        },
        feedback: imageUrl == "404"
            ? Container()
            : Image.network(
                imageUrl,
                width: 55,
                height: 55,
              ),
        childWhenDragging: Container(),
        child: imageUrl == "404"
            ? Container()
            : Image.network(
                imageUrl,
                width: 55,
                height: 55,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDate(widget.date);
    try {
      final document =
          Document.fromDelta(Delta.fromJson(jsonDecode(decryptedEntry)));
      final plainText = document.toPlainText();
      decryptedEntry = plainText; // Update the decryptedEntry to plainText
    } catch (e) {
      print("Error parsing decrypted entry: $e");
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          Navigator.push(
            context,
            PageTransition(
              curve: Curves.fastLinearToSlowEaseIn,
              duration: const Duration(milliseconds: 200),
              type: PageTransitionType.leftToRight,
              child: EditDiary(
                title: decryptedTitle,
                entry: decryptedEntry,
                date: DateTime.parse(widget.date).toString(),
                id: widget.id,
                images: widget.imageUrls.isEmpty ? ["404"] : widget.imageUrls,
              ),
            ),
          );
        });
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
                    color: Colors.white10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                    child: Column(
                      children: [
                        ListTile(
                          title: HighlightText(
                            decryptedTitle,
                            highlight: Highlight(
                              words: searchController.text.isNotEmpty
                                  ? searchController.text.split(' ')
                                  : [],
                            ),
                            caseSensitive: false,
                            detectWords: true,
                            highlightStyle: GoogleFonts.silkscreen(
                              color: Theme.of(context)
                                  .indicatorColor
                                  .withGreen(144),
                            ),
                            style: GoogleFonts.silkscreen(
                              color:
                                  Theme.of(context).colorScheme.inverseSurface,
                            ),
                          ),
                        ),
                        ListTile(
                          subtitle: HighlightText(
                            decryptedEntry.length > 144
                                ? decryptedEntry.substring(0, 89) + ' ... '
                                : decryptedEntry,
                            highlight: Highlight(
                              words: searchController.text.isNotEmpty
                                  ? searchController.text.split(' ')
                                  : [],
                            ),
                            caseSensitive: false,
                            detectWords: true,
                            highlightStyle: GoogleFonts.silkscreen(
                              color: Theme.of(context)
                                  .indicatorColor
                                  .withGreen(144),
                            ),
                            style: GoogleFonts.enriqueta(),
                          ),
                        ),
                        ListTile(
                          subtitle: Text(
                            formattedDate,
                            style: GoogleFonts.silkscreen(fontSize: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    Center(child: Container()),
                  if (snapshot.hasError)
                    Center(child: Text('Error loading image positions')),
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

  String formattedDate =
      '${dateTime.day}$daySuffix ${DateFormat.MMMM().format(dateTime)}';
  return formattedDate;
}
