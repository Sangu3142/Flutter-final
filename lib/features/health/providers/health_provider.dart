/// health_provider.dart
/// Purpose: Computes the 5-sub-score Financial Health Score and manages
///          weekly score history in Hive.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/business/providers/business_provider.dart';
import 'package:zamwealth_quest/features/health/models/health_record.dart';
import 'package:zamwealth_quest/features/loans/providers/loans_provider.dart';
import 'package:zamwealth_quest/features/portfolio/providers/portfolio_provider.dart';
import 'package:zamwealth_quest/features/savings/providers/savings_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Health Data
// ─────────────────────────────────────────────────────────────────────────────

class HealthData {
  const HealthData({
    required this.emergencyFundScore,
    required this.debtHealthScore,
    required this.investmentScore,
    required this.incomeScore,
    required this.budgetScore,
  });

  final int emergencyFundScore; // 0–20
  final int debtHealthScore;    // 0–20
  final int investmentScore;    // 0–20
  final int incomeScore;        // 0–20
  final int budgetScore;        // 0–20

  int get totalScore =>
      emergencyFundScore + debtHealthScore + investmentScore + incomeScore + budgetScore;

  String get band {
    if (totalScore >= 86) return 'Excellent';
    if (totalScore >= 71) return 'Good';
    if (totalScore >= 41) return 'Fair';
    return 'Needs Work';
  }

  String get tip {
    if (emergencyFundScore < 8) return 'Build your emergency fund — target 1,000 ZamCoins saved.';
    if (debtHealthScore < 8) return 'Pay loans on time to rebuild your credit score.';
    if (investmentScore < 8) return 'Start investing in LUSE Shares or Government Bonds.';
    if (incomeScore < 8) return 'Grow your income — consider starting or expanding a business.';
    if (budgetScore < 8) return 'Reduce overdue obligations and maintain a wallet buffer.';
    return 'Great discipline! Keep saving and investing consistently.';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class HealthState {
  const HealthState({this.data, this.record, this.isLoading = false});

  final HealthData? data;
  final HealthRecord? record;
  final bool isLoading;
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class HealthNotifier extends StateNotifier<HealthState> {
  HealthNotifier(this._ref) : super(const HealthState(isLoading: true)) {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.currentUser?.uid != next.currentUser?.uid) _load();
    });
    _load();
  }

  final Ref _ref;

  Box<HealthRecord> get _box => Hive.box<HealthRecord>(kHealthBox);
  String? get _uid => _ref.read(currentUserProvider)?.uid;

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      state = const HealthState();
      return;
    }

    var record = _box.get(uid);
    if (record == null) {
      record = HealthRecord(
        uid: uid,
        scoreHistory: [],
        scoreDatesHistory: [],
        lastScoredDateStr: '2000-01-01',
      );
      await _box.put(uid, record);
    }

    final data = _computeHealth();
    await _maybeSaveWeekly(record, data.totalScore);

    state = HealthState(data: data, record: _box.get(uid));
  }

  Future<void> refresh() => _load();

  HealthData _computeHealth() {
    final user    = _ref.read(currentUserProvider);
    final loans   = _ref.read(loansProvider).record;
    final port    = _ref.read(portfolioProvider).portfolio;
    final biz     = _ref.read(businessProvider).business;
    final sav     = _ref.read(savingsProvider).record;
    final wallet  = user?.walletBalance ?? 0;
    final totalSaved = sav?.totalSavedZamCoins ?? 0;

    // ── 1. Emergency Fund (target 1,000 ZC saved) ─────────────────────────
    final emergencyScore = (totalSaved / 1000.0 * 20).floor().clamp(0, 20);

    // ── 2. Debt Health (creditScore 500–850 → 0–20) ──────────────────────
    final creditScore  = loans?.creditScore ?? kCreditScoreDefault;
    final activeLoans  = loans?.loans.where((l) => !l.isPaidOff).length ?? 0;
    final debtScore    = activeLoans == 0
        ? 20
        : ((creditScore - 500) / 350.0 * 20).round().clamp(0, 20);

    // ── 3. Investment Growth ──────────────────────────────────────────────
    final invested    = port?.totalInvestedZamCoins ?? 0;
    final returnsPct  = port?.returnsPercent ?? 0.0;
    final int investScore;
    if (invested == 0) {
      investScore = 5;
    } else if (returnsPct >= 15) { investScore = 20; }
    else if (returnsPct >= 8)  { investScore = 16; }
    else if (returnsPct >= 0)  { investScore = 12; }
    else if (returnsPct >= -5) { investScore = 8; }
    else                       { investScore = 4; }

    // ── 4. Income Stability ───────────────────────────────────────────────
    int incomeScore = 0;
    if ((biz?.weeklyProfit ?? 0) > 0) incomeScore += 10;
    if (wallet >= 1000) {
      incomeScore += 10;
    } else if (wallet >= 500)  { incomeScore += 6; }
    else if (wallet >= 100)    { incomeScore += 3; }
    incomeScore = incomeScore.clamp(0, 20);

    // ── 5. Budget Discipline ─────────────────────────────────────────────
    final hasOverdue = loans?.loans.any((l) => l.isOverdue && !l.isPaidOff) ?? false;
    int budgetScore = 0;
    if (!hasOverdue)      budgetScore += 8;
    if (totalSaved > 0)   budgetScore += 6;
    if (wallet >= 200)    budgetScore += 6;
    budgetScore = budgetScore.clamp(0, 20);

    return HealthData(
      emergencyFundScore: emergencyScore,
      debtHealthScore:    debtScore,
      investmentScore:    investScore,
      incomeScore:        incomeScore,
      budgetScore:        budgetScore,
    );
  }

  Future<void> _maybeSaveWeekly(HealthRecord record, int score) async {
    final last = DateTime.tryParse(record.lastScoredDateStr) ?? DateTime(2000);
    if (DateTime.now().difference(last).inDays < 7) return;

    record.scoreHistory.add(score);
    record.scoreDatesHistory.add(_todayStr());
    record.lastScoredDateStr = _todayStr();

    if (record.scoreHistory.length > kHealthHistoryMax) {
      record.scoreHistory.removeAt(0);
      record.scoreDatesHistory.removeAt(0);
    }
    await record.save();
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final healthProvider =
    StateNotifierProvider<HealthNotifier, HealthState>((ref) => HealthNotifier(ref));
