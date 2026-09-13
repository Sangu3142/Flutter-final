// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FamilyModelAdapter extends TypeAdapter<FamilyModel> {
  @override
  final int typeId = 4;

  @override
  FamilyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FamilyModel(
      uid: fields[0] as String,
      spouseName: fields[1] as String,
      childName: fields[2] as String,
      happinessScore: fields[3] as int,
      healthScore: fields[4] as int,
      housingTier: fields[5] as int,
      monthlyFoodBudget: fields[6] as int,
      childInSchool: fields[7] as bool,
      schoolFeesPaid: fields[8] as bool,
      recentEvents: (fields[9] as List).cast<String>(),
      lastUpdatedStr: fields[10] as String,
      monthlyExpenses: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FamilyModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.spouseName)
      ..writeByte(2)
      ..write(obj.childName)
      ..writeByte(3)
      ..write(obj.happinessScore)
      ..writeByte(4)
      ..write(obj.healthScore)
      ..writeByte(5)
      ..write(obj.housingTier)
      ..writeByte(6)
      ..write(obj.monthlyFoodBudget)
      ..writeByte(7)
      ..write(obj.childInSchool)
      ..writeByte(8)
      ..write(obj.schoolFeesPaid)
      ..writeByte(9)
      ..write(obj.recentEvents)
      ..writeByte(10)
      ..write(obj.lastUpdatedStr)
      ..writeByte(11)
      ..write(obj.monthlyExpenses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
