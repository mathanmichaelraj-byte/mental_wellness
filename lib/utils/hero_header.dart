import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../utils/app_theme.dart';

/// Scrollable welcome card — displayed as the **first item** in the home
/// screen's [SingleChildScrollView].
///
/// Shows:
///  • Personalised greeting + username
///  • Mood-aware affirmation of the day
///  • Today's mood chip (tappable → MoodHistoryScreen)
///
/// The top app bar (brand + action icons) is now a separate pinned
/// [AppBar] in [HomeScreen] and is NOT part of this widget.
class HeroWelcomeCard extends StatelessWidget {
  final String? username;

  /// Map with `'mood'` int key (0–4) when today's mood is known, else null.
  final Map<String, dynamic>? todayMood;

  /// The affirmation string to show — chosen by [HomeScreen] based on the
  /// inferred [EmotionalState].
  final String affirmation;

  const HeroWelcomeCard({
    super.key,
    required this.username,
    required this.todayMood,
    required this.affirmation,
  });

  static const List<Map<String, Object>> _moods = [
    {'label': 'Sad',     'color': Color(0xFFB0BEC5)},
    {'label': 'Anxious', 'color': Color(0xFFFFCC80)},
    {'label': 'Neutral', 'color': Color(0xFF80DEEA)},
    {'label': 'Good',    'color': Color(0xFFA5D6A7)},
    {'label': 'Great',   'color': Color(0xFFCE93D8)},
  ];

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final bool logged = todayMood != null;
    final int? moodIdx = logged ? todayMood!['mood'] as int? : null;
    final Map<String, Object>? mood =
        (moodIdx != null && moodIdx >= 0 && moodIdx < _moods.length)
            ? _moods[moodIdx]
            : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.gradientDeep,
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(top: -40, right: -30,  child: _circle(180, 0.07)),
          Positioned(bottom: -20, left: -40, child: _circle(140, 0.05)),
          Positioned(top: 50, left: 16,      child: _circle(50,  0.06)),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  username != null
                      ? '${_greeting()},\n$username 👋'
                      : 'Welcome back 👋',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.18,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your space for emotional well-being',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Affirmation of the day
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          affirmation,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.92),
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Today's mood chip
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      context, AppConstants.moodRoute),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.26)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "TODAY'S MOOD",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      Colors.white.withValues(alpha: 0.6),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                logged && mood != null
                                    ? mood['label'] as String
                                    : 'Tap to log your mood',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: (logged && mood != null)
                                      ? mood['color'] as Color
                                      : Colors.white
                                          .withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            logged
                                ? Icons.check_rounded
                                : Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );
}
