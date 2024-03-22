import 'dart:convert';

import 'package:booness/pages/EditDiary.dart';
import 'package:booness/pages/writeDiary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
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
  const EditDiary(
      {super.key,
      required this.title,
      required this.entry,
      required this.date,
      required this.id});

  @override
  State<EditDiary> createState() => _EditDiaryState();
}

class _EditDiaryState extends State<EditDiary> {
  String widgetId = "";
  @override
  void initState() {
    super.initState();
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
  }

  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.red,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(PhosphorIcons.x_bold), // replace with your custom icon
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

              setState(() {
                userSelectedDate = DateTime.now();
              });
              titleController.clear();
              quillController.clear();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(PhosphorIcons.check),
              color: Colors.green,
              onPressed: () {
                final delta =
                    quillController.document.toDelta(); // Get the Delta
                final jsonString = jsonEncode(delta.toJson());
                ref.child(widgetId).update({
                  'id': widgetId,
                  'title': titleController.text,
                  'entry': jsonString,
                  'date': userSelectedDate.toString(),
                });
                setState(() {
                  userSelectedDate = DateTime.now();
                });
                titleController.clear();
                quillController.clear();

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
                      focusNode: FocusNode(),
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
                            controller: quillController)),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              final pickedFiles = await pickImages();

                              if (pickedFiles != null) {
                                // Get the paths of the picked images
                                final pickedImagePaths = pickedFiles
                                    .map((file) => file.path)
                                    .toList();

                                // Store the images
                                final storedImagePaths =
                                    await storeImagePaths(pickedImagePaths);

                                print('Stored image paths: $storedImagePaths');

                                // Retrieve the image paths
                                // You'll need to adjust this part to handle multiple images
                                final retrievedImagePath =
                                    await retrieveImagePath('your_date');

                                print(
                                    'Retrieved image path: $retrievedImagePath');
                              } else {
                                print('No images selected.');
                              }
                            },
                            icon: Icon(PhosphorIcons.image_bold)),
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
                SizedBox(height: 20),

                QuillEditor(
                  configurations: QuillEditorConfigurations(
                    placeholder: "What happened today?",
                    controller: quillController,
                    readOnly: false,
                  ),
                  focusNode: FocusNode(),
                  scrollController:
                      ScrollController(), // Provide a valid ScrollController instance
                ),

                SizedBox(height: 20),

                // Divider with date picker and upload button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [],
                ),
              ],
            ),
          ),
        ));
  }
}
