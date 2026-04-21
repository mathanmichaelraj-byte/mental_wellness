import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/emotional_note.dart';
import '../models/behavior_pattern.dart';
import '../models/gratitude_entry.dart';
import '../core/constants/app_constants.dart';

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
      version: AppConstants.dbVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='behavior_patterns'"
        );
        if (tables.isEmpty) {
          await db.execute('''DROP TABLE IF EXISTS emotional_notes''');
          await _createDB(db, AppConstants.dbVersion);
        }
      },
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE emotional_notes ADD COLUMN sentiment TEXT');
      await db.execute('ALTER TABLE behavior_patterns ADD COLUMN dayOfWeek TEXT DEFAULT "monday"');
      await db.execute('ALTER TABLE behavior_patterns ADD COLUMN sessionCount INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE behavior_patterns ADD COLUMN featureUsed TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE gratitude_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          content TEXT NOT NULL,
          category TEXT,
          createdAt TEXT NOT NULL
        )
      ''');
    }
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

    await db.execute('''
      CREATE TABLE gratitude_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        category TEXT,
        createdAt TEXT NOT NULL
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

  Future<List<BehaviorPattern>> getBehaviorPatterns({int limit = 30}) async {
    final db = await database;
    final result = await db.query(
      'behavior_patterns',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => BehaviorPattern.fromMap(map)).toList();
  }

  Future<List<EmotionalNote>> getEmotionalNotes() async {
    final db = await database;
    final result = await db.query(
      'emotional_notes',
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => EmotionalNote.fromMap(map)).toList();
  }

  Future<int> insertGratitudeEntry(GratitudeEntry entry) async {
    final db = await database;
    return await db.insert('gratitude_entries', entry.toMap());
  }

  Future<List<GratitudeEntry>> getGratitudeEntries({int days = 30}) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final result = await db.query(
      'gratitude_entries',
      where: 'createdAt > ?',
      whereArgs: [cutoff],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => GratitudeEntry.fromMap(map)).toList();
  }

  Future<List<GratitudeEntry>> getGratitudeEntriesByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      'gratitude_entries',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => GratitudeEntry.fromMap(map)).toList();
  }

  Future<int> deleteGratitudeEntry(int id) async {
    final db = await database;
    return await db.delete('gratitude_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
