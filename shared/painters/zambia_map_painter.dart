/// zambia_map_painter.dart
///
/// Draws a simplified silhouette of Zambia's country border as a filled
/// polygon watermark. The polygon is scaled proportionally to fill the
/// entire canvas, so the caller controls the displayed size via a SizedBox
/// or Positioned constraint.
///
/// Expected size: any — the polygon normalises to [0,1] and scales to fit.
/// Suggested use: place inside a Stack with a low-opacity Color applied to
/// the [color] parameter (e.g. alpha 0.08) for a subtle watermark effect.
library;

import 'package:flutter/material.dart';

/// [ZambiaMapPainter] renders a single-colour fill of the Zambia border
/// outline, scaled to the canvas. Designed for use as a decorative watermark.
class ZambiaMapPainter extends CustomPainter {
  const ZambiaMapPainter({required this.color});

  /// Fill colour — apply low alpha (e.g. 0.08) at the call site for watermark.
  final Color color;

  // Normalised polygon approximating Zambia's border, clockwise from NW.
  static const List<Offset> _pts = [
    Offset(0.18, 0.00),
    Offset(0.28, 0.02),
    Offset(0.36, 0.00),
    Offset(0.50, 0.05),
    Offset(0.60, 0.00),
    Offset(0.70, 0.06),
    Offset(0.78, 0.18),
    Offset(0.88, 0.30),
    Offset(0.96, 0.44),
    Offset(0.92, 0.58),
    Offset(0.82, 0.70),
    Offset(0.72, 0.82),
    Offset(0.60, 0.90),
    Offset(0.48, 0.96),
    Offset(0.36, 0.90),
    Offset(0.26, 0.80),
    Offset(0.18, 0.68),
    Offset(0.05, 0.62),
    Offset(0.02, 0.46),
    Offset(0.08, 0.28),
    Offset(0.14, 0.12),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final first = Offset(_pts[0].dx * size.width, _pts[0].dy * size.height);
    path.moveTo(first.dx, first.dy);
    for (int i = 1; i < _pts.length; i++) {
      path.lineTo(_pts[i].dx * size.width, _pts[i].dy * size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ZambiaMapPainter old) => old.color != color;
}
