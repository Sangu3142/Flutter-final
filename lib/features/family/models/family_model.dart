/// family_model.dart
/// Purpose: Hive model for the Virtual Family system — tracks spouse/child
///          names, happiness, health, housing, food budget, school status,
///          and a log of recent family events.
library;

import 'package:hive/hive.dart';

part 'family_model.g.dart';

@HiveType(typeId: 4)
class FamilyModel extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String spouseName;

  @HiveField(2)
  String childName;

  /// Happiness 0–100. Starts at 70.
  @HiveField(3)
  int happinessScore;

  /// Health 0–100. Starts at 80.
  @HiveField(4)
  int healthScore;

  /// 1 = rented room, 2 = apartment, 3 = own house.
  @HiveField(5)
  int housingTier;

  /// Monthly food budget in ZMW.
  @HiveField(6)
  int monthlyFoodBudget;

  @HiveField(7)
  bool childInSchool;

  @HiveField(8)
  bool schoolFeesPaid;

  /// Up to 10 most recent event descriptions.
  @HiveField(9)
  List<String> recentEvents;

  /// ISO date string 'YYYY-MM-DD' of last update.
  @HiveField(10)
  String lastUpdatedStr;

  /// Total monthly family expenses in ZMW (food + housing + school).
  @HiveField(11)
  int monthlyExpenses;

  FamilyModel({
    required this.uid,
    required this.spouseName,
    required this.childName,
    this.happinessScore = 70,
    this.healthScore = 80,
    this.housingTier = 1,
    this.monthlyFoodBudget = 800,
    this.childInSchool = true,
    this.schoolFeesPaid = false,
    List<String>? recentEvents,
    this.lastUpdatedStr = '',
    this.monthlyExpenses = 1200,
  }) : recentEvents = recentEvents ?? [];

  static const List<String> housingNames = [
    'Rented Room',
    'Apartment',
    'Own House',
  ];

  static const List<int> housingCosts = [400, 700, 1000];
  static const List<int> housingUpgradeCosts = [0, 50, 100]; // ZamCoins

  String get housingName => housingNames[housingTier - 1];

  void addEvent(String event) {
    recentEvents.insert(0, event);
    if (recentEvents.length > 10) recentEvents.removeLast();
  }

  void clampScores() {
    happinessScore = happinessScore.clamp(0, 100);
    healthScore = healthScore.clamp(0, 100);
  }

  void recalcExpenses() {
    monthlyExpenses =
        monthlyFoodBudget + housingCosts[housingTier - 1] + (childInSchool ? 300 : 0);
  }
}
