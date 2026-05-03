/// daily_challenge_screen.dart
/// Purpose: Full-screen Daily Challenge UI. Shows today's question, accepts
///          the player's answer, displays a result card with explanation, and
///          surfaces streak / shield stats.
/// Reads from: dailyChallengeProvider
/// Writes to: dailyChallengeProvider (via submitAnswer)
/// Navigation: back to calling screen (context.pop), → /home (result CTA)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/daily_challenge/models/challenge.dart';
import 'package:zamwealth_quest/features/daily_challenge/providers/daily_challenge_provider.dart';

/// The Daily Challenge screen — one question per day, same for all users.
class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  int? _selectedIndex;
  final TextEditingController _numericController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailyChallengeProvider.notifier).getTodaysChallenge();
    });
  }

  @override
  void dispose() {
    _numericController.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit(DailyChallenge challenge) async {
    if (challenge.type == ChallengeType.numeric) {
      final val = double.tryParse(_numericController.text);
      if (val == null) return;
      await ref.read(dailyChallengeProvider.notifier).submitAnswer(val);
    } else {
      if (_selectedIndex == null) return;
      await ref
          .read(dailyChallengeProvider.notifier)
          .submitAnswer(_selectedIndex!);
    }
  }

  bool _canSubmit(DailyChallenge challenge) {
    if (challenge.type == ChallengeType.numeric) {
      return _numericController.text.trim().isNotEmpty &&
          double.tryParse(_numericController.text) != null;
    }
    return _selectedIndex != null;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dcState = ref.watch(dailyChallengeProvider);
    final record = dcState.record;
    final challenge = dcState.todaysChallenge;

    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        title: const Text('Daily Challenge'),
        backgroundColor: kCopper,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: dcState.isLoading
            ? const Center(child: CircularProgressIndicator(color: kCopper))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Stat bar ─────────────────────────────────────────
                    _buildStatBar(context, record),

                    if (challenge == null) ...[
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          'No challenge available right now.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: kCharcoalLight),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 20),

                      // ── Topic chip ────────────────────────────────────
                      _buildTopicChip(context, challenge.topic),
                      const SizedBox(height: 12),

                      // ── Question card ─────────────────────────────────
                      _buildQuestionCard(context, challenge),
                      const SizedBox(height: 20),

                      // ── Input / result area ───────────────────────────
                      if (record != null &&
                          record.completedToday &&
                          !dcState.isAnswered) ...[
                        _buildAlreadyCompletedCard(context, challenge),
                        const SizedBox(height: 20),
                        _buildBackButton(context),
                      ] else if (dcState.isAnswered) ...[
                        _buildResultCard(context, dcState, challenge),
                        const SizedBox(height: 20),
                        _buildBackButton(context),
                      ] else ...[
                        if (challenge.type == ChallengeType.numeric)
                          _buildNumericInput(context)
                        else
                          _buildOptionsList(context, challenge),
                        const SizedBox(height: 20),
                        _buildConfirmButton(context, challenge),
                      ],
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Stat bar ───────────────────────────────────────────────────────────────

  Widget _buildStatBar(BuildContext context, record) {
    final streak = record?.currentStreak ?? 0;
    final shields = record?.streakShields ?? 0;
    final total = record?.totalCompleted ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: zamCard(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statPill(context, '🔥', '$streak', 'day streak'),
          _verticalDivider(),
          _statPill(context, '🛡️', '$shields', 'shields'),
          _verticalDivider(),
          _statPill(context, '✅', '$total', 'completed'),
        ],
      ),
    );
  }

  Widget _statPill(
      BuildContext context, String emoji, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: kCharcoal,
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: kCharcoalLight),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
        width: 1,
        height: 40,
        color: kCopperLight.withValues(alpha: 0.3));
  }

  // ── Topic chip ─────────────────────────────────────────────────────────────

  Widget _buildTopicChip(BuildContext context, String topic) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: kCopper.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kCopper.withValues(alpha: 0.4)),
          ),
          child: Text(
            '📚 $topic',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: kCopper,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }

  // ── Question card ──────────────────────────────────────────────────────────

  Widget _buildQuestionCard(BuildContext context, DailyChallenge challenge) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: zamCard(highlighted: true),
      child: Text(
        challenge.question,
        style: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 18,
          color: kCharcoal,
          height: 1.55,
        ),
      ),
    );
  }

  // ── Options list (multipleChoice / trueFalse) ──────────────────────────────

  Widget _buildOptionsList(BuildContext context, DailyChallenge challenge) {
    return Column(
      children: List.generate(challenge.options.length, (i) {
        final selected = _selectedIndex == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = i),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? kCopper
                    : kCopperLight.withValues(alpha: 0.35),
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: kCopper.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: kCopper.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: selected ? kCopper : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? kCopper : kCharcoalLight,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 15)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    challenge.options[i],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kCharcoal,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Numeric input ──────────────────────────────────────────────────────────

  Widget _buildNumericInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your answer (ZMW):',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: kCharcoal),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _numericController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            hintText: 'Enter a number…',
            prefixText: 'ZMW ',
            prefixStyle: const TextStyle(
                color: kCharcoal, fontWeight: FontWeight.w600),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: kCopperLight.withValues(alpha: 0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kCopper, width: 2),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  // ── Confirm button ─────────────────────────────────────────────────────────

  Widget _buildConfirmButton(BuildContext context, DailyChallenge challenge) {
    final enabled = _canSubmit(challenge);
    return ElevatedButton(
      onPressed: enabled ? () => _submit(challenge) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: kCopper,
        foregroundColor: Colors.white,
        disabledBackgroundColor: kCopperLight.withValues(alpha: 0.35),
        minimumSize: const Size.fromHeight(52),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'Confirm Answer',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ── Result card ────────────────────────────────────────────────────────────

  Widget _buildResultCard(
    BuildContext context,
    DailyChallengeState dcState,
    DailyChallenge challenge,
  ) {
    final correct = dcState.isCorrect;

    // Build the correct-answer label for the wrong-answer case.
    final String correctLabel;
    if (challenge.type == ChallengeType.numeric) {
      final n = challenge.correctNumeric;
      correctLabel =
          'ZMW ${n == n.roundToDouble() ? n.toInt() : n.toStringAsFixed(2)}';
    } else {
      correctLabel = challenge.options[challenge.correctIndex];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: correct
            ? kGreen.withValues(alpha: 0.08)
            : kError.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: correct
              ? kGreen.withValues(alpha: 0.4)
              : kError.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                correct ? '✅' : '❌',
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  correct ? 'Correct!' : 'Not quite!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: correct ? kGreen : kError,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (correct)
                Text(
                  '+$kDailyChallengeXp XP',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: kGold,
                        fontWeight: FontWeight.w800,
                      ),
                ),
            ],
          ),
          if (!correct) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: kGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Correct answer: $correctLabel',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                              color: kGreen,
                              fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          Text(
            challenge.explanation,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: kCharcoal, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── Already-completed card (previous session today) ────────────────────────

  Widget _buildAlreadyCompletedCard(
      BuildContext context, DailyChallenge challenge) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: kGreen.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✅', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Challenge Complete!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: kGreen,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Come back tomorrow for a new challenge!',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: kCharcoalLight),
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          Text(
            challenge.explanation,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: kCharcoal, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── Back to Dashboard button ───────────────────────────────────────────────

  Widget _buildBackButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.go(AppRoutes.home),
      style: ElevatedButton.styleFrom(
        backgroundColor: kCopper,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'Back to Dashboard',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }
}
