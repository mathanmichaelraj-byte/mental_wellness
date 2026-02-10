import '../models/emotional_confidence.dart';
import 'database_service.dart';

enum EmotionalState { calm, restless, stressed, lowEnergy, neutral, distressed }

class EmotionalInferenceService {
  static final EmotionalInferenceService instance = EmotionalInferenceService._init();
  EmotionalInferenceService._init();

  Future<EmotionalState> inferEmotionalState() async {
    final patterns = await DatabaseService.instance.getRecentBehaviorPatterns(days: 3);
    
    if (patterns.isEmpty) return EmotionalState.neutral;

    int totalOpenCount = 0;
    int lateNightCount = 0;
    int highSpeedCount = 0;
    int longSessionCount = 0;

    for (var pattern in patterns) {
      totalOpenCount += pattern.appOpenCount;
      if (pattern.timeOfDay == 'late_night') lateNightCount++;
      if (pattern.interactionSpeed > 5) highSpeedCount++;
      if (pattern.screenTimeSeconds > 600) longSessionCount++;
    }

    double avgOpenCount = totalOpenCount / patterns.length;

    if (avgOpenCount > 15 && lateNightCount > patterns.length * 0.7) {
      return EmotionalState.distressed;
    }
    
    if (avgOpenCount > 10 && highSpeedCount > patterns.length * 0.5) {
      return EmotionalState.restless;
    }
    
    if (lateNightCount > patterns.length * 0.6 && avgOpenCount > 8) {
      return EmotionalState.stressed;
    }
    
    if (avgOpenCount < 3 && longSessionCount < 2) {
      return EmotionalState.lowEnergy;
    }
    
    if (avgOpenCount >= 3 && avgOpenCount <= 6 && highSpeedCount < patterns.length * 0.3) {
      return EmotionalState.calm;
    }

    return EmotionalState.neutral;
  }

  Future<EmotionalConfidence> calculateConfidence() async {
    final patterns = await DatabaseService.instance.getRecentBehaviorPatterns(days: 7);
    final moods = await DatabaseService.instance.getMoodEntries(limit: 10);
    
    List<String> signals = [];
    double confidenceScore = 0.0;
    
    if (patterns.length >= 5) {
      signals.add('consistent_behavior_pattern');
      confidenceScore += 0.2;
    }
    
    if (moods.length >= 3) {
      final lowMoodCount = moods.where((m) => m.moodScore <= 4).length;
      if (lowMoodCount >= 2) {
        signals.add('repeated_low_mood');
        confidenceScore += 0.3;
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
    
    if (moods.isNotEmpty) {
      final recentMoods = moods.take(5).toList();
      final variance = _calculateVariance(recentMoods.map((m) => m.moodScore.toDouble()).toList());
      if (variance > 6.0) {
        signals.add('mood_instability');
        confidenceScore += 0.15;
      }
    }
    
    ConfidenceLevel level;
    if (confidenceScore >= 0.7 && signals.length >= 4) {
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

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => (v - mean) * (v - mean));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
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
        return [
          'Try listening to calming audio',
          'Practice breathing exercises',
          'Take a short walk outside'
        ];
      case EmotionalState.stressed:
        return [
          'Consider visiting a calming location',
          'Listen to relaxation audio',
          'Try deep breathing for 5 minutes'
        ];
      case EmotionalState.lowEnergy:
        return [
          'Get some fresh air',
          'Light physical activity might help',
          'Stay hydrated'
        ];
      default:
        return ['Keep maintaining your routine'];
    }
  }
}
