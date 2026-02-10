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

class _HomeScreenState extends State<HomeScreen> {
  EmotionalState _currentState = EmotionalState.neutral;
  EmotionalConfidence? _confidence;
  bool _medicalGuidanceDismissed = false;

  @override
  void initState() {
    super.initState();
    _loadEmotionalState();
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Mental Wellness',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
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
              const SizedBox(height: 32),
              if (_confidence != null && _confidence!.canEscalateToMedical() && !_medicalGuidanceDismissed)
                _buildMedicalGuidanceCard(),
              _buildEmotionalStateCard(),
              const SizedBox(height: 32),
              Text(
                'Wellness Tools',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalGuidanceCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Important Notice',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _medicalGuidanceDismissed = true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Based on consistent patterns, you may benefit from professional support. This is not a diagnosis.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationFinderScreen()),
              ),
              icon: const Icon(Icons.location_on),
              label: const Text('Find Professional Help'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warning,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionalStateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EmotionalInferenceService.instance.getStateDescription(_currentState),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on your patterns',
                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              if (_confidence != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(_confidence!.level),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _confidence!.level.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          ...EmotionalInferenceService.instance
              .getSuggestions(_currentState, _confidence?.level ?? ConfidenceLevel.low)
              .map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 14, color: AppTheme.success),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            s,
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  )),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      ('Emotional Analysis', Icons.insights, AppTheme.primaryGradient, () {
        BehaviorTracker.instance.trackFeatureUsage('emotional_analysis');
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodHistoryScreen()));
      }),
      ('Emotional Release', Icons.edit_note, AppTheme.successGradient, () {
        BehaviorTracker.instance.trackFeatureUsage('emotional_release');
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EmotionalReleaseScreen()));
      }),
      ('Calm Audio', Icons.music_note, AppTheme.warningGradient, () {
        BehaviorTracker.instance.trackFeatureUsage('calm_audio');
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CalmAudioScreen()));
      }),
      ('Find Places', Icons.location_on, const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFEF4444)]), () {
        BehaviorTracker.instance.trackFeatureUsage('location_finder');
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationFinderScreen()));
      }),
      ('Breathing', Icons.air, const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0891B2)]), () {
        BehaviorTracker.instance.trackFeatureUsage('breathing');
        _showBreathingDialog();
      }),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final (title, icon, gradient, onTap) = features[index];
        return _buildFeatureCard(title, icon, gradient, onTap);
      },
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, Gradient gradient, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [AppTheme.softShadow],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.low:
        return Colors.grey.shade600;
      case ConfidenceLevel.medium:
        return AppTheme.primary;
      case ConfidenceLevel.high:
        return AppTheme.warning;
    }
  }

  void _showBreathingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.air, color: Color(0xFF14B8A6), size: 28),
            SizedBox(width: 12),
            Text('Breathing Exercise', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'Breathe in for 4 seconds\nHold for 4 seconds\nBreathe out for 4 seconds\n\nRepeat 5 times',
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
