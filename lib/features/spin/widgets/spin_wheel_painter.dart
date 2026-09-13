// lib/features/spin/widgets/spin_wheel_painter.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';

class SpinWheelPainter extends CustomPainter {
  final double rotation; // radians

  static const List<Color> _segmentColors = [
    Color(0xFF36ECDE), // kNeonMint
    Color(0xFFFFB703), // kGold
    Color(0xFF1A73E8), // kPrimaryBlue
    Color(0xFF2BC48A), // kGreen
    Color(0xFFFF6B35),
    Color(0xFF9B59B6),
    Color(0xFFE74C3C),
    Color(0xFF3498DB),
  ];

  const SpinWheelPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const segmentCount = 8;
    const sweepAngle = 2 * pi / segmentCount;

    final borderPaint = Paint()
      ..color = kCharcoal.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < segmentCount; i++) {
      final startAngle = rotation + i * sweepAngle - pi / 2;
      final segPaint = Paint()
        ..color = _segmentColors[i % _segmentColors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 4),
        startAngle,
        sweepAngle,
        true,
        segPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 4),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      final labelAngle = startAngle + sweepAngle / 2;
      final labelRadius = radius * 0.65;
      final labelX = center.dx + labelRadius * cos(labelAngle);
      final labelY = center.dy + labelRadius * sin(labelAngle);

      final label = kWheelSegments[i]['label'] as String;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: i < 2 ? kCoreNavy : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(labelX, labelY);
      canvas.rotate(labelAngle + pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    canvas.drawCircle(center, 20, Paint()..color = kDeepNavy);
    canvas.drawCircle(
        center,
        20,
        Paint()
          ..color = kNeonMint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(SpinWheelPainter old) => old.rotation != rotation;
}
