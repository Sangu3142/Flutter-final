/// hearts_provider.dart
/// Purpose: HeartsNotifier manages heart count and refill logic. heartsProvider exposes it.
/// Reads from: Hive box 'hearts', currentUserProvider
/// Writes to: Hive box 'hearts'
/// Navigation: none
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/hearts_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants.dart';
import '../../shop/providers/inventory_provider.dart';

class HeartsNotifier extends StateNotifier<HeartsModel> {
  final String _uid;
  final Box<HeartsModel> _box;

  HeartsNotifier(this._uid, this._box) : super(_loadOrCreate(_uid, _box)) {
    // Apply any pending refills on startup; fire-and-forget the Hive write
    // since constructors can't be async. Subsequent reads are safe because
    // `state` is updated synchronously.
    _applyRefill();
  }

  static HeartsModel _loadOrCreate(String uid, Box<HeartsModel> box) {
    return box.get(uid) ?? HeartsModel.full();
  }

  Future<void> _applyRefill() async {
    final cutoff =
        DateTime.now().subtract(const Duration(minutes: kHeartRefillMinutes));
    final remaining = state.lostAt
        .where((ts) => DateTime.parse(ts).isAfter(cutoff))
        .toList();
    final refilled = state.lostAt.length - remaining.length;
    if (refilled > 0) {
      state = HeartsModel(
        heartsCount: (state.heartsCount + refilled).clamp(0, kMaxHearts),
        lostAt: remaining,
      );
      await _box.put(_uid, state);
    }
  }

  /// Returns false if shield blocked the loss, true if a heart was deducted.
  Future<bool> loseHeart({InventoryNotifier? inventory}) async {
    await _applyRefill();
    if (inventory != null && inventory.state.has(kPowerUpShield)) {
      await inventory.consume(kPowerUpShield);
      return false;
    }
    if (state.heartsCount <= 0) return true;
    final newLostAt = List<String>.from(state.lostAt)
      ..add(DateTime.now().toIso8601String());
    state = HeartsModel(
      heartsCount: state.heartsCount - 1,
      lostAt: newLostAt,
    );
    await _box.put(_uid, state);
    return true;
  }

  Future<void> gainHeart() async {
    await _applyRefill();
    if (state.heartsCount < kMaxHearts) {
      final newLostAt = List<String>.from(state.lostAt);
      if (newLostAt.isNotEmpty) newLostAt.removeLast();
      state = HeartsModel(
        heartsCount: state.heartsCount + 1,
        lostAt: newLostAt,
      );
      await _box.put(_uid, state);
    }
  }

  Future<void> resetToFull() async {
    state = HeartsModel(
      heartsCount: kMaxHearts,
      lostAt: [],
    );
    await _box.put(_uid, state);
  }

  Duration? timeUntilNextRefill() {
    // Fire-and-forget: state is mutated synchronously, only the Hive persist
    // is async, which is safe to defer for this read-only computation.
    // ignore: discarded_futures
    _applyRefill();
    if (state.heartsCount >= kMaxHearts) return null;
    if (state.lostAt.isEmpty) return null;
    final oldest = state.lostAt
        .map(DateTime.parse)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final refillAt = oldest.add(const Duration(minutes: kHeartRefillMinutes));
    final remaining = refillAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }


}

final heartsProvider = StateNotifierProvider<HeartsNotifier, HeartsModel>((ref) {
  final user = ref.watch(currentUserProvider);
  final box = Hive.box<HeartsModel>(kHeartsBox);
  return HeartsNotifier(user?.uid ?? '__guest__', box);
});
