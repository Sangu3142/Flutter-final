# Setup Guide

Full instructions for setting up a ZamWealth Quest development environment.

---

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Flutter SDK | stable channel (3.x+) | Do not use beta or dev channels |
| Dart SDK | Included with Flutter | Dart 3.x required (null safety) |
| Android Studio | Latest | For Android emulator and SDK tools |
| VS Code | Latest (optional) | Lighter alternative to Android Studio |
| Git | Any recent version | For cloning and version control |
| Claude Code | v2.1.143+ | Installed in `C:\Users\sangu\.claude\` |
| Android device or emulator | API 21+ (Android 5.0+) | Physical device preferred for performance |

---

## Install Flutter

1. Download the Flutter SDK from https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter` (avoid paths with spaces)
3. Add `C:\flutter\bin` to your `PATH` environment variable
4. Run `flutter doctor` and resolve all reported issues before proceeding

```powershell
flutter doctor
```

All items should show a green checkmark. Pay particular attention to:
- Android toolchain
- Connected device
- No version conflicts

---

## Clone and Install Dependencies

```powershell
git clone <repo-url> "zamwealth_quest"
cd zamwealth_quest
flutter pub get
```

`flutter pub get` downloads all packages listed in `pubspec.yaml`. This includes Hive, Riverpod, go_router, and all other dependencies. It also runs the build_runner code generation for Hive TypeAdapters.

If TypeAdapters are missing or out of date:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

---

## Connect a Physical Android Device

This project was developed and tested on a physical Android device. Physical devices provide more accurate performance profiling than emulators.

1. On your Android device, go to **Settings → About Phone**
2. Tap **Build Number** 7 times to unlock Developer Options
3. Go to **Settings → Developer Options**
4. Enable **USB Debugging**
5. Connect device to computer via USB
6. Accept the "Allow USB Debugging" dialog on the device

Verify the device is detected:

```powershell
flutter devices
```

Expected output includes your device with a device ID. Then run:

```powershell
flutter run
```

---

## Run on Emulator

If you prefer an emulator:

1. Open Android Studio
2. Go to **Tools → Device Manager**
3. Create a new Virtual Device — choose a phone profile with API 21 or higher
4. Start the emulator
5. Run `flutter devices` to confirm the emulator appears
6. Run `flutter run`

Note: The app's animations (adventure map path, confetti, HeartsHUD pulse) may run at reduced frame rates on emulators. Always test on a physical device before reporting performance issues.

---

## Environment Overview

The development environment for this project:

| Component | Detail |
|---|---|
| Development machine | Windows 11 Home (10.0.26200) |
| Primary testing device | Physical Android device |
| IDE | VS Code with Flutter extension |
| AI assistant | Claude Code v2.1.143 |
| Skills directory | `C:\Users\sangu\.claude\skills\` |
| Project directory | `C:\Users\sangu\Documents\Claude\Projects\Flutter final\` |

---

## Build Release APK

```powershell
flutter build apk --release
```

The signed APK will be output to:

```
build/app/outputs/flutter-apk/app-release.apk
```

To install directly to a connected device:

```powershell
flutter install
```

For Play Store upload, build an AAB (Android App Bundle) instead:

```powershell
flutter build appbundle --release
```

---

## Common Errors and Fixes

### Error: Hive TypeAdapter not registered

```
HiveError: Cannot read, unknown typeId: X
```

**Cause:** A Hive model was added or regenerated but the adapter registration in `main.dart` was not updated.

**Fix:**
1. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate adapter classes
2. In `lib/main.dart`, add `Hive.registerAdapter(NewModelAdapter())` before `Future.wait([...])`
3. Assign the next available typeId (check [hive.md](hive.md) for the current sequence — next is typeId 23)

### Error: GoRouter redirect loop (black screen or spinning forever)

```
GoException: Too many redirects
```

**Cause:** The router redirect logic is cycling between two states — typically because `authProvider` is returning inconsistent state.

**Fix:**
1. Check that `kSessionBox` contains a valid `'currentUid'` value
2. Check that the corresponding `UserProfile` exists in `kUserBox`
3. Check that `'onboardingDone_<uid>'` is set in `kSettingsBox`
4. If all state is stale/corrupted, open DevScreen (`/profile/dev`) and reset all boxes, or uninstall/reinstall the app

### Error: Black screen on launch

**Cause:** One of the Hive boxes failed to open before `runApp()`. This usually means a TypeAdapter conflict (typeId collision) or a corrupted box file.

**Fix:**
1. Check `main.dart` adapter registration order against [hive.md](hive.md)
2. Look for duplicate typeId assignments
3. If a box file is corrupted: delete the app data (Settings → Apps → ZamWealth Quest → Clear Data) and restart

### Error: "Bad state: no element" or null dereference after navigation

**Cause:** A Hive write was not awaited before navigation. The read on the next screen found an empty/partial record.

**Fix:** Find the navigation call that happens after the write and add `await` to the Hive operation. Add `if (context.mounted)` guard after the await. See [hive.md](hive.md) — "Why All Hive Writes Must Be Awaited".

### Error: Tutorial repeating every launch

**Cause:** A `Hive.box(kSettingsBox).delete(kTutorialCompletedKey)` call exists in the codebase that should only exist in debug mode.

**Fix:** Search for `delete(kTutorialCompletedKey)` and remove the call or gate it behind `kDebugMode`.

### Error: flutter pub get fails with version conflict

**Cause:** A transitive dependency version conflict.

**Fix:**

```powershell
flutter pub upgrade
```

If that does not resolve it:

```powershell
flutter clean
flutter pub get
```

### Error: build_runner failing on annotation processor

**Cause:** Hive model files have changed but generated `.g.dart` files are stale.

**Fix:**

```powershell
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

---

## Hot Reload and Hot Restart

| Action | Key | Effect |
|---|---|---|
| Hot reload | `r` in terminal | Injects code changes; preserves state |
| Hot restart | `R` in terminal | Full restart; clears in-memory state (Hive data on disk is preserved) |
| Full cold restart | Stop + `flutter run` | Full restart; Hive boxes are re-opened, `_seedLeaderboard()` runs |

Note: `_seedLeaderboard()` is guarded by the `'leaderboardSeeded'` flag so it only seeds once per device even on repeated cold restarts.

---

## Dev Screen

The `/profile/dev` route opens `DevScreen`, which provides:
- Reset all Hive boxes (wipes all user data)
- Toggle sandbox mode
- Display current box contents for debugging
- Reset tutorial state

This route is accessible from the ProfileScreen via a hidden tap target. Remove or gate this route behind `kDebugMode` before shipping to production.
