/// news_record.dart
/// Purpose: Hive model for Financial News Feed — weekly headline rotation.
library;

import 'package:hive/hive.dart';

part 'news_record.g.dart';

@HiveType(typeId: 16)
class NewsRecord extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String lastRotationDateStr;

  @HiveField(2)
  List<int> currentHeadlineIndices;

  NewsRecord({
    required this.uid,
    required this.lastRotationDateStr,
    required this.currentHeadlineIndices,
  });
}
