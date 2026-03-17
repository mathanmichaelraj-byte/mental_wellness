import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import '../utils/app_theme.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.semanticLabel,
  });

  final String title;
  final String description;
  final IconData icon;
  final String semanticLabel;
}


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {

  static const String _onboardingKey = 'onboarding_complete';

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Welcome to Mental Wellness',
      description: 'Your personal companion for emotional well-being',
      icon: Icons.favorite_rounded,
      semanticLabel: 'Heart icon representing personal wellness',
    ),
    _OnboardingPage(
      title: 'Non-Intrusive Support',
      description:
          'We understand your emotions through gentle patterns, not questions',
      icon: Icons.psychology_rounded,
      semanticLabel: 'Psychology icon representing gentle emotional support',
    ),
    _OnboardingPage(
      title: 'Calming Resources',
      description: 'Access soothing audio and nearby calming locations',
      icon: Icons.spa_rounded,
      semanticLabel: 'Spa icon representing calming resources',
    ),
  ];


  late final PageController _pageController;
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;

  int _currentPage = 0;
  bool _isNavigating = false; 

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }


  void _onPageChanged(int index) {
    if (!mounted) return;
    setState(() => _currentPage = index);
    _fadeController
      ..reset()
      ..forward();
    _scaleController
      ..reset()
      ..forward();
  }

  Future<void> _completeOnboarding() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (_) {
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  bool get _isLastPage => _currentPage == _pages.length - 1;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                opacity: _isLastPage ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: Semantics(
                  button: true,
                  label: 'Skip onboarding',
                  child: TextButton(
                    onPressed: _isLastPage ? null : _completeOnboarding,
                    child: const Text('Skip'),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) =>
                    _OnboardingPageView(
                  page: _pages[index],
                  fadeController: _fadeController,
                  scaleController: _scaleController,
                ),
              ),
            ),

            _DotIndicator(
              pageCount: _pages.length,
              currentPage: _currentPage,
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                  CurvedAnimation(
                      parent: _fadeController, curve: Curves.easeOut),
                ),
                child: Semantics(
                  button: true,
                  label: _isLastPage ? 'Get started' : 'Next page',
                  child: ElevatedButton(
                    onPressed: _isNavigating
                        ? null
                        : (_isLastPage ? _completeOnboarding : _goToNextPage),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppTheme.primary.withValues(alpha: 0.6),
                    ),
                    child: _isNavigating
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isLastPage ? 'Get Started' : 'Next'),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({
    required this.page,
    required this.fadeController,
    required this.scaleController,
  });

  final _OnboardingPage page;
  final AnimationController fadeController;
  final AnimationController scaleController;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon circle
            ScaleTransition(
              scale: Tween<double>(begin: 0.75, end: 1.0).animate(
                CurvedAnimation(
                    parent: scaleController, curve: Curves.elasticOut),
              ),
              child: Semantics(
                image: true,
                label: page.semanticLabel,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.28),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(page.icon, size: 58, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Text(
              page.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              page.description,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppTheme.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({
    required this.pageCount,
    required this.currentPage,
  });

  final int pageCount;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Page ${currentPage + 1} of $pageCount',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          final isActive = currentPage == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primary : AppTheme.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}