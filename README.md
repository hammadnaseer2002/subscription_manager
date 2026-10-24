# Subscription Manager

A complete, production-ready Android app in Flutter (Dart, Material 3) that tracks recurring subscriptions, shows a countdown to the next payment, sends reminders, shows analytics, and backs up/syncs data to Google Drive.

## Features
- **Offline First**: All data is stored locally using SQLite (Drift).
- **Google Drive Backup**: Uses `googleapis` to backup app data to the hidden `appDataFolder` in Google Drive.
- **Reminders**: Local notifications for upcoming payments using `flutter_local_notifications` and exact alarms.
- **Analytics**: Donut chart and breakdown of spending.

## Google Drive Setup
To enable Google Drive Backup:
1. Go to the [Google Cloud Console](https://console.cloud.google.com).
2. Create a new project.
3. Enable the **Google Drive API** in the API library.
4. Configure the **OAuth Consent Screen**. Add the scope `https://www.googleapis.com/auth/drive.appdata` and `email`.
5. Create an **OAuth 2.0 Client ID** for Android.
   - Enter your package name.
   - Enter the SHA-1 signing certificate fingerprint.
   - Get the SHA-1 using: `./gradlew signingReport` in the `android/` folder.
   - Create one client ID for Debug and another for Release keystores.
6. The app relies on the `google_sign_in` plugin, which automatically picks up the Android client IDs based on the signing certificate.

## Building the App
Run the following commands:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release
```

Note: On some systems, the build_runner might get stuck on `Missing implementation of visitDotShorthandPropertyAccess`. This is usually solved by running `flutter pub upgrade` to update `analyzer` or ignoring it if code is generated successfully.

## Architecture
- **State Management**: Riverpod
- **Local Database**: Drift
- **Navigation**: go_router
- **Architecture**: Repository Pattern, Feature-first directories.
