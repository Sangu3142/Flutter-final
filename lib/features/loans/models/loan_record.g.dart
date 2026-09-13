// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanRecordAdapter extends TypeAdapter<LoanRecord> {
  @override
  final int typeId = 14;

  @override
  LoanRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanRecord(
      uid: fields[0] as String,
      loansRaw: fields[1] as List<dynamic>,
      creditScore: fields[2] as int,
      recentEvents: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, LoanRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.loansRaw)
      ..writeByte(2)
      ..write(obj.creditScore)
      ..writeByte(3)
      ..write(obj.recentEvents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
