// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentRecordAdapter extends TypeAdapter<PaymentRecord> {
  @override
  final int typeId = 2;

  @override
  PaymentRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentRecord(
      paymentId: fields[0] as String,
      uid: fields[1] as String,
      tier: fields[2] as String,
      amountZMW: fields[3] as double,
      provider: fields[4] as String,
      timestampStr: fields[5] as String?,
      sandboxMode: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.paymentId)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.tier)
      ..writeByte(3)
      ..write(obj.amountZMW)
      ..writeByte(4)
      ..write(obj.provider)
      ..writeByte(5)
      ..write(obj.timestampStr)
      ..writeByte(6)
      ..write(obj.sandboxMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
