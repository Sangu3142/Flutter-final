library;

import 'package:flutter/material.dart';

class CoinsPainter extends CustomPainter {
  const CoinsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF00203F), Color(0xFF0D1B2A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    void drawCoinStack(double cx, double baseY, int count, Color color) {
      final r = w * 0.09;
      final step = h * 0.06;
      for (int i = count - 1; i >= 0; i--) {
        final y = baseY - i * step;
        // Coin edge shadow
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, y + r * 0.25), width: r * 2, height: r * 0.55),
          Paint()..color = color.withValues(alpha: 0.5),
        );
        // Coin face
        canvas.drawCircle(Offset(cx, y), r, Paint()..color = color);
        // Shine
        canvas.drawCircle(
          Offset(cx - r * 0.25, y - r * 0.25),
          r * 0.20,
          Paint()..color = Colors.white.withValues(alpha: 0.40),
        );
        // Inner ring
        canvas.drawCircle(
          Offset(cx, y),
          r * 0.65,
          Paint()
            ..color = color.withValues(alpha: 0.0)
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.12
            ..color = Colors.white.withValues(alpha: 0.25),
        );
      }
    }

    // Three coin stacks
    drawCoinStack(w * 0.25, h * 0.72, 3, const Color(0xFFFFB703));
    drawCoinStack(w * 0.50, h * 0.72, 5, const Color(0xFFFFB703));
    drawCoinStack(w * 0.75, h * 0.72, 4, const Color(0xFFFFB703));

    // Sparkles
    final sparklePaint = Paint()
      ..color = const Color(0xFFFFB703).withValues(alpha: 0.80)
      ..strokeWidth = 2;
    for (final pos in [
      Offset(w * 0.12, h * 0.30),
      Offset(w * 0.88, h * 0.25),
      Offset(w * 0.50, h * 0.18),
      Offset(w * 0.35, h * 0.45),
    ]) {
      canvas.drawLine(
          Offset(pos.dx - 6, pos.dy), Offset(pos.dx + 6, pos.dy), sparklePaint);
      canvas.drawLine(
          Offset(pos.dx, pos.dy - 6), Offset(pos.dx, pos.dy + 6), sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CoinsPainter old) => false;
}
