// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myth_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MythRecordAdapter extends TypeAdapter<MythRecord> {
  @override
  final int typeId = 18;

  @override
  MythRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MythRecord(
      uid: fields[0] as String,
      seenMythIds: (fields[1] as List).cast<int>(),
      correctMythIds: (fields[2] as List).cast<int>(),
      totalMythsAnswered: fields[3] as int,
      lastDailyDateStr: fields[4] as String,
      todaysMythIds: (fields[5] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, MythRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.seenMythIds)
      ..writeByte(2)
      ..write(obj.correctMythIds)
      ..writeByte(3)
      ..write(obj.totalMythsAnswered)
      ..writeByte(4)
      ..write(obj.lastDailyDateStr)
      ..writeByte(5)
      ..write(obj.todaysMythIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MythRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
