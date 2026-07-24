# AppPulse

**Know Where Your Time Goes.**

Production-oriented, fully offline Android app that tracks how much time you spend in every installed application — with analytics, timelines, limits, focus mode, and local reports.

> **Platform note:** App usage tracking relies on Android’s `UsageStatsManager`. The codebase is structured for future iOS where feasible, but iOS does not expose equivalent third-party app-usage APIs.

---

## Phase status

| Phase | Scope | Status |
|------:|-------|--------|
| 1 | Project, deps, structure, theme, routing, DB, DI | Complete |
| 2 | Permissions, usage engine, background services | Complete |
| 3 | Dashboard, apps, details, timeline | Complete |
| 4 | Analytics, charts, reports, export | Complete |
| 5 | Limits, notifications, focus, settings, tests, docs | **Complete — awaiting approval** |

---

## Stack

- Flutter 3.44+ / Dart 3.12+
- Material 3 + Material You (`dynamic_color`)
- Riverpod + Flutter Hooks
- GoRouter
- Drift (SQLite) + Hive (settings)
- Freezed / JSON Serializable (codegen ready)
- fl_chart, Google Fonts, Lottie, Shimmer
- permission_handler, workmanager, flutter_local_notifications, flutter_foreground_task
- pdf / csv / share_plus / file_picker (reports & backups)

---

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

**Requirements**

- Flutter stable channel
- Android Studio / SDK (API 26+ devices or emulators)
- JDK 17

Grant **Usage Access** on first launch (required). Notifications and battery optimization are optional but improve limit/focus reminders and background reliability.

---

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for layering, data model, and background flow.

```
lib/
  core/             # constants, errors, logging, extensions
  shared/           # reusable widgets & models
  features/         # dashboard, apps, analytics, timeline, focus, …
    <feature>/
      presentation/
      application/
      domain/
      data/
  database/         # Drift tables, DAOs, AppDatabase
  infrastructure/   # DI, platform adapters
  services/         # usage, tracking, limits, focus, backup, notifications
  routing/
  theme/
  l10n/
```

Dependencies flow inward: **Presentation → Application → Domain ← Data**.

---

## Database

**Drift (SQLite)** — installed apps, usage sessions, daily/weekly/monthly summaries, hourly buckets, app limits, focus sessions, notification history.

**Hive** — theme, Material You, notification prefs, onboarding flags, date/time formats, default home, warn defaults, sync bookmarks.

---

## Features (Phase 5)

- **App limits** — daily/weekly/monthly caps with warn thresholds and reminder actions
- **Focus mode** — presets/custom timer, apps to avoid, daily focus stats
- **Notifications** — channels for tracking/limits/focus + on-device history
- **Settings** — formats, default home, backup/restore, reset/clear, privacy, licenses
- **In-app reminders** — overlay/confirm/full-screen UI while AppPulse is open

---

## Build

```bash
# Debug
flutter run

# Analyze + tests
flutter analyze
flutter test

# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release
```

Replace the debug signing config in `android/app/build.gradle.kts` with your Play upload keystore before publishing.

---

## Privacy

AppPulse is offline-first. No Firebase, no backend, no analytics SDKs. All usage data remains on-device unless the user explicitly exports or shares it.
