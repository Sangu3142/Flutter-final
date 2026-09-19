import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/secure_hive.dart';

/// Exercises the plaintext → encrypted migration without touching platform
/// secure storage (which needs a real device). The cipher is supplied
/// directly; getHiveCipher() is the only part not covered here, and it is a
/// thin read/write against flutter_secure_storage.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late HiveAesCipher cipher;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('secure_hive_test_');
    Hive.init(dir.path);
    cipher = HiveAesCipher(Hive.generateSecureKey());
  });

  tearDown(() async {
    await Hive.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('migrates an existing plaintext box into the encrypted box', () async {
    // An install from before the encryption change.
    final legacyName = kLegacyBoxNames[kSettingsBox]!;
    final legacy = await Hive.openBox(legacyName);
    await legacy.put('onboardingDone_chanda', true);
    await legacy.put('leaderboardSeeded', true);
    await legacy.put('tutorial_completed', true);
    await legacy.close();

    await openMigrationBox();
    final migrated = await openSecureBox<dynamic>(kSettingsBox, cipher);

    // Every value survives — this is the part that must never regress.
    expect(migrated.get('onboardingDone_chanda'), isTrue);
    expect(migrated.get('leaderboardSeeded'), isTrue);
    expect(migrated.get('tutorial_completed'), isTrue);
    expect(migrated.length, equals(3));

    // The plaintext file is gone.
    expect(await Hive.boxExists(legacyName), isFalse);

    // And the flag is recorded, so it will not run again.
    expect(
      Hive.box(kMigrationBox).get('enc_migrated_$kSettingsBox'),
      isTrue,
    );
  });

  test('migration is idempotent and does not clobber later writes', () async {
    final legacyName = kLegacyBoxNames[kSettingsBox]!;
    final legacy = await Hive.openBox(legacyName);
    await legacy.put('value', 'original');
    await legacy.close();

    await openMigrationBox();
    var box = await openSecureBox<dynamic>(kSettingsBox, cipher);
    await box.put('value', 'updated-after-migration');
    await box.close();

    // Second launch: the flag short-circuits the copy, so the post-migration
    // write is not overwritten by stale legacy data.
    box = await openSecureBox<dynamic>(kSettingsBox, cipher);
    expect(box.get('value'), equals('updated-after-migration'));
  });

  test('a fresh install opens an empty encrypted box', () async {
    await openMigrationBox();
    final box = await openSecureBox<dynamic>(kSettingsBox, cipher);
    expect(box.isEmpty, isTrue);
    expect(
      Hive.box(kMigrationBox).get('enc_migrated_$kSettingsBox'),
      isTrue,
    );
  });

  test('stored values are not readable in the box file', () async {
    await openMigrationBox();
    final box = await openSecureBox<dynamic>(kSettingsBox, cipher);
    await box.put('secret', 'ZMW-wallet-balance-9999');
    await box.flush();

    final file = File('${dir.path}/$kSettingsBox.hive');
    expect(file.existsSync(), isTrue);
    final bytes = file.readAsBytesSync();
    expect(String.fromCharCodes(bytes).contains('ZMW-wallet-balance-9999'),
        isFalse,
        reason: 'box contents must be ciphertext on disk');
  });

  test('a lost key does not crash the app — the box opens empty', () async {
    await openMigrationBox();
    final box = await openSecureBox<dynamic>(kSettingsBox, cipher);
    await box.put('value', 'written-under-old-key');
    await box.close();

    // Simulate the keystore entry being lost: a different key, same file.
    // Hive treats the undecryptable frames as corruption and truncates rather
    // than throwing, so the observable behaviour is an empty box — which is
    // exactly the wipe-and-recreate outcome, reached by Hive's own path.
    final newCipher = HiveAesCipher(Hive.generateSecureKey());
    final recovered = await openSecureBox<dynamic>(kSettingsBox, newCipher);

    expect(recovered.isEmpty, isTrue);
  });

  test('the encryption-reset flag round-trips', () async {
    // getHiveCipher() sets this when it finds encrypted boxes on disk but no
    // key in secure storage; that path needs a platform channel, so the flag
    // itself is exercised here.
    await openMigrationBox();
    expect(encryptionResetOccurred, isFalse);

    await Hive.box(kMigrationBox).put(kEncResetOccurredKey, true);
    expect(encryptionResetOccurred, isTrue);

    await clearEncryptionResetFlag();
    expect(encryptionResetOccurred, isFalse);
  });
}
