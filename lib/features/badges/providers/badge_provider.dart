/// badge_provider.dart
/// Purpose: Provides badgeMapProvider (earned status for all badges) and
///          BadgeService (central service for checking and awarding badges).
/// Reads from: authProvider (current user)
/// Writes to: UserProfile.earnedBadges (via user.awardBadge)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/auth/models/user_profile.dart';
import 'package:zamwealth_quest/features/badges/models/badge_model.dart';
import 'package:zamwealth_quest/features/badges/widgets/badge_unlock_toast.dart';

/// Watches the current user's earnedBadges list.
/// Returns a Map<String, bool> — badgeId → earned.
final badgeMapProvider = Provider<Map<String, bool>>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.currentUser;
  if (user == null) return {};
  final earned = user.earnedBadges.toSet();
  return {for (final b in kAllBadges) b.id: earned.contains(b.id)};
});

/// Central service for awarding badges. Inject this where needed.
final badgeServiceProvider = Provider<BadgeService>((ref) {
  return BadgeService(ref);
});

class BadgeService {
  final Ref _ref;
  BadgeService(this._ref);

  /// Call this after EVERY simulation completion and after any XP change.
  void checkAndAward({
    String? completedSimId,
    int? newXp,
    int? newStreak,
    bool taxQuizPerfect = false,
    Set<String>? completedSimIds,
    int? completedLevelNumber,
    BuildContext? context,
  }) {
    final user = _ref.read(authProvider).currentUser;
    if (user == null) return;

    // ── Onboarding ──────────────────────────────────────────────────────────
    // first_login is awarded directly in AuthNotifier.register() — skip here.
    if (completedSimId == 'onboarding') _award(user, 'onboarding_complete', context);

    // ── Simulation specific ─────────────────────────────────────────────────
    if (completedSimId == 'budget_allocator')    _award(user, 'budget_done', context);
    if (completedSimId == 'emergency_fund')      _award(user, 'savings_emergency', context);
    if (completedSimId == 'debt_manager')        _award(user, 'debt_done', context);
    if (completedSimId == 'investment_simulator') _award(user, 'investment_lusaka_se', context);
    if (completedSimId == 'pacra_registration')  _award(user, 'pacra_done', context);
    if (completedSimId == 'payroll_simulator')   _award(user, 'payroll_done', context);
    if (taxQuizPerfect)                          _award(user, 'tax_wizard', context);

    // ── Multi-mode badges ────────────────────────────────────────────────────
    if (completedSimIds != null) {
      const savingsModes = {'savings_emergency', 'savings_school', 'savings_house', 'savings_wedding'};
      if (savingsModes.every(completedSimIds.contains)) _award(user, 'savings_all_modes', context);

      const investModes = {'investment_luse', 'investment_tbill', 'investment_pension'};
      if (investModes.every(completedSimIds.contains)) _award(user, 'investment_all_modes', context);

      const bizModes = {'pacra_registration', 'revenue_profit', 'payroll_simulator', 'tax_quiz'};
      if (bizModes.every(completedSimIds.contains)) _award(user, 'business_all_modes', context);
    }

    // ── Level milestones ─────────────────────────────────────────────────────
    if (completedLevelNumber == 1) _award(user, 'level_1_done', context);
    if (completedLevelNumber == 2) _award(user, 'level_2_done', context);
    if (completedLevelNumber == 3) _award(user, 'level_3_done', context);
    if (completedLevelNumber == 4) _award(user, 'level_4_done', context);

    // ── XP milestones ────────────────────────────────────────────────────────
    if (newXp != null) {
      if (newXp >= 500)  _award(user, 'xp_500', context);
      if (newXp >= 2000) _award(user, 'xp_2000', context);
      if (newXp >= 5000) _award(user, 'xp_5000', context);
    }

    // ── Streak milestones ─────────────────────────────────────────────────────
    if (newStreak != null) {
      if (newStreak >= 3)  _award(user, 'streak_3', context);
      if (newStreak >= 7)  _award(user, 'streak_7', context);
      if (newStreak >= 30) _award(user, 'streak_30', context);
    }
  }

  void _award(UserProfile user, String badgeId, [BuildContext? context]) {
    if (!user.hasBadge(badgeId)) {
      user.awardBadge(badgeId);
      _ref.read(authProvider.notifier).refreshUser();
      final badge = badgeById(badgeId);
      if (context != null && badge != null) {
        BadgeUnlockToast.show(context, badge);
      }
    }
  }
}
