// lib/features/spin/providers/spin_provider.dart
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shop/providers/inventory_provider.dart';
import '../../streak/providers/streak_provider.dart';
import '../../../core/constants.dart';
import '../../../services/streak_service.dart';

class SpinState {
  final bool canSpin;
  final Duration? cooldownRemaining; // null = can spin
  final int? lastWinnerIndex; // null = not yet spun this session

  const SpinState({
    required this.canSpin,
    this.cooldownRemaining,
    this.lastWinnerIndex,
  });
}

class SpinNotifier extends StateNotifier<SpinState> {
  final Ref _ref;

  SpinNotifier(this._ref) : super(const SpinState(canSpin: true)) {
    _checkAvailability();
  }

  void _checkAvailability() {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final lastSpinStr = user.spinLastDate;
    if (lastSpinStr == null) {
      state = const SpinState(canSpin: true);
      return;
    }

    if (user.bonusSpinsAvailable > 0) {
      state = const SpinState(canSpin: true);
      return;
    }

    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (lastSpinStr == todayStr) {
      final midnight = DateTime(today.year, today.month, today.day + 1);
      final remaining = midnight.difference(today);
      state = SpinState(canSpin: false, cooldownRemaining: remaining);
    } else {
      state = const SpinState(canSpin: true);
    }
  }

  int computeWinner(int spinCount) {
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    return Random(seed * 1000 + spinCount).nextInt(8);
  }

  Future<void> applyWin(int segmentIndex) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final segment = kWheelSegments[segmentIndex];
    final type = segment['type'] as String;
    final value = segment['value'];

    if (type == 'coins') {
      await _ref.read(authProvider.notifier).addWalletCoins(value as int);
    } else if (type == 'xp') {
      await _ref.read(authProvider.notifier).addXp(value as int);
    } else if (type == 'powerup') {
      await _ref.read(inventoryProvider.notifier).addItem(value as String);
    } else if (type == 'streak_shield') {
      final uid = _ref.read(currentUserProvider)?.uid;
      if (uid != null) {
        await StreakService.addShield(uid);
        _ref.read(globalStreakProvider.notifier).refresh();
      }
    }

    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (user.bonusSpinsAvailable > 0) {
      user.bonusSpinsAvailable--;
    } else {
      user.spinLastDate = todayStr;
    }
    await user.save();

    _checkAvailability();
  }
}

final spinProvider =
    StateNotifierProvider<SpinNotifier, SpinState>((ref) {
  return SpinNotifier(ref);
});
