/// business_model.dart
/// Purpose: Hive model for the Virtual Business Engine — tracks name, type,
///          stage, revenue/expenses, compliance scores, staff, and event log.
library;

import 'package:hive/hive.dart';

part 'business_model.g.dart';

@HiveType(typeId: 5)
class BusinessModel extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String businessName;

  /// 'retail' | 'services' | 'farming' | 'tech' | 'food'
  @HiveField(2)
  String businessType;

  /// 1 = Startup, 2 = Small Biz, 3 = Growing, 4 = Established, 5 = Enterprise
  @HiveField(3)
  int stage;

  /// Weekly revenue in ZMW.
  @HiveField(4)
  int weeklyRevenue;

  /// Weekly operating expenses in ZMW.
  @HiveField(5)
  int weeklyExpenses;

  /// Compliance score 0–100 (PACRA + ZRA + NAPSA).
  @HiveField(6)
  int complianceScore;

  @HiveField(7)
  int staff;

  /// ISO date string of last weekly decision.
  @HiveField(8)
  String lastDecisionDateStr;

  /// Cumulative profit in ZMW (revenue - expenses across all weeks).
  @HiveField(9)
  int totalProfit;

  @HiveField(10)
  bool pacraRegistered;

  @HiveField(11)
  bool zraTaxFiled;

  @HiveField(12)
  bool napssaContributed;

  /// Up to 10 most recent business event descriptions.
  @HiveField(13)
  List<String> recentEvents;

  /// ISO date string of last weekly profit transfer to wallet.
  @HiveField(14)
  String lastWeeklyUpdateStr;

  BusinessModel({
    required this.uid,
    required this.businessName,
    required this.businessType,
    this.stage = 1,
    this.weeklyRevenue = 500,
    this.weeklyExpenses = 350,
    this.complianceScore = 0,
    this.staff = 0,
    this.lastDecisionDateStr = '',
    this.totalProfit = 0,
    this.pacraRegistered = false,
    this.zraTaxFiled = false,
    this.napssaContributed = false,
    List<String>? recentEvents,
    this.lastWeeklyUpdateStr = '',
  }) : recentEvents = recentEvents ?? [];

  static const List<String> stageNames = [
    'Startup',
    'Small Business',
    'Growing',
    'Established',
    'Enterprise',
  ];

  static const Map<String, String> typeEmojis = {
    'retail': '🛒',
    'services': '🔧',
    'farming': '🌱',
    'tech': '💻',
    'food': '🍽️',
  };

  static const Map<String, int> baseRevenue = {
    'retail': 600,
    'services': 500,
    'farming': 400,
    'tech': 700,
    'food': 550,
  };

  String get stageName => stageNames[stage - 1];
  String get typeEmoji => typeEmojis[businessType] ?? '🏢';
  int get weeklyProfit => weeklyRevenue - weeklyExpenses;

  void addEvent(String event) {
    recentEvents.insert(0, event);
    if (recentEvents.length > 10) recentEvents.removeLast();
  }

  void recalcCompliance() {
    int score = 0;
    if (pacraRegistered) score += 34;
    if (zraTaxFiled) score += 33;
    if (napssaContributed) score += 33;
    complianceScore = score;
  }

  bool get canMakeWeeklyDecision {
    if (lastDecisionDateStr.isEmpty) return true;
    final last = DateTime.tryParse(lastDecisionDateStr);
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= 7;
  }
}
