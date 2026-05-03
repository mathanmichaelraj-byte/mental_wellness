import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/media/audio_service.dart';
import '../../services/local/behavior_tracker.dart';
import '../../utils/app_theme.dart';

class CalmAudioScreen extends StatefulWidget {
  const CalmAudioScreen({super.key});

  @override
  State<CalmAudioScreen> createState() => _CalmAudioScreenState();
}

class _CalmAudioScreenState extends State<CalmAudioScreen> 
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  String _currentTrack = '';
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

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
    )..forward();
  }

  @override
  void dispose() {
    AudioService.instance.stop();
    _pulseController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _playTrack(String track, Future<void> Function() playFunction) async {
    BehaviorTracker.instance.trackInteraction();
    await AudioService.instance.stop();
    await playFunction();
    setState(() {
      _isPlaying = true;
      _currentTrack = track;
    });
  }

  Future<void> _pause() async {
    await AudioService.instance.pause();
    setState(() => _isPlaying = false);
  }

  Future<void> _stop() async {
    await AudioService.instance.stop();
    setState(() {
      _isPlaying = false;
      _currentTrack = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        title: const Text('Calm Audio'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero)
              .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Your Peace',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Calming sounds to help you relax and center yourself',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 32),
                if (_currentTrack.isNotEmpty) _buildNowPlayingCard(),
                Text(
                  'Choose a track',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTrackCard(
                  'Calm Meditation',
                  'Peaceful meditation sounds to quiet your mind',
                  Icons.self_improvement,
                  AppTheme.gradient,
                  () => _playTrack('Calm Meditation', AudioService.instance.playCalm),
                  index: 0,
                ),
                _buildTrackCard(
                  'Rain Sounds',
                  'Gentle rain sounds for relaxation',
                  Icons.air,
                  AppTheme.gradient,
                  () => _playTrack('Rain Sounds', AudioService.instance.playBreathing),
                  index: 1,
                ),
                _buildTrackCard(
                  'Nature Sounds',
                  'Relaxing natural ambience from peaceful settings',
                  Icons.nature,
                  AppTheme.gradient,
                  () => _playTrack('Nature Sounds', AudioService.instance.playNature),
                  index: 2,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.1),
                        AppTheme.success.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.headphones,
                          color: AppTheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tip:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use headphones for the best calming experience',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary(context),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNowPlayingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppTheme.gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [AppTheme.shadow],
      ),
      child: Column(
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.05).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.music_note : Icons.pause,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Now Playing',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentTrack,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                onPressed: _isPlaying 
                    ? _pause 
                    : () => _playTrack(
                        _currentTrack, 
                        _getCurrentTrackFunction(),
                      ),
              ),
              const SizedBox(width: 24),
              _buildControlButton(
                icon: Icons.stop,
                onPressed: _stop,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: 36,
        color: AppTheme.primary,
        onPressed: onPressed,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildTrackCard(
    String title,
    String description,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap, {
    required int index,
  }) {
    final isCurrentTrack = _currentTrack == title;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * AppConstants.staggerDelayMs)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrentTrack 
                ? AppTheme.primary.withOpacity(0.5)
                : Colors.grey.shade200,
            width: isCurrentTrack ? 2 : 1,
          ),
          boxShadow: [
            if (isCurrentTrack)
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: -5,
              )
            else
              AppTheme.shadow,
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.colors.first.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary(context),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCurrentTrack && _isPlaying
                          ? AppTheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCurrentTrack && _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_outline,
                      color: isCurrentTrack 
                          ? AppTheme.primary 
                          : AppTheme.textSecondary(context),
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> Function() _getCurrentTrackFunction() {
    switch (_currentTrack) {
      case 'Calm Meditation':
        return AudioService.instance.playCalm;
      case 'Rain Sounds':
        return AudioService.instance.playBreathing;
      case 'Nature Sounds':
        return AudioService.instance.playNature;
      default:
        return AudioService.instance.playCalm;
    }
  }
}
