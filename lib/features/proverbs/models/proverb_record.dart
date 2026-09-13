/// proverb_record.dart
/// Purpose: Hive model that tracks collected Zambian proverbs.
library;

import 'package:hive/hive.dart';

part 'proverb_record.g.dart';

@HiveType(typeId: 21)
class ProverbRecord extends HiveObject {
  ProverbRecord({
    required this.uid,
    required this.collectedProverbIds,
    required this.totalProverbsSeen,
  });

  @HiveField(0) String uid;
  @HiveField(1) List<int> collectedProverbIds;
  @HiveField(2) int totalProverbsSeen;
}
