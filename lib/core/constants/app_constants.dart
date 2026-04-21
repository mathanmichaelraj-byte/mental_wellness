class AppConstants {
  // App Info
  static const String appName = 'Mental Wellness';
  static const String appTagline = 'Your emotional companion';
  static const String version = '2.1.0';
  
  // Database
  static const String dbName = 'mental_wellness.db';
  static const int dbVersion = 3;
  
  // Session
  static const int minSessionSeconds = 5;
  static const int maxInteractionSpeed = 10;
  
  // Time Periods
  static const int defaultHistoryDays = 7;
  static const int noteExpiryHours = 24;
  static const int gratitudeRetentionDays = 30;
  
  // Animation Durations (milliseconds)
  static const int fadeAnimationMs = 600;
  static const int slideAnimationMs = 800;
  static const int pulseAnimationMs = 2000;
  static const int staggerDelayMs = 100;
  
  // Routes
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String settingsRoute = '/settings';
  static const String homeRoute = '/home';
  static const String moodRoute = '/mood';
  static const String releaseRoute = '/release';
  static const String audioRoute = '/audio';
  static const String locationRoute = '/location';
  static const String breathingRoute = '/breathing';
  static const String gratitudeRoute = '/gratitude';
  
  // Feature Keys
  static const String moodAnalysisFeature = 'mood_analysis';
  static const String emotionalReleaseFeature = 'emotional_release';
  static const String calmAudioFeature = 'calm_audio';
  static const String locationFinderFeature = 'location_finder';
  static const String breathingExercisesFeature = 'breathing_exercises';
  static const String gratitudeJournalFeature = 'gratitude_journal';
  
  // Gratitude Categories
  static const List<String> gratitudeCategories = [
    'people',
    'moments',
    'self',
    'nature',
    'other',
  ];
  
  // Time of Day
  static const Map<String, String> timeOfDayLabels = {
    'lateNight': 'Late Night',
    'morning': 'Morning',
    'afternoon': 'Afternoon',
    'evening': 'Evening',
  };
  
  // Affirmations
  static const List<String> dailyAffirmations = [
    'You are worthy of love and respect.',
    'Today is full of possibilities.',
    'You have the strength to overcome any challenge.',
    'Your feelings are valid and important.',
    'You are making progress, even when it doesn\'t feel like it.',
    'You deserve peace and happiness.',
    'Your mental health matters.',
    'You are not alone in your journey.',
    'Every day is a fresh start.',
    'You are capable of amazing things.',
    'Your presence makes a difference.',
    'You are enough, just as you are.',
    'It\'s okay to take time for yourself.',
    'You are growing and learning every day.',
    'Your story is important and worth sharing.',
    'You have the power to create positive change.',
    'You are resilient and brave.',
    'Your emotions don\'t define you.',
    'You deserve kindness, especially from yourself.',
    'You are on the right path.',
    'Your well-being is a priority.',
    'You have overcome difficult times before.',
    'You are worthy of good things.',
    'Your journey is unique and valuable.',
    'You are stronger than you think.',
    'Today, you choose peace.',
    'You are doing your best, and that\'s enough.',
    'Your mental health journey is valid.',
    'You deserve to feel good.',
    'You are creating a life you love.',
  ];
  
  // Notification Settings
  static const String affirmationChannelId = 'affirmation_channel';
  static const String affirmationChannelName = 'Daily Affirmations';
  static const String affirmationChannelDesc = 'Positive daily affirmations';
  static const int affirmationNotificationId = 1;
  static const int defaultAffirmationHour = 9;
  static const int defaultAffirmationMinute = 0;
}
