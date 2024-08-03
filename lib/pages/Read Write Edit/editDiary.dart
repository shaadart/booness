// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../../main.dart';
import '../../models/userData.dart';
import '../../services/exncryption_and_decryption.dart';
import '../../services/realtime_database.dart';

class EditDiary extends StatefulWidget {
  final String title;
  final String entry;
  final String date;
  final String id;
  final List images;

  const EditDiary({
    super.key,
    required this.title,
    required this.entry,
    required this.date,
    required this.id,
    required this.images,
  });

  @override
  State<EditDiary> createState() => _EditDiaryState();
}

class _EditDiaryState extends State<EditDiary> {
  TextEditingController titleController = TextEditingController();
  QuillController quillController = QuillController.basic();
  String widgetId = "";
  final _focusNode = FocusNode();
  List<String> _imagesNetwork = [];
  final List<File> _imagesFile = [];
  bool isLoading = false;

  int maxLines = 1;
  double _titleFontSize = 21;
  var userEditPageDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    _imagesNetwork = List<String>.from(widget.images);
    setState(() {
      userEditPageDate = DateTime.parse(widget.date);
    });
    titleController.text = widget.title;
    widgetId = widget.id;

    try {
      final trimmedJson = widget.entry.trim().replaceAll('\u00A0', '');
      final decodedData = jsonDecode(trimmedJson);
      final doc = Document.fromJson(decodedData);
      quillController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (error) {
      print('Error decoding JSON: $error');
    }
    quillController.addListener(() {
      final delta = quillController.document.toDelta();
      final jsonString = jsonEncode(delta.toJson());

      // Encrypt the entry before saving to Firebase
      final encryptedEntry = EncryptionService.encryptText(jsonString);

      ref.child(widgetId).update({
        'entry': encryptedEntry,
        "image_position": [0, 0]
      });
    });

    titleController.addListener(() {
      final encryptedTitle =
          EncryptionService.encryptText(titleController.text);
      ref.child(widgetId).update({
        'title': encryptedTitle,
        "image_position": [0, 0]
      });
    });
    titleController.addListener(_updateMaxLines);
    titleController.addListener(_adjustFontSize);
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

  @override
  void dispose() {
    quillController.removeListener(() {});
    titleController.removeListener(() {});
    titleController.dispose();
    quillController.dispose();
    super.dispose();
  }

  final picker = ImagePicker();
  Future pickImages() async {
    if (_imagesFile.length + _imagesNetwork.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add only 5 photos')),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'gif', 'jpeg'],
      allowMultiple: true,
    );

    if (result != null) {
      if (_imagesFile.length + _imagesNetwork.length + result.files.length >
          6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add only 5 photos')),
        );
        return;
      }

      for (var file in result.files) {
        if (file.extension == 'gif') {
          // Handle GIF file
          File gifFile = File(file.path!);
          _imagesFile.add(gifFile);
        } else {
          // Handle image file
          final bytes = await File(file.path!).readAsBytes();
          img.Image? image = img.decodeImage(bytes);

          if (image != null) {
            img.Image compressedImage = img.copyResize(image, width: 500);
            List<int> compressedBytes;

            if (image.hasAlpha) {
              compressedBytes = img.encodePng(compressedImage);
            } else {
              compressedBytes = img.encodeJpg(compressedImage, quality: 45);
            }

            File compressedFile = File(file.path!)
              ..writeAsBytesSync(compressedBytes);
            _imagesFile.add(compressedFile);
          }
        }
      }

      setState(() {});
    } else {
      print('No images selected.');
    }
  }

  Future<void> deleteImage(String url) async {
    firebase_storage.Reference storageRef =
        firebase_storage.FirebaseStorage.instance.refFromURL(url);
    await storageRef.delete();

    _imagesNetwork.remove(url);
    ref.child(widgetId).update({'images': _imagesNetwork});

    setState(() {
      _imagesNetwork.remove(url);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _imagesNetwork.removeAt(oldIndex);
      _imagesNetwork.insert(newIndex, item);
      // Update Firebase Database with new image order
      ref.child(widgetId).update({'images': _imagesNetwork});
    });
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
                    onPressed: _imagesFile.length + _imagesNetwork.length >= 6
                        ? null
                        : () async {
                            await pickImages();
                          },
                    icon: const Icon(PhosphorIcons.image_bold),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: userEditPageDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      ).then((newDate) {
                        if (newDate != null) {
                          setState(() {
                            userEditPageDate = newDate;
                          });
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          userEditPageDate != null
                              ? DateFormat('dd-MM-yy').format(userEditPageDate)
                              : DateFormat('dd-MM-yy').format(DateTime.now()),
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
         IconButton(
  icon: isLoading
      ? const CircularProgressIndicator()
      : const Icon(PhosphorIcons.check),
  onPressed: () async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      firebase_storage.Reference storageRef =
          firebase_storage.FirebaseStorage.instance.ref('/$uid/${widget.id}');
      List<String> imageUrls = [];

      // Upload new images and get their URLs
      for (var image in _imagesFile) {
        firebase_storage.UploadTask task =
            storageRef.child(image.path).putFile(image);
        final snapshot = await task.whenComplete(() {});
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      imageUrls.addAll(_imagesNetwork);

      // Update Firebase Realtime Database
      await ref.child(widgetId).update({
        'id': widgetId,
        'date': userEditPageDate.toString(),
        'images': imageUrls,
      });

      setState(() {
        _imagesNetwork = imageUrls; // Update the _imagesNetwork list with new URLs
        _imagesFile.clear(); // Clear the _imagesFile list after upload
        isLoading = false;
        Navigator.pushReplacement(
          context,
          PageTransition(
            curve: Curves.fastEaseInToSlowEaseOut,
            duration: const Duration(milliseconds: 300),
            type: PageTransitionType.topToBottom,
            child: const HomeScreen(title: ''),
          ),
        );
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diary updated')),
      );

    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update diary: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  },
)

          ],
          title: Opacity(
            opacity: 0.89,
            child: Text(
              "Edit",
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
                      maxLines: maxLines,
                      maxLength: 60,
                      style: GoogleFonts.silkscreen(
                        fontSize: _titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: titleController,
                      decoration: InputDecoration(
                        counterStyle: GoogleFonts.silkscreen(),
                        hintText: "What happened today?",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildImageGallery(),
                const SizedBox(height: 34),
                QuillEditor(
                  configurations: QuillEditorConfigurations(
                    placeholder: "What happened today?",
                    controller: quillController,
                  ),
                  focusNode: _focusNode,
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

  Widget _buildImageGallery() {
    if ((_imagesNetwork.isEmpty || _imagesNetwork[0] == "404") &&
        _imagesFile.isEmpty) {
      return Container(
          height:
              0); // Return a Container with zero height when no images are present
    }

    return Padding(
      // Add padding when images are present
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: 150, // Give a fixed height to ensure it has constraints
        child: ReorderableListView(
          scrollDirection: Axis.horizontal,
          onReorder: _onReorder,
          children: [
            ..._imagesFile
                .map((file) => _buildReorderableImageCard(file: file)),
            ..._imagesNetwork
                .map((url) => _buildReorderableImageCard(url: url)),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableImageCard({File? file, String? url}) {
    return Card(
      color: Theme.of(context).cardColor,
      key: ValueKey(file?.path ?? url),
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: file != null
                ? Image.file(
                    file,
                  )
                : url != null && url != "404"
                    ? Image.network(
                        url,
                      )
                    : Container(),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () async {
                if (file != null) {
                  setState(() {
                    _imagesFile.remove(file);
                  });
                } else if (url != null) {
                  await deleteImage(url);
                  setState(() {
                    _imagesNetwork.remove(url);
                  });
                }
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
  }
}
