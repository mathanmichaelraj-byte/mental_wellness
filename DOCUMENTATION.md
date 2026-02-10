# Mental Wellness App - Complete Documentation

## Project Overview

A Flutter-based mobile application designed to provide emotional support through passive behavioral tracking and location-based calming assistance. The app uses a confidence-based approach to gradually understand user emotions without intrusive questioning.

---

## Core Philosophy

### Non-Intrusive Design
- No forced emotional input
- Automatic pattern recognition
- Gradual confidence building
- User always in control

### Privacy-First Approach
- All data stored locally
- No cloud synchronization
- No background tracking
- Complete user privacy

---

## Features

### 1. Automatic Emotional Tracking

The app passively monitors:
- App usage frequency
- Session duration
- Time-of-day patterns
- Interaction speed

**No manual mood input required** - the system learns from behavior.

---

### 2. Confidence-Based Support System

#### Low Confidence (0-40%)
- Neutral, calming responses
- General wellness tips
- No specific recommendations

#### Medium Confidence (40-70%)
- Wellness suggestions
- Calming audio recommendations
- Breathing exercises
- Nearby calming locations

#### High Confidence (70%+)
- Medical-aligned guidance
- Professional help recommendations
- Requires 5+ consistent signals
- Never provides diagnosis

---

### 3. Multi-Signal Analysis

The system analyzes:
- **Behavioral Patterns**: 7+ days of usage data
- **Mood Variance**: Emotional stability tracking
- **Late Night Activity**: Sleep pattern indicators
- **Usage Frequency**: Stress indicators
- **Session Length**: Engagement patterns

---

### 4. Emotional States

Detected states:
- **Calm**: Balanced usage patterns
- **Restless**: High frequency, fast interactions
- **Stressed**: Late night usage, high frequency
- **Low Energy**: Infrequent use, short sessions
- **Distressed**: Multiple severe indicators
- **Neutral**: Insufficient data

---

### 5. Location-Based Support

#### OpenStreetMap Integration
- Free OSM tiles (no API key)
- In-app map visualization
- User location marker
- Nearby place markers

#### Place Categories
- Mental health clinics
- Therapists
- Parks and nature spots
- Meditation centers
- Hospitals
- Spiritual places

#### Navigation
- Tap marker for details
- "Open in Google Maps" button
- External navigation (no billing)

---

### 6. Calming Features

#### Audio Therapy
- Calm meditation tracks
- Breathing guides
- Nature sounds
- Play/pause/stop controls

#### Emotional Release
- Temporary note writing
- Auto-delete (1-48 hours)
- Safe expression space
- Manual delete option

#### Breathing Exercises
- 4-4-4 technique
- Guided instructions
- Quick access dialog

---

## Technical Architecture

### Technology Stack
- **Framework**: Flutter 3.10.4+
- **Language**: Dart
- **Database**: SQLite (sqflite)
- **Maps**: flutter_map (OpenStreetMap)
- **Location**: Geolocator
- **Audio**: audioplayers
- **Notifications**: flutter_local_notifications

### Project Structure
```
lib/
├── main.dart
├── models/
│   ├── mood_entry.dart
│   ├── emotional_note.dart
│   ├── behavior_pattern.dart
│   └── emotional_confidence.dart
├── services/
│   ├── database_service.dart
│   ├── emotional_inference_service.dart
│   ├── location_service.dart
│   ├── audio_service.dart
│   └── notification_service.dart
├── screens/
│   ├── welcome_screen.dart
│   ├── home_screen.dart
│   ├── mood_history_screen.dart
│   ├── emotional_release_screen.dart
│   ├── calm_audio_screen.dart
│   └── location_finder_screen.dart
└── utils/
    └── hormone_calculator.dart
```

---

## Database Schema

### mood_entries
- id (INTEGER PRIMARY KEY)
- moodScore (INTEGER 1-10)
- notes (TEXT, optional)
- timestamp (TEXT ISO8601)

### emotional_notes
- id (INTEGER PRIMARY KEY)
- content (TEXT)
- createdAt (TEXT ISO8601)
- expiresAt (TEXT ISO8601)

### behavior_patterns
- id (INTEGER PRIMARY KEY)
- timestamp (TEXT ISO8601)
- appOpenCount (INTEGER)
- screenTimeSeconds (INTEGER)
- timeOfDay (TEXT: 'day' or 'late_night')
- interactionSpeed (INTEGER 1-10)

---

## Confidence Calculation Algorithm

```dart
Confidence Score = 0.0

IF behavioral_patterns >= 5:
    score += 0.2
    
IF low_mood_entries >= 2 (out of last 10):
    score += 0.3
    
IF late_night_usage > 60%:
    score += 0.2
    
IF high_frequency_usage > 50%:
    score += 0.15
    
IF mood_variance > 6.0:
    score += 0.15

Confidence Level:
- Low: score < 0.4
- Medium: 0.4 <= score < 0.7
- High: score >= 0.7
```

---

## Medical Escalation Rules

### Requirements for Medical Guidance
1. Confidence level must be HIGH (70%+)
2. Minimum 5 consistent signals
3. Patterns observed over 7+ days
4. No contradictory data

### Guidance Language
- Uses probability-based phrasing
- "May indicate" instead of "is"
- "Consider" instead of "must"
- Always suggests professional consultation
- Never provides diagnosis

### User Control
- Dismissible notifications
- Optional guidance
- No forced actions
- Privacy maintained

---

## Setup Instructions

### Prerequisites
- Flutter SDK 3.10.4+
- Android SDK (for Android)
- Dart 3.0+

### Installation
```bash
# Clone or download project
cd mental_wellness

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run
```

### No Configuration Required
- No API keys needed
- No external services
- Works immediately
- Fully offline capable

---

## Privacy & Ethics

### Data Storage
- SQLite local database only
- No cloud backup
- No external transmission
- User-controlled deletion

### Permissions
- **Location**: Only when using map
- **Notifications**: Optional reminders
- **Storage**: Local database only

### Ethical Guidelines
- No medical diagnosis
- No emotional labeling
- Transparent uncertainty
- User empowerment
- Professional referral when needed

---

## UI/UX Design

### Color Palette
- Primary: Blue shades (calming)
- Secondary: Purple (supportive)
- Accent: Orange (attention)
- Background: Soft gradients

### Design Principles
- Minimal cognitive load
- Soothing animations
- Clear typography
- Intuitive navigation
- Stress-free interactions

### Animations
- Fade-in effects
- Scale transitions
- Smooth page changes
- Loading indicators

---

## Academic Compliance

### Lab Requirements Met
✅ Android/Flutter development
✅ GUI components and layouts
✅ Event handling
✅ Database integration (SQLite)
✅ GPS and location services
✅ Notifications
✅ Animations
✅ Multi-screen navigation

### Educational Value
- Real-world problem solving
- Ethical technology use
- Privacy-first design
- User-centered approach
- Mental health awareness

---

## Future Enhancements

### Potential Features
- Export mood data to CSV
- Weekly/monthly reports
- Dark mode theme
- Breathing animation
- More audio tracks
- Custom location categories
- Multi-language support

### Scalability
- Cloud backup (optional)
- Social support features
- Wearable integration
- Advanced analytics

---

## Troubleshooting

### Common Issues

**Build fails**
```bash
flutter clean
flutter pub get
flutter run
```

**Location not working**
- Check device GPS enabled
- Grant location permission
- Ensure internet for map tiles

**Audio not playing**
- Add MP3 files to assets/audio/
- Check file names match code
- Verify pubspec.yaml assets

**Database errors**
- App auto-creates database
- Check storage permission
- Clear app data if needed

---

## Disclaimer

This application is designed for educational and self-awareness purposes only. It does not provide medical diagnosis, treatment, or professional mental health services.

**Important Notes:**
- Not a substitute for professional help
- Emotional inference is approximate
- Confidence scores are estimates
- Always consult healthcare professionals
- Emergency: Contact local crisis services

---

## Credits

### Technologies Used
- Flutter & Dart (Google)
- OpenStreetMap (OSM Foundation)
- SQLite (Public Domain)
- Open-source Flutter packages

### Purpose
Educational project demonstrating:
- Ethical AI/ML concepts
- Privacy-first design
- Mental health awareness
- Mobile app development

---

## License

Educational use only. Not for commercial distribution.

---

**Version**: 1.0.0  
**Last Updated**: 2024  
**Platform**: Android (Flutter)
