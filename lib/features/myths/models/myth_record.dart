/// myth_record.dart
/// Purpose: Hive model that tracks which myths a player has seen/answered.
library;

import 'package:hive/hive.dart';

part 'myth_record.g.dart';

@HiveType(typeId: 18)
class MythRecord extends HiveObject {
  MythRecord({
    required this.uid,
    required this.seenMythIds,
    required this.correctMythIds,
    required this.totalMythsAnswered,
    required this.lastDailyDateStr,
    required this.todaysMythIds,
  });

  @HiveField(0) String uid;
  @HiveField(1) List<int> seenMythIds;
  @HiveField(2) List<int> correctMythIds;
  @HiveField(3) int totalMythsAnswered;
  @HiveField(4) String lastDailyDateStr;
  @HiveField(5) List<int> todaysMythIds;
}
