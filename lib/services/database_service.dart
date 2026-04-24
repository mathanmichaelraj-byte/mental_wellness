import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/emotional_note.dart';
import '../models/behavior_pattern.dart';
import '../models/gratitude_entry.dart';
import '../models/journal_entry.dart';
import '../core/constants/app_constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
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
        // Safety check: if behavior_patterns is missing, recreate all tables.
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='behavior_patterns'",
        );
        if (tables.isEmpty) {
          await db.execute('DROP TABLE IF EXISTS emotional_notes');
          await _createDB(db, AppConstants.dbVersion);
        }
      },
    );
  }

  // ── Schema creation ────────────────────────────────────────────────────────

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS emotional_notes (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        content   TEXT    NOT NULL,
        createdAt TEXT    NOT NULL,
        expiresAt TEXT    NOT NULL,
        sentiment TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS behavior_patterns (
        id                 INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp          TEXT    NOT NULL,
        appOpenCount       INTEGER NOT NULL,
        screenTimeSeconds  INTEGER NOT NULL,
        timeOfDay          TEXT    NOT NULL,
        interactionSpeed   INTEGER NOT NULL,
        dayOfWeek          TEXT    NOT NULL,
        sessionCount       INTEGER NOT NULL,
        featureUsed        TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS gratitude_entries (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        content   TEXT NOT NULL,
        category  TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS journal_entries (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        title     TEXT NOT NULL,
        content   TEXT NOT NULL,
        mood      TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE emotional_notes ADD COLUMN sentiment TEXT');
      await db.execute(
          'ALTER TABLE behavior_patterns ADD COLUMN dayOfWeek TEXT DEFAULT "monday"');
      await db.execute(
          'ALTER TABLE behavior_patterns ADD COLUMN sessionCount INTEGER DEFAULT 1');
      await db.execute(
          'ALTER TABLE behavior_patterns ADD COLUMN featureUsed TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS gratitude_entries (
          id        INTEGER PRIMARY KEY AUTOINCREMENT,
          content   TEXT NOT NULL,
          category  TEXT,
          createdAt TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 4) {
      // New permanent daily journal table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS journal_entries (
          id        INTEGER PRIMARY KEY AUTOINCREMENT,
          title     TEXT NOT NULL,
          content   TEXT NOT NULL,
          mood      TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
    }
  }

  // ── Emotional Notes ────────────────────────────────────────────────────────

  Future<int> insertEmotionalNote(EmotionalNote note) async {
    final db = await database;
    return db.insert('emotional_notes', note.toMap());
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
    return result.map(EmotionalNote.fromMap).toList();
  }

  Future<List<EmotionalNote>> getRecentEmotionalNotes({int days = 7}) async {
    final db = await database;
    final cutoff =
        DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final result = await db.query(
      'emotional_notes',
      where: 'createdAt > ?',
      whereArgs: [cutoff],
      orderBy: 'createdAt DESC',
    );
    return result.map(EmotionalNote.fromMap).toList();
  }

  /// All notes whose [createdAt] falls within today (00:00–23:59 local).
  Future<List<EmotionalNote>> getTodayEmotionalNotes() async {
    final db = await database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toIso8601String();
    final end =
        DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    final result = await db.query(
      'emotional_notes',
      where: 'createdAt >= ? AND createdAt <= ?',
      whereArgs: [start, end],
      orderBy: 'createdAt DESC',
    );
    return result.map(EmotionalNote.fromMap).toList();
  }

  Future<List<EmotionalNote>> getEmotionalNotes() async {
    final db = await database;
    final result =
        await db.query('emotional_notes', orderBy: 'createdAt DESC');
    return result.map(EmotionalNote.fromMap).toList();
  }

  Future<int> deleteEmotionalNote(int id) async {
    final db = await database;
    return db.delete('emotional_notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteExpiredNotes() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.delete('emotional_notes',
        where: 'expiresAt <= ?', whereArgs: [now]);
  }

  // ── Behavior Patterns ──────────────────────────────────────────────────────

  Future<int> insertBehaviorPattern(BehaviorPattern pattern) async {
    final db = await database;
    return db.insert('behavior_patterns', pattern.toMap());
  }

  Future<List<BehaviorPattern>> getRecentBehaviorPatterns(
      {int days = 7}) async {
    final db = await database;
    final cutoff =
        DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final result = await db.query(
      'behavior_patterns',
      where: 'timestamp > ?',
      whereArgs: [cutoff],
      orderBy: 'timestamp DESC',
    );
    return result.map(BehaviorPattern.fromMap).toList();
  }

  Future<List<BehaviorPattern>> getBehaviorPatterns({int limit = 30}) async {
    final db = await database;
    final result = await db.query(
      'behavior_patterns',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map(BehaviorPattern.fromMap).toList();
  }

  /// All behavior patterns whose [timestamp] falls within today (00:00–now).
  Future<List<BehaviorPattern>> getTodayBehaviorPatterns() async {
    final db = await database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toIso8601String();
    final result = await db.query(
      'behavior_patterns',
      where: 'timestamp >= ?',
      whereArgs: [start],
      orderBy: 'timestamp DESC',
    );
    return result.map(BehaviorPattern.fromMap).toList();
  }

  // ── Gratitude Entries ──────────────────────────────────────────────────────

  Future<int> insertGratitudeEntry(GratitudeEntry entry) async {
    final db = await database;
    return db.insert('gratitude_entries', entry.toMap());
  }

  Future<List<GratitudeEntry>> getGratitudeEntries({int days = 30}) async {
    final db = await database;
    final cutoff =
        DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final result = await db.query(
      'gratitude_entries',
      where: 'createdAt > ?',
      whereArgs: [cutoff],
      orderBy: 'createdAt DESC',
    );
    return result.map(GratitudeEntry.fromMap).toList();
  }

  Future<List<GratitudeEntry>> getGratitudeEntriesByCategory(
      String category) async {
    final db = await database;
    final result = await db.query(
      'gratitude_entries',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'createdAt DESC',
    );
    return result.map(GratitudeEntry.fromMap).toList();
  }

  Future<int> deleteGratitudeEntry(int id) async {
    final db = await database;
    return db.delete('gratitude_entries', where: 'id = ?', whereArgs: [id]);
  }

  // ── Journal Entries (permanent) ────────────────────────────────────────────

  Future<int> insertJournalEntry(JournalEntry entry) async {
    final db = await database;
    return db.insert('journal_entries', entry.toMap());
  }

  Future<int> updateJournalEntry(JournalEntry entry) async {
    final db = await database;
    return db.update(
      'journal_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteJournalEntry(int id) async {
    final db = await database;
    return db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  /// Returns all journal entries, newest first.
  Future<List<JournalEntry>> getAllJournalEntries() async {
    final db = await database;
    final result =
        await db.query('journal_entries', orderBy: 'createdAt DESC');
    return result.map(JournalEntry.fromMap).toList();
  }

  /// Returns journal entries whose [createdAt] is within the given date range.
  Future<List<JournalEntry>> getJournalEntriesBetween(
      DateTime from, DateTime to) async {
    final db = await database;
    final result = await db.query(
      'journal_entries',
      where: 'createdAt >= ? AND createdAt <= ?',
      whereArgs: [from.toIso8601String(), to.toIso8601String()],
      orderBy: 'createdAt DESC',
    );
    return result.map(JournalEntry.fromMap).toList();
  }

  /// Returns journal entries for today (00:00–23:59 local).
  Future<List<JournalEntry>> getTodayJournalEntries() async {
    final now = DateTime.now();
    return getJournalEntriesBetween(
      DateTime(now.year, now.month, now.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
