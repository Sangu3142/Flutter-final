# Security Audit

This document catalogues all security concerns identified in the ZamWealth Quest codebase. The app is fully offline with no server-side authentication, so the threat model is focused on local data integrity, device-level access, and accidental data exposure.

---

## Issue 1 — All Hive Boxes Are Unencrypted

**Severity:** HIGH

**Location:** `lib/main.dart` — all 26 `Hive.openBox()` calls

**Description:** Every Hive box is opened without an `encryptionCipher` argument. All user data — including wallet balances, XP, level progress, payment records, family financial models, loan records, and savings goals — is stored as plaintext in the app's data directory. On a rooted Android device, any app with root access can read or modify this data using a Hive viewer or hex editor.

**Data at risk:**
- `UserProfile.walletBalance` — in-game currency
- `UserProfile.xp`, `currentLevel`, `unlockedLevels` — all game progress
- All financial simulation data (loans, property, investments, savings)
- `UserProfile.passwordHash` — the user's hashed password

**Recommended Fix:**

```dart
// Generate and securely store a key using flutter_secure_storage
final secureStorage = const FlutterSecureStorage();
var encryptionKeyString = await secureStorage.read(key: 'hive_key');
if (encryptionKeyString == null) {
  final key = Hive.generateSecureKey();
  await secureStorage.write(key: 'hive_key', value: base64UrlEncode(key));
  encryptionKeyString = base64UrlEncode(key);
}
final encryptionKey = base64Url.decode(encryptionKeyString);
final cipher = HiveAesCipher(encryptionKey);

// Use cipher when opening sensitive boxes
await Hive.openBox<UserProfile>(kUserBox, encryptionCipher: cipher);
await Hive.openBox<PaymentRecord>(kPaymentBox, encryptionCipher: cipher);
```

At minimum, encrypt `kUserBox` and `kPaymentBox`. The `kLeaderboardBox` (fictional data) does not need encryption.

---

## Issue 2 — Password Hash Implementation Unknown

**Severity:** HIGH

**Location:** `lib/features/auth/models/user_profile.dart` field 3 (`passwordHash`)

**Description:** `UserProfile` stores a `passwordHash` field. The hashing algorithm used in `AuthNotifier` (the registration/login flow) was not fully read. If the implementation uses a weak scheme (MD5, SHA-1, or plain SHA-256 without salt), passwords are vulnerable to dictionary attacks on a rooted device.

**Data at risk:** The `passwordHash` stored in the unencrypted `users` Hive box.

**Recommended Fix:** Use `bcrypt` or `argon2` for password hashing. If the current implementation uses a custom scheme, replace it with the `crypto` package using PBKDF2 with a random salt per user, or add the `bcrypt` package. Store the salt alongside the hash.

Since ZamWealth Quest is a local-only app with educational fictional finances, the immediate risk is low, but this should be addressed before any real-money features are added.

---

## Issue 3 — kTutorialCompletedKey Delete Line Must Be Removed Before Release

**Severity:** HIGH

**Location:** `lib/main.dart` (check for presence) or `lib/widgets/tutorial_overlay.dart`

**Description:** During development, a line that deletes `kTutorialCompletedKey` from kSettingsBox was added to force-reset the tutorial on every launch for testing. If this line exists at release time, every user will be forced through the tutorial on every app start.

**Data at risk:** User experience (tutorial restarts), and `kTutorialCompletedKey` state.

**Recommended Fix:** Search for and remove any `Hive.box(kSettingsBox).delete(kTutorialCompletedKey)` call before building the release APK. Gate it behind `kDebugMode` or a `sandboxMode` flag if needed during QA.

```dart
// MUST NOT ship to production:
if (kDebugMode) {
  Hive.box(kSettingsBox).delete(kTutorialCompletedKey);
}
```

---

## Issue 4 — No Server-Side Authentication

**Severity:** MEDIUM

**Location:** `lib/features/auth/providers/auth_provider.dart`

**Description:** Authentication is entirely local. There is no server, no JWT, no OAuth. The user's identity is verified by comparing the entered password hash against the stored hash in the `users` Hive box. This means:
- There is no way to recover a forgotten password.
- A user on a rooted device can impersonate any other user on the same device by writing their uid to `kSessionBox`.
- Usernames are not globally unique — two devices can have users with the same username with no conflict.

**Risk Level:** For the current offline, educational use case, this is acceptable. For any future multi-device or cloud sync feature, full authentication would need to be added.

**Recommended Fix:** If multi-device support is added, implement server-side auth (Firebase Auth or Supabase Auth). For the current single-device offline use case, document this as an accepted limitation.

---

## Issue 5 — Leaderboard Data Is Modifiable on Rooted Devices

**Severity:** MEDIUM

**Location:** `lib/main.dart` `_seedLeaderboard()` → `kLeaderboardBox`

**Description:** The 9 fictional leaderboard entries are stored unencrypted in the `leaderboard` Hive box under the key `'entries'`. The current user's live rank is computed from `authProvider` (reactive), but the fictional player data is static in Hive. A rooted user could modify the fictional players' XP values to place themselves at any rank.

**Risk Level:** Low for the current offline, non-competitive use case. The leaderboard is primarily motivational (showing fictional Zambian player names and XP). No real prizes are awarded based on rank.

**Recommended Fix:** If a competitive leaderboard is added in the future, move the leaderboard to a server. For the current fictional leaderboard, document this as an accepted limitation.

---

## Issue 6 — No Input Validation on User-Entered Values

**Severity:** MEDIUM

**Location:** `lib/features/auth/screens/register_screen.dart`, `lib/features/auth/screens/login_screen.dart`, all budget/savings/loan input screens

**Description:** User-entered text fields (username, name, password, financial amounts) are not validated for:
- Minimum/maximum length
- Character whitelist (allows special characters that could confuse Hive key lookups)
- Numeric range validation on financial inputs (e.g., entering a negative loan amount)

**Risk Level:** Since all data is local and the app is offline, there is no injection vector. However, invalid data (e.g., a username with a `/` character) could corrupt Hive key lookups that use `'<uid>_<levelId>'` patterns.

**Recommended Fix:** Add input validation on registration (alphanumeric usernames only, max 20 chars). Add range validation on all financial input fields (> 0, < reasonable max).

---

## Issue 7 — sandboxMode Flag Has No Authentication Gate

**Severity:** LOW

**Location:** `lib/core/constants.dart` and DevScreen

**Description:** `'sandboxMode'` in kSettingsBox, when set to `true`, presumably enables developer features. This flag is readable and writable by any code on the device. There is no PIN, password, or build-mode gate preventing a regular user from enabling sandbox mode.

**Recommended Fix:** Gate sandboxMode behind `kDebugMode || kProfileMode` — it should be impossible to enable in a release build.

```dart
bool get isSandboxMode =>
    (kDebugMode || kProfileMode) &&
    (Hive.box(kSettingsBox).get('sandboxMode', defaultValue: false) as bool);
```

---

## Issue 8 — Riverpod State Not Persisted Securely

**Severity:** LOW

**Location:** All Riverpod providers

**Description:** Riverpod state lives in memory and is derived from Hive. Since the Hive boxes are unencrypted (Issue 1), all Riverpod state is also unencrypted at rest. Additionally, Riverpod state is not encrypted in transit between providers (it is in-memory, so this is expected — but worth noting for future background isolate or cross-process use cases).

**Risk Level:** Low — this is the inherent consequence of Issue 1. Fixing Issue 1 addresses the at-rest exposure.

---

## Issue 9 — kTutorialCompletedKey Is Global (Not Per-User)

**Severity:** LOW

**Location:** `lib/widgets/tutorial_overlay.dart`

**Description:** `kTutorialCompletedKey = 'tutorial_completed'` is stored without a uid prefix, unlike most other per-user settings. This means if two user accounts are on the same device, completing the tutorial for User A also marks it as complete for User B (and any future user).

**Risk Level:** Low — for most users this is acceptable or even desirable. A first-time user on a shared device will still see the tutorial if no account has completed it. But for QA and testing, it makes resetting the tutorial state harder.

**Recommended Fix:** Change the key to `'tutorial_completed_$uid'` to make it per-user. Update `markTutorialComplete(uid)` and `isTutorialDone(uid)` to accept and use the uid.
