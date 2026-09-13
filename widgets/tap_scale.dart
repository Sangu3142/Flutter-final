/// tap_scale.dart
/// TapScale is a GestureDetector wrapper that animates its child down to 0.96
/// while pressed (≈120ms) and back to 1.0 on release. Used to give every
/// interactive surface a satisfying tactile feel without writing the boilerplate
/// in every screen.
library;

import 'package:flutter/material.dart';

class TapScale extends StatefulWidget {
  const TapScale({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.96,
    this.duration = const Duration(milliseconds: 120),
    this.behavior = HitTestBehavior.opaque,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;
  final HitTestBehavior behavior;
  final bool enabled;

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (!widget.enabled) return;
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final disabled = !widget.enabled || widget.onTap == null;
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: disabled ? null : (_) => _setPressed(true),
      onTapCancel: disabled ? null : () => _setPressed(false),
      onTapUp: disabled ? null : (_) => _setPressed(false),
      onTap: disabled ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
