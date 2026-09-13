// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_routine_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyRoutineRecordAdapter extends TypeAdapter<DailyRoutineRecord> {
  @override
  final int typeId = 22;

  @override
  DailyRoutineRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyRoutineRecord(
      uid: fields[0] as String,
      lastMorningDateStr: fields[1] as String,
      lastMiddayDateStr: fields[2] as String,
      lastEveningDateStr: fields[3] as String,
      lastPerfectDayDateStr: fields[4] as String,
      reflectionJournal: (fields[5] as List).cast<String>(),
      perfectDaysTotal: fields[6] as int,
      currentPerfectDayStreak: fields[7] as int,
      lastStreakDateStr: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DailyRoutineRecord obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.lastMorningDateStr)
      ..writeByte(2)
      ..write(obj.lastMiddayDateStr)
      ..writeByte(3)
      ..write(obj.lastEveningDateStr)
      ..writeByte(4)
      ..write(obj.lastPerfectDayDateStr)
      ..writeByte(5)
      ..write(obj.reflectionJournal)
      ..writeByte(6)
      ..write(obj.perfectDaysTotal)
      ..writeByte(7)
      ..write(obj.currentPerfectDayStreak)
      ..writeByte(8)
      ..write(obj.lastStreakDateStr);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRoutineRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
