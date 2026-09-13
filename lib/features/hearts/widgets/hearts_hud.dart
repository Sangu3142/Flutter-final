// lib/features/hearts/widgets/hearts_hud.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hearts_provider.dart';
import '../../../core/constants.dart';

/// HeartsHUD
/// - Shakes + brief red flash when a heart is lost.
/// - Bounces in newly-restored hearts.
/// - Pulses the last remaining heart when count is at/below 1 (low warning).
class HeartsHUD extends ConsumerStatefulWidget {
  const HeartsHUD({super.key});

  @override
  ConsumerState<HeartsHUD> createState() => _HeartsHUDState();
}

class _HeartsHUDState extends ConsumerState<HeartsHUD>
    with TickerProviderStateMixin {
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  late final AnimationController _flashCtrl;
  late final Animation<double> _flashAnim;

  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  int? _prevHearts;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeOut));

    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashAnim = CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut);

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _bounceAnim = CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _flashCtrl.dispose();
    _bounceCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _updatePulse(int hearts) {
    final shouldPulse = hearts > 0 && hearts <= 1;
    if (shouldPulse && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!shouldPulse && _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
      _pulseCtrl.value = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hearts = ref.watch(heartsProvider);
    final count = hearts.heartsCount;

    final prev = _prevHearts;
    if (prev != null && prev != count) {
      if (count < prev) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _shakeCtrl.forward(from: 0);
          _flashCtrl.forward(from: 0).then((_) {
            if (mounted) _flashCtrl.reverse();
          });
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _bounceCtrl.forward(from: 0);
        });
      }
    }
    _prevHearts = count;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updatePulse(count);
    });

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_shakeAnim, _flashAnim, _bounceAnim, _pulseAnim]),
        builder: (context, _) {
          return Transform.translate(
            offset: Offset(_shakeAnim.value, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(kMaxHearts, (i) {
                final filled = i < count;
                final isLastFilled = filled && i == count - 1;
                final isJustRestored =
                    filled && prev != null && count > prev && i == count - 1;

                // Scale for: pulse (low), bounce (restored)
                double scale = 1.0;
                if (isLastFilled && count <= 1) {
                  scale = _pulseAnim.value;
                }
                if (isJustRestored && _bounceCtrl.isAnimating) {
                  // Elastic out from 0 -> 1 added on top
                  scale = scale * (0.3 + 0.7 * _bounceAnim.value);
                }

                final baseColor = filled
                    ? Color.lerp(
                        Colors.red,
                        Colors.redAccent.shade100,
                        _flashAnim.value,
                      )!
                    : Colors.red.withValues(alpha: 0.3);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.scale(
                    scale: scale,
                    child: Icon(
                      filled ? Icons.favorite : Icons.favorite_border,
                      color: baseColor,
                      size: 20,
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
