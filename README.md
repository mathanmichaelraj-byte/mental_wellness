# Mental Wellness App — v2.2.0

Flutter mobile app for emotional support through passive behavioural tracking, daily journaling, mood-aware affirmations, and mindfulness practices.

---

## 🌟 What's New in v2.2.0

- **Fixed AppBar** — Brand bar + icons pinned at top; welcome card scrolls with content
- **Daily Journal** — Permanent personal diary (SQLite, no expiry, mood-tagged entries)
- **Mood-Aware Affirmations** — Affirmation text chosen from state-specific pools per `EmotionalState`
- **Motivational Popup** — Shown once per calendar day on app open (skips if already shown)
- **Affirmations Screen** — Browsable, filterable by emotional state with animated featured card
- **Cloud Sync** — Opt-in; syncs only anonymised mood sentiment (not content) to Firestore
- **Service layer restructured** — Flat `services/` split into 7 focused subdirectories
- **DB schema v4** — Added `journal_entries` table with safe `onUpgrade` migration path
- **`emotional_release` renamed** — Previous "Journal" quick action correctly labelled "Emotional Release"

---

## ✨ Features

### Authentication
- Email/password sign-up and sign-in via Firebase Auth
- Auth state stream drives `AuthWrapper` → `HomeScreen` / `LoginScreen`
- Password reset via email

### Home Screen
- Fixed `AppBar` — brand logo, theme toggle, settings, help, sign-out (never scrolls)
- Scrollable `HeroWelcomeCard` — greeting, today's mood chip, mood-aware affirmation
- Emotional state card with confidence badge and contextual suggestions
- Pull-to-refresh reloads all DB + inference data in parallel

### Quick Actions
| Feature | Description |
|---|---|
| Emotional Release | Temporary venting notes — sentiment-analysed, auto-expire after chosen window |
| Gratitude | 30-day gratitude entries in 5 categories with stats |
| Mood | Mood history, inferred state timeline, behavioural signals |
| Breathe | 6 guided breathing exercises for different emotional states |

### Wellness Tools
| Feature | Description |
|---|---|
| Daily Journal | Permanent diary — title, content, 9 mood tags, edit/delete |
| Affirmations | Mood-filtered affirmation browser with animated featured card |
| Calm Audio | 3 therapeutic tracks — meditation, rain, nature (loops) |
| Find Places | Nearby therapists, parks, meditation centres via Overpass API |

### Cloud Sync (opt-in)
- Toggle in Settings — defaults to **off**
- Syncs only `{ date, sentiment, syncedAt }` — no text, no journal content
- Firestore path: `users/{uid}/mood_sync/{YYYY-MM-DD}`
- Batch-writes 30-day history on first enable; single-note sync on each save
- `clearCloudData()` available for full remote delete

### Notifications
- Daily affirmation push notification at user-configured time
- Schedule stored in Firestore user profile (`affirmationsEnabled`, `affirmationTime`)
- Test notification in Settings

---

## 🗂️ Folder Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart        # Routes, DB version, animation durations,
│   │                                 # affirmation pools, mood maps
│   └── config/
│       └── app_config.dart
│
├── models/
│   ├── behavior_pattern.dart
│   ├── emotional_confidence.dart
│   ├── emotional_note.dart
│   ├── gratitude_entry.dart
│   ├── journal_entry.dart            # NEW — permanent diary entry model
│   └── onboarding_step.dart
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── quick_actions/
│   │   ├── breathing_techniques_screen.dart
│   │   ├── gratitude_screen.dart
│   │   ├── journal_screen.dart       # NEW — permanent daily journal
│   │   └── mood_history_screen.dart
│   ├── wellness_tools/
│   │   ├── affirmations_screen.dart  # NEW — mood-filtered affirmation browser
│   │   ├── calm_audio_screen.dart
│   │   ├── emotional_release_screen.dart
│   │   └── location_finder_screen.dart
│   ├── auth_wrapper.dart
│   ├── home_screen.dart
│   ├── settings_screen.dart
│   ├── splash_screen.dart
│   └── welcome_screen.dart
│
├── services/
│   ├── local/                        # SQLite persistence + passive tracking
│   │   ├── database_service.dart     # Single DB facade (all 4 tables)
│   │   ├── behavior_tracker.dart     # Session lifecycle + pattern recording
│   │   └── gratitude_service.dart    # Gratitude CRUD wrapper
│   ├── inference/                    # Emotional state reasoning
│   │   ├── emotional_inference_service.dart  # Rule-based state inference
│   │   └── mood_affirmation_service.dart     # State → affirmation pool
│   ├── cloud/                        # Firebase integrations
│   │   ├── auth_service.dart         # Firebase Auth + Firestore user profile
│   │   └── cloud_sync_service.dart   # Opt-in mood sentiment sync
│   ├── notifications/                # Push notifications
│   │   ├── notification_service.dart # Low-level plugin wrapper
│   │   └── affirmation_service.dart  # Scheduled daily affirmation
│   ├── onboarding/
│   │   └── onboarding_service.dart   # SharedPreferences completion flag
│   ├── media/
│   │   └── audio_service.dart        # audioplayers wrapper
│   ├── location/
│   │   └── location_service.dart     # Geolocator + Overpass API
│   │
│   # ── Legacy re-export stubs (backwards compat, do not use in new code) ──
│   ├── database_service.dart         → local/database_service.dart
│   ├── behavior_tracker.dart         → local/behavior_tracker.dart
│   ├── gratitude_service.dart        → local/gratitude_service.dart
│   ├── emotional_inference_service.dart → inference/emotional_inference_service.dart
│   ├── mood_affirmation_service.dart → inference/mood_affirmation_service.dart
│   ├── cloud_sync_service.dart       → cloud/cloud_sync_service.dart
│   ├── notification_service.dart     → notifications/notification_service.dart
│   ├── affirmation_service.dart      → notifications/affirmation_service.dart
│   ├── onboarding_service.dart       → onboarding/onboarding_service.dart
│   ├── audio_service.dart            → media/audio_service.dart
│   ├── location_service.dart         → location/location_service.dart
│   └── firebase/
│       └── auth_service.dart         → cloud/auth_service.dart
│
├── utils/
│   ├── app_theme.dart                # Colors, gradients, light/dark themes
│   ├── hero_header.dart              # HeroWelcomeCard widget
│   ├── responsive.dart
│   └── sentiment_analyzer.dart       # Rule-based NLP sentiment
│
├── widgets/
│   ├── onboarding/
│   │   ├── onboarding_manager.dart
│   │   ├── onboarding_overlay.dart
│   │   └── onboarding_tooltip.dart
│   ├── hero_welcome_card.dart
│   ├── motivational_popup.dart       # NEW — once-per-day affirmation dialog
│   ├── optional_share_dialog.dart
│   └── ui_components.dart
│
├── firebase_options.dart
└── main.dart                         # App root, ThemeProvider, route table
```

---

## 🗄️ Database Schema (v4)

| Table | Purpose | Retention |
|---|---|---|
| `emotional_notes` | Venting notes with sentiment | Auto-expire (user-chosen window) |
| `behavior_patterns` | Passive usage signals | 7-day rolling query window |
| `gratitude_entries` | Gratitude practice entries | 30 days |
| `journal_entries` | Personal diary entries | **Permanent** — user deletes manually |

### `journal_entries` columns
```sql
id        INTEGER PRIMARY KEY AUTOINCREMENT
title     TEXT    NOT NULL
content   TEXT    NOT NULL
mood      TEXT                 -- nullable mood tag (Happy/Calm/Grateful/…)
createdAt TEXT    NOT NULL     -- ISO 8601
updatedAt TEXT    NOT NULL     -- ISO 8601
```

---

## 🔧 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.10.4+ / Dart 3+ |
| Authentication | Firebase Auth (email/password) |
| Remote DB | Cloud Firestore |
| Local DB | SQLite via sqflite |
| Notifications | flutter_local_notifications + timezone |
| Audio | audioplayers |
| Location | geolocator + Overpass API (OpenStreetMap) |
| State | InheritedWidget (`ThemeProvider`) + `StatefulWidget` |

---

## 📦 Setup

```bash
# 1. Install dependencies
flutter pub get

# 2. Configure Firebase
#    - Create a Firebase project
#    - Enable Authentication (Email/Password) and Firestore
#    - Run: flutterfire configure
#    - This generates lib/firebase_options.dart

# 3. Run
flutter run

# 4. Build for release
flutter build apk --release   # Android
flutter build ios --release   # iOS
```

---

## 🔒 Privacy

- **All personal data stays on device** — journal entries, emotional notes, behaviour patterns, gratitude entries are SQLite-only
- **Cloud sync is opt-in and anonymous** — only `{ date, sentiment }` is uploaded; no text content ever leaves the device unless the user explicitly enables sync
- **Firebase Auth** stores only email and display name
- **Firestore security rules** isolate each user's data by UID

---

## 🧠 How Emotional Inference Works

1. `BehaviorTracker` records a `BehaviorPattern` at the end of every app session (session duration, time of day, interaction speed, day of week)
2. `EmotionalInferenceService` queries the last 3 days of patterns + notes, computes 8 behavioural ratios, then applies a rule tree → `EmotionalState` (calm / restless / stressed / lowEnergy / neutral / distressed)
3. `EmotionalConfidence.calculateConfidence()` scores up to 9 signals → low / medium / high confidence
4. `MoodAffirmationService.getForState(state)` picks a random affirmation from the matching pool
5. `HomeScreen._loadData()` runs all four steps in parallel via `Future.wait`

---

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (11.0+)
- ⚠️ Web (limited — no SQLite, no notifications)
- ⚠️ Desktop (limited — location and notifications may vary)

---

## 🗺️ Roadmap

- [x] Firebase Authentication
- [x] Daily Affirmations (notification + in-app)
- [x] Mood-aware affirmation pools
- [x] Motivational popup (once per day)
- [x] Permanent Daily Journal
- [x] Emotional Release (temp notes, auto-expire)
- [x] Cloud Sync (opt-in, sentiment only)
- [x] Service layer modularised into subfolders
- [ ] Social login (Google, Apple)
- [ ] Weekly wellness report PDF export
- [ ] Mood calendar heat-map
- [ ] Voice journaling
- [ ] Custom affirmation creator
- [ ] Biometric integration (heart rate)

---

## ⚠️ Disclaimer

This is an educational wellness tool, not a medical device. It is not intended to diagnose, treat, cure, or prevent any medical condition. If you are experiencing mental health concerns, please consult a qualified healthcare professional.

---

**Version**: 2.2.0  
**DB Schema**: v4  
**Last Updated**: May 2026  

**See Also**: [Firebase Setup Guide](FIREBASE_SETUP.md) · [Architecture Docs](ARCHITECTURE.md) · [Developer Guide](DEVELOPER_GUIDE.md)
