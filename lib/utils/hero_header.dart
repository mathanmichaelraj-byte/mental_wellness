import 'package:flutter/material.dart';
import 'package:mental_wellness/core/constants/app_constants.dart';
import 'package:mental_wellness/utils/app_theme.dart';

/// Combined brand header widget used as the **fixed, non-scrolling** top
/// section of [HomeScreen].
///
/// It merges what was previously a separate [SliverAppBar] and the hero
/// banner into a single gradient container that is pinned above the
/// scrollable content.
///
/// Parameters:
///   [username]  – Display name of the signed-in user (nullable).
///   [todayMood] – Map with a `'mood'` int key (0–4) when the user has data
///                 for today, or `null` to show "Tap to log your mood".
///   [actions]   – Icon buttons rendered at the trailing end of the brand row
///                 (theme toggle, settings, help, logout, etc.).
class HeroHeader extends StatelessWidget {
  final String? username;
  final Map<String, dynamic>? todayMood;
  final List<Widget> actions;

  const HeroHeader({
    super.key,
    required this.username,
    required this.todayMood,
    this.actions = const [],
  });

  // Mood labels / accent colours mapped by index 0-4
  static const List<Map<String, Object>> _moods = [
    {'label': 'Sad',     'color': Color(0xFFB0BEC5)},
    {'label': 'Anxious', 'color': Color(0xFFFFCC80)},
    {'label': 'Neutral', 'color': Color(0xFF80DEEA)},
    {'label': 'Good',    'color': Color(0xFFA5D6A7)},
    {'label': 'Great',   'color': Color(0xFFCE93D8)},
  ];

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
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
      decoration: const BoxDecoration(
        gradient: AppTheme.gradientDeep,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          // ── Decorative circles ─────────────────────────────────────────
          Positioned(
            top: -50, right: -40,
            child: _circle(220, 0.07),
          ),
          Positioned(
            bottom: -20, left: -50,
            child: _circle(180, 0.05),
          ),
          Positioned(
            top: 60, left: 20,
            child: _circle(60, 0.06),
          ),
          // ── Main content ───────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 8, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand row — app icon + name + action buttons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // App icon
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Mental Wellness',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      // Action icon buttons from HomeScreen
                      ...actions,
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Greeting
                  Text(
                    username != null
                        ? '${_greeting()},\n$username'
                        : 'Welcome back',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your space for emotional well-being',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.78),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Frosted-glass mood card
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppConstants.moodRoute),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                        ),
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
                                    color: Colors.white.withValues(alpha: 0.65),
                                    letterSpacing: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  logged && mood != null
                                      ? mood['label'] as String
                                      : 'Tap to log your mood',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: (logged && mood != null)
                                        ? mood['color'] as Color
                                        : Colors.white.withValues(alpha: 0.92),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              logged ? Icons.check_rounded : Icons.add_rounded,
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
