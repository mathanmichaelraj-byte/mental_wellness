import '../../models/emotional_confidence.dart';
import '../../models/behavior_pattern.dart';
import '../local/database_service.dart';
import '../../utils/sentiment_analyzer.dart';

enum EmotionalState { calm, restless, stressed, lowEnergy, neutral, distressed }

/// Rule-based emotional inference from passive [BehaviorPattern] signals
/// and optional NLP sentiment from [EmotionalNote] content.
class EmotionalInferenceService {
  static final EmotionalInferenceService instance =
      EmotionalInferenceService._init();
  EmotionalInferenceService._init();

  Future<void> initializeML() async {}

  Future<EmotionalState> inferEmotionalState() async {
    final patterns =
        await DatabaseService.instance.getRecentBehaviorPatterns(days: 3);
    final notes =
        await DatabaseService.instance.getRecentEmotionalNotes(days: 3);

    if (patterns.isEmpty) return EmotionalState.neutral;

    final Map<String, List<BehaviorPattern>> daily = {};
    for (final p in patterns) {
      final day = p.timestamp.toIso8601String().split('T')[0];
      daily.putIfAbsent(day, () => []).add(p);
    }

    int lateNight = 0, highSpeed = 0, shortSess = 0, negCount = 0, posCount = 0;
    double sentimentSum = 0.0;
    final List<int> times = [];

    for (final p in patterns) {
      times.add(p.screenTimeSeconds);
      if (p.timeOfDay == 'lateNight') lateNight++;
      if (p.interactionSpeed > 5) highSpeed++;
      if (p.screenTimeSeconds < 60) shortSess++;
    }

    for (final n in notes) {
      final s = n.sentiment ?? SentimentAnalyzer.analyze(n.content);
      if (s == 'negative') { negCount++; sentimentSum -= 1.0; }
      else if (s == 'positive') { posCount++; sentimentSum += 1.0; }
    }

    final double avgOpens   = patterns.length / daily.length;
    final double variance   = _variance(times.map((t) => t.toDouble()).toList());
    final double lnRatio    = lateNight / patterns.length;
    final double hsRatio    = highSpeed  / patterns.length;
    final double ssRatio    = shortSess  / patterns.length;
    final double avgSentiment =
        notes.isEmpty ? 0 : sentimentSum / notes.length;

    if ((negCount >= 3 && avgSentiment < -0.6) ||
        (avgOpens > 10 && lnRatio > 0.5 && negCount >= 2)) {
      return EmotionalState.distressed;
    }
    if ((negCount >= 2 && variance > 150) ||
        (avgOpens > 7 && hsRatio > 0.4 && avgSentiment < -0.3)) {
      return EmotionalState.restless;
    }
    if ((lnRatio > 0.4 && avgOpens > 5) ||
        (negCount >= 2 && lnRatio > 0.3)) {
      return EmotionalState.stressed;
    }
    if ((avgOpens < 3 && ssRatio > 0.5) ||
        (avgOpens < 4 && negCount >= 1 && posCount == 0)) {
      return EmotionalState.lowEnergy;
    }
    if ((posCount >= 2 && avgSentiment > 0.5) ||
        (avgOpens >= 3 && avgOpens <= 6 && hsRatio < 0.3 &&
            variance < 150 && negCount == 0)) {
      return EmotionalState.calm;
    }
    return EmotionalState.neutral;
  }

  Future<EmotionalConfidence> calculateConfidence() async {
    final patterns =
        await DatabaseService.instance.getRecentBehaviorPatterns(days: 7);
    final notes =
        await DatabaseService.instance.getRecentEmotionalNotes(days: 7);

    if (patterns.isEmpty) {
      return EmotionalConfidence(
        level: ConfidenceLevel.low, score: 0.0, signalCount: 0,
        lastUpdated: DateTime.now(), signals: [],
      );
    }

    final Map<String, List<BehaviorPattern>> daily = {};
    for (final p in patterns) {
      final day = p.timestamp.toIso8601String().split('T')[0];
      daily.putIfAbsent(day, () => []).add(p);
    }

    final List<String> signals = [];
    double score = 0.0;

    if (daily.length >= 3) { signals.add('consistent_behavior_pattern'); score += 0.15; }

    if (notes.length >= 2) {
      signals.add('frequent_emotional_expression'); score += 0.15;
      int neg = 0, pos = 0; double total = 0.0;
      for (final n in notes) {
        final s = n.sentiment ?? SentimentAnalyzer.analyze(n.content);
        if (s == 'negative') { neg++; total -= 1.0; }
        else if (s == 'positive') { pos++; total += 1.0; }
      }
      if (neg >= 3 || (neg >= 2 && total < -1.5)) {
        signals.add('persistent_negative_sentiment'); score += 0.3;
      } else if (neg >= 2) {
        signals.add('repeated_negative_sentiment'); score += 0.2;
      }
      if (notes.length >= 3 &&
          (neg == notes.length || pos == notes.length)) {
        signals.add('consistent_emotional_pattern'); score += 0.15;
      }
    }

    final lnCount = patterns.where((p) => p.timeOfDay == 'lateNight').length;
    if (lnCount > patterns.length * 0.4) {
      signals.add('persistent_late_night_activity'); score += 0.2;
    }

    final avgDaily = patterns.length / daily.length;
    if (avgDaily > 5) { signals.add('high_frequency_usage'); score += 0.15; }
    if (avgDaily > 7) { signals.add('elevated_app_usage');   score += 0.15; }

    final variance = _calcVariance(patterns.map((p) => p.screenTimeSeconds).toList());
    if (variance > 150) { signals.add('erratic_usage_pattern'); score += 0.15; }

    final wEnd = patterns.where((p) => p.dayOfWeek == 'Saturday' || p.dayOfWeek == 'Sunday').length;
    final wDay = patterns.length - wEnd;
    if (wEnd > 0 && wDay > 0) {
      if (((wEnd / 2.0) - (wDay / 5.0)).abs() > 2) {
        signals.add('weekend_weekday_behavior_shift'); score += 0.1;
      }
    }

    final short = patterns.where((p) => p.screenTimeSeconds < 60).length;
    if (short > patterns.length * 0.5) {
      signals.add('frequent_brief_sessions'); score += 0.1;
    }

    final level = (score >= 0.6 && signals.length >= 4)
        ? ConfidenceLevel.high
        : (score >= 0.3 && signals.length >= 2)
            ? ConfidenceLevel.medium
            : ConfidenceLevel.low;

    return EmotionalConfidence(
      level: level, score: score.clamp(0.0, 1.0),
      signalCount: signals.length, lastUpdated: DateTime.now(),
      signals: signals,
    );
  }

  double _variance(List<double> v) {
    if (v.isEmpty) return 0;
    final mean = v.reduce((a, b) => a + b) / v.length;
    return v.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / v.length;
  }

  double _calcVariance(List<int> v) =>
      _variance(v.map((x) => x.toDouble()).toList());

  String getStateDescription(EmotionalState s) {
    switch (s) {
      case EmotionalState.calm:       return 'You seem calm and balanced';
      case EmotionalState.restless:   return 'You might be feeling restless';
      case EmotionalState.stressed:   return 'You may be experiencing stress';
      case EmotionalState.lowEnergy:  return 'Your energy seems low';
      case EmotionalState.distressed: return 'Patterns suggest you may be experiencing distress';
      default:                        return 'Your state is neutral';
    }
  }

  List<String> getSuggestions(EmotionalState state, ConfidenceLevel confidence) {
    if (confidence == ConfidenceLevel.low) {
      return ['Take a moment to breathe', 'Stay hydrated', 'Consider a short walk'];
    }
    if (confidence == ConfidenceLevel.high && state == EmotionalState.distressed) {
      return [
        'This pattern may indicate ongoing distress',
        'Consider speaking with a mental health professional',
        'Use the location finder to find nearby help',
      ];
    }
    switch (state) {
      case EmotionalState.restless:
        return ['Try calming audio', 'Practice breathing exercises', 'Take a short walk'];
      case EmotionalState.stressed:
        return ['Visit a calming location', 'Listen to relaxation audio', 'Try deep breathing'];
      case EmotionalState.lowEnergy:
        return ['Get fresh air', 'Light physical activity', 'Stay hydrated'];
      default:
        return ['Keep maintaining your routine'];
    }
  }
}
