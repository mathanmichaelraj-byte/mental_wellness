import 'package:flutter/material.dart';
import 'package:mental_wellness/services/onboarding_service.dart';
import '../core/constants/app_constants.dart';
import '../services/emotional_inference_service.dart';
import '../services/firebase/auth_service.dart';
import '../models/emotional_confidence.dart';
import '../utils/app_theme.dart';
import '../widgets/optional_share_dialog.dart';
import '../services/behavior_tracker.dart';
import '../main.dart';
import '../widgets/onboarding/onboarding_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  EmotionalState _currentState = EmotionalState.neutral;
  EmotionalConfidence? _confidence;
  bool _medicalGuidanceDismissed = false;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: AppConstants.pulseAnimationMs),
      vsync: this,
    )..repeat(reverse: true);
    _fadeController = AnimationController(
      duration: Duration(milliseconds: AppConstants.fadeAnimationMs),
      vsync: this,
    )..forward();
    _slideController = AnimationController(
      duration: Duration(milliseconds: AppConstants.slideAnimationMs),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEmotionalState();
      _showDialogIfNeeded();
      _slideController.forward();
      OnboardingManager().showOnboarding(context);
    });
  }
  
  Future<void> _showDialogIfNeeded() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      await OptionalShareDialog.show(context, autoShow: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadEmotionalState() async {
    BehaviorTracker.instance.trackInteraction();
    final state = await EmotionalInferenceService.instance.inferEmotionalState();
    final confidence = await EmotionalInferenceService.instance.calculateConfidence();
    setState(() {
      _currentState = state;
      _confidence = confidence;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final userName = AuthService.instance.currentUser?.displayName ?? 'Friend';
    
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, themeProvider),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeController,
              child: Column(
                children: [
                  _buildWelcomeSection(context, userName),
                  if (_confidence != null && _confidence!.canEscalateToMedical() && !_medicalGuidanceDismissed)
                    _buildMedicalCard(),
                  _buildEmotionalCard(),
                  _buildQuickActions(context),
                  _buildWellnessTools(context),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }
  
  Widget _buildAppBar(BuildContext context, ThemeProvider? themeProvider) {
    return SliverAppBar(
      expandedHeight: MediaQuery.heightOf(context) * 0.05,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primaryLight],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(themeProvider?.themeMode == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: Colors.white),
          onPressed: themeProvider?.toggleTheme,
        ),
        IconButton(
          icon: Icon(Icons.settings, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, AppConstants.settingsRoute),
        ),
        IconButton(
          icon: Icon(Icons.help_outline, color: Colors.white),
          onPressed: () async {
            await OnboardingService().resetOnboarding();
            if (mounted) OnboardingManager().showOnboarding(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            await AuthService.instance.signOut();
            if (mounted) Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context, String userName) {
    final String? username;
  final Map<String, dynamic>? todayMood;
  final logged = todayMood != null;
    final moodIdx = logged ? todayMood!['mood'] as int : null;
    final mood = moodIdx != null ? _moods[moodIdx] : null;

  const _moods = [
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
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    
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
  
  Widget _buildMedicalCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
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
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.favorite_border, color: Colors.red.shade700, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'We\'re Here for You',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _medicalGuidanceDismissed = true),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'We\'ve noticed patterns that suggest you might benefit from additional support.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppConstants.locationRoute),
            icon: Icon(Icons.location_on),
            label: Text('Find Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmotionalCard() {
    final stateStr = _currentState.toString().split('.').last;
    final stateInfo = _getStateInfo(stateStr);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [stateInfo['color'].withOpacity(0.1), stateInfo['color'].withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stateInfo['color'].withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: stateInfo['color'].withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [stateInfo['color'], stateInfo['color'].withOpacity(0.7)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: stateInfo['color'].withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(stateInfo['icon'], color: Colors.white, size: 32),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stateInfo['title'],
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    if (_confidence != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: stateInfo['color'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _confidence!.level.toString().split('.').last.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: stateInfo['color'],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface(context).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggestions:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                ...stateInfo['suggestions'].map<Widget>((s) => Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: stateInfo['color']),
                      SizedBox(width: 8),
                      Expanded(child: Text(s, style: TextStyle(fontSize: 13, height: 1.4))),
                    ],
                  ),
                )).toList(),
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
  
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.edit_note, 'label': 'Journal', 'route': AppConstants.releaseRoute, 'color': Colors.purple},
      {'icon': Icons.favorite, 'label': 'Gratitude', 'route': AppConstants.gratitudeRoute, 'color': Colors.pink},
      {'icon': Icons.insights, 'label': 'Mood', 'route': AppConstants.moodRoute, 'color': Colors.blue},
      {'icon': Icons.air, 'label': 'Breathe', 'route': AppConstants.breathingRoute, 'color': Colors.cyan},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: actions.map((action) {
              final index = actions.indexOf(action);
              return Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (value * 0.2),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          BehaviorTracker.instance.trackInteraction();
                          Navigator.pushNamed(context, action['route'] as String);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                (action['color'] as Color).withOpacity(0.8),
                                (action['color'] as Color).withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (action['color'] as Color).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(action['icon'] as IconData, color: Colors.white, size: 28),
                              SizedBox(height: 8),
                              Text(
                                action['label'] as String,
                                style: TextStyle(
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
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessTools(BuildContext context) {
    final tools = [
      {'icon': Icons.music_note, 'title': 'Calm Audio', 'subtitle': 'Relaxing sounds', 'route': AppConstants.audioRoute, 'gradient': [Colors.indigo, Colors.purple]},
      {'icon': Icons.location_on, 'title': 'Find Places', 'subtitle': 'Support resources', 'route': AppConstants.locationRoute, 'gradient': [Colors.teal, Colors.green]},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Wellness Tools',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 8),
          ...tools.map((tool) {
            final index = tools.indexOf(tool);
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 500 + (index * 100)),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      BehaviorTracker.instance.trackInteraction();
                      Navigator.pushNamed(context, tool['route'] as String);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: (tool['gradient'] as List<Color>).map((c) => c.withOpacity(0.15)).toList(),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (tool['gradient'] as List<Color>)[0].withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: tool['gradient'] as List<Color>),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (tool['gradient'] as List<Color>)[0].withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(tool['icon'] as IconData, color: Colors.white, size: 28),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tool['title'] as String,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: 4),
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
                          Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
      child: FloatingActionButton.extended(
        onPressed: () => OptionalShareDialog.show(context),
        backgroundColor: AppTheme.primary,
        elevation: 8,
        icon: Icon(Icons.edit_note, color: Colors.white),
        label: Text(
          'Share Feelings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
