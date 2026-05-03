import 'package:shared_preferences/shared_preferences.dart';

/// Manages the one-time in-app onboarding flow completion state.
class OnboardingService {
  static const String _key = 'onboarding_completed';
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  Future<bool> isOnboardingCompleted() async =>
      (await SharedPreferences.getInstance()).getBool(_key) ?? false;

  Future<void> completeOnboarding() async =>
      (await SharedPreferences.getInstance()).setBool(_key, true);

  Future<void> resetOnboarding() async =>
      (await SharedPreferences.getInstance()).setBool(_key, false);
}
