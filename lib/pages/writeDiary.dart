import 'dart:io';

import 'package:booness/services/realtime_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../main.dart';
import '../models/diaryentry.dart';
import '../services/imageservices.dart';

DateTime now = DateTime.now();
DateTime date = DateTime(now.year, now.month, now.day);
List<DiaryEntry> diaryEntries = []; // List of diary entries
var userSelectedDate = DateTime.now(); // User selected date in the Bottom sheet
// Create a database reference

TextEditingController titleController = TextEditingController();
TextEditingController entryController = TextEditingController();
QuillController _controller = QuillController.basic();

class WriteDiary extends StatefulWidget {
  const WriteDiary({super.key});

  @override
  State<WriteDiary> createState() => _WriteDiaryState();
}

class _WriteDiaryState extends State<WriteDiary> {
  @override
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
                  duration: Duration(milliseconds: 300),
                  type: PageTransitionType.topToBottom,
                  child: HomeScreen(
                    title: '',
                  ),
                ),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(PhosphorIcons.check),
              color: Colors.green,
              onPressed: () {
                ref
                    .child(DateTime.now().millisecondsSinceEpoch.toString())
                    .set({
                  'title': titleController.text,
                  'entry': _controller.document.toDelta().toString(),
                  'date': userSelectedDate.toString(),
                });
                // setState(() {
                //   DiaryEntry newEntry = DiaryEntry(
                //     title: titleController.text,
                //     entry: entryController.text,
                //     date: date,
                //   );
                //   diaryEntries.add(newEntry);
                Navigator.pop(context);
                titleController.clear();
                _controller.clear();
                entryController.clear();

                // Implement upload functionality
              },
            ),
          ],
          title: Text(
            "Write !",
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
                      controller: titleController,
                      decoration: InputDecoration(
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
                            controller: _controller)),
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
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            ).then((selectedDate) {
                              if (selectedDate != null) {
                                // Handle selected date
                                setState(() {
                                  userSelectedDate = selectedDate;
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
                    controller: _controller,
                    readOnly: false,
                  ),
                  focusNode: FocusNode(),
                  scrollController:
                      ScrollController(), // Provide a valid ScrollController instance
                ),
                // Paragraph writing
                // TextField(
                //   controller: entryController,
                //   keyboardType: TextInputType.multiline,
                //   maxLines: null, // Allow unlimited lines
                //   decoration: const InputDecoration(
                //     hintText: 'what happened today!',
                //     border: InputBorder.none,
                //   ),
                // ),
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
