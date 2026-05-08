/// baobab_painter.dart
///
/// Draws a stylised baobab tree silhouette: a large rounded canopy sitting
/// atop a wide, slightly tapered trunk. Designed to be recognisable at small
/// sizes (48×48 px) but scales to any square canvas proportionally.
///
/// Expected size: 48×48 px (square). The painter uses normalised coordinates
/// so the output scales to whatever SizedBox contains it.
/// Suggested use: as a decorative illustration in level or stat cards.
library;

import 'package:flutter/material.dart';

/// [BaobabPainter] draws a minimal baobab tree icon in a single fill colour,
/// evoking the iconic African savanna tree.
class BaobabPainter extends CustomPainter {
  const BaobabPainter({required this.color});

  /// Fill colour for both the canopy and trunk.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Trunk — slightly wider at the base (trapezoid shape)
    final trunk = Path()
      ..moveTo(w * 0.40, h * 0.52)
      ..lineTo(w * 0.32, h * 1.00)
      ..lineTo(w * 0.68, h * 1.00)
      ..lineTo(w * 0.60, h * 0.52)
      ..close();
    canvas.drawPath(trunk, paint);

    // Canopy — large oval sitting on top of the trunk
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.30),
        width: w * 0.88,
        height: h * 0.58,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant BaobabPainter old) => old.color != color;
}
