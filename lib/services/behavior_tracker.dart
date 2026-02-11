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
    _savePattern(); // Save immediately on app open
  }

  void trackInteraction() {
    _interactionCount++;
  }

  void trackFeatureUsage(String feature) {
    _currentFeature = feature;
    trackInteraction();
    _savePattern(); // Save when feature is used
  }

  Future<void> _savePattern() async {
    if (_sessionStart == null) return;

    final now = DateTime.now();
    final sessionDuration = now.difference(_sessionStart!).inSeconds;
    final interactionSpeed = sessionDuration > 0 ? (_interactionCount / (sessionDuration / 60)).round() : 0;

    final pattern = BehaviorPattern(
      timestamp: now,
      appOpenCount: _appOpenCount,
      screenTimeSeconds: sessionDuration,
      timeOfDay: _getTimeOfDay(now),
      interactionSpeed: interactionSpeed.clamp(1, 10),
      dayOfWeek: _getDayOfWeek(now),
      sessionCount: 1,
      featureUsed: _currentFeature,
    );

    await DatabaseService.instance.insertBehaviorPattern(pattern);
  }

  Future<void> endSession() async {
    await _savePattern();
    _sessionStart = null;
    _interactionCount = 0;
    _currentFeature = null;
  }

  String _getTimeOfDay(DateTime time) {
    final hour = time.hour;
    if (hour >= 22 || hour < 6) return 'lateNight';
    if (hour >= 6 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    return 'evening';
  }

  String _getDayOfWeek(DateTime time) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[time.weekday - 1];
  }

  bool isWeekend(DateTime time) {
    return time.weekday == 6 || time.weekday == 7;
  }
}
