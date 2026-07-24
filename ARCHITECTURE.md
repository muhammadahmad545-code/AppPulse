# AppPulse Architecture

AppPulse is an offline-first Android Flutter app that reconstructs screen time from
`UsageStatsManager`, stores everything on-device, and surfaces analytics, limits,
focus mode, and local exports — without a backend.

## Goals

- Feature-first Clean Architecture with inward dependency flow
- Fully offline: Drift (SQLite) for relational data, Hive for preferences
- Background reliability via a foreground service + WorkManager
- Reminders only — never force-close third-party apps

## Layering

```
Presentation (screens, widgets, Riverpod UI providers)
    ↓
Application / services (sync, limits, focus, backup, reports)
    ↓
Domain models & pure helpers
    ↑
Data (Drift DAOs, Hive SettingsStorage, platform channels)
```

Features live under `lib/features/<name>/` with presentation first. Shared
engines that multiple features need live under `lib/services/`.

## Key modules

| Area | Location | Responsibility |
|------|----------|----------------|
| Bootstrap / DI | `lib/bootstrap.dart`, `lib/infrastructure/di/` | Open Hive/Drift, wire Riverpod overrides |
| Usage engine | `lib/services/usage/` | Catalog sync, session reconstruction, summaries |
| Tracking | `lib/services/tracking/` | FGS task handler, WorkManager, isolate bootstrap |
| Limits | `lib/services/limits/` | Evaluate caps, dedupe alerts, notify |
| Focus | `lib/services/focus/` | Timed sessions + blocked-app awareness |
| Notifications | `lib/services/notifications/` | Channels + Drift history |
| Backup | `lib/services/backup/` | Export/share/restore SQLite |
| Platform bridge | `android/.../UsageStats*` + `lib/infrastructure/platform/` | Usage stats & permission APIs |
| UI shell | `lib/routing/`, `lib/shared/widgets/` | GoRouter + bottom nav |

## Data model (Drift)

- **Installed apps** — catalog + favorites/pins/categories
- **Usage sessions** — reconstructed foreground intervals
- **Daily / weekly / monthly summaries** — rollups for charts & limits
- **Hourly usage** — heatmap / day curves
- **App limits** — duration caps + warn thresholds + reminder action
- **Focus sessions** — planned/actual duration + blocked packages JSON
- **Notification history** — local log of shown alerts

Hive holds theme, Material You, tracking/notification toggles, date/time formats,
default home tab, warn defaults, and sync bookmarks.

## Background flow

1. Main isolate boots tracking + WorkManager.
2. FGS isolate opens its own Drift/Hive handles via `IsolateBootstrap`.
3. On each poll: catalog sync → usage sync → focus tick → limit check.
4. Alerts are notified locally and sent to the main isolate as `sync_result`
   for in-app reminder UI (`LimitReminderListener`).

## Limits & focus behavior

Android does not allow third-party apps to reliably kill other apps. Limit
actions (`onlyNotify`, `overlay`, `confirm`, `fullScreen`, `delay`, `strict`)
are reminder strategies. During focus, non-reached alerts are silenced unless the
blocked app is in the foreground.

## Testing

Prefer pure unit tests for reconstructors, report builders, limit evaluation, and
focus session state using `AppDatabase.forTesting(NativeDatabase.memory())`.

## Privacy

No network stack for product analytics. Exports leave the device only through
explicit user share/export actions.
