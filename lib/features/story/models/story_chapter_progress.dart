library;

import 'package:hive/hive.dart';

part 'story_chapter_progress.g.dart';

@HiveType(typeId: 12)
class StoryChapterProgress extends HiveObject {
  StoryChapterProgress({
    required this.uid,
    required this.chapterId,
    this.isUnlocked = false,
    this.playerChoice = 0,
    this.dateUnlockedStr,
  });

  @HiveField(0)
  String uid;

  @HiveField(1)
  int chapterId;

  @HiveField(2)
  bool isUnlocked;

  /// 0 = no choice made, 1 = Choice A, 2 = Choice B.
  @HiveField(3)
  int playerChoice;

  @HiveField(4)
  String? dateUnlockedStr;

  String get boxKey => '${uid}_$chapterId';
}
