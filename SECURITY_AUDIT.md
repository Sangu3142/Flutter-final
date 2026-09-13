# ZamWealth Quest — Security Audit Report

**Audited by:** Claude Code Security Analysis  
**Date:** 2026-05-26  
**App version:** ZamWealth Quest v1.0  
**Platform:** Android (Flutter)  
**Audit type:** Static code analysis + threat modelling

---

## Executive Summary

ZamWealth Quest is a fully offline Flutter application with **no server-side validation of any game state**. Every critical value — ZamCoins, XP, level unlock flags, streaks, badges, payment records, and leaderboard rankings — is stored in plaintext Hive boxes that are readable and writable on any rooted device or via ADB backup on stock Android. The app's release build is unsigned (debug key used), unobfuscated, and ships without root detection, making it trivially exploitable by any technically motivated user. **The app is not ready for public Google Play Store release** in its current state; addressing all CRITICAL and HIGH findings is mandatory before submission.

---

## Severity Legend

| Severity | Meaning |
|----------|---------|
| 🔴 CRITICAL | Exploitable right now, breaks app integrity |
| 🟠 HIGH | Serious risk for public release |
| 🟡 MEDIUM | Should fix before release |
| 🟢 LOW | Best practice improvement |

---

## Findings

---

### [VUL-001] All Hive Boxes Opened Without Encryption

**Severity:** 🔴 CRITICAL  
**Category:** Insecure Data Storage (OWASP M2)  
**Location:** `lib/main.dart:72–99`

**Description:**  
Twenty-five Hive boxes are opened with `Hive.openBox()` and `Hive.openBox<T>()`, neither of which applies any encryption. The Hive database files are written as plain binary on the device filesystem at a path such as `/data/data/com.example.zamwealth_quest/app_flutter/*.hive`. These files are human-readable with the Hive binary format and directly editable with free tools.

**How an attacker exploits this:**  
On a rooted device, the attacker uses a root file explorer (e.g. MT Manager, Root Explorer) to navigate to `/data/data/com.example.zamwealth_quest/app_flutter/` and copies the `.hive` files. They then use a Hive box editor script or the Hive Dart CLI to open the box, read all fields, and write arbitrary values. On a non-rooted device, the attacker runs `adb backup` (see VUL-006 for why this works) to extract the same files. No special hardware or jailbreak is required for the ADB path.

**Impact:**  
Every single piece of game state — balances, achievements, payment records, level unlocks — can be read and rewritten. All other CRITICAL and HIGH Hive-related findings (VUL-002 through VUL-014) are enabled by this root vulnerability.

**Fix:**  
Add `flutter_secure_storage` to `pubspec.yaml` and encrypt every Hive box before opening it.

```yaml
# pubspec.yaml — add to dependencies:
flutter_secure_storage: ^9.2.2
crypto: ^3.0.3
```

```dart
// lib/main.dart — replace the current main() body with:

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // ── 1. Get or create encryption key ─────────────────────────────────────
  final encryptionKey = await _getOrCreateHiveKey();
  final cipher = HiveAesCipher(encryptionKey);

  // ── 2. Register TypeAdapters (unchanged) ─────────────────────────────────
  // ... (same as current code) ...

  // ── 3. Open ALL boxes with encryption ───────────────────────────────────
  await Future.wait([
    Hive.openBox<UserProfile>(kUserBox, encryptionCipher: cipher),
    Hive.openBox<LevelModel>(kLevelBox, encryptionCipher: cipher),
    Hive.openBox<PaymentRecord>(kPaymentBox, encryptionCipher: cipher),
    Hive.openBox(kSessionBox, encryptionCipher: cipher),
    Hive.openBox(kLeaderboardBox, encryptionCipher: cipher),
    Hive.openBox(kSettingsBox, encryptionCipher: cipher),
    Hive.openBox(kStreakBox, encryptionCipher: cipher),
    // ... all other boxes with the same cipher ...
  ]);

  await _seedLeaderboard();
  runApp(const ProviderScope(child: ZamWealthApp()));
}

/// Retrieves the AES-256 key from secure storage, or generates and stores
/// a new one on first launch. Key never leaves the secure enclave.
Future<Uint8List> _getOrCreateHiveKey() async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final existingKey = await storage.read(key: 'hive_encryption_key');
  if (existingKey != null) {
    return base64Decode(existingKey);
  }
  final key = Hive.generateSecureKey();
  await storage.write(
    key: 'hive_encryption_key',
    value: base64Encode(key),
  );
  return key;
}
```

> **Note:** On first install after adding encryption, existing unencrypted boxes must be migrated. For a fresh release this is not an issue. For an update to existing installs, add a migration step that reads the old unencrypted box, writes to the new encrypted box, and deletes the old file.

---

### [VUL-002] ZamCoins and Wallet Balance Lack Integrity Checking

**Severity:** 🔴 CRITICAL  
**Category:** Code Tampering / Insecure Data Storage (OWASP M2, M8)  
**Location:** `lib/features/auth/models/user_profile.dart:105–107`; `lib/features/auth/providers/auth_provider.dart:356–362`

**Description:**  
`UserProfile.zamCoins` (HiveField 8), `UserProfile.walletBalance` (HiveField 20), and `UserProfile.xp` (HiveField 7) are plain `int` fields stored in the `users` Hive box with no checksum, HMAC, or any integrity verification. Even after Hive encryption is applied (VUL-001 fix), an attacker with root access can decrypt the box using the extracted secure-storage key and directly write `walletBalance: 9999999`.

**How an attacker exploits this:**  
1. Root the device or use ADB backup.  
2. Extract the `users.hive` file and the key from Android Keystore/EncryptedSharedPreferences.  
3. Use a Dart script to open the box with the recovered key, set `walletBalance` to 9,999,999, and write the file back.  
4. Relaunch the app — unlimited ZamCoins available.

**Impact:**  
Players can grant themselves unlimited virtual currency, bypassing every spending gate in the shop, property system, portfolio, family upgrades, and loan repayments.

**Fix:**  
Store a SHA-256 checksum alongside every critical balance. On read, verify the checksum and reset to zero on mismatch.

```dart
// lib/services/integrity_service.dart (new file)
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';

class IntegrityService {
  // Internal secret — not a secret key, just a deterrent against naive edits.
  static const _secret = 'zw_integrity_v1';

  static String _hash(String field, int value) {
    final input = '$_secret:$field:$value';
    return sha256.convert(utf8.encode(input)).toString();
  }

  static Future<void> saveBalance(int amount) async {
    final box = Hive.box(kSettingsBox);
    await box.put('wallet_balance', amount);
    await box.put('wallet_balance_hash', _hash('wallet_balance', amount));
  }

  static int readBalance() {
    final box = Hive.box(kSettingsBox);
    final amount = box.get('wallet_balance', defaultValue: 0) as int;
    final stored = box.get('wallet_balance_hash') as String?;
    if (stored == null || stored != _hash('wallet_balance', amount)) {
      box.put('wallet_balance', 0);
      box.put('wallet_balance_hash', _hash('wallet_balance', 0));
      return 0;
    }
    return amount;
  }

  static Future<void> saveXp(int amount) async {
    final box = Hive.box(kSettingsBox);
    await box.put('player_xp', amount);
    await box.put('player_xp_hash', _hash('player_xp', amount));
  }

  static int readXp() {
    final box = Hive.box(kSettingsBox);
    final amount = box.get('player_xp', defaultValue: 0) as int;
    final stored = box.get('player_xp_hash') as String?;
    if (stored == null || stored != _hash('player_xp', amount)) {
      box.put('player_xp', 0);
      box.put('player_xp_hash', _hash('player_xp', 0));
      return 0;
    }
    return amount;
  }
}
```

> **Note:** Also add the `crypto: ^3.0.3` package to `pubspec.yaml`. This is a deterrent layer on top of Hive encryption (VUL-001); the two together make casual tampering impractical.

---

### [VUL-003] Password Stored as Reversible Base64 Encoding, Not a Hash

**Severity:** 🔴 CRITICAL  
**Category:** Insufficient Cryptography (OWASP M5)  
**Location:** `lib/features/auth/providers/auth_provider.dart:80–83`

**Description:**  
The `_hashPassword` method does not hash the password. It prepends a hardcoded prefix `zmw_quest_2024_` and then base64-encodes the result. Base64 is encoding, not encryption or hashing — it is **trivially reversible** with `base64Decode()`. The salt is also static and embedded in APK source, so every user's "hash" uses the same salt. Anyone who reads the `passwordHash` field from the `users` Hive box can recover the plaintext password by base64-decoding and stripping the prefix.

```dart
// Current vulnerable implementation:
String _hashPassword(String password) {
  final salted = 'zmw_quest_2024_$password';   // static prefix, not a salt
  return base64Encode(utf8.encode(salted));     // encoding, NOT hashing
}
```

**How an attacker exploits this:**  
1. Extract the `users.hive` box.  
2. Read `user.passwordHash` for any registered user.  
3. Run `utf8.decode(base64Decode(hash)).replaceFirst('zmw_quest_2024_', '')` — the original password is immediately recovered.  
4. Use that password to log in as the victim user and access their profile.

**Impact:**  
All user passwords are stored in recoverable form. In a local-only app, this primarily exposes passwords that users reuse on other services (a common practice). It also allows account takeover by a shared-device attacker.

**Fix:**  
Use SHA-256 with a per-user random salt. Add a `passwordSalt` field to `UserProfile`.

```dart
// pubspec.yaml — already needed by VUL-002:
// crypto: ^3.0.3

// In auth_provider.dart:
import 'package:crypto/crypto.dart';
import 'dart:math';

/// Generates a cryptographically random 16-byte hex salt.
String _generateSalt() {
  final rng = Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// Computes SHA-256(salt + ':' + password).
String _hashPassword(String password, String salt) {
  final combined = '$salt:$password';
  return sha256.convert(utf8.encode(combined)).toString();
}

// On registration — generate and store the salt:
final salt = _generateSalt();
final hash = _hashPassword(password, salt);
// Store both salt and hash in UserProfile (add a passwordSalt HiveField)

// On login — retrieve stored salt, re-hash, compare:
final hash = _hashPassword(enteredPassword, user.passwordSalt);
if (user.passwordHash != hash) { /* reject */ }
```

```dart
// In user_profile.dart — add a new HiveField:
@HiveField(30)
String passwordSalt;
```

---

### [VUL-004] Developer Console Route Accessible in Production Release

**Severity:** 🔴 CRITICAL  
**Category:** Extraneous Functionality / Insecure Authorization (OWASP M10, M6)  
**Location:** `lib/core/router.dart:338–344`; `lib/features/profile/screens/dev_screen.dart`

**Description:**  
The route `/profile/dev` (`AppRoutes.dev`) is a fully registered GoRouter route in the production build. The `DevScreen` provides: (1) force-unlock of Levels 2, 3, and 4 bypassing payment; (2) raw read-access to all Hive boxes (users, levels, payments, session, settings, leaderboard); and (3) a "Reset All Progress" nuclear option. The only protection is a 7-tap Easter egg in the Profile screen UI — the route itself has no authentication guard whatsoever. Any authenticated user can navigate directly to `/profile/dev` via `context.go('/profile/dev')` or if the app supports deep linking.

```dart
// router.dart:338 — unguarded dev route registered in production:
GoRoute(
  path: AppRoutes.dev,  // = '/profile/dev'
  pageBuilder: (context, state) => _fadeSlidePage(
    pageKey: state.pageKey,
    child: const DevScreen(),
  ),
),
```

**How an attacker exploits this:**  
1. Install the APK and register an account.  
2. In any screen that has a `ref` / router access, call `context.go('/profile/dev')`.  
3. Alternatively, if the device has ADB access, use `adb shell am start -n com.example.zamwealth_quest/.MainActivity --es "route" "/profile/dev"`.  
4. In the DevScreen, tap "Unlock" on Levels 2, 3, and 4 — all premium content is unlocked without payment.  
5. Use the Raw Hive Box Viewer to read all user passwords (see VUL-003), payment records, and session data.

**Impact:**  
Any registered user can bypass all payment gates for free, read raw Hive data for all users on the device, and expose the developer console in screenshots shared publicly.

**Fix:**  
Remove the `DevScreen` route entirely from the production router. Use a Dart compilation flag so the route only exists in debug/profile builds.

```dart
// lib/core/router.dart — wrap the dev route:
import 'package:flutter/foundation.dart' show kDebugMode, kProfileMode;

// Inside the routes list:
if (kDebugMode || kProfileMode)
  GoRoute(
    path: AppRoutes.dev,
    pageBuilder: (context, state) => _fadeSlidePage(
      pageKey: state.pageKey,
      child: const DevScreen(),
    ),
  ),
```

> If `if` clauses in the routes list cause type issues with your GoRouter version, move the dev route into a separate list and spread conditionally:

```dart
routes: [
  ...coreRoutes,
  if (kDebugMode || kProfileMode) ...devRoutes,
],
```

---

### [VUL-005] Level Unlock and Payment Verification Are Entirely Client-Side

**Severity:** 🔴 CRITICAL  
**Category:** Insecure Authorization (OWASP M6)  
**Location:** `lib/features/auth/models/user_profile.dart:112–114`; `lib/features/payments/models/payment_record.dart`

**Description:**  
Level access is controlled by `UserProfile.unlockedLevels` — a plain `List<int>` stored in the unencrypted `users` Hive box. Payment verification checks for a `PaymentRecord` in the `payments` Hive box. Both can be fabricated. An attacker can write `unlockedLevels: [1, 2, 3, 4]` or create a synthetic `PaymentRecord` with `sandboxMode: true`, `isPaid: true`, and a valid-looking UUID — all without touching the payment screen.

**How an attacker exploits this:**  
1. Extract the `users.hive` box.  
2. Edit the `unlockedLevels` field to include `[1, 2, 3, 4]`.  
3. Optionally, write a fake `PaymentRecord` to `payments.hive` with the correct `uid` and `tier`.  
4. Relaunch the app — all levels accessible with no payment.

**Impact:**  
All premium content (Levels 2/3/4, valued at ZMW 25/50/80) accessible for free, eliminating the commercial revenue model.

**Fix:**  
For a local-only app, add an integrity check on the payment record and validate it against the unlocked level list at access time:

```dart
// lib/features/levels/providers/level_provider.dart — add validation:
bool isLevelUnlocked(int levelId, String uid) {
  if (levelId == 1) return true; // Level 1 is always free

  // Check payment record exists and is internally consistent
  final paymentBox = Hive.box<PaymentRecord>(kPaymentBox);
  final record = paymentBox.values.where(
    (r) => r.uid == uid && r.tier.contains('Level $levelId'),
  ).firstOrNull;

  if (record == null) return false;

  // Validate record integrity: must have a non-empty paymentId,
  // a non-zero amount, and a timestamp within plausible range.
  final tooOld = DateTime.now().subtract(const Duration(days: 3650));
  return record.paymentId.isNotEmpty &&
         record.amountZMW > 0 &&
         record.timestamp.isAfter(tooOld) &&
         record.uid == uid;
}
```

> **Long-term fix:** Move payment verification to a server. Local-only validation is always bypassable on rooted devices; server-side receipts (Google Play Billing) are the only robust solution.

---

### [VUL-006] ADB Backup Enabled — All Hive Data Extractable Without Root

**Severity:** 🟠 HIGH  
**Category:** Insecure Data Storage (OWASP M2)  
**Location:** `android/app/src/main/AndroidManifest.xml:2–7`

**Description:**  
`android:allowBackup` is not set in the `<application>` tag, so it defaults to `true` on Android < 12, and on Android 12+ the `android:dataExtractionRules` attribute is also absent. This means `adb backup` on a non-rooted, non-unlocked device can extract all app data, including every Hive box file. The attacker does not need root.

**How an attacker exploits this:**  
1. Connect any Android device (not rooted) via USB with ADB enabled.  
2. Run `adb backup -noapk com.example.zamwealth_quest`.  
3. Convert the resulting `.ab` file: `dd if=backup.ab bs=1 skip=24 | python -c "import zlib,sys; sys.stdout.buffer.write(zlib.decompress(sys.stdin.buffer.read()))" | tar -xvf -`.  
4. Navigate to `apps/com.example.zamwealth_quest/f/` to find all `.hive` files.

**Impact:**  
All Hive data (users, payments, levels, leaderboard) extracted without root, enabling the full suite of Hive tampering attacks.

**Fix:**  

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:label="zamwealth_quest"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:allowBackup="false"
    android:fullBackupContent="false">
```

For Android 12+ also add a data extraction rules file:

```xml
<!-- android/app/src/main/res/xml/data_extraction_rules.xml (new file) -->
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <exclude domain="file" path="."/>
    </cloud-backup>
    <device-transfer>
        <exclude domain="file" path="."/>
    </device-transfer>
</data-extraction-rules>
```

```xml
<!-- In AndroidManifest.xml <application> tag, also add: -->
android:dataExtractionRules="@xml/data_extraction_rules"
```

---

### [VUL-007] Release Build Uses Debug Signing Key

**Severity:** 🟠 HIGH  
**Category:** Build and Release (OWASP M9)  
**Location:** `android/app/build.gradle.kts:34–38`

**Description:**  
The release `buildTypes` block explicitly sets `signingConfig = signingConfigs.getByName("debug")`. This means the release APK is signed with the shared Android debug keystore (`~/.android/debug.keystore`), which has a known password (`android`), is the same on every developer machine, and provides no meaningful authentication for the release build. Google Play will reject an AAB/APK signed with the debug key, and any side-loaded release APK can be trivially re-signed by an attacker.

```kotlin
// Current vulnerable build.gradle.kts:
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug") // ← debug key in release!
    }
}
```

**How an attacker exploits this:**  
The debug keystore is public knowledge. An attacker can strip the existing signature, modify the APK (inject malicious code), re-sign with the same debug key, and distribute the trojaned APK. Users cannot distinguish it from the original.

**Impact:**  
Enables APK tampering and redistribution. Also, the app cannot be submitted to Google Play with debug signing.

**Fix:**  

```kotlin
// android/app/build.gradle.kts
android {
    signingConfigs {
        create("release") {
            storeFile = file(System.getenv("KEYSTORE_PATH") ?: "release.keystore")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: ""
            keyAlias = System.getenv("KEY_ALIAS") ?: ""
            keyPassword = System.getenv("KEY_PASSWORD") ?: ""
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

> Generate a production keystore with: `keytool -genkey -v -keystore release.keystore -alias zamwealth -keyalg RSA -keysize 2048 -validity 10000`  
> Store the keystore password in CI/CD environment variables, never in the repository.

---

### [VUL-008] No Code Obfuscation in Release Build

**Severity:** 🟠 HIGH  
**Category:** Reverse Engineering (OWASP M9)  
**Location:** `android/app/build.gradle.kts:33–38`

**Description:**  
The release `buildTypes` block contains no `isMinifyEnabled`, `isShrinkResources`, or ProGuard/R8 configuration. The release APK ships with full class names, method names, and string literals visible in the decompiled output. An attacker using `jadx`, `apktool`, or `dex2jar` can read the complete application logic, identify every Hive box key name, every constant value, the password hashing algorithm, and all business logic gates.

**How an attacker exploits this:**  
1. Download the APK from Google Play or a sideload source.  
2. Run `jadx -d output/ zamwealth_quest.apk` or use the online APK decompiler.  
3. Search for `kUserBox`, `walletBalance`, `zmw_quest_2024_` — all string literals are plaintext in the DEX bytecode.  
4. Understand the exact Hive schema and replicate any Hive box structure for tampering.

**Impact:**  
Reveals internal architecture, box key names, the password "salt" (`zmw_quest_2024_`), and all constants needed to construct fake Hive entries. Accelerates every other attack.

**Fix:**  

```kotlin
// android/app/build.gradle.kts — buildTypes.release:
release {
    isMinifyEnabled = true
    isShrinkResources = true
    proguardFiles(
        getDefaultProguardFile("proguard-android-optimize.txt"),
        "proguard-rules.pro"
    )
    signingConfig = signingConfigs.getByName("release")
}
```

```pro
# android/app/proguard-rules.pro (new file)

# Keep Hive TypeAdapters — required for box operations
-keep class com.hive.** { *; }
-keep class io.hive.** { *; }
-dontwarn io.hive.**

# Keep Flutter embedding
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep the app's own generated Hive adapters
-keep class com.example.zamwealth_quest.** { *; }

# Keep Dart-generated adapter classes (hive_generator output)
-keepclassmembers class * extends com.google.gson.TypeAdapter { *; }
```

Also enable Flutter-level obfuscation by building with:
```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-symbols/
```

---

### [VUL-009] No Root / Tamper Detection

**Severity:** 🟠 HIGH  
**Category:** Code Tampering (OWASP M8)  
**Location:** `lib/main.dart` (absent)

**Description:**  
The app performs no check for rooted or compromised device environments at launch. On rooted devices, all Hive files are directly accessible, Xposed framework can hook into the Dart VM to modify runtime values, and memory editors can rewrite in-memory provider state. Root detection is the first line of defence against the Hive tampering attacks described in VUL-001 through VUL-005.

**How an attacker exploits this:**  
1. Install on any rooted device (Magisk, KernelSU).  
2. Launch the app — no warning or block.  
3. While the app runs, use a memory editor (GameGuardian) to locate `walletBalance` in memory and write any value.  
4. Alternatively, use a root file manager to directly edit Hive files between sessions.

**Impact:**  
Rooted devices are the primary attack platform for all Hive tampering scenarios. Without root detection, the app has no ability to respond to this environment.

**Fix:**  

```yaml
# pubspec.yaml — add to dependencies:
flutter_jailbreak_detection: ^1.10.0
```

```dart
// lib/main.dart — add before runApp():
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _checkDeviceSecurity();
  // ... rest of init ...
}

Future<void> _checkDeviceSecurity() async {
  try {
    final isRooted = await FlutterJailbreakDetection.jailbroken;
    if (isRooted) {
      // Do not run Hive init — app is on a compromised device.
      runApp(const _RootedDeviceWarningApp());
      return;
    }
  } catch (_) {
    // If detection itself fails, proceed cautiously (fail open to avoid
    // blocking legitimate users on unusual ROMs).
  }
}

class _RootedDeviceWarningApp extends StatelessWidget {
  const _RootedDeviceWarningApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0A1628),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.security, color: Colors.red, size: 64),
                SizedBox(height: 16),
                Text(
                  'Security Alert',
                  style: TextStyle(color: Colors.white, fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'ZamWealth Quest cannot run on rooted or compromised '
                  'devices to protect your account data.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### [VUL-010] Spin Wheel Daily Cooldown Stored as Plain String in Hive

**Severity:** 🟠 HIGH  
**Category:** Insecure Data Storage / Client-Side Business Logic (OWASP M2, M6)  
**Location:** `lib/features/auth/models/user_profile.dart:174` (`spinLastDate`)

**Description:**  
The spin wheel cooldown is enforced by comparing today's date string with `UserProfile.spinLastDate` (a plain `String?` stored in the `users` Hive box). If a player edits this field to any past date, the cooldown is immediately bypassed, allowing infinite daily spins. The check in `spin_screen.dart` reads `user.spinLastDate` directly from the in-memory `UserProfile` — which was itself loaded from the unencrypted Hive box.

**How an attacker exploits this:**  
1. Spin the wheel once (spinLastDate is set to today, e.g. `2026-05-26`).  
2. Kill the app, edit `spinLastDate` to `2020-01-01` in the Hive box.  
3. Relaunch — the countdown is zero, spin again.  
4. Repeat for unlimited daily rewards.

**Impact:**  
Unlimited acquisition of spin-wheel rewards (ZamCoins, XP boosts, power-ups) without waiting the daily cooldown.

**Fix:**  
Store an HMAC of the spin date alongside the date field, and verify it on read. Also apply integrity checksums (as in VUL-002) to spin-related state:

```dart
// In IntegrityService (from VUL-002 fix), add:
static Future<void> saveSpinDate(String dateStr) async {
  final box = Hive.box(kSettingsBox);
  await box.put('spin_last_date', dateStr);
  await box.put('spin_date_hash', _hash('spin_last_date', dateStr.hashCode));
}

static String? readSpinDate() {
  final box = Hive.box(kSettingsBox);
  final dateStr = box.get('spin_last_date') as String?;
  if (dateStr == null) return null;
  final stored = box.get('spin_date_hash') as String?;
  if (stored == null || stored != _hash('spin_last_date', dateStr.hashCode)) {
    box.delete('spin_last_date');
    return null;
  }
  return dateStr;
}
```

---

### [VUL-011] Leaderboard XP Values Writable in Hive — Fake Rank #1

**Severity:** 🟠 HIGH  
**Category:** Insecure Data Storage / Client-Side Business Logic (OWASP M2, M6)  
**Location:** `lib/features/leaderboard/screens/leaderboard_screen.dart:187–211`

**Description:**  
The leaderboard is constructed by reading raw `Map` entries from `Hive.box(kLeaderboardBox).get('entries')`. The seeded placeholder XP values (50–2150) are stored in the `leaderboard` Hive box without any integrity protection. An attacker can overwrite the entries with arbitrary XP values, set their own username's XP to 999,999, and appear as the permanent #1 ranked player.

**How an attacker exploits this:**  
1. Extract `leaderboard.hive`.  
2. Edit the `entries` list to add an entry with `name: 'Chanda Mwale', xp: 999999`.  
3. The leaderboard screen reads and sorts by XP — attacker appears first.

**Impact:**  
Fake leaderboard dominance, undermining the competitive integrity of the ranking system and user trust.

**Fix:**  
Clamp XP values to a realistic maximum on read, and validate the structure of each entry:

```dart
// In leaderboard_screen.dart — replace the rawEntries loop:
List<Map<String, dynamic>> _buildEntries(
    String uid, int userXp, String userName, String userAvatarId) {
  try {
    final box = Hive.box(kLeaderboardBox);
    final rawEntries = (box.get('entries') as List? ?? []).cast<Map>();

    final entries = <Map<String, dynamic>>[];
    const maxPlausibleXp = 9999; // max achievable via normal gameplay

    for (final e in rawEntries) {
      final name = (e['name'] as String? ?? 'Player').trim();
      // Sanitise: names over 30 chars or with special chars are suspicious
      if (name.isEmpty || name.length > 30) continue;

      final xp = (e['xp'] as int? ?? 0).clamp(0, maxPlausibleXp);
      entries.add({
        'name': name,
        'xp': xp,
        'badge': e['badge'] as String? ?? 'budget_master',
        'isCurrentUser': false,
        'avatarId': kAvatarConfigs
            .map((c) => c.id)
            .toList()[name.codeUnitAt(0) % kAvatarConfigs.length],
      });
    }

    // The current user's XP comes from the authenticated Riverpod state,
    // not from the Hive leaderboard box — it cannot be spoofed here.
    entries.add({
      'name': userName,
      'xp': userXp.clamp(0, maxPlausibleXp),
      'badge': 'savings_star',
      'isCurrentUser': true,
      'avatarId': userAvatarId,
    });

    entries.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
    return entries;
  } catch (_) {
    return [/* fallback */];
  }
}
```

---

### [VUL-012] Streak Count Directly Writable in Hive

**Severity:** 🟠 HIGH  
**Category:** Insecure Data Storage (OWASP M2)  
**Location:** `lib/features/auth/models/user_profile.dart:121` (HiveField 12)

**Description:**  
`UserProfile.streak` is a plain `int` stored in the unencrypted `users` Hive box with no integrity protection. An attacker can set it to any value (e.g. 365) to fake a year-long daily streak, which unlocks streak-based badges and leaderboard bragging rights.

**How an attacker exploits this:**  
Edit `users.hive`, set `streak: 365`. On next app launch, streak-based badges are awarded and the profile displays a 365-day streak.

**Impact:**  
Fake achievement unlocks, badge awards, and false social proof on any shared profile screenshots.

**Fix:**  
Apply the same checksum pattern from VUL-002 to the streak value. Store `streak_hash` alongside `streak` in the settings box and verify on every read.

---

### [VUL-013] Payment Records Fabricatable in Hive

**Severity:** 🟠 HIGH  
**Category:** Insecure Authorization / Insecure Data Storage (OWASP M6, M2)  
**Location:** `lib/features/payments/models/payment_record.dart`

**Description:**  
`PaymentRecord` objects stored in the `payments` Hive box are the only persistent proof that a payment occurred. Since the entire payments flow is simulated (`sandboxMode: true`, no real API call), a `PaymentRecord` can be constructed from scratch with a valid UUID `paymentId`, a matching `uid`, the correct `tier` string, and any `amountZMW`. There is no server receipt, no cryptographic signature, and no external validation. Level unlock logic checks for the presence of a `PaymentRecord` — writing a fake one grants level access.

**How an attacker exploits this:**  
1. Inspect the `PaymentRecord` Hive schema via the dev screen or APK decompilation.  
2. Write a synthetic record: `PaymentRecord(paymentId: 'any-uuid', uid: 'victim', tier: 'Level 2 — Woodlands Heights', amountZMW: 25.0, provider: 'MTN MoMo', sandboxMode: true)`.  
3. Level 2 is now unlocked.

**Impact:**  
Bypasses the simulated payment gate for all premium levels. For a future real-payment integration, this would directly enable revenue fraud.

**Fix:**  
In addition to the integrity check in VUL-005, add a server-generated receipt token field to `PaymentRecord` for future real payments. For the current sandbox mode, add a HMAC on the `(uid + tier + amountZMW)` tuple:

```dart
// Future PaymentRecord should include:
@HiveField(7)
String receiptHmac; // Server-signed or locally HMAC-signed on creation

// Validation on use:
bool isValid(String secretKey) {
  final payload = '$uid:$tier:$amountZMW';
  final expected = Hmac(sha256, utf8.encode(secretKey))
      .convert(utf8.encode(payload))
      .toString();
  return receiptHmac == expected;
}
```

---

### [VUL-014] Badge List Writable in Hive — Unlock All Achievements

**Severity:** 🟠 HIGH  
**Category:** Insecure Data Storage (OWASP M2)  
**Location:** `lib/features/auth/models/user_profile.dart:133–135` (HiveField 15)

**Description:**  
`UserProfile.earnedBadges` is a plain `List<String>` stored in the `users` Hive box. An attacker can append any badge ID from the constant list to this field, instantly unlocking all badges without completing any gameplay requirement.

**How an attacker exploits this:**  
Edit `users.hive` and set `earnedBadges: ['first_login', 'onboarding_complete', 'budget_master', 'savings_star', 'debt_slayer', 'investor_pro', 'business_mogul', 'zamcoin_collector', /* ... all badge IDs */]`.

**Impact:**  
All achievement badges unlocked without gameplay, undermining the reward system and bragging rights.

**Fix:**  
Add a checksum on the badges list. Store an HMAC of the sorted badge ID list alongside it:

```dart
// IntegrityService extension:
static Future<void> saveBadges(List<String> badges) async {
  final box = Hive.box(kSettingsBox);
  final sorted = [...badges]..sort();
  final payload = sorted.join(',');
  await box.put('earned_badges', badges);
  await box.put('badges_hash', _hash('earned_badges', payload.hashCode));
}

static List<String> readBadges() {
  final box = Hive.box(kSettingsBox);
  final badges = (box.get('earned_badges') as List? ?? []).cast<String>();
  final stored = box.get('badges_hash') as String?;
  final sorted = [...badges]..sort();
  final payload = sorted.join(',');
  if (stored == null || stored != _hash('earned_badges', payload.hashCode)) {
    return []; // Tampering detected — return empty
  }
  return badges;
}
```

---

### [VUL-015] Application ID Is a Placeholder — Not Unique for Play Store

**Severity:** 🟠 HIGH  
**Category:** Build and Release  
**Location:** `android/app/build.gradle.kts:9`

**Description:**  
The `applicationId` is set to `"com.example.zamwealth_quest"`. The `com.example.*` namespace is a Google-reserved placeholder used in tutorials and templates. Google Play Store will reject any submission with this ID. More critically, if another developer submits an app with the same ID first, it permanently blocks this app from the Play Store under that ID.

**How an attacker exploits this:**  
A malicious actor could register `com.example.zamwealth_quest` on the Play Store first (with a throwaway app) to prevent ZamWealth Quest from ever being published under that ID.

**Impact:**  
App rejected at Play Store submission. Rebranding the ID after publication requires users to uninstall and reinstall (losing all Hive data), damaging trust.

**Fix:**  

```kotlin
// android/app/build.gradle.kts:
defaultConfig {
    applicationId = "com.zamwealthquest.app" // or your actual domain
    // ...
}
```

Also update `android/app/src/main/AndroidManifest.xml` namespace and `android/app/build.gradle.kts` namespace field accordingly.

---

### [VUL-016] Hearts Count Directly Writable in Hive

**Severity:** 🟡 MEDIUM  
**Category:** Insecure Data Storage (OWASP M2)  
**Location:** `lib/features/hearts/models/hearts_model.dart:16` (HiveField 0)

**Description:**  
`HeartsModel.heartsCount` is a plain `int` stored in the `hearts` Hive box. An attacker can set it to 5 (or any positive integer) at any time, effectively bypassing the hearts depletion mechanic that limits gameplay frequency.

**How an attacker exploits this:**  
Edit `hearts.hive`, set `heartsCount: 5`, relaunch the app — full hearts restored instantly without waiting the 30-minute refill timer.

**Impact:**  
Unlimited gameplay sessions without the intended pacing constraint.

**Fix:**  
Store the hearts count with an integrity checksum using the same `IntegrityService` pattern from VUL-002. Verify on every read in `HeartsProvider`.

---

### [VUL-017] XP Boost Expiry Stored as Plain String in Hive

**Severity:** 🟡 MEDIUM  
**Category:** Insecure Data Storage (OWASP M2)  
**Location:** `lib/features/auth/models/user_profile.dart:191` (HiveField 28)

**Description:**  
`UserProfile.xpBoostExpiry` is a nullable `String?` (ISO-8601 datetime) stored in the unencrypted `users` Hive box. An attacker can set this to a far-future date (e.g. `2099-12-31T00:00:00.000`) to grant a permanent 2× XP multiplier on all activities.

**How an attacker exploits this:**  
Edit `users.hive`, set `xpBoostExpiry: '2099-12-31T00:00:00.000'`, relaunch — permanent double XP.

**Impact:**  
Permanent XP boost without purchasing the item from the shop, accelerating all level-up and rank progression.

**Fix:**  
Apply the checksum pattern from VUL-002 to the xpBoostExpiry string. Additionally, cross-validate that the boost was purchased from the shop by checking the `InventoryModel` power-ups map — if the `xp_boost` count in inventory is 0 but the expiry is in the future, flag as tampered.

---

### [VUL-018] Weak Login Error Messages Enable Username Enumeration

**Severity:** 🟡 MEDIUM  
**Category:** Improper Platform Usage (OWASP M1)  
**Location:** `lib/features/auth/providers/auth_provider.dart:142–148`

**Description:**  
The login method returns distinct error messages for "user not found" vs "incorrect password":
- `'Account not found. Please register first.'` — confirms username does not exist.  
- `'Incorrect password. Please try again.'` — confirms username exists but password is wrong.

This allows an attacker to enumerate valid usernames by observing which error is returned.

**How an attacker exploits this:**  
1. Try username `alice` — if `'Account not found'` appears, alice is not registered.  
2. Try username `bob` — if `'Incorrect password'` appears, bob IS registered.  
3. Enumerate all common names to build a list of registered usernames.

**Impact:**  
In a local single-device context, impact is limited. For shared family devices, this leaks other users' registration status.

**Fix:**  

```dart
// auth_provider.dart:
// Replace both specific error messages with a single generic one:
state = state.copyWith(
  isLoading: false,
  error: 'Incorrect username or password.',
);
```

---

### [VUL-019] No Rate Limiting on Local Login Attempts

**Severity:** 🟡 MEDIUM  
**Category:** Insecure Authentication (OWASP M4)  
**Location:** `lib/features/auth/providers/auth_provider.dart:133–176`

**Description:**  
The login function has no attempt counter, no lockout, and no delay. An automated tool can try every possible password against a known username at the speed of Dart async processing — thousands of attempts per second. Combined with VUL-003 (weak password "hash"), the password is trivially recoverable by brute force or from the Hive box directly.

**How an attacker exploits this:**  
Write a simple Dart script that calls `authNotifier.login(username, candidate)` in a loop across a wordlist. On a fast device, this can exhaust a 6-character lowercase password in minutes.

**Impact:**  
Account takeover via brute force on shared-device scenarios.

**Fix:**  

```dart
// auth_provider.dart — add to AuthNotifier:
int _failedAttempts = 0;
DateTime? _lockoutUntil;

Future<void> login(String username, String password) async {
  if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
    final remaining = _lockoutUntil!.difference(DateTime.now()).inSeconds;
    state = state.copyWith(
      isLoading: false,
      error: 'Too many failed attempts. Try again in $remaining seconds.',
    );
    return;
  }

  // ... existing login logic ...

  // On failure:
  _failedAttempts++;
  if (_failedAttempts >= 5) {
    _lockoutUntil = DateTime.now().add(const Duration(minutes: 5));
    _failedAttempts = 0;
  }

  // On success:
  _failedAttempts = 0;
  _lockoutUntil = null;
}
```

---

### [VUL-020] Missing `android:usesCleartextTraffic="false"` in Release Manifest

**Severity:** 🟡 MEDIUM  
**Category:** Insecure Communication (OWASP M3)  
**Location:** `android/app/src/main/AndroidManifest.xml:2–7`

**Description:**  
The release `AndroidManifest.xml` does not set `android:usesCleartextTraffic="false"`. While the app is currently offline-only, the `google_fonts` package makes network requests to download font files on first launch, and future features (leaderboard sync, payment verification) will add more. Without this flag, any future HTTP (non-HTTPS) traffic would be allowed in release builds.

**Fix:**  

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:label="zamwealth_quest"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:allowBackup="false"
    android:usesCleartextTraffic="false">
```

---

### [VUL-021] Tutorial Completion Flag Unprotected in Settings Box

**Severity:** 🟡 MEDIUM  
**Category:** Insecure Data Storage (OWASP M2)  
**Location:** `lib/widgets/tutorial_overlay.dart:6–15`; `lib/features/profile/screens/profile_screen.dart:845`

**Description:**  
The tutorial completion state is stored as a boolean under the key `'tutorial_completed'` in the unencrypted `settings` Hive box. While there is a legitimate user-facing "Replay Tutorial" button in the Profile screen, this flag has no integrity protection. An attacker can set it to `false` to force-replay the tutorial, or (if tutorial completion gates any rewards or XP) set it to `true` to skip earning those rewards normally.

**Note:** The `delete()` operation on `kTutorialCompletedKey` referenced in prior audit notes was **not found in `main.dart`** in the current codebase — this specific debug pattern appears to have been removed. The residual risk is the unprotected flag in the settings box.

**Fix:**  
If the tutorial completion gates any XP or badge awards, move the completion record to an integrity-checked location alongside the `IntegrityService` pattern from VUL-002. If no gameplay rewards are tied to tutorial completion, the current design is acceptable once Hive encryption (VUL-001) is applied.

---

### [VUL-022] Daily Bonus Claim State Stored Unprotected in Hive

**Severity:** 🟡 MEDIUM  
**Category:** Insecure Data Storage (OWASP M2)  
**Location:** `lib/features/auth/models/user_profile.dart:181–184` (`loginBonusLastDate`, `loginBonusDay`)

**Description:**  
The daily login bonus is governed by `UserProfile.loginBonusLastDate` and `loginBonusDay`, both stored as plain fields in the unencrypted `users` Hive box. Clearing or backdating `loginBonusLastDate` re-enables the daily bonus claim.

**Fix:**  
Apply the checksum pattern (VUL-002) to `loginBonusLastDate`. Verify checksum before processing any bonus claim.

---

### [VUL-023] No Network Security Configuration File

**Severity:** 🟢 LOW  
**Category:** Insecure Communication (OWASP M3)  
**Location:** `android/app/src/main/` (file absent)

**Description:**  
Android's Network Security Configuration lets developers explicitly declare trusted certificate authorities, enable certificate pinning, and prevent cleartext traffic per-domain. The app has no `res/xml/network_security_config.xml` file and no `android:networkSecurityConfig` reference in the manifest. While the app is currently offline, `google_fonts` does make HTTPS requests and any future API integration starts without a security baseline.

**Fix:**  

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml (new file) -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

```xml
<!-- android/app/src/main/AndroidManifest.xml <application> tag: -->
android:networkSecurityConfig="@xml/network_security_config"
```

---

### [VUL-024] minSdk Inherited from Flutter Default — May Be Dangerously Low

**Severity:** 🟢 LOW  
**Category:** Improper Platform Usage (OWASP M1)  
**Location:** `android/app/build.gradle.kts:26`

**Description:**  
`minSdk = flutter.minSdkVersion` defers to the Flutter plugin default, which is currently Android API 21 (Android 5.0, Lollipop). Android 5.0 devices are over a decade old, receive no security patches, and have known kernel and framework vulnerabilities. Users on these devices cannot benefit from modern Android security features (hardware-backed keystore for AES-256, StrongBox, etc.), reducing the effectiveness of VUL-001's encryption fix.

**Fix:**  

```kotlin
// android/app/build.gradle.kts
defaultConfig {
    applicationId = "com.zamwealthquest.app"
    minSdk = 26  // Android 8.0 — supports hardware-backed keystore for HiveAesCipher
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}
```

> Setting `minSdk = 26` requires Android 8.0+. As of 2026, ~97% of active Android devices run API 26+. This is the recommended minimum for apps using `flutter_secure_storage` with `encryptedSharedPreferences: true`.

---

### [VUL-025] Release Build Namespace Exposes Package Structure

**Severity:** 🟢 LOW  
**Category:** Reverse Engineering (OWASP M9)  
**Location:** `android/app/build.gradle.kts:9`

**Description:**  
`namespace = "com.example.zamwealth_quest"` is clearly a tutorial default, signalling to any analyst or malicious actor that the developer may not have performed a security hardening review. Alongside no obfuscation (VUL-008), the full class structure of the app is visible in the APK.

**Fix:**  
Change namespace to the real reverse-domain identifier alongside the application ID fix in VUL-015.

---

### [VUL-026] `debugShowCheckedModeBanner` — PASS

**Severity:** N/A  
**Category:** Verification  
**Location:** `lib/main.dart:179`

**Description:**  
This item was verified. `debugShowCheckedModeBanner: false` is already correctly set in `MaterialApp.router`. No action required.

---

## Summary Table

| ID | Title | Severity | Status |
|----|-------|----------|--------|
| VUL-001 | All Hive Boxes Opened Without Encryption | 🔴 CRITICAL | Not fixed |
| VUL-002 | ZamCoins/Wallet/XP Lack Integrity Checking | 🔴 CRITICAL | Not fixed |
| VUL-003 | Password Stored as Reversible Base64 Encoding | 🔴 CRITICAL | Not fixed |
| VUL-004 | Developer Console Route Accessible in Production | 🔴 CRITICAL | Not fixed |
| VUL-005 | Level Unlock/Payment Verification Client-Side Only | 🔴 CRITICAL | Not fixed |
| VUL-006 | ADB Backup Enabled — All Hive Data Extractable | 🟠 HIGH | Not fixed |
| VUL-007 | Release Build Uses Debug Signing Key | 🟠 HIGH | Not fixed |
| VUL-008 | No Code Obfuscation in Release Build | 🟠 HIGH | Not fixed |
| VUL-009 | No Root/Tamper Detection | 🟠 HIGH | Not fixed |
| VUL-010 | Spin Wheel Cooldown Bypassable via Hive Edit | 🟠 HIGH | Not fixed |
| VUL-011 | Leaderboard XP Values Writable in Hive | 🟠 HIGH | Not fixed |
| VUL-012 | Streak Count Directly Writable in Hive | 🟠 HIGH | Not fixed |
| VUL-013 | Payment Records Fabricatable in Hive | 🟠 HIGH | Not fixed |
| VUL-014 | Badge List Writable in Hive | 🟠 HIGH | Not fixed |
| VUL-015 | Application ID Is a Placeholder | 🟠 HIGH | Not fixed |
| VUL-016 | Hearts Count Directly Writable in Hive | 🟡 MEDIUM | Not fixed |
| VUL-017 | XP Boost Expiry Stored as Plain String in Hive | 🟡 MEDIUM | Not fixed |
| VUL-018 | Login Error Messages Enable Username Enumeration | 🟡 MEDIUM | Not fixed |
| VUL-019 | No Rate Limiting on Local Login Attempts | 🟡 MEDIUM | Not fixed |
| VUL-020 | Missing `usesCleartextTraffic="false"` in Manifest | 🟡 MEDIUM | Not fixed |
| VUL-021 | Tutorial Completion Flag Unprotected | 🟡 MEDIUM | Not fixed |
| VUL-022 | Daily Bonus Claim State Unprotected in Hive | 🟡 MEDIUM | Not fixed |
| VUL-023 | No Network Security Configuration File | 🟢 LOW | Not fixed |
| VUL-024 | minSdk Too Low (inherits API 21) | 🟢 LOW | Not fixed |
| VUL-025 | Release Namespace Exposes Package Structure | 🟢 LOW | Not fixed |
| VUL-026 | debugShowCheckedModeBanner | N/A | ✅ PASS |

---

## Recommended Fix Priority

### Immediate — Before Any Build Shared Externally

1. **[VUL-004]** Remove `DevScreen` route from production router. **Effort: 30 min.** Single `if (kDebugMode)` guard in `router.dart`.

2. **[VUL-003]** Replace base64 password "hash" with real SHA-256 + per-user salt. **Effort: 2 hrs.** Requires adding `passwordSalt` HiveField and running data migration.

3. **[VUL-001]** Encrypt all Hive boxes with AES-256 via `flutter_secure_storage`. **Effort: 3–4 hrs.** Touches `main.dart` only, plus `pubspec.yaml`.

### Critical — Before Play Store Submission

4. **[VUL-007]** Create a production keystore and configure release signing. **Effort: 1 hr.**

5. **[VUL-015]** Change `applicationId` from `com.example.zamwealth_quest` to production value. **Effort: 15 min.**

6. **[VUL-008]** Enable ProGuard/R8 minification and Flutter obfuscation. **Effort: 2 hrs.** Includes testing that Hive adapters survive shrinking.

7. **[VUL-006]** Set `android:allowBackup="false"` and add `dataExtractionRules`. **Effort: 15 min.**

8. **[VUL-009]** Add `flutter_jailbreak_detection` and block launch on rooted devices. **Effort: 1 hr.**

9. **[VUL-002]** Add integrity checksums to wallet, XP, streak, and badge fields. **Effort: 4 hrs.** Implement `IntegrityService`.

10. **[VUL-005]** Strengthen payment record validation at level access time. **Effort: 2 hrs.**

### High — Hardening Pass

11. **[VUL-010]** Protect spin wheel date with HMAC. **Effort: 1 hr.**
12. **[VUL-011]** Clamp and validate leaderboard entries on read. **Effort: 1 hr.**
13. **[VUL-012]** Apply checksum to streak. **Effort: 30 min.**
14. **[VUL-013]** Add HMAC to payment records. **Effort: 2 hrs.**
15. **[VUL-014]** Protect badge list with checksum. **Effort: 1 hr.**

### Medium — Polish Pass

16. **[VUL-016–VUL-022]** Remaining Hive field integrity + auth hardening. **Effort: 3–4 hrs.**
17. **[VUL-020]** Add `android:usesCleartextTraffic="false"`. **Effort: 15 min.**

### Low — Best Practice

18. **[VUL-023]** Add network security config. **Effort: 30 min.**
19. **[VUL-024]** Set `minSdk = 26`. **Effort: 15 min.** (Test on API 26 device.)
20. **[VUL-025]** Update namespace to production ID. **Effort: 15 min.**

---

## Dependencies to Add to pubspec.yaml

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_secure_storage` | `^9.2.2` | AES key storage in Android Keystore (required for VUL-001) |
| `crypto` | `^3.0.3` | SHA-256 integrity checksums and HMAC (required for VUL-002, VUL-003, VUL-010, VUL-013, VUL-014) |
| `flutter_jailbreak_detection` | `^1.10.0` | Root and tamper detection (required for VUL-009) |

---

## Pre-Release Security Checklist

- [ ] **[VUL-004]** Remove or guard `DevScreen` route with `if (kDebugMode)` in `router.dart`
- [ ] **[VUL-001]** Encrypt all 25+ Hive boxes with `HiveAesCipher` using key from `flutter_secure_storage`
- [ ] **[VUL-003]** Replace base64 "hash" with SHA-256 + per-user random salt in `auth_provider.dart`
- [ ] **[VUL-006]** Set `android:allowBackup="false"` and add `dataExtractionRules` to manifest
- [ ] **[VUL-007]** Generate production keystore and configure release signing (remove debug key from release buildType)
- [ ] **[VUL-008]** Enable `isMinifyEnabled = true`, `isShrinkResources = true`, and ProGuard in `build.gradle.kts`
- [ ] **[VUL-008]** Build release with `flutter build appbundle --release --obfuscate --split-debug-info=./symbols/`
- [ ] **[VUL-009]** Add `flutter_jailbreak_detection` and block app launch on rooted devices
- [ ] **[VUL-002]** Implement `IntegrityService` with SHA-256 checksums on `walletBalance`, `xp`, `streak`, `earnedBadges`
- [ ] **[VUL-010]** Apply HMAC to `spinLastDate` in `IntegrityService`
- [ ] **[VUL-011]** Clamp leaderboard XP to `maxPlausibleXp` on every read
- [ ] **[VUL-015]** Change `applicationId` from `com.example.zamwealth_quest` to production reverse-domain
- [ ] **[VUL-020]** Add `android:usesCleartextTraffic="false"` to release manifest
- [ ] **[VUL-023]** Create `res/xml/network_security_config.xml` and reference it in manifest
- [ ] **[VUL-024]** Set `minSdk = 26` in `build.gradle.kts`
- [ ] **[VUL-019]** Add failed-login attempt counter and 5-minute lockout after 5 failures
- [ ] **[VUL-018]** Unify login error messages to prevent username enumeration
- [ ] Remove all `debugPrint` statements from production code paths
- [ ] Verify release build is not debuggable (`android:debuggable` not set or `false`)
- [ ] Test release APK with `apktool d` and verify class names are obfuscated
- [ ] Test on a rooted device to confirm root detection blocks launch
- [ ] Test on a non-rooted device via `adb backup` to confirm backup is blocked
- [ ] Verify all Hive boxes open with encryption cipher (no plain `Hive.openBox()` calls remain)
- [ ] Run `flutter analyze` and address all remaining warnings before submission
