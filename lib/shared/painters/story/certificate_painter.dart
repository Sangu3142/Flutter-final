library;

import 'package:flutter/material.dart';

class CertificatePainter extends CustomPainter {
  const CertificatePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF00203F), Color(0xFF1A3A5C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Certificate body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.10, w * 0.84, h * 0.80),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFFFF8E7),
    );

    // Outer border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.11, h * 0.14, w * 0.78, h * 0.72),
        const Radius.circular(6),
      ),
      Paint()
        ..color = const Color(0xFFFFB703)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Corner ornaments
    for (final pos in [
      Offset(w * 0.13, h * 0.16),
      Offset(w * 0.87, h * 0.16),
      Offset(w * 0.13, h * 0.84),
      Offset(w * 0.87, h * 0.84),
    ]) {
      canvas.drawCircle(pos, 5, Paint()..color = const Color(0xFFFFB703));
    }

    // Medallion (seal)
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.36),
      w * 0.12,
      Paint()..color = const Color(0xFFFFB703),
    );
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.36),
      w * 0.09,
      Paint()..color = const Color(0xFFFFF8E7),
    );
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.36),
      w * 0.06,
      Paint()..color = const Color(0xFFFFB703),
    );

    // Star in medallion
    _drawStar(
      canvas,
      Offset(w * 0.50, h * 0.36),
      w * 0.04,
      const Color(0xFFFFF8E7),
    );

    // Title lines (represented as colored bars)
    final linePaint = Paint()
      ..color = const Color(0xFF1A3A5C)
      ..strokeCap = StrokeCap.round;
    linePaint.strokeWidth = 4;
    canvas.drawLine(
        Offset(w * 0.20, h * 0.56), Offset(w * 0.80, h * 0.56), linePaint);
    linePaint.strokeWidth = 2.5;
    canvas.drawLine(
        Offset(w * 0.28, h * 0.63), Offset(w * 0.72, h * 0.63), linePaint);
    linePaint.strokeWidth = 2;
    canvas.drawLine(
        Offset(w * 0.35, h * 0.70), Offset(w * 0.65, h * 0.70), linePaint);

    // Ribbon
    final ribbonPaint = Paint()..color = const Color(0xFF36ECDE);
    canvas.drawRect(Rect.fromLTWH(w * 0.40, h * 0.80, w * 0.20, h * 0.07),
        ribbonPaint);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.40, h * 0.80)
        ..lineTo(w * 0.34, h * 0.75)
        ..lineTo(w * 0.40, h * 0.80),
      ribbonPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.60, h * 0.80)
        ..lineTo(w * 0.66, h * 0.75)
        ..lineTo(w * 0.60, h * 0.80),
      ribbonPaint,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color color) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = i * 3.14159 * 2 / 5 - 3.14159 / 2;
      final inner = outer + 3.14159 / 5;
      final op = Offset(
        center.dx + r * _cos(outer),
        center.dy + r * _sin(outer),
      );
      final ip = Offset(
        center.dx + r * 0.45 * _cos(inner),
        center.dy + r * 0.45 * _sin(inner),
      );
      if (i == 0) path.moveTo(op.dx, op.dy);
      path.lineTo(ip.dx, ip.dy);
      path.lineTo(op.dx, op.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  double _cos(double r) => r == 0
      ? 1
      : r == 3.14159 / 2
          ? 0
          : (r == 3.14159 ? -1 : _approxCos(r));
  double _sin(double r) => _approxSin(r);

  double _approxCos(double x) {
    double c = 1, term = 1;
    for (int i = 1; i <= 6; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      c += term;
    }
    return c;
  }

  double _approxSin(double x) {
    double s = x, term = x;
    for (int i = 1; i <= 6; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      s += term;
    }
    return s;
  }

  @override
  bool shouldRepaint(covariant CertificatePainter old) => false;
}
