library;

import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zamwealth_quest/core/constants.dart';
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
const Color _kErrorRed    = Color(0xFFE53935);

// ─────────────────────────────────────────────────────────────────────────────
// QuizScreen — ConsumerStatefulWidget with Duolingo-grade feedback animations
// ─────────────────────────────────────────────────────────────────────────────

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with TickerProviderStateMixin {
  // ── Entry: fade + slide up ────────────────────────────────────────────────
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  // ── Wrong-answer screen shake ─────────────────────────────────────────────
  late final AnimationController _shakeCtrl;

  // ── Red / green full-screen flash ─────────────────────────────────────────
  late final AnimationController _redFlashCtrl;
  late final AnimationController _greenFlashCtrl;

  // ── Correct-answer checkmark bounce ───────────────────────────────────────
  late final AnimationController _checkCtrl;

  // ── Confetti for perfect score ────────────────────────────────────────────
  late final ConfettiController _confettiCtrl;

  bool _confettiFired = false;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      // 20px up == ~0.05 of a typical screen height; use pixel-precise translation via a Transform in build
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _redFlashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _greenFlashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _confettiCtrl =
        ConfettiController(duration: const Duration(milliseconds: 1200));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _shakeCtrl.dispose();
    _redFlashCtrl.dispose();
    _greenFlashCtrl.dispose();
    _checkCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  // ── Animation triggers ─────────────────────────────────────────────────────

  void _playCorrectFeedback() {
    _greenFlashCtrl.forward(from: 0);
    _checkCtrl.forward(from: 0);
  }

  void _playWrongFeedback() {
    _redFlashCtrl.forward(from: 0);
    _shakeCtrl.forward(from: 0);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Listen to provider transitions for the reveal moment.
    ref.listen<QuizSession>(quizProvider, (prev, next) {
      // Reveal just turned on -> trigger correct/wrong feedback once.
      final justRevealed = (prev?.revealed != true) && next.revealed;
      if (justRevealed && next.current != null) {
        final isCorrect = next.selectedAnswer == next.current!.correctIndex;
        if (isCorrect) {
          _playCorrectFeedback();
        } else {
          _playWrongFeedback();
        }
      }

      // Fire confetti once when results screen first appears with a perfect score.
      if (!_confettiFired &&
          next.isDone &&
          next.totalQuestions > 0 &&
          next.correctCount == next.totalQuestions) {
        _confettiFired = true;
        _confettiCtrl.play();
      }

      // Reset confetti latch on restart.
      if (prev != null && prev.isDone && !next.isDone) {
        _confettiFired = false;
      }
    });

    final session = ref.watch(quizProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FadeTransition(
            opacity: _entryFade,
            child: SlideTransition(
              position: _entrySlide,
              child: AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (context, child) {
                  // ±8px sine oscillation, ~5 cycles in 300ms.
                  final t = _shakeCtrl.value;
                  final dx = t == 0
                      ? 0.0
                      : math.sin(t * math.pi * 2 * 5) * 8 * (1 - t);
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: child,
                  );
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: session.isDone
                          ? _buildResults(context, session)
                          : _buildQuestion(context, session),
                    ),
                    // Red flash overlay
                    _buildFlashOverlay(_redFlashCtrl, _kErrorRed, 0.25),
                    // Green flash overlay
                    _buildFlashOverlay(_greenFlashCtrl, _kFreshGreen, 0.30),
                    // Checkmark burst
                    _buildCheckBurst(),
                    // Confetti (perfect score only)
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiCtrl,
                        blastDirection: math.pi / 2, // downward
                        emissionFrequency: 0.05,
                        numberOfParticles: 22,
                        maxBlastForce: 18,
                        minBlastForce: 6,
                        gravity: 0.3,
                        shouldLoop: false,
                        colors: const [
                          _kNeonMint,
                          _kGold,
                          _kFreshGreen,
                          _kPrimaryBlue,
                          Colors.white,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Flash overlay helper ──────────────────────────────────────────────────

  Widget _buildFlashOverlay(
      AnimationController ctrl, Color color, double peakAlpha) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (context, _) {
          if (ctrl.value == 0) return const SizedBox.shrink();
          // 0 -> peak -> 0 triangular curve.
          final t = ctrl.value;
          final alpha = (t <= 0.5 ? t * 2 : (1 - t) * 2) * peakAlpha;
          return Positioned.fill(
            child: Container(color: color.withValues(alpha: alpha)),
          );
        },
      ),
    );
  }

  // ── Centered checkmark bounce + fade ──────────────────────────────────────

  Widget _buildCheckBurst() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _checkCtrl,
        builder: (context, _) {
          final t = _checkCtrl.value;
          if (t == 0) return const SizedBox.shrink();
          // Scale 0 -> 1 with bounceOut.
          final scale = Curves.bounceOut.transform(t.clamp(0.0, 1.0));
          // Fade out in the last 300ms (i.e. last half of the 600ms).
          double opacity = 1.0;
          if (t > 0.5) {
            opacity = (1 - ((t - 0.5) / 0.5)).clamp(0.0, 1.0);
          }
          return Center(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _kFreshGreen.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                    border: Border.all(color: _kFreshGreen, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _kFreshGreen.withValues(alpha: 0.45),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: _kFreshGreen,
                    size: 72,
                  ),
                ),
              ),
            ),
          );
        },
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
          bottom:
              BorderSide(color: _kNeonMint.withValues(alpha: 0.20), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child:
                const Icon(Icons.arrow_back_ios, color: _kNeonMint, size: 20),
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

  // ── Progress dots (animated width on active dot) ──────────────────────────

  Widget _buildProgressDots(QuizSession session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(session.totalQuestions, (i) {
          final done = i < session.currentIndex;
          final current = i == session.currentIndex;
          final color = done
              ? _kFreshGreen
              : current
                  ? _kNeonMint
                  : Colors.white.withValues(alpha: 0.15);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: current ? 20 : 8,
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Question view ──────────────────────────────────────────────────────────

  Widget _buildQuestion(BuildContext context, QuizSession session) {
    final q = session.current!;
    const optionLabels = ['A', 'B', 'C', 'D'];

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kPrimaryBlue.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: _kPrimaryBlue.withValues(alpha: 0.50)),
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
                  return _OptionButton(
                    label: optionLabels[i],
                    text: q.options[i],
                    index: i,
                    correctIndex: q.correctIndex,
                    selectedAnswer: session.selectedAnswer,
                    revealed: session.revealed,
                    onTap: session.revealed
                        ? null
                        : () =>
                            ref.read(quizProvider.notifier).selectAnswer(i),
                  );
                }),

                // Explanation (shown after answer)
                if (session.revealed) ...[
                  const SizedBox(height: 16),
                  _buildExplanation(session, q),
                  const SizedBox(height: 20),
                  _NextButton(
                    isLast:
                        session.currentIndex == session.totalQuestions - 1,
                    onTap: () =>
                        ref.read(quizProvider.notifier).nextQuestion(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExplanation(QuizSession session, QuizQuestion q) {
    final isCorrect = session.selectedAnswer == q.correctIndex;
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
                isCorrect ? '+${q.xpReward} XP' : 'Explanation',
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
            q.explanation,
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

  // ── Results view ───────────────────────────────────────────────────────────

  Widget _buildResults(BuildContext context, QuizSession session) {
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
              bottom: BorderSide(
                  color: _kNeonMint.withValues(alpha: 0.20), width: 1),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: GoogleFonts.rajdhani(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${session.correctCount} out of ${session.totalQuestions} correct',
                  style: GoogleFonts.inter(fontSize: 15, color: _kSoftGray),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RewardBox(
                      icon: Icons.bolt,
                      color: _kNeonMint,
                      label: 'XP',
                      value: session.sessionXP,
                    ),
                    const SizedBox(width: 14),
                    _RewardBox(
                      icon: Icons.monetization_on,
                      color: _kGold,
                      label: 'COINS',
                      value: session.sessionCoins,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OptionButton — tap-scales 0.96, animated border colour fade
// ─────────────────────────────────────────────────────────────────────────────

class _OptionButton extends StatefulWidget {
  const _OptionButton({
    required this.label,
    required this.text,
    required this.index,
    required this.correctIndex,
    required this.selectedAnswer,
    required this.revealed,
    required this.onTap,
  });

  final String label;
  final String text;
  final int index;
  final int correctIndex;
  final int selectedAnswer;
  final bool revealed;
  final VoidCallback? onTap;

  @override
  State<_OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<_OptionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.white.withValues(alpha: 0.10);
    Color bgColor = _kDeepNavy;
    Color textColor = _kSoftGray;

    if (widget.revealed) {
      if (widget.index == widget.correctIndex) {
        borderColor = _kFreshGreen;
        bgColor = _kFreshGreen.withValues(alpha: 0.12);
        textColor = _kFreshGreen;
      } else if (widget.index == widget.selectedAnswer) {
        borderColor = _kErrorRed;
        bgColor = _kErrorRed.withValues(alpha: 0.10);
        textColor = _kErrorRed;
      }
    } else if (widget.index == widget.selectedAnswer) {
      borderColor = _kNeonMint;
      bgColor = _kNeonMint.withValues(alpha: 0.08);
    }

    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onTap == null
          ? null
          : () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: borderColor),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          builder: (context, animatedBorder, _) {
            final border = animatedBorder ?? borderColor;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: border.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                      border: Border.all(color: border),
                    ),
                    child: Center(
                      child: Text(
                        widget.label,
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.revealed ? textColor : _kNeonMint,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.text,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (widget.revealed && widget.index == widget.correctIndex)
                    const Icon(Icons.check_circle,
                        color: _kFreshGreen, size: 20),
                  if (widget.revealed &&
                      widget.index == widget.selectedAnswer &&
                      widget.index != widget.correctIndex)
                    const Icon(Icons.cancel, color: _kErrorRed, size: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NextButton — gradient + tap scale 0.96
// ─────────────────────────────────────────────────────────────────────────────

class _NextButton extends StatefulWidget {
  const _NextButton({required this.isLast, required this.onTap});
  final bool isLast;
  final VoidCallback onTap;

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
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
              widget.isLast ? 'See Results  →' : 'Next Question  →',
              style: GoogleFonts.rajdhani(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RewardBox — XP / Coins box with count-up TweenAnimationBuilder
// (pattern adapted from lib/features/wallet/widgets/wallet_badge.dart)
// ─────────────────────────────────────────────────────────────────────────────

class _RewardBox extends StatelessWidget {
  const _RewardBox({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Text(
              '+${v.round()}',
              style: GoogleFonts.orbitron(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
