/// inventory_model.dart
/// Purpose: Hive model for player inventory — power-ups, cosmetic unlocks, and active selections.
/// Reads from: Hive box 'inventory'
/// Writes to: Hive box 'inventory'
/// Navigation: none (data model only)
library;

import 'package:hive/hive.dart';
import '../../../core/constants.dart';

part 'inventory_model.g.dart';

@HiveType(typeId: 11)
class InventoryModel extends HiveObject {
  @HiveField(0)
  Map<dynamic, dynamic> powerUpsRaw;

  @HiveField(1)
  List<String> unlockedOutfits;

  @HiveField(2)
  List<String> unlockedFrames;

  @HiveField(3)
  List<String> unlockedStreakIcons;

  @HiveField(4)
  String? activeOutfitId;

  @HiveField(5)
  String? activeFrameId;

  @HiveField(6)
  String? activeStreakIconId;

  InventoryModel({
    required this.powerUpsRaw,
    required this.unlockedOutfits,
    required this.unlockedFrames,
    required this.unlockedStreakIcons,
    this.activeOutfitId,
    this.activeFrameId,
    this.activeStreakIconId,
  });

  Map<String, int> get powerUps =>
      powerUpsRaw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));

  int countOf(String powerUpId) => powerUps[powerUpId] ?? 0;
  bool has(String powerUpId) => countOf(powerUpId) > 0;

  factory InventoryModel.empty() => InventoryModel(
        powerUpsRaw: Map<String, dynamic>.from(kDefaultPowerUps),
        unlockedOutfits: [],
        unlockedFrames: [],
        unlockedStreakIcons: [],
      );
}
