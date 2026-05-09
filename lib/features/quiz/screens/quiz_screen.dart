library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zamwealth_quest/features/quiz/providers/quiz_provider.dart';
import 'package:zamwealth_quest/shared/widgets/animated_gradient_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────

const Color _kDeepNavy    = Color(0xFF0D1B2A);
const Color _kCoreNavy    = Color(0xFF00203F);
const Color _kPrimaryBlue = Color(0xFF1A73E8);
const Color _kNeonMint    = Color(0xFF36ECDE);
const Color _kFreshGreen  = Color(0xFF2BC48A);
const Color _kSoftGray    = Color(0xFFE6E9EC);
const Color _kGold        = Color(0xFFFFB703);

// ─────────────────────────────────────────────────────────────────────────────
// QuizScreen
// ─────────────────────────────────────────────────────────────────────────────

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(quizProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: session.isDone
              ? _buildResults(context, ref, session)
              : _buildQuestion(context, ref, session),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, QuizSession session) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: _kDeepNavy.withValues(alpha: 0.90),
        border: Border(
          bottom: BorderSide(color: _kNeonMint.withValues(alpha: 0.20), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios, color: _kNeonMint, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'FINANCIAL QUIZ',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kSoftGray,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Text(
            '${session.currentIndex + 1} / ${session.totalQuestions}',
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _kNeonMint,
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress dots ──────────────────────────────────────────────────────────

  Widget _buildProgressDots(QuizSession session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(session.totalQuestions, (i) {
          final done = i < session.currentIndex;
          final current = i == session.currentIndex;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              decoration: BoxDecoration(
                color: done
                    ? _kFreshGreen
                    : current
                        ? _kNeonMint
                        : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Question view ──────────────────────────────────────────────────────────

  Widget _buildQuestion(BuildContext context, WidgetRef ref, QuizSession session) {
    final q = session.current!;
    final optionLabels = ['A', 'B', 'C', 'D'];

    return Column(
      children: [
        _buildHeader(context, session),
        _buildProgressDots(session),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kPrimaryBlue.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _kPrimaryBlue.withValues(alpha: 0.50)),
                  ),
                  child: Text(
                    q.category,
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _kNeonMint,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Question card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _kDeepNavy,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _kNeonMint.withValues(alpha: 0.20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kNeonMint.withValues(alpha: 0.08),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Text(
                    q.question,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Options
                ...List.generate(q.options.length, (i) {
                  return _buildOptionButton(
                    context: context,
                    ref: ref,
                    session: session,
                    label: optionLabels[i],
                    text: q.options[i],
                    index: i,
                    correctIndex: q.correctIndex,
                  );
                }),

                // Explanation (shown after answer)
                if (session.revealed) ...[
                  const SizedBox(height: 16),
                  _buildExplanation(session, q.explanation),
                  const SizedBox(height: 20),
                  _buildNextButton(context, ref, session),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required WidgetRef ref,
    required QuizSession session,
    required String label,
    required String text,
    required int index,
    required int correctIndex,
  }) {
    Color borderColor = Colors.white.withValues(alpha: 0.10);
    Color bgColor = _kDeepNavy;
    Color textColor = _kSoftGray;

    if (session.revealed) {
      if (index == correctIndex) {
        borderColor = _kFreshGreen;
        bgColor = _kFreshGreen.withValues(alpha: 0.12);
        textColor = _kFreshGreen;
      } else if (index == session.selectedAnswer) {
        borderColor = const Color(0xFFE53935);
        bgColor = const Color(0xFFE53935).withValues(alpha: 0.10);
        textColor = const Color(0xFFE53935);
      }
    } else if (index == session.selectedAnswer) {
      borderColor = _kNeonMint;
      bgColor = _kNeonMint.withValues(alpha: 0.08);
    }

    return GestureDetector(
      onTap: session.revealed
          ? null
          : () => ref.read(quizProvider.notifier).selectAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.20),
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: session.revealed ? textColor : _kNeonMint,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ),
            if (session.revealed && index == correctIndex)
              const Icon(Icons.check_circle, color: _kFreshGreen, size: 20),
            if (session.revealed &&
                index == session.selectedAnswer &&
                index != correctIndex)
              const Icon(Icons.cancel, color: Color(0xFFE53935), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation(QuizSession session, String explanation) {
    final isCorrect = session.selectedAnswer ==
        (session.current?.correctIndex ?? -1);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCorrect
            ? _kFreshGreen.withValues(alpha: 0.08)
            : _kCoreNavy.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect
              ? _kFreshGreen.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.emoji_events : Icons.lightbulb_outline,
                color: isCorrect ? _kGold : _kNeonMint,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? '+${session.questions[session.currentIndex - (session.revealed ? 0 : 1)].xpReward} XP' : 'Explanation',
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCorrect ? _kGold : _kNeonMint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _kSoftGray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(
      BuildContext context, WidgetRef ref, QuizSession session) {
    final isLast = session.currentIndex == session.totalQuestions - 1;
    return GestureDetector(
      onTap: () => ref.read(quizProvider.notifier).nextQuestion(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kPrimaryBlue, _kNeonMint],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _kNeonMint.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            isLast ? 'See Results  →' : 'Next Question  →',
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

  // ── Results view ───────────────────────────────────────────────────────────

  Widget _buildResults(BuildContext context, WidgetRef ref, QuizSession session) {
    final pct = session.correctCount / session.totalQuestions;
    final emoji = pct == 1.0
        ? '🏆'
        : pct >= 0.6
            ? '🎯'
            : '📚';
    final message = pct == 1.0
        ? 'Perfect Score!'
        : pct >= 0.6
            ? 'Well Done!'
            : 'Keep Learning!';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: _kDeepNavy.withValues(alpha: 0.90),
            border: Border(
              bottom:
                  BorderSide(color: _kNeonMint.withValues(alpha: 0.20), width: 1),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_ios,
                    color: _kNeonMint, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'RESULTS',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kSoftGray,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: GoogleFonts.rajdhani(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${session.correctCount} out of ${session.totalQuestions} correct',
                    style: GoogleFonts.inter(fontSize: 16, color: _kSoftGray),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: _kDeepNavy,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _kNeonMint.withValues(alpha: 0.35)),
                          boxShadow: [
                            BoxShadow(
                              color: _kNeonMint.withValues(alpha: 0.15),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.bolt,
                                color: _kNeonMint, size: 26),
                            const SizedBox(height: 4),
                            Text(
                              '+${session.sessionXP}',
                              style: GoogleFonts.orbitron(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _kNeonMint,
                              ),
                            ),
                            Text(
                              'XP',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: _kNeonMint,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: _kDeepNavy,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _kGold.withValues(alpha: 0.35)),
                          boxShadow: [
                            BoxShadow(
                              color: _kGold.withValues(alpha: 0.15),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.monetization_on,
                                color: _kGold, size: 26),
                            const SizedBox(height: 4),
                            Text(
                              '+${session.sessionCoins}',
                              style: GoogleFonts.orbitron(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _kGold,
                              ),
                            ),
                            Text(
                              'COINS',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: _kGold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              ref.read(quizProvider.notifier).restart(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _kNeonMint,
                            side: const BorderSide(color: _kNeonMint),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Play Again',
                            style: GoogleFonts.rajdhani(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kNeonMint,
                            foregroundColor: _kCoreNavy,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Back to Home',
                            style: GoogleFonts.rajdhani(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
