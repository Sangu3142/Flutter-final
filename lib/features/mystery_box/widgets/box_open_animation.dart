import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

/// 4-stage mystery box opening animation.
/// Call [play()] to start. [onComplete] fires when animation is done.
class BoxOpenAnimation extends StatefulWidget {
  final String lootLabel;
  final String rarityTier;
  final VoidCallback onComplete;

  const BoxOpenAnimation({
    super.key,
    required this.lootLabel,
    required this.rarityTier,
    required this.onComplete,
  });

  @override
  State<BoxOpenAnimation> createState() => BoxOpenAnimationState();
}

class BoxOpenAnimationState extends State<BoxOpenAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _shakeCtrl;
  late final AnimationController _glowCtrl;
  late final ConfettiController _confettiCtrl;

  bool _revealed = false;
  double _glowSize = 0;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));
    _glowCtrl.addListener(() {
      if (mounted) setState(() => _glowSize = _glowCtrl.value * 32);
    });
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _glowCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  Future<void> play() async {
    // Stage 1: Shake
    await _shakeCtrl.forward();
    _shakeCtrl.reset();

    // Stage 2: Glow expand
    await _glowCtrl.forward();

    // Stage 3: Confetti burst
    _confettiCtrl.play();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Stage 4: Reveal card
    setState(() => _revealed = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    widget.onComplete();
  }

  Color get _rarityColor {
    switch (widget.rarityTier) {
      case 'rare':
        return const Color(0xFF2980B9);
      case 'epic':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shakeAnim = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        ConfettiWidget(
          confettiController: _confettiCtrl,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: 0.05,
          numberOfParticles: 20,
          gravity: 0.3,
          colors: [_rarityColor, Colors.white, const Color(0xFFFFD700)],
        ),
        AnimatedBuilder(
          animation: _shakeCtrl,
          builder: (_, child) => Transform.rotate(
            angle: shakeAnim.value,
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _rarityColor.withValues(alpha: 0.7),
                  blurRadius: _glowSize,
                  spreadRadius: _glowSize / 4,
                ),
              ],
            ),
            child: const Center(
              child: Text('🎁', style: TextStyle(fontSize: 56)),
            ),
          ),
        ),
        if (_revealed)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (_, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: _rarityColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.rarityTier.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.lootLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
