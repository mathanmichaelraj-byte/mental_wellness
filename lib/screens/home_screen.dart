import 'package:flutter/material.dart';
import '../services/emotional_inference_service.dart';
import '../services/behavior_tracker.dart';
import '../models/emotional_confidence.dart';
import '../utils/app_theme.dart';
import 'mood_history_screen.dart';
import 'emotional_release_screen.dart';
import 'location_finder_screen.dart';
import 'calm_audio_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadEmotionalState();
    
    // Pulse animation for confidence badge
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // Fade in animation for cards
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadEmotionalState() async {
    final state = await EmotionalInferenceService.instance.inferEmotionalState();
    final confidence = await EmotionalInferenceService.instance.calculateConfidence();
    setState(() {
      _currentState = state;
      _confidence = confidence;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Subtle animated background gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.background,
              Color(0xFFF1F5F9),
              AppTheme.surface.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadEmotionalState,
            color: AppTheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  if (_confidence != null && 
                      _confidence!.canEscalateToMedical() && 
                      !_medicalGuidanceDismissed)
                    _buildMedicalGuidanceCard(),
                  _buildEmotionalStateCard(),
                  const SizedBox(height: 32),
                  Text(
                    'Wellness Tools',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureGrid(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mental Wellness',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your companion for emotional well-being',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalGuidanceCard() {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.warning.withOpacity(0.15),
              AppTheme.warning.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.warning.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.warning.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.warning,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [AppTheme.glowShadow(AppTheme.warning)],
                  ),
                  child: const Icon(
                    Icons.favorite_outline,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'We\'re Here for You',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 22),
                  onPressed: () => setState(() => _medicalGuidanceDismissed = true),
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'We\'ve noticed patterns that suggest you might benefit from additional support. Remember, seeking help is a sign of strength, not weakness.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LocationFinderScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.location_on),
                    label: const Text('Explore Support Options'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warning,
                      foregroundColor: AppTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                // Show more information dialog
                _showSupportInfoDialog();
              },
              icon: Icon(Icons.info_outline, size: 18),
              label: const Text('Why am I seeing this?'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalStateCard() {
    final stateColor = AppTheme.getStateColor(_currentState.toString());
    
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: stateColor.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            AppTheme.softShadow,
            BoxShadow(
              color: stateColor.withOpacity(0.05),
              blurRadius: 30,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        stateColor.withOpacity(0.2),
                        stateColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getStateIcon(_currentState),
                    color: stateColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        EmotionalInferenceService.instance
                            .getStateDescription(_currentState),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Based on your patterns',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_confidence != null) _buildConfidenceBadge(),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 20),
            ...EmotionalInferenceService.instance
                .getSuggestions(
                  _currentState,
                  _confidence?.level ?? ConfidenceLevel.low,
                )
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: AppTheme.successGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              AppTheme.glowShadow(AppTheme.success),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            s,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                            ),
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

  Widget _buildConfidenceBadge() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.getConfidenceColor(_confidence!.level.name),
              AppTheme.getConfidenceColor(_confidence!.level.name).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getConfidenceColor(_confidence!.level.name)
                  .withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Text(
          _confidence!.level.name.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      _FeatureData(
        'Emotional Analysis',
        Icons.insights,
        AppTheme.primaryGradient,
        () {
          BehaviorTracker.instance.trackFeatureUsage('emotional_analysis');
          Navigator.push(
            context,
            _createRoute(const MoodHistoryScreen()),
          );
        },
      ),
      _FeatureData(
        'Emotional Release',
        Icons.edit_note,
        AppTheme.successGradient,
        () {
          BehaviorTracker.instance.trackFeatureUsage('emotional_release');
          Navigator.push(
            context,
            _createRoute(const EmotionalReleaseScreen()),
          );
        },
      ),
      _FeatureData(
        'Calm Audio',
        Icons.music_note,
        AppTheme.audioGradient,
        () {
          BehaviorTracker.instance.trackFeatureUsage('calm_audio');
          Navigator.push(
            context,
            _createRoute(const CalmAudioScreen()),
          );
        },
      ),
      _FeatureData(
        'Find Places',
        Icons.location_on,
        AppTheme.locationGradient,
        () {
          BehaviorTracker.instance.trackFeatureUsage('location_finder');
          Navigator.push(
            context,
            _createRoute(const LocationFinderScreen()),
          );
        },
      ),
      _FeatureData(
        'Breathing',
        Icons.air,
        AppTheme.breathingGradient,
        () {
          BehaviorTracker.instance.trackFeatureUsage('breathing');
          _showBreathingDialog();
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.0, // Perfect square
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(
          feature.title,
          feature.icon,
          feature.gradient,
          feature.onTap,
          index,
        );
      },
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (value * 0.05),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                AppTheme.softShadow,
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 56, color: Colors.white),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 0.3,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStateIcon(EmotionalState state) {
    switch (state) {
      case EmotionalState.calm:
        return Icons.self_improvement;
      case EmotionalState.restless:
        return Icons.trending_up;
      case EmotionalState.stressed:
        return Icons.warning_amber_rounded;
      case EmotionalState.lowEnergy:
        return Icons.battery_2_bar;
      case EmotionalState.distressed:
        return Icons.emergency;
      default:
        return Icons.sentiment_neutral;
    }
  }

  void _showBreathingDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.breathingGradient.colors.first.withOpacity(0.1),
                AppTheme.breathingGradient.colors.last.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.breathingGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.air,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Breathing Exercise',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Follow this simple pattern:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildBreathingStep('Breathe in', '4 seconds', Icons.arrow_downward),
              _buildBreathingStep('Hold', '4 seconds', Icons.pause),
              _buildBreathingStep('Breathe out', '4 seconds', Icons.arrow_upward),
              const SizedBox(height: 24),
              const Text(
                'Repeat 5 times for best results',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Got it!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingStep(String action, String duration, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.success, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            duration,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('About This Notice'),
        content: const Text(
          'This app uses behavioral patterns to understand your emotional state. '
          'When we notice consistent patterns that may indicate you could benefit '
          'from professional support, we show this notice.\n\n'
          'This is not a diagnosis. It\'s a gentle reminder that help is available '
          'when you need it.',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        const curve = Curves.easeOut;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        var offsetAnimation = animation.drive(tween);
        var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: curve),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}

class _FeatureData {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  _FeatureData(this.title, this.icon, this.gradient, this.onTap);
}