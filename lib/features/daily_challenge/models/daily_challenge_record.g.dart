// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_challenge_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyChallengeRecordAdapter extends TypeAdapter<DailyChallengeRecord> {
  @override
  final int typeId = 3;

  @override
  DailyChallengeRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyChallengeRecord(
      lastCompletedDateStr: fields[0] as String,
      currentStreak: fields[1] as int,
      totalCompleted: fields[2] as int,
      streakShields: fields[3] as int,
      bonusXpEarned: fields[4] as int,
      uid: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DailyChallengeRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.lastCompletedDateStr)
      ..writeByte(1)
      ..write(obj.currentStreak)
      ..writeByte(2)
      ..write(obj.totalCompleted)
      ..writeByte(3)
      ..write(obj.streakShields)
      ..writeByte(4)
      ..write(obj.bonusXpEarned)
      ..writeByte(5)
      ..write(obj.uid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyChallengeRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
