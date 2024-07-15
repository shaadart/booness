import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper.internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;

    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'my_app.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE notification_time (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL
      )
    ''');
  }

  Future<void> saveNotificationTime(int hour, int minute) async {
    final dbClient = await db;
    // Check if a record already exists
    List<Map<String, dynamic>> existing = await dbClient.query('notification_time', limit: 1);
    if (existing.isNotEmpty) {
      // Update the existing record
      await dbClient.update('notification_time', {'hour': hour, 'minute': minute},
          where: 'id = ?', whereArgs: [existing.first['id']]);
    } else {
      // Insert a new record
      await dbClient.insert('notification_time', {'hour': hour, 'minute': minute});
    }
  }

  Future<Map<String, dynamic>?> getNotificationTime() async {
    final dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient.query('notification_time', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}
