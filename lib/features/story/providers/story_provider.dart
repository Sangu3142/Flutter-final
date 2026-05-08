library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/story/models/story_chapter_progress.dart';

@immutable
class StoryState {
  const StoryState({required this.chapters});

  final Map<int, StoryChapterProgress> chapters;

  bool isUnlocked(int chapterId) =>
      chapterId == 1 || (chapters[chapterId]?.isUnlocked ?? false);

  int playerChoice(int chapterId) =>
      chapters[chapterId]?.playerChoice ?? 0;

  bool hasChoice(int chapterId) => playerChoice(chapterId) != 0;
}

class StoryNotifier extends StateNotifier<StoryState> {
  StoryNotifier(this._ref) : super(const StoryState(chapters: {})) {
    _load();
  }

  final Ref _ref;

  void _load() {
    final uid = _ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    final box = Hive.box<StoryChapterProgress>(kStoryBox);
    final map = <int, StoryChapterProgress>{};
    for (final ch in kStoryChapters) {
      final record = box.get('${uid}_${ch.chapterId}');
      if (record != null) map[ch.chapterId] = record;
    }
    state = StoryState(chapters: map);
  }

  /// Returns false if the user cannot afford the unlock cost.
  Future<bool> unlockChapter(int chapterId) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return false;

    final data = kStoryChapters.firstWhere(
      (c) => c.chapterId == chapterId,
      orElse: () => kStoryChapters.first,
    );

    // xpCost is a minimum XP gate, not deducted. zamCoinCost is deducted.
    if (user.xp < data.xpCost || user.zamCoins < data.zamCoinCost) {
      return false;
    }

    user.zamCoins -= data.zamCoinCost;
    user.unlockChapter(chapterId);
    await user.save();

    final box = Hive.box<StoryChapterProgress>(kStoryBox);
    final progress = StoryChapterProgress(
      uid: user.uid,
      chapterId: chapterId,
      isUnlocked: true,
      playerChoice: 0,
      dateUnlockedStr: DateTime.now().toIso8601String(),
    );
    await box.put('${user.uid}_$chapterId', progress);

    _ref.read(authProvider.notifier).refreshUser();
    _load();
    return true;
  }

  Future<void> recordChoice(int chapterId, int choice) async {
    final uid = _ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    final box = Hive.box<StoryChapterProgress>(kStoryBox);
    final key = '${uid}_$chapterId';
    final existing = box.get(key);
    if (existing == null) return;
    existing.playerChoice = choice;
    await existing.save();
    _load();
  }
}

final storyProvider =
    StateNotifierProvider<StoryNotifier, StoryState>((ref) {
  return StoryNotifier(ref);
});
