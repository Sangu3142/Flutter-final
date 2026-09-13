import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class FlipCardWidget extends StatefulWidget {
  final String frontText;
  final String backText;
  final String cardId;
  final bool isFlipped;
  final bool isMatched;
  final VoidCallback onTap;

  const FlipCardWidget({
    super.key,
    required this.frontText,
    required this.backText,
    required this.cardId,
    required this.isFlipped,
    required this.isMatched,
    required this.onTap,
  });

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _anim = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.isFlipped || widget.isMatched) _ctrl.forward();
  }

  @override
  void didUpdateWidget(FlipCardWidget old) {
    super.didUpdateWidget(old);
    if ((widget.isFlipped || widget.isMatched) && !_ctrl.isCompleted) {
      _ctrl.forward();
    } else if (!widget.isFlipped && !widget.isMatched && _ctrl.isCompleted) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isMatched ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final isFront = _anim.value < pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_anim.value),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: widget.isMatched
                    ? kGreen.withValues(alpha: 0.2)
                    : isFront
                        ? kDeepNavy
                        : kNeonMint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isMatched
                      ? kGreen
                      : isFront
                          ? kCharcoalLight.withValues(alpha: 0.3)
                          : kNeonMint,
                ),
              ),
              child: Center(
                child: isFront
                    ? const Icon(Icons.help_outline,
                        color: kCharcoalLight, size: 28)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            widget.backText,
                            style: const TextStyle(
                              color: kCharcoal,
                              fontSize: 9,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
