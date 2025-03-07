import 'dart:convert';
import 'dart:io';
import 'package:booness/services/realtime_database.dart';
import 'package:booness/services/streak_services.dart';
import 'package:confetti/confetti.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../../main.dart';
import '../../models/diaryentry.dart';
import '../../models/userData.dart';
import '../../services/exncryption_and_decryption.dart';

class WriteDiary extends StatefulWidget {
  final DiaryEntry? entry;
  const WriteDiary({super.key, this.entry});

  @override
  State<WriteDiary> createState() => _WriteDiaryState();
}

class _WriteDiaryState extends State<WriteDiary> {
  TextEditingController titleController = TextEditingController();
  late ConfettiController confettiController;
  QuillController quillController = QuillController.basic();
  final picker = ImagePicker();
  late EncryptionService encryptionService;
  var userSelectedDate = DateTime.now();

  final List<File> _images = []; // List to store picked images
  bool isLoading = false;
  int maxLines = 2;
  double _titleFontSize = 21;

  Future<void> pickImages() async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only add up to 5 images.')),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      for (var file in result.files) {
        // Ensure the total number of images does not exceed 5
        if (_images.length >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only add up to 5 images.')),
          );
          break;
        }

        // Check if the file is a GIF
        if (file.extension!.toLowerCase() == 'gif') {
          _images.add(File(file.path!));
        } else {
          // Read and process the image file
          final bytes = await File(file.path!).readAsBytes();
          final String extension = file.extension!.toLowerCase();
          img.Image? image = img.decodeImage(bytes);

          if (image != null) {
            img.Image compressedImage = img.copyResize(image, width: 500);
            List<int> compressedBytes;
            if (extension == 'png') {
              compressedBytes = img.encodePng(compressedImage);
            } else {
              compressedBytes = img.encodeJpg(compressedImage, quality: 50);
            }

            String newPath = file.path!.replaceFirst(
              RegExp(r'\.\w+$'),
              extension == 'png' ? '_compressed.png' : '_compressed.jpg',
            );
            File compressedFile = File(newPath)
              ..writeAsBytesSync(compressedBytes);
            _images.add(compressedFile);
          }
        }
      }
      setState(() {});
    } else {
      print('No images selected.');
    }
  }

  @override
  void initState() {
    super.initState();
    titleController.addListener(_updateMaxLines);
    titleController.addListener(_adjustFontSize);
    encryptionService = EncryptionService.instance; // Initialize if needed
  }

  void _updateMaxLines() {
    setState(() {
      int charCount = titleController.text.length;
      maxLines = (charCount / 15).ceil().clamp(1, 4);
    });
  }

  void _adjustFontSize() {
    int charCount = titleController.text.length;
    // Assuming you want the font size to reach 16px at 100 characters
    // Calculate the decrease per character
    double decreasePerChar = (30 - 16) / 75; // Adjust this formula as needed

    setState(() {
      // Calculate new font size based on character count
      _titleFontSize = 30 - (charCount * decreasePerChar);
      // Ensure font size does not go below 16
      if (_titleFontSize < 16) _titleFontSize = 16;
      // Ensure font size does not exceed 30
      if (_titleFontSize > 30) _titleFontSize = 30;
    });
  }

  void saveDiary() async {
    if (isLoading || !mounted) {
      return; // Prevent multiple calls if already loading or if the widget is disposed
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (!mounted) return;
      if (quillController.document.isEmpty()) {
        throw Exception('Diary entry cannot be empty');
      }
      String id = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference storageRef = storage.ref('/$uid/$id');

      List<String> imageUrls = [];

      for (var image in _images) {
        firebase_storage.UploadTask task =
            storageRef.child(image.path).putFile(image);
        await task; // Await the upload task
        String downloadUrl = await task.snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      final delta = quillController.document.toDelta();
      final jsonString = jsonEncode(delta.toJson());

      // Encrypt the title and entry before saving
      String encryptedTitle =
          EncryptionService.encryptText(titleController.text);
      String encryptedEntry = EncryptionService.encryptText(jsonString);
      // Save diary entry to Firebase
      await ref.child(id).set({
        'id': id,
        'title': encryptedTitle,
        'entry': encryptedEntry,
        'date': userSelectedDate.toString(),
        'images': imageUrls,
        'image_position': [10, 34]
      });

      if (!mounted) return;
      titleController.clear();
      quillController.clear();
      userSelectedDate = DateTime.now();

      // Update streaks
      await updateStreak();

      // Only update lastUpdated after updating streak
      await streakRef.update({
        'lastUpdated': DateTime.now().toString(),
      });

      if (!mounted) return;
      confettiController.play();
      Navigator.of(context).pop(true);
    } catch (e) {
      print('Error saving diary entry: $e');
      // Optionally, show a message to the user
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => HomeScreen(title: '')));
        });
      }
    }
  }

  int calculateDateDifference(DateTime todayDate, DateTime lastDate) {
    Duration difference =
        todayDate.difference(DateTime.parse(lastDate.toString()));
    return difference.inDays;
  }

  Future<void> updateStreak() async {
    DatabaseEvent snapshot = await streakRef.once();
    if (snapshot.snapshot.value != null) {
      Map<dynamic, dynamic> streakData =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      int streak = streakData['streak'];
      int lives = streakData['lives'];
      DateTime lastRecordedDate = DateTime.parse(streakData['lastUpdated']);

      int dateDifference =
          calculateDateDifference(DateTime.now(), lastRecordedDate);

      if (dateDifference == 0) {
        await streakRef.update({
          'lastUpdated': DateTime.now().toString(),
        });
      } else if (dateDifference == 1) {
        await streakRef.update({
          'lastUpdated': DateTime.now().toString(),
          'streak': streak + 1,
        });
      } else if (dateDifference > 1) {
        if (lives == 0) {
          await streakRef.update({
            'lastUpdated': DateTime.now().toString(),
            'streak': 1,
          });
        } else if (lives > 0) {
          await streakRef.update({
            'lastUpdated': DateTime.now().toString(),
            'streak': streak + 1,
          });
        }
        await streakRef.update({
          'streak': streak + 1,
          'lastUpdated': DateTime.now().toString(),
        });
      }
    }
  }

  @override
  void dispose() {
    titleController.removeListener(_updateMaxLines);
    titleController.removeListener(_adjustFontSize);
    if (quillController.document.isEmpty() &&
        titleController.text.isEmpty &&
        _images.isEmpty) {
      titleController.dispose();
      quillController.dispose();
    }
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (quillController.document.isEmpty() &&
        titleController.text.isEmpty &&
        _images.isEmpty) {
      titleController.dispose();
      quillController.dispose();
      return true;
    }
    final shouldLeave = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Don\'t forget to save your day!'),
        content: const Text('Are you sure you want to go back without saving?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Exit'),
          ),
          if (isLoading)
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
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    onPressed: _images.length >= 5
                        ? null
                        : () async {
                            await pickImages();
                          },
                    icon: Icon(PhosphorIcons.image,
                        color: _images.length >= 5 ? Colors.grey : null),
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
                    child: Text(
                      DateFormat('dd-MM-yy').format(userSelectedDate),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(PhosphorIcons.x),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pushReplacement(
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
          title: Opacity(
            opacity: 0.89,
            child: Text(
              "Write",
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
                    child: TextFormField(
                      focusNode: FocusNode(),
                      maxLines: maxLines,
                      maxLength: 60,
                      style: GoogleFonts.silkscreen(
                        fontSize: _titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: titleController,
                      decoration: InputDecoration(
                        counter: Opacity(
                          opacity: 0.34,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "${titleController.text.length.toString()}/60",
                              style: GoogleFonts.silkscreen(),
                            ),
                          ),
                        ),
                        counterStyle: GoogleFonts.silkscreen(),
                        hintText: "Title",
                        hintStyle: GoogleFonts.silkscreen(
                          fontSize: titleController.text.isEmpty
                              ? 34
                              : _titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
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
                                          PhosphorIcons.x,
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
                        height: MediaQuery.of(context).size.longestSide * 0.02,
                      ),
                QuillEditor(
                  configurations: QuillEditorConfigurations(
                    enableScribble: true,
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
    );
  }
}

Future<void> checkAndRenewLives() async {
  DatabaseEvent snapshot = await streakRef.once();
  if (snapshot.snapshot.value != null) {
    Map<dynamic, dynamic> streakData =
        snapshot.snapshot.value as Map<dynamic, dynamic>;
    int lives = streakData['lives'];
    DateTime lastUpdatedDate = DateTime.parse(streakData['lastUpdated']);

    DateTime now = DateTime.now();
    int calculateDateDifference(DateTime todayDate, DateTime lastDate) {
      Duration difference =
          todayDate.difference(DateTime.parse(lastDate.toString()));
      return difference.inDays;
    }

    int dateDifference =
        calculateDateDifference(DateTime.now(), lastUpdatedDate);

    if (dateDifference > 1) {
      if (lives == 0) {
        await streakRef.update({
          'lastUpdated': DateTime.now().toString(),
          'streak': 1,
        });
      } else if (lives > 0) {
        int finalLife =
            (lives - dateDifference) >= 0 ? (lives - dateDifference) : 0;
        await streakRef.update({
          'lives': finalLife,
          'lastUpdated': DateTime.now().toString(),
        });
      }
    }
    if (now.month != lastUpdatedDate.month) {
      await streakRef.update({
        'lives': 5, // Reset lives to 5 at the beginning of the month
        'lastUpdated': DateTime.now().toString(),
      });
    }

    if (lives == null && streakData['streak'] == null) {
      await streakRef.set({
        "streak": 0,
        "lives": 5,
        "lastUpdated": DateTime.now().toString(),
      });
    }
  }
}
