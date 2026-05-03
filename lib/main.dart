/// main.dart
/// Purpose: App entry point — initialises Hive, registers all TypeAdapters,
///          opens all required boxes, seeds initial data, then launches the
///          Flutter widget tree wrapped in ProviderScope.
/// Reads from: Hive boxes (all, on initialisation)
/// Writes to: Hive boxes 'leaderboard', 'settings' (initial seed data)
/// Navigation: delegates entirely to GoRouter (router.dart)
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/auth/models/user_profile.dart';
import 'package:zamwealth_quest/features/daily_challenge/models/daily_challenge_record.dart';
import 'package:zamwealth_quest/features/levels/models/level_model.dart';
import 'package:zamwealth_quest/features/payments/models/payment_record.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Initialise Hive ──────────────────────────────────────────────────
  await Hive.initFlutter();

  // ── 2. Register TypeAdapters ─────────────────────────────────────────────
  // Order matters — register before opening boxes.
  Hive.registerAdapter(UserProfileAdapter()); // typeId 0
  Hive.registerAdapter(LevelModelAdapter()); // typeId 1
  Hive.registerAdapter(PaymentRecordAdapter()); // typeId 2
  Hive.registerAdapter(DailyChallengeRecordAdapter()); // typeId 3

  // ── 3. Open all Hive boxes ───────────────────────────────────────────────
  await Future.wait([
    Hive.openBox<UserProfile>(kUserBox),
    Hive.openBox<LevelModel>(kLevelBox),
    Hive.openBox<PaymentRecord>(kPaymentBox),
    Hive.openBox(kSessionBox),
    Hive.openBox(kLeaderboardBox),
    Hive.openBox(kSettingsBox),
    Hive.openBox<DailyChallengeRecord>(kDailyChallengeBox),
  ]);

  // ── 4. Seed one-time initial data ────────────────────────────────────────
  await _seedLeaderboard();

  // ── 5. Launch app ────────────────────────────────────────────────────────
  runApp(
    // ProviderScope is the root of the Riverpod state tree.
    const ProviderScope(
      child: ZamWealthApp(),
    ),
  );
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
    );
  }
}
