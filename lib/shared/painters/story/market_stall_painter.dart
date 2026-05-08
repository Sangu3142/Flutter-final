library;

import 'package:flutter/material.dart';

class MarketStallPainter extends CustomPainter {
  const MarketStallPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF00203F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.72, w, h * 0.28),
      Paint()..color = const Color(0xFF3D2B1F),
    );

    // Stall frame (vertical poles)
    final pole = Paint()..color = const Color(0xFF8B5E3C);
    canvas.drawRect(Rect.fromLTWH(w * 0.18, h * 0.35, w * 0.04, h * 0.38), pole);
    canvas.drawRect(Rect.fromLTWH(w * 0.78, h * 0.35, w * 0.04, h * 0.38), pole);

    // Counter
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.58, w * 0.76, h * 0.14),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF5C3D2E),
    );

    // Awning — striped
    final awningPath = Path()
      ..moveTo(w * 0.08, h * 0.38)
      ..lineTo(w * 0.92, h * 0.38)
      ..lineTo(w * 0.86, h * 0.55)
      ..lineTo(w * 0.14, h * 0.55)
      ..close();

    canvas.drawPath(awningPath, Paint()..color = const Color(0xFF36ECDE));

    // Awning stripes
    final stripePaint = Paint()
      ..color = const Color(0xFF1A73E8)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 5; i++) {
      final x = w * (0.20 + i * 0.14);
      canvas.drawLine(Offset(x, h * 0.38), Offset(x - 4, h * 0.55), stripePaint);
    }

    // Goods on counter — circles representing produce
    final colors = [
      const Color(0xFFFF6B35),
      const Color(0xFFFFB703),
      const Color(0xFF2BC48A),
      const Color(0xFFFF6B35),
      const Color(0xFFFFB703),
      const Color(0xFF2BC48A),
    ];
    for (int i = 0; i < 6; i++) {
      canvas.drawCircle(
        Offset(w * (0.20 + i * 0.12), h * 0.56),
        w * 0.05,
        Paint()..color = colors[i],
      );
    }

    // Sign above stall
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.28, h * 0.18, w * 0.44, h * 0.14),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFFFB703),
    );
  }

  @override
  bool shouldRepaint(covariant MarketStallPainter old) => false;
}
