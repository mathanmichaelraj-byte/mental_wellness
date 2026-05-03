import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../local/database_service.dart';
import '../../models/emotional_note.dart';

/// Opt-in cloud sync — uploads **only anonymised mood sentiment** to
/// Firestore.  No personal text, no journal content is ever sent.
///
/// Firestore path: `users/{uid}/mood_sync/{YYYY-MM-DD}`
/// Document shape: `{ date, sentiment, syncedAt }`
class CloudSyncService {
  static final CloudSyncService instance = CloudSyncService._init();
  CloudSyncService._init();

  static const String _prefKey = 'cloud_sync_enabled';

  final FirebaseFirestore _db   = FirebaseFirestore.instance;
  final FirebaseAuth      _auth = FirebaseAuth.instance;

  Future<bool> isSyncEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_prefKey) ?? false;

  Future<void> setSyncEnabled(bool enabled) async {
    await (await SharedPreferences.getInstance()).setBool(_prefKey, enabled);
    if (enabled) await syncNow();
  }

  /// Full 30-day historical sync — call after sign-in or on toggle-on.
  Future<void> syncNow() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || !await isSyncEnabled()) return;

    final notes =
        await DatabaseService.instance.getRecentEmotionalNotes(days: 30);

    final Map<String, EmotionalNote> byDay = {};
    for (final n in notes) {
      final day = _dayKey(n.createdAt);
      byDay.putIfAbsent(day, () => n);
    }

    final batch = _db.batch();
    final col   = _db.collection('users').doc(uid).collection('mood_sync');

    for (final e in byDay.entries) {
      batch.set(
        col.doc(e.key),
        {'date': e.key, 'sentiment': e.value.sentiment ?? 'neutral', 'syncedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  /// Single-note sync — call immediately after saving an emotional note.
  Future<void> syncNote(EmotionalNote note) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || !await isSyncEnabled()) return;
    final day = _dayKey(note.createdAt);
    await _db.collection('users').doc(uid).collection('mood_sync').doc(day).set(
      {'date': day, 'sentiment': note.sentiment ?? 'neutral', 'syncedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  Future<List<Map<String, dynamic>>> fetchSyncedRecords() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || !await isSyncEnabled()) return [];
    final snap = await _db
        .collection('users').doc(uid).collection('mood_sync')
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  Future<void> clearCloudData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final snap =
        await _db.collection('users').doc(uid).collection('mood_sync').get();
    final batch = _db.batch();
    for (final doc in snap.docs) batch.delete(doc.reference);
    await batch.commit();
  }

  String _dayKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
