/// shop_front_painter.dart
///
/// Draws a minimal shop-front icon in Neon Mint outline style: a rectangular
/// building body with a trapezoidal awning and a centred door. Used in the
/// business-showcase horizontal scroll cards on the Level screen.
///
/// Expected size: 36×36 px (square). Scales proportionally via normalised
/// coordinates to any square canvas.
library;

import 'package:flutter/material.dart';

/// [ShopFrontPainter] draws a stroke-style shop-front icon in Neon Mint.
/// The Neon Mint outline gives it a techy, game-HUD aesthetic consistent with
/// the ZamWealth Quest dark fintech palette.
class ShopFrontPainter extends CustomPainter {
  const ShopFrontPainter({
    this.color = const Color(0xFF36ECDE),
  });

  /// Stroke colour — defaults to Neon Mint #36ECDE.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = color
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Building body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.36, w * 0.80, h * 0.56),
        Radius.circular(w * 0.06),
      ),
      stroke,
    );

    // Awning — trapezoid above the building body
    final awning = Path()
      ..moveTo(w * 0.04, h * 0.36)
      ..lineTo(w * 0.96, h * 0.36)
      ..lineTo(w * 0.84, h * 0.20)
      ..lineTo(w * 0.16, h * 0.20)
      ..close();
    canvas.drawPath(awning, stroke);

    // Door — rounded rectangle centred at the bottom of the building
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.38, h * 0.62, w * 0.24, h * 0.30),
        Radius.circular(w * 0.04),
      ),
      stroke,
    );

    // Window — small square on the left side of the building
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.16, h * 0.46, w * 0.18, h * 0.16),
        Radius.circular(w * 0.02),
      ),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant ShopFrontPainter old) => old.color != color;
}
