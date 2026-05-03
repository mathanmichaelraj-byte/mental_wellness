import '../../models/gratitude_entry.dart';
import 'database_service.dart';

/// Business-logic wrapper around gratitude-entry persistence.
class GratitudeService {
  static final GratitudeService instance = GratitudeService._init();
  GratitudeService._init();

  Future<int> addEntry(String content, String category) async {
    final entry = GratitudeEntry(
      content: content,
      category: category,
      createdAt: DateTime.now(),
    );
    return DatabaseService.instance.insertGratitudeEntry(entry);
  }

  Future<List<GratitudeEntry>> getEntries({int days = 30}) =>
      DatabaseService.instance.getGratitudeEntries(days: days);

  Future<List<GratitudeEntry>> getEntriesByCategory(String category) =>
      DatabaseService.instance.getGratitudeEntriesByCategory(category);

  Future<int> deleteEntry(int id) =>
      DatabaseService.instance.deleteGratitudeEntry(id);

  Future<Map<String, int>> getCategoryStats() async {
    final entries = await getEntries();
    final stats = <String, int>{};
    for (final e in entries) {
      final cat = e.category ?? 'other';
      stats[cat] = (stats[cat] ?? 0) + 1;
    }
    return stats;
  }
}
