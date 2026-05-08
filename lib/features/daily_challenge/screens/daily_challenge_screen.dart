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
import 'package:google_fonts/google_fonts.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/features/daily_challenge/models/challenge.dart';
import 'package:zamwealth_quest/features/daily_challenge/providers/daily_challenge_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette constants (matches dashboard / profile dark theme)
// ─────────────────────────────────────────────────────────────────────────────

const Color _kDeepNavy   = Color(0xFF0D1B2A);
const Color _kPrimaryBlue = Color(0xFF1A73E8);
const Color _kNeonMint    = Color(0xFF36ECDE);
const Color _kFreshGreen  = Color(0xFF2BC48A);
const Color _kSoftGray    = Color(0xFFE6E9EC);
const Color _kGold        = Color(0xFFFFB703);
const Color _kError       = Color(0xFFEF233C);

// ─────────────────────────────────────────────────────────────────────────────
// DailyChallengeScreen
// ─────────────────────────────────────────────────────────────────────────────

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
      backgroundColor: _kDeepNavy,
      appBar: AppBar(
        backgroundColor: _kPrimaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Daily Challenge',
          style: GoogleFonts.rajdhani(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: dcState.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: _kNeonMint),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Streak / Shields / Completed stat bar ─────────────
                    _buildStatBar(record),
                    const SizedBox(height: 20),

                    if (challenge == null) ...[
                      Center(
                        child: Text(
                          'No challenge available right now.',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: _kSoftGray,
                          ),
                        ),
                      ),
                    ] else ...[
                      // ── Topic chip ────────────────────────────────────
                      _buildTopicChip(challenge.topic),
                      const SizedBox(height: 12),

                      // ── Question card ─────────────────────────────────
                      _buildQuestionCard(challenge),
                      const SizedBox(height: 20),

                      // ── Input / result area ───────────────────────────
                      if (record != null &&
                          record.completedToday &&
                          !dcState.isAnswered) ...[
                        _buildAlreadyCompletedCard(challenge),
                        const SizedBox(height: 20),
                        _buildBackButton(context),
                      ] else if (dcState.isAnswered) ...[
                        _buildResultCard(dcState, challenge),
                        const SizedBox(height: 20),
                        _buildBackButton(context),
                      ] else ...[
                        if (challenge.type == ChallengeType.numeric)
                          _buildNumericInput()
                        else
                          _buildOptionsList(challenge),
                        const SizedBox(height: 20),
                        _buildConfirmButton(challenge),
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

  Widget _buildStatBar(record) {
    final streak = record?.currentStreak ?? 0;
    final shields = record?.streakShields ?? 0;
    final total = record?.totalCompleted ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _kNeonMint.withValues(alpha: 0.20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _kNeonMint.withValues(alpha: 0.10),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statPill('🔥', '$streak', 'streak'),
          _statDivider(),
          _statPill('🛡️', '$shields', 'shields'),
          _statDivider(),
          _statPill('✅', '$total', 'completed'),
        ],
      ),
    );
  }

  Widget _statPill(String emoji, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _kNeonMint,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: _kSoftGray,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _statDivider() => Container(
        width: 1,
        height: 44,
        color: Colors.white.withValues(alpha: 0.08),
      );

  // ── Topic chip ─────────────────────────────────────────────────────────────

  Widget _buildTopicChip(String topic) {
    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _kPrimaryBlue.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: _kPrimaryBlue.withValues(alpha: 0.50)),
          ),
          child: Text(
            '📚 $topic',
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kNeonMint,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Question card ──────────────────────────────────────────────────────────

  Widget _buildQuestionCard(DailyChallenge challenge) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: const BorderSide(color: _kNeonMint, width: 3),
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          right: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        challenge.question,
        style: GoogleFonts.inter(
          fontSize: 17,
          color: Colors.white,
          height: 1.6,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── Options list (multipleChoice / trueFalse) ──────────────────────────────

  Widget _buildOptionsList(DailyChallenge challenge) {
    return Column(
      children: List.generate(challenge.options.length, (i) {
        final selected = _selectedIndex == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = i),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? _kPrimaryBlue.withValues(alpha: 0.15)
                  : _kDeepNavy,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? _kNeonMint
                    : Colors.white.withValues(alpha: 0.10),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: selected ? _kNeonMint : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? _kNeonMint
                          : _kSoftGray.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check,
                          color: _kDeepNavy, size: 15)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    challenge.options[i],
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: selected ? Colors.white : _kSoftGray,
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

  Widget _buildNumericInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your answer (ZMW):',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _kSoftGray,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _numericController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Enter a number…',
            hintStyle: GoogleFonts.inter(
                color: _kSoftGray.withValues(alpha: 0.5)),
            prefixText: 'ZMW ',
            prefixStyle: GoogleFonts.inter(
              color: _kNeonMint,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: _kDeepNavy,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: _kNeonMint, width: 2),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  // ── Confirm button ─────────────────────────────────────────────────────────

  Widget _buildConfirmButton(DailyChallenge challenge) {
    final enabled = _canSubmit(challenge);
    return GestureDetector(
      onTap: enabled ? () => _submit(challenge) : null,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: enabled
              ? _kPrimaryBlue
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _kPrimaryBlue.withValues(alpha: 0.40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            'Confirm Answer',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: enabled
                  ? Colors.white
                  : _kSoftGray.withValues(alpha: 0.40),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // ── Result card ────────────────────────────────────────────────────────────

  Widget _buildResultCard(
    DailyChallengeState dcState,
    DailyChallenge challenge,
  ) {
    final correct = dcState.isCorrect;

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
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: correct
              ? _kFreshGreen.withValues(alpha: 0.50)
              : _kError.withValues(alpha: 0.50),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (correct ? _kFreshGreen : _kError)
                .withValues(alpha: 0.12),
            blurRadius: 16,
          ),
        ],
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
                  style: GoogleFonts.rajdhani(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: correct ? _kFreshGreen : _kError,
                  ),
                ),
              ),
              if (correct)
                Text(
                  '+$kDailyChallengeXp XP',
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _kGold,
                  ),
                ),
            ],
          ),
          if (!correct) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _kFreshGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _kFreshGreen.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: _kFreshGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Correct answer: $correctLabel',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _kFreshGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Divider(color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 10),
          Text(
            challenge.explanation,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _kSoftGray,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Already-completed card (returned from a previous session today) ────────

  Widget _buildAlreadyCompletedCard(DailyChallenge challenge) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _kFreshGreen.withValues(alpha: 0.50),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _kFreshGreen.withValues(alpha: 0.10),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✅', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Text(
                'Challenge Complete!',
                style: GoogleFonts.rajdhani(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _kFreshGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Come back tomorrow for a new challenge!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _kSoftGray,
            ),
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 10),
          Text(
            challenge.explanation,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _kSoftGray,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Back to Dashboard button ───────────────────────────────────────────────

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.home),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: _kPrimaryBlue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _kPrimaryBlue.withValues(alpha: 0.40),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Back to Dashboard',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
