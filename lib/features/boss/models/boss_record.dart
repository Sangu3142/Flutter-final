/// boss_record.dart
/// Purpose: Hive model for boss battle progress — tracks defeat status, replay count, and best score per level.
/// Reads from: Hive box 'boss_records'
/// Writes to: Hive box 'boss_records'
/// Navigation: none (data model only)
library;

import 'package:hive/hive.dart';

part 'boss_record.g.dart';

@HiveType(typeId: 13)
class BossRecord extends HiveObject {
  @HiveField(0)
  int levelId;

  @HiveField(1)
  bool defeated;

  @HiveField(2)
  int replayCount;

  @HiveField(3)
  int bestScore;

  @HiveField(4)
  String? defeatedAt;

  BossRecord({
    required this.levelId,
    required this.defeated,
    required this.replayCount,
    required this.bestScore,
    this.defeatedAt,
  });

  factory BossRecord.fresh(int levelId) => BossRecord(
        levelId: levelId,
        defeated: false,
        replayCount: 0,
        bestScore: 0,
      );
}
