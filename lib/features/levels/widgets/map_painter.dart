// lib/features/levels/widgets/map_painter.dart
import 'dart:ui' as ui show PathMetric;
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class MapPainter extends CustomPainter {
  final double pathProgress; // 0.0 - 1.0, how much of path to draw

  MapPainter({required this.pathProgress});

  // Cached per-size so we don't rebuild Path + metrics on every animation tick.
  static Size? _cachedSize;
  static Path? _cachedPath;
  static List<ui.PathMetric>? _cachedMetrics;
  static double _cachedTotalLength = 0;

  static void _ensurePathCache(Size size) {
    if (_cachedSize == size && _cachedPath != null) return;
    final nodes = _zonePositions(size);
    final p = Path();
    p.moveTo(nodes[0].dx, nodes[0].dy);
    p.cubicTo(
      nodes[0].dx + 80, nodes[0].dy - 80,
      nodes[1].dx - 80, nodes[1].dy + 80,
      nodes[1].dx, nodes[1].dy,
    );
    p.cubicTo(
      nodes[1].dx + 80, nodes[1].dy - 80,
      nodes[2].dx - 80, nodes[2].dy + 80,
      nodes[2].dx, nodes[2].dy,
    );
    p.cubicTo(
      nodes[2].dx + 60, nodes[2].dy - 60,
      nodes[3].dx - 60, nodes[3].dy + 60,
      nodes[3].dx, nodes[3].dy,
    );
    final metrics = p.computeMetrics().toList(growable: false);
    _cachedSize = size;
    _cachedPath = p;
    _cachedMetrics = metrics;
    _cachedTotalLength = metrics.fold<double>(0, (sum, m) => sum + m.length);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _ensurePathCache(size);
    _drawDotGrid(canvas, size);
    _drawPath(canvas, size);
  }

  void _drawDotGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kNeonMint.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  void _drawPath(Canvas canvas, Size size) {
    final fullPath = _cachedPath!;
    final metrics = _cachedMetrics!;
    final totalLength = _cachedTotalLength;

    final trackPaint = Paint()
      ..color = kDeepNavy.withValues(alpha: 0.6)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(fullPath, trackPaint);

    if (pathProgress > 0) {
      final progressLength = totalLength * pathProgress;

      final progressPaint = Paint()
        ..color = kNeonMint
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      double drawn = 0;
      for (final metric in metrics) {
        final remaining = progressLength - drawn;
        if (remaining <= 0) break;
        final extract = metric.extractPath(
            0, remaining.clamp(0, metric.length));
        canvas.drawPath(extract, progressPaint);
        drawn += metric.length;
      }
    }
  }

  static List<Offset> _zonePositions(Size size) {
    return [
      Offset(size.width * 0.35, size.height * 0.85), // Level 1 — Kabulonga
      Offset(size.width * 0.65, size.height * 0.60), // Level 2 — Woodlands
      Offset(size.width * 0.30, size.height * 0.35), // Level 3 — Levy
      Offset(size.width * 0.60, size.height * 0.10), // Level 4 — Mukuba
    ];
  }

  static List<Offset> zonePositions(Size size) => _zonePositions(size);

  @override
  bool shouldRepaint(MapPainter oldDelegate) =>
      oldDelegate.pathProgress != pathProgress;
}
