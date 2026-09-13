library;

import 'package:flutter/material.dart';

class SupplierPainter extends CustomPainter {
  const SupplierPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF1A3A5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Road
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.70, w, h * 0.30),
      Paint()..color = const Color(0xFF2A2A2A),
    );
    // Road markings
    final markPaint = Paint()
      ..color = const Color(0xFFFFB703)
      ..strokeWidth = 3;
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(w * (0.05 + i * 0.22), h * 0.82),
        Offset(w * (0.15 + i * 0.22), h * 0.82),
        markPaint,
      );
    }

    // Truck body (cargo)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.38, w * 0.55, h * 0.32),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF36ECDE),
    );

    // Cab
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.60, h * 0.44, w * 0.32, h * 0.26),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF1A73E8),
    );

    // Windshield
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.64, h * 0.47, w * 0.22, h * 0.13),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF36ECDE).withValues(alpha: 0.45),
    );

    // Wheels
    final wheelPaint = Paint()..color = const Color(0xFF111111);
    final rimPaint = Paint()..color = const Color(0xFF888888);
    for (final cx in [w * 0.20, w * 0.40, w * 0.72]) {
      canvas.drawCircle(Offset(cx, h * 0.72), w * 0.075, wheelPaint);
      canvas.drawCircle(Offset(cx, h * 0.72), w * 0.038, rimPaint);
    }

    // Headlight
    canvas.drawCircle(
      Offset(w * 0.91, h * 0.62),
      w * 0.025,
      Paint()..color = const Color(0xFFFFB703),
    );
  }

  @override
  bool shouldRepaint(covariant SupplierPainter old) => false;
}
