import 'package:flutter/material.dart';
import '../../models/onboarding_step.dart';
import '../../services/onboarding/onboarding_service.dart';
import 'onboarding_overlay.dart';

class OnboardingManager {
  static final OnboardingManager _instance = OnboardingManager._internal();

  factory OnboardingManager() {
    return _instance;
  }

  OnboardingManager._internal();

  final List<OnboardingStep> steps = [
    OnboardingStep(
      title: 'Welcome to Mental Wellness',
      description: 'Your personal companion for emotional well-being. Let\'s explore the app together!',
    ),
    OnboardingStep(
      title: 'Share Your Feelings',
      description: 'Tap the button below to express what\'s on your mind. Your thoughts are safe here.',
    ),
    OnboardingStep(
      title: 'Explore Wellness Tools',
      description: 'Discover breathing exercises, calming audio, and more to support your well-being.',
    ),
    OnboardingStep(
      title: 'Track Your Progress',
      description: 'View your emotional patterns and insights over time to understand yourself better.',
    ),
    OnboardingStep(
      title: 'Find Support',
      description: 'Locate nearby therapists, parks, and meditation centers for additional support.',
    ),
  ];

  Future<void> showOnboarding(BuildContext context) async {
    final isCompleted = await OnboardingService().isOnboardingCompleted();
    if (isCompleted) return;

    int currentStep = 0;

    void showStep() {
      if (currentStep >= steps.length) {
        OnboardingService().completeOnboarding();
        return;
      }

      final step = steps[currentStep];
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => OnboardingOverlay(
          title: step.title,
          description: step.description,
          onNext: () {
            Navigator.pop(dialogContext);
            currentStep++;
            showStep();
          },
          onSkip: () {
            Navigator.pop(dialogContext);
            OnboardingService().completeOnboarding();
          },
          isLast: currentStep == steps.length - 1,
          currentStep: currentStep + 1,
          totalSteps: steps.length,
        ),
      );
    }

    showStep();
  }
}
