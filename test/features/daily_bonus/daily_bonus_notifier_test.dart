import 'package:flutter_test/flutter_test.dart';
import 'package:zamwealth_quest/core/constants.dart';

// Pure logic tests for daily bonus day calculation — no Hive needed.

int _calculateBonusDay({
  required String? lastDateStr,
  required int currentDay,
}) {
  if (lastDateStr == null) return 1;
  final last = DateTime.parse(lastDateStr);
  final today = DateTime.now();
  final lastDate = DateTime(last.year, last.month, last.day);
  final todayDate = DateTime(today.year, today.month, today.day);
  final diff = todayDate.difference(lastDate).inDays;
  if (diff == 0) return currentDay; // already claimed today
  if (diff == 1) return (currentDay % 7) + 1; // consecutive day
  return 1; // missed — reset
}

void main() {
  test('first ever login returns day 1', () {
    expect(_calculateBonusDay(lastDateStr: null, currentDay: 1), equals(1));
  });

  test('consecutive day increments bonus day', () {
    final yesterday =
        DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
    expect(_calculateBonusDay(lastDateStr: yesterday, currentDay: 3),
        equals(4));
  });

  test('consecutive day 7 wraps back to 1', () {
    final yesterday =
        DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
    expect(_calculateBonusDay(lastDateStr: yesterday, currentDay: 7),
        equals(1));
  });

  test('missed day resets to 1', () {
    final twoDaysAgo =
        DateTime.now().subtract(const Duration(days: 2)).toIso8601String();
    expect(_calculateBonusDay(lastDateStr: twoDaysAgo, currentDay: 5),
        equals(1));
  });

  test('same day returns same day (already claimed)', () {
    final today = DateTime.now().toIso8601String();
    expect(_calculateBonusDay(lastDateStr: today, currentDay: 3), equals(3));
  });

  test('kDailyBonusSchedule has 7 entries', () {
    expect(kDailyBonusSchedule.length, equals(7));
  });

  test('day 7 bonus includes double_xp power-up', () {
    final day7 = kDailyBonusSchedule[6];
    expect(day7['powerUp'], equals(kPowerUpDoubleXp));
  });
}
