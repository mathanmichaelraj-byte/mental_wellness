import 'package:flutter/material.dart';
import '../services/emotional_inference_service.dart';
import '../services/database_service.dart';
import '../models/behavior_pattern.dart';
import '../models/emotional_confidence.dart';
import 'mood_tracking_screen.dart';
import 'mood_history_screen.dart';
import 'emotional_release_screen.dart';
import 'location_finder_screen.dart';
import 'calm_audio_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  EmotionalState _currentState = EmotionalState.neutral;
  EmotionalConfidence? _confidence;
  DateTime? _sessionStart;
  int _appOpenCount = 0;
  bool _medicalGuidanceDismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionStart = DateTime.now();
    _appOpenCount++;
    _loadEmotionalState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordBehaviorPattern();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _recordBehaviorPattern();
    } else if (state == AppLifecycleState.resumed) {
      _sessionStart = DateTime.now();
      _appOpenCount++;
    }
  }

  Future<void> _loadEmotionalState() async {
    final state = await EmotionalInferenceService.instance.inferEmotionalState();
    final confidence = await EmotionalInferenceService.instance.calculateConfidence();
    setState(() {
      _currentState = state;
      _confidence = confidence;
    });
  }

  Future<void> _recordBehaviorPattern() async {
    if (_sessionStart == null) return;
    
    final duration = DateTime.now().difference(_sessionStart!).inSeconds;
    final hour = DateTime.now().hour;
    final timeOfDay = hour >= 22 || hour < 6 ? 'late_night' : 'day';
    
    final pattern = BehaviorPattern(
      timestamp: DateTime.now(),
      appOpenCount: _appOpenCount,
      screenTimeSeconds: duration,
      timeOfDay: timeOfDay,
      interactionSpeed: 5,
    );
    
    await DatabaseService.instance.insertBehaviorPattern(pattern);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Wellness'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_confidence != null && _confidence!.canEscalateToMedical() && !_medicalGuidanceDismissed)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Important Notice',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => setState(() => _medicalGuidanceDismissed = true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Based on consistent patterns over time, you may benefit from professional support. This is not a diagnosis, but a suggestion based on observed patterns.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LocationFinderScreen()),
                        ),
                        icon: const Icon(Icons.location_on, size: 18),
                        label: const Text('Find Professional Help'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            EmotionalInferenceService.instance.getStateDescription(_currentState),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_confidence != null)
                          Chip(
                            label: Text(
                              _confidence!.level.name.toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: _getConfidenceColor(_confidence!.level),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...EmotionalInferenceService.instance
                        .getSuggestions(_currentState, _confidence?.level ?? ConfidenceLevel.low)
                        .map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('• $s', style: const TextStyle(color: Colors.grey)),
                            )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  'Track Mood',
                  Icons.mood,
                  Colors.blue,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodTrackingScreen())),
                ),
                _buildFeatureCard(
                  'Mood History',
                  Icons.history,
                  Colors.green,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodHistoryScreen())),
                ),
                _buildFeatureCard(
                  'Emotional Release',
                  Icons.edit_note,
                  Colors.purple,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmotionalReleaseScreen())),
                ),
                _buildFeatureCard(
                  'Calm Audio',
                  Icons.music_note,
                  Colors.orange,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalmAudioScreen())),
                ),
                _buildFeatureCard(
                  'Find Calm Places',
                  Icons.location_on,
                  Colors.red,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationFinderScreen())),
                ),
                _buildFeatureCard(
                  'Breathing Exercise',
                  Icons.air,
                  Colors.teal,
                  () => _showBreathingDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.low:
        return Colors.grey.shade300;
      case ConfidenceLevel.medium:
        return Colors.blue.shade200;
      case ConfidenceLevel.high:
        return Colors.orange.shade300;
    }
  }

  Widget _buildFeatureCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showBreathingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Breathing Exercise'),
        content: const Text('Breathe in for 4 seconds\nHold for 4 seconds\nBreathe out for 4 seconds\n\nRepeat 5 times'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
