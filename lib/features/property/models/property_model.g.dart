// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PropertyModelAdapter extends TypeAdapter<PropertyModel> {
  @override
  final int typeId = 7;

  @override
  PropertyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PropertyModel(
      uid: fields[0] as String,
      tier: fields[1] as int,
      isOwned: fields[2] as bool,
      purchaseDateStr: fields[3] as String,
      currentValueZMW: fields[4] as int,
      totalInvestedZamCoins: fields[5] as int,
      monthlyMortgageZamCoins: fields[6] as int,
      mortgageMonthsRemaining: fields[7] as int,
      isRentedOut: fields[8] as bool,
      lastAppreciationStr: fields[9] as String,
      lastRentalStr: fields[10] as String,
      recentEvents: (fields[11] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PropertyModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.tier)
      ..writeByte(2)
      ..write(obj.isOwned)
      ..writeByte(3)
      ..write(obj.purchaseDateStr)
      ..writeByte(4)
      ..write(obj.currentValueZMW)
      ..writeByte(5)
      ..write(obj.totalInvestedZamCoins)
      ..writeByte(6)
      ..write(obj.monthlyMortgageZamCoins)
      ..writeByte(7)
      ..write(obj.mortgageMonthsRemaining)
      ..writeByte(8)
      ..write(obj.isRentedOut)
      ..writeByte(9)
      ..write(obj.lastAppreciationStr)
      ..writeByte(10)
      ..write(obj.lastRentalStr)
      ..writeByte(11)
      ..write(obj.recentEvents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
