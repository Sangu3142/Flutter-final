/// level_node.dart
/// Purpose: Reusable level map node widget — displays a neighbourhood's name,
///          emoji, lock/unlock/complete state, price badge, and XP reward.
///          Tappable with a minimum touch target of 48×48dp.
/// Reads from: LevelMeta (constants), LevelModel (state)
/// Writes to: nothing (tap callback delegates to caller)
/// Navigation: none (caller handles routing on onTap)
library;

import 'package:flutter/material.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/levels/models/level_model.dart';

/// [LevelNode] is the visual tile for a single level on the Level Map screen.
///
/// It is purely presentational — the [onTap] callback is responsible for
/// any navigation or state changes.
class LevelNode extends StatelessWidget {
  const LevelNode({
    super.key,
    required this.meta,
    required this.model,
    required this.onTap,
  });

  /// Static metadata for this level (name, price, emoji, etc.).
  final LevelMeta meta;

  /// Current runtime state of this level (LOCKED / UNLOCKED / etc.).
  /// Null means the level has not been seeded yet (shows loading state).
  final LevelModel? model;

  /// Called when the node is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Derive display properties from the current status
    final status = model?.status ?? kStatusLocked;
    final isLocked = status == kStatusLocked;
    final isCompleted = status == kStatusCompleted;
    final isInProgress = status == kStatusInProgress;

    // Choose colours and icons based on status
    final borderColor = switch (status) {
      kStatusCompleted => kGreen,
      kStatusInProgress => kCopper,
      kStatusUnlocked => kGreenLight,
      _ => kLocked,
    };

    final bgColor = switch (status) {
      kStatusCompleted => kGreen.withValues(alpha: 0.06),
      kStatusInProgress => kCopper.withValues(alpha: 0.06),
      kStatusUnlocked => Colors.white,
      _ => Colors.grey.shade100,
    };

    return GestureDetector(
      onTap: model == null ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // Minimum touch target: 48dp tall is guaranteed by padding
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isLocked ? 1 : 2),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: isLocked ? 0.06 : 0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Level Emoji Circle ────────────────────────────────────
            _emojiCircle(isLocked),

            const SizedBox(width: 14),

            // ── Level Info ────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + status icon row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meta.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isLocked ? kLocked : kCharcoal,
                                    fontWeight: FontWeight.w700,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _statusIcon(isLocked, isCompleted, isInProgress),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    meta.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isLocked ? kLocked : kCharcoalLight,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),

                  const SizedBox(height: 6),

                  // Price / XP chips row
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      // Price or FREE chip
                      _chip(
                        label: meta.isFree
                            ? '🆓 FREE'
                            : '💳 ZMW ${meta.price.toStringAsFixed(0)}',
                        color: meta.isFree ? kGreen : kCopper,
                      ),

                      // XP reward chip
                      _chip(
                        label: '⚡ ${meta.xpReward} XP',
                        color: kGold,
                        textColor: kCharcoal,
                      ),

                      // Simulation count
                      if (!isLocked)
                        _chip(
                          label:
                              '📋 ${model?.completedSimulations.length ?? 0}/${meta.simulations.length}',
                          color: kCharcoalLight,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Chevron / Lock ────────────────────────────────────────
            const SizedBox(width: 8),
            Icon(
              isLocked ? Icons.lock_outline : Icons.chevron_right,
              color: isLocked ? kLocked : borderColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ── Emoji Circle ──────────────────────────────────────────────────────────

  Widget _emojiCircle(bool isLocked) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade200 : kCopper.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: isLocked ? kLocked : kCopperLight.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          isLocked ? '🔒' : meta.emoji,
          style: TextStyle(fontSize: isLocked ? 22 : 26),
        ),
      ),
    );
  }

  // ── Status Icon ───────────────────────────────────────────────────────────

  Widget _statusIcon(bool isLocked, bool isCompleted, bool isInProgress) {
    if (isCompleted) {
      return const Icon(Icons.check_circle, color: kGreen, size: 20);
    }
    if (isInProgress) {
      return const Icon(Icons.timelapse, color: kCopper, size: 20);
    }
    if (!isLocked) {
      return const Icon(Icons.lock_open_outlined, color: kGreenLight, size: 20);
    }
    return const SizedBox.shrink();
  }

  // ── Chip ──────────────────────────────────────────────────────────────────

  Widget _chip({
    required String label,
    required Color color,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor ?? color,
        ),
      ),
    );
  }
}
