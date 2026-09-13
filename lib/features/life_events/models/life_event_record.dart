/// life_event_record.dart
/// Purpose: Hive model tracking which life events have been shown to a user
///          and when the last event was triggered.
library;

import 'package:hive/hive.dart';

part 'life_event_record.g.dart';

@HiveType(typeId: 6)
class LifeEventRecord extends HiveObject {
  @HiveField(0)
  String uid;

  /// ISO date string of last triggered event.
  @HiveField(1)
  String lastEventDateStr;

  /// ID of the last event shown (index into kLifeEvents).
  @HiveField(2)
  int lastEventId;

  /// IDs of all events shown (to avoid repeating until pool exhausted).
  @HiveField(3)
  List<int> eventHistory;

  LifeEventRecord({
    required this.uid,
    this.lastEventDateStr = '',
    this.lastEventId = -1,
    List<int>? eventHistory,
  }) : eventHistory = eventHistory ?? [];

  bool get triggeredToday {
    if (lastEventDateStr.isEmpty) return false;
    final last = DateTime.tryParse(lastEventDateStr);
    if (last == null) return false;
    final now = DateTime.now();
    return last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
  }
}
