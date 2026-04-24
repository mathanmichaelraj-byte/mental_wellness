import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/behavior_tracker.dart';
import '../../utils/app_theme.dart';

class BreathingTechnique {
  final String name;
  final String description;
  final String purpose;
  final int inhale;
  final int hold;
  final int exhale;
  final int cycles;
  final IconData icon;
  final Gradient gradient;

  BreathingTechnique({
    required this.name,
    required this.description,
    required this.purpose,
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.cycles,
    required this.icon,
    required this.gradient,
  });
}

class BreathingTechniquesScreen extends StatefulWidget {
  const BreathingTechniquesScreen({super.key});

  @override
  State<BreathingTechniquesScreen> createState() => _BreathingTechniquesScreenState();
}

class _BreathingTechniquesScreenState extends State<BreathingTechniquesScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
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
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final techniques = [
      BreathingTechnique(
        name: '4-7-8 Relaxation',
        description: 'Calms nervous system, reduces anxiety',
        purpose: 'Stress & Anxiety Relief',
        inhale: 4,
        hold: 7,
        exhale: 8,
        cycles: 4,
        icon: Icons.nightlight,
        gradient: AppTheme.gradient,
      ),
      BreathingTechnique(
        name: 'Box Breathing',
        description: 'Used by Navy SEALs for focus',
        purpose: 'Focus & Concentration',
        inhale: 4,
        hold: 4,
        exhale: 4,
        cycles: 5,
        icon: Icons.crop_square,
        gradient: AppTheme.gradient,
      ),
      BreathingTechnique(
        name: 'Anger Release',
        description: 'Quick exhale releases tension',
        purpose: 'Anger Management',
        inhale: 3,
        hold: 2,
        exhale: 6,
        cycles: 6,
        icon: Icons.whatshot,
        gradient: AppTheme.gradient,
      ),
      BreathingTechnique(
        name: 'Grief Comfort',
        description: 'Gentle rhythm for emotional pain',
        purpose: 'Sadness & Grief',
        inhale: 5,
        hold: 3,
        exhale: 7,
        cycles: 5,
        icon: Icons.favorite,
        gradient: AppTheme.gradient,
      ),
      BreathingTechnique(
        name: 'Energy Boost',
        description: 'Increases alertness and energy',
        purpose: 'Low Energy',
        inhale: 2,
        hold: 1,
        exhale: 2,
        cycles: 10,
        icon: Icons.bolt,
        gradient: AppTheme.gradient,
      ),
      BreathingTechnique(
        name: 'Sleep Preparation',
        description: 'Slows heart rate for better sleep',
        purpose: 'Insomnia & Restlessness',
        inhale: 4,
        hold: 6,
        exhale: 8,
        cycles: 6,
        icon: Icons.bedtime,
        gradient: AppTheme.gradient,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        title: const Text('Breathing Techniques'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero)
              .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut)),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.space16),
            itemCount: techniques.length,
            itemBuilder: (context, index) {
              final technique = techniques[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * AppConstants.staggerDelayMs)),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _TechniqueCard(
                        technique: technique,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BreathingExerciseScreen(technique: technique),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  final BreathingTechnique technique;
  final VoidCallback onTap;

  const _TechniqueCard({required this.technique, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.space16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.space16),
                decoration: BoxDecoration(
                  gradient: technique.gradient,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                ),
                child: Icon(technique.icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: AppTheme.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      technique.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,color: AppTheme.textPrimary(context)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      technique.purpose,
                      style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(context), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      technique.description,
                      style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(context)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textPrimary(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class BreathingExerciseScreen extends StatefulWidget {
  final BreathingTechnique technique;

  const BreathingExerciseScreen({super.key, required this.technique});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _currentCycle = 0;
  int _countdown = 0;
  String _phase = 'Ready';
  bool _isRunning = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startExercise() {
    BehaviorTracker.instance.trackInteraction();
    setState(() {
      _isRunning = true;
      _currentCycle = 1;
      _startInhale();
    });
  }

  void _startInhale() {
    setState(() {
      _phase = 'Breathe In';
      _countdown = widget.technique.inhale;
    });
    _animController.duration = Duration(seconds: widget.technique.inhale);
    _animController.forward(from: 0);
    _runTimer(widget.technique.inhale, _startHold);
  }

  void _startHold() {
    setState(() {
      _phase = 'Hold';
      _countdown = widget.technique.hold;
    });
    _runTimer(widget.technique.hold, _startExhale);
  }

  void _startExhale() {
    setState(() {
      _phase = 'Breathe Out';
      _countdown = widget.technique.exhale;
    });
    _animController.duration = Duration(seconds: widget.technique.exhale);
    _animController.reverse(from: 1);
    _runTimer(widget.technique.exhale, _nextCycle);
  }

  void _nextCycle() {
    if (_currentCycle < widget.technique.cycles) {
      setState(() => _currentCycle++);
      _startInhale();
    } else {
      _complete();
    }
  }

  void _complete() {
    _timer?.cancel();
    _animController.stop();
    setState(() {
      _isRunning = false;
      _phase = 'Complete!';
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
        title: const Text('Well Done!'),
        content: const Text('You completed the breathing exercise. How do you feel?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Finish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startExercise();
            },
            child: const Text('Repeat'),
          ),
        ],
      ),
    );
  }

  void _runTimer(int seconds, VoidCallback onComplete) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        onComplete();
      }
    });
  }

  void _stopExercise() {
    _timer?.cancel();
    _animController.stop();
    setState(() {
      _isRunning = false;
      _phase = 'Ready';
      _currentCycle = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        title: Text(widget.technique.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        final size = 150 + (_animController.value * 100);
                        return ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                            CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
                          ),
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              gradient: widget.technique.gradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.technique.gradient.colors.first.withValues(alpha: 0.4 * _animController.value),
                                  blurRadius: 40 + (_animController.value * 20),
                                  spreadRadius: 5 + (_animController.value * 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _countdown > 0 ? '$_countdown' : '',
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                    Text(
                      _phase,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppTheme.space16),
                    if (_isRunning)
                      Text(
                        'Cycle $_currentCycle of ${widget.technique.cycles}',
                        style: TextStyle(fontSize: 18, color: AppTheme.textPrimary(context)),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.space24),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(parent: _animController, curve: Curves.easeOut),
                ),
                child: _isRunning
                    ? ElevatedButton(
                        onPressed: _stopExercise,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
                        ),
                        child: const Text('Stop', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      )
                    : ElevatedButton(
                        onPressed: _startExercise,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
                        ),
                        child: const Text('Start Exercise', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
