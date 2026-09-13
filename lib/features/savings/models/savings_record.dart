/// savings_record.dart
/// Purpose: Hive model for a player's savings goals portfolio.
/// SavingsGoalModel is a plain Dart class serialised as Map inside goalsRaw.
library;

import 'package:hive/hive.dart';

part 'savings_record.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Plain Dart data class — embedded via goalsRaw
// ─────────────────────────────────────────────────────────────────────────────

class SavingsGoalModel {
  SavingsGoalModel({
    required this.goalId,
    required this.goalName,
    required this.targetZamCoins,
    required this.savedZamCoins,
    required this.weeklyDepositZamCoins,
    required this.lastDepositDateStr,
    required this.isCompleted,
    required this.createdDateStr,
  });

  String goalId;
  String goalName;
  int targetZamCoins;
  int savedZamCoins;
  int weeklyDepositZamCoins;
  String lastDepositDateStr; // YYYY-MM-DD
  bool isCompleted;
  String createdDateStr;

  double get progress =>
      targetZamCoins == 0 ? 0.0 : (savedZamCoins / targetZamCoins).clamp(0.0, 1.0);

  int get remaining => (targetZamCoins - savedZamCoins).clamp(0, targetZamCoins);

  bool get canDeposit {
    if (isCompleted) return false;
    final last = DateTime.parse(lastDepositDateStr);
    return DateTime.now().difference(last).inDays >= 7;
  }

  // Annual interest rate applied weekly (8% pa ÷ 52 weeks)
  static const double annualInterestRate = 0.08;
  static const double weeklyInterestRate = annualInterestRate / 52;

  Map<String, dynamic> toMap() => {
        'id': goalId,
        'name': goalName,
        'target': targetZamCoins,
        'saved': savedZamCoins,
        'weekly': weeklyDepositZamCoins,
        'lastDeposit': lastDepositDateStr,
        'completed': isCompleted,
        'created': createdDateStr,
      };

  factory SavingsGoalModel.fromMap(Map<String, dynamic> m) => SavingsGoalModel(
        goalId: m['id'] as String,
        goalName: m['name'] as String,
        targetZamCoins: m['target'] as int,
        savedZamCoins: m['saved'] as int,
        weeklyDepositZamCoins: m['weekly'] as int,
        lastDepositDateStr: m['lastDeposit'] as String,
        isCompleted: m['completed'] as bool,
        createdDateStr: m['created'] as String,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// HiveObject container — stored in kSavingsGoalsBox keyed by uid
// ─────────────────────────────────────────────────────────────────────────────

@HiveType(typeId: 15)
class SavingsRecord extends HiveObject {
  SavingsRecord({
    required this.uid,
    required this.goalsRaw,
    required this.recentEvents,
  });

  @HiveField(0) String uid;
  @HiveField(1) List<dynamic> goalsRaw; // List of Map<String, dynamic>
  @HiveField(2) List<String> recentEvents;

  List<SavingsGoalModel> get goals => goalsRaw
      .map((e) => SavingsGoalModel.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList();

  void setGoals(List<SavingsGoalModel> updated) {
    goalsRaw = updated.map((g) => g.toMap()).toList();
  }

  int get totalSavedZamCoins =>
      goals.fold(0, (s, g) => s + g.savedZamCoins);

  int get completedGoals =>
      goals.where((g) => g.isCompleted).length;
}
