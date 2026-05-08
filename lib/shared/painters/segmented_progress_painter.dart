/// segmented_progress_painter.dart
///
/// Draws a custom segmented progress bar divided into [totalSegments] equal
/// pill-shaped segments separated by small gaps. Completed segments are filled
/// with a Fresh Green gradient; incomplete segments use a white at 0.1 opacity.
/// The Core Navy divider between segments keeps it crisp on dark backgrounds.
///
/// Expected size: any width, height ≈ 18–24 px for best legibility.
library;

import 'package:flutter/material.dart';

/// Renders [totalSegments] pill segments, of which [completedSegments] are
/// visually filled using [activeColor] (defaults to Fresh Green #2BC48A).
class SegmentedProgressPainter extends CustomPainter {
  const SegmentedProgressPainter({
    required this.completedSegments,
    required this.totalSegments,
    this.activeColor = const Color(0xFF2BC48A),
    this.borderColor = const Color(0xFF2BC48A),
    this.emptyColor = const Color(0x1AFFFFFF),
    this.dividerColor = const Color(0xFF00203F),
  });

  final int completedSegments;
  final int totalSegments;

  /// Fill colour for completed segments — defaults to Fresh Green.
  final Color activeColor;

  /// Stroke colour for completed segment borders — defaults to Fresh Green.
  final Color borderColor;

  /// Fill colour for incomplete segments — defaults to white at 10% opacity.
  final Color emptyColor;

  /// Colour of the small gap/divider between segments — defaults to Core Navy.
  final Color dividerColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (totalSegments <= 0) return;

    const gap = 6.0;
    final radius = size.height / 2;
    final segW = (size.width - gap * (totalSegments - 1)) / totalSegments;

    for (int i = 0; i < totalSegments; i++) {
      final left = i * (segW + gap);
      final rect = Rect.fromLTWH(left, 0, segW, size.height);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

      final filled = i < completedSegments;

      if (filled) {
        // Gradient fill from Fresh Green to a slightly lighter shade
        final fillPaint = Paint()
          ..shader = LinearGradient(
            colors: [activeColor, activeColor.withValues(alpha: 0.75)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(rect)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(rrect, fillPaint);
      } else {
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = emptyColor
            ..style = PaintingStyle.fill,
        );
      }

      // Subtle border
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = filled
              ? borderColor.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.06)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SegmentedProgressPainter old) =>
      old.completedSegments != completedSegments ||
      old.totalSegments != totalSegments ||
      old.activeColor != activeColor;
}
