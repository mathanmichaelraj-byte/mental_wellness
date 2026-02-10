import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/emotional_note.dart';
import '../models/behavior_pattern.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mental_wellness.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE emotional_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        sentiment TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE behavior_patterns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        appOpenCount INTEGER NOT NULL,
        screenTimeSeconds INTEGER NOT NULL,
        timeOfDay TEXT NOT NULL,
        interactionSpeed INTEGER NOT NULL,
        dayOfWeek TEXT NOT NULL,
        sessionCount INTEGER NOT NULL,
        featureUsed TEXT
      )
    ''');
  }

  Future<int> insertEmotionalNote(EmotionalNote note) async {
    final db = await database;
    return await db.insert('emotional_notes', note.toMap());
  }

  Future<List<EmotionalNote>> getActiveEmotionalNotes() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final result = await db.query(
      'emotional_notes',
      where: 'expiresAt > ?',
      whereArgs: [now],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => EmotionalNote.fromMap(map)).toList();
  }

  Future<List<EmotionalNote>> getRecentEmotionalNotes({int days = 7}) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final result = await db.query(
      'emotional_notes',
      where: 'createdAt > ?',
      whereArgs: [cutoff],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => EmotionalNote.fromMap(map)).toList();
  }

  Future<int> deleteEmotionalNote(int id) async {
    final db = await database;
    return await db.delete('emotional_notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteExpiredNotes() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.delete('emotional_notes', where: 'expiresAt <= ?', whereArgs: [now]);
  }

  Future<int> insertBehaviorPattern(BehaviorPattern pattern) async {
    final db = await database;
    return await db.insert('behavior_patterns', pattern.toMap());
  }

  Future<List<BehaviorPattern>> getRecentBehaviorPatterns({int days = 7}) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final result = await db.query(
      'behavior_patterns',
      where: 'timestamp > ?',
      whereArgs: [cutoff],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => BehaviorPattern.fromMap(map)).toList();
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
