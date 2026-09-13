// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PortfolioModelAdapter extends TypeAdapter<PortfolioModel> {
  @override
  final int typeId = 8;

  @override
  PortfolioModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PortfolioModel(
      uid: fields[0] as String,
      sharesZamCoins: fields[1] as int,
      bondsZamCoins: fields[2] as int,
      moneyMarketZamCoins: fields[3] as int,
      cryptoZamCoins: fields[4] as int,
      totalInvestedZamCoins: fields[5] as int,
      snapshotDates: (fields[6] as List).cast<String>(),
      snapshotValues: (fields[7] as List).cast<int>(),
      lastMarketTickStr: fields[8] as String,
      recentEvents: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PortfolioModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.sharesZamCoins)
      ..writeByte(2)
      ..write(obj.bondsZamCoins)
      ..writeByte(3)
      ..write(obj.moneyMarketZamCoins)
      ..writeByte(4)
      ..write(obj.cryptoZamCoins)
      ..writeByte(5)
      ..write(obj.totalInvestedZamCoins)
      ..writeByte(6)
      ..write(obj.snapshotDates)
      ..writeByte(7)
      ..write(obj.snapshotValues)
      ..writeByte(8)
      ..write(obj.lastMarketTickStr)
      ..writeByte(9)
      ..write(obj.recentEvents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
