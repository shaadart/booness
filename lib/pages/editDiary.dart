// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';

import 'package:booness/pages/EditDiary.dart';
import 'package:booness/pages/writeDiary.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../main.dart';
import '../services/imageservices.dart';
import '../services/realtime_database.dart';

class EditDiary extends StatefulWidget {
  final String title;
  final String entry;
  final String date;
  final String id;
  final List images;
  EditDiary(
      {super.key,
      required this.title,
      required this.entry,
      required this.date,
      required this.id,
      required this.images});

  @override
  State<EditDiary> createState() => _EditDiaryState();
}

class _EditDiaryState extends State<EditDiary> {
  TextEditingController titleController = TextEditingController();

  QuillController quillController = QuillController.basic();
  String widgetId = "";
  final _focusNode = FocusNode();
  List<String> _images = [];
  @override
  void initState() {
    super.initState();

    _images = List<String>.from(widget.images);
    userSelectedDate = DateTime.parse(widget.date);
    titleController.text = widget.title;
    widgetId = widget.id;
    print('widget.id: ${widget.id}');
    print('widgetId: ${widgetId}');

    try {
      // Attempt to trim potential whitespace
      final trimmedJson = widget.entry.trim().replaceAll('\u00A0', ' ');
      final decodedData = jsonDecode(trimmedJson);
      final doc = Document.fromJson(decodedData);
      quillController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (error) {
      print('Error decoding JSON: $error');
      // Add error handling, potentially show a message or use a default entry
    }

    quillController.addListener(() {
      final delta = quillController.document.toDelta(); // Get the Delta
      final jsonString = jsonEncode(delta.toJson());
      ref.child(widgetId).update({
        'entry': jsonString,

        //  'images': _imageUrls,
      });
    });

    titleController.addListener(() {
      ref.child(widgetId).update({
        'title': titleController.text,
      });
    });
  }

  @override
  void dispose() {
    quillController.removeListener(() {}); // Add this line
    super.dispose();

    titleController.removeListener(() {}); // Add this line
    super.dispose();
  }

  final picker = ImagePicker();
  // List to store picked images

  // firebase_storage.FirebaseStorage storage =
  //     firebase_storage.FirebaseStorage.instance;

  Future pickImages() async {
    final pickedFiles = await picker.pickMultiImage(imageQuality: 50);
    if (pickedFiles != null) {
      setState(() {
        for (final file in pickedFiles) {
          _images.add(DiaryImage(file: File(file.path)) as String);
        }
      });
    } else {
      print('No images selected.');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.red,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(PhosphorIcons.x), // replace with your custom icon
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  curve: Curves.fastEaseInToSlowEaseOut,
                  duration: const Duration(milliseconds: 300),
                  type: PageTransitionType.topToBottom,
                  child: const HomeScreen(
                    title: '',
                  ),
                ),
              );

              // setState(() {
              //   userSelectedDate = DateTime.now();
              // });
              // titleController.clear();
              // quillController.clear();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(PhosphorIcons.check),
              //color: Colors.green,
              onPressed: () {
                final delta =
                    quillController.document.toDelta(); // Get the Delta
                final jsonString = jsonEncode(delta.toJson());
                ref.child(widgetId).update({
                  'id': widgetId,
                  'title': titleController.text,
                  'entry': jsonString,
                  'date': userSelectedDate.toString(),
                  //  'images': _imageUrls,
                });
                setState(() {
                  userSelectedDate = DateTime.now();
                });

                _focusNode.unfocus();
                Navigator.pop(context);

                // Implement upload functionality
              },
            ),
          ],
          title: Text(
            "Edit !",
            style: GoogleFonts.cedarvilleCursive(
              fontWeight: FontWeight.bold,
            ),
          ),
          // backgroundColor: Colors.transparent,

          toolbarHeight: 50,
          // Here we take the value from the HomeScreen object that was created by
          // the App.build method, and use it to set our appbar title.
          //   title: Text(widget.title),
        ),
        body: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title

                Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                  child: Center(
                    child: TextFormField(
                      focusNode: _focusNode,
                      maxLines: 1,
                      maxLength: 60,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      //  controller: TextEditingController(text: widget.title),
                      controller: titleController,
                      decoration: const InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none // Rem
                          ),
                    ),
                  ),
                ),

                // Divider(),
                // SizedBox(height: 20),

                // Text formatting tools
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    QuillToolbar.simple(
                        configurations: QuillSimpleToolbarConfigurations(
                            showDividers: false,
                            showFontFamily: false,
                            showFontSize: false,
                            showBoldButton: true,
                            showItalicButton: true,
                            showSmallButton: false, // Changed from false
                            showUnderLineButton: false,
                            showStrikeThrough: false,
                            showInlineCode: false,
                            showColorButton: false,
                            showBackgroundColorButton: false,
                            showClearFormat: false,
                            showAlignmentButtons: true, // Changed from false
                            showLeftAlignment: false,
                            showCenterAlignment: false,
                            showRightAlignment: false,
                            showJustifyAlignment: false,
                            showHeaderStyle: false,
                            showListNumbers: false,
                            showListBullets: false,
                            showListCheck: false,
                            showCodeBlock: false,
                            showQuote: false,
                            showIndent: false,
                            showLink: false,
                            showUndo: false,
                            showRedo: false,
                            showDirection: false, // Changed from false
                            showSearchButton: false,
                            showSubscript: false,
                            showSuperscript: false,
                            showClipboardCopy: false,
                            showClipboardCut: false,
                            showClipboardPaste: false,
                            controller: quillController)),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              await pickImages();
                            },
                            icon: const Icon(PhosphorIcons.image_bold)),
                        OutlinedButton(
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              initialDate:
                                  userSelectedDate, // Use selectedDate here
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            ).then((newDate) {
                              if (newDate != null) {
                                setState(() {
                                  userSelectedDate = newDate;
                                });
                              }
                            });
                          },
                          child: Row(
                            children: [
                              Text(userSelectedDate != null
                                  ? DateFormat('dd-MM-yyyy')
                                      .format(userSelectedDate)
                                  // Replace colon with comma and add DateTime.now()
                                  : DateFormat('dd-MM-yyyy').format(date)),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                _images.isEmpty || _images[0] == "404"
                    ? Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                      )
                    : Container(
                        margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                        height: 150,
                        child: ListView.builder(
                          scrollDirection:
                              Axis.horizontal, // For horizontal scrolling
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.only(right: 10),
                              child: Stack(
                                children: [
                                  // Your existing Image with ClipRRect
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      _images[index],
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          const Icon(Icons.image_not_supported),
                                    ),
                                  ),

                                  // The Close Button
                                  Positioned(
                                    top: 5, // Adjust top/right position
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Remove image logic (update _images list)
                                        setState(() {
                                          _images.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                            4), // Increase padding around the icon
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 18, // Adjust icon size
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Three-Dot Menu Button
                                  Positioned(
                                    bottom: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Show your options menu
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) => Container(
                                                // Your menu options here (Remove Image, Alt Image)
                                                ));
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.more_vert,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                QuillEditor(
                  configurations: QuillEditorConfigurations(
                    placeholder: "What happened today?",
                    controller: quillController,
                  ),
                  focusNode: _focusNode,
                  scrollController: ScrollController(),
                ),

                const SizedBox(height: 20),

                // Divider with date picker and upload button
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [],
                ),
              ],
            ),
          ),
        ));
  }
}

class DiaryImage {
  String? url; // For pre-existing images
  File? file; // For picked images

  DiaryImage({this.url, this.file});
}

// ... inside your _EditDiaryState ...
List<DiaryImage> _images = [];
