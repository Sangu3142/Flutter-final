// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proverb_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProverbRecordAdapter extends TypeAdapter<ProverbRecord> {
  @override
  final int typeId = 21;

  @override
  ProverbRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProverbRecord(
      uid: fields[0] as String,
      collectedProverbIds: (fields[1] as List).cast<int>(),
      totalProverbsSeen: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProverbRecord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.collectedProverbIds)
      ..writeByte(2)
      ..write(obj.totalProverbsSeen);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProverbRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
