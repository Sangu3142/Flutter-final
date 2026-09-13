/// health_record.dart
/// Purpose: Hive model for Financial Health Score — weekly score history.
library;

import 'package:hive/hive.dart';

part 'health_record.g.dart';

@HiveType(typeId: 17)
class HealthRecord extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  List<int> scoreHistory;

  @HiveField(2)
  List<String> scoreDatesHistory;

  @HiveField(3)
  String lastScoredDateStr;

  HealthRecord({
    required this.uid,
    required this.scoreHistory,
    required this.scoreDatesHistory,
    required this.lastScoredDateStr,
  });
}
