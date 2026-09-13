/// spotlight_record.dart
/// Purpose: Hive model that tracks entrepreneur spotlight story progress.
library;

import 'package:hive/hive.dart';

part 'spotlight_record.g.dart';

@HiveType(typeId: 19)
class SpotlightRecord extends HiveObject {
  SpotlightRecord({
    required this.uid,
    required this.completedSpotlightIds,
    required this.chapterProgress,
    required this.choicesJson,
  });

  @HiveField(0) String uid;
  /// IDs of stories the player has finished.
  @HiveField(1) List<int> completedSpotlightIds;
  /// Chapter index reached per story (story index → chapter 0–4).
  @HiveField(2) List<int> chapterProgress;
  /// JSON-encoded Map<String, List<int>> of choices made per story.
  @HiveField(3) String choicesJson;
}
