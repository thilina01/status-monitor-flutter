# Status Monitor

**Status Monitor** is a cross-platform Flutter application designed to provide real-time health monitoring of backend services. It displays system status with granular CPU, memory, and network metrics while providing rich UI feedback, customizable settings, background monitoring, and smart notifications for service disruptions.

---

## 🚀 Features

- ✅ **Real-Time Health Dashboard**
  - Displays service status as **Up**, **Down**, **Healthy**, or **Unhealthy**
  - Visual indicators using color-coded icons and performance metrics
- 🔁 **Auto Refresh**
  - Configurable auto-refresh duration
  - Countdown-based refresh indicator
- 🔔 **Local Notifications**
  - Alerts when services go from “Up” to “Down” or “Unhealthy”
- 🌙 **Dark/Light Theme Toggle**
  - User-preferred theme with persistence using `shared_preferences`
- ⚙️ **Settings Screen**
  - API endpoint configuration
  - Auto-refresh toggle and interval
- 📱 **Cross-Platform Compatibility**
  - Works on Android, iOS, Linux, Windows, macOS
- 🧰 **Background Monitoring**
  - Runs periodic status checks using `workmanager` plugin
  - Notifies even when the app is minimized (Android-specific feature)
- ☁️ **GitHub & Play Store Automation**
  - CI/CD with GitHub Actions for release builds and deployment to Google Play

---

## 🏗️ Architecture

- **Flutter (Dart)** for frontend
- **Provider** for state management
- **Workmanager** for background tasks
- **Flutter Local Notifications** for alerts
- **SharedPreferences** for persistent settings
- **MethodChannel** to handle Android-specific minimize behavior

---

## 📁 Directory Structure

```
lib/
├── screens/
│   ├── home_screen.dart       # Main dashboard UI
│   └── settings_screen.dart   # App settings form
├── services/
│   ├── api_service.dart       # Fetches and processes service health data
│   ├── background_service.dart# Handles periodic background tasks
│   └── theme_provider.dart    # Manages theme state
└── main.dart                  # Entry point and provider setup
```

---

## 🛠️ Setup & Installation

### 🔧 Prerequisites

- Flutter SDK (>= 3.0.0)
- Android/iOS SDKs (for respective platforms)

### 🔄 Dependencies

```bash
flutter pub get
```

### ▶️ Run App

```bash
flutter run
```

### 🧪 Run Tests

```bash
flutter test
```

---

## 🧩 Configuration

### API Endpoint

- Set via **Settings screen**
- Persists across sessions via `SharedPreferences`

### Notifications

- Triggered when a service goes **down** (status changes)
- Resets if the service recovers

---

## 🔄 CI/CD

Two GitHub Actions workflows provided:

1. `flutter-github-release.yml` – builds and uploads release APK/AAB to GitHub
2. `flutter-release.yml` – version bumps and uploads to Google Play internal track

Secrets required:
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `GOOGLE_PLAY_KEY_JSON` (optional)

---

## 📲 Screenshots

> Screenshots and icons should be placed in `assets/` and referenced in README for store listings.

---

## 📦 Release Versioning

Follows **Semantic Versioning** (`major.minor.patch+build`).

Version is dynamically managed by the GitHub workflow based on input (`major`, `minor`, `patch`).

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

## 📝 License

MIT License. See `LICENSE` file for details.

---

## 📧 Contact

Developed by **thilina01**.  
Email: `thilina01@apache.org`  
Website: `https://www.thilina01.com`  

