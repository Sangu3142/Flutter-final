import 'dart:math' as math;
import 'package:flutter/material.dart';

enum BossType { debtCollector, loanShark, gambler, taxEvader }

class BossCharacterPainter extends CustomPainter {
  final BossType bossType;

  const BossCharacterPainter({required this.bossType});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.38;
    final r = size.width * 0.26;

    switch (bossType) {
      case BossType.debtCollector:
        _drawChipata(canvas, size, cx, cy, r);
      case BossType.loanShark:
        _drawGenericBoss(canvas, size, cx, cy, r, const Color(0xFF1E3A5F));
      case BossType.gambler:
        _drawGenericBoss(canvas, size, cx, cy, r, const Color(0xFF9B2335));
      case BossType.taxEvader:
        _drawGenericBoss(canvas, size, cx, cy, r, const Color(0xFF374151));
    }
  }

  // ── Chipata the Debt Collector ────────────────────────────────────────────

  void _drawChipata(Canvas canvas, Size size, double cx, double cy, double r) {
    final paint = Paint()..isAntiAlias = true;

    // ── Horns (drawn behind head) ─────────────────────────────────────
    paint.color = const Color(0xFF1A0000);
    final leftHorn = Path()
      ..moveTo(cx - r * 0.40, cy - r * 0.78)
      ..quadraticBezierTo(
          cx - r * 0.68, cy - r * 1.52, cx - r * 0.28, cy - r * 1.38)
      ..quadraticBezierTo(
          cx - r * 0.08, cy - r * 1.10, cx - r * 0.18, cy - r * 0.75)
      ..close();
    canvas.drawPath(leftHorn, paint);

    final rightHorn = Path()
      ..moveTo(cx + r * 0.40, cy - r * 0.78)
      ..quadraticBezierTo(
          cx + r * 0.68, cy - r * 1.52, cx + r * 0.28, cy - r * 1.38)
      ..quadraticBezierTo(
          cx + r * 0.08, cy - r * 1.10, cx + r * 0.18, cy - r * 0.75)
      ..close();
    canvas.drawPath(rightHorn, paint);

    // Horn tips — slightly lighter
    paint.color = const Color(0xFF3D0000);
    canvas.drawCircle(Offset(cx - r * 0.28, cy - r * 1.40), r * 0.08, paint);
    canvas.drawCircle(Offset(cx + r * 0.28, cy - r * 1.40), r * 0.08, paint);

    // ── Head — maroon ────────────────────────────────────────────────
    paint
      ..color = const Color(0xFF7B1818)
      ..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(1.0, 1.08);
    canvas.drawCircle(Offset.zero, r, paint);
    canvas.restore();

    // Depth shadow on face
    canvas.drawCircle(
      Offset(cx, cy + r * 0.08),
      r * 0.96,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 9),
    );

    // ── Angry eyebrows (V-shape pointing down to center) ─────────────
    final browPaint = Paint()
      ..color = const Color(0xFF0D0000)
      ..strokeWidth = r * 0.13
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx - r * 0.62, cy - r * 0.40),
      Offset(cx - r * 0.14, cy - r * 0.28),
      browPaint,
    );
    canvas.drawLine(
      Offset(cx + r * 0.62, cy - r * 0.40),
      Offset(cx + r * 0.14, cy - r * 0.28),
      browPaint,
    );

    // ── Left eye — narrow and dark ───────────────────────────────────
    final leftEyeCenter = Offset(cx - r * 0.30, cy - r * 0.06);
    canvas.drawOval(
      Rect.fromCenter(
          center: leftEyeCenter, width: r * 0.38, height: r * 0.18),
      Paint()..color = const Color(0xFF080000),
    );
    // Red iris glint
    canvas.drawCircle(
      Offset(leftEyeCenter.dx - r * 0.04, leftEyeCenter.dy - r * 0.03),
      r * 0.050,
      Paint()..color = const Color(0xFFCC1010),
    );

    // ── Right eye — narrow with monocle ─────────────────────────────
    final rightEyeCenter = Offset(cx + r * 0.30, cy - r * 0.06);
    canvas.drawOval(
      Rect.fromCenter(
          center: rightEyeCenter, width: r * 0.38, height: r * 0.18),
      Paint()..color = const Color(0xFF080000),
    );
    canvas.drawCircle(
      Offset(rightEyeCenter.dx + r * 0.04, rightEyeCenter.dy - r * 0.03),
      r * 0.050,
      Paint()..color = const Color(0xFFCC1010),
    );

    // Monocle gold frame
    canvas.drawCircle(
      Offset(cx + r * 0.30, cy - r * 0.04),
      r * 0.30,
      Paint()
        ..color = const Color(0xFFB8860B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.055,
    );
    // Monocle lens tint
    canvas.drawCircle(
      Offset(cx + r * 0.30, cy - r * 0.04),
      r * 0.26,
      Paint()..color = const Color(0xFF1A73E8).withValues(alpha: 0.08),
    );
    // Monocle chain
    final chainPaint = Paint()
      ..color = const Color(0xFFB8860B)
      ..strokeWidth = r * 0.022
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx + r * 0.56, cy + r * 0.18),
      Offset(cx + r * 0.64, cy + r * 0.36),
      chainPaint,
    );
    canvas.drawLine(
      Offset(cx + r * 0.64, cy + r * 0.36),
      Offset(cx + r * 0.58, cy + r * 0.50),
      chainPaint,
    );

    // ── Nose ─────────────────────────────────────────────────────────
    final nosePath = Path()
      ..moveTo(cx, cy + r * 0.06)
      ..lineTo(cx - r * 0.11, cy + r * 0.30)
      ..quadraticBezierTo(cx, cy + r * 0.36, cx + r * 0.11, cy + r * 0.30)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFF4A0A0A));

    // ── Frown ─────────────────────────────────────────────────────────
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.61),
        width: r * 0.54,
        height: r * 0.20,
      ),
      0,
      -math.pi, // counterclockwise = top of oval = frown shape
      false,
      Paint()
        ..color = const Color(0xFF1A0000)
        ..strokeWidth = r * 0.072
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // ── Body — dark pinstripe suit ───────────────────────────────────
    final bodyTop = cy + r * 0.88;
    final bodyBottom = size.height;
    paint.color = const Color(0xFF100505);
    canvas.drawRRect(
      RRect.fromLTRBR(
          cx - r * 0.74, bodyTop, cx + r * 0.74, bodyBottom,
          const Radius.circular(8)),
      paint,
    );

    // Suit lapels
    final lapelPaint = Paint()..color = const Color(0xFF1E0808);
    // Left lapel
    final leftLapel = Path()
      ..moveTo(cx, bodyTop)
      ..lineTo(cx - r * 0.28, bodyTop + r * 0.18)
      ..lineTo(cx - r * 0.42, bodyTop + r * 0.50)
      ..lineTo(cx - r * 0.52, bodyTop)
      ..close();
    canvas.drawPath(leftLapel, lapelPaint);
    // Right lapel
    final rightLapel = Path()
      ..moveTo(cx, bodyTop)
      ..lineTo(cx + r * 0.28, bodyTop + r * 0.18)
      ..lineTo(cx + r * 0.42, bodyTop + r * 0.50)
      ..lineTo(cx + r * 0.52, bodyTop)
      ..close();
    canvas.drawPath(rightLapel, lapelPaint);

    // Tie — blood red
    final tieH = size.height - bodyTop;
    final tiePath = Path()
      ..moveTo(cx - r * 0.07, bodyTop)
      ..lineTo(cx + r * 0.07, bodyTop)
      ..lineTo(cx + r * 0.10, bodyTop + tieH * 0.52)
      ..lineTo(cx + r * 0.14, bodyTop + tieH * 0.78)
      ..lineTo(cx, bodyTop + tieH * 0.90)
      ..lineTo(cx - r * 0.14, bodyTop + tieH * 0.78)
      ..lineTo(cx - r * 0.10, bodyTop + tieH * 0.52)
      ..close();
    canvas.drawPath(tiePath, Paint()..color = const Color(0xFF8B0000));
  }

  // ── Generic boss (loanShark, gambler, taxEvader) ──────────────────────────

  void _drawGenericBoss(Canvas canvas, Size size, double cx, double cy,
      double r, Color bodyColor) {
    final paint = Paint()..isAntiAlias = true;

    // Head
    paint.color = const Color(0xFFD4956B);
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // Eyes
    paint
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.30, cy - r * 0.05), r * 0.09, paint);
    canvas.drawCircle(Offset(cx + r * 0.30, cy - r * 0.05), r * 0.09, paint);

    // Stern mouth
    paint
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - r * 0.22, cy + r * 0.30),
      Offset(cx + r * 0.22, cy + r * 0.30),
      paint,
    );

    // Body
    paint
      ..color = bodyColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromLTRBR(
          cx - r * 0.70, cy + r, cx + r * 0.70, size.height * 0.92,
          const Radius.circular(8)),
      paint,
    );
  }

  @override
  bool shouldRepaint(BossCharacterPainter old) => old.bossType != bossType;
}
