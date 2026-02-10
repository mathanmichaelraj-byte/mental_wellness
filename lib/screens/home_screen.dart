import 'package:flutter/material.dart';
import '../services/emotional_inference_service.dart';
import '../services/database_service.dart';
import '../models/behavior_pattern.dart';
import '../models/emotional_confidence.dart';
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
      _loadEmotionalState();
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Mental Wellness',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your companion for emotional well-being',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),
                if (_confidence != null && _confidence!.canEscalateToMedical() && !_medicalGuidanceDismissed)
                  _buildMedicalGuidanceCard(),
                _buildEmotionalStateCard(),
                const SizedBox(height: 30),
                const Text(
                  'Wellness Tools',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildFeatureGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalGuidanceCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade100, Colors.orange.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Important Notice',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _medicalGuidanceDismissed = true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Based on consistent patterns, you may benefit from professional support. This is not a diagnosis.',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LocationFinderScreen()),
            ),
            icon: const Icon(Icons.location_on),
            label: const Text('Find Professional Help'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EmotionalInferenceService.instance.getStateDescription(_currentState),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on your patterns',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (_confidence != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(_confidence!.level),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _confidence!.level.name.toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          ...EmotionalInferenceService.instance
              .getSuggestions(_currentState, _confidence?.level ?? ConfidenceLevel.low)
              .map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 18, color: Colors.blue[400]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(s, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        ),
                      ],
                    ),
                  )),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildFeatureCard(
          'Mood History',
          Icons.timeline,
          [Colors.green.shade400, Colors.green.shade600],
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodHistoryScreen())),
        ),
        _buildFeatureCard(
          'Emotional Release',
          Icons.edit_note,
          [Colors.purple.shade400, Colors.purple.shade600],
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmotionalReleaseScreen())),
        ),
        _buildFeatureCard(
          'Calm Audio',
          Icons.music_note,
          [Colors.orange.shade400, Colors.orange.shade600],
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalmAudioScreen())),
        ),
        _buildFeatureCard(
          'Find Calm Places',
          Icons.location_on,
          [Colors.red.shade400, Colors.red.shade600],
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationFinderScreen())),
        ),
        _buildFeatureCard(
          'Breathing',
          Icons.air,
          [Colors.teal.shade400, Colors.teal.shade600],
          () => _showBreathingDialog(),
        ),
      ],
    );
  }

  Color _getConfidenceColor(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.low:
        return Colors.grey;
      case ConfidenceLevel.medium:
        return Colors.blue;
      case ConfidenceLevel.high:
        return Colors.orange;
    }
  }

  Widget _buildFeatureCard(String title, IconData icon, List<Color> gradient, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBreathingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.air, color: Colors.teal),
            SizedBox(width: 8),
            Text('Breathing Exercise'),
          ],
        ),
        content: const Text(
          'Breathe in for 4 seconds\nHold for 4 seconds\nBreathe out for 4 seconds\n\nRepeat 5 times',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
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
