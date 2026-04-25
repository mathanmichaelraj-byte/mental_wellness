import 'dart:math';
import '../core/constants/app_constants.dart';
import '../services/emotional_inference_service.dart';

/// Returns mood-aware affirmations keyed to the current [EmotionalState].
///
/// Usage:
/// ```dart
/// final text = MoodAffirmationService.instance.getForState(EmotionalState.stressed);
/// ```
class MoodAffirmationService {
  static final MoodAffirmationService instance =
      MoodAffirmationService._init();
  MoodAffirmationService._init();

  final Random _rng = Random();

  /// Returns a single affirmation appropriate for [state].
  String getForState(EmotionalState state) {
    final pool = _poolFor(state);
    return pool[_rng.nextInt(pool.length)];
  }

  /// Returns [count] unique affirmations for [state] (with wrap-around if
  /// the pool is smaller than [count]).
  List<String> getMultipleForState(EmotionalState state, {int count = 5}) {
    final pool = List<String>.from(_poolFor(state))..shuffle(_rng);
    if (pool.length >= count) return pool.take(count).toList();
    // Pad with general affirmations if the mood pool is small
    final general = List<String>.from(AppConstants.generalAffirmations)
      ..shuffle(_rng);
    return [...pool, ...general].take(count).toList();
  }

  /// Returns the full list for a given state (for the Affirmations screen).
  List<String> getAllForState(EmotionalState state) =>
    List<String>.from(_poolFor(state));

  List<String> _poolFor(EmotionalState state) {
    switch (state) {
      case EmotionalState.calm:
        return AppConstants.moodAffirmations['calm']!;
      case EmotionalState.stressed:
        return AppConstants.moodAffirmations['stressed']!;
      case EmotionalState.restless:
        return AppConstants.moodAffirmations['restless']!;
      case EmotionalState.lowEnergy:
        return AppConstants.moodAffirmations['lowEnergy']!;
      case EmotionalState.distressed:
        return AppConstants.moodAffirmations['distressed']!;
      default:
        return AppConstants.moodAffirmations['neutral']!;
    }
  }
}
