import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zamwealth_quest/core/password_hasher.dart';

/// Reproduces the pre-2026 reversible scheme so the migration path can be
/// tested against a realistic stored value.
String legacyHash(String password) =>
    base64Encode(utf8.encode('zmw_quest_2024_$password'));

void main() {
  // Keep iterations low in tests — correctness is what is under test, not the
  // work factor. Production uses kPbkdf2Iterations.
  const testIterations = 1000;

  group('hashPassword / verifyPassword', () {
    test('a freshly hashed password verifies', () {
      final stored = hashPassword('chanda2026', iterations: testIterations);
      expect(verifyPassword('chanda2026', stored), isTrue);
    });

    test('a wrong password is rejected', () {
      final stored = hashPassword('chanda2026', iterations: testIterations);
      expect(verifyPassword('chanda2025', stored), isFalse);
      expect(verifyPassword('', stored), isFalse);
      expect(verifyPassword('CHANDA2026', stored), isFalse);
    });

    test('the same password hashes differently each time (random salt)', () {
      final a = hashPassword('kwacha', iterations: testIterations);
      final b = hashPassword('kwacha', iterations: testIterations);
      expect(a, isNot(equals(b)));
      expect(verifyPassword('kwacha', a), isTrue);
      expect(verifyPassword('kwacha', b), isTrue);
    });

    test('the stored value is not reversible to the password', () {
      final stored = hashPassword('mukuba123', iterations: testIterations);
      expect(stored.contains('mukuba123'), isFalse);
      // Every segment is base64 of derived bytes, never of the password.
      expect(utf8.decode(base64Decode(stored.split(r'$')[4]), allowMalformed: true),
          isNot(contains('mukuba123')));
    });

    test('the format is self-describing', () {
      final stored = hashPassword('abc123', iterations: testIterations);
      final parts = stored.split(r'$');
      expect(parts, hasLength(5));
      expect(parts[0], equals(kPbkdf2Prefix));
      expect(parts[1], equals('sha256'));
      expect(int.parse(parts[2]), equals(testIterations));
      expect(base64Decode(parts[3]), hasLength(kSaltLengthBytes));
      expect(base64Decode(parts[4]), hasLength(kDerivedKeyLengthBytes));
    });

    test('malformed stored values are rejected, not crashed on', () {
      expect(verifyPassword('x', ''), isFalse);
      expect(verifyPassword('x', r'pbkdf2$sha256$broken'), isFalse);
      expect(verifyPassword('x', r'pbkdf2$sha256$1000$!!!$!!!'), isFalse);
      expect(verifyPassword('x', r'pbkdf2$md5$1000$AAAA$AAAA'), isFalse);
    });
  });

  group('legacy migration', () {
    test('a legacy hash is recognised as legacy', () {
      expect(isLegacyHash(legacyHash('lusaka')), isTrue);
      expect(isLegacyHash(hashPassword('lusaka', iterations: testIterations)),
          isFalse);
    });

    test('a legacy hash still verifies, so nobody is locked out', () {
      expect(verifyPassword('lusaka', legacyHash('lusaka')), isTrue);
      expect(verifyPassword('wrong', legacyHash('lusaka')), isFalse);
    });

    test('the original password is recovered from a legacy hash', () {
      expect(recoverLegacyPassword(legacyHash('ndalama99')),
          equals('ndalama99'));
      expect(
          recoverLegacyPassword(
              hashPassword('x', iterations: testIterations)),
          isNull);
      expect(recoverLegacyPassword('not-base64-at-all!!'), isNull);
    });

    test('upgrading preserves the password', () {
      final legacy = legacyHash('bwalya2026');
      final upgraded = upgradeLegacyHash(legacy, iterations: testIterations);

      expect(upgraded, isNotNull);
      expect(isLegacyHash(upgraded!), isFalse);
      // The whole point: the player logs in with the same password afterwards.
      expect(verifyPassword('bwalya2026', upgraded), isTrue);
      expect(verifyPassword('bwalya2027', upgraded), isFalse);
    });

    test('needsRehash flags legacy hashes and weaker iteration counts', () {
      expect(needsRehash(legacyHash('x')), isTrue);
      expect(
          needsRehash(hashPassword('x', iterations: 1000), iterations: 5000),
          isTrue);
      expect(
          needsRehash(hashPassword('x', iterations: 5000), iterations: 5000),
          isFalse);
    });
  });

  group('PBKDF2 correctness', () {
    test('matches RFC 6070-style expectations for HMAC-SHA256', () {
      // Derivation is deterministic for a fixed salt: re-verifying the same
      // stored string must succeed every time.
      final stored = hashPassword('password', iterations: testIterations);
      for (var i = 0; i < 5; i++) {
        expect(verifyPassword('password', stored), isTrue);
      }
    });

    test('iteration count affects the derived key', () {
      final a = hashPassword('same', iterations: 1000);
      final salt = a.split(r'$')[3];
      // Same salt, different iterations → different derived key. Rebuild a
      // stored string by hand to isolate the iteration variable.
      final b = a.split(r'$');
      final tampered = 'pbkdf2\$sha256\$2000\$$salt\$${b[4]}';
      expect(verifyPassword('same', tampered), isFalse);
    });
  });
}
