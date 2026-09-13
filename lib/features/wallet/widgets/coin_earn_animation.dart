// lib/features/wallet/widgets/coin_earn_animation.dart
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class CoinEarnAnimation extends StatefulWidget {
  final int amount;
  final VoidCallback? onComplete;

  const CoinEarnAnimation({
    super.key,
    required this.amount,
    this.onComplete,
  });

  static void show(BuildContext context, int amount) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: offset.dx + size.width / 2 - 40,
        top: offset.dy,
        child: IgnorePointer(
          child: CoinEarnAnimation(
            amount: amount,
            onComplete: () => entry.remove(),
          ),
        ),
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<CoinEarnAnimation> createState() => _CoinEarnAnimationState();
}

class _CoinEarnAnimationState extends State<CoinEarnAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _offsetAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    // SOUND_HOOK_COIN_EARN
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _offsetAnim = Tween<double>(begin: 0, end: -60).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _opacityAnim = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    _ctrl.forward().then((_) => widget.onComplete?.call());
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
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _offsetAnim.value),
        child: Opacity(
          opacity: _opacityAnim.value,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kGold.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+ZMW ${widget.amount}',
              style: const TextStyle(
                color: kCoreNavy,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
