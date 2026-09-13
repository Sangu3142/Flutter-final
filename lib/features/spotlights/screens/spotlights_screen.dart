/// spotlights_screen.dart
/// Purpose: Lists all entrepreneur spotlight stories with lock/unlock state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/features/spotlights/providers/spotlight_provider.dart';

class SpotlightsScreen extends ConsumerWidget {
  const SpotlightsScreen({super.key});

  static const _navy = Color(0xFF00203F);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(spotlightProvider);
    final notifier = ref.read(spotlightProvider.notifier);

    return Scaffold(
      backgroundColor: _navy,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Entrepreneur Spotlights',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Text(
                    'Follow Zambian entrepreneurs through real financial decisions. Choose wisely.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: kAllSpotlights.length,
                    itemBuilder: (context, i) {
                      final story   = kAllSpotlights[i];
                      final unlocked = notifier.isUnlocked(story);
                      final done    = state.isCompleted(story.id);
                      final chapter = state.chapterFor(i);
                      return _StoryCard(
                        story: story,
                        unlocked: unlocked,
                        completed: done,
                        chapterProgress: chapter,
                        onTap: unlocked
                            ? () => context.push(
                                AppRoutes.spotlightStory,
                                extra: {'storyId': story.id, 'storyIdx': i},
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.story,
    required this.unlocked,
    required this.completed,
    required this.chapterProgress,
    this.onTap,
  });

  final SpotlightStory story;
  final bool           unlocked;
  final bool           completed;
  final int            chapterProgress;
  final VoidCallback?  onTap;

  static const _gold = Color(0xFFFFD700);
  static const _teal = Color(0xFF36ECDE);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: unlocked ? const Color(0xFF0D2137) : const Color(0xFF0A1520),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: completed ? _teal.withValues(alpha: 0.7)
                : unlocked ? _gold.withValues(alpha: 0.3)
                : Colors.white12,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Emoji avatar
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: unlocked ? _gold.withValues(alpha: 0.12) : Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(story.emoji,
                      style: TextStyle(fontSize: 28, color: unlocked ? null : null)
                              .copyWith(color: unlocked ? null : const Color(0x88FFFFFF))),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + completion badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(story.title,
                              style: TextStyle(
                                color: unlocked ? Colors.white : Colors.white38,
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        if (completed)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: _teal.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                            child: const Text('Done', style: TextStyle(color: _teal, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(story.protagonist,
                        style: TextStyle(color: unlocked ? Colors.white54 : Colors.white24, fontSize: 12)),
                    const SizedBox(height: 8),
                    // Chapter dots
                    Row(
                      children: [
                        ...List.generate(5, (c) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: !unlocked ? Colors.white12
                                : c < chapterProgress ? _gold
                                : Colors.white24,
                          ),
                        )),
                        const SizedBox(width: 8),
                        Text(unlocked ? '$chapterProgress/5 chapters' : 'Unlock Level ${story.unlockLevel}',
                            style: TextStyle(color: unlocked ? Colors.white38 : Colors.white24, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('+${story.xpReward} XP on completion',
                        style: TextStyle(color: unlocked ? _gold.withValues(alpha: 0.7) : Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              if (!unlocked)
                const Icon(Icons.lock_outline, color: Colors.white24, size: 20)
              else
                const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
