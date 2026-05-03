/// daily_challenge_record.dart
/// Purpose: Hive model that persists a user's Daily Challenge progress per uid.
///          Tracks streak, Streak Shields, total completions, and bonus XP.
/// Reads from: Hive box 'daily_challenge'
/// Writes to: Hive box 'daily_challenge'
/// Navigation: none (data model only)
library;

import 'package:hive/hive.dart';

part 'daily_challenge_record.g.dart';

/// Persisted record of a player's daily challenge history.
///
/// One record exists per user, keyed by [uid] in the 'daily_challenge' box.
/// Dates are stored as ISO-8601 date strings (`yyyy-MM-dd`) — same convention
/// as [UserProfile.lastActiveStr] — to avoid a custom DateTime TypeAdapter.
@HiveType(typeId: 3)
class DailyChallengeRecord extends HiveObject {
  DailyChallengeRecord({
    required this.lastCompletedDateStr,
    required this.currentStreak,
    required this.totalCompleted,
    required this.streakShields,
    required this.bonusXpEarned,
    required this.uid,
  });

  /// ISO-8601 date string of the last day the challenge was completed
  /// (format: `'yyyy-MM-dd'`). Empty string if never completed.
  @HiveField(0)
  String lastCompletedDateStr;

  /// Number of consecutive days the player has completed the challenge.
  @HiveField(1)
  int currentStreak;

  /// Total number of challenges completed across all time.
  @HiveField(2)
  int totalCompleted;

  /// Number of Streak Shields currently held (max [kMaxStreakShields]).
  @HiveField(3)
  int streakShields;

  /// Cumulative bonus XP earned from daily challenges.
  @HiveField(4)
  int bonusXpEarned;

  /// The uid (username) of the owning player — mirrors the Hive box key.
  @HiveField(5)
  String uid;

  // ── Computed helpers ───────────────────────────────────────────────────────

  /// Returns true if the challenge was already completed today.
  bool get completedToday {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return lastCompletedDateStr == todayStr;
  }

  /// Returns true if the streak has been broken (last completion was more than
  /// one calendar day ago). Returns false if never completed.
  bool get streakBroken {
    if (lastCompletedDateStr.isEmpty) return false;
    final last = DateTime.parse(lastCompletedDateStr);
    final today = DateTime.now();
    final diff = DateTime(today.year, today.month, today.day)
        .difference(DateTime(last.year, last.month, last.day))
        .inDays;
    return diff > 1;
  }
}
