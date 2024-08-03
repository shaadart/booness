// ReadDiary.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import '../../main.dart';
import '../../models/userData.dart';
import 'editDiary.dart';

class ReadDiary extends StatefulWidget {
  final String title;
  final String entry;
  final String date;
  final String id;
  final List<String> images;

  const ReadDiary({
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
  final FocusNode _focusNode = FocusNode();
  late List<String> _imagesNetwork;
  bool isLoading = false;

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

  @override
  Widget build(BuildContext context) {
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
                  child: const ListTile(
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
                  child: const ListTile(
                    leading: Icon(PhosphorIcons.trash),
                    title: Text('Delete'),
                  ),
                  onTap: () {
                    _deleteEntry(context, widget.id, widget.images);
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
              icon: const Icon(PhosphorIcons.dots_three),
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
        body: buildReadingWidget(context, _focusNode, quillController,
            widget.title, widget.id, _imagesNetwork),
      ),
    );
  }
}
Widget buildReadingWidget(
  BuildContext context,
  FocusNode focusNode,
  QuillController quillController,
  String title,
  String id,
  List<String> imagesNetwork,
) {
  double calculateFontSize(String title) {
    const int minTitleLength = 1;
    const int maxTitleLength = 50;
    const double minFontSize = 16.0;
    const double maxFontSize = 34.0;
    double fontSize = maxFontSize;

    if (title.length > maxTitleLength) {
      fontSize = minFontSize;
    } else if (title.length < minTitleLength) {
      fontSize = maxFontSize;
    } else {
      double ratio =
          (title.length - minTitleLength) / (maxTitleLength - minTitleLength);
      fontSize = maxFontSize - ratio * (maxFontSize - minFontSize);
    }
    return fontSize.clamp(minFontSize, maxFontSize);
  }

  void showImageDialog(String imageUrl) {
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

  Widget buildImageGallery() {
    if (imagesNetwork.isEmpty || imagesNetwork[0] == "404") {
      return Container(height: 0);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.shortestSide / 5,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: imagesNetwork.length,
          itemBuilder: (context, index) {
            final url = imagesNetwork[index];
            return GestureDetector(
              onTap: () => showImageDialog(url),
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

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 600;

  return Padding(
    padding: EdgeInsets.all(MediaQuery.of(context).size.shortestSide * 0.05),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.all(MediaQuery.of(context).size.shortestSide * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.silkscreen(
                      fontSize: calculateFontSize(title),
                      fontWeight: FontWeight.bold,
                    ),
                    // Remove maxLines and overflow to allow multi-line text
                  ),
                ),
                if (isDesktop(context))
                  PopupMenuButton(
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(PhosphorIcons.user_plus_fill),
                          title: Text('Invite Friends'),
                          trailing: Text('Pro'),
                        ),
                        onTap: () {
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
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(PhosphorIcons.pencil_fill),
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
                                title: title,
                                entry: jsonEncode(quillController.document
                                    .toDelta()
                                    .toJson()),
                                date: DateTime.now().toString(),
                                id: id, // Use the actual ID
                                images: imagesNetwork.isEmpty
                                    ? ["404"]
                                    : imagesNetwork,
                              ),
                            ),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(PhosphorIcons.trash_fill),
                          title: Text('Delete'),
                        ),
                        onTap: () {
                          _deleteEntry(context, id, imagesNetwork);
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
                    icon: Icon(Icons.more_vert),
                  ),
              ],
            ),
          ),
          buildImageGallery(),
          const SizedBox(height: 34),
          QuillEditor.basic(
            scrollController: ScrollController(),
            focusNode: focusNode,
            configurations: QuillEditorConfigurations(
              controller: quillController,
              autoFocus: false,
              expands: false,
              padding: EdgeInsets.zero,
              scrollable: true,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

void _deleteEntry(BuildContext context, String entryId, List<String> images) {
  DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child('entries/$entryId');
  databaseReference.remove().then((_) {
    if (images.isNotEmpty && images[0] != "404") {
      for (String image in images) {
        FirebaseStorage.instance.refFromURL(image).delete().then((_) {
          print('Image deleted successfully.');
        }).catchError((error) {
          print('Failed to delete image: $error');
        });
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry deleted successfully')),
    );
  }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete entry: $error')),
    );
  });
}
