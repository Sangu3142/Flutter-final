/// zamcoin_badge.dart
/// Purpose: Reusable ZamCoin balance badge widget — a pill-shaped label
///          showing the gold coin emoji and the player's current ZamCoin
///          balance. Used in the app bar and dashboard header.
/// Reads from: nothing (pure presentational widget)
/// Writes to: nothing
/// Navigation: none
library;

import 'package:flutter/material.dart';
import 'package:zamwealth_quest/core/theme.dart';

/// [ZamCoinBadge] renders an inline coin balance indicator.
///
/// Example:
/// ```dart
/// ZamCoinBadge(coins: 250)
/// // renders: 🪙 250
/// ```
class ZamCoinBadge extends StatelessWidget {
  const ZamCoinBadge({
    super.key,
    required this.coins,
    this.large = false,
    this.background,
    this.textColor,
  });

  /// The number of ZamCoins to display.
  final int coins;

  /// When true, uses larger text and padding (for dashboard stat cards).
  final bool large;

  /// Override background colour. Defaults to a gold tint.
  final Color? background;

  /// Override text colour. Defaults to [kCharcoal].
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final bg = background ?? kGold.withValues(alpha: 0.15);
    final fg = textColor ?? kCharcoal;
    final fontSize = large ? 18.0 : 13.0;
    final emojiSize = large ? 22.0 : 16.0;
    final padding = large
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 5);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGold.withValues(alpha: 0.45), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🪙',
            style: TextStyle(fontSize: emojiSize),
          ),
          const SizedBox(width: 5),
          Text(
            _formatCoins(coins),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats large coin amounts with K suffix (e.g. 1500 → "1.5K").
  String _formatCoins(int amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }
}
