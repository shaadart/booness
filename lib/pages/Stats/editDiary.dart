import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:booness/pages/Stats/writeDiary.dart';
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
import '../../services/imageservices.dart';
import '../../services/realtime_database.dart';

class EditDiary extends StatefulWidget {
  final String title;
  final String entry;
  final String date;
  final String id;
  final List images;

  EditDiary({
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
  List<File> _imagesFile = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _imagesNetwork = List<String>.from(widget.images);
    userSelectedDate = DateTime.parse(widget.date);
    titleController.text = widget.title;
    widgetId = widget.id;

    try {
      final trimmedJson = widget.entry.trim().replaceAll('\u00A0', ' ');
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
      ref.child(widgetId).update({
        'entry': jsonString,
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
    quillController.removeListener(() {});
    titleController.removeListener(() {});
    super.dispose();
  }

  final picker = ImagePicker();

  Future pickImages() async {
    if (_imagesFile.length + _imagesNetwork.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add only 5 photos')),
      );
      return;
    }

    final pickedFiles = await picker.pickMultiImage(imageQuality: 50);
    if (pickedFiles != null) {
      if (_imagesFile.length + _imagesNetwork.length + pickedFiles.length > 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Add only 5 photos')),
        );
        return;
      }

      for (var file in pickedFiles) {
        // Compress and add the image file as before
        final bytes = await file.readAsBytes();
        img.Image? image = img.decodeImage(bytes);

        if (image != null) {
          img.Image compressedImage = img.copyResize(image, width: 400);
          List<int> compressedBytes =
              img.encodeJpg(compressedImage, quality: 45);
          File compressedFile = File(file.path)
            ..writeAsBytesSync(compressedBytes);

          _imagesFile.add(compressedFile);
        }
      }

      setState(() {});
    } else {
      print('No images selected.');
    }
  }

  Future<void> deleteImage(String url) async {
    // Delete image from Firebase Storage
    firebase_storage.Reference storageRef =
        firebase_storage.FirebaseStorage.instance.refFromURL(url);
    await storageRef.delete();

    // Update the list of image URLs in Firebase Realtime Database
    _imagesNetwork.remove(url);
    ref.child(widgetId).update({'images': _imagesNetwork});

    // Update the imageUrls list
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
   padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
       
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: BottomAppBar(child:  Row(
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
                          onPressed: 
                              _imagesFile.length + _imagesNetwork.length >= 6
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
                              initialDate: userSelectedDate,
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
                              Text(
                                userSelectedDate != null
                                    ? DateFormat('dd-MM-yyyy')
                                        .format(userSelectedDate)
                                    : DateFormat('dd-MM-yyyy')
                                        .format(DateTime.now()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(PhosphorIcons.x),
            onPressed: () {
              Navigator.push(
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
                  ? CircularProgressIndicator()
                  : Icon(PhosphorIcons.check),
              onPressed: () async {
                if (isLoading == false) {
                  setState(() {
                    isLoading = true;
                  });
                } else {
                  return;
                }
                if (isLoading) {
                  firebase_storage.Reference storageRef =
                      storage.ref('/$uid/${widget.id}');
                  List<String> imageUrls = [];
      
                  // Upload new images and get their URLs
                  for (var image in _imagesFile) {
                    firebase_storage.UploadTask task =
                        storageRef.child(image.path).putFile(image);
                    await task.whenComplete(() {});
                    String downloadUrl = await task.snapshot.ref.getDownloadURL();
                    imageUrls.add(downloadUrl);
                  }
      
                  // Combine new and existing URLs
                  imageUrls.addAll(_imagesNetwork);
      
                  final delta = quillController.document.toDelta();
                  final jsonString = jsonEncode(delta.toJson());
                  ref.child(widgetId).update({
                    'id': widgetId,
                    'title': titleController.text,
                    'entry': jsonString,
                    'date': userSelectedDate.toString(),
                    'images': imageUrls,
                  });
      
                  setState(() {
                    _imagesNetwork =
                        imageUrls; // Update the _imagesNetwork list with new URLs
                    _imagesFile
                        .clear(); // Clear the _imagesFile list after upload
                    isLoading = false;
                  });
      
                  _focusNode.unfocus();
                  Navigator.pop(context);
                }
              },
            ),
          ],
          title: Text(
            "Edit !",
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
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                  child: Center(
                    child: TextFormField(
                      maxLines: 1,
                      maxLength: 60,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
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
                .map((file) => _buildReorderableImageCard(file: file))
                .toList(),
            ..._imagesNetwork
                .map((url) => _buildReorderableImageCard(url: url))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableImageCard({File? file, String? url}) {
    return Card(
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
  }
}
