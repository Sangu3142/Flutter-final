// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boss_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BossRecordAdapter extends TypeAdapter<BossRecord> {
  @override
  final int typeId = 13;

  @override
  BossRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BossRecord(
      levelId: fields[0] as int,
      defeated: fields[1] as bool,
      replayCount: fields[2] as int,
      bestScore: fields[3] as int,
      defeatedAt: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BossRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.levelId)
      ..writeByte(1)
      ..write(obj.defeated)
      ..writeByte(2)
      ..write(obj.replayCount)
      ..writeByte(3)
      ..write(obj.bestScore)
      ..writeByte(4)
      ..write(obj.defeatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BossRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
