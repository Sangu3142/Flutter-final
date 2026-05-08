/// sparkle_overlay.dart
/// Purpose: Reusable sparkle particle effect. Wraps any widget and exposes a
///          trigger() method that fires 14 particles shooting outward from the
///          widget centre, colour-shifting from kNeonMint → kPrimaryBlue as they
///          travel outward, fading to transparent at 70px. Duration 1400ms.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

const Color _kNeonMint    = Color(0xFF36ECDE);
const Color _kPrimaryBlue = Color(0xFF1A73E8);

/// Wraps [child] and can be triggered via [SparkleOverlayState.trigger] to
/// animate 14 sparkle particles shooting outward from the widget's centre.
///
/// Access the state via a [GlobalKey<SparkleOverlayState>] and call trigger().
class SparkleOverlay extends StatefulWidget {
  const SparkleOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<SparkleOverlay> createState() => SparkleOverlayState();
}

class SparkleOverlayState extends State<SparkleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _travel;
  late final Animation<double> _fade;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _travel = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuart);
    _fade   = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _active = false);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Fires the sparkle animation from the centre of the wrapped widget.
  void trigger() {
    if (!mounted) return;
    setState(() => _active = true);
    _ctrl.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (_active)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => CustomPaint(
                  painter: _SparklePainter(
                    travel: _travel.value,
                    fade:   _fade.value,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.travel, required this.fade});

  final double travel;
  final double fade;

  static const int    _count     = 14;
  static const double _maxRadius = 70.0;
  static const double _dotRadius = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center  = Offset(size.width / 2, size.height / 2);
    final opacity = (1.0 - fade).clamp(0.0, 1.0);
    // Colour shifts from kNeonMint (travel=0) → kPrimaryBlue (travel=1).
    final color   = Color.lerp(_kNeonMint, _kPrimaryBlue, travel)!
        .withValues(alpha: opacity);
    final paint   = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    for (int i = 0; i < _count; i++) {
      final angle = (i / _count) * 2 * math.pi;
      final dist  = travel * _maxRadius;
      final pos   = Offset(
        center.dx + math.cos(angle) * dist,
        center.dy + math.sin(angle) * dist,
      );
      canvas.drawCircle(pos, _dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter old) =>
      old.travel != travel || old.fade != fade;
}
