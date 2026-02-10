# Mental Wellness App - Complete Documentation

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Features](#features)
4. [Technical Implementation](#technical-implementation)
5. [API Reference](#api-reference)
6. [Customization Guide](#customization-guide)

## Project Overview

### Concept
A non-intrusive mental wellness application that infers emotional states through behavior patterns rather than direct questioning, providing calming resources and support.

### Key Differentiators
- **No direct emotional questioning** - reduces cognitive load
- **Behavior-based inference** - passive monitoring
- **Rule-based logic** - no complex AI needed
- **Privacy-first** - all data local
- **Free APIs only** - suitable for academic projects

### Target Users
- Individuals seeking emotional self-awareness
- People experiencing stress or anxiety
- Students learning about mental wellness
- Anyone wanting non-intrusive emotional support

## Architecture

### Design Pattern
**Clean Architecture** with separation of concerns:
- **Models**: Data structures
- **Services**: Business logic
- **Screens**: UI components
- **Utils**: Helper functions

### Data Flow
```
User Interaction → Screen → Service → Database
                              ↓
                         Inference Engine
                              ↓
                         Suggestions
```

### Database Schema

#### mood_entries
- id (INTEGER PRIMARY KEY)
- moodScore (INTEGER 1-10)
- notes (TEXT, optional)
- timestamp (TEXT ISO8601)

#### emotional_notes
- id (INTEGER PRIMARY KEY)
- content (TEXT)
- createdAt (TEXT ISO8601)
- expiresAt (TEXT ISO8601)

#### behavior_patterns
- id (INTEGER PRIMARY KEY)
- timestamp (TEXT ISO8601)
- appOpenCount (INTEGER)
- screenTimeSeconds (INTEGER)
- timeOfDay (TEXT: 'day' or 'late_night')
- interactionSpeed (INTEGER 1-10)

## Features

### 1. Emotional Inference System

**How it works:**
```dart
// Tracks behavior patterns
- App open frequency
- Screen time duration
- Time of day usage
- Interaction speed

// Applies rules
if (high frequency + fast interactions) → Restless
if (late night + high frequency) → Stressed
if (low frequency + short sessions) → Low Energy
if (balanced patterns) → Calm
```

**States:**
- Calm
- Restless
- Stressed
- Low Energy
- Neutral

### 2. Mood Tracking

**Input:** 1-10 scale slider
**Output:** 
- Mood score saved
- Hormone levels calculated
- Suggestions generated
- Notification sent

**Hormone Calculation:**
```dart
Serotonin = (moodScore / 10) × 100
Dopamine = ((moodScore + 2) / 12) × 100
Oxytocin = ((moodScore + 1) / 11) × 100

Categories:
- Low: < 40%
- Normal: 40-70%
- High: > 70%
```

### 3. Emotional Release

**Purpose:** Safe space for temporary emotional expression

**Features:**
- Write notes without judgment
- Auto-delete after 1-48 hours
- Manual delete option
- No permanent storage

**Use case:** Express difficult emotions knowing they'll disappear

### 4. Location Finder

**Technology:** Google Maps Flutter plugin

**Features:**
- Embedded map view
- Current location marker
- Nearby calming places
- Distance calculation
- Open in Google Maps app

**Location Types:**
- Parks
- Meditation centers
- Hospitals
- Nature spots
- Spiritual places

### 5. Calm Audio

**Purpose:** Audio therapy for relaxation

**Tracks:**
- Calm meditation
- Breathing guide
- Nature sounds

**Controls:**
- Play/Pause
- Stop
- Volume control

### 6. Notifications

**Types:**
- Daily reminders
- Mood tracking confirmations
- Gentle suggestions

**Implementation:** Flutter Local Notifications

## Technical Implementation

### Services

#### DatabaseService
```dart
// Singleton pattern
DatabaseService.instance

// Methods
- insertMoodEntry(MoodEntry)
- getMoodEntries({limit})
- insertEmotionalNote(EmotionalNote)
- getActiveEmotionalNotes()
- deleteExpiredNotes()
- insertBehaviorPattern(BehaviorPattern)
- getRecentBehaviorPatterns({days})
```

#### EmotionalInferenceService
```dart
// Infer emotional state
inferEmotionalState() → EmotionalState

// Get description
getStateDescription(EmotionalState) → String

// Get suggestions
getSuggestions(EmotionalState) → List<String>
```

#### LocationService
```dart
// Get current position
getCurrentLocation() → Position?

// Calculate distance
calculateDistance(lat1, lon1, lat2, lon2) → double

// Get locations
getCalmingLocations() → List<Map>

// Create markers
createMarkers(locations) → Set<Marker>
```

#### NotificationService
```dart
// Initialize
initialize()

// Show instant notification
showInstantNotification(title, body)

// Schedule daily reminder
scheduleDailyReminder()

// Cancel all
cancelAllNotifications()
```

#### AudioService
```dart
// Play tracks
playCalm()
playBreathing()
playNature()

// Controls
pause()
stop()
setVolume(double)
```

### Models

#### MoodEntry
```dart
{
  int? id,
  int moodScore,
  String? notes,
  DateTime timestamp
}
```

#### EmotionalNote
```dart
{
  int? id,
  String content,
  DateTime createdAt,
  DateTime expiresAt
}
```

#### BehaviorPattern
```dart
{
  int? id,
  DateTime timestamp,
  int appOpenCount,
  int screenTimeSeconds,
  String timeOfDay,
  int interactionSpeed
}
```

## API Reference

### HormoneCalculator

```dart
// Calculate hormone levels
HormoneLevel calculate(int moodScore)

// Get suggestions
List<String> getSuggestions(HormoneLevel levels)
```

### HormoneLevel

```dart
class HormoneLevel {
  double serotonin;
  double dopamine;
  double oxytocin;
  
  String getSerotoninLevel() // 'Low', 'Normal', 'High'
  String getDopamineLevel()
  String getOxytocinLevel()
}
```

## Customization Guide

### 1. Adjust Emotional Inference Rules

Edit: `lib/services/emotional_inference_service.dart`

```dart
// Modify thresholds
if (avgOpenCount > 10 && highSpeedCount > patterns.length * 0.5) {
  return EmotionalState.restless;
}

// Add new states
enum EmotionalState { 
  calm, restless, stressed, lowEnergy, neutral, 
  anxious // NEW
}
```

### 2. Change Hormone Formulas

Edit: `lib/utils/hormone_calculator.dart`

```dart
static HormoneLevel calculate(int moodScore) {
  final serotonin = (moodScore / 10) * 100; // Modify formula
  final dopamine = ((moodScore + 2) / 12) * 100;
  final oxytocin = ((moodScore + 1) / 11) * 100;
  
  return HormoneLevel(...);
}
```

### 3. Add More Calming Locations

Edit: `lib/services/location_service.dart`

```dart
List<Map<String, dynamic>> getCalmingLocations() {
  return [
    {'name': 'New Park', 'lat': 28.xxx, 'lng': 77.xxx, 'type': 'Park'},
    // Add more locations
  ];
}
```

### 4. Customize Suggestions

Edit: `lib/services/emotional_inference_service.dart`

```dart
List<String> getSuggestions(EmotionalState state) {
  switch (state) {
    case EmotionalState.restless:
      return [
        'Your custom suggestion',
        'Another suggestion',
      ];
  }
}
```

### 5. Change Notification Schedule

Edit: `lib/services/notification_service.dart`

```dart
// Change from daily to custom interval
await _notifications.periodicallyShow(
  1,
  'Title',
  'Body',
  RepeatInterval.hourly, // or weekly, daily
  details,
);
```

### 6. Modify UI Theme

Edit: `lib/main.dart`

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.purple, // Change color
  ),
  useMaterial3: true,
),
```

## Performance Considerations

### Database Optimization
- Indexed timestamp columns
- Limit query results
- Auto-cleanup expired notes

### Memory Management
- Dispose controllers in screens
- Stop audio on screen exit
- Release map controller

### Battery Optimization
- No continuous GPS tracking
- Local notifications only
- Minimal background processing

## Privacy & Security

### Data Storage
- All data stored locally in SQLite
- No cloud sync
- No external data transmission

### Permissions
- Location: Only when using map feature
- Notifications: User can disable
- Storage: For local database only

### User Control
- Delete mood entries (can be added)
- Delete emotional notes anytime
- Clear all data (can be added)

## Testing Checklist

- [ ] Onboarding flow completes
- [ ] Mood tracking saves correctly
- [ ] Mood history displays entries
- [ ] Emotional notes auto-delete
- [ ] Behavior patterns record
- [ ] Emotional state inference works
- [ ] Hormone calculations correct
- [ ] Notifications appear
- [ ] Location permission requested
- [ ] Map displays (with API key)
- [ ] Audio plays (with files)

## Troubleshooting

### Common Issues

**Issue:** App crashes on startup
**Solution:** Run `flutter clean && flutter pub get`

**Issue:** Map doesn't show
**Solution:** Add Google Maps API key in AndroidManifest.xml

**Issue:** Audio doesn't play
**Solution:** Add MP3 files to assets/audio/ folder

**Issue:** Notifications don't appear
**Solution:** Check Android notification permissions

**Issue:** Location permission denied
**Solution:** Grant location permission in device settings

## Future Enhancements

### Easy Additions
- Export mood data to CSV
- Dark mode theme
- More audio tracks
- Breathing animation
- Weekly mood reports

### Medium Complexity
- Mood trends graph
- Custom location categories
- Reminder time customization
- Multiple language support

### Advanced Features
- Cloud backup (Firebase)
- Social support features
- Advanced analytics
- Wearable integration

## Academic Project Tips

### For Presentation
1. Demonstrate non-intrusive design
2. Show behavior pattern tracking
3. Explain rule-based inference
4. Highlight privacy features
5. Discuss scalability

### For Report
- Include architecture diagrams
- Document database schema
- Explain algorithms
- Show code snippets
- Discuss challenges faced

### For Demo
- Prepare test data
- Show all features
- Explain technical choices
- Discuss future scope
- Answer questions confidently

## Credits & Resources

### Flutter Packages
- sqflite, geolocator, google_maps_flutter
- audioplayers, flutter_local_notifications
- All open-source and free

### Design Inspiration
- Material Design 3
- Mental health best practices
- Non-intrusive UX patterns

### Educational Purpose
This project is designed for learning and awareness.
Not intended for medical diagnosis or treatment.

---

**Version:** 1.0.0  
**Last Updated:** 2024  
**License:** Educational Use
