/// daily_bonus_provider.dart
/// Purpose: Manages the daily login bonus state — calculates the current
///          bonus day (1–7), handles streak resets with shield protection,
///          and applies coin/XP/power-up rewards on claim.
/// Reads from: authProvider (currentUser), inventoryProvider
/// Writes to: UserProfile.loginBonusDay, UserProfile.loginBonusLastDate
/// Navigation: none (provider only)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shop/providers/inventory_provider.dart';
import '../../../core/constants.dart';

class DailyBonusState {
  final bool shouldShow;
  final int bonusDay; // 1-7
  final bool alreadyClaimed;

  const DailyBonusState({
    required this.shouldShow,
    required this.bonusDay,
    required this.alreadyClaimed,
  });
}

class DailyBonusNotifier extends StateNotifier<DailyBonusState> {
  final Ref _ref;

  DailyBonusNotifier(this._ref)
      : super(const DailyBonusState(
          shouldShow: false,
          bonusDay: 1,
          alreadyClaimed: false,
        )) {
    _checkOnLogin();
  }

  Future<void> _checkOnLogin() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final lastDateStr = user.loginBonusLastDate;
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Already claimed today
    if (lastDateStr != null && lastDateStr.startsWith(todayStr)) {
      state = DailyBonusState(
        shouldShow: false,
        bonusDay: user.loginBonusDay,
        alreadyClaimed: true,
      );
      return;
    }

    // Calculate new bonus day
    int newDay;
    if (lastDateStr == null) {
      newDay = 1;
    } else {
      final last = DateTime.parse(lastDateStr);
      final lastDate = DateTime(last.year, last.month, last.day);
      final todayDate = DateTime(today.year, today.month, today.day);
      final diff = todayDate.difference(lastDate).inDays;
      if (diff == 1) {
        newDay = (user.loginBonusDay % 7) + 1;
      } else {
        // Missed day(s) — check for shield protection
        final inventory = _ref.read(inventoryProvider);
        if (inventory.has(kPowerUpShield)) {
          await _ref.read(inventoryProvider.notifier).consume(kPowerUpShield);
          newDay = (user.loginBonusDay % 7) + 1;
        } else {
          newDay = 1;
        }
      }
    }

    state = DailyBonusState(
      shouldShow: true,
      bonusDay: newDay,
      alreadyClaimed: false,
    );
  }

  /// Call this when the player taps "Claim!" on the bonus screen.
  Future<void> claimBonus() async {
    final user = _ref.read(currentUserProvider);
    if (user == null || state.alreadyClaimed) return;

    final schedule = kDailyBonusSchedule[state.bonusDay - 1];
    final coins = schedule['coins'] as int;
    final xp = schedule['xp'] as int;
    final powerUp = schedule['powerUp'] as String?;

    // Apply coin reward
    await _ref.read(authProvider.notifier).addWalletCoins(coins);

    // Apply XP reward
    if (xp > 0) {
      await _ref.read(authProvider.notifier).addXp(xp);
    }

    // Apply power-up reward
    if (powerUp != null) {
      await _ref.read(inventoryProvider.notifier).addItem(powerUp);
    }

    // Update user persistence
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    user.loginBonusDay = state.bonusDay;
    user.loginBonusLastDate = todayStr;
    await user.save();

    state = DailyBonusState(
      shouldShow: false,
      bonusDay: state.bonusDay,
      alreadyClaimed: true,
    );
  }
}

final dailyBonusProvider =
    StateNotifierProvider<DailyBonusNotifier, DailyBonusState>((ref) {
  return DailyBonusNotifier(ref);
});
