# Mental Wellness App

Flutter mobile app for emotional support through passive behavioral tracking.

## Features

- **Rule-Based Analysis** - Intelligent emotional state detection from behavioral patterns
- **Automatic Tracking** - No manual input, monitors 20+ behavioral signals
- **Share Feelings** - Optional dialog (auto-popup once/day + FAB for manual access)
- **Confidence-Based Support** - Low/Medium/High confidence responses
- **Location Finder** - Therapists, parks, meditation centers (OpenStreetMap)
- **Calming Tools** - Audio therapy, 6 breathing techniques with timers, emotional notes
- **Privacy First** - All data stored locally, no cloud sync
- **Consistent Design** - 4-color palette (Indigo, Teal, Amber, Slate) with responsive layout

## Tech Stack

- Flutter SDK
- SQLite (local database)
- OpenStreetMap
- Geolocator

## Setup

```bash
flutter pub get
flutter run
```

## How It Works

### Behavioral Tracking (Passive)
- Usage frequency and patterns
- Time-of-day (late night, morning, afternoon, evening)
- Session duration and variance
- Day-of-week patterns (weekend vs weekday)
- Interaction speed
- Short/medium/long session ratios

### Emotional Input (Optional)
- "Share Feelings" dialog auto-popups once per day
- FAB button on home screen for manual access anytime
- Sentiment analysis (positive/neutral/negative)
- Notes stored locally for 24 hours

### Rule-Based Inference
- Analyzes 20+ behavioral features
- 6 emotional states: calm, restless, stressed, lowEnergy, neutral, distressed
- Confidence scoring based on signal strength
- No ML dependencies - pure algorithmic approach

## Privacy

- 100% local storage
- ML runs on-device (no cloud)
- No background tracking
- No data sharing
- User controls all data

## Disclaimer

Educational tool only. Not for medical diagnosis.
