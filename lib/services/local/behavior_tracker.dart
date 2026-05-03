import '../../core/constants/app_constants.dart';
import '../../models/behavior_pattern.dart';
import '../local/database_service.dart';

/// Tracks passive user behaviour and persists [BehaviorPattern] records
/// to SQLite at the end of each session.
class BehaviorTracker {
  static final BehaviorTracker instance = BehaviorTracker._init();
  BehaviorTracker._init();

  DateTime? _sessionStart;
  int _interactionCount = 0;
  String? _currentFeature;

  void startSession() {
    _sessionStart = DateTime.now();
    _interactionCount = 0;
  }

  void trackInteraction() => _interactionCount++;

  void trackFeatureUsage(String feature) {
    _currentFeature = feature;
    trackInteraction();
  }

  Future<void> endSession() async {
    await _savePattern();
    _sessionStart = null;
    _interactionCount = 0;
    _currentFeature = null;
  }

  Future<void> _savePattern() async {
    if (_sessionStart == null) return;
    final now = DateTime.now();
    final sessionDuration = now.difference(_sessionStart!).inSeconds;
    if (sessionDuration < AppConstants.minSessionSeconds) return;

    final interactionSpeed = sessionDuration > 0
        ? (_interactionCount / (sessionDuration / 60))
            .round()
            .clamp(1, AppConstants.maxInteractionSpeed)
        : 1;

    await DatabaseService.instance.insertBehaviorPattern(BehaviorPattern(
      timestamp: now,
      appOpenCount: 1,
      screenTimeSeconds: sessionDuration,
      timeOfDay: _getTimeOfDay(now),
      interactionSpeed: interactionSpeed,
      dayOfWeek: _getDayOfWeek(now),
      sessionCount: 1,
      featureUsed: _currentFeature,
    ));
  }

  String _getTimeOfDay(DateTime t) {
    final h = t.hour;
    if (h >= 22 || h < 6) return 'lateNight';
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  String _getDayOfWeek(DateTime t) {
    const days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return days[t.weekday - 1];
  }

  bool isWeekend(DateTime t) => t.weekday == 6 || t.weekday == 7;
}
