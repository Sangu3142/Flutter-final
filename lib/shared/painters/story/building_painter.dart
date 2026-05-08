library;

import 'package:flutter/material.dart';

class BuildingPainter extends CustomPainter {
  const BuildingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Night sky
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF00203F), Color(0xFF0D1B2A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Stars
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    for (final pos in [
      Offset(w * 0.10, h * 0.08),
      Offset(w * 0.30, h * 0.05),
      Offset(w * 0.55, h * 0.12),
      Offset(w * 0.78, h * 0.07),
      Offset(w * 0.90, h * 0.15),
    ]) {
      canvas.drawCircle(pos, 2, starPaint);
    }

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.82, w, h * 0.18),
      Paint()..color = const Color(0xFF1A1A2E),
    );

    // Main building
    canvas.drawRect(
      Rect.fromLTWH(w * 0.25, h * 0.18, w * 0.50, h * 0.64),
      Paint()..color = const Color(0xFF1A3A5C),
    );

    // Building top accent
    canvas.drawRect(
      Rect.fromLTWH(w * 0.25, h * 0.15, w * 0.50, h * 0.05),
      Paint()..color = const Color(0xFF36ECDE),
    );

    // Windows grid (4 cols × 5 rows)
    final litPaint = Paint()..color = const Color(0xFFFFB703).withValues(alpha: 0.85);
    final darkPaint = Paint()..color = const Color(0xFF0D2A44);
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 4; col++) {
        final lit = (row + col) % 3 != 0;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              w * (0.31 + col * 0.11),
              h * (0.24 + row * 0.11),
              w * 0.07,
              h * 0.07,
            ),
            const Radius.circular(2),
          ),
          lit ? litPaint : darkPaint,
        );
      }
    }

    // Small side buildings
    canvas.drawRect(
      Rect.fromLTWH(w * 0.05, h * 0.45, w * 0.18, h * 0.37),
      Paint()..color = const Color(0xFF0F2840),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.77, h * 0.38, w * 0.18, h * 0.44),
      Paint()..color = const Color(0xFF0F2840),
    );

    // Neon sign on building
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.30, h * 0.63, w * 0.40, h * 0.08),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF36ECDE).withValues(alpha: 0.20),
    );
  }

  @override
  bool shouldRepaint(covariant BuildingPainter old) => false;
}
