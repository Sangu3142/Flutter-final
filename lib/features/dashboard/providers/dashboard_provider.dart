/// dashboard_provider.dart
/// Purpose: Provides computed dashboard state — XP progress, rank badge,
///          streak status, and badge count — derived from the current user.
/// Reads from: authProvider (UserProfile), levelProvider (level completion)
/// Writes to: nothing (read-only computed state)
/// Navigation: none
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/auth/models/user_profile.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard State
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable snapshot of all values shown on the Dashboard screen.
class DashboardState {
  const DashboardState({
    required this.user,
    required this.rankLabel,
    required this.xpInCurrentRank,
    required this.xpForNextRank,
    required this.xpToNextRankLabel,
    required this.progressPercent,
    required this.isStreakActive,
  });

  /// The current [UserProfile].
  final UserProfile user;

  /// Human-readable rank label (e.g. 'Copper Investor').
  final String rankLabel;

  /// XP earned within the current rank tier.
  final int xpInCurrentRank;

  /// XP required to complete the current rank tier.
  final int xpForNextRank;

  /// Remaining XP to reach the next rank (shown as "X XP to next rank").
  final int xpToNextRankLabel;

  /// Progress fraction 0.0–1.0 within the current rank tier.
  final double progressPercent;

  /// True if the player logged in on consecutive days.
  final bool isStreakActive;

  /// Short-hand accessors
  String get name => user.name;
  int get xp => user.xp;
  int get zamCoins => user.zamCoins;
  int get streak => user.streak;
  int get currentLevel => user.currentLevel;
  int get badgeCount => user.earnedBadges.length;
  double get totalSavingsZMW => user.totalSavingsZMW;
  List<String> get badges => user.earnedBadges;
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the [DashboardState] computed from the current user.
/// Returns null if no user is authenticated.
final dashboardProvider = Provider<DashboardState?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final xp = user.xp;
  final rank = xpRankLabel(xp);
  final rankStart = xpCurrentRankStart(xp);
  final remaining = xpToNextRank(xp);

  // Determine the size of the current rank tier
  final thresholdIndex = kXpThresholds.indexWhere((t) => xp < t);
  final int tierSize;

  if (thresholdIndex <= 0) {
    // Either at the first threshold or past the last one
    tierSize = thresholdIndex == 0
        ? kXpThresholds[0]
        : kXpThresholds.last - kXpThresholds[kXpThresholds.length - 2];
  } else {
    tierSize = kXpThresholds[thresholdIndex] - rankStart;
  }

  final xpInTier = xp - rankStart;
  final progress = tierSize > 0 ? (xpInTier / tierSize).clamp(0.0, 1.0) : 1.0;

  // Streak is "active" if the user last logged in today or yesterday
  final daysSinceActive = DateTime.now().difference(user.lastActive).inDays;
  final streakActive = daysSinceActive <= 1;

  return DashboardState(
    user: user,
    rankLabel: rank,
    xpInCurrentRank: xpInTier,
    xpForNextRank: tierSize,
    xpToNextRankLabel: remaining,
    progressPercent: progress,
    isStreakActive: streakActive,
  );
});
