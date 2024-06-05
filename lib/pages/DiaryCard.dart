import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:highlightable/highlightable.dart';
import 'dart:convert';
import 'package:page_transition/page_transition.dart';

import '../models/userData.dart';
import '../services/realtime_database.dart';
import 'DairyUi.dart';
import 'Stats/editDiary.dart';

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

  @override
  void initState() {
    super.initState();
    // Initialize offsets for each image
    imageOffsets = {};
    final imagePositionalRef = FirebaseDatabase.instance
        .ref()
        .child('USERS')
        .child(uid!)
        .child('Post')
        .child(widget.id);

    imagePositionalRef.get().then((DataSnapshot data) async {
      print((data.value! as Map)["image_position"][0]);
      setState(() {
        leftPosition = (data.value! as Map)["image_position"][0].toDouble();
        topPosition = (data.value! as Map)["image_position"][1].toDouble();
      });
    });

    _fetchInitialPositions();
    for (int i = 0; i < widget.imageUrls.length; i++) {
      imageOffsets[i] = Offset(20.0 * i, 0.0); // Initial offsets set to (0, 0)
    }
  }

  Future<void> _fetchInitialPositions() async {
    final imagePositionalRef = FirebaseDatabase.instance
        .ref()
        .child('USERS')
        .child(uid!)
        .child('Post')
        .child(widget.id);
    try {
      final snapshot = await imagePositionalRef.get();
      if (snapshot.exists) {
        final dynamic value = snapshot.value;
        if (value is Map<String, dynamic>) {
          final Map<String, dynamic>? initialValue = value;
          if (initialValue != null &&
              initialValue.containsKey('initial_position')) {
            setState(() {
              leftPosition = (initialValue['initial_position'] as Map)['left'];
              topPosition = (initialValue['initial_position'] as Map)['top'];
            });
          }
        }
      }
    } catch (e) {
      // Handle error (e.g., network error, data not found)
      print('Error fetching initial positions: $e');
      // You can use default positions here or show a loading indicator
    }
  }

  Widget _buildSingleImage(BoxConstraints constraints) {
    final imagePositionalRef = FirebaseDatabase.instance
        .ref()
        .child('USERS')
        .child(uid!)
        .child('Post')
        .child(widget.id);

    imagePositionalRef.get().then((DataSnapshot data) async {
      leftPosition = ((data.value! as Map)["image_position"][0]).toDouble();
      topPosition = ((data.value! as Map)["image_position"][1]).toDouble();
    });

    if (widget.imageUrls.isEmpty) return Container();

    String imageUrl = widget.imageUrls.first;
    return Positioned(
      left: leftPosition,
      top: topPosition,
      child: Draggable(
        onDragEnd: (details) {
          imagePositionalRef.get().then((DataSnapshot data) async {
            setState(() {
              leftPosition =
                  (data.value! as Map)["image_position"][0].toDouble();
              topPosition =
                  (data.value! as Map)["image_position"][1].toDouble();
            });
          });
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
    final document =
        Document.fromDelta(Delta.fromJson(jsonDecode(widget.entry)));
    final plainText = document.toPlainText();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            curve: Curves.fastLinearToSlowEaseIn,
            duration: const Duration(milliseconds: 200),
            type: PageTransitionType.leftToRight,
            child: EditDiary(
              title: widget.title,
              entry: widget.entry,
              date: DateTime.parse(widget.date).toString(),
              id: widget.id,
              images: widget.imageUrls.isEmpty ? ["404"] : widget.imageUrls,
            ),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
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
                        widget.title,
                        highlight: Highlight(
                          words: searchController.text.isNotEmpty
                              ? searchController.text.split(' ')
                              : [],
                        ),
                        caseSensitive: false,
                        detectWords: true,
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
                    ListTile(
                      subtitle: HighlightText(
                        plainText.length > 144
                            ? plainText.substring(0, 89) + ' ... '
                            : plainText,
                        highlight: Highlight(
                          words: searchController.text.isNotEmpty
                              ? searchController.text.split(' ')
                              : [],
                        ),
                        caseSensitive: false,
                        detectWords: true,
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
                        widget.date,
                        style: const TextStyle(fontSize: 8),
                      ),
                    ),
                  ],
                ),
              ),
              _buildSingleImage(constraints),
            ],
          );
        },
      ),
    );
  }
}
