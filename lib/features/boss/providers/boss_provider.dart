import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../badges/providers/badge_provider.dart';
import '../models/boss_record.dart';

class BossNotifier extends StateNotifier<BossRecord> {
  final Ref _ref;
  final int levelId;

  BossNotifier(this._ref, this.levelId)
      : super(BossRecord(
          levelId: levelId,
          defeated: false,
          replayCount: 0,
          bestScore: 0,
          defeatedAt: null,
        )) {
    _load();
  }

  void _load() {
    final uid = _ref.read(currentUserProvider)?.uid ?? '';
    final box = Hive.box<BossRecord>(kBossBox);
    final record = box.get('${uid}_$levelId');
    if (record != null) state = record;
  }

  Future<void> _save() async {
    final uid = _ref.read(currentUserProvider)?.uid ?? '';
    final box = Hive.box<BossRecord>(kBossBox);
    await box.put('${uid}_$levelId', state);
  }

  Future<void> recordDefeat({required int score, required bool isReplay}) async {
    final now = DateTime.now().toIso8601String();
    if (!isReplay) {
      state = BossRecord(
        levelId: levelId,
        defeated: true,
        replayCount: state.replayCount,
        bestScore: score > state.bestScore ? score : state.bestScore,
        defeatedAt: state.defeatedAt ?? now,
      );
    } else {
      state = BossRecord(
        levelId: levelId,
        defeated: state.defeated,
        replayCount: state.replayCount + 1,
        bestScore: score > state.bestScore ? score : state.bestScore,
        defeatedAt: state.defeatedAt,
      );
    }
    await _save();

    final config = kBossConfigs.firstWhere(
      (c) => c.levelId == levelId,
      orElse: () => kBossConfigs.first,
    );
    final xp    = isReplay ? (config.xpReward * 0.5).round() : config.xpReward;
    final coins = isReplay ? 50 : config.coinsReward;

    await _ref.read(authProvider.notifier).addXp(xp);
    await _ref.read(authProvider.notifier).addWalletCoins(coins);

    // Award bonus spin
    final user = _ref.read(currentUserProvider);
    if (user != null) {
      user.bonusSpinsAvailable = user.bonusSpinsAvailable + 1;
      await user.save();
      _ref.read(authProvider.notifier).refreshUser();
    }

    // First-time defeat only: award badge
    if (!isReplay) {
      _ref.read(badgeServiceProvider).awardById(config.badgeId);
    }
  }
}

final bossProvider =
    StateNotifierProvider.family<BossNotifier, BossRecord, int>(
  (ref, levelId) => BossNotifier(ref, levelId),
);
