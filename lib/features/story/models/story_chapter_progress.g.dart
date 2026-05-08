// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_chapter_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoryChapterProgressAdapter extends TypeAdapter<StoryChapterProgress> {
  @override
  final int typeId = 12;

  @override
  StoryChapterProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoryChapterProgress(
      uid: fields[0] as String,
      chapterId: fields[1] as int,
      isUnlocked: fields[2] as bool? ?? false,
      playerChoice: fields[3] as int? ?? 0,
      dateUnlockedStr: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StoryChapterProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.chapterId)
      ..writeByte(2)
      ..write(obj.isUnlocked)
      ..writeByte(3)
      ..write(obj.playerChoice)
      ..writeByte(4)
      ..write(obj.dateUnlockedStr);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryChapterProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
