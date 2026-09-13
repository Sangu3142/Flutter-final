/// season_provider.dart
/// Purpose: Computes the current rotating season (1-of-8 weekly), detects
///          Zambian holidays, and manages the monthly challenge completion flow.
/// Reads from: authProvider (current user), constants (kZambiaHolidays, kMonthlyChallenge)
/// Writes to: UserProfile.monthlyChallengeDoneMonth (via Hive), authProvider,
///            inventoryProvider, badgeServiceProvider
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../badges/providers/badge_provider.dart';
import '../../shop/providers/inventory_provider.dart';
import '../models/season_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Season State
// ─────────────────────────────────────────────────────────────────────────────

class SeasonState {
  final SeasonConfig currentSeason;
  final int daysRemainingInWeek;
  final bool hasActiveHoliday;
  final String? holidayName;
  final bool isHolidayXpDay;
  final bool monthlyChallengeCompleted;
  final String monthlyChallengeDescription;

  const SeasonState({
    required this.currentSeason,
    required this.daysRemainingInWeek,
    this.hasActiveHoliday = false,
    this.holidayName,
    this.isHolidayXpDay = false,
    this.monthlyChallengeCompleted = false,
    required this.monthlyChallengeDescription,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Season Notifier
// ─────────────────────────────────────────────────────────────────────────────

class SeasonNotifier extends StateNotifier<SeasonState> {
  final Ref _ref;

  SeasonNotifier(this._ref) : super(_computeInitial(_ref));

  static SeasonState _computeInitial(Ref ref) {
    final now = DateTime.now();
    final weekOfYear = _weekOfYear(now);
    final seasonIdx = weekOfYear % 8;
    final season = kSeasonConfigs[seasonIdx];
    // Season runs Sun→Sat. Sunday starts a fresh 7-day season; Saturday is
    // the last day (daysLeft=1). On Sunday daysUntilSunday=0, so we reset to 7.
    final weekday = now.weekday; // Mon=1 … Sun=7
    final daysUntilSunday = 7 - weekday;
    final daysLeft = daysUntilSunday == 0 ? 7 : daysUntilSunday;

    final holidayKey = (now.month, now.day);
    final holidayName = kZambiaHolidays[holidayKey];
    final isIndependenceDay = now.month == 10 && now.day == 24;

    final user = ref.read(currentUserProvider);
    // monthlyChallengeDoneMonth is encoded as year * 100 + month
    final currentKey = now.year * 100 + now.month;
    final challengeDone = user?.monthlyChallengeDoneMonth == currentKey;
    final challengeDesc =
        kMonthlyChallenge[now.month] ?? 'Complete a challenge this month';

    return SeasonState(
      currentSeason: season,
      daysRemainingInWeek: daysLeft,
      hasActiveHoliday: holidayName != null,
      holidayName: holidayName,
      isHolidayXpDay: isIndependenceDay,
      monthlyChallengeCompleted: challengeDone,
      monthlyChallengeDescription: challengeDesc,
    );
  }

  /// Returns the 0-based week-of-year for [date].
  static int _weekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays + 1;
    return (dayOfYear - 1) ~/ 7;
  }

  /// Marks the monthly challenge as completed for the current month, awards
  /// 200 XP, 150 wallet coins, one mystery_box power-up, and a monthly badge.
  Future<void> completeMonthlyChallenge() async {
    final now = DateTime.now();
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    // Encode as year * 100 + month to prevent cross-year collisions
    user.monthlyChallengeDoneMonth = now.year * 100 + now.month;
    await user.save();
    _ref.read(authProvider.notifier).refreshUser();

    await _ref.read(authProvider.notifier).addXp(200);
    await _ref.read(authProvider.notifier).addWalletCoins(150);
    await _ref.read(inventoryProvider.notifier).addItem('mystery_box');

    _ref
        .read(badgeServiceProvider)
        .awardById('monthly_${_monthName(now.month)}');

    state = state._copyWith(monthlyChallengeCompleted: true);
  }

  static String _monthName(int month) {
    const names = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
    ];
    return names[month - 1];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private copyWith extension
// ─────────────────────────────────────────────────────────────────────────────

extension _SeasonStateX on SeasonState {
  SeasonState _copyWith({bool? monthlyChallengeCompleted}) => SeasonState(
        currentSeason: currentSeason,
        daysRemainingInWeek: daysRemainingInWeek,
        hasActiveHoliday: hasActiveHoliday,
        holidayName: holidayName,
        isHolidayXpDay: isHolidayXpDay,
        monthlyChallengeCompleted:
            monthlyChallengeCompleted ?? this.monthlyChallengeCompleted,
        monthlyChallengeDescription: monthlyChallengeDescription,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final seasonProvider =
    StateNotifierProvider<SeasonNotifier, SeasonState>(
  (ref) => SeasonNotifier(ref),
);
