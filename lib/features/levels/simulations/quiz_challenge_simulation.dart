/// quiz_challenge_simulation.dart
/// Purpose: Full-screen quiz simulation covering Zambia-specific financial
///          literacy topics. Tracks streak and shields; shows per-question
///          feedback, then a results summary that calls onComplete.
/// Reads from: nothing (self-contained)
/// Writes to: nothing (delegates completion via onComplete callback)
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────

const Color _kNavy = Color(0xFF0D1B2A);
const Color _kCard = Color(0xFF152535);
const Color _kTeal = Color(0xFF36ECDE);
const Color _kCorrect = Color(0xFF2BC48A);
const Color _kWrong = Color(0xFFEF5350);
const Color _kText = Color(0xFFE6E9EC);
const Color _kSubtext = Color(0xFF8CA0B3);

// ─────────────────────────────────────────────────────────────────────────────
// Data Model
// ─────────────────────────────────────────────────────────────────────────────

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    required this.categoryEmoji,
  });

  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;
  final String categoryEmoji;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sample Questions — Zambia financial literacy
// ─────────────────────────────────────────────────────────────────────────────

const List<QuizQuestion> _kQuestions = [
  QuizQuestion(
    question:
        'What percentage of your gross salary must you contribute to NAPSA each month as an employee?',
    options: ['3%', '5%', '8%', '10%'],
    correctAnswerIndex: 1,
    category: 'NAPSA',
    categoryEmoji: '📚',
  ),
  QuizQuestion(
    question:
        "What is Zambia's standard VAT rate on most goods and services?",
    options: ['10%', '12.5%', '16%', '20%'],
    correctAnswerIndex: 2,
    category: 'Tax',
    categoryEmoji: '🏛️',
  ),
  QuizQuestion(
    question:
        "If Zambia's annual inflation rate is 12%, a product costing ZMW 100 today will cost approximately how much in one year?",
    options: ['ZMW 108', 'ZMW 110', 'ZMW 112', 'ZMW 125'],
    correctAnswerIndex: 2,
    category: 'Inflation',
    categoryEmoji: '📉',
  ),
  QuizQuestion(
    question:
        'Financial experts recommend your emergency fund should cover how many months of living expenses?',
    options: ['1–2 months', '3–6 months', '8–10 months', '12+ months'],
    correctAnswerIndex: 1,
    category: 'Savings',
    categoryEmoji: '🛡️',
  ),
  QuizQuestion(
    question:
        'When sending ZMW 500 via mobile money, which approach generally minimises total transaction fees?',
    options: [
      'Many small transfers',
      'One single large transfer',
      'Always use the same network',
      'Fees are always equal',
    ],
    correctAnswerIndex: 1,
    category: 'Mobile Money',
    categoryEmoji: '📱',
  ),
  QuizQuestion(
    question:
        "Who is responsible for deducting PAYE (Pay As You Earn) tax from an employee's salary in Zambia?",
    options: ['The employee', 'ZRA directly', 'The employer', 'NAPSA'],
    correctAnswerIndex: 2,
    category: 'Tax',
    categoryEmoji: '🏛️',
  ),
  QuizQuestion(
    question: "The Bank of Zambia's primary mandate is to:",
    options: [
      'Collect income taxes for government',
      'Register all new businesses',
      'Maintain price stability and control monetary policy',
      'Manage the national pension fund',
    ],
    correctAnswerIndex: 2,
    category: 'Banking',
    categoryEmoji: '🏦',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// QuizChallengeSimulation Widget
// ─────────────────────────────────────────────────────────────────────────────

class QuizChallengeSimulation extends StatefulWidget {
  const QuizChallengeSimulation({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<QuizChallengeSimulation> createState() =>
      _QuizChallengeSimulationState();
}

class _QuizChallengeSimulationState extends State<QuizChallengeSimulation> {
  int _questionIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _isCorrect = false;
  int _streak = 0;
  int _shields = 3;
  int _correctCount = 0;
  bool _showResults = false;
  Timer? _advanceTimer;

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  QuizQuestion get _currentQuestion => _kQuestions[_questionIndex];
  int get _totalQuestions => _kQuestions.length;

  void _confirmAnswer() {
    if (_selectedOption == null || _answered) return;
    final correct = _selectedOption == _currentQuestion.correctAnswerIndex;
    setState(() {
      _answered = true;
      _isCorrect = correct;
      if (correct) {
        _streak++;
        _correctCount++;
      } else {
        _streak = 0;
        if (_shields > 0) _shields--;
      }
    });
    _advanceTimer = Timer(const Duration(milliseconds: 1700), _advance);
  }

  void _advance() {
    if (!mounted) return;
    if (_questionIndex + 1 >= _totalQuestions) {
      setState(() => _showResults = true);
    } else {
      setState(() {
        _questionIndex++;
        _selectedOption = null;
        _answered = false;
        _isCorrect = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return SizedBox(
      height: screenHeight * 0.92,
      child: _showResults ? _buildResults(context) : _buildQuiz(context),
    );
  }

  // ── Results Screen ──────────────────────────────────────────────────────────

  Widget _buildResults(BuildContext context) {
    final xpEarned = (_correctCount / _totalQuestions * 40).round();
    final percent = (_correctCount / _totalQuestions * 100).round();
    final perfect = _correctCount == _totalQuestions;

    return Container(
      color: _kNavy,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _dragHandle(),
          const SizedBox(height: 44),

          // Trophy icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kTeal.withValues(alpha: 0.12),
              border: Border.all(color: _kTeal, width: 2),
            ),
            child: const Icon(Icons.emoji_events, color: _kTeal, size: 42),
          ),
          const SizedBox(height: 20),

          Text(
            perfect
                ? 'Perfect Score! 🎉'
                : percent >= 70
                    ? 'Great Work!'
                    : 'Keep Practising!',
            style: GoogleFonts.rajdhani(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_correctCount of $_totalQuestions correct  ·  $percent%',
            style: GoogleFonts.inter(fontSize: 15, color: _kSubtext),
          ),
          const SizedBox(height: 32),

          // Stat cards row
          Row(
            children: [
              _statCard('🔥', '$_streak', 'Best Streak'),
              const SizedBox(width: 12),
              _statCard('⭐', '+$xpEarned XP', 'Earned'),
              const SizedBox(width: 12),
              _statCard('🛡️', '$_shields', 'Shields Left'),
            ],
          ),

          const Spacer(),

          // Claim reward button
          GestureDetector(
            onTap: widget.onComplete,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: _kTeal,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _kTeal.withValues(alpha: 0.40),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Claim Reward',
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kTeal.withValues(alpha: 0.20)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.rajdhani(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kTeal,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: _kSubtext),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quiz Screen ─────────────────────────────────────────────────────────────

  Widget _buildQuiz(BuildContext context) {
    final question = _currentQuestion;
    return Container(
      color: _kNavy,
      child: Column(
        children: [
          const SizedBox(height: 12),
          _dragHandle(),
          const SizedBox(height: 16),

          // Stats bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildStatsBar(),
          ),
          const SizedBox(height: 16),

          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildProgressBar(),
          ),
          const SizedBox(height: 16),

          // Scrollable question + options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryBadge(question),
                  const SizedBox(height: 20),
                  _buildQuestionText(question),
                  const SizedBox(height: 24),
                  ...List.generate(
                    question.options.length,
                    (i) => _buildOptionCard(i, question),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Confirm / feedback button
          _buildConfirmButton(),
        ],
      ),
    );
  }

  // ── Drag Handle ─────────────────────────────────────────────────────────────

  Widget _dragHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ── Stats Bar ───────────────────────────────────────────────────────────────

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kTeal.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          // Streak
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_streak',
                      style: GoogleFonts.rajdhani(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _kTeal,
                      ),
                    ),
                    Text(
                      'streak',
                      style:
                          GoogleFonts.inter(fontSize: 11, color: _kSubtext),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Vertical divider
          Container(
            width: 1,
            height: 36,
            color: Colors.white.withValues(alpha: 0.12),
          ),

          // Shields
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield, color: _kTeal, size: 24),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_shields',
                      style: GoogleFonts.rajdhani(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _kTeal,
                      ),
                    ),
                    Text(
                      'shields',
                      style:
                          GoogleFonts.inter(fontSize: 11, color: _kSubtext),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress Bar ────────────────────────────────────────────────────────────

  Widget _buildProgressBar() {
    final qNum = _questionIndex + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $qNum of $_totalQuestions',
              style: GoogleFonts.inter(fontSize: 12, color: _kSubtext),
            ),
            Text(
              '${(qNum / _totalQuestions * 100).round()}%',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _kTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: qNum / _totalQuestions,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: const AlwaysStoppedAnimation<Color>(_kTeal),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  // ── Category Badge ──────────────────────────────────────────────────────────

  Widget _buildCategoryBadge(QuizQuestion question) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _kTeal.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kTeal.withValues(alpha: 0.50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(question.categoryEmoji,
              style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            question.category.toUpperCase(),
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kTeal,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Question Text ───────────────────────────────────────────────────────────

  Widget _buildQuestionText(QuizQuestion question) {
    return Text(
      question.question,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.55,
      ),
    );
  }

  // ── Option Card ─────────────────────────────────────────────────────────────

  Widget _buildOptionCard(int index, QuizQuestion question) {
    final isSelected = _selectedOption == index;
    final isCorrectAnswer = index == question.correctAnswerIndex;

    final Color borderColor;
    final Color bgColor;
    final Color textColor;
    final Color circleColor;
    final Color circleBorder;
    final Widget circleContent;

    if (!_answered) {
      if (isSelected) {
        borderColor = _kTeal;
        bgColor = _kTeal.withValues(alpha: 0.08);
        textColor = Colors.white;
        circleColor = _kTeal;
        circleBorder = _kTeal;
        circleContent = Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _kNavy,
            ),
          ),
        );
      } else {
        borderColor = Colors.white.withValues(alpha: 0.12);
        bgColor = _kCard;
        textColor = _kText;
        circleColor = Colors.transparent;
        circleBorder = Colors.white.withValues(alpha: 0.30);
        circleContent = const SizedBox.shrink();
      }
    } else {
      if (isCorrectAnswer) {
        borderColor = _kCorrect;
        bgColor = _kCorrect.withValues(alpha: 0.12);
        textColor = Colors.white;
        circleColor = _kCorrect;
        circleBorder = _kCorrect;
        circleContent =
            const Icon(Icons.check, size: 12, color: _kNavy);
      } else if (isSelected) {
        borderColor = _kWrong;
        bgColor = _kWrong.withValues(alpha: 0.10);
        textColor = _kWrong;
        circleColor = _kWrong;
        circleBorder = _kWrong;
        circleContent =
            const Icon(Icons.close, size: 12, color: Colors.white);
      } else {
        borderColor = Colors.white.withValues(alpha: 0.06);
        bgColor = _kCard;
        textColor = _kSubtext;
        circleColor = Colors.transparent;
        circleBorder = Colors.white.withValues(alpha: 0.15);
        circleContent = const SizedBox.shrink();
      }
    }

    return GestureDetector(
      onTap:
          _answered ? null : () => setState(() => _selectedOption = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: (isSelected && !_answered) ||
                    (_answered && isCorrectAnswer)
                ? 1.5
                : 1.0,
          ),
          boxShadow: (isSelected && !_answered)
              ? [
                  BoxShadow(
                    color: _kTeal.withValues(alpha: 0.15),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            // Radio circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: circleBorder, width: 2),
                color: circleColor,
              ),
              child: circleContent,
            ),
            const SizedBox(width: 14),

            // Option label
            Expanded(
              child: Text(
                question.options[index],
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Confirm Button ──────────────────────────────────────────────────────────

  Widget _buildConfirmButton() {
    final enabled = _selectedOption != null && !_answered;

    final Color buttonColor;
    final Color textColor;
    final String label;

    if (_answered) {
      if (_isCorrect) {
        buttonColor = _kCorrect;
        textColor = _kNavy;
        label = '✓  Correct!';
      } else {
        buttonColor = _kWrong;
        textColor = Colors.white;
        label = '✗  Incorrect — Next Question';
      }
    } else {
      buttonColor =
          enabled ? _kTeal : Colors.white.withValues(alpha: 0.10);
      textColor = enabled ? _kNavy : _kSubtext;
      label = 'Confirm Answer';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: GestureDetector(
        onTap: enabled ? _confirmAnswer : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: (enabled || _answered)
                ? [
                    BoxShadow(
                      color: buttonColor.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
