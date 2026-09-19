/// password_hasher.dart
/// Purpose: PBKDF2-HMAC-SHA256 password hashing, verification, and one-way
///          migration off the old reversible base64 scheme.
/// Reads from: nothing
/// Writes to: nothing (pure functions — callers persist the result)
/// Navigation: none
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Format
// ─────────────────────────────────────────────────────────────────────────────
//
// Stored hashes are self-describing strings:
//
//     pbkdf2$sha256$<iterations>$<saltBase64>$<derivedKeyBase64>
//
// Everything needed to verify a password lives inside the string, so the
// iteration count can be raised later without invalidating existing accounts
// and without adding a HiveField to UserProfile.

/// Prefix identifying the current hash format.
const String kPbkdf2Prefix = 'pbkdf2';

/// PBKDF2 iteration count for new hashes.
///
/// Tuned for low-end Android hardware: high enough that offline guessing is
/// expensive, low enough that login stays responsive on the budget devices
/// this app targets. Raising it later is safe — old hashes carry their own
/// iteration count and keep verifying.
const int kPbkdf2Iterations = 50000;

/// Salt length in bytes (128-bit, per NIST SP 800-132).
const int kSaltLengthBytes = 16;

/// Derived key length in bytes (256-bit, matching the SHA-256 block output).
const int kDerivedKeyLengthBytes = 32;

/// Static prefix used by the pre-2026 reversible "hash". Retained solely so
/// legacy records can be recognised and upgraded. Never used for new hashes.
const String _kLegacySaltPrefix = 'zmw_quest_2024_';

final Random _secureRandom = Random.secure();

// ─────────────────────────────────────────────────────────────────────────────
// Public API
// ─────────────────────────────────────────────────────────────────────────────

/// Hashes [password] with a fresh random salt.
///
/// Returns the full self-describing string to store in
/// `UserProfile.passwordHash`.
String hashPassword(String password, {int iterations = kPbkdf2Iterations}) {
  final salt = _generateSalt();
  return _encode(
    iterations: iterations,
    salt: salt,
    derivedKey: _pbkdf2(
      password: password,
      salt: salt,
      iterations: iterations,
      keyLength: kDerivedKeyLengthBytes,
    ),
  );
}

/// Verifies [password] against a [stored] hash.
///
/// Handles both the current PBKDF2 format and the legacy base64 scheme, so an
/// account whose hash has not been migrated yet can still log in. Use
/// [needsRehash] afterwards to decide whether to upgrade the stored value.
bool verifyPassword(String password, String stored) {
  if (stored.isEmpty) return false;

  if (!isLegacyHash(stored)) {
    final parts = stored.split(r'$');
    // pbkdf2 $ sha256 $ iterations $ salt $ key
    if (parts.length != 5) return false;
    if (parts[0] != kPbkdf2Prefix || parts[1] != 'sha256') return false;

    final iterations = int.tryParse(parts[2]);
    if (iterations == null || iterations <= 0) return false;

    final Uint8List salt;
    final Uint8List expected;
    try {
      salt = base64Decode(parts[3]);
      expected = base64Decode(parts[4]);
    } catch (_) {
      return false;
    }

    final actual = _pbkdf2(
      password: password,
      salt: salt,
      iterations: iterations,
      keyLength: expected.length,
    );
    return _constantTimeEquals(actual, expected);
  }

  // Legacy path: recompute the old encoding and compare.
  return stored == _legacyEncode(password);
}

/// True when [stored] uses the old reversible base64 encoding.
bool isLegacyHash(String stored) => !stored.startsWith('$kPbkdf2Prefix\$');

/// True when [stored] should be re-hashed — either it is legacy, or it was
/// produced with fewer iterations than we now require.
bool needsRehash(String stored, {int iterations = kPbkdf2Iterations}) {
  if (isLegacyHash(stored)) return true;
  final parts = stored.split(r'$');
  if (parts.length != 5) return true;
  final storedIterations = int.tryParse(parts[2]);
  return storedIterations == null || storedIterations < iterations;
}

/// Recovers the plaintext password from a legacy hash.
///
/// This is possible precisely because the old scheme was base64 **encoding**,
/// not hashing — which is the vulnerability being fixed. It exists only so
/// existing accounts can be migrated to PBKDF2 without forcing a password
/// reset, and it is called exactly once per account, at startup. Returns null
/// if [stored] is not a decodable legacy hash.
String? recoverLegacyPassword(String stored) {
  if (!isLegacyHash(stored)) return null;
  try {
    final decoded = utf8.decode(base64Decode(stored));
    if (!decoded.startsWith(_kLegacySaltPrefix)) return null;
    return decoded.substring(_kLegacySaltPrefix.length);
  } catch (_) {
    return null;
  }
}

/// Upgrades a legacy hash to PBKDF2 in place, preserving the user's password.
///
/// Returns the new hash string, or null when [stored] is already current or
/// cannot be decoded (in which case the caller should leave it alone — the
/// legacy verification path still works).
String? upgradeLegacyHash(String stored,
    {int iterations = kPbkdf2Iterations}) {
  final plaintext = recoverLegacyPassword(stored);
  if (plaintext == null) return null;
  return hashPassword(plaintext, iterations: iterations);
}

// ─────────────────────────────────────────────────────────────────────────────
// Internals
// ─────────────────────────────────────────────────────────────────────────────

String _encode({
  required int iterations,
  required Uint8List salt,
  required Uint8List derivedKey,
}) {
  return '$kPbkdf2Prefix\$sha256\$$iterations\$'
      '${base64Encode(salt)}\$${base64Encode(derivedKey)}';
}

String _legacyEncode(String password) =>
    base64Encode(utf8.encode('$_kLegacySaltPrefix$password'));

Uint8List _generateSalt() {
  return Uint8List.fromList(
    List<int>.generate(kSaltLengthBytes, (_) => _secureRandom.nextInt(256)),
  );
}

/// PBKDF2 (RFC 8018 §5.2) with HMAC-SHA256 as the pseudorandom function.
Uint8List _pbkdf2({
  required String password,
  required Uint8List salt,
  required int iterations,
  required int keyLength,
}) {
  final hmac = Hmac(sha256, utf8.encode(password));
  const hashLength = 32; // SHA-256 output, bytes
  final blockCount = (keyLength / hashLength).ceil();
  final output = Uint8List(blockCount * hashLength);

  for (var block = 1; block <= blockCount; block++) {
    // U1 = PRF(password, salt || INT_32_BE(block))
    final blockIndex = Uint8List(4)
      ..[0] = (block >> 24) & 0xff
      ..[1] = (block >> 16) & 0xff
      ..[2] = (block >> 8) & 0xff
      ..[3] = block & 0xff;

    var u = Uint8List.fromList(
      hmac.convert(<int>[...salt, ...blockIndex]).bytes,
    );
    final accumulator = Uint8List.fromList(u);

    // U2..Uc, XOR-folded into the accumulator.
    for (var i = 1; i < iterations; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (var j = 0; j < hashLength; j++) {
        accumulator[j] ^= u[j];
      }
    }

    output.setRange(
        (block - 1) * hashLength, block * hashLength, accumulator);
  }

  return Uint8List.sublistView(output, 0, keyLength);
}

/// Compares two byte lists in time independent of where they first differ.
bool _constantTimeEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}
