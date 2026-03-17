import 'package:flutter/material.dart';
import 'package:mental_wellness/services/onboarding_service.dart';
import '../services/emotional_inference_service.dart';
import '../models/emotional_confidence.dart';
import '../utils/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/optional_share_dialog.dart';
import '../widgets/ui_components.dart';
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
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this)..forward();
    _slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
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
    final r = context.responsive;
    final themeProvider = ThemeProvider.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(themeProvider?.themeMode == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
            onPressed: themeProvider?.toggleTheme,
            tooltip: 'Toggle theme',
          ),
          IconButton(
            onPressed: () async {
                  await OnboardingService().resetOnboarding();
                  if (mounted) {
                    OnboardingManager().showOnboarding(context);
                  }
            }, 
            icon: Icon(Icons.help),
            tooltip: "Help",
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
        child: FloatingActionButton.extended(
          onPressed: () => OptionalShareDialog.show(context),
          backgroundColor: AppTheme.primary,
          elevation: 8,
          icon: Icon(Icons.edit_note, color: Colors.white),
          label: Text('Share Feelings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.background(context),
              AppTheme.surface(context).withOpacity(0.3),
              AppTheme.background(context),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadEmotionalState,
            color: AppTheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      _buildHeader(context),
                      SizedBox(height: 32),
                      if (_confidence != null && _confidence!.canEscalateToMedical() && !_medicalGuidanceDismissed)
                        _buildMedicalCard(),
                      _buildEmotionalCard(),
                      SizedBox(height: 32),
                      _buildToolsSection(context, r),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [AppTheme.shadow],
              ),
              child: Icon(Icons.favorite, color: Colors.white, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mental Wellness',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your emotional companion',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildMedicalCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: MedicalGuidanceCard(
              fadeController: _fadeController,
              onDismiss: () => setState(() => _medicalGuidanceDismissed = true),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEmotionalCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: EmotionalStateCard(
              state: _currentState,
              confidence: _confidence,
              fadeController: _fadeController,
              pulseController: _pulseController,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildToolsSection(BuildContext context, dynamic r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.apps_rounded, color: AppTheme.primary, size: 24),
            SizedBox(width: 12),
            Text(
              'Wellness Tools',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        WellnessToolsGrid(responsive: r),
      ],
    );
  }
}
