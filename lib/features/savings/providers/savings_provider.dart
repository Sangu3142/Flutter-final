/// savings_provider.dart
/// Purpose: Manages savings goals — creation, weekly deposits, interest accrual.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/savings/models/savings_record.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class SavingsState {
  const SavingsState({this.record, this.isLoading = false});
  final SavingsRecord? record;
  final bool isLoading;
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class SavingsNotifier extends StateNotifier<SavingsState> {
  SavingsNotifier(this._ref) : super(const SavingsState()) {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.currentUser?.uid != next.currentUser?.uid) _load();
    });
    _load();
  }

  final Ref _ref;
  static const _uuid = Uuid();

  Box<SavingsRecord> get _box => Hive.box<SavingsRecord>(kSavingsGoalsBox);
  String? get _uid => _ref.read(currentUserProvider)?.uid;

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      state = const SavingsState();
      return;
    }
    SavingsRecord? record = _box.get(uid);
    if (record == null) {
      record = SavingsRecord(uid: uid, goalsRaw: [], recentEvents: []);
      await _box.put(uid, record);
    }
    await _maybeApplyWeeklyInterest(record);
    state = SavingsState(record: _box.get(uid));
  }

  // ── Create goal ───────────────────────────────────────────────────────────

  Future<bool> createGoal({
    required String goalName,
    required int targetZamCoins,
    required int weeklyDepositZamCoins,
  }) async {
    final uid = _uid;
    if (uid == null) return false;
    final record = _box.get(uid);
    if (record == null) return false;

    final goals = record.goals;
    if (goals.length >= kMaxSavingsGoals) return false;
    if (targetZamCoins <= 0 || weeklyDepositZamCoins <= 0) return false;

    final goal = SavingsGoalModel(
      goalId: _uuid.v4().substring(0, 8),
      goalName: goalName,
      targetZamCoins: targetZamCoins,
      savedZamCoins: 0,
      weeklyDepositZamCoins: weeklyDepositZamCoins,
      lastDepositDateStr: _pastWeekStr(),
      isCompleted: false,
      createdDateStr: _todayStr(),
    );

    goals.add(goal);
    record.setGoals(goals);
    _addEvent(record, '🎯 New goal: $goalName (target: $targetZamCoins ZC)');
    await record.save();
    state = SavingsState(record: record);
    return true;
  }

  // ── Deposit weekly amount ─────────────────────────────────────────────────

  Future<bool> deposit(String goalId) async {
    final record = state.record;
    if (record == null) return false;

    final goals = record.goals;
    final idx = goals.indexWhere((g) => g.goalId == goalId);
    if (idx < 0) return false;

    final goal = goals[idx];
    if (!goal.canDeposit) return false;

    final amount = goal.weeklyDepositZamCoins;
    final spent =
        await _ref.read(authProvider.notifier).spendWalletCoins(amount);
    if (!spent) return false;

    goal.savedZamCoins += amount;
    goal.lastDepositDateStr = _todayStr();

    if (goal.savedZamCoins >= goal.targetZamCoins) {
      goal.isCompleted = true;
      goal.savedZamCoins = goal.targetZamCoins;
      _addEvent(record, '🏆 Goal "${goal.goalName}" completed!');
      await _ref.read(authProvider.notifier).addXp(100);
      await _ref.read(authProvider.notifier).addWalletCoins(20);
    } else {
      _addEvent(
          record, '✅ Saved $amount ZC → ${goal.goalName} (${(goal.progress * 100).round()}%)');
    }

    record.setGoals(goals);
    await record.save();
    state = SavingsState(record: record);
    return true;
  }

  // ── Delete goal ───────────────────────────────────────────────────────────

  Future<void> deleteGoal(String goalId) async {
    final record = state.record;
    if (record == null) return;

    final goals = record.goals..removeWhere((g) => g.goalId == goalId);
    record.setGoals(goals);
    await record.save();
    state = SavingsState(record: record);
  }

  // ── Weekly interest on all active goals (8% pa ÷ 52) ─────────────────────

  Future<void> _maybeApplyWeeklyInterest(SavingsRecord record) async {
    final goals = record.goals;
    bool changed = false;

    for (final goal in goals) {
      if (goal.isCompleted || goal.savedZamCoins == 0) continue;
      final last = DateTime.parse(goal.lastDepositDateStr);
      final weeksElapsed = DateTime.now().difference(last).inDays ~/ 7;
      if (weeksElapsed <= 0) continue;

      for (int i = 0; i < weeksElapsed; i++) {
        final interest =
            (goal.savedZamCoins * SavingsGoalModel.weeklyInterestRate).round();
        if (interest > 0) {
          goal.savedZamCoins += interest;
          changed = true;
        }
      }

      if (goal.savedZamCoins >= goal.targetZamCoins) {
        goal.savedZamCoins = goal.targetZamCoins;
        goal.isCompleted = true;
        _addEvent(record, '🏆 "${goal.goalName}" reached target via interest!');
      }
    }

    if (changed) {
      record.setGoals(goals);
      await record.save();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _addEvent(SavingsRecord r, String msg) {
    r.recentEvents.insert(0, msg);
    if (r.recentEvents.length > 10) r.recentEvents.removeLast();
  }

  String _todayStr() => DateTime.now().toIso8601String().split('T')[0];

  String _pastWeekStr() {
    final d = DateTime.now().subtract(const Duration(days: 8));
    return d.toIso8601String().split('T')[0];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final savingsProvider =
    StateNotifierProvider<SavingsNotifier, SavingsState>((ref) {
  return SavingsNotifier(ref);
});
