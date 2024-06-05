import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:booness/services/realtime_database.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../../main.dart';
import '../../models/diaryentry.dart';
import '../../models/userData.dart';

DateTime now = DateTime.now();
late ConfettiController controllerBottomCenter;
DateTime date = DateTime(now.year, now.month, now.day);
List<DiaryEntry> diaryEntries = []; // List of diary entries
var userSelectedDate = DateTime.now();

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
  bool isLoading = false;
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

  void saveDiary() async {
    if (isLoading == false) {
      setState(() {
        isLoading = true;
      });
    } else {
      return;
    }

    if (isLoading) {
      String id = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference storage_ref = storage.ref('/${uid}/${id}');

      List<String> imageUrls = [];

      for (var image in _images) {
        firebase_storage.UploadTask task =
            storage_ref.child(image.path).putFile(image);
        await Future.value(task);
        String downloadUrl = await task.snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
      final delta = quillController.document.toDelta();
      final jsonString = jsonEncode(delta.toJson());
      ref.child(id).set({
        'id': id,
        'title': titleController.text,
        'entry': jsonString,
        'date': userSelectedDate.toString(),
        'images': imageUrls,
        'image_position' :[110,164]
        
      });

      titleController.clear();
      quillController.clear();
      userSelectedDate = DateTime.now();

      controllerBottomCenter.play();
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    quillController.dispose();
    titleController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (quillController.document.isEmpty() &&
        titleController.text.isEmpty &&
        _images.isEmpty) {
      return true;
    }
    final shouldLeave = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Don\'t forget to save your day!'),
        content: const Text('Are you sure you want to go back without saving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
          if (isLoading == true)
            const CircularProgressIndicator()
          else
            TextButton(
              onPressed: () {
                saveDiary();
                Navigator.of(context).pop(false);
              },
              child: const Text('Save'),
            ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Scaffold(
          
          resizeToAvoidBottomInset: false,
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
                    showSmallButton: false,
                    showUnderLineButton: false,
                    showStrikeThrough: false,
                    showInlineCode: false,
                    showColorButton: false,
                    showBackgroundColorButton: false,
                    showClearFormat: false,
                    showAlignmentButtons: true,
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
                    showDirection: false,
                    showSearchButton: false,
                    showSubscript: false,
                    showSuperscript: false,
                    showClipboardCopy: false,
                    showClipboardCut: false,
                    showClipboardPaste: false,
                    controller: quillController,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await pickImages();
                      },
                      icon: const Icon(PhosphorIcons.image),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        ).then((selectedDate) {
                          if (selectedDate != null) {
                            setState(() {
                              userSelectedDate = selectedDate;
                            });
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            DateFormat('dd-MM-yyyy').format(userSelectedDate),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(PhosphorIcons.x_bold),
              onPressed: () async {
                if (await _onWillPop()) {
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
                }
              },
            ),
            actions: [
              IconButton(
                icon: isLoading
                    ? const CircularProgressIndicator()
                    : const Icon(PhosphorIcons.check),
                onPressed: () async {
                  saveDiary();
                },
              ),
            ],
            title: Text(
              "Write !",
              style: GoogleFonts.cedarvilleCursive(
                fontWeight: FontWeight.bold,
              ),
            ),
            toolbarHeight: 50,
          ),
          body: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.05),
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
                          enabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
               _images.isNotEmpty
  ? Container(
      margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
      height: 150,
      child: ReorderableListView(
        scrollDirection: Axis.horizontal,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final item = _images.removeAt(oldIndex);
            _images.insert(newIndex, item);
          });
        },
        children: List.generate(_images.length, (index) {
          return Card(
            key: ValueKey(_images[index]),
            margin: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.file(_images[index]),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _images.removeAt(index);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(),
                      );
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
        }),
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
                    scrollController: ScrollController(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
