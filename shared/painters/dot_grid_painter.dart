/// dot_grid_painter.dart
///
/// Draws a repeating grid of tiny filled circles, providing a subtle tactile
/// dot-paper texture over dark backgrounds. The grid tiles across the entire
/// canvas with no clipping required.
///
/// For dark backgrounds pass white with very low alpha — e.g.
/// `DotGridPainter(color: Colors.white.withValues(alpha: 0.05))`.
///
/// Expected size: any — the grid adapts to any canvas dimensions.
library;

import 'package:flutter/material.dart';

/// Renders a regular grid of 1 px radius circles spaced 24 px apart on both
/// axes — a subtle texture effect that works best on dark backgrounds.
class DotGridPainter extends CustomPainter {
  const DotGridPainter({required this.color});

  /// Dot colour. Use white at very low alpha (e.g. 0.05) on dark surfaces.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    const radius = 1.0;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotGridPainter old) => old.color != color;
}
