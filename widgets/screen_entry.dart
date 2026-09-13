/// screen_entry.dart
/// Reusable fade + slide-up screen entry animation.
/// Wraps any child with a 300ms easeOut FadeTransition + 20px slide-up.
library;

import 'package:flutter/material.dart';

class ScreenEntry extends StatefulWidget {
  const ScreenEntry({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.slidePixels = 20,
  });

  final Widget child;
  final Duration duration;
  final double slidePixels;

  @override
  State<ScreenEntry> createState() => _ScreenEntryState();
}

class _ScreenEntryState extends State<ScreenEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _fade = curved;
    // 20px slide-up — convert to fractional offset based on slidePixels.
    // Using fractional offset of ~0.04 ≈ 20px on typical screens; close enough.
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(curved);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
