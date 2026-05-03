import 'dart:math';
import '../../core/constants/app_constants.dart';
import 'emotional_inference_service.dart';

/// Returns mood-aware affirmations keyed to the current [EmotionalState].
class MoodAffirmationService {
  static final MoodAffirmationService instance =
      MoodAffirmationService._init();
  MoodAffirmationService._init();

  final Random _rng = Random();

  /// One random affirmation appropriate for [state].
  String getForState(EmotionalState state) {
    final pool = _poolFor(state);
    return pool[_rng.nextInt(pool.length)];
  }

  /// [count] unique affirmations, padded with general ones if the pool is small.
  List<String> getMultipleForState(EmotionalState state, {int count = 5}) {
    final pool = List<String>.from(_poolFor(state))..shuffle(_rng);
    if (pool.length >= count) return pool.take(count).toList();
    final general = List<String>.from(AppConstants.generalAffirmations)
      ..shuffle(_rng);
    return [...pool, ...general].take(count).toList();
  }

  /// Full pool for [state] — used by [AffirmationsScreen].
  List<String> getAllForState(EmotionalState state) =>
      List<String>.from(_poolFor(state));

  List<String> _poolFor(EmotionalState state) {
    switch (state) {
      case EmotionalState.calm:       return AppConstants.moodAffirmations['calm']!;
      case EmotionalState.stressed:   return AppConstants.moodAffirmations['stressed']!;
      case EmotionalState.restless:   return AppConstants.moodAffirmations['restless']!;
      case EmotionalState.lowEnergy:  return AppConstants.moodAffirmations['lowEnergy']!;
      case EmotionalState.distressed: return AppConstants.moodAffirmations['distressed']!;
      default:                        return AppConstants.moodAffirmations['neutral']!;
    }
  }
}
