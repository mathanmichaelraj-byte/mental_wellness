import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/affirmation_service.dart';
import 'services/behavior_tracker.dart';
import 'screens/auth_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quick_actions/mood_history_screen.dart';
import 'screens/wellness_tools/emotional_release_screen.dart';
import 'screens/wellness_tools/calm_audio_screen.dart';
import 'screens/wellness_tools/location_finder_screen.dart';
import 'screens/quick_actions/breathing_techniques_screen.dart';
import 'screens/quick_actions/gratitude_screen.dart';
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

class MentalWellnessApp extends StatefulWidget {
  const MentalWellnessApp({super.key});

  @override
  State<MentalWellnessApp> createState() => _MentalWellnessAppState();
}

class _MentalWellnessAppState extends State<MentalWellnessApp> with WidgetsBindingObserver {
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
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      BehaviorTracker.instance.endSession();
    } else if (state == AppLifecycleState.resumed) {
      BehaviorTracker.instance.startSession();
    }
  }
  
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', newMode == ThemeMode.dark);
    setState(() {
      _themeMode = newMode;
    });
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
        home: AuthWrapper(),
        routes: {
          AppConstants.loginRoute: (context) => LoginScreen(),
          AppConstants.signupRoute: (context) => SignUpScreen(),
          AppConstants.settingsRoute: (context) => SettingsScreen(),
          AppConstants.homeRoute: (context) => HomeScreen(),
          AppConstants.moodRoute: (context) => MoodHistoryScreen(),
          AppConstants.releaseRoute: (context) => EmotionalReleaseScreen(),
          AppConstants.audioRoute: (context) => CalmAudioScreen(),
          AppConstants.journalRoute: (context) => EmotionalReleaseScreen(), // Reusing for now
          AppConstants.affirmationsRoute: (context) => Placeholder(),
          AppConstants.locationRoute: (context) => LocationFinderScreen(),
          AppConstants.breathingRoute: (context) => BreathingTechniquesScreen(),
          AppConstants.gratitudeRoute: (context) => GratitudeScreen(),
        },
      ),
    );
  }
}

class ThemeProvider extends InheritedWidget {
  final Function() toggleTheme;
  final ThemeMode themeMode;

  const ThemeProvider({
    super.key,
    required this.toggleTheme,
    required this.themeMode,
    required super.child,
  });

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}