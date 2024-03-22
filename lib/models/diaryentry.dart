class DiaryEntry {
  final String title;
  final String entry;
  final DateTime date;
  final String id; // Add a unique ID field

  DiaryEntry({
    required this.title,
    required this.entry,
    required this.date,
    required this.id,
  });
}