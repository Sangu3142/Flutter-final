// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'life_event_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LifeEventRecordAdapter extends TypeAdapter<LifeEventRecord> {
  @override
  final int typeId = 6;

  @override
  LifeEventRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LifeEventRecord(
      uid: fields[0] as String,
      lastEventDateStr: fields[1] as String,
      lastEventId: fields[2] as int,
      eventHistory: (fields[3] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, LifeEventRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.lastEventDateStr)
      ..writeByte(2)
      ..write(obj.lastEventId)
      ..writeByte(3)
      ..write(obj.eventHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LifeEventRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
