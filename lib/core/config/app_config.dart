import '../constants/app_constants.dart';

class AppConfig {
  // Environment
  static const bool isProduction = true;
  static const bool enableLogging = !isProduction;
  
  // Database
  static String get databaseName => AppConstants.dbName;
  static int get databaseVersion => AppConstants.dbVersion;
  
  // Features
  static const bool enableNotifications = true;
  static const bool enableOnboarding = true;
  static const bool enableDarkMode = true;
  
  // Timing
  static Duration get sessionTimeout => Duration(minutes: 30);
  static Duration get noteExpiry => Duration(hours: AppConstants.noteExpiryHours);
  static Duration get gratitudeRetention => Duration(days: AppConstants.gratitudeRetentionDays);
  
  // UI
  static Duration get fadeAnimation => Duration(milliseconds: AppConstants.fadeAnimationMs);
  static Duration get slideAnimation => Duration(milliseconds: AppConstants.slideAnimationMs);
  static Duration get pulseAnimation => Duration(milliseconds: AppConstants.pulseAnimationMs);
  
  // Limits
  static const int maxNoteLength = 500;
  static const int maxGratitudeLength = 300;
  static const int minSessionDuration = AppConstants.minSessionSeconds;
}
