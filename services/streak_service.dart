/// streak_service.dart
/// Purpose: Tracks daily learning streaks and streak shields.
/// All persistence via Hive kStreakBox (plain Box, uid-keyed primitives).
library;

import 'package:hive/hive.dart';
import 'package:zamwealth_quest/core/constants.dart';

class StreakResult {
  final int streak;
  final int shieldCount;
  final int shieldsEarned;

  const StreakResult({
    required this.streak,
    required this.shieldCount,
    required this.shieldsEarned,
  });
}

class StreakService {
  StreakService._();

  static Box get _box => Hive.box(kStreakBox);

  static String _streakKey(String uid) => '${uid}_streak';
  static String _dateKey(String uid) => '${uid}_lastDate';
  static String _shieldKey(String uid) => '${uid}_shields';

  static String _todayStr() =>
      DateTime.now().toIso8601String().split('T')[0];

  static String _yesterdayStr() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return y.toIso8601String().split('T')[0];
  }

  /// Call once per quiz/challenge completion for [uid].
  /// Idempotent within the same calendar day.
  static Future<StreakResult> recordActivity(String uid) async {
    final today = _todayStr();
    final yesterday = _yesterdayStr();

    final lastDate = _box.get(_dateKey(uid), defaultValue: '') as String;
    int streak = _box.get(_streakKey(uid), defaultValue: 0) as int;
    int shields = _box.get(_shieldKey(uid), defaultValue: 0) as int;

    // Already recorded today — idempotent
    if (lastDate == today) {
      return StreakResult(
          streak: streak, shieldCount: shields, shieldsEarned: 0);
    }

    int shieldsEarned = 0;

    if (lastDate == yesterday) {
      // Continued streak
      streak++;
    } else if (lastDate.isNotEmpty && shields > 0) {
      // Missed a day but a shield absorbs the break
      shields--;
      streak++;
    } else {
      // Streak broken or fresh start
      streak = 1;
    }

    // Award a shield every kStreakShieldInterval days
    if (streak > 0 && streak % kStreakShieldInterval == 0) {
      if (shields < kMaxStreakShields) {
        shields++;
        shieldsEarned++;
      }
    }

    await _box.put(_streakKey(uid), streak);
    await _box.put(_dateKey(uid), today);
    await _box.put(_shieldKey(uid), shields);

    return StreakResult(
        streak: streak, shieldCount: shields, shieldsEarned: shieldsEarned);
  }

  /// Add one streak shield (capped at kMaxStreakShields).
  static Future<void> addShield(String uid) async {
    int shields = _box.get(_shieldKey(uid), defaultValue: 0) as int;
    if (shields < kMaxStreakShields) {
      shields++;
      await _box.put(_shieldKey(uid), shields);
    }
  }

  /// Read current streak data without modifying it.
  static ({int streak, int shields, String lastDate}) read(String uid) {
    return (
      streak: _box.get(_streakKey(uid), defaultValue: 0) as int,
      shields: _box.get(_shieldKey(uid), defaultValue: 0) as int,
      lastDate: _box.get(_dateKey(uid), defaultValue: '') as String,
    );
  }
}
