# Estate CRM — Mobile App

Flutter client for the Real Estate CRM system. Connects to the Spring Boot backend for clients, properties, deals, and meetings.

## Requirements

- Flutter SDK 3.x (project uses [FVM](https://fvm.app) — run `fvm flutter` if configured)
- Xcode (iOS) or Android Studio (Android)
- Backend running locally or reachable via API config

## Quick start

```bash
cd mobile
flutter pub get
flutter run
```

## Project layout

```
lib/
├── core/           # Theme, API service, models, router
├── features/       # Screens and BLoCs per feature
│   ├── auth/
│   ├── dashboard/
│   ├── clients/
│   ├── properties/
│   ├── deals/
│   ├── meetings/
│   └── profile/
└── main.dart
```

## Commands

| Task | Command |
|---|---|
| Run app | `flutter run` |
| Run tests | `flutter test` |
| Analyze | `flutter analyze` |
| Build APK | `flutter build apk` |
| Build iOS | `flutter build ios` |

## Notes

- Dark mode toggle is available in Profile → Preferences
- Agent ID can be copied from the Profile screen
