import '../models/emotional_confidence.dart';
import '../models/behavior_pattern.dart';
import 'database_service.dart';
import '../utils/sentiment_analyzer.dart';

enum EmotionalState { calm, restless, stressed, lowEnergy, neutral, distressed }

class EmotionalInferenceService {
  static final EmotionalInferenceService instance = EmotionalInferenceService._init();
  EmotionalInferenceService._init();
  
  Future<void> initializeML() async {
    // Rule-based system only, no ML initialization needed
  }

  Future<EmotionalState> inferEmotionalState() async {
    final patterns = await DatabaseService.instance.getRecentBehaviorPatterns(days: 3);
    final emotionalNotes = await DatabaseService.instance.getRecentEmotionalNotes(days: 3);
    
    if (patterns.isEmpty) return EmotionalState.neutral;

    // Aggregate by day
    Map<String, List<BehaviorPattern>> dailyPatterns = {};
    for (var pattern in patterns) {
      final day = pattern.timestamp.toIso8601String().split('T')[0];
      dailyPatterns.putIfAbsent(day, () => []).add(pattern);
    }

    int totalDailyOpens = 0;
    int lateNightSessions = 0;
    int highSpeedSessions = 0;
    int shortSessions = 0;
    int negativeNoteCount = 0;
    int positiveNoteCount = 0;
    double totalSentimentScore = 0.0;
    List<int> sessionTimes = [];

    // Calculate daily metrics
    for (var dayPatterns in dailyPatterns.values) {
      totalDailyOpens += dayPatterns.length;
      for (var pattern in dayPatterns) {
        sessionTimes.add(pattern.screenTimeSeconds);
        if (pattern.timeOfDay == 'lateNight') lateNightSessions++;
        if (pattern.interactionSpeed > 5) highSpeedSessions++;
        if (pattern.screenTimeSeconds < 60) shortSessions++;
      }
    }
    
    // Analyze emotional notes with NLP sentiment
    for (var note in emotionalNotes) {
      final sentiment = note.sentiment ?? SentimentAnalyzer.analyze(note.content);
      if (sentiment == 'negative') {
        negativeNoteCount++;
        totalSentimentScore -= 1.0;
      } else if (sentiment == 'positive') {
        positiveNoteCount++;
        totalSentimentScore += 1.0;
      }
    }

    double avgDailyOpens = totalDailyOpens / dailyPatterns.length;
    double sessionVariance = _calculateVariance(sessionTimes.map((s) => s.toDouble()).toList());
    double lateNightRatio = patterns.isEmpty ? 0 : lateNightSessions / patterns.length;
    double highSpeedRatio = patterns.isEmpty ? 0 : highSpeedSessions / patterns.length;
    double shortSessionRatio = patterns.isEmpty ? 0 : shortSessions / patterns.length;
    double avgSentiment = emotionalNotes.isEmpty ? 0 : totalSentimentScore / emotionalNotes.length;

    // Distressed: Strong negative sentiment + behavioral distress signals
    if ((negativeNoteCount >= 3 && avgSentiment < -0.6) || 
        (avgDailyOpens > 10 && lateNightRatio > 0.5 && negativeNoteCount >= 2)) {
      return EmotionalState.distressed;
    }
    
    // Restless: Negative sentiment with erratic behavior
    if ((negativeNoteCount >= 2 && sessionVariance > 150) || 
        (avgDailyOpens > 7 && highSpeedRatio > 0.4 && avgSentiment < -0.3)) {
      return EmotionalState.restless;
    }
    
    // Stressed: Late nights + moderate negative sentiment
    if ((lateNightRatio > 0.4 && avgDailyOpens > 5) || 
        (negativeNoteCount >= 2 && lateNightRatio > 0.3)) {
      return EmotionalState.stressed;
    }
    
    // Low Energy: Low usage + negative or neutral sentiment
    if ((avgDailyOpens < 3 && shortSessionRatio > 0.5) || 
        (avgDailyOpens < 4 && negativeNoteCount >= 1 && positiveNoteCount == 0)) {
      return EmotionalState.lowEnergy;
    }
    
    // Calm: Positive sentiment + stable behavior
    if ((positiveNoteCount >= 2 && avgSentiment > 0.5) || 
        (avgDailyOpens >= 3 && avgDailyOpens <= 6 && highSpeedRatio < 0.3 && 
         sessionVariance < 150 && negativeNoteCount == 0)) {
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
    
    if (patterns.isEmpty) {
      return EmotionalConfidence(
        level: ConfidenceLevel.low,
        score: 0.0,
        signalCount: 0,
        lastUpdated: DateTime.now(),
        signals: [],
      );
    }
    
    // Aggregate by day
    Map<String, List<BehaviorPattern>> dailyPatterns = {};
    for (var pattern in patterns) {
      final day = pattern.timestamp.toIso8601String().split('T')[0];
      dailyPatterns.putIfAbsent(day, () => []).add(pattern);
    }
    
    List<String> signals = [];
    double confidenceScore = 0.0;
    
    // Signal 1: Consistent behavior pattern (at least 3 days)
    if (dailyPatterns.length >= 3) {
      signals.add('consistent_behavior_pattern');
      confidenceScore += 0.15;
    }
    
    // Signal 2-4: NLP-enhanced emotional expression analysis
    if (emotionalNotes.length >= 2) {
      signals.add('frequent_emotional_expression');
      confidenceScore += 0.15;
      
      // Analyze sentiment with NLP
      int negativeCount = 0;
      int positiveCount = 0;
      double totalSentiment = 0.0;
      
      for (var note in emotionalNotes) {
        final sentiment = note.sentiment ?? SentimentAnalyzer.analyze(note.content);
        if (sentiment == 'negative') {
          negativeCount++;
          totalSentiment -= 1.0;
        } else if (sentiment == 'positive') {
          positiveCount++;
          totalSentiment += 1.0;
        }
      }
      
      // Strong negative sentiment pattern
      if (negativeCount >= 3 || (negativeCount >= 2 && totalSentiment < -1.5)) {
        signals.add('persistent_negative_sentiment');
        confidenceScore += 0.3;
      } else if (negativeCount >= 2) {
        signals.add('repeated_negative_sentiment');
        confidenceScore += 0.2;
      }
      
      // Sentiment consistency (all same type)
      if (emotionalNotes.length >= 3 && (negativeCount == emotionalNotes.length || positiveCount == emotionalNotes.length)) {
        signals.add('consistent_emotional_pattern');
        confidenceScore += 0.15;
      }
    }
    
    // Signal 4: Late night activity
    final lateNightSessions = patterns.where((p) => p.timeOfDay == 'lateNight').length;
    if (lateNightSessions > patterns.length * 0.4) {
      signals.add('persistent_late_night_activity');
      confidenceScore += 0.2;
    }
    
    // Signal 5: High frequency usage (more than 5 sessions per day on average)
    final avgDailySessions = patterns.length / dailyPatterns.length;
    if (avgDailySessions > 5) {
      signals.add('high_frequency_usage');
      confidenceScore += 0.15;
    }
    
    // Signal 6: Elevated usage (more than 7 sessions per day)
    if (avgDailySessions > 7) {
      signals.add('elevated_app_usage');
      confidenceScore += 0.15;
    }
    
    // Signal 7: Erratic pattern
    final sessionTimes = patterns.map((p) => p.screenTimeSeconds).toList();
    final variance = _calculateSessionVariance(sessionTimes);
    if (variance > 150) {
      signals.add('erratic_usage_pattern');
      confidenceScore += 0.15;
    }
    
    // Signal 8: Weekend/weekday shift
    final weekendPatterns = patterns.where((p) => p.dayOfWeek == 'Saturday' || p.dayOfWeek == 'Sunday').toList();
    final weekdayPatterns = patterns.where((p) => p.dayOfWeek != 'Saturday' && p.dayOfWeek != 'Sunday').toList();
    
    if (weekendPatterns.isNotEmpty && weekdayPatterns.isNotEmpty) {
      final weekendAvg = weekendPatterns.length / 2.0; // Divide by 2 days
      final weekdayAvg = weekdayPatterns.length / 5.0; // Divide by 5 days
      
      if ((weekendAvg - weekdayAvg).abs() > 2) {
        signals.add('weekend_weekday_behavior_shift');
        confidenceScore += 0.1;
      }
    }
    
    // Signal 9: Frequent brief sessions
    final shortSessions = patterns.where((p) => p.screenTimeSeconds < 60).length;
    if (shortSessions > patterns.length * 0.5) {
      signals.add('frequent_brief_sessions');
      confidenceScore += 0.1;
    }
    
    // Determine confidence level
    ConfidenceLevel level;
    if (confidenceScore >= 0.6 && signals.length >= 4) {
      level = ConfidenceLevel.high;
    } else if (confidenceScore >= 0.3 && signals.length >= 2) {
      level = ConfidenceLevel.medium;
    } else {
      level = ConfidenceLevel.low;
    }
    
    return EmotionalConfidence(
      level: level,
      score: confidenceScore.clamp(0.0, 1.0),
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
