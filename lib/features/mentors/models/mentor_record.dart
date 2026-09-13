/// mentor_record.dart
/// Purpose: Hive model that persists unlocked mentors and challenge progress.
library;

import 'package:hive/hive.dart';

part 'mentor_record.g.dart';

@HiveType(typeId: 20)
class MentorRecord extends HiveObject {
  MentorRecord({
    required this.uid,
    required this.unlockedMentorIds,
    required this.lastTipDatesJson,
    required this.challengesCompletedJson,
  });

  @HiveField(0) String uid;
  @HiveField(1) List<String> unlockedMentorIds;
  /// JSON-encoded Map<String, String> — mentorId → ISO date of last tip shown.
  @HiveField(2) String lastTipDatesJson;
  /// JSON-encoded Map<String, int> — mentorId → challenges completed count.
  @HiveField(3) String challengesCompletedJson;
}
