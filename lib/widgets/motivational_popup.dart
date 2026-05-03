import 'package:flutter/material.dart';
import '../services/inference/emotional_inference_service.dart';
import '../services/inference/mood_affirmation_service.dart';
import '../utils/app_theme.dart';

/// Shows a one-time motivational popup when the user opens the app.
///
/// The affirmation text is chosen based on [currentState] so it matches
/// what the user is likely feeling.  Call [MotivationalPopup.show] from
/// a [postFrameCallback] in [HomeScreen.initState].
class MotivationalPopup {
  MotivationalPopup._();

  static Future<void> show(
    BuildContext context, {
    required EmotionalState currentState,
  }) async {
    final text =
        MoodAffirmationService.instance.getForState(currentState);

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => _PopupContent(
        affirmation: text,
        state: currentState,
      ),
    );
  }
}

class _PopupContent extends StatelessWidget {
  final String affirmation;
  final EmotionalState state;

  const _PopupContent({
    required this.affirmation,
    required this.state,
  });

  static const Map<EmotionalState, Color> _stateColors = {
    EmotionalState.calm:       Color(0xFFA5D6A7),
    EmotionalState.restless:   Color(0xFFFFCC80),
    EmotionalState.stressed:   Color(0xFFFFAB91),
    EmotionalState.lowEnergy:  Color(0xFFB0BEC5),
    EmotionalState.distressed: Color(0xFF90CAF9),
    EmotionalState.neutral:    Color(0xFF80DEEA),
  };

  Color get _color => _stateColors[state] ?? const Color(0xFF80DEEA);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.background(context),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: _color.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.format_quote_rounded,
                    size: 34, color: _color),
              ),
              const SizedBox(height: 20),

              // Label
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "TODAY'S AFFIRMATION",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _color,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Affirmation text
              Text(
                affirmation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 28),

              // Dismiss button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Carry this with me',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
