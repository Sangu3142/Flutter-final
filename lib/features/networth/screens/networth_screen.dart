/// networth_screen.dart
/// Purpose: Net Worth Dashboard — Baobab tree growth stages, asset/liability
///          breakdown, and Debt-O-Meter arc gauge.
/// Palette: deep navy (#0A1628) + gold (#FFB703)
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zamwealth_quest/features/networth/providers/networth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────

const _kNavy  = Color(0xFF0A1628);
const _kCard  = Color(0xFF0D1B2A);
const _kGold  = Color(0xFFFFB703);
const _kAmber = Color(0xFFFB8500);
const _kText  = Color(0xFFFFF8E1);
const _kGreen = Color(0xFF4CAF50);
const _kRed   = Color(0xFFF44336);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class NetWorthScreen extends ConsumerWidget {
  const NetWorthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nw = ref.watch(netWorthProvider);

    return Scaffold(
      backgroundColor: _kNavy,
      appBar: AppBar(
        backgroundColor: _kNavy,
        foregroundColor: _kText,
        title: const Text('Net Worth',
            style: TextStyle(
                color: _kText, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(nw),
              const SizedBox(height: 20),
              _buildBaobabCard(nw),
              const SizedBox(height: 20),
              _buildAssetsCard(nw),
              const SizedBox(height: 16),
              if (nw.totalLiabilitiesZMW > 0) ...[
                _buildLiabilitiesCard(nw),
                const SizedBox(height: 16),
                _buildDebtMeter(nw),
                const SizedBox(height: 16),
              ],
              _buildEducationCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Summary card ──────────────────────────────────────────────────────────

  Widget _buildSummaryCard(NetWorthData nw) {
    final isPositive = nw.netWorthZMW >= 0;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [_kAmber, _kGold]
              : [const Color(0xFFB71C1C), const Color(0xFFF44336)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Net Worth',
                    style: TextStyle(color: Colors.black54, fontSize: 12)),
                Text(
                  'ZMW ${_fmt(nw.netWorthZMW.abs())}',
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isPositive ? 'Assets exceed liabilities' : 'Liabilities exceed assets',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(isPositive ? '🌳' : '⚠️',
                  style: const TextStyle(fontSize: 32)),
              Text(nw.baobabStageName,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Baobab tree card ──────────────────────────────────────────────────────

  Widget _buildBaobabCard(NetWorthData nw) {
    return Container(
      decoration: BoxDecoration(
          color: _kCard, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌳',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'YOUR BAOBAB  •  STAGE ${nw.baobabStage}/6',
                style: const TextStyle(
                    color: _kGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _BaobabPainter(stage: nw.baobabStage),
                size: const Size(double.infinity, 160),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(nw.baobabDescription,
              style: TextStyle(
                  color: _kText.withValues(alpha: 0.7), fontSize: 13, height: 1.4)),
          const SizedBox(height: 8),
          // Stage progress bar
          Row(
            children: List.generate(6, (i) {
              final filled = i < nw.baobabStage;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 3),
                  height: 6,
                  decoration: BoxDecoration(
                    color: filled
                        ? _kGold
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Assets card ───────────────────────────────────────────────────────────

  Widget _buildAssetsCard(NetWorthData nw) {
    return Container(
      decoration: BoxDecoration(
          color: _kCard, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assets  •  ZMW ${_fmt(nw.totalAssetsZMW)}',
              style: const TextStyle(
                  color: _kGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 12),
          _assetRow('💼', 'Wallet', nw.walletAssetsZMW, nw.totalAssetsZMW),
          _assetRow('🏠', 'Property', nw.propertyAssetsZMW, nw.totalAssetsZMW),
          _assetRow('📊', 'Portfolio', nw.portfolioAssetsZMW, nw.totalAssetsZMW),
          _assetRow('🎯', 'Savings Goals', nw.savingsAssetsZMW, nw.totalAssetsZMW),
          _assetRow('🏢', 'Business Profit', nw.businessAssetsZMW, nw.totalAssetsZMW),
        ],
      ),
    );
  }

  Widget _assetRow(String emoji, String label, int value, int total) {
    if (value == 0) return const SizedBox.shrink();
    final pct = total == 0 ? 0.0 : (value / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        color: _kText.withValues(alpha: 0.8), fontSize: 12)),
              ]),
              Text('ZMW ${_fmt(value)}',
                  style: TextStyle(
                      color: _kText.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
            borderRadius: BorderRadius.circular(3),
            minHeight: 5,
          ),
        ],
      ),
    );
  }

  // ── Liabilities card ──────────────────────────────────────────────────────

  Widget _buildLiabilitiesCard(NetWorthData nw) {
    return Container(
      decoration: BoxDecoration(
          color: _kCard, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Liabilities  •  ZMW ${_fmt(nw.totalLiabilitiesZMW)}',
              style: const TextStyle(
                  color: _kRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 12),
          if (nw.loanLiabilitiesZMW > 0)
            _liabRow('🏦', 'Loan Balances', nw.loanLiabilitiesZMW),
          if (nw.mortgageLiabilitiesZMW > 0)
            _liabRow('🏠', 'Mortgage Remaining', nw.mortgageLiabilitiesZMW),
        ],
      ),
    );
  }

  Widget _liabRow(String emoji, String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(label,
                style:
                    TextStyle(color: _kText.withValues(alpha: 0.8), fontSize: 12)),
          ]),
          Text('ZMW ${_fmt(value)}',
              style: TextStyle(
                  color: _kRed.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── Debt-O-Meter ──────────────────────────────────────────────────────────

  Widget _buildDebtMeter(NetWorthData nw) {
    final label = nw.debtRatio < 0.3
        ? 'Low Debt'
        : nw.debtRatio < 0.6
            ? 'Moderate Debt'
            : 'High Debt';
    final labelColor = nw.debtRatio < 0.3
        ? _kGreen
        : nw.debtRatio < 0.6
            ? const Color(0xFFFFC107)
            : _kRed;

    return Container(
      decoration: BoxDecoration(
          color: _kCard, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Row(
            children: [
              Text('⚖️', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text('DEBT-O-METER',
                  style: TextStyle(
                      color: _kGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _DebtMeterPainter(ratio: nw.debtRatio),
                size: const Size(double.infinity, 110),
              ),
            ),
          ),
          Text(
            '${(nw.debtRatio * 100).round()}% of assets are liabilities  •  $label',
            style: TextStyle(
                color: labelColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ── Education card ────────────────────────────────────────────────────────

  Widget _buildEducationCard() {
    return Container(
      decoration: BoxDecoration(
        color: _kGold.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kGold.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: _kAmber, size: 18),
              SizedBox(width: 6),
              Text('Net Worth Wisdom',
                  style: TextStyle(
                      color: _kAmber, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          _tip('Net worth = Total Assets − Total Liabilities. Growing it requires both saving more and reducing debt.'),
          _tip('Property in Zambia has appreciated 10–12% annually in recent years — owning assets that grow beats holding cash.'),
          _tip('Stage 4+ Baobab? You are in the top 20% of Zambian savers. Keep compound interest working for you.'),
          _tip('Reduce liabilities first — a ZMW 1 debt costs more than ZMW 1 in interest over time.'),
        ],
      ),
    );
  }

  Widget _tip(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ',
                style: TextStyle(color: _kAmber.withValues(alpha: 0.7), fontSize: 13)),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: _kText.withValues(alpha: 0.65), fontSize: 12)),
            ),
          ],
        ),
      );

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return '$v';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Baobab Tree Painter
// ─────────────────────────────────────────────────────────────────────────────

class _BaobabPainter extends CustomPainter {
  const _BaobabPainter({required this.stage});
  final int stage;

  static const _trunkColor  = Color(0xFF8B5E3C);
  static const _leafColor1  = Color(0xFF4CAF50);
  static const _leafColor2  = Color(0xFF2E7D32);
  @override
  void paint(Canvas canvas, Size size) {
    final w      = size.width;
    final h      = size.height;
    final cx     = w / 2;
    final groundY = h - 6.0;

    final ground = Paint()
      ..color = _trunkColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(Offset(cx - 70, groundY), Offset(cx + 70, groundY), ground);

    switch (stage) {
      case 1:
        _line(canvas, cx, groundY, cx, h * 0.58, 3, _trunkColor);
        _circle(canvas, cx, h * 0.52, 11, _leafColor1);
        break;

      case 2:
        _line(canvas, cx, groundY, cx, h * 0.42, 5, _trunkColor);
        _circle(canvas, cx, h * 0.35, 20, _leafColor1);
        _circle(canvas, cx - 14, h * 0.42, 12, _leafColor2);
        _circle(canvas, cx + 14, h * 0.42, 12, _leafColor1);
        break;

      case 3:
        _trunk(canvas, cx, groundY, h * 0.34, 0.30);
        _circle(canvas, cx, h * 0.27, 26, _leafColor1);
        _circle(canvas, cx - 18, h * 0.34, 14, _leafColor2);
        _circle(canvas, cx + 18, h * 0.34, 14, _leafColor1);
        break;

      case 4:
        _trunk(canvas, cx, groundY, h * 0.32, 0.44);
        _line(canvas, cx, h * 0.32, cx - 34, h * 0.17, 4, _trunkColor);
        _line(canvas, cx, h * 0.32, cx + 34, h * 0.17, 4, _trunkColor);
        _circle(canvas, cx - 38, h * 0.14, 22, _leafColor1);
        _circle(canvas, cx + 38, h * 0.14, 22, _leafColor2);
        _circle(canvas, cx, h * 0.11, 20, _leafColor1);
        break;

      case 5:
        _trunk(canvas, cx, groundY, h * 0.30, 0.55);
        _line(canvas, cx, h * 0.30, cx - 50, h * 0.15, 5, _trunkColor);
        _line(canvas, cx, h * 0.30, cx + 50, h * 0.15, 5, _trunkColor);
        _line(canvas, cx, h * 0.34, cx - 28, h * 0.09, 4, _trunkColor);
        _line(canvas, cx, h * 0.34, cx + 28, h * 0.09, 4, _trunkColor);
        _circle(canvas, cx - 52, h * 0.12, 24, _leafColor1);
        _circle(canvas, cx + 52, h * 0.12, 24, _leafColor2);
        _circle(canvas, cx - 28, h * 0.06, 20, _leafColor2);
        _circle(canvas, cx + 28, h * 0.06, 20, _leafColor1);
        _circle(canvas, cx, h * 0.04, 24, _leafColor1);
        break;

      default: // stage 6
        _trunk(canvas, cx, groundY, h * 0.28, 0.65);
        const angles = [-65.0, -40.0, -18.0, 18.0, 40.0, 65.0];
        for (final deg in angles) {
          final rad  = deg * pi / 180;
          final tipX = cx + sin(rad) * 64;
          final tipY = h * 0.28 - cos(rad).abs() * 58;
          _line(canvas, cx, h * 0.28, tipX, tipY, 5, _trunkColor);
          _circle(canvas, tipX, tipY - 6, 20,
              deg.abs() < 30 ? _leafColor2 : _leafColor1);
        }
        _circle(canvas, cx, h * 0.03, 26, _leafColor2);
        break;
    }
  }

  void _trunk(Canvas canvas, double cx, double groundY, double topY, double wf) {
    final hw   = 40 * wf;
    final span = groundY - topY;
    final path = Path()
      ..moveTo(cx - hw, groundY)
      ..quadraticBezierTo(cx - hw * 1.25, groundY - span * 0.55, cx - hw * 0.55, topY)
      ..lineTo(cx + hw * 0.55, topY)
      ..quadraticBezierTo(cx + hw * 1.25, groundY - span * 0.55, cx + hw, groundY)
      ..close();
    canvas.drawPath(path, Paint()..color = _trunkColor);
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.07)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  void _line(Canvas canvas, double x1, double y1, double x2, double y2,
      double w, Color c) {
    canvas.drawLine(
      Offset(x1, y1),
      Offset(x2, y2),
      Paint()
        ..color = c
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round,
    );
  }

  void _circle(Canvas canvas, double x, double y, double r, Color c) {
    canvas.drawCircle(Offset(x, y), r, Paint()..color = c);
  }

  @override
  bool shouldRepaint(_BaobabPainter old) => old.stage != stage;
}

// ─────────────────────────────────────────────────────────────────────────────
// Debt-O-Meter Painter
// ─────────────────────────────────────────────────────────────────────────────

class _DebtMeterPainter extends CustomPainter {
  const _DebtMeterPainter({required this.ratio});
  final double ratio;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.90);
    final radius = size.width * 0.38;
    const startAngle = pi;
    const totalSweep = pi;

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

    if (ratio > 0) {
      final color = ratio < 0.30
          ? const Color(0xFF4CAF50)
          : ratio < 0.60
              ? const Color(0xFFFFC107)
              : const Color(0xFFF44336);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        totalSweep * ratio,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round,
      );

      final needleAngle = startAngle + totalSweep * ratio;
      final nx = center.dx + cos(needleAngle) * (radius - 6);
      final ny = center.dy + sin(needleAngle) * (radius - 6);
      canvas.drawLine(
        center,
        Offset(nx, ny),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(center, 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_DebtMeterPainter old) => old.ratio != ratio;
}
