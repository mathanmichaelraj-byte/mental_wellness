import '../models/emotional_confidence.dart';
import 'database_service.dart';

enum EmotionalState { calm, restless, stressed, lowEnergy, neutral, distressed }

class EmotionalInferenceService {
  static final EmotionalInferenceService instance = EmotionalInferenceService._init();
  EmotionalInferenceService._init();

  Future<EmotionalState> inferEmotionalState() async {
    final patterns = await DatabaseService.instance.getRecentBehaviorPatterns(days: 3);
    final emotionalNotes = await DatabaseService.instance.getRecentEmotionalNotes(days: 3);
    
    if (patterns.isEmpty) return EmotionalState.neutral;

    int totalOpenCount = 0;
    int lateNightCount = 0;
    int highSpeedCount = 0;
    int shortSessionCount = 0;
    int negativeNoteCount = 0;
    List<int> sessionTimes = [];

    for (var pattern in patterns) {
      totalOpenCount += pattern.appOpenCount;
      sessionTimes.add(pattern.screenTimeSeconds);
      if (pattern.timeOfDay == 'late_night') lateNightCount++;
      if (pattern.interactionSpeed > 5) highSpeedCount++;
      if (pattern.screenTimeSeconds < 60) shortSessionCount++;
    }
    
    for (var note in emotionalNotes) {
      if (note.sentiment == 'negative') negativeNoteCount++;
    }

    double avgOpenCount = totalOpenCount / patterns.length;
    double sessionVariance = _calculateVariance(sessionTimes.map((s) => s.toDouble()).toList());

    if ((avgOpenCount > 15 && lateNightCount > patterns.length * 0.7) || negativeNoteCount >= 3) {
      return EmotionalState.distressed;
    }
    
    if ((avgOpenCount > 10 && highSpeedCount > patterns.length * 0.5) || 
        (negativeNoteCount >= 2 && sessionVariance > 200)) {
      return EmotionalState.restless;
    }
    
    if (lateNightCount > patterns.length * 0.6 && avgOpenCount > 8) {
      return EmotionalState.stressed;
    }
    
    if (avgOpenCount < 3 && shortSessionCount > patterns.length * 0.6) {
      return EmotionalState.lowEnergy;
    }
    
    if (avgOpenCount >= 3 && avgOpenCount <= 6 && highSpeedCount < patterns.length * 0.3 && sessionVariance < 200) {
      return EmotionalState.calm;
    }

    return EmotionalState.neutral;
  }

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => (v - mean) * (v - mean));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  Future<EmotionalConfidence> calculateConfidence() async {
    final patterns = await DatabaseService.instance.getRecentBehaviorPatterns(days: 7);
    final emotionalNotes = await DatabaseService.instance.getRecentEmotionalNotes(days: 7);
    
    List<String> signals = [];
    double confidenceScore = 0.0;
    
    if (patterns.length >= 5) {
      signals.add('consistent_behavior_pattern');
      confidenceScore += 0.15;
    }
    
    if (emotionalNotes.length >= 3) {
      signals.add('frequent_emotional_expression');
      confidenceScore += 0.2;
      
      final negativeCount = emotionalNotes.where((n) => n.sentiment == 'negative').length;
      if (negativeCount >= 2) {
        signals.add('repeated_negative_sentiment');
        confidenceScore += 0.25;
      }
    }
    
    final lateNightPatterns = patterns.where((p) => p.timeOfDay == 'late_night').length;
    if (lateNightPatterns > patterns.length * 0.6) {
      signals.add('persistent_late_night_activity');
      confidenceScore += 0.2;
    }
    
    final highFrequency = patterns.where((p) => p.appOpenCount > 10).length;
    if (highFrequency > patterns.length * 0.5) {
      signals.add('high_frequency_usage');
      confidenceScore += 0.15;
    }
    
    if (patterns.isNotEmpty) {
      final avgOpenCount = patterns.map((p) => p.appOpenCount).reduce((a, b) => a + b) / patterns.length;
      if (avgOpenCount > 12) {
        signals.add('elevated_app_usage');
        confidenceScore += 0.15;
      }
      
      final sessionTimes = patterns.map((p) => p.screenTimeSeconds).toList();
      final variance = _calculateSessionVariance(sessionTimes);
      if (variance > 200) {
        signals.add('erratic_usage_pattern');
        confidenceScore += 0.15;
      }
    }
    
    final weekendPatterns = patterns.where((p) => p.dayOfWeek == 'saturday' || p.dayOfWeek == 'sunday').toList();
    final weekdayPatterns = patterns.where((p) => p.dayOfWeek != 'saturday' && p.dayOfWeek != 'sunday').toList();
    
    if (weekendPatterns.isNotEmpty && weekdayPatterns.isNotEmpty) {
      final weekendAvg = weekendPatterns.map((p) => p.appOpenCount).reduce((a, b) => a + b) / weekendPatterns.length;
      final weekdayAvg = weekdayPatterns.map((p) => p.appOpenCount).reduce((a, b) => a + b) / weekdayPatterns.length;
      
      if ((weekendAvg - weekdayAvg).abs() > 5) {
        signals.add('weekend_weekday_behavior_shift');
        confidenceScore += 0.1;
      }
    }
    
    final shortSessions = patterns.where((p) => p.screenTimeSeconds < 60).length;
    if (shortSessions > patterns.length * 0.6) {
      signals.add('frequent_brief_sessions');
      confidenceScore += 0.1;
    }
    
    ConfidenceLevel level;
    if (confidenceScore >= 0.7 && signals.length >= 5) {
      level = ConfidenceLevel.high;
    } else if (confidenceScore >= 0.4 && signals.length >= 2) {
      level = ConfidenceLevel.medium;
    } else {
      level = ConfidenceLevel.low;
    }
    
    return EmotionalConfidence(
      level: level,
      score: confidenceScore,
      signalCount: signals.length,
      lastUpdated: DateTime.now(),
      signals: signals,
    );
  }

  double _calculateSessionVariance(List<int> sessions) {
    if (sessions.isEmpty) return 0.0;
    final mean = sessions.reduce((a, b) => a + b) / sessions.length;
    final squaredDiffs = sessions.map((v) => (v - mean) * (v - mean));
    return squaredDiffs.reduce((a, b) => a + b) / sessions.length;
  }

  String getStateDescription(EmotionalState state) {
    switch (state) {
      case EmotionalState.calm:
        return 'You seem calm and balanced';
      case EmotionalState.restless:
        return 'You might be feeling restless';
      case EmotionalState.stressed:
        return 'You may be experiencing stress';
      case EmotionalState.lowEnergy:
        return 'Your energy seems low';
      case EmotionalState.distressed:
        return 'Patterns suggest you may be experiencing distress';
      case EmotionalState.neutral:
        return 'Your state is neutral';
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
        'Contact a therapist or counselor for support',
        'Use the location finder to find nearby help'
      ];
    }
    
    switch (state) {
      case EmotionalState.restless:
        return ['Try listening to calming audio', 'Practice breathing exercises', 'Take a short walk outside'];
      case EmotionalState.stressed:
        return ['Consider visiting a calming location', 'Listen to relaxation audio', 'Try deep breathing for 5 minutes'];
      case EmotionalState.lowEnergy:
        return ['Get some fresh air', 'Light physical activity might help', 'Stay hydrated'];
      default:
        return ['Keep maintaining your routine'];
    }
  }
}
