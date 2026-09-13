library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/models/user_profile.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/badges/providers/badge_provider.dart';
import 'package:zamwealth_quest/features/story/models/dialogue_moment.dart';
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
    // Use walletBalance (same field as walletProvider) so the HUD stays in sync.
    if (user.xp < data.xpCost || user.walletBalance < data.zamCoinCost) {
      return false;
    }

    // Spend via authProvider so walletProvider fires reactively for all screens.
    final spent = await _ref
        .read(authProvider.notifier)
        .spendWalletCoins(data.zamCoinCost);
    if (!spent) return false;

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

  Future<void> recordDialogueChoice(
    String momentId,
    int choiceIndex,
    DialogueOption option,
  ) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final choices = Map<dynamic, dynamic>.from(user.storyChoicesRaw);
    choices[momentId] = choiceIndex;
    user.storyChoicesRaw = choices;
    await user.save();

    await _ref.read(authProvider.notifier).addXp(option.xpDelta);

    if (option.leadsToBadge != null) {
      _checkStoryPathBadge(user, option.leadsToBadge!);
    }
  }

  void _checkStoryPathBadge(UserProfile user, String badgeId) {
    final choices = (user.storyChoicesRaw)
        .map((k, v) => MapEntry(k.toString(), v as int));

    final momentsForBadge = kDialogueMoments.values
        .where((m) => m.options.any((o) => o.leadsToBadge == badgeId));

    final matchingChosen = momentsForBadge.where((m) {
      final idx = choices[m.momentId];
      if (idx == null) return false;
      return m.options[idx].leadsToBadge == badgeId;
    });

    if (momentsForBadge.isNotEmpty &&
        matchingChosen.length == momentsForBadge.length) {
      _ref.read(badgeServiceProvider).awardById(badgeId);
    }
  }
}

final storyProvider =
    StateNotifierProvider<StoryNotifier, StoryState>((ref) {
  return StoryNotifier(ref);
});
