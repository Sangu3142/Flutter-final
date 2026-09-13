/// loan_record.dart
/// Purpose: Hive model for a player's loan portfolio and credit score.
/// LoanModel is a plain Dart class serialised as Map inside loansRaw.
library;

import 'package:hive/hive.dart';

part 'loan_record.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Plain Dart data class — not stored in its own box, embedded via loansRaw
// ─────────────────────────────────────────────────────────────────────────────

class LoanModel {
  LoanModel({
    required this.loanId,
    required this.loanType,
    required this.principalZamCoins,
    required this.interestRateAnnual,
    required this.termMonths,
    required this.monthlyPaymentZamCoins,
    required this.remainingBalanceZamCoins,
    required this.monthsRemaining,
    required this.isOverdue,
    required this.nextPaymentDateStr,
    required this.takenDateStr,
  });

  String loanId;
  String loanType; // 'personal', 'business', 'home', 'emergency'
  int principalZamCoins;
  double interestRateAnnual;
  int termMonths;
  int monthlyPaymentZamCoins;
  int remainingBalanceZamCoins;
  int monthsRemaining;
  bool isOverdue;
  String nextPaymentDateStr; // YYYY-MM-DD
  String takenDateStr;       // YYYY-MM-DD

  bool get isPaidOff =>
      monthsRemaining <= 0 || remainingBalanceZamCoins <= 0;

  Map<String, dynamic> toMap() => {
        'id': loanId,
        'type': loanType,
        'principal': principalZamCoins,
        'rate': interestRateAnnual,
        'term': termMonths,
        'monthly': monthlyPaymentZamCoins,
        'remaining': remainingBalanceZamCoins,
        'months': monthsRemaining,
        'overdue': isOverdue,
        'nextDate': nextPaymentDateStr,
        'takenDate': takenDateStr,
      };

  factory LoanModel.fromMap(Map<String, dynamic> m) => LoanModel(
        loanId: m['id'] as String,
        loanType: m['type'] as String,
        principalZamCoins: m['principal'] as int,
        interestRateAnnual: (m['rate'] as num).toDouble(),
        termMonths: m['term'] as int,
        monthlyPaymentZamCoins: m['monthly'] as int,
        remainingBalanceZamCoins: m['remaining'] as int,
        monthsRemaining: m['months'] as int,
        isOverdue: m['overdue'] as bool,
        nextPaymentDateStr: m['nextDate'] as String,
        takenDateStr: m['takenDate'] as String,
      );

  // ── Loan product catalogue ────────────────────────────────────────────────
  static const Map<String, double> loanRates = {
    'personal': 0.25,
    'business': 0.18,
    'home': 0.12,
    'emergency': 0.30,
  };
  static const Map<String, int> loanMaxAmounts = {
    'personal': 200,
    'business': 500,
    'home': 1000,
    'emergency': 100,
  };
  static const Map<String, int> loanTermMonths = {
    'personal': 12,
    'business': 24,
    'home': 60,
    'emergency': 6,
  };
  static const Map<String, String> loanEmojis = {
    'personal': '👤',
    'business': '🏢',
    'home': '🏠',
    'emergency': '🚨',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// HiveObject container — stored in kLoansBox keyed by uid
// ─────────────────────────────────────────────────────────────────────────────

@HiveType(typeId: 14)
class LoanRecord extends HiveObject {
  LoanRecord({
    required this.uid,
    required this.loansRaw,
    required this.creditScore,
    required this.recentEvents,
  });

  @HiveField(0) String uid;
  @HiveField(1) List<dynamic> loansRaw; // List of Map<String, dynamic>
  @HiveField(2) int creditScore;
  @HiveField(3) List<String> recentEvents;

  List<LoanModel> get loans => loansRaw
      .map((e) => LoanModel.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList();

  void setLoans(List<LoanModel> updated) {
    loansRaw = updated.map((l) => l.toMap()).toList();
  }

  int get totalMonthlyPayments =>
      loans.fold(0, (s, l) => s + (l.isPaidOff ? 0 : l.monthlyPaymentZamCoins));
}
