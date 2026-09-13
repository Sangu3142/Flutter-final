// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingsRecordAdapter extends TypeAdapter<SavingsRecord> {
  @override
  final int typeId = 15;

  @override
  SavingsRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingsRecord(
      uid: fields[0] as String,
      goalsRaw: fields[1] as List<dynamic>,
      recentEvents: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SavingsRecord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.goalsRaw)
      ..writeByte(2)
      ..write(obj.recentEvents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
