import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/emotional_note.dart';
import '../../models/behavior_pattern.dart';
import '../../models/gratitude_entry.dart';
import '../../models/journal_entry.dart';
import '../../core/constants/app_constants.dart';

/// SQLite data layer — single source of truth for all local persistence.
///
/// Tables (schema v4):
///   emotional_notes   – temporary venting notes (auto-expire)
///   behavior_patterns – passive usage signals for emotional inference
///   gratitude_entries – 30-day gratitude records
///   journal_entries   – permanent personal diary (no expiry)
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

  // ── Schema ─────────────────────────────────────────────────────────────────

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
      await db.execute('ALTER TABLE emotional_notes ADD COLUMN sentiment TEXT');
      await db.execute('ALTER TABLE behavior_patterns ADD COLUMN dayOfWeek TEXT DEFAULT "monday"');
      await db.execute('ALTER TABLE behavior_patterns ADD COLUMN sessionCount INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE behavior_patterns ADD COLUMN featureUsed TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS gratitude_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT NOT NULL,
          category TEXT, createdAt TEXT NOT NULL)
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS journal_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL,
          content TEXT NOT NULL, mood TEXT,
          createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL)
      ''');
    }
  }

  // ── Emotional Notes ────────────────────────────────────────────────────────

  Future<int> insertEmotionalNote(EmotionalNote note) async =>
      (await database).insert('emotional_notes', note.toMap());

  Future<List<EmotionalNote>> getActiveEmotionalNotes() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final r = await db.query('emotional_notes', where: 'expiresAt > ?', whereArgs: [now], orderBy: 'createdAt DESC');
    return r.map(EmotionalNote.fromMap).toList();
  }

  Future<List<EmotionalNote>> getRecentEmotionalNotes({int days = 7}) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final r = await db.query('emotional_notes', where: 'createdAt > ?', whereArgs: [cutoff], orderBy: 'createdAt DESC');
    return r.map(EmotionalNote.fromMap).toList();
  }

  Future<List<EmotionalNote>> getTodayEmotionalNotes() async {
    final db = await database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toIso8601String();
    final end   = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    final r = await db.query('emotional_notes', where: 'createdAt >= ? AND createdAt <= ?', whereArgs: [start, end], orderBy: 'createdAt DESC');
    return r.map(EmotionalNote.fromMap).toList();
  }

  Future<List<EmotionalNote>> getEmotionalNotes() async {
    final r = await (await database).query('emotional_notes', orderBy: 'createdAt DESC');
    return r.map(EmotionalNote.fromMap).toList();
  }

  Future<int> deleteEmotionalNote(int id) async =>
      (await database).delete('emotional_notes', where: 'id = ?', whereArgs: [id]);

  Future<void> deleteExpiredNotes() async {
    final now = DateTime.now().toIso8601String();
    await (await database).delete('emotional_notes', where: 'expiresAt <= ?', whereArgs: [now]);
  }

  // ── Behavior Patterns ──────────────────────────────────────────────────────

  Future<int> insertBehaviorPattern(BehaviorPattern pattern) async =>
      (await database).insert('behavior_patterns', pattern.toMap());

  Future<List<BehaviorPattern>> getRecentBehaviorPatterns({int days = 7}) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final r = await db.query('behavior_patterns', where: 'timestamp > ?', whereArgs: [cutoff], orderBy: 'timestamp DESC');
    return r.map(BehaviorPattern.fromMap).toList();
  }

  Future<List<BehaviorPattern>> getBehaviorPatterns({int limit = 30}) async {
    final r = await (await database).query('behavior_patterns', orderBy: 'timestamp DESC', limit: limit);
    return r.map(BehaviorPattern.fromMap).toList();
  }

  Future<List<BehaviorPattern>> getTodayBehaviorPatterns() async {
    final db = await database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toIso8601String();
    final r = await db.query('behavior_patterns', where: 'timestamp >= ?', whereArgs: [start], orderBy: 'timestamp DESC');
    return r.map(BehaviorPattern.fromMap).toList();
  }

  // ── Gratitude Entries ──────────────────────────────────────────────────────

  Future<int> insertGratitudeEntry(GratitudeEntry entry) async =>
      (await database).insert('gratitude_entries', entry.toMap());

  Future<List<GratitudeEntry>> getGratitudeEntries({int days = 30}) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final r = await db.query('gratitude_entries', where: 'createdAt > ?', whereArgs: [cutoff], orderBy: 'createdAt DESC');
    return r.map(GratitudeEntry.fromMap).toList();
  }

  Future<List<GratitudeEntry>> getGratitudeEntriesByCategory(String category) async {
    final r = await (await database).query('gratitude_entries', where: 'category = ?', whereArgs: [category], orderBy: 'createdAt DESC');
    return r.map(GratitudeEntry.fromMap).toList();
  }

  Future<int> deleteGratitudeEntry(int id) async =>
      (await database).delete('gratitude_entries', where: 'id = ?', whereArgs: [id]);

  // ── Journal Entries (permanent) ────────────────────────────────────────────

  Future<int> insertJournalEntry(JournalEntry entry) async =>
      (await database).insert('journal_entries', entry.toMap());

  Future<int> updateJournalEntry(JournalEntry entry) async =>
      (await database).update('journal_entries', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);

  Future<int> deleteJournalEntry(int id) async =>
      (await database).delete('journal_entries', where: 'id = ?', whereArgs: [id]);

  Future<List<JournalEntry>> getAllJournalEntries() async {
    final r = await (await database).query('journal_entries', orderBy: 'createdAt DESC');
    return r.map(JournalEntry.fromMap).toList();
  }

  Future<List<JournalEntry>> getJournalEntriesBetween(DateTime from, DateTime to) async {
    final r = await (await database).query('journal_entries',
        where: 'createdAt >= ? AND createdAt <= ?',
        whereArgs: [from.toIso8601String(), to.toIso8601String()],
        orderBy: 'createdAt DESC');
    return r.map(JournalEntry.fromMap).toList();
  }

  Future<List<JournalEntry>> getTodayJournalEntries() async {
    final now = DateTime.now();
    return getJournalEntriesBetween(
      DateTime(now.year, now.month, now.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  Future<void> close() async => (await database).close();
}
