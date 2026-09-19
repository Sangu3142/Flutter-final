/// secure_hive.dart
/// Purpose: AES-256 encryption for every Hive box — key management via the
///          platform keystore, one-time migration of existing plaintext boxes,
///          and recovery when the key is no longer available.
/// Reads from: platform secure storage, Hive boxes (legacy + encrypted)
/// Writes to: Hive boxes (encrypted), Hive box 'zw_migration'
/// Navigation: none
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';

/// Secure-storage key under which the AES-256 Hive key is kept.
const String _kHiveKeyName = 'hive_encryption_key';

/// Migration-box key prefix: `enc_migrated_<boxName>` → bool.
const String _kMigratedPrefix = 'enc_migrated_';

/// Migration-box key set when a box had to be wiped because it could not be
/// decrypted. The UI can read this once to tell the player what happened.
const String kEncResetOccurredKey = 'enc_reset_occurred';

const FlutterSecureStorage _storage = FlutterSecureStorage(
  // encryptedSharedPreferences routes the key through the Android Keystore
  // rather than a plain SharedPreferences file. Requires API 23+; the project
  // inherits Flutter's default minSdk of 24, so this is satisfied.
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

// ─────────────────────────────────────────────────────────────────────────────
// Key management
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the app's [HiveAesCipher], generating and storing a key on first
/// launch.
///
/// The key lives in the Android Keystore / iOS Keychain, never in a file the
/// app itself can be tricked into reading, and is not included in cloud
/// backups. Extracting the `.hive` files (root, or `adb backup`) therefore
/// yields ciphertext only.
///
/// Call [openMigrationBox] first so key loss can be recorded.
Future<HiveAesCipher> getHiveCipher() async {
  final existing = await _storage.read(key: _kHiveKeyName);
  if (existing != null) {
    try {
      return HiveAesCipher(base64Decode(existing));
    } catch (_) {
      // Stored value is corrupt — fall through and mint a new key.
    }
  }

  // No usable key. If encrypted boxes already exist on disk, the key was lost
  // (device restore, app-data clear, keystore reset) and their contents are
  // unrecoverable — Hive will silently truncate them on open rather than
  // throwing. Record it here, where the signal is unambiguous, so the app can
  // tell the player instead of quietly showing a blank profile.
  if (await _encryptedBoxesExist()) {
    await _recordEncryptionReset();
  }

  final key = Hive.generateSecureKey();
  await _storage.write(key: _kHiveKeyName, value: base64Encode(key));
  return HiveAesCipher(key);
}

Future<bool> _encryptedBoxesExist() async {
  for (final name in kLegacyBoxNames.keys) {
    if (await Hive.boxExists(name)) return true;
  }
  return false;
}

Future<void> _recordEncryptionReset() async {
  try {
    final box = Hive.isBoxOpen(kMigrationBox)
        ? Hive.box(kMigrationBox)
        : await Hive.openBox(kMigrationBox);
    await box.put(kEncResetOccurredKey, true);
  } catch (_) {}
}

// ─────────────────────────────────────────────────────────────────────────────
// Box opening + migration
// ─────────────────────────────────────────────────────────────────────────────

/// Opens the unencrypted bookkeeping box that tracks migration state.
///
/// Deliberately plaintext — it holds only flags, and it has to be readable
/// before any cipher-protected box is opened. Must be awaited once before the
/// first [openSecureBox] call.
Future<Box> openMigrationBox() => Hive.openBox(kMigrationBox);

/// Opens [name] with [cipher], migrating the corresponding plaintext box from
/// [kLegacyBoxNames] on first run.
///
/// Migration order is deliberate and crash-safe:
///
///   1. copy every entry from the legacy box into the encrypted box,
///   2. flush,
///   3. only then set the migrated flag,
///   4. only then delete the plaintext file.
///
/// A crash at any step leaves the legacy box intact with the flag unset, so
/// the next launch simply repeats the copy. There is no point at which the
/// data exists in neither box.
///
/// If the box cannot be opened at all, it is wiped and recreated empty so the
/// app still launches, and [kEncResetOccurredKey] is set. This is a deliberate
/// trade: local progress in that box is lost, but the alternative is an app
/// that can never start again.
///
/// Note that a *wrong key* usually does not reach this catch — Hive treats
/// undecryptable frames as corruption and silently truncates the box. That
/// case is detected earlier, in [getHiveCipher], which is where the missing
/// key is actually observable. This catch covers genuine open failures.
Future<Box<T>> openSecureBox<T>(String name, HiveAesCipher cipher) async {
  final migrationBox = Hive.box(kMigrationBox);
  final migratedKey = '$_kMigratedPrefix$name';
  final alreadyMigrated =
      migrationBox.get(migratedKey, defaultValue: false) as bool;

  if (!alreadyMigrated) {
    await _migrateLegacyBox<T>(name, cipher, migrationBox, migratedKey);
  }

  try {
    return await Hive.openBox<T>(name, encryptionCipher: cipher);
  } catch (e) {
    // Undecryptable (lost key) or corrupt. Wipe and recreate.
    if (kDebugMode) debugPrint('secure_hive: recovering box "$name": $e');
    await _wipeBox(name);
    await migrationBox.put(kEncResetOccurredKey, true);
    return Hive.openBox<T>(name, encryptionCipher: cipher);
  }
}

/// Copies an existing plaintext box into its encrypted replacement.
Future<void> _migrateLegacyBox<T>(
  String name,
  HiveAesCipher cipher,
  Box migrationBox,
  String migratedKey,
) async {
  final legacyName = kLegacyBoxNames[name];

  // Nothing to migrate: unknown box, or a fresh install.
  if (legacyName == null || !await Hive.boxExists(legacyName)) {
    await migrationBox.put(migratedKey, true);
    return;
  }

  try {
    final legacy = await Hive.openBox<T>(legacyName);
    final encrypted = await Hive.openBox<T>(name, encryptionCipher: cipher);

    for (final key in legacy.keys) {
      final value = legacy.get(key);
      if (value != null) await encrypted.put(key, value);
    }

    await encrypted.flush();
    await migrationBox.put(migratedKey, true); // (3) point of no return
    await legacy.close();
    await encrypted.close();
    await Hive.deleteBoxFromDisk(legacyName); // (4) plaintext gone
  } catch (e) {
    // Leave the flag unset — the next launch retries from the intact legacy
    // box. Do not rethrow: one bad box must not stop the app from starting.
    if (kDebugMode) {
      debugPrint('secure_hive: migration of "$legacyName" deferred: $e');
    }
  }
}

Future<void> _wipeBox(String name) async {
  try {
    if (Hive.isBoxOpen(name)) await Hive.box<dynamic>(name).close();
  } catch (_) {}
  try {
    await Hive.deleteBoxFromDisk(name);
  } catch (_) {}
}

// ─────────────────────────────────────────────────────────────────────────────
// Diagnostics
// ─────────────────────────────────────────────────────────────────────────────

/// True if any box had to be wiped because it could not be decrypted.
bool get encryptionResetOccurred {
  try {
    return Hive.box(kMigrationBox)
        .get(kEncResetOccurredKey, defaultValue: false) as bool;
  } catch (_) {
    return false;
  }
}

/// Clears the reset flag after the user has been told about it once.
Future<void> clearEncryptionResetFlag() async {
  try {
    await Hive.box(kMigrationBox).delete(kEncResetOccurredKey);
  } catch (_) {}
}
