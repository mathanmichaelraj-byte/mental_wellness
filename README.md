# Mental Wellness & Location Support App

A Flutter-based mobile application for emotional support through passive behavioral tracking and location-based assistance.

## Core Features

### 1. Automatic Emotional Tracking
- **No manual mood input required**
- Tracks app usage patterns automatically
- Monitors time-of-day usage, frequency, session duration
- Builds confidence over time with multiple signals

### 2. Confidence-Based Support
- **Low Confidence**: Neutral calming responses
- **Medium Confidence**: Wellness suggestions (audio, breathing, locations)
- **High Confidence**: Medical guidance when 5+ consistent signals detected

### 3. OpenStreetMap Integration
- Free OSM tiles (no API key needed)
- External Google Maps for navigation
- Nearby therapists, parks, meditation centers

### 4. Calming Features
- Audio therapy player
- Emotional release notes (auto-delete)
- Breathing exercises
- Mood history visualization

## Technology Stack
- Flutter SDK
- SQLite (local storage)
- OpenStreetMap (flutter_map)
- Geolocator (GPS)
- Local notifications

## Setup

```bash
flutter pub get
flutter run
```

No API keys required. Works immediately.

## Privacy
- All data stored locally
- No cloud sync
- No background tracking
- User always in control

## Disclaimer
Educational tool only. Not for medical diagnosis. Consult professionals for mental health support.
