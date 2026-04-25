import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../models/emotional_note.dart';

/// Opt-in cloud sync — uploads **only anonymised mood sentiment data**
/// (no personal text, no journal content) to the authenticated user's
/// Firestore sub-collection.
///
/// Firestore path:
///   users/{uid}/mood_sync/{date}  →  { date, sentiment, syncedAt }
///
/// The user's preference is stored in [SharedPreferences] under
/// [_prefKey].  Sync runs automatically after sign-in and after each
/// new emotional note is saved (if enabled).
class CloudSyncService {
  static final CloudSyncService instance = CloudSyncService._init();
  CloudSyncService._init();

  static const String _prefKey = 'cloud_sync_enabled';

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Preference ─────────────────────────────────────────────────────────────

  Future<bool> isSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  Future<void> setSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
    if (enabled) await syncNow();
  }

  // ── Sync ───────────────────────────────────────────────────────────────────

  /// Syncs the last 30 days of mood sentiment to Firestore.
  /// Each day is collapsed to a single document keyed by date string
  /// (YYYY-MM-DD) using the most recent note of that day.
  ///
  /// Call this after sign-in or when the user enables sync.
  Future<void> syncNow() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    if (!await isSyncEnabled()) return;

    final notes = await DatabaseService.instance
        .getRecentEmotionalNotes(days: 30);

    // Group by date, keep the latest per day
    final Map<String, EmotionalNote> byDay = {};
    for (final note in notes) {
      final day = _dayKey(note.createdAt);
      if (!byDay.containsKey(day)) byDay[day] = note;
    }

    final batch = _db.batch();
    final col = _db.collection('users').doc(uid).collection('mood_sync');

    for (final entry in byDay.entries) {
      final ref = col.doc(entry.key);
      batch.set(ref, {
        'date': entry.key,
        'sentiment': entry.value.sentiment ?? 'neutral',
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// Syncs a single note immediately after it's saved (if sync is on).
  Future<void> syncNote(EmotionalNote note) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    if (!await isSyncEnabled()) return;

    final day = _dayKey(note.createdAt);
    await _db
        .collection('users')
        .doc(uid)
        .collection('mood_sync')
        .doc(day)
        .set({
      'date': day,
      'sentiment': note.sentiment ?? 'neutral',
      'syncedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Returns all synced mood records for this user from Firestore,
  /// sorted newest-first.  Returns `[]` if sync is disabled or user is
  /// not authenticated.
  Future<List<Map<String, dynamic>>> fetchSyncedRecords() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    if (!await isSyncEnabled()) return [];

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('mood_sync')
        .orderBy('date', descending: true)
        .get();

    return snap.docs.map((d) => d.data()).toList();
  }

  /// Deletes all synced mood data from Firestore for the current user.
  Future<void> clearCloudData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final col = _db.collection('users').doc(uid).collection('mood_sync');
    final snap = await col.get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _dayKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
