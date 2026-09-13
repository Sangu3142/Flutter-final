// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotlight_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpotlightRecordAdapter extends TypeAdapter<SpotlightRecord> {
  @override
  final int typeId = 19;

  @override
  SpotlightRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpotlightRecord(
      uid: fields[0] as String,
      completedSpotlightIds: (fields[1] as List).cast<int>(),
      chapterProgress: (fields[2] as List).cast<int>(),
      choicesJson: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SpotlightRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.completedSpotlightIds)
      ..writeByte(2)
      ..write(obj.chapterProgress)
      ..writeByte(3)
      ..write(obj.choicesJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpotlightRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
