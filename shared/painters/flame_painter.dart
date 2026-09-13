/// flame_painter.dart
///
/// Draws a stylised organic flame silhouette using cubic Bézier curves. An
/// optional inner highlight adds depth. Designed to replace a plain fire
/// emoji with a hand-crafted illustration in the daily challenge card.
///
/// Expected size: 28×36 px (portrait). The painter uses normalised
/// proportions and scales to any canvas size.
/// Suggested use: inside a SizedBox with the desired pixel dimensions.
library;

import 'package:flutter/material.dart';

/// [FlamePainter] draws a flame shape in [color], with an optional inner
/// highlight layer in [innerColor] for a warm, glowing appearance.
class FlamePainter extends CustomPainter {
  const FlamePainter({required this.color, this.innerColor});

  /// Primary flame body colour.
  final Color color;

  /// Optional inner highlight colour (slightly lighter / more transparent).
  final Color? innerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Outer flame body
    final outer = Path()
      ..moveTo(w * 0.50, h * 1.00)
      ..cubicTo(w * 0.10, h * 0.76, w * 0.04, h * 0.50, w * 0.28, h * 0.36)
      ..cubicTo(w * 0.18, h * 0.60, w * 0.36, h * 0.56, w * 0.38, h * 0.32)
      ..cubicTo(w * 0.40, h * 0.16, w * 0.50, h * 0.00, w * 0.55, h * 0.14)
      ..cubicTo(w * 0.60, h * 0.00, w * 0.72, h * 0.10, w * 0.66, h * 0.30)
      ..cubicTo(w * 0.62, h * 0.50, w * 0.82, h * 0.58, w * 0.72, h * 0.36)
      ..cubicTo(w * 0.96, h * 0.50, w * 0.92, h * 0.76, w * 0.50, h * 1.00)
      ..close();

    canvas.drawPath(outer, Paint()..color = color..style = PaintingStyle.fill);

    // Inner highlight (optional)
    if (innerColor != null) {
      final inner = Path()
        ..moveTo(w * 0.50, h * 0.90)
        ..cubicTo(w * 0.28, h * 0.76, w * 0.30, h * 0.60, w * 0.44, h * 0.52)
        ..cubicTo(w * 0.40, h * 0.62, w * 0.50, h * 0.60, w * 0.50, h * 0.46)
        ..cubicTo(w * 0.52, h * 0.58, w * 0.62, h * 0.58, w * 0.56, h * 0.52)
        ..cubicTo(w * 0.72, h * 0.60, w * 0.72, h * 0.76, w * 0.50, h * 0.90)
        ..close();

      canvas.drawPath(
        inner,
        Paint()..color = innerColor!..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FlamePainter old) =>
      old.color != color || old.innerColor != innerColor;
}
