import 'package:booness/models/diaryentry.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime now = DateTime.now();
DateTime date = DateTime(now.year, now.month, now.day);
List<DiaryEntry> diaryEntries = []; // List of diary entries
var userSelectedDate; // User selected date in the Bottom sheet
final database =
    FirebaseDatabase.instance.ref('Post'); // Create a database reference

TextEditingController titleController = TextEditingController();
TextEditingController entryController = TextEditingController();
Future OpenDairy(context) {
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FractionallySizedBox(
              heightFactor: 0.99,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth / 10,
                        vertical: constraints.maxHeight / 10,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title

                          TextFormField(
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            controller: titleController,
                            decoration: InputDecoration(
                              hintText: 'Title',
                              border: InputBorder.none,
                            ),
                          ),

                          Divider(),
                          // SizedBox(height: 20),

                          // Text formatting tools
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed:
                                        () {}, // Implement bold functionality
                                    icon: Icon(Icons.format_bold_rounded),
                                  ),
                                  IconButton(
                                    onPressed:
                                        () {}, // Implement bold functionality
                                    icon: Icon(Icons.format_italic_rounded),
                                  ),
                                ],
                              ),
                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.image_outlined))
                            ],
                          ),
                          SizedBox(height: 20),

                          // Paragraph writing
                          TextField(
                            controller: entryController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null, // Allow unlimited lines
                            decoration: const InputDecoration(
                              hintText: 'Write your entry here...',
                              border: InputBorder.none,
                            ),
                          ),
                          SizedBox(height: 20),

                          // Divider with date picker and upload button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                                        : DateFormat('dd-MM-yyyy')
                                            .format(date)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check),
                                color: Colors.green,
                                onPressed: () {
                                  database
                                      .child(DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString())
                                      .set({
                                    'title': titleController.text,
                                    'entry': entryController.text,
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
                                  entryController.clear();

                                  // Implement upload functionality
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      });
}
