import 'package:flutter/material.dart';
import 'package:mental_wellness/utils/app_theme.dart';

class _HeroHeader extends StatelessWidget {
  final String? username;
  final Map<String, dynamic>? todayMood;
  const _HeroHeader({required this.username, required this.todayMood});

  static const _moods = [
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
    final logged = todayMood != null;
    final moodIdx = logged ? todayMood!['mood'] as int : null;
    final mood = moodIdx != null ? _moods[moodIdx] : null;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(opacity: v, child: child),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.gradientDeep,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(36),
            bottomRight: Radius.circular(36),
          ),
        ),
        child: Stack(
          children: [
            // Large decorative circle — top right
            Positioned(
              top: -50, right: -40,
              child: Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            // Medium circle — bottom left
            Positioned(
              bottom: -20, left: -50,
              child: Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            // Small accent circle — top left
            Positioned(
              top: 60, left: 20,
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Content
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App name row
                    Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mental Wellness',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    // Greeting — large and bold
                    Text(
                      username != null ? '${_greeting()},\n$username' : 'Welcome back',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your space for emotional well-being',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.78),
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Mood card — frosted glass
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/mood_tracker'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                        ),
                        child: Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              "TODAY'S MOOD",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.65),
                                letterSpacing: 1.3,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              logged ? (mood!['label'] as String) : 'Tap to log your mood',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: logged
                                    ? (mood!['color'] as Color)
                                    : Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                          ])),
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: Icon(
                              logged ? Icons.check_rounded : Icons.add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}