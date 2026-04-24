class AppConstants {
  // App Info
  static const String appName = 'Mental Wellness';
  static const String appTagline = 'Your emotional companion';
  static const String version = '2.2.0';

  // Database
  static const String dbName = 'mental_wellness.db';
  static const int dbVersion = 4; // bumped: added journal_entries table

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
  static const String releaseRoute = '/release';   // Emotional Release (temp notes)
  static const String journalRoute = '/journal';   // Daily Journal (permanent)
  static const String affirmationsRoute = '/affirmations';
  static const String audioRoute = '/audio';
  static const String locationRoute = '/location';
  static const String breathingRoute = '/breathing';
  static const String gratitudeRoute = '/gratitude';

  // Feature Keys
  static const String moodAnalysisFeature = 'mood_analysis';
  static const String emotionalReleaseFeature = 'emotional_release';
  static const String journalFeature = 'journal';
  static const String affirmationsFeature = 'affirmations';
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

  // Notification Settings
  static const String affirmationChannelId = 'affirmation_channel';
  static const String affirmationChannelName = 'Daily Affirmations';
  static const String affirmationChannelDesc = 'Positive daily affirmations';
  static const int affirmationNotificationId = 1;
  static const int defaultAffirmationHour = 9;
  static const int defaultAffirmationMinute = 0;

  // Mood-aware affirmation pools — selected by EmotionalState
  static const Map<String, List<String>> moodAffirmations = {
    // calm / great
    'calm': [
      'Your peace is a gift — protect it.',
      'Stillness is a superpower.',
      'You are in harmony with yourself today.',
      'Calm is not the absence of storms — it is choosing peace within them.',
      'You radiate tranquillity and strength.',
    ],
    // neutral
    'neutral': [
      'Every day is a fresh start.',
      'You are capable of amazing things.',
      'You are enough, just as you are.',
      'Your story is important and worth telling.',
      'Small steps still move you forward.',
    ],
    // restless / anxious
    'restless': [
      'Take a breath — this moment will pass.',
      'You have navigated uncertainty before and you will again.',
      'Your feelings are valid; they do not have the final word.',
      'One small, gentle step is enough right now.',
      'You are stronger than the restlessness you feel.',
    ],
    // stressed
    'stressed': [
      'You are doing more than enough.',
      'Rest is productive — give yourself permission.',
      'This pressure is temporary; your resilience is permanent.',
      'It is okay to slow down.',
      'You have overcome stress before — you will now.',
    ],
    // low energy
    'lowEnergy': [
      'It is okay to rest; restoration is not laziness.',
      'Even on low-energy days you still show up.',
      'Your worth is not measured by your productivity.',
      'Be gentle with yourself today.',
      'Small acts of self-care are acts of courage.',
    ],
    // distressed
    'distressed': [
      'You are not alone — support exists and is close.',
      'Reaching out is the bravest thing you can do.',
      'This moment is hard, but it is not permanent.',
      'You deserve care and kindness, especially from yourself.',
      'You have survived every difficult day so far.',
    ],
  };

  // Generic fallback pool (used when no state is inferred yet)
  static const List<String> generalAffirmations = [
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
    // Daily rotating affirmations (used for daily notification or home greeting)
  static const List<String> dailyAffirmations = [
    'Today is a new chance to care for yourself.',
    'You have everything you need to handle today.',
    'Small progress today leads to big change tomorrow.',
    'You deserve patience, kindness, and understanding.',
    'Focus on what you can control and release the rest.',
    'Your effort today matters, no matter how small.',
    'You are growing even when it feels slow.',
    'Take things one step at a time — that is enough.',
    'Today, choose peace over pressure.',
    'You are capable of facing whatever comes today.',
    'Give yourself credit for how far you have come.',
    'Each day is an opportunity to reset and begin again.',
    'You are stronger than yesterday.',
    'It is okay to move at your own pace.',
    'You can handle today with courage and calm.',
    'Trust yourself — you are learning every day.',
    'Your presence matters in this world.',
    'Today, allow yourself to breathe and be.',
    'You are worthy of a calm and meaningful day.',
    'Every sunrise brings new possibilities.',
    'Take a moment to appreciate yourself today.',
    'You are allowed to rest without guilt.',
    'Kindness toward yourself changes everything.',
    'You are building resilience one day at a time.',
    'Today is a step forward in your journey.',
    'You deserve moments of peace today.',
    'Let today be guided by patience and hope.',
    'Your growth is happening, even silently.',
    'You have survived every tough day so far.',
    'Today, choose to be gentle with yourself.',
  ];
}
