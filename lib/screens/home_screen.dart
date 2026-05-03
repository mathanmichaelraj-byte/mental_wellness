import 'package:flutter/material.dart';
import 'package:mental_wellness/services/local/behavior_tracker.dart';
import 'package:mental_wellness/services/inference/emotional_inference_service.dart';
import 'package:mental_wellness/services/inference/mood_affirmation_service.dart';
import 'package:mental_wellness/services/local/database_service.dart';
import 'package:mental_wellness/services/onboarding/onboarding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../services/cloud/auth_service.dart';
import '../models/emotional_confidence.dart';
import '../utils/app_theme.dart';
import '../utils/hero_header.dart';
import '../widgets/motivational_popup.dart';
import '../widgets/optional_share_dialog.dart';
import '../widgets/onboarding/onboarding_manager.dart';
import '../main.dart'; // ThemeProvider

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  EmotionalState _currentState = EmotionalState.neutral;
  EmotionalConfidence? _confidence;
  Map<String, dynamic>? _todayMood;
  String _affirmation = '';
  bool _medicalGuidanceDismissed = false;

  late AnimationController _fadeCtrl;

  // Key used to show the motivational popup only once per calendar day
  static const String _popupShownKey = 'motivational_popup_shown_date';

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: Duration(milliseconds: AppConstants.fadeAnimationMs),
      vsync: this,
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
      _showShareDialogIfNeeded();
      OnboardingManager().showOnboarding(context);
      _maybeShowMotivationalPopup();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Data ───────────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    BehaviorTracker.instance.trackInteraction();

    final results = await Future.wait([
      EmotionalInferenceService.instance.inferEmotionalState(),
      EmotionalInferenceService.instance.calculateConfidence(),
      DatabaseService.instance.getTodayEmotionalNotes(),
      DatabaseService.instance.getTodayBehaviorPatterns(),
    ]);

    final state      = results[0] as EmotionalState;
    final confidence = results[1] as EmotionalConfidence;
    final notes      = results[2] as List;
    final patterns   = results[3] as List;

    final todayMood  = _computeTodayMood(state, notes, patterns);
    final affirmation =
        MoodAffirmationService.instance.getForState(state);

    if (mounted) {
      setState(() {
        _currentState = state;
        _confidence   = confidence;
        _todayMood    = todayMood;
        _affirmation  = affirmation;
      });
    }
  }

  Map<String, dynamic>? _computeTodayMood(
      EmotionalState state, List notes, List patterns) {
    if (notes.isNotEmpty) {
      final sentiment = (notes.first as dynamic).sentiment as String?;
      return {'mood': _sentimentToIndex(sentiment)};
    }
    if (patterns.isNotEmpty) return {'mood': _stateToIndex(state)};
    return null;
  }

  int _sentimentToIndex(String? sentiment) {
    switch (sentiment) {
      case 'positive': return 3;
      case 'negative': return 0;
      default:         return 2;
    }
  }

  int _stateToIndex(EmotionalState state) {
    switch (state) {
      case EmotionalState.calm:      return 3;
      case EmotionalState.restless:  return 1;
      case EmotionalState.stressed:  return 1;
      case EmotionalState.lowEnergy: return 0;
      case EmotionalState.distressed:return 0;
      default:                       return 2;
    }
  }

  // ── Motivational popup — once per day ──────────────────────────────────────

  Future<void> _maybeShowMotivationalPopup() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month}-${today.day}';
    final lastShown = prefs.getString(_popupShownKey);
    if (lastShown == todayStr) return; // already shown today

    await prefs.setString(_popupShownKey, todayStr);
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        await MotivationalPopup.show(context, currentState: _currentState);
      }
    }
  }

  Future<void> _showShareDialogIfNeeded() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) await OptionalShareDialog.show(context, autoShow: true);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final userName = AuthService.instance.currentUser?.displayName;

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      // ── Fixed AppBar (brand + icons — never scrolls) ───────────────────
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.favorite_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 4),
            const Text(
              'Mental Wellness',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider?.themeMode == ThemeMode.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: Colors.white,
            ),
            onPressed: themeProvider?.toggleTheme,
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, AppConstants.settingsRoute),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            tooltip: 'Help',
            onPressed: () async {
              await OnboardingService().resetOnboarding();
              if (mounted) OnboardingManager().showOnboarding(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign out',
            onPressed: () async {
              await AuthService.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(
                    context, AppConstants.loginRoute);
              }
            },
          ),
        ],
      ),

      // ── Scrollable body ────────────────────────────────────────────────
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: FadeTransition(
            opacity: _fadeCtrl,
            child: Column(
              children: [
                // Welcome card (scrolls with content)
                HeroWelcomeCard(
                  username: userName,
                  todayMood: _todayMood,
                  affirmation: _affirmation.isEmpty
                      ? AppConstants.generalAffirmations[0]
                      : _affirmation,
                ),

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

      floatingActionButton: _buildFAB(),
    );
  }

  // ── Medical card ────────────────────────────────────────────────────────────

  Widget _buildMedicalCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.red.shade50, Colors.orange.shade50]),
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
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.favorite_border,
                    color: Colors.red.shade700, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('We\'re Here for You',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () =>
                    setState(() => _medicalGuidanceDismissed = true),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'We\'ve noticed patterns that suggest you might benefit from additional support.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppConstants.locationRoute),
            icon: const Icon(Icons.location_on, size: 18),
            label: const Text('Find Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
    final info = _stateInfo(stateStr);
    final color = info['color'] as Color;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.65)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 1)
                  ],
                ),
                child: Icon(info['icon'] as IconData,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info['title'] as String,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    if (_confidence != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _confidence!.level
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface(context).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Suggestions:',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...(info['suggestions'] as List<String>).map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              size: 14, color: color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(s,
                                style: const TextStyle(
                                    fontSize: 12, height: 1.45)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _stateInfo(String state) {
    switch (state) {
      case 'calm':
        return {
          'title': 'You\'re Feeling Calm',
          'icon': Icons.spa,
          'color': Colors.green,
          'suggestions': ['Keep up the good work', 'Practice gratitude', 'Maintain your routine'],
        };
      case 'stressed':
        return {
          'title': 'Feeling Stressed',
          'icon': Icons.psychology,
          'color': Colors.orange,
          'suggestions': ['Try breathing exercises', 'Take a short break', 'Listen to calm audio'],
        };
      case 'restless':
        return {
          'title': 'Feeling Restless',
          'icon': Icons.directions_run,
          'color': Colors.amber,
          'suggestions': ['Go for a walk', 'Practice mindfulness', 'Try breathing techniques'],
        };
      case 'lowEnergy':
        return {
          'title': 'Low Energy Detected',
          'icon': Icons.battery_2_bar,
          'color': Colors.blue,
          'suggestions': ['Get some rest', 'Stay hydrated', 'Light exercise might help'],
        };
      case 'distressed':
        return {
          'title': 'Feeling Distressed',
          'icon': Icons.sentiment_very_dissatisfied,
          'color': Colors.red,
          'suggestions': ['Reach out for support', 'Practice self-care', 'Consider professional help'],
        };
      default:
        return {
          'title': 'Neutral State',
          'icon': Icons.sentiment_neutral,
          'color': AppTheme.primary,
          'suggestions': ['Stay mindful', 'Check in with yourself', 'Use wellness tools'],
        };
    }
  }

  // ── Quick actions ──────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    // "Emotional Release" label (was incorrectly "Journal" before)
    const actions = [
      {'icon': Icons.self_improvement, 'label': 'Emotional\nRelease', 'route': AppConstants.releaseRoute,    'color': Colors.purple},
      {'icon': Icons.favorite,         'label': 'Gratitude',           'route': AppConstants.gratitudeRoute,  'color': Colors.pink},
      {'icon': Icons.insights,         'label': 'Mood',                'route': AppConstants.moodRoute,       'color': Colors.blue},
      {'icon': Icons.air,              'label': 'Breathe',             'route': AppConstants.breathingRoute,  'color': Colors.cyan},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: List.generate(actions.length, (i) {
              final action = actions[i];
              final color = action['color'] as Color;
              return Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (i * 80)),
                  curve: Curves.easeOut,
                  builder: (_, v, child) => Transform.scale(
                    scale: 0.85 + (v * 0.15),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                color.withValues(alpha: 0.85),
                                color.withValues(alpha: 0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: color.withValues(alpha: 0.28),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(action['icon'] as IconData,
                                  color: Colors.white, size: 26),
                              const SizedBox(height: 8),
                              Text(
                                action['label'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3),
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
    final tools = [
      {
        'icon': Icons.book_outlined,
        'title': 'Daily Journal',
        'subtitle': 'Permanent personal diary',
        'route': AppConstants.journalRoute,
        'gradient': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      },
      {
        'icon': Icons.format_quote_rounded,
        'title': 'Affirmations',
        'subtitle': 'Mood-matched encouragement',
        'route': AppConstants.affirmationsRoute,
        'gradient': [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
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
        'subtitle': 'Support resources nearby',
        'route': AppConstants.locationRoute,
        'gradient': [Colors.teal, Colors.green],
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wellness Tools',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...List.generate(tools.length, (i) {
            final tool = tools[i];
            final gradient = tool['gradient'] as List<Color>;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 480 + (i * 80)),
              curve: Curves.easeOut,
              builder: (_, v, child) => Transform.translate(
                offset: Offset(0, 18 * (1 - v)),
                child: Opacity(opacity: v, child: child),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      BehaviorTracker.instance.trackInteraction();
                      Navigator.pushNamed(
                          context, tool['route'] as String);
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient
                              .map((c) => c.withValues(alpha: 0.13))
                              .toList(),
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: gradient[0].withValues(alpha: 0.28)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradient),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                    color: gradient[0].withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3))
                              ],
                            ),
                            child: Icon(tool['icon'] as IconData,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tool['title'] as String,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text(
                                  tool['subtitle'] as String,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary(context)),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              size: 14,
                              color: AppTheme.textSecondary(context)),
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
      scale: CurvedAnimation(parent: _fadeCtrl, curve: Curves.elasticOut),
      child: FloatingActionButton.extended(
        onPressed: () => OptionalShareDialog.show(context),
        backgroundColor: AppTheme.primary,
        elevation: 8,
        icon: const Icon(Icons.edit_note, color: Colors.white),
        label: const Text('Share Feelings',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
