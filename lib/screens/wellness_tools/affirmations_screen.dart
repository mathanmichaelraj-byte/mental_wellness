import '../../core/constants/app_constants.dart';
import '../../services/emotional_inference_service.dart';
import '../../services/mood_affirmation_service.dart';
import '../../utils/app_theme.dart';
import 'package:flutter/material.dart';
/// Browsable affirmations screen — shows all mood-appropriate affirmations
/// and lets the user cycle through them or see the full list.
class AffirmationsScreen extends StatefulWidget {
  /// Pre-select a state when navigating from the home screen.
  final EmotionalState? initialState;

  const AffirmationsScreen({super.key, this.initialState});

  @override
  State<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen>
    with TickerProviderStateMixin {
  late EmotionalState _selectedState;
  late List<String> _affirmations;
  int _featuredIndex = 0;
  late AnimationController _cardCtrl;
  late Animation<double> _cardFade;

  static const List<Map<String, dynamic>> _stateOptions = [
    {'label': 'Calm',       'state': EmotionalState.calm,       'color': Color(0xFFA5D6A7), 'icon': Icons.spa},
    {'label': 'Neutral',    'state': EmotionalState.neutral,    'color': Color(0xFF80DEEA), 'icon': Icons.sentiment_neutral},
    {'label': 'Restless',   'state': EmotionalState.restless,   'color': Color(0xFFFFCC80), 'icon': Icons.bolt},
    {'label': 'Stressed',   'state': EmotionalState.stressed,   'color': Color(0xFFFFAB91), 'icon': Icons.psychology},
    {'label': 'Low Energy', 'state': EmotionalState.lowEnergy,  'color': Color(0xFFB0BEC5), 'icon': Icons.battery_2_bar},
    {'label': 'Distressed', 'state': EmotionalState.distressed, 'color': Color(0xFF90CAF9), 'icon': Icons.favorite_border},
  ];

  @override
  void initState() {
    super.initState();
    _selectedState = widget.initialState ?? EmotionalState.neutral;
    _affirmations =
        MoodAffirmationService.instance.getAllForState(_selectedState)
          ..addAll(AppConstants.generalAffirmations);

    _cardCtrl = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _cardFade =
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    super.dispose();
  }

  void _switchState(EmotionalState state) {
    setState(() {
      _selectedState = state;
      _featuredIndex = 0;
      _affirmations =
          MoodAffirmationService.instance.getAllForState(state)
            ..addAll(AppConstants.generalAffirmations);
    });
    _cardCtrl.forward(from: 0);
  }

  void _nextAffirmation() {
    _cardCtrl.reverse().then((_) {
      setState(() {
        _featuredIndex = (_featuredIndex + 1) % _affirmations.length;
      });
      _cardCtrl.forward();
    });
  }

  Color get _stateColor {
    final opt = _stateOptions.firstWhere(
      (o) => o['state'] == _selectedState,
      orElse: () => _stateOptions[1],
    );
    return opt['color'] as Color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        title: const Text('Affirmations'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood state filter chips
            const Text('Choose your mood:',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _stateOptions.map((opt) {
                final selected = _selectedState == opt['state'];
                final color = opt['color'] as Color;
                return GestureDetector(
                  onTap: () =>
                      _switchState(opt['state'] as EmotionalState),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.25)
                          : AppTheme.surface(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? color : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(opt['icon'] as IconData,
                            size: 15,
                            color: selected
                                ? color
                                : AppTheme.textSecondary(context)),
                        const SizedBox(width: 6),
                        Text(opt['label'] as String,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: selected
                                    ? color
                                    : AppTheme.textSecondary(context))),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Featured affirmation card
            FadeTransition(
              opacity: _cardFade,
              child: GestureDetector(
                onTap: _nextAffirmation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _stateColor.withValues(alpha: 0.35),
                        _stateColor.withValues(alpha: 0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: _stateColor.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.format_quote_rounded,
                          size: 36,
                          color: _stateColor.withValues(alpha: 0.7)),
                      const SizedBox(height: 16),
                      Text(
                        _affirmations[_featuredIndex],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app_outlined,
                              size: 14,
                              color: AppTheme.textSecondary(context)),
                          const SizedBox(width: 6),
                          Text('Tap for next',
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      AppTheme.textSecondary(context))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Page dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _affirmations.length.clamp(0, 8),
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _featuredIndex % 8 ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _featuredIndex % 8
                        ? _stateColor
                        : _stateColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Full list
            Text('All affirmations (${_affirmations.length})',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            ...List.generate(_affirmations.length, (i) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surface(context),
                  borderRadius: BorderRadius.circular(16),
                  border: i == _featuredIndex
                      ? Border.all(color: _stateColor, width: 1.5)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _stateColor.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _stateColor)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _affirmations[i],
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
