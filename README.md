# Mental Wellness & Location Support App

A lightweight mobile application focused on emotional support and location-based calming assistance. The app is designed to reduce user frustration by avoiding forced emotional input and instead understanding the user gradually through optional interaction and behavioral patterns.

---

## ✨ Core Idea

The app does not immediately label emotions or jump to conclusions. Emotional understanding is built slowly using multiple signals over time. Users stay in control at all times, and all support is optional, calm, and non-intrusive.

---

## 🧠 Emotional Understanding Flow

### Optional First Screen
- On app launch, users may see an optional prompt such as:
  > “What’s on your mind right now?”
- This input can be skipped.
- Any response is treated as a **low-confidence signal**.

### Ambiguity Handling
- Mixed or contradictory inputs (e.g., “happy fight”) are classified as **ambiguous**.
- The app avoids emotional labeling based on a single input.

### Confidence-Based Inference
Emotional understanding improves over time using:
- Optional text input
- App usage patterns
- Time-of-day usage
- Skip behavior
- Interaction frequency

Behavioral patterns are prioritized over one-time responses.

---

## 🌱 Support Levels

- **Low confidence:** Neutral presence and calming UI
- **Medium confidence:** Suggestions like relaxing audio or calming places
- **High confidence:** Medically aligned guidance such as recommending professional support  
  (No diagnosis is ever performed)

---

## 🎧 Calming Features

- Relaxing music or ambient sounds
- Optional notes / journaling
- Soft animations and calming color themes
- All features are optional and user-controlled

---

## 📍 Location & Map Module

### Design Choice
- **OpenStreetMap (OSM)** is used for in-app map display
- **Google Maps** is opened externally for navigation

This approach avoids billing risks while providing a familiar navigation experience.

---

## 🗺️ Map Flow

1. Request location permission
2. Obtain current GPS coordinates
3. Display OpenStreetMap centered on the user
4. Show nearby calming places or therapists using markers
5. When a marker is tapped:
   - Show place details
   - Option to open in Google Maps
6. Launch Google Maps externally for navigation

---

## 🗄️ Local Data Storage

- SQLite is used to store:
  - User notes
  - Interaction history
  - Saved locations
- All data is stored locally for privacy

---

## 🔔 Notifications

- Gentle reminders
- Optional calming prompts
- Implemented using the platform’s notification system

---

## 🛠️ Technology Stack

### Flutter
- Flutter SDK
- `flutter_map` (OpenStreetMap)
- `latlong2`
- `url_launcher`
- SQLite
- Device GPS services

### OR Native Android
- Java
- Android SDK
- OpenStreetMap (osmdroid)
- SQLite
- Notification Manager
- Location services

---

## 🔐 Privacy & Ethics

- No forced emotional input
- No background tracking without consent
- No emotional diagnosis
- All emotional understanding is approximate and confidence-based
- User can ignore or disable any feature

---

## 📌 Summary

This app provides emotional support through calm design, gradual understanding, and location-based assistance. It prioritizes user comfort, privacy, and control while remaining lightweight and cost-free.

---