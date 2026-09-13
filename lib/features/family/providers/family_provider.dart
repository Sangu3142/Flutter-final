/// family_provider.dart
/// Purpose: Riverpod state management for the Virtual Family feature.
///          Loads/creates a FamilyModel from Hive, exposes update methods,
///          and deducts monthly expenses from the wallet once per month.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/family/models/family_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class FamilyState {
  const FamilyState({
    this.family,
    this.isLoading = false,
  });

  final FamilyModel? family;
  final bool isLoading;

  bool get hasFamily => family != null;

  FamilyState copyWith({FamilyModel? family, bool? isLoading}) {
    return FamilyState(
      family: family ?? this.family,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class FamilyNotifier extends StateNotifier<FamilyState> {
  FamilyNotifier(this._box, this._ref) : super(const FamilyState()) {
    _load();
  }

  final Box<FamilyModel> _box;
  final Ref _ref;

  String get _uid => _ref.read(currentUserProvider)?.uid ?? '';

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    final uid = _uid;
    if (uid.isEmpty) {
      state = const FamilyState();
      return;
    }
    final family = _box.get(uid);
    if (family != null) _maybeDeductMonthlyExpenses(family);
    state = FamilyState(family: family, isLoading: false);
  }

  // ── Setup ──────────────────────────────────────────────────────────────────

  Future<void> setupFamily({
    required String spouseName,
    required String childName,
    required int housingTier,
  }) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    final family = FamilyModel(
      uid: uid,
      spouseName: spouseName,
      childName: childName,
      housingTier: housingTier,
    )..recalcExpenses();
    await _box.put(uid, family);
    state = state.copyWith(family: family);
  }

  // ── Pay school fees ────────────────────────────────────────────────────────

  Future<bool> paySchoolFees() async {
    final family = state.family;
    if (family == null) return false;
    const fee = 450;
    final wallet = _ref.read(currentUserProvider)?.walletBalance ?? 0;
    if (wallet < fee) return false;
    await _ref.read(authProvider.notifier).addWalletCoins(-fee);
    family
      ..schoolFeesPaid = true
      ..happinessScore = (family.happinessScore + 8).clamp(0, 100)
      ..addEvent('📚 Paid ${family.childName}\'s school fees — ZMW $fee');
    await family.save();
    state = state.copyWith(family: family);
    return true;
  }

  // ── Upgrade housing ────────────────────────────────────────────────────────

  Future<bool> upgradeHousing() async {
    final family = state.family;
    if (family == null || family.housingTier >= 3) return false;
    final cost = FamilyModel.housingUpgradeCosts[family.housingTier];
    final wallet = _ref.read(currentUserProvider)?.walletBalance ?? 0;
    if (wallet < cost) return false;
    await _ref.read(authProvider.notifier).addWalletCoins(-cost);
    family
      ..housingTier += 1
      ..happinessScore = (family.happinessScore + 12).clamp(0, 100)
      ..addEvent('🏠 Upgraded to ${family.housingName} — great move!');
    family.recalcExpenses();
    await family.save();
    state = state.copyWith(family: family);
    return true;
  }

  // ── Boost happiness ────────────────────────────────────────────────────────

  Future<bool> boostHappiness() async {
    final family = state.family;
    if (family == null) return false;
    const cost = 20;
    final wallet = _ref.read(currentUserProvider)?.walletBalance ?? 0;
    if (wallet < cost) return false;
    await _ref.read(authProvider.notifier).addWalletCoins(-cost);
    family
      ..happinessScore = (family.happinessScore + 15).clamp(0, 100)
      ..addEvent('🎉 Family outing boosted happiness!');
    await family.save();
    state = state.copyWith(family: family);
    return true;
  }

  // ── Apply life event effect on family ──────────────────────────────────────

  Future<void> applyHappinessDelta(int delta, String eventDescription) async {
    final family = state.family;
    if (family == null) return;
    family
      ..happinessScore = (family.happinessScore + delta).clamp(0, 100)
      ..addEvent(eventDescription);
    await family.save();
    state = state.copyWith(family: family);
  }

  // ── Monthly expense deduction ──────────────────────────────────────────────

  void _maybeDeductMonthlyExpenses(FamilyModel family) {
    final last = DateTime.tryParse(family.lastUpdatedStr);
    final now = DateTime.now();
    if (last != null) {
      final sameMonth = last.year == now.year && last.month == now.month;
      if (sameMonth) return;
    }
    // Deduct expenses from wallet (best-effort — can go negative briefly)
    final expenses = family.monthlyExpenses;
    _ref.read(authProvider.notifier).addWalletCoins(-expenses);
    family
      ..lastUpdatedStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'
      ..addEvent('📅 Monthly family expenses deducted: ZMW $expenses');
    family.save();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final familyProvider =
    StateNotifierProvider<FamilyNotifier, FamilyState>((ref) {
  final box = Hive.box<FamilyModel>(kFamilyBox);
  final notifier = FamilyNotifier(box, ref);

  ref.listen(authProvider, (prev, next) {
    if (next.currentUser?.uid != prev?.currentUser?.uid) {
      notifier._load();
    }
  });

  return notifier;
});
