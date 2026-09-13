/// animated_gradient_background.dart
/// Purpose: Animated shifting gradient background for every screen in the app.
///          Breathes slowly through three dark-navy states — subtle depth, not
///          distraction. A dot-grid CustomPaint layer adds tactile texture.
/// Animation: 5000ms repeating with reverse; 3-state A→B→A colour sequence.
library;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State colours
// ─────────────────────────────────────────────────────────────────────────────

const Color _kStateATop    = Color(0xFF00203F); // kCoreNavy
const Color _kStateABottom = Color(0xFF0D1B2A); // kDeepNavy
const Color _kStateBTop    = Color(0xFF0D1B2A); // kDeepNavy
const Color _kStateBBottom = Color(0xFF011F2E); // slightly darker teal-navy

// ─────────────────────────────────────────────────────────────────────────────
// AnimatedGradientBackground
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [child] in a slowly-breathing gradient that cycles through three dark
/// states over 5 seconds, reversing infinitely. The shift is barely visible —
/// pure depth, not animation for animation's sake.
///
/// A dot-grid CustomPaint layer (tiny circles at 0.03 opacity, 26 px spacing)
/// sits between the gradient and the content to add tactile texture.
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        // 3-state interpolation: A (t=0) → B (t=0.5) → A (t=1.0)
        // Combined with repeat(reverse:true) this creates a perfectly smooth
        // and continuous loop through all three states.
        final t = _ctrl.value;
        final Color topColor;
        final Color bottomColor;

        if (t < 0.5) {
          final s = t * 2.0;
          topColor    = Color.lerp(_kStateATop,    _kStateBTop,    s)!;
          bottomColor = Color.lerp(_kStateABottom, _kStateBBottom, s)!;
        } else {
          final s = (t - 0.5) * 2.0;
          topColor    = Color.lerp(_kStateBTop,    _kStateATop,    s)!;
          bottomColor = Color.lerp(_kStateBBottom, _kStateABottom, s)!;
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [topColor, bottomColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: CustomPaint(
            painter: const _DotGridPainter(),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dot Grid Painter
// ─────────────────────────────────────────────────────────────────────────────

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    const spacing = 26.0;
    const radius  = 1.2;

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter old) => false;
}
