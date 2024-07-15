// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';
import 'package:booness/pages/Read%20Write%20Edit/editDiary.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';

import '../../main.dart';
import '../../models/userData.dart';

class ReadDiary extends StatefulWidget {
  final String title;
  final String entry;
  final String date;
  final String id;
  final List images;

  ReadDiary({
    super.key,
    required this.title,
    required this.entry,
    required this.date,
    required this.id,
    required this.images,
  });

  @override
  State<ReadDiary> createState() => _ReadDiaryState();
}

class _ReadDiaryState extends State<ReadDiary> {
  QuillController quillController = QuillController.basic();
  final _focusNode = FocusNode();
  List<String> _imagesNetwork = [];
  bool isLoading = false;

  double calculateFontSize(String title) {
    // Constants for font size calculations
    const int minTitleLength =
        1; // Assuming 1 as the minimum length of a title for max font size
    const int maxTitleLength =
        50; // Assuming 50 as the max length of a title for min font size
    const double minFontSize = 21.0;
    const double maxFontSize = 34.0;

    // Calculate the font size based on the title length
    double fontSize = maxFontSize;

    if (title.length > maxTitleLength) {
      fontSize = minFontSize;
    } else if (title.length < minTitleLength) {
      fontSize = maxFontSize;
    } else {
      // Calculate font size based on a simple linear interpolation between min and max lengths and font sizes
      double ratio =
          (title.length - minTitleLength) / (maxTitleLength - minTitleLength);
      fontSize = maxFontSize - ratio * (maxFontSize - minFontSize);
    }

    // Ensure font size is within the specified range
    return fontSize.clamp(minFontSize, maxFontSize);
  }

  @override
  void initState() {
    super.initState();

    _imagesNetwork = List<String>.from(widget.images);

    quillController = QuillController(
      document: Document.fromDelta(Delta.fromJson(jsonDecode(widget.entry))),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _deleteEntry(String id, List<String> imageUrls) async {
    final databaseRef = FirebaseDatabase.instance
        .ref()
        .child('USERS')
        .child(uid!)
        .child('Post')
        .child(id);

    try {
      for (String imageUrl in imageUrls) {
        if (imageUrl != "404") {
          try {
            final imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
            await imageRef.delete();
          } catch (e) {
            print("Error deleting image: $e");
          }
        }
      }

      await databaseRef.remove();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted successfully')),
      );
    } catch (e) {
      print("Problem deleting...: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final document =
        Document.fromDelta(Delta.fromJson(jsonDecode(widget.entry)));
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(PhosphorIcons.x),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageTransition(
                  curve: Curves.fastEaseInToSlowEaseOut,
                  duration: const Duration(milliseconds: 300),
                  type: PageTransitionType.topToBottom,
                  child: const HomeScreen(title: ''),
                ),
              );
            },
          ),
          actions: [
            PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(PhosphorIcons.pencil),
                    title: Text('Edit'),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
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
                          images:
                              widget.images.isEmpty ? ["404"] : widget.images,
                        ),
                      ),
                    );
                  },
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(PhosphorIcons.trash),
                    title: Text('Delete'),
                  ),
                  onTap: () {
                    _deleteEntry(widget.id, widget.images.cast<String>());
                    Navigator.pushReplacement(
                      context,
                      PageTransition(
                        curve: Curves.fastEaseInToSlowEaseOut,
                        duration: const Duration(milliseconds: 300),
                        type: PageTransitionType.topToBottom,
                        child: const HomeScreen(title: ''),
                      ),
                    );
                  },
                ),
              ],
              icon: Icon(PhosphorIcons.dots_three),
            )
          ],
          title: Opacity(
            opacity: 0.89,
            child: Text(
              "Read",
              style: GoogleFonts.silkscreen(),
            ),
          ),
          toolbarHeight: 50,
          centerTitle: true,
        ),
        body: Padding(
          padding:
              EdgeInsets.all(MediaQuery.of(context).size.shortestSide * 0.05),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(
                      MediaQuery.of(context).size.shortestSide * 0.05),
                  child: Center(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.silkscreen(
                        fontSize: calculateFontSize(widget.title),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildImageGallery(),
                const SizedBox(height: 34),
                QuillEditor(
                  scrollController: ScrollController(),
                  focusNode: _focusNode,
                  configurations: QuillEditorConfigurations(
                    controller: quillController,
                    autoFocus: false,
                    expands: false,
                    padding: EdgeInsets.zero,
                    scrollable: true,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    if (_imagesNetwork.isEmpty || _imagesNetwork[0] == "404") {
      return Container(height: 0);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.shortestSide / 2.5,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _imagesNetwork.length,
          itemBuilder: (context, index) {
            final url = _imagesNetwork[index];
            return GestureDetector(
              onTap: () => _showImageDialog(url),
              child: Card(
                margin: const EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(url),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: MediaQuery.of(context).size.shortestSide * 0.8,
              height: MediaQuery.of(context).size.longestSide * 0.6,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
