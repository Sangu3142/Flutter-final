/// kente_pattern_painter.dart
///
/// Draws a repeating geometric overlay inspired by kente-cloth weaving: two
/// sets of 45-degree diagonal hatching lines with small diamond accents at
/// regular grid points. The pattern tiles continuously across the full canvas.
///
/// Expected size: any — the pattern is infinite-tiling by design.
/// Suggested use: Positioned.fill inside a ClipRRect, using a [color] with
/// very low alpha (e.g. 0.07) so it reads as a subtle texture rather than
/// a loud graphic element.
library;

import 'package:flutter/material.dart';

/// [KentePatternPainter] renders a subtle diagonal-grid geometric pattern
/// reminiscent of traditional kente textile motifs.
class KentePatternPainter extends CustomPainter {
  const KentePatternPainter({required this.color});

  /// Stroke and fill colour. Apply low alpha at the call site for subtlety.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final diamondPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 28.0;

    // Diagonal lines: top-left → bottom-right (positive slope)
    for (double x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        linePaint,
      );
    }

    // Diagonal lines: top-right → bottom-left (negative slope)
    for (double x = 0; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        linePaint,
      );
    }

    // Small diamond accents at regular grid intersections
    for (double gx = 0; gx < size.width; gx += spacing) {
      for (double gy = 0; gy < size.height; gy += spacing) {
        const r = 3.0;
        final path = Path()
          ..moveTo(gx, gy - r)
          ..lineTo(gx + r, gy)
          ..lineTo(gx, gy + r)
          ..lineTo(gx - r, gy)
          ..close();
        canvas.drawPath(path, diamondPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant KentePatternPainter old) =>
      old.color != color;
}
