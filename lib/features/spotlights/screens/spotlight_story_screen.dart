/// spotlight_story_screen.dart
/// Purpose: Full-screen story reading experience with chapter navigation
///          and 3 decision points per story.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/features/spotlights/providers/spotlight_provider.dart';

class SpotlightStoryScreen extends ConsumerStatefulWidget {
  const SpotlightStoryScreen({super.key, required this.storyId, required this.storyIdx});
  final int storyId;
  final int storyIdx;

  @override
  ConsumerState<SpotlightStoryScreen> createState() => _SpotlightStoryScreenState();
}

class _SpotlightStoryScreenState extends ConsumerState<SpotlightStoryScreen> {
  int _localChapter = 0;
  final Map<int, int> _choices = {};
  bool _showingEnding = false;

  static const _navy  = Color(0xFF00203F);
  static const _gold  = Color(0xFFFFD700);
  static const _teal  = Color(0xFF36ECDE);

  SpotlightStory get _story => kAllSpotlights.firstWhere((s) => s.id == widget.storyId);

  // Decision points appear after chapters 1, 2, 3
  bool get _isDecisionChapter => _localChapter > 0 && _localChapter <= 3 && !_choices.containsKey(_localChapter - 1);

  @override
  void initState() {
    super.initState();
    final saved = ref.read(spotlightProvider).chapterFor(widget.storyIdx);
    _localChapter = saved;
  }

  Future<void> _nextChapter() async {
    if (_localChapter < 4) {
      setState(() => _localChapter++);
      await ref.read(spotlightProvider.notifier).advanceChapter(widget.storyIdx);
    } else {
      setState(() => _showingEnding = true);
      await ref.read(spotlightProvider.notifier).completeStory(widget.storyId);
    }
  }

  Future<void> _makeChoice(int decisionIdx, int choiceIdx) async {
    setState(() => _choices[decisionIdx] = choiceIdx);
    await ref.read(spotlightProvider.notifier).makeChoice(widget.storyId, decisionIdx, choiceIdx);
  }

  // Determine which ending: A if majority chose A (0), else B
  bool get _endingIsA {
    final vals = _choices.values.toList();
    return vals.where((v) => v == 0).length >= vals.where((v) => v == 1).length;
  }

  @override
  Widget build(BuildContext context) {
    final story = _story;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1520),
      body: _showingEnding ? _endingView(story) : _readingView(story),
    );
  }

  Widget _readingView(SpotlightStory story) {
    if (_isDecisionChapter) { return _decisionView(story, _localChapter - 1); }

    final chapter = story.chapters[_localChapter.clamp(0, 4)];
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => context.pop()),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(story.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Chapter ${_localChapter + 1} of 5',
                          style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
                Text(story.emoji, style: const TextStyle(fontSize: 24)),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (_localChapter + 1) / 5,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                minHeight: 4,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chapter title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _gold.withValues(alpha: 0.3)),
                    ),
                    child: Text(chapter.title, style: const TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  const SizedBox(height: 20),
                  // Character portrait row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Character circle
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: _gold.withValues(alpha: 0.4)),
                        ),
                        child: Center(child: Text(story.emoji, style: const TextStyle(fontSize: 22))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Text(chapter.body,
                              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.7)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Next button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextChapter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal, foregroundColor: _navy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_localChapter < 4 ? 'Continue →' : 'Final Chapter →',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decisionView(SpotlightStory story, int decisionIdx) {
    final dec = story.decisions[decisionIdx.clamp(0, 2)];
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => context.pop()),
                const Expanded(child: Center(child: Text('Decision Point', style: TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 14)))),
                const Text('⚡', style: TextStyle(fontSize: 22)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _gold.withValues(alpha: 0.4)),
                    ),
                    child: Text(dec.prompt,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, height: 1.4)),
                  ),
                  const SizedBox(height: 24),
                  _choiceBtn(0, 'A', dec.choiceA, dec.consequenceA, decisionIdx),
                  const SizedBox(height: 12),
                  _choiceBtn(1, 'B', dec.choiceB, dec.consequenceB, decisionIdx),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _choiceBtn(int idx, String label, String choice, String consequence, int decisionIdx) {
    final selected = _choices[decisionIdx] == idx;
    return GestureDetector(
      onTap: selected ? null : () => _makeChoice(decisionIdx, idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _teal.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _teal : Colors.white24, width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? _teal : Colors.white24,
                  ),
                  child: Center(child: Text(label, style: TextStyle(color: selected ? _navy : Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(choice, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
              ],
            ),
            if (selected) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 14)),
                    Expanded(child: Text(consequence, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextChapter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal, foregroundColor: _navy,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Continue with this choice →', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _endingView(SpotlightStory story) {
    final isA = _endingIsA;
    final ending = isA ? story.endingA : story.endingB;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => context.pop()),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Text(story.emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text('Story Complete!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('+${story.xpReward} XP earned', style: const TextStyle(color: _gold, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isA ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isA ? Colors.green.withValues(alpha: 0.5) : Colors.orange.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isA ? '🏆 Optimal Path' : '💭 Alternative Ending',
                            style: TextStyle(color: isA ? Colors.greenAccent : Colors.orangeAccent,
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 10),
                        Text(ending, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5)),
                      ],
                    ),
                  ),
                  if (!isA) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Optimal Path was:', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          Text(story.endingA, style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: _navy,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Back to Stories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
