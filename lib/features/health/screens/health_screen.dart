/// health_screen.dart
/// Purpose: Financial Health Score — circular gauge, 5 sub-score cards,
///          weekly score history, and personalised tips.
/// Palette: deep navy + dynamic colour based on score band.
library;

import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zamwealth_quest/features/health/providers/health_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF0A1628);
const _kCard = Color(0xFF0D1B2A);
const _kText = Color(0xFFE6E9EC);

Color _bandColor(int score) {
  if (score >= 86) return const Color(0xFFFFB703); // gold
  if (score >= 71) return const Color(0xFF36ECDE); // teal
  if (score >= 41) return const Color(0xFFFFC107); // amber
  return const Color(0xFFF44336);                  // red
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthProvider);
    final data  = state.data;

    return Scaffold(
      backgroundColor: _kNavy,
      appBar: AppBar(
        backgroundColor: _kNavy,
        foregroundColor: _kText,
        title: const Text('Financial Health',
            style: TextStyle(
                color: _kText, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Refresh score',
            onPressed: () => ref.read(healthProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.isLoading || data == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF36ECDE)))
          : SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  MediaQuery.paddingOf(context).bottom + 24,
                ),
                child: Column(
                  children: [
                    _buildGaugeCard(data),
                    const SizedBox(height: 20),
                    _buildSubScores(data),
                    const SizedBox(height: 20),
                    if ((state.record?.scoreHistory.length ?? 0) > 1)
                      _buildHistoryChart(state.record!.scoreHistory),
                    if ((state.record?.scoreHistory.length ?? 0) > 1)
                      const SizedBox(height: 20),
                    _buildTipCard(data),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Gauge card ────────────────────────────────────────────────────────────

  Widget _buildGaugeCard(HealthData data) {
    final score = data.totalScore;
    final color = _bandColor(score);

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('FINANCIAL HEALTH SCORE',
              style: TextStyle(
                  color: _kText.withValues(alpha: 0.5),
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    painter: _HealthGaugePainter(score: score, color: color),
                    size: const Size(180, 180),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$score',
                        style: TextStyle(
                            color: color,
                            fontSize: 48,
                            fontWeight: FontWeight.bold)),
                    Text('/ 100',
                        style: TextStyle(
                            color: _kText.withValues(alpha: 0.45),
                            fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(data.band,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  // ── Sub-score cards ───────────────────────────────────────────────────────

  Widget _buildSubScores(HealthData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sub-Scores  (each out of 20)',
            style: TextStyle(
                color: _kText.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        _subScoreCard('🛡️', 'Emergency Fund',
            'Savings cushion against unexpected expenses',
            data.emergencyFundScore),
        _subScoreCard('🏦', 'Debt Health',
            'Credit score & loan repayment discipline',
            data.debtHealthScore),
        _subScoreCard('📈', 'Investment Growth',
            'Portfolio returns & investment activity',
            data.investmentScore),
        _subScoreCard('💼', 'Income Stability',
            'Business profit & wallet balance',
            data.incomeScore),
        _subScoreCard('🎯', 'Budget Discipline',
            'No overdue debt, regular saving, wallet buffer',
            data.budgetScore),
      ],
    );
  }

  Widget _subScoreCard(String emoji, String label, String desc, int score) {
    final color = _bandColor(score * 5); // scale 0–20 → 0–100 for color
    final pct   = score / 20.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration:
          BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: _kText.withValues(alpha: 0.9),
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    Text('$score / 20',
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc,
                    style: TextStyle(
                        color: _kText.withValues(alpha: 0.45), fontSize: 11)),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: pct,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── History chart ─────────────────────────────────────────────────────────

  Widget _buildHistoryChart(List<int> history) {
    final spots = history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList();
    final latest = history.last;
    final color  = _bandColor(latest);

    return Container(
      height: 130,
      decoration:
          BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Score History',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 3,
                          color: color,
                          strokeWidth: 0,
                          strokeColor: Colors.transparent),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tip card ──────────────────────────────────────────────────────────────

  Widget _buildTipCard(HealthData data) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF36ECDE).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF36ECDE).withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              color: Color(0xFF36ECDE), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Priority Action',
                    style: TextStyle(
                        color: Color(0xFF36ECDE),
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 6),
                Text(data.tip,
                    style: TextStyle(
                        color: _kText.withValues(alpha: 0.75),
                        fontSize: 13,
                        height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Health Gauge Painter
// ─────────────────────────────────────────────────────────────────────────────

class _HealthGaugePainter extends CustomPainter {
  const _HealthGaugePainter({required this.score, required this.color});
  final int score;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    const startAngle = pi * 7 / 6;  // 210°
    const totalSweep = pi * 5 / 3;  // 300°

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    if (score > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        totalSweep * score / 100,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_HealthGaugePainter old) =>
      old.score != score || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini Gauge (reusable by dashboard)
// ─────────────────────────────────────────────────────────────────────────────

class HealthMiniGauge extends StatelessWidget {
  const HealthMiniGauge({super.key, required this.score, this.size = 36});
  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MiniGaugePainter(score: score),
      ),
    );
  }
}

class _MiniGaugePainter extends CustomPainter {
  const _MiniGaugePainter({required this.score});
  final int score;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.40;
    const startAngle = pi * 7 / 6;
    const totalSweep = pi * 5 / 3;
    final color = _bandColor(score);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, totalSweep, false,
      Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    if (score > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, totalSweep * score / 100, false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniGaugePainter old) => old.score != score;
}
