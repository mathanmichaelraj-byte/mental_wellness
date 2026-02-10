import 'database_service.dart';
import '../models/behavior_pattern.dart';

class BehaviorTracker {
  static final BehaviorTracker instance = BehaviorTracker._init();
  BehaviorTracker._init();

  DateTime? _sessionStart;
  int _appOpenCount = 0;
  int _interactionCount = 0;
  String? _currentFeature;

  void startSession() {
    _sessionStart = DateTime.now();
    _appOpenCount++;
  }

  void trackInteraction() {
    _interactionCount++;
  }

  void trackFeatureUsage(String feature) {
    _currentFeature = feature;
    trackInteraction();
  }

  Future<void> endSession() async {
    if (_sessionStart == null) return;

    final now = DateTime.now();
    final sessionDuration = now.difference(_sessionStart!).inSeconds;
    final interactionSpeed = sessionDuration > 0 ? _interactionCount ~/ (sessionDuration / 60) : 0;

    final pattern = BehaviorPattern(
      timestamp: now,
      appOpenCount: _appOpenCount,
      screenTimeSeconds: sessionDuration,
      timeOfDay: _getTimeOfDay(now),
      interactionSpeed: interactionSpeed,
      dayOfWeek: _getDayOfWeek(now),
      sessionCount: 1,
      featureUsed: _currentFeature,
    );

    await DatabaseService.instance.insertBehaviorPattern(pattern);

    _sessionStart = null;
    _interactionCount = 0;
    _currentFeature = null;
  }

  String _getTimeOfDay(DateTime time) {
    final hour = time.hour;
    if (hour >= 22 || hour < 6) return 'late_night';
    if (hour >= 6 && hour < 9) return 'morning';
    if (hour >= 12 && hour < 14) return 'midday';
    if (hour >= 18 && hour < 22) return 'evening';
    return 'daytime';
  }

  String _getDayOfWeek(DateTime time) {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[time.weekday - 1];
  }

  bool isWeekend(DateTime time) {
    return time.weekday == 6 || time.weekday == 7;
  }
}
