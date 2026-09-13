// lib/features/flash_challenge/screens/flash_challenge_screen.dart
/// Purpose: Timed Flash Challenge — 5 multiple-choice questions, 30 s each.
///          Awards 2× XP per correct answer + 50 ZamCoins on completion.
/// Reads from: flashChallengeProvider, heartsProvider, inventoryProvider, authProvider
/// Writes to: authProvider (XP + coins), heartsProvider (lose hearts)
/// Navigation: replaces to /challenge-expired if window is closed
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../providers/flash_challenge_provider.dart';
import '../widgets/countdown_timer_bar.dart';
import '../../hearts/providers/hearts_provider.dart';
import '../../hearts/widgets/hearts_hud.dart';
import '../../shop/providers/inventory_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../daily_challenge/models/challenge.dart';
import '../../streak/providers/streak_provider.dart';
import '../../../core/constants.dart';
import '../../../services/streak_service.dart';
import '../../../core/theme.dart';
import '../../../core/router.dart';

const int kFlashQuestionSeconds = 30;

// Only multipleChoice and trueFalse have options — filter numeric out
List<DailyChallenge> _selectableQuestions() {
  return kDailyChallenges
      .where((q) =>
          q.type == ChallengeType.multipleChoice ||
          q.type == ChallengeType.trueFalse)
      .toList();
}

class FlashChallengeScreen extends ConsumerStatefulWidget {
  const FlashChallengeScreen({super.key});

  @override
  ConsumerState<FlashChallengeScreen> createState() =>
      _FlashChallengeScreenState();
}

class _FlashChallengeScreenState extends ConsumerState<FlashChallengeScreen>
    with SingleTickerProviderStateMixin {
  late List<DailyChallenge> _questions;
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _timerPaused = false;
  int _correctCount = 0;
  bool _completed = false;
  final GlobalKey<CountdownTimerBarState> _timerKey = GlobalKey();
  late ConfettiController _confettiCtrl;

  // Screen entry: fade + slide-up 20 px, 300 ms easeOut.
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    // Load 5 non-numeric questions, rotating by day so variety changes daily
    final list = _selectableQuestions();
    final maxStart = (list.length - 5).clamp(0, list.length);
    final startIdx = (DateTime.now().day * 3) % (maxStart == 0 ? 1 : maxStart);
    final endIdx = (startIdx + 5).clamp(0, list.length);
    _questions = list.sublist(startIdx, endIdx);

    // Redirect to expired screen if the flash window is not active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(flashChallengeProvider);
      if (!state.isActive) {
        context.replace(AppRoutes.challengeExpired);
        return;
      }
      _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTimerExpired() async {
    if (!_answered) {
      await ref.read(heartsProvider.notifier).loseHeart(
            inventory: ref.read(inventoryProvider.notifier),
          );
      _nextQuestion();
    }
  }

  Future<void> _onAnswerSelected(int index) async {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });
    final correct = _questions[_currentIndex].correctIndex;
    if (index == correct) {
      _correctCount++;
    } else {
      await ref.read(heartsProvider.notifier).loseHeart(
            inventory: ref.read(inventoryProvider.notifier),
          );
    }
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_currentIndex >= _questions.length - 1) {
      _finishChallenge();
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  Future<void> _finishChallenge() async {
    setState(() => _completed = true);
    await ref
        .read(authProvider.notifier)
        .addXp(kDailyChallengeXp * 2 * _correctCount);
    await ref.read(authProvider.notifier).addWalletCoins(50);
    if (DateTime.now().millisecond % 10 == 0) {
      await ref.read(inventoryProvider.notifier).addItem(kPowerUpMysteryBox);
    }
    _confettiCtrl.play();
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid != null) {
      await StreakService.recordActivity(uid);
      if (mounted) ref.read(globalStreakProvider.notifier).refresh();
    }
  }

  Future<void> _useFreeze() async {
    final consumed =
        await ref.read(inventoryProvider.notifier).consume(kPowerUpFreeze);
    if (!mounted) return;
    if (consumed) {
      setState(() => _timerPaused = true);
      _timerKey.currentState?.freeze(10);
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) setState(() => _timerPaused = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return Scaffold(
        backgroundColor: kCoreNavy,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🎉 Challenge Complete!',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: kGold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$_correctCount/${_questions.length} correct',
                      style:
                          const TextStyle(fontSize: 20, color: kCharcoalLight),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '+ZMW 50 coins earned',
                      style: TextStyle(color: kNeonMint, fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kNeonMint,
                          foregroundColor: kCoreNavy),
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
            ),
            ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [kNeonMint, kGold, kGreen],
            ),
          ],
        ),
      );
    }

    final q = _questions[_currentIndex];
    return Scaffold(
      backgroundColor: kCoreNavy,
      appBar: AppBar(
        backgroundColor: kCoreNavy,
        title: Text(
          'Flash Challenge ${_currentIndex + 1}/${_questions.length}',
          style: const TextStyle(color: kCharcoalLight),
        ),
        actions: const [HeartsHUD(), SizedBox(width: 12)],
      ),
      body: FadeTransition(
        opacity: _entryFade,
        child: SlideTransition(
        position: _entrySlide,
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CountdownTimerBar(
              key: _timerKey,
              durationSeconds: kFlashQuestionSeconds,
              onExpired: _onTimerExpired,
              paused: _timerPaused,
            ),
            const SizedBox(height: 24),
            Text(
              q.question,
              style: const TextStyle(
                  fontSize: 18,
                  color: kCharcoalLight,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              q.options.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AnswerTile(
                  text: q.options[i],
                  onTap: () => _onAnswerSelected(i),
                  state: _answered
                      ? (i == q.correctIndex
                          ? _AnswerState.correct
                          : i == _selectedAnswer
                              ? _AnswerState.wrong
                              : _AnswerState.neutral)
                      : _AnswerState.neutral,
                ),
              ),
            ),
            const Spacer(),
            Consumer(
              builder: (_, ref, __) {
                final inv = ref.watch(inventoryProvider);
                final freezeCount = inv.countOf(kPowerUpFreeze);
                return OutlinedButton.icon(
                  onPressed:
                      freezeCount > 0 && !_timerPaused ? _useFreeze : null,
                  icon: const Text('❄️'),
                  label: Text('Freeze ($freezeCount)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryBlue,
                    side: BorderSide(
                        color: freezeCount > 0 ? kPrimaryBlue : kCharcoalLight),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Answer tile helpers
// ─────────────────────────────────────────────────────────────────────────────

enum _AnswerState { neutral, correct, wrong }

class _AnswerTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final _AnswerState state;

  const _AnswerTile(
      {required this.text, required this.onTap, required this.state});

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color bg;
    switch (state) {
      case _AnswerState.correct:
        border = kGreen;
        bg = kGreen.withValues(alpha: 0.1);
      case _AnswerState.wrong:
        border = kError;
        bg = kError.withValues(alpha: 0.1);
      case _AnswerState.neutral:
        border = kNeonMint.withValues(alpha: 0.3);
        bg = kDeepNavy;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        child: Text(text,
            style: const TextStyle(color: kCharcoalLight, fontSize: 15)),
      ),
    );
  }
}
