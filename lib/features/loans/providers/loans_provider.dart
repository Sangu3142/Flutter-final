/// loans_provider.dart
/// Purpose: Manages loan lifecycle — taking, paying, overdue detection, credit score.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/loans/models/loan_record.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class LoansState {
  const LoansState({this.record, this.isLoading = false});
  final LoanRecord? record;
  final bool isLoading;
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class LoansNotifier extends StateNotifier<LoansState> {
  LoansNotifier(this._ref) : super(const LoansState()) {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.currentUser?.uid != next.currentUser?.uid) _load();
    });
    _load();
  }

  final Ref _ref;
  static const _uuid = Uuid();

  Box<LoanRecord> get _box => Hive.box<LoanRecord>(kLoansBox);
  String? get _uid => _ref.read(currentUserProvider)?.uid;

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      state = const LoansState();
      return;
    }
    final record = _box.get(uid) ?? _createEmpty(uid);
    if (!_box.containsKey(uid)) {
      await _box.put(uid, record);
    }
    _checkOverdue(record);
    await record.save();
    state = LoansState(record: record);
  }

  // ── Take a new loan ───────────────────────────────────────────────────────

  Future<bool> takeLoan({
    required String loanType,
    required int amountZamCoins,
  }) async {
    final uid = _uid;
    if (uid == null) return false;

    final record = _box.get(uid) ?? _createEmpty(uid);

    // Business loan requires PACRA + minimum credit score
    if (loanType == 'business' &&
        record.creditScore < kBusinessLoanMinCreditScore) {
      return false;
    }

    final max = LoanModel.loanMaxAmounts[loanType] ?? 200;
    if (amountZamCoins <= 0 || amountZamCoins > max) return false;

    final rate = LoanModel.loanRates[loanType] ?? 0.25;
    final termMonths = LoanModel.loanTermMonths[loanType] ?? 12;
    // Simple monthly payment: principal * (r/12) / (1 - (1+r/12)^-n)
    final monthlyRate = rate / 12;
    final payment = monthlyRate == 0
        ? (amountZamCoins / termMonths).ceil()
        : (amountZamCoins *
                monthlyRate /
                (1 - (1 + monthlyRate) * -(termMonths.toDouble())))
            .ceil();

    final today = _todayStr();
    final nextDate = _addMonth(today);

    final loan = LoanModel(
      loanId: _uuid.v4().substring(0, 8),
      loanType: loanType,
      principalZamCoins: amountZamCoins,
      interestRateAnnual: rate,
      termMonths: termMonths,
      monthlyPaymentZamCoins: payment.clamp(1, 9999),
      remainingBalanceZamCoins: amountZamCoins,
      monthsRemaining: termMonths,
      isOverdue: false,
      nextPaymentDateStr: nextDate,
      takenDateStr: today,
    );

    final loans = record.loans..add(loan);
    record.setLoans(loans);
    await _ref.read(authProvider.notifier).addWalletCoins(amountZamCoins);
    _addEvent(record,
        '🏦 Took ${LoanModel.loanEmojis[loanType]} ${_loanLabel(loanType)} loan: $amountZamCoins ZC');
    if (!_box.containsKey(uid)) {
      await _box.put(uid, record);
    } else {
      await record.save();
    }
    state = LoansState(record: record);
    return true;
  }

  // ── Pay monthly instalment ────────────────────────────────────────────────

  Future<bool> payInstalment(String loanId) async {
    final record = state.record;
    if (record == null) return false;

    final loans = record.loans;
    final idx = loans.indexWhere((l) => l.loanId == loanId);
    if (idx < 0) return false;

    final loan = loans[idx];
    if (loan.isPaidOff) return false;

    final payment = loan.monthlyPaymentZamCoins;
    final spent =
        await _ref.read(authProvider.notifier).spendWalletCoins(payment);
    if (!spent) return false;

    loan.remainingBalanceZamCoins =
        (loan.remainingBalanceZamCoins - payment).clamp(0, 999999);
    loan.monthsRemaining -= 1;
    loan.isOverdue = false;
    loan.nextPaymentDateStr = _addMonth(_todayStr());

    // Credit score boost for on-time payment
    record.creditScore =
        (record.creditScore + kOnTimeCreditReward).clamp(0, 850);

    final msg = loan.isPaidOff
        ? '🎉 Loan fully repaid!'
        : '✅ Paid ${_loanLabel(loan.loanType)} instalment ($payment ZC)';
    _addEvent(record, msg);

    record.setLoans(loans);
    await record.save();
    state = LoansState(record: record);
    return true;
  }

  // ── Overdue detection (called on load) ────────────────────────────────────

  void _checkOverdue(LoanRecord record) {
    final today = DateTime.now();
    final loans = record.loans;
    bool changed = false;

    for (final loan in loans) {
      if (loan.isPaidOff || loan.isOverdue) continue;
      final due = DateTime.parse(loan.nextPaymentDateStr);
      if (today.isAfter(due)) {
        loan.isOverdue = true;
        record.creditScore =
            (record.creditScore - kOverdueCreditPenalty).clamp(0, 850);
        _addEvent(record,
            '⚠️ ${_loanLabel(loan.loanType)} loan overdue! Credit score dropped.');
        changed = true;
      }
    }

    if (changed) {
      record.setLoans(loans);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  LoanRecord _createEmpty(String uid) => LoanRecord(
        uid: uid,
        loansRaw: [],
        creditScore: kCreditScoreDefault,
        recentEvents: [],
      );

  void _addEvent(LoanRecord r, String msg) {
    r.recentEvents.insert(0, msg);
    if (r.recentEvents.length > 10) r.recentEvents.removeLast();
  }

  String _loanLabel(String type) =>
      type[0].toUpperCase() + type.substring(1);

  String _todayStr() => DateTime.now().toIso8601String().split('T')[0];

  String _addMonth(String dateStr) {
    final d = DateTime.parse(dateStr);
    final next = DateTime(d.year, d.month + 1, d.day);
    return next.toIso8601String().split('T')[0];
  }

  // Credit score getter for cross-feature use
  int get creditScore => state.record?.creditScore ?? kCreditScoreDefault;
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final loansProvider =
    StateNotifierProvider<LoansNotifier, LoansState>((ref) {
  return LoansNotifier(ref);
});
