import 'package:flutter/material.dart';
import '../services/emotional_inference_service.dart';
import '../models/emotional_confidence.dart';
import '../utils/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/optional_share_dialog.dart';
import '../widgets/ui_components.dart';
import '../services/behavior_tracker.dart';

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
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _fadeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this)..forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEmotionalState();
      _showDialogIfNeeded();
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
    final r = context.responsive;
    
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => OptionalShareDialog.show(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.edit_note),
        label: const Text('Share Feelings'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.background, Color(0xFFF5F5F5), AppTheme.neutralLight],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadEmotionalState,
            color: AppTheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: r.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: r.hp(2)),
                  HeaderSection(),
                  SizedBox(height: r.hp(4)),
                  if (_confidence != null && _confidence!.canEscalateToMedical() && !_medicalGuidanceDismissed)
                    MedicalGuidanceCard(
                      fadeController: _fadeController,
                      onDismiss: () => setState(() => _medicalGuidanceDismissed = true),
                    ),
                  EmotionalStateCard(
                    state: _currentState,
                    confidence: _confidence,
                    fadeController: _fadeController,
                    pulseController: _pulseController,
                  ),
                  SizedBox(height: r.hp(4)),
                  Text('Wellness Tools', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: r.hp(2)),
                  WellnessToolsGrid(responsive: r),
                  SizedBox(height: r.hp(3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
