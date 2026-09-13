// lib/features/levels/widgets/zone_node_widget.dart
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';

class ZoneNodeWidget extends StatefulWidget {
  final int levelId;
  final String status; // kStatusLocked | kStatusUnlocked | kStatusInProgress | kStatusCompleted
  final String name;
  final String emoji;
  final VoidCallback onTap;
  final VoidCallback? onLockedTap;

  const ZoneNodeWidget({
    super.key,
    required this.levelId,
    required this.status,
    required this.name,
    required this.emoji,
    required this.onTap,
    this.onLockedTap,
  });

  @override
  State<ZoneNodeWidget> createState() => _ZoneNodeWidgetState();
}

class _ZoneNodeWidgetState extends State<ZoneNodeWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _shakeCtrl;
  late AnimationController _tapCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _shakeAnim;
  late Animation<double> _tapAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: _pulseDurationFor(widget.status),
    );
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 0), weight: 1),
    ]).animate(_shakeCtrl);

    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _tapAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(_tapCtrl);

    // Only active and locked nodes animate. Completed/unlocked stay static
    // to avoid wasting 60fps repaints on every node forever.
    if (_shouldPulse(widget.status)) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  static bool _shouldPulse(String status) =>
      status == kStatusInProgress || status == kStatusLocked;

  static Duration _pulseDurationFor(String status) =>
      status == kStatusLocked
          ? const Duration(milliseconds: 2000)
          : const Duration(milliseconds: 1500);

  @override
  void didUpdateWidget(ZoneNodeWidget old) {
    super.didUpdateWidget(old);
    if (old.status != widget.status) {
      _pulseCtrl.duration = _pulseDurationFor(widget.status);
      if (_shouldPulse(widget.status)) {
        if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
      } else {
        _pulseCtrl.stop();
        _pulseCtrl.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _shakeCtrl.dispose();
    _tapCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    final isLocked = widget.status == kStatusLocked;
    if (isLocked) {
      _shakeCtrl.forward(from: 0);
      widget.onLockedTap?.call();
      return;
    }
    await _tapCtrl.forward(from: 0);
    widget.onTap();
  }

  Color get _nodeColor {
    switch (widget.status) {
      case kStatusCompleted:
        return kGreen;
      case kStatusInProgress:
        return kNeonMint;
      case kStatusUnlocked:
        return kPrimaryBlue;
      default:
        return kCharcoalLight.withValues(alpha: 0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.status == kStatusLocked;
    final isActive = widget.status == kStatusInProgress;
    final isCompleted = widget.status == kStatusCompleted;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseCtrl, _shakeCtrl, _tapCtrl]),
        builder: (_, child) => Transform.translate(
          offset: Offset(_shakeAnim.value, 0),
          child: Transform.scale(
            scale: _tapAnim.value,
            child: isLocked
                // Locked: grey shimmer — opacity pulses 0.35 → 0.65
                ? Opacity(
                    opacity: 0.35 + _pulseAnim.value * 0.30, child: child)
                // Active: strong breathing scale 0.95 → 1.05
                : Transform.scale(
                    scale: isActive
                        ? 0.95 + _pulseAnim.value * 0.10
                        : 1.0 + _pulseAnim.value * 0.03,
                    child: child,
                  ),
          ),
        ),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _nodeColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: _nodeColor,
              width: isActive ? 3 : 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: kNeonMint.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 4,
                    )
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 28)),
              if (isLocked)
                const Positioned(
                  bottom: 4,
                  right: 4,
                  child: Icon(Icons.lock, size: 16, color: kCharcoalLight),
                ),
              if (isCompleted)
                const Positioned(
                  top: 2,
                  right: 2,
                  child: Text('⭐', style: TextStyle(fontSize: 14)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
