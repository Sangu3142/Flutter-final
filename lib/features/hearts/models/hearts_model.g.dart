// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hearts_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HeartsModelAdapter extends TypeAdapter<HeartsModel> {
  @override
  final int typeId = 10;

  @override
  HeartsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HeartsModel(
      heartsCount: fields[0] as int,
      lostAt: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, HeartsModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.heartsCount)
      ..writeByte(1)
      ..write(obj.lostAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeartsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
