import '../models/gratitude_entry.dart';
import 'database_service.dart';

class GratitudeService {
  static final GratitudeService instance = GratitudeService._init();
  GratitudeService._init();

  Future<int> addEntry(String content, String category) async {
    final entry = GratitudeEntry(
      content: content,
      category: category,
      createdAt: DateTime.now(),
    );
    return await DatabaseService.instance.insertGratitudeEntry(entry);
  }

  Future<List<GratitudeEntry>> getEntries({int days = 30}) async {
    return await DatabaseService.instance.getGratitudeEntries(days: days);
  }

  Future<List<GratitudeEntry>> getEntriesByCategory(String category) async {
    return await DatabaseService.instance.getGratitudeEntriesByCategory(category);
  }

  Future<int> deleteEntry(int id) async {
    return await DatabaseService.instance.deleteGratitudeEntry(id);
  }

  Future<Map<String, int>> getCategoryStats() async {
    final entries = await getEntries();
    final stats = <String, int>{};
    
    for (var entry in entries) {
      final category = entry.category ?? 'other';
      stats[category] = (stats[category] ?? 0) + 1;
    }
    
    return stats;
  }
}
