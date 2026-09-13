// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryModelAdapter extends TypeAdapter<InventoryModel> {
  @override
  final int typeId = 11;

  @override
  InventoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryModel(
      powerUpsRaw: (fields[0] as Map).cast<dynamic, dynamic>(),
      unlockedOutfits: (fields[1] as List).cast<String>(),
      unlockedFrames: (fields[2] as List).cast<String>(),
      unlockedStreakIcons: (fields[3] as List).cast<String>(),
      activeOutfitId: fields[4] as String?,
      activeFrameId: fields[5] as String?,
      activeStreakIconId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.powerUpsRaw)
      ..writeByte(1)
      ..write(obj.unlockedOutfits)
      ..writeByte(2)
      ..write(obj.unlockedFrames)
      ..writeByte(3)
      ..write(obj.unlockedStreakIcons)
      ..writeByte(4)
      ..write(obj.activeOutfitId)
      ..writeByte(5)
      ..write(obj.activeFrameId)
      ..writeByte(6)
      ..write(obj.activeStreakIconId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
