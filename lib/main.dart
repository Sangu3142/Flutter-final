/// main.dart
/// Purpose: App entry point — initialises Hive, registers all TypeAdapters,
///          opens all boxes **encrypted**, migrates legacy plaintext data and
///          legacy password hashes, seeds initial data, then launches the
///          Flutter widget tree wrapped in ProviderScope.
/// Reads from: Hive boxes (all, on initialisation), platform secure storage
/// Writes to: Hive boxes 'leaderboard', 'settings' (initial seed data),
///            'users' (one-time password hash upgrade), 'zw_migration'
/// Navigation: delegates entirely to GoRouter (router.dart)
library;

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/password_hasher.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/core/secure_hive.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/auth/models/user_profile.dart';
import 'package:zamwealth_quest/features/daily_challenge/models/daily_challenge_record.dart';
import 'package:zamwealth_quest/features/levels/models/level_model.dart';
import 'package:zamwealth_quest/features/payments/models/payment_record.dart';
import 'package:zamwealth_quest/features/story/models/story_chapter_progress.dart';
import 'package:zamwealth_quest/features/hearts/models/hearts_model.dart';
import 'package:zamwealth_quest/features/shop/models/inventory_model.dart';
import 'package:zamwealth_quest/features/boss/models/boss_record.dart';
import 'package:zamwealth_quest/features/family/models/family_model.dart';
import 'package:zamwealth_quest/features/business/models/business_model.dart';
import 'package:zamwealth_quest/features/life_events/models/life_event_record.dart';
import 'package:zamwealth_quest/features/property/models/property_model.dart';
import 'package:zamwealth_quest/features/portfolio/models/portfolio_model.dart';
import 'package:zamwealth_quest/features/loans/models/loan_record.dart';
import 'package:zamwealth_quest/features/savings/models/savings_record.dart';
import 'package:zamwealth_quest/features/news/models/news_record.dart';
import 'package:zamwealth_quest/features/health/models/health_record.dart';
import 'package:zamwealth_quest/features/myths/models/myth_record.dart';
import 'package:zamwealth_quest/features/spotlights/models/spotlight_record.dart';
import 'package:zamwealth_quest/features/mentors/models/mentor_record.dart';
import 'package:zamwealth_quest/features/proverbs/models/proverb_record.dart';
import 'package:zamwealth_quest/features/daily_routine/models/daily_routine_record.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Initialise Hive + load the encryption key ────────────────────────
  // The migration bookkeeping box is plaintext and must be open first: it
  // records both the per-box migration flags and, if the keystore entry has
  // been lost, the fact that encrypted data could not be recovered.
  await Hive.initFlutter();
  await openMigrationBox();
  final cipher = await getHiveCipher();

  // ── 2. Register TypeAdapters ─────────────────────────────────────────────
  // Order matters — register before opening boxes.
  Hive.registerAdapter(UserProfileAdapter()); // typeId 0
  Hive.registerAdapter(LevelModelAdapter()); // typeId 1
  Hive.registerAdapter(PaymentRecordAdapter()); // typeId 2
  Hive.registerAdapter(DailyChallengeRecordAdapter()); // typeId 3
  Hive.registerAdapter(FamilyModelAdapter()); // typeId 4
  Hive.registerAdapter(BusinessModelAdapter()); // typeId 5
  Hive.registerAdapter(LifeEventRecordAdapter()); // typeId 6
  Hive.registerAdapter(StoryChapterProgressAdapter()); // typeId 12
  Hive.registerAdapter(HeartsModelAdapter()); // typeId 10
  Hive.registerAdapter(InventoryModelAdapter()); // typeId 11
  Hive.registerAdapter(BossRecordAdapter()); // typeId 13
  Hive.registerAdapter(PropertyModelAdapter()); // typeId 7
  Hive.registerAdapter(PortfolioModelAdapter()); // typeId 8
  Hive.registerAdapter(LoanRecordAdapter()); // typeId 14
  Hive.registerAdapter(SavingsRecordAdapter()); // typeId 15
  Hive.registerAdapter(NewsRecordAdapter()); // typeId 16
  Hive.registerAdapter(HealthRecordAdapter()); // typeId 17
  Hive.registerAdapter(MythRecordAdapter()); // typeId 18
  Hive.registerAdapter(SpotlightRecordAdapter()); // typeId 19
  Hive.registerAdapter(MentorRecordAdapter()); // typeId 20
  Hive.registerAdapter(ProverbRecordAdapter()); // typeId 21
  Hive.registerAdapter(DailyRoutineRecordAdapter()); // typeId 22

  // ── 3. Open all Hive boxes, encrypted ────────────────────────────────────
  // SECURITY (audit issue 1): every box is AES-256 encrypted with a key held
  // in the platform keystore. openSecureBox also performs the one-time
  // migration of an existing install's plaintext boxes — see
  // lib/core/secure_hive.dart.
  await Future.wait([
    openSecureBox<UserProfile>(kUserBox, cipher),
    openSecureBox<LevelModel>(kLevelBox, cipher),
    openSecureBox<PaymentRecord>(kPaymentBox, cipher),
    openSecureBox<dynamic>(kSessionBox, cipher),
    openSecureBox<dynamic>(kLeaderboardBox, cipher),
    openSecureBox<dynamic>(kSettingsBox, cipher),
    openSecureBox<DailyChallengeRecord>(kDailyChallengeBox, cipher),
    openSecureBox<FamilyModel>(kFamilyBox, cipher),
    openSecureBox<BusinessModel>(kBusinessBox, cipher),
    openSecureBox<LifeEventRecord>(kLifeEventsBox, cipher),
    openSecureBox<StoryChapterProgress>(kStoryBox, cipher),
    openSecureBox<HeartsModel>(kHeartsBox, cipher),
    openSecureBox<InventoryModel>(kInventoryBox, cipher),
    openSecureBox<BossRecord>(kBossBox, cipher),
    openSecureBox<PropertyModel>(kPropertyBox, cipher),
    openSecureBox<PortfolioModel>(kInvestmentsBox, cipher),
    openSecureBox<LoanRecord>(kLoansBox, cipher),
    openSecureBox<SavingsRecord>(kSavingsGoalsBox, cipher),
    openSecureBox<NewsRecord>(kNewsBox, cipher),
    openSecureBox<HealthRecord>(kHealthBox, cipher),
    openSecureBox<MythRecord>(kMythsBox, cipher),
    openSecureBox<SpotlightRecord>(kSpotlightsBox, cipher),
    openSecureBox<MentorRecord>(kMentorsBox, cipher),
    openSecureBox<ProverbRecord>(kProverbsBox, cipher),
    openSecureBox<DailyRoutineRecord>(kDailyRoutineBox, cipher),
    openSecureBox<dynamic>(kStreakBox, cipher),
  ]);

  // ── 4. Upgrade any legacy password hashes ────────────────────────────────
  await _migratePasswordHashes();

  // ── 5. Seed one-time initial data ────────────────────────────────────────
  await _seedLeaderboard();

  // ── 5. Launch app ────────────────────────────────────────────────────────
  runApp(
    // ProviderScope is the root of the Riverpod state tree.
    const ProviderScope(
      child: ZamWealthApp(),
    ),
  );
}

/// Re-hashes any password still stored under the old reversible base64 scheme.
///
/// SECURITY (audit issue 2): the previous `_hashPassword` base64-encoded a
/// static-salted password, which is trivially reversible. Because it *is*
/// reversible, the original password can be recovered here and re-hashed with
/// PBKDF2 — so existing players keep their passwords instead of being locked
/// out, and the recoverable form disappears from disk even for accounts that
/// are never logged into again.
///
/// Runs once: after the first pass every hash carries the `pbkdf2$` prefix and
/// the loop does no work. Cost is one PBKDF2 derivation per legacy account,
/// and a personal device holds a handful of accounts at most.
Future<void> _migratePasswordHashes() async {
  try {
    final box = Hive.box<UserProfile>(kUserBox);
    for (final key in box.keys) {
      final user = box.get(key);
      if (user == null) continue;
      if (!isLegacyHash(user.passwordHash)) continue;

      final upgraded = upgradeLegacyHash(user.passwordHash);
      if (upgraded == null) continue; // undecodable — leave it for login-time
      user.passwordHash = upgraded;
      await user.save();
    }
  } catch (e) {
    // Never block startup on this. Any account missed here is still upgraded
    // on its next successful login (see AuthNotifier.login).
    if (kDebugMode) debugPrint('main: password hash migration deferred: $e');
  }
}

/// Seeds the leaderboard box with 9 fictional Zambian players on first launch.
/// Called only once — guarded by the 'leaderboardSeeded' settings flag.
Future<void> _seedLeaderboard() async {
  final settingsBox = Hive.box(kSettingsBox);
  final alreadySeeded =
      settingsBox.get('leaderboardSeeded', defaultValue: false) as bool;
  if (alreadySeeded) return;

  final rng = Random();

  /// Fictional Zambian player names for the placeholder leaderboard.
  const names = [
    'Chanda Mwale',
    'Bwalya Mutale',
    'Mwape Tembo',
    'Nalukui Siame',
    'Chitalu Banda',
    'Kapembwa Mwansa',
    'Towela Ng\'andu',
    'Musonda Chipimo',
    'Lungowe Phiri',
  ];

  // Generate random XP values spread across the four rank tiers.
  final entries = names.map((name) {
    return {
      'name': name,
      'xp': 50 + rng.nextInt(2100), // 50–2150 XP range
      'badge': _randomBadge(rng),
    };
  }).toList();

  await Hive.box(kLeaderboardBox).put('entries', entries);
  await settingsBox.put('leaderboardSeeded', true);
}

/// Returns a random badge identifier for a placeholder leaderboard player.
String _randomBadge(Random rng) {
  const badges = [
    'budget_master',
    'savings_star',
    'debt_slayer',
    'investor_pro',
    'business_mogul',
    'zamcoin_collector',
  ];
  return badges[rng.nextInt(badges.length)];
}

// ─────────────────────────────────────────────────────────────────────────────
// Root App Widget
// ─────────────────────────────────────────────────────────────────────────────

/// The root [ConsumerWidget] that wires [GoRouter] and [zamWealthTheme]
/// into [MaterialApp.router].
class ZamWealthApp extends ConsumerWidget {
  const ZamWealthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router — it re-creates when auth state changes so GoRouter
    // can re-evaluate its redirect rules and navigate accordingly.
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ZamWealth Quest',
      debugShowCheckedModeBanner: false,
      theme: zamWealthTheme,
      routerConfig: router,
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
