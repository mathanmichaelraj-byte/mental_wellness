import 'package:flutter/material.dart';
import 'package:mental_wellness/services/onboarding_service.dart';
import '../core/constants/app_constants.dart';
import '../services/database_service.dart';
import '../services/emotional_inference_service.dart';
import '../services/firebase/auth_service.dart';
import '../models/emotional_confidence.dart';
import '../utils/app_theme.dart';
import '../widgets/optional_share_dialog.dart';
import '../services/behavior_tracker.dart';
import '../main.dart';
import '../widgets/onboarding/onboarding_manager.dart';
import '../utils/hero_header.dart'; // HeroHeader

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  EmotionalState _currentState = EmotionalState.neutral;
  EmotionalConfidence? _confidence;
  Map<String, dynamic>? _todayMood; // null = nothing logged today
  bool _medicalGuidanceDismissed = false;

  late AnimationController _fadeController;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: AppConstants.fadeAnimationMs),
      vsync: this,
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _showShareDialogIfNeeded();
      OnboardingManager().showOnboarding(context);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    BehaviorTracker.instance.trackInteraction();

    // Run all DB + inference calls in parallel for speed
    final results = await Future.wait([
      EmotionalInferenceService.instance.inferEmotionalState(),
      EmotionalInferenceService.instance.calculateConfidence(),
      DatabaseService.instance.getTodayEmotionalNotes(),
      DatabaseService.instance.getTodayBehaviorPatterns(),
    ]);

    final state = results[0] as EmotionalState;
    final confidence = results[1] as EmotionalConfidence;
    final todayNotes = results[2] as List;
    final todayPatterns = results[3] as List;

    final todayMood = _computeTodayMood(state, todayNotes, todayPatterns);

    if (mounted) {
      setState(() {
        _currentState = state;
        _confidence = confidence;
        _todayMood = todayMood;
      });
    }
  }

  /// Derives today's mood map `{'mood': int}` (index 0-4) from the DB data:
  ///
  ///  1. If the user has written an emotional note today → use its sentiment.
  ///  2. Else if there are behavior records today → use the inferred state.
  ///  3. Otherwise return `null` ("Tap to log your mood").
  Map<String, dynamic>? _computeTodayMood(
    EmotionalState state,
    List todayNotes,
    List todayPatterns,
  ) {
    if (todayNotes.isNotEmpty) {
      final latestSentiment = (todayNotes.first as dynamic).sentiment as String?;
      return {'mood': _sentimentToIndex(latestSentiment)};
    }
    if (todayPatterns.isNotEmpty) {
      return {'mood': _stateToIndex(state)};
    }
    return null;
  }

  /// Maps a sentiment string from [emotional_notes] to a mood index (0–4).
  int _sentimentToIndex(String? sentiment) {
    switch (sentiment) {
      case 'positive':
        return 3; // Good
      case 'negative':
        return 0; // Sad
      default:
        return 2; // Neutral
    }
  }

  /// Maps an [EmotionalState] (inferred from behavior patterns) to a mood
  /// index (0–4) used in [HeroHeader].
  int _stateToIndex(EmotionalState state) {
    switch (state) {
      case EmotionalState.calm:
        return 3; // Good
      case EmotionalState.restless:
        return 1; // Anxious
      case EmotionalState.stressed:
        return 1; // Anxious
      case EmotionalState.lowEnergy:
        return 0; // Sad
      case EmotionalState.distressed:
        return 0; // Sad
      default:
        return 2; // Neutral
    }
  }

  Future<void> _showShareDialogIfNeeded() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      await OptionalShareDialog.show(context, autoShow: true);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final userName = AuthService.instance.currentUser?.displayName;

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.primary,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Column(
                    children: [
                      HeroHeader(
                        username: userName,
                        todayMood: _todayMood,
                        actions: _buildActionButtons(context, themeProvider),
                      ),
                      const SizedBox(height: 12),
                      if (_confidence != null &&
                          _confidence!.canEscalateToMedical() &&
                          !_medicalGuidanceDismissed)
                        _buildMedicalCard(),
                      _buildEmotionalCard(),
                      _buildQuickActions(context),
                      _buildWellnessTools(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ── Action buttons (previously in SliverAppBar) ────────────────────────────

  List<Widget> _buildActionButtons(
      BuildContext context, ThemeProvider? themeProvider) {
    return [
      _iconBtn(
        icon: themeProvider?.themeMode == ThemeMode.light
            ? Icons.dark_mode_outlined
            : Icons.light_mode_outlined,
        onPressed: themeProvider?.toggleTheme,
      ),
      _iconBtn(
        icon: Icons.settings,
        onPressed: () =>
            Navigator.pushNamed(context, AppConstants.settingsRoute),
      ),
      _iconBtn(
        icon: Icons.help_outline,
        onPressed: () async {
          await OnboardingService().resetOnboarding();
          if (mounted) OnboardingManager().showOnboarding(context);
        },
      ),
      _iconBtn(
        icon: Icons.logout,
        onPressed: () async {
          await AuthService.instance.signOut();
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
          }
        },
      ),
    ];
  }

  Widget _iconBtn({required IconData icon, VoidCallback? onPressed}) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 22),
      onPressed: onPressed,
      splashRadius: 20,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }

  // ── Medical card ────────────────────────────────────────────────────────────

  Widget _buildMedicalCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.orange.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(Icons.favorite_border, color: Colors.red.shade700, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'We\'re Here for You',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () =>
                    setState(() => _medicalGuidanceDismissed = true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'We\'ve noticed patterns that suggest you might benefit from additional support.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppConstants.locationRoute),
            icon: const Icon(Icons.location_on),
            label: const Text('Find Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Emotional state card ───────────────────────────────────────────────────

  Widget _buildEmotionalCard() {
    final stateStr = _currentState.toString().split('.').last;
    final stateInfo = _getStateInfo(stateStr);
    final color = stateInfo['color'] as Color;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(stateInfo['icon'] as IconData,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stateInfo['title'] as String,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    if (_confidence != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _confidence!.level
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface(context).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Suggestions:',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...(stateInfo['suggestions'] as List<String>).map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle, size: 16, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(s,
                              style: const TextStyle(
                                  fontSize: 13, height: 1.4)),
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

  Map<String, dynamic> _getStateInfo(String state) {
    switch (state) {
      case 'calm':
        return {
          'title': 'You\'re Feeling Calm',
          'icon': Icons.spa,
          'color': Colors.green,
          'suggestions': [
            'Keep up the good work',
            'Practice gratitude',
            'Maintain your routine',
          ],
        };
      case 'stressed':
        return {
          'title': 'Feeling Stressed',
          'icon': Icons.psychology,
          'color': Colors.orange,
          'suggestions': [
            'Try breathing exercises',
            'Take a short break',
            'Listen to calm audio',
          ],
        };
      case 'restless':
        return {
          'title': 'Feeling Restless',
          'icon': Icons.directions_run,
          'color': Colors.amber,
          'suggestions': [
            'Go for a walk',
            'Practice mindfulness',
            'Try breathing techniques',
          ],
        };
      case 'lowEnergy':
        return {
          'title': 'Low Energy Detected',
          'icon': Icons.battery_2_bar,
          'color': Colors.blue,
          'suggestions': [
            'Get some rest',
            'Stay hydrated',
            'Light exercise might help',
          ],
        };
      case 'distressed':
        return {
          'title': 'Feeling Distressed',
          'icon': Icons.sentiment_very_dissatisfied,
          'color': Colors.red,
          'suggestions': [
            'Reach out for support',
            'Practice self-care',
            'Consider professional help',
          ],
        };
      default:
        return {
          'title': 'Neutral State',
          'icon': Icons.sentiment_neutral,
          'color': AppTheme.primary,
          'suggestions': [
            'Stay mindful',
            'Check in with yourself',
            'Use wellness tools',
          ],
        };
    }
  }

  // ── Quick actions ──────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    const actions = [
      {
        'icon': Icons.edit_note,
        'label': 'Journal',
        'route': AppConstants.journalRoute,
        'color': Colors.purple,
      },
      {
        'icon': Icons.favorite,
        'label': 'Gratitude',
        'route': AppConstants.gratitudeRoute,
        'color': Colors.pink,
      },
      {
        'icon': Icons.insights,
        'label': 'Mood',
        'route': AppConstants.moodRoute,
        'color': Colors.blue,
      },
      {
        'icon': Icons.air,
        'label': 'Breathe',
        'route': AppConstants.breathingRoute,
        'color': Colors.cyan,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text('Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(actions.length, (i) {
              final action = actions[i];
              final color = action['color'] as Color;
              return Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (i * 100)),
                  curve: Curves.easeOut,
                  builder: (_, v, child) => Transform.scale(
                    scale: 0.8 + (v * 0.2),
                    child: Opacity(opacity: v, child: child),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          BehaviorTracker.instance.trackInteraction();
                          Navigator.pushNamed(
                              context, action['route'] as String);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                color.withValues(alpha: 0.8),
                                color.withValues(alpha: 0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(action['icon'] as IconData,
                                  color: Colors.white, size: 28),
                              const SizedBox(height: 8),
                              Text(
                                action['label'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Wellness tools ─────────────────────────────────────────────────────────

  Widget _buildWellnessTools(BuildContext context) {
    const tools = [
      {
        'icon': Icons.self_improvement,
        'title': 'Affirmations',
        'subtitle': 'Positive reminders',
        'route': AppConstants.affirmationsRoute,
        'gradient': [Colors.pink, Colors.red],
      },
      {
        'icon': Icons.book,
        'title': 'Emotional Release',
        'subtitle': 'Express your feelings',
        'route': AppConstants.releaseRoute,
        'gradient': [Colors.blue, Colors.indigo],
      },
      {
        'icon': Icons.music_note,
        'title': 'Calm Audio',
        'subtitle': 'Relaxing sounds',
        'route': AppConstants.audioRoute,
        'gradient': [Colors.indigo, Colors.purple],
      },
      {
        'icon': Icons.location_on,
        'title': 'Find Places',
        'subtitle': 'Support resources',
        'route': AppConstants.locationRoute,
        'gradient': [Colors.teal, Colors.green],
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text('Wellness Tools',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          ...List.generate(tools.length, (i) {
            final tool = tools[i];
            final gradient = tool['gradient'] as List<Color>;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 500 + (i * 100)),
              curve: Curves.easeOut,
              builder: (_, v, child) => Transform.translate(
                offset: Offset(0, 20 * (1 - v)),
                child: Opacity(opacity: v, child: child),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      BehaviorTracker.instance.trackInteraction();
                      Navigator.pushNamed(context, tool['route'] as String);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient
                              .map((c) => c.withValues(alpha: 0.15))
                              .toList(),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: gradient[0].withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradient),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: gradient[0].withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(tool['icon'] as IconData,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tool['title'] as String,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tool['subtitle'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppTheme.textSecondary(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── FAB ────────────────────────────────────────────────────────────────────

  Widget _buildFAB() {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
      child: FloatingActionButton.extended(
        onPressed: () => OptionalShareDialog.show(context),
        backgroundColor: AppTheme.primary,
        elevation: 8,
        icon: const Icon(Icons.edit_note, color: Colors.white),
        label: const Text(
          'Share Feelings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
