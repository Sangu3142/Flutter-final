// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BusinessModelAdapter extends TypeAdapter<BusinessModel> {
  @override
  final int typeId = 5;

  @override
  BusinessModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BusinessModel(
      uid: fields[0] as String,
      businessName: fields[1] as String,
      businessType: fields[2] as String,
      stage: fields[3] as int,
      weeklyRevenue: fields[4] as int,
      weeklyExpenses: fields[5] as int,
      complianceScore: fields[6] as int,
      staff: fields[7] as int,
      lastDecisionDateStr: fields[8] as String,
      totalProfit: fields[9] as int,
      pacraRegistered: fields[10] as bool,
      zraTaxFiled: fields[11] as bool,
      napssaContributed: fields[12] as bool,
      recentEvents: (fields[13] as List).cast<String>(),
      lastWeeklyUpdateStr: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BusinessModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.businessName)
      ..writeByte(2)
      ..write(obj.businessType)
      ..writeByte(3)
      ..write(obj.stage)
      ..writeByte(4)
      ..write(obj.weeklyRevenue)
      ..writeByte(5)
      ..write(obj.weeklyExpenses)
      ..writeByte(6)
      ..write(obj.complianceScore)
      ..writeByte(7)
      ..write(obj.staff)
      ..writeByte(8)
      ..write(obj.lastDecisionDateStr)
      ..writeByte(9)
      ..write(obj.totalProfit)
      ..writeByte(10)
      ..write(obj.pacraRegistered)
      ..writeByte(11)
      ..write(obj.zraTaxFiled)
      ..writeByte(12)
      ..write(obj.napssaContributed)
      ..writeByte(13)
      ..write(obj.recentEvents)
      ..writeByte(14)
      ..write(obj.lastWeeklyUpdateStr);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
