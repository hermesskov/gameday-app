# Gameday App

Cross-platform mobile app for the volleyballlife.com gameday experience. Built with Flutter + Material 3, matching the Vuetify design language.

## What It Does

- Login with your Volleyball Life account
- Check in to tournaments
- View match schedule + live scores
- Track bracket progress
- Watchlist for bookmarked teams and divisions
- Push notifications for match updates

## Tech Stack

- **Flutter** — cross-platform (Android + iOS)
- **Riverpod** — state management
- **GoRouter** — navigation
- **Material 3** — Vuetify-matched theming
- **Dart** — type-safe, JIT + AOT compilation

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp + Router
├── models/                      # Data models
├── screens/                     # One file per screen
├── services/                    # API, auth, notifications
├── theme/                       # Vuetify theme
└── widgets/                     # Reusable UI components
```

## Getting Started

```bash
# Install Flutter (Ubuntu)
sudo snap install flutter --classic

# Clone
git clone https://github.com/hermesskov/gameday-app.git
cd gameday-app

# Run
flutter pub get
flutter run -d chrome  # web for quick dev
```

## Development Workflow

Built using subagent-driven development:
1. Plan written → this repo
2. Sub-agent builds each feature
3. Spec review → quality review
4. Tests pass → merge

See `docs/implementation-plan.md` for the full plan.
