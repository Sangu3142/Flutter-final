/// property_provider.dart
/// Purpose: Manages property purchase, mortgage payments, appreciation, and rental.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/property/models/property_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class PropertyState {
  const PropertyState({this.property, this.isLoading = false});
  final PropertyModel? property;
  final bool isLoading;
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class PropertyNotifier extends StateNotifier<PropertyState> {
  PropertyNotifier(this._ref) : super(const PropertyState()) {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.currentUser?.uid != next.currentUser?.uid) _load();
    });
    _load();
  }

  final Ref _ref;

  Box<PropertyModel> get _box => Hive.box<PropertyModel>(kPropertyBox);
  String? get _uid => _ref.read(currentUserProvider)?.uid;

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      state = const PropertyState();
      return;
    }
    state = const PropertyState(isLoading: true);
    try {
      final prop = _box.get(uid);
      if (prop != null) {
        await _maybeApplyAppreciation(prop);
        await _maybeTransferRental(prop);
      }
      // Re-fetch after any appreciation/rental writes so the fresh value is used.
      state = PropertyState(property: _box.get(uid));
    } catch (e, s) {
      // Safe fallback: always exit the loading state so the UI isn't stuck.
      debugPrint('PropertyProvider _load error: $e\n$s');
      try {
        state = PropertyState(property: _box.get(uid));
      } catch (e2) {
        debugPrint('PropertyProvider _load inner error: $e2');
        state = const PropertyState();
      }
    }
  }

  // ── Purchase ──────────────────────────────────────────────────────────────

  Future<bool> purchaseProperty(int tier) async {
    final uid = _uid;
    if (uid == null || tier < 1 || tier > 5) return false;
    state = const PropertyState(isLoading: true);
    try {
      final deposit = PropertyModel.tierDepositZamCoins[tier];
      final spent =
          await _ref.read(authProvider.notifier).spendWalletCoins(deposit);
      if (!spent) {
        state = const PropertyState();
        return false;
      }

      final today = _todayStr();
      final prop = PropertyModel(
        uid: uid,
        tier: tier,
        isOwned: true,
        purchaseDateStr: today,
        currentValueZMW: PropertyModel.tierBaseZMW[tier],
        totalInvestedZamCoins: deposit,
        monthlyMortgageZamCoins: PropertyModel.tierMortgageZamCoins[tier],
        mortgageMonthsRemaining: PropertyModel.tierMortgageMonths[tier],
        isRentedOut: false,
        lastAppreciationStr: today,
        lastRentalStr: today,
        recentEvents: ['🏠 Purchased ${PropertyModel.tierNames[tier]}!'],
      );
      await _box.put(uid, prop);
      await _ref.read(authProvider.notifier).addXp(50);
      state = PropertyState(property: prop);
      return true;
    } catch (_) {
      state = const PropertyState();
      return false;
    }
  }

  // ── Pay mortgage instalment ───────────────────────────────────────────────

  Future<bool> payMortgage() async {
    final prop = state.property;
    if (prop == null || !prop.hasMortgage) return false;
    state = PropertyState(property: prop, isLoading: true);
    try {
      final spent = await _ref
          .read(authProvider.notifier)
          .spendWalletCoins(prop.monthlyMortgageZamCoins);
      if (!spent) {
        state = PropertyState(property: prop);
        return false;
      }

      prop.mortgageMonthsRemaining -= 1;
      prop.totalInvestedZamCoins += prop.monthlyMortgageZamCoins;
      final msg = prop.mortgageMonthsRemaining <= 0
          ? '🎉 Mortgage fully paid off!'
          : '💳 Mortgage paid (${prop.mortgageMonthsRemaining} months left)';
      _addEvent(prop, msg);
      await prop.save();
      state = PropertyState(property: prop);
      return true;
    } catch (_) {
      state = PropertyState(property: prop);
      return false;
    }
  }

  // ── Toggle rental ─────────────────────────────────────────────────────────

  Future<void> toggleRental() async {
    final prop = state.property;
    if (prop == null || !prop.canRentOut) return;
    prop.isRentedOut = !prop.isRentedOut;
    _addEvent(
      prop,
      prop.isRentedOut
          ? '🏘️ Property listed for rental'
          : '🔒 Property removed from rental',
    );
    await prop.save();
    state = PropertyState(property: prop);
  }

  // ── Upgrade to next tier ──────────────────────────────────────────────────

  Future<bool> upgradeProperty() async {
    final prop = state.property;
    if (prop == null || !prop.canUpgrade) return false;
    state = PropertyState(property: prop, isLoading: true);
    try {
      final nextTier = prop.tier + 1;
      final cost = PropertyModel.tierDepositZamCoins[nextTier];
      final spent =
          await _ref.read(authProvider.notifier).spendWalletCoins(cost);
      if (!spent) {
        state = PropertyState(property: prop);
        return false;
      }

      // Sell appreciation gains: 1 ZamCoin per ZMW 1,000 gained
      final gainZMW =
          prop.currentValueZMW - PropertyModel.tierBaseZMW[prop.tier];
      final bonus = (gainZMW / 1000).round();
      if (bonus > 0) {
        await _ref.read(authProvider.notifier).addWalletCoins(bonus);
      }

      final today = _todayStr();
      prop.tier = nextTier;
      prop.currentValueZMW = PropertyModel.tierBaseZMW[nextTier];
      prop.monthlyMortgageZamCoins =
          PropertyModel.tierMortgageZamCoins[nextTier];
      prop.mortgageMonthsRemaining =
          PropertyModel.tierMortgageMonths[nextTier];
      prop.totalInvestedZamCoins += cost;
      prop.isRentedOut = false;
      prop.lastAppreciationStr = today;
      _addEvent(prop, '🆙 Upgraded to ${PropertyModel.tierNames[nextTier]}!');
      await prop.save();
      await _ref.read(authProvider.notifier).addXp(30);
      state = PropertyState(property: prop);
      return true;
    } catch (_) {
      state = PropertyState(property: prop);
      return false;
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _maybeApplyAppreciation(PropertyModel prop) async {
    final last = DateTime.parse(prop.lastAppreciationStr);
    final now = DateTime.now();
    final monthsElapsed =
        (now.year - last.year) * 12 + (now.month - last.month);
    if (monthsElapsed <= 0) return;

    for (int i = 0; i < monthsElapsed; i++) {
      prop.currentValueZMW = (prop.currentValueZMW * 1.03).round();
    }
    prop.lastAppreciationStr = _todayStr();
    _addEvent(
      prop,
      '📈 Value grew to ZMW ${_fmt(prop.currentValueZMW)}',
    );
    await prop.save();
  }

  Future<void> _maybeTransferRental(PropertyModel prop) async {
    if (!prop.isRentedOut || prop.weeklyRentalZamCoins == 0) return;
    final last = DateTime.parse(prop.lastRentalStr);
    final weeksElapsed = DateTime.now().difference(last).inDays ~/ 7;
    if (weeksElapsed <= 0) return;

    final earned = weeksElapsed * prop.weeklyRentalZamCoins;
    await _ref.read(authProvider.notifier).addWalletCoins(earned);
    prop.lastRentalStr = _todayStr();
    _addEvent(prop, '💰 Rental income: $earned ZamCoins');
    await prop.save();
  }

  void _addEvent(PropertyModel prop, String msg) {
    prop.recentEvents.insert(0, msg);
    if (prop.recentEvents.length > 10) prop.recentEvents.removeLast();
  }

  String _todayStr() => DateTime.now().toIso8601String().split('T')[0];

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return '$n';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final propertyProvider =
    StateNotifierProvider<PropertyNotifier, PropertyState>((ref) {
  return PropertyNotifier(ref);
});
