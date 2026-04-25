# Mental Wellness App v2.1

Flutter mobile app for emotional support through passive behavioral tracking and mindfulness practices.

## 🌟 What's New in v2.1

- **Firebase Authentication** - Secure login and signup with email/password
- **Daily Affirmations** - Positive notifications to brighten your day
- **User Settings** - Customize affirmation time and preferences
- **Cloud Sync** - User preferences synced across devices
- **Production Ready** - Enterprise-grade security and error handling

## ✨ Features

### Core Features
- **Firebase Authentication** - Secure email/password login and signup
- **Daily Affirmations** - 30+ positive affirmations delivered daily
- **Rule-Based Analysis** - Intelligent emotional state detection from 20+ behavioral signals
- **Automatic Tracking** - Passive monitoring without manual input
- **Share Feelings** - Optional daily dialog + manual FAB access
- **Confidence-Based Support** - Low/Medium/High confidence responses
- **Privacy First** - Behavioral data stored locally, only auth in cloud

### Wellness Tools
1. **User Authentication** - Secure login/signup with Firebase
2. **Daily Affirmations** - Customizable positive notifications
3. **Emotional Analysis** - View mood history and behavioral patterns
4. **Emotional Release** - Write and track emotional notes (24hr retention)
5. **Gratitude Journal** - Daily gratitude practice with 5 categories
6. **Calm Audio** - 3 therapeutic audio tracks (meditation, rain, nature)
7. **Breathing Techniques** - 6 guided exercises for different emotional states
8. **Location Finder** - Find therapists, parks, meditation centers
9. **Settings** - Customize affirmation time and app preferences

## 🎨 Design System

### Color Palette
- **Primary**: Teal (#14B8A6) - Calm and healing
- **Accent**: Light Teal (#5EEAD4) - Energy and hope
- **Base**: Black & White - Clean contrast
- **Surface**: Grey (#374151) - Subtle depth

### UI Principles
- Smooth animations (fade, slide, scale)
- Consistent spacing (8/16/24px)
- Rounded corners (16px radius)
- Gradient accents for emphasis
- Theme support (light/dark mode)

## 🏗️ Architecture

### Folder Structure
```
lib/
├── core/
│   ├── constants/        # App-wide constants
│   └── config/           # Configuration files
├── models/               # Data models
├── screens/              # UI screens
│   └── auth/             # Authentication screens
│   ├── quick_actions/    # Quick Action Screens  
│   └── wellness_tools/   # Wellness Tools Screen
├── services/             # Business logic
│   └── firebase/         # Firebase services
├── utils/                # Helpers (theme, responsive)
├── widgets/              # Reusable components
│   └── onboarding/       # On Boarding Components
```

### Key Principles
- **Separation of Concerns** - Services handle logic, screens handle UI
- **Single Responsibility** - Each class has one clear purpose
- **Dependency Injection** - Singleton services for shared state
- **Constants Management** - No magic numbers or hardcoded strings

## 🔧 Tech Stack

- **Framework**: Flutter SDK 3.10.4+
- **Authentication**: Firebase Auth
- **Cloud Database**: Cloud Firestore
- **Local Database**: SQLite
- **Notifications**: flutter_local_notifications + timezone
- **Maps**: OpenStreetMap + flutter_map
- **Audio**: audioplayers
- **Location**: geolocator

## 📦 Setup

```bash
# Install dependencies
flutter pub get

# Configure Firebase (see FIREBASE_SETUP.md)
# 1. Create Firebase project
# 2. Add Android/iOS apps
# 3. Download config files
# 4. Enable Authentication & Firestore

# Run the app
flutter run

# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 🧠 How It Works

### Authentication Flow
- Email/password signup with validation
- Secure Firebase Authentication
- User preferences stored in Firestore
- Automatic session management

### Daily Affirmations
- 30+ positive affirmations
- Customizable notification time
- Random selection for variety
- Test notification feature
- Enable/disable in settings

### Behavioral Tracking (Passive)
- App usage frequency and patterns
- Time-of-day analysis (late night, morning, afternoon, evening)
- Session duration and variance
- Day-of-week patterns (weekend vs weekday)
- Interaction speed metrics
- Feature usage tracking

### Emotional Input (Optional)
- Auto-popup dialog once per day
- Manual access via FAB button
- Sentiment analysis (positive/neutral/negative)
- 24-hour note retention

### Rule-Based Inference
- Analyzes 20+ behavioral features
- 6 emotional states: calm, restless, stressed, lowEnergy, neutral, distressed
- Confidence scoring (low/medium/high)
- Contextual suggestions based on state

### Gratitude Practice
- 5 categories for organized reflection
- 30-day retention period
- Category-based filtering
- Visual statistics

## 🔒 Privacy & Security

- **Secure Authentication** - Firebase Auth with industry-standard encryption
- **Local Behavioral Data** - All tracking data stays on your device
- **Cloud User Preferences** - Only settings synced to Firebase
- **No Third-Party Tracking** - Zero analytics or tracking services
- **User Control** - Delete account and data anytime
- **Firestore Security Rules** - User data isolated by UID

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (11.0+)
- ✅ Web (limited features)
- ✅ Windows/macOS/Linux (desktop support)

## 🎯 Roadmap

- [x] Firebase Authentication
- [x] Daily Affirmations
- [x] User Settings
- [ ] Social login (Google, Apple)
- [ ] Export gratitude journal as PDF
- [ ] Custom affirmation creator
- [ ] Weekly wellness reports
- [ ] Mood calendar visualization
- [ ] Voice journaling
- [ ] Biometric integration (heart rate)

## ⚠️ Disclaimer

This is an educational wellness tool, not a medical device. It is not intended to diagnose, treat, cure, or prevent any medical condition. If you're experiencing mental health concerns, please consult a qualified healthcare professional.

## 📄 License

MIT License - See LICENSE file for details

## 🤝 Contributing

Contributions welcome! Please read CONTRIBUTING.md for guidelines.

---

**Version**: 2.1.0  
**Last Updated**: 2024  
**Maintained by**: Mental Wellness Team

**See Also**:
- [Firebase Setup Guide](FIREBASE_SETUP.md)
- [Architecture Documentation](ARCHITECTURE.md)
- [Developer Guide](DEVELOPER_GUIDE.md)
