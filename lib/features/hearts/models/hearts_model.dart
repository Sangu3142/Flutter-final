/// hearts_model.dart
/// Purpose: Hive model for player hearts — tracks count and loss timestamps for 30-minute refill logic.
/// Reads from: Hive box 'hearts'
/// Writes to: Hive box 'hearts'
/// Navigation: none (data model only)
library;

import 'package:hive/hive.dart';

part 'hearts_model.g.dart';

@HiveType(typeId: 10)
class HeartsModel extends HiveObject {
  @HiveField(0)
  int heartsCount;

  @HiveField(1)
  List<String> lostAt; // ISO-8601 timestamps of each heart loss

  HeartsModel({
    required this.heartsCount,
    required this.lostAt,
  });

  factory HeartsModel.full() => HeartsModel(
        heartsCount: 5,
        lostAt: [],
      );
}
