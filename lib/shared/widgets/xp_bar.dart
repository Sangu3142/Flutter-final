/// xp_bar.dart
/// Purpose: Reusable animated XP / progress bar widget used on the Dashboard,
///          Level screen, and Profile screen to show progression within a rank
///          tier or level completion status.
/// Reads from: nothing (pure presentational widget)
/// Writes to: nothing
/// Navigation: none
library;

import 'package:flutter/material.dart';
import 'package:zamwealth_quest/core/theme.dart';

/// [XpBar] renders an animated linear progress indicator with optional
/// current/max labels displayed beneath the bar.
///
/// Usage:
/// ```dart
/// XpBar(progress: 0.6, currentXp: 120, maxXp: 200)
/// ```
class XpBar extends StatefulWidget {
  const XpBar({
    super.key,
    required this.progress,
    required this.currentXp,
    required this.maxXp,
    this.activeColor,
    this.trackColor,
    this.height = 10.0,
    this.showLabels = false,
    this.animationDuration = const Duration(milliseconds: 700),
  });

  /// Progress fraction between 0.0 and 1.0.
  final double progress;

  /// Current value shown on the left label (only when [showLabels] is true).
  final int currentXp;

  /// Maximum value shown on the right label (only when [showLabels] is true).
  final int maxXp;

  /// Fill colour for the active portion of the bar.
  /// Defaults to [kCopper].
  final Color? activeColor;

  /// Track colour for the inactive portion of the bar.
  /// Defaults to a translucent copper.
  final Color? trackColor;

  /// Height of the progress bar track in logical pixels.
  final double height;

  /// When true, renders "currentXp / maxXp" labels below the bar.
  final bool showLabels;

  /// Duration of the fill animation on first build.
  final Duration animationDuration;

  @override
  State<XpBar> createState() => _XpBarState();
}

class _XpBarState extends State<XpBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _animation = Tween<double>(begin: 0, end: widget.progress.clamp(0.0, 1.0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(XpBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate to the new progress value when the widget rebuilds
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.activeColor ?? kCopper;
    final track = widget.trackColor ?? active.withValues(alpha: 0.18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Animated bar ───────────────────────────────────────────────
        AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(widget.height / 2),
              child: Stack(
                children: [
                  // Track (background)
                  Container(
                    height: widget.height,
                    width: double.infinity,
                    color: track,
                  ),
                  // Fill (foreground)
                  FractionallySizedBox(
                    widthFactor: _animation.value,
                    child: Container(
                      height: widget.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            active.withValues(alpha: 0.85),
                            active,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(widget.height / 2),
                        boxShadow: [
                          BoxShadow(
                            color: active.withValues(alpha: 0.35),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // ── Optional labels ────────────────────────────────────────────
        if (widget.showLabels) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.currentXp} XP',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: active,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${widget.maxXp} XP',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: kCharcoalLight,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
