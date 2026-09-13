/// daily_routine_record.dart
/// Purpose: Hive model for the 3-part daily financial routine progress.
library;

import 'package:hive/hive.dart';

part 'daily_routine_record.g.dart';

@HiveType(typeId: 22)
class DailyRoutineRecord extends HiveObject {
  DailyRoutineRecord({
    required this.uid,
    required this.lastMorningDateStr,
    required this.lastMiddayDateStr,
    required this.lastEveningDateStr,
    required this.lastPerfectDayDateStr,
    required this.reflectionJournal,
    required this.perfectDaysTotal,
    required this.currentPerfectDayStreak,
    required this.lastStreakDateStr,
  });

  @HiveField(0) String uid;
  @HiveField(1) String lastMorningDateStr;
  @HiveField(2) String lastMiddayDateStr;
  @HiveField(3) String lastEveningDateStr;
  @HiveField(4) String lastPerfectDayDateStr;
  @HiveField(5) List<String> reflectionJournal;
  @HiveField(6) int perfectDaysTotal;
  @HiveField(7) int currentPerfectDayStreak;
  @HiveField(8) String lastStreakDateStr;

  bool get morningDoneToday => lastMorningDateStr == _today();
  bool get middayDoneToday  => lastMiddayDateStr  == _today();
  bool get eveningDoneToday => lastEveningDateStr == _today();
  bool get perfectDayToday  => lastPerfectDayDateStr == _today();

  static String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }
}
