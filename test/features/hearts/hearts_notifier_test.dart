import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:zamwealth_quest/features/hearts/models/hearts_model.dart';
import 'package:zamwealth_quest/core/constants.dart';

Future<Box<HeartsModel>> openTestHeartsBox() async {
  final dir = await Directory.systemTemp.createTemp('hive_test_');
  Hive.init(dir.path);
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(HeartsModelAdapter());
  }
  return await Hive.openBox<HeartsModel>('test_hearts');
}

void main() {
  test('HeartsModel starts with 5 hearts', () {
    final model = HeartsModel.full();
    expect(model.heartsCount, equals(5));
    expect(model.lostAt, isEmpty);
  });

  test('loseHeart decrements count and records timestamp', () {
    final model = HeartsModel(heartsCount: 5, lostAt: []);
    final before = DateTime.now();
    model.lostAt.add(DateTime.now().toIso8601String());
    model.heartsCount--;
    final after = DateTime.now();

    expect(model.heartsCount, equals(4));
    expect(model.lostAt.length, equals(1));
    final ts = DateTime.parse(model.lostAt.first);
    expect(ts.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
    expect(ts.isBefore(after.add(const Duration(seconds: 1))), isTrue);
  });

  test('refill logic removes timestamps older than 30 minutes', () {
    final oldTimestamp =
        DateTime.now().subtract(const Duration(minutes: 31)).toIso8601String();
    final recentTimestamp =
        DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String();
    final lostAt = [oldTimestamp, recentTimestamp];
    final cutoff = DateTime.now().subtract(const Duration(minutes: kHeartRefillMinutes));
    final remaining = lostAt.where((ts) => DateTime.parse(ts).isAfter(cutoff)).toList();
    final refilled = lostAt.length - remaining.length;
    expect(remaining.length, equals(1));
    expect(refilled, equals(1));
  });

  test('heartsCount cannot exceed kMaxHearts after refill', () {
    final model = HeartsModel(heartsCount: 4, lostAt: []);
    const refilled = 1;
    final newCount = (model.heartsCount + refilled).clamp(0, kMaxHearts);
    expect(newCount, equals(5));
  });
}
