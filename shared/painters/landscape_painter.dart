/// landscape_painter.dart
///
/// Draws a simplified Zambian savanna landscape redrawn in blue and mint tones
/// to match the ZamWealth Quest dark fintech palette. Two acacia silhouettes
/// on the left in Primary Blue at 0.3 opacity, a round sun on the right in
/// Neon Mint at 0.2 opacity, and a ground strip in the silhouette colour.
///
/// Expected size: full-width, height ≈ 180–200 px. Proportions adapt to any
/// canvas dimensions via normalised coordinates.
library;

import 'package:flutter/material.dart';

/// [LandscapePainter] renders a minimal Zambian savanna silhouette in blue and
/// mint tones, designed to overlay a dark gradient header background.
class LandscapePainter extends CustomPainter {
  const LandscapePainter({
    /// Acacia tree silhouettes and ground strip — Primary Blue at opacity 0.3.
    this.color = const Color(0x4D1A73E8),
    /// Sun circle — Neon Mint at opacity 0.2.
    this.accentColor = const Color(0x3336ECDE),
  });

  final Color color;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final silhouettePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final horizonY = h * 0.64;

    // Ground strip — fills from horizon to bottom edge
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, w, h - horizonY),
      silhouettePaint,
    );

    // Sun — large circle top-right in Neon Mint
    canvas.drawCircle(Offset(w * 0.84, h * 0.28), h * 0.17, accentPaint);

    // Two acacia silhouettes, left side in Primary Blue
    _drawAcacia(canvas, silhouettePaint, w, h,
        cx: w * 0.11, groundY: horizonY, scale: 1.0);
    _drawAcacia(canvas, silhouettePaint, w, h,
        cx: w * 0.25, groundY: horizonY, scale: 0.75);
  }

  void _drawAcacia(
    Canvas canvas,
    Paint paint,
    double w,
    double h, {
    required double cx,
    required double groundY,
    required double scale,
  }) {
    final trunkH = h * 0.30 * scale;
    final trunkW = w * 0.016 * scale;

    // Trunk
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, groundY - trunkH / 2),
        width: trunkW,
        height: trunkH,
      ),
      paint,
    );

    // Flat acacia canopy — wide, shallow oval
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, groundY - trunkH - h * 0.05 * scale),
        width: w * 0.20 * scale,
        height: h * 0.11 * scale,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant LandscapePainter old) =>
      old.color != color || old.accentColor != accentColor;
}
