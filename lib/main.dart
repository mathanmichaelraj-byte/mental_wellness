import 'package:flutter/material.dart';
import 'package:mental_wellness/screens/quick_actions/breathing_techniques_screen.dart';
import 'package:mental_wellness/screens/quick_actions/gratitude_screen.dart';
import 'package:mental_wellness/screens/quick_actions/mood_history_screen.dart';
import 'package:mental_wellness/screens/wellness_tools/calm_audio_screen.dart';
import 'package:mental_wellness/screens/wellness_tools/emotional_release_screen.dart';
import 'package:mental_wellness/screens/wellness_tools/location_finder_screen.dart';
import 'package:mental_wellness/services/local/behavior_tracker.dart';
import 'package:mental_wellness/services/local/database_service.dart';
import 'package:mental_wellness/services/notifications/affirmation_service.dart';
import 'package:mental_wellness/services/notifications/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'screens/auth_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quick_actions/journal_screen.dart';
import 'screens/wellness_tools/affirmations_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await DatabaseService.instance.database;
  await NotificationService.instance.initialize();
  await AffirmationService.instance.initialize();

  BehaviorTracker.instance.startSession();
  runApp(const MentalWellnessApp());
}

// ── App root ──────────────────────────────────────────────────────────────────

class MentalWellnessApp extends StatefulWidget {
  const MentalWellnessApp({super.key});

  @override
  State<MentalWellnessApp> createState() => _MentalWellnessAppState();
}

class _MentalWellnessAppState extends State<MentalWellnessApp>
    with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      BehaviorTracker.instance.endSession();
    } else if (state == AppLifecycleState.resumed) {
      BehaviorTracker.instance.startSession();
    }
  }

  Future<void> toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', newMode == ThemeMode.dark);
    setState(() => _themeMode = newMode);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      toggleTheme: toggleTheme,
      themeMode: _themeMode,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: const AuthWrapper(),
        routes: {
          AppConstants.loginRoute:       (_) => const LoginScreen(),
          AppConstants.signupRoute:      (_) => const SignUpScreen(),
          AppConstants.settingsRoute:    (_) => const SettingsScreen(),
          AppConstants.homeRoute:        (_) => const HomeScreen(),
          AppConstants.moodRoute:        (_) => const MoodHistoryScreen(),
          AppConstants.releaseRoute:     (_) => const EmotionalReleaseScreen(),
          AppConstants.journalRoute:     (_) => const JournalScreen(),
          AppConstants.affirmationsRoute:(_) => const AffirmationsScreen(),
          AppConstants.audioRoute:       (_) => const CalmAudioScreen(),
          AppConstants.locationRoute:    (_) => const LocationFinderScreen(),
          AppConstants.breathingRoute:   (_) => const BreathingTechniquesScreen(),
          AppConstants.gratitudeRoute:   (_) => const GratitudeScreen(),
        },
      ),
    );
  }
}

// ── ThemeProvider ─────────────────────────────────────────────────────────────

class ThemeProvider extends InheritedWidget {
  final void Function() toggleTheme;
  final ThemeMode themeMode;

  const ThemeProvider({
    super.key,
    required this.toggleTheme,
    required this.themeMode,
    required super.child,
  });

  static ThemeProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeProvider>();

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) =>
      themeMode != oldWidget.themeMode;
}
