// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NewsRecordAdapter extends TypeAdapter<NewsRecord> {
  @override
  final int typeId = 16;

  @override
  NewsRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NewsRecord(
      uid: fields[0] as String,
      lastRotationDateStr: fields[1] as String,
      currentHeadlineIndices: (fields[2] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, NewsRecord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.lastRotationDateStr)
      ..writeByte(2)
      ..write(obj.currentHeadlineIndices);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
