// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MentorRecordAdapter extends TypeAdapter<MentorRecord> {
  @override
  final int typeId = 20;

  @override
  MentorRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MentorRecord(
      uid: fields[0] as String,
      unlockedMentorIds: (fields[1] as List).cast<String>(),
      lastTipDatesJson: fields[2] as String,
      challengesCompletedJson: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MentorRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.unlockedMentorIds)
      ..writeByte(2)
      ..write(obj.lastTipDatesJson)
      ..writeByte(3)
      ..write(obj.challengesCompletedJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MentorRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
