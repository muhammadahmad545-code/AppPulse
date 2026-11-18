# AppPulse

Offline screen-time tracker for Android, part of the Basalt app suite. AppPulse reads Android's own usage
records (UsageStatsManager), rebuilds every app session from them and keeps the history on the phone.

## Features

- **Today**: screen time with a daily goal ring, change vs yesterday, unlocks, app opens, longest session,
  usage by hour and the most used apps.
- **Apps**: every app you used today, in the last 7 or 30 days, with search, sort and opens. Each app has a
  detail page: today, 7-day average, 30-day total, a 7-day chart, today by hour, recent sessions, its limit
  and a shortcut to Android's app info.
- **Insights**: overview (total, daily average, busiest day, daily chart, categories, top apps, focus) and a
  day-by-day timeline of sessions.
- **App limits**: a daily limit per app. A notification arrives 5 minutes before and when the limit is
  reached. Optional reminder card drawn over the app (needs "Display over other apps"). Apps are never blocked.
- **Focus sessions**: 15–90 minute sessions with a countdown notification, a completion notification and a
  summary of time spent in other apps during the session.
- **Reports**: CSV or PDF for this week, last 7 days, last 30 days or this month, shared through Android.
- **Accuracy check**: today's per-app numbers next to Android's own totals.
- Usage access onboarding with an "Open settings" button that re-checks when you come back; a clear card
  everywhere data would be while access is missing.
- System, light and dark themes.

## How it works

- Sessions are rebuilt from resume/pause events: one app in front at a time, screen off/lock ends a session,
  sessions over midnight are split between days, the home screen, System UI and AppPulse are not counted.
  Unit tests cover these cases (`test/reconstruct_test.dart`).
- Android keeps about a week of events, so AppPulse stores sessions in SQLite. It syncs on open and every
  time you return to the app.
- Limits are checked by a native WorkManager job every 15 minutes while any limit exists, plus a check timed
  to the moment the app in front crosses its threshold. Nothing runs in the background without limits.

## Updates

On every launch (and on return after 15 minutes) the app checks the latest GitHub release of
`muhammadahmad545-code/AppPulse`, downloads the APK for the phone's ABI, verifies its SHA-256 and opens the
Android installer. Settings has "Check for updates".

## Stack

Flutter 3.47, Riverpod, sqflite, the shared `basalt` package (theme, widgets, updater), Kotlin for
UsageStatsManager/PackageManager/WorkManager/notifications, `pdf` and `share_plus` for reports.

## Build

CI (`.github/workflows/build.yml`) runs analyze and tests, builds split-per-ABI release APKs and runs an
emulator smoke test with end-to-end checks (`scripts/smoke.sh`, `scripts/e2e.sh`). Locally:

```sh
flutter pub get
flutter test
flutter build apk --release --split-per-abi
```

Release signing comes from the `RELEASE_KEYSTORE_*` environment variables; without them the build is
debug-signed.
