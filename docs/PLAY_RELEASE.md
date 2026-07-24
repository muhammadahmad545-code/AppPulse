# AppPulse — Play Store release guide

## Signing

1. Generate a keystore (once):

```bash
keytool -genkey -v \
  -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

2. Copy `android/key.properties.example` to `android/key.properties` and fill in values.
3. Never commit `key.properties` or `*.jks`.

## Build

```bash
flutter build appbundle --release
# output: build/app/outputs/bundle/release/app-release.aab

flutter build apk --release --target-platform android-arm64
# sideload APK for testers
```

## Data safety (Play Console)

AppPulse is offline-first:

- No account system
- No cloud backup by default
- Usage data stays on device unless the user exports/shares it
- Permissions: Usage Access (required), Notifications (optional), Overlay (optional), Battery optimization (optional)

## Store listing checklist

- [ ] App icon (512×512)
- [ ] Feature graphic (1024×500)
- [ ] Phone screenshots (dashboard, apps, analytics, focus, settings)
- [ ] Short description: “Know Where Your Time Goes.”
- [ ] Full description covering offline tracking, limits, focus, reports
- [ ] Privacy policy URL (can host `PrivacyScreen` content)
- [ ] Content rating questionnaire
- [ ] Target API / declarations for foreground service specialUse

## ProGuard / R8

Release builds currently keep minify off for sideload stability; enable R8 before Play if desired. Play Core stubs are covered in
`android/app/proguard-rules.pro`. Validate on a physical device after each
major dependency bump.


## Sideload OTA updates (GitHub Releases)

While testing outside Play Store, pushes to `main` publish a signed `AppPulse.apk`
via `.github/workflows/release.yml`. The app checks the latest GitHub Release and
can download/install an update in-place (same signing key required).

1. Uninstall any **debug-signed** build once.
2. Install the APK from the latest GitHub Release (internally signed).
3. Later: open the app → update prompt, or **Settings → Check for updates**.

Play uploads should use a separate upload keystore; do not reuse the internal
sideload key for production if you want to rotate freely.
