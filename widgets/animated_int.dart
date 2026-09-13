/// animated_int.dart
/// AnimatedInt counts from the previous integer to the current one over
/// 600ms with easeOutCubic. Mirrors the _AnimatedBalance pattern used by
/// the wallet badge so family/business stats animate consistently.
library;

import 'package:flutter/material.dart';

class AnimatedInt extends StatefulWidget {
  const AnimatedInt({
    super.key,
    required this.value,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.textAlign,
  });

  final int value;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final Curve curve;
  final TextAlign? textAlign;

  @override
  State<AnimatedInt> createState() => _AnimatedIntState();
}

class _AnimatedIntState extends State<AnimatedInt> {
  late int _previous;

  @override
  void initState() {
    super.initState();
    _previous = widget.value;
  }

  @override
  void didUpdateWidget(AnimatedInt old) {
    super.didUpdateWidget(old);
    _previous = old.value;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: _previous.toDouble(),
        end: widget.value.toDouble(),
      ),
      duration: widget.duration,
      curve: widget.curve,
      builder: (_, value, __) => Text(
        '${widget.prefix}${value.round()}${widget.suffix}',
        style: widget.style,
        textAlign: widget.textAlign,
      ),
    );
  }
}
