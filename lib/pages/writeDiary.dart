import 'dart:convert';
import 'dart:io';

import 'package:booness/services/realtime_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/translations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../main.dart';
import '../models/diaryentry.dart';
import '../models/userData.dart';
import '../services/imageservices.dart';

DateTime now = DateTime.now();
DateTime date = DateTime(now.year, now.month, now.day);
List<DiaryEntry> diaryEntries = []; // List of diary entries
var userSelectedDate = DateTime.now(); // User selected date in the Bottom sheet
// Create a database reference

class WriteDiary extends StatefulWidget {
  final DiaryEntry? entry;
  const WriteDiary({super.key, this.entry});

  @override
  State<WriteDiary> createState() => _WriteDiaryState();
}

class _WriteDiaryState extends State<WriteDiary> {
  TextEditingController titleController = TextEditingController();

  QuillController quillController = QuillController.basic();
  final picker = ImagePicker();
  List<File> _images = []; // List to store picked images

  // firebase_storage.FirebaseStorage storage =
  //     firebase_storage.FirebaseStorage.instance;

  Future pickImages() async {
    final pickedFiles = await picker.pickMultiImage(imageQuality: 50);
    if (pickedFiles != null) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    } else {
      print('No images selected.');
    }
  }

  @override
  void initState() {
    super.initState();

    // if (widget.entry != null) {
    //   // Pre-populate the fields with existing entry data
    //   titleController.text = widget.entry!.title;
    //   quillController.document =
    //       Document.fromJson(jsonDecode(widget.entry!.entry));
    //   userSelectedDate = widget.entry!.date;
    // }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.red,

        bottomNavigationBar: BottomAppBar(
          child: Row(
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
                      showUndo: true,
                      showRedo: true,
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
                      icon: const Icon(PhosphorIcons.image)),
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
                        // ignore: unnecessary_null_comparison
                        Text(userSelectedDate != null
                            ? DateFormat('dd-MM-yyyy').format(userSelectedDate)
                            // Replace colon with comma and add DateTime.now()
                            : DateFormat('dd-MM-yyyy').format(date)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
                PhosphorIcons.x_bold), // replace with your custom icon
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
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(PhosphorIcons.check),
              //color: Colors.green,
              onPressed: () async {
                String id = DateTime.now().millisecondsSinceEpoch.toString();
                firebase_storage.Reference storage_ref =
                    storage.ref('/${uid}/${id}');

                // Create a list to store downloaded image URLs
                List<String> imageUrls = [];

                for (var image in _images) {
                  firebase_storage.UploadTask task = storage_ref
                      .child(image.path)
                      .putFile(image); //  Include file name
                  await Future.value(task);
                  String downloadUrl = await task.snapshot.ref.getDownloadURL();
                  imageUrls.add(downloadUrl);
                }
                final delta =
                    quillController.document.toDelta(); // Get the Delta
                final jsonString =
                    jsonEncode(delta.toJson()); // Convert Delta to JSON string
                ref.child(id).set({
                  'id': id,
                  'title': titleController.text,
                  'entry': jsonString, // Convert to JSON string
                  'date': userSelectedDate.toString(),
                  'images': imageUrls,
                });
                // setState(() {
                //   DiaryEntry newEntry = DiaryEntry(
                //     title: titleController.text,
                //     entry: entryController.text,
                //     date: date,
                //   );
                //   diaryEntries.add(newEntry);
                titleController.clear();
                quillController.clear();
                Navigator.pop(context);

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

                //   SizedBox(height: 10),

                (_images.isNotEmpty)
                    ? Container(
                        margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                        height: 150, // Adjust height as needed
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.only(right: 10),
                              child: Stack(
                                children: [
                                  // Your existing Image with ClipRRect
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.file(_images[index]),
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
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),

                QuillEditor(
                  configurations: QuillEditorConfigurations(
                    placeholder: "What happened today?",
                    controller: quillController,
                  ),
                  focusNode: FocusNode(),
                  scrollController:
                      ScrollController(), // Provide a valid ScrollController instance
                ),

                const SizedBox(height: 20),

                // Divider with date picker and upload button
              ],
            ),
          ),
        ));
  }
}
