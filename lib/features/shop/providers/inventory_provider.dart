/// inventory_provider.dart
/// Purpose: Manages the player's inventory — power-ups, cosmetics, and
///          active selections — persisted in the 'inventory' Hive box.
/// Reads from: Hive box 'inventory', auth state
/// Writes to: Hive box 'inventory'
/// Navigation: none (provider only)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/inventory_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants.dart';

class InventoryNotifier extends StateNotifier<InventoryModel> {
  final String _uid;
  final Box<InventoryModel> _box;

  InventoryNotifier(this._uid, this._box)
      : super(_box.get(_uid) ?? InventoryModel.empty());

  /// Adds count of a power-up or cosmetic to inventory.
  Future<void> addItem(String id, {int count = 1}) async {
    if (kDefaultPowerUps.containsKey(id)) {
      final current = state.countOf(id);
      state.powerUpsRaw[id] = current + count;
    } else if (id.contains('outfit')) {
      if (!state.unlockedOutfits.contains(id)) {
        state.unlockedOutfits.add(id);
      }
    } else if (id.contains('frame')) {
      if (!state.unlockedFrames.contains(id)) {
        state.unlockedFrames.add(id);
      }
    } else if (id.contains('flame')) {
      if (!state.unlockedStreakIcons.contains(id)) {
        state.unlockedStreakIcons.add(id);
      }
    } else {
      assert(false, 'Unknown item id: $id');
      return;
    }
    await _save();
  }

  /// Consumes 1 unit of a power-up. Returns false if not available.
  Future<bool> consume(String powerUpId) async {
    final current = state.countOf(powerUpId);
    if (current <= 0) return false;
    state.powerUpsRaw[powerUpId] = current - 1;
    await _save();
    return true;
  }

  /// Equips the outfit with [outfitId] as the active outfit.
  Future<void> equipOutfit(String outfitId) async {
    state = InventoryModel(
      powerUpsRaw: Map.from(state.powerUpsRaw),
      unlockedOutfits: List.from(state.unlockedOutfits),
      unlockedFrames: List.from(state.unlockedFrames),
      unlockedStreakIcons: List.from(state.unlockedStreakIcons),
      activeOutfitId: outfitId,
      activeFrameId: state.activeFrameId,
      activeStreakIconId: state.activeStreakIconId,
    );
    await _box.put(_uid, state);
  }

  /// Equips the frame with [frameId] as the active frame.
  Future<void> equipFrame(String frameId) async {
    state = InventoryModel(
      powerUpsRaw: Map.from(state.powerUpsRaw),
      unlockedOutfits: List.from(state.unlockedOutfits),
      unlockedFrames: List.from(state.unlockedFrames),
      unlockedStreakIcons: List.from(state.unlockedStreakIcons),
      activeOutfitId: state.activeOutfitId,
      activeFrameId: frameId,
      activeStreakIconId: state.activeStreakIconId,
    );
    await _box.put(_uid, state);
  }

  /// Equips the streak icon with [iconId] as the active streak icon.
  Future<void> equipStreakIcon(String iconId) async {
    state = InventoryModel(
      powerUpsRaw: Map.from(state.powerUpsRaw),
      unlockedOutfits: List.from(state.unlockedOutfits),
      unlockedFrames: List.from(state.unlockedFrames),
      unlockedStreakIcons: List.from(state.unlockedStreakIcons),
      activeOutfitId: state.activeOutfitId,
      activeFrameId: state.activeFrameId,
      activeStreakIconId: iconId,
    );
    await _box.put(_uid, state);
  }

  Future<void> _save() async {
    state = InventoryModel(
      powerUpsRaw: Map.from(state.powerUpsRaw),
      unlockedOutfits: List.from(state.unlockedOutfits),
      unlockedFrames: List.from(state.unlockedFrames),
      unlockedStreakIcons: List.from(state.unlockedStreakIcons),
      activeOutfitId: state.activeOutfitId,
      activeFrameId: state.activeFrameId,
      activeStreakIconId: state.activeStreakIconId,
    );
    await _box.put(_uid, state);
  }
}

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, InventoryModel>((ref) {
  final user = ref.watch(currentUserProvider);
  final box = Hive.box<InventoryModel>(kInventoryBox);
  if (user == null) return InventoryNotifier('__guest__', box);
  return InventoryNotifier(user.uid, box);
});
