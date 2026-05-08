/// kwacha_icon_painter.dart
///
/// Contains four stroke-style icon painters used in the stat cards and
/// business showcase cards. All painters draw with warm gold strokes and
/// no fill, giving a light, hand-crafted feel.
///
/// Painters in this file:
///   • [KwachaIconPainter]  — stylised K (Zambian Kwacha currency symbol)
///   • [PiggyBankPainter]   — outline piggy bank, for the Savings stat card
///   • [StarRosettePainter] — 8-pointed star rosette, for the Badges stat card
///   • [StorefrontPainter]  — simple shop-front with awning, for business cards
///
/// Expected size for all painters: 28×28 px (square). They scale
/// proportionally to any square canvas via normalised coordinates.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KwachaIconPainter
// ─────────────────────────────────────────────────────────────────────────────

/// [KwachaIconPainter] draws a stylised Zambian Kwacha 'K' symbol with a
/// characteristic double horizontal bar crossing the diagonal strokes.
class KwachaIconPainter extends CustomPainter {
  const KwachaIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = color
      ..strokeWidth = w * 0.13
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Vertical stem
    canvas.drawLine(Offset(w * 0.24, h * 0.10), Offset(w * 0.24, h * 0.90), stroke);

    // Upper diagonal
    canvas.drawLine(Offset(w * 0.24, h * 0.50), Offset(w * 0.82, h * 0.10), stroke);

    // Lower diagonal
    canvas.drawLine(Offset(w * 0.24, h * 0.50), Offset(w * 0.82, h * 0.90), stroke);

    // Double horizontal bar (Kwacha diacritic)
    final thin = Paint()
      ..color = color
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(w * 0.16, h * 0.40), Offset(w * 0.66, h * 0.40), thin);
    canvas.drawLine(Offset(w * 0.16, h * 0.54), Offset(w * 0.66, h * 0.54), thin);
  }

  @override
  bool shouldRepaint(covariant KwachaIconPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// PiggyBankPainter
// ─────────────────────────────────────────────────────────────────────────────

/// [PiggyBankPainter] draws a stroke-style piggy bank icon: an oval body,
/// a circular head with a small snout, a coin slot on top, and four short legs.
class PiggyBankPainter extends CustomPainter {
  const PiggyBankPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = color
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Body — oval
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.42, h * 0.56),
        width: w * 0.64,
        height: h * 0.52,
      ),
      stroke,
    );

    // Head — circle
    canvas.drawCircle(Offset(w * 0.78, h * 0.46), w * 0.18, stroke);

    // Snout — small oval
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.93, h * 0.48),
        width: w * 0.14,
        height: h * 0.10,
      ),
      stroke,
    );

    // Coin slot — short horizontal line on top of body
    canvas.drawLine(
      Offset(w * 0.35, h * 0.29),
      Offset(w * 0.50, h * 0.29),
      stroke,
    );

    // Four legs — short vertical strokes at the base
    for (final lx in [0.18, 0.30, 0.42, 0.54]) {
      canvas.drawLine(
        Offset(w * lx, h * 0.80),
        Offset(w * lx, h * 0.96),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PiggyBankPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// StarRosettePainter
// ─────────────────────────────────────────────────────────────────────────────

/// [StarRosettePainter] draws an 8-pointed star rosette using alternating
/// outer and inner radii. Used as the badge/achievement stat-card icon.
class StarRosettePainter extends CustomPainter {
  const StarRosettePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width * 0.44;
    final innerR = size.width * 0.20;
    const points = 8;

    final stroke = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.09
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = i * math.pi / points - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant StarRosettePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// StorefrontPainter
// ─────────────────────────────────────────────────────────────────────────────

/// [StorefrontPainter] draws a minimal shop-front icon: a rectangular
/// building body with a trapezoidal awning and a centred door. Used in the
/// business-showcase cards on the Level screen.
class StorefrontPainter extends CustomPainter {
  const StorefrontPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = color
      ..strokeWidth = w * 0.09
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

    // Door — rounded rectangle centred at the bottom
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.38, h * 0.62, w * 0.24, h * 0.30),
        Radius.circular(w * 0.04),
      ),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant StorefrontPainter old) => old.color != color;
}
