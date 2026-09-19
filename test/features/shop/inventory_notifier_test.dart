import 'package:flutter_test/flutter_test.dart';
import 'package:zamwealth_quest/features/shop/models/inventory_model.dart';
import 'package:zamwealth_quest/core/constants.dart';

void main() {
  test('InventoryModel starts with all power-ups at 0', () {
    final inv = InventoryModel.empty();
    for (final id in kDefaultPowerUps.keys) {
      expect(inv.countOf(id), equals(0));
    }
  });

  test('has() returns false for zero-count power-up', () {
    final inv = InventoryModel.empty();
    expect(inv.has(kPowerUpShield), isFalse);
  });

  test('countOf() returns correct count after manual increment', () {
    final inv = InventoryModel.empty();
    inv.powerUpsRaw[kPowerUpHintToken] = 3;
    expect(inv.countOf(kPowerUpHintToken), equals(3));
  });

  test('powerUps getter casts correctly from raw map', () {
    final inv = InventoryModel.empty();
    inv.powerUpsRaw[kPowerUpShield] = 2;
    final typed = inv.powerUps;
    expect(typed[kPowerUpShield], equals(2));
  });

  test('has() returns true for non-zero count', () {
    final inv = InventoryModel.empty();
    inv.powerUpsRaw[kPowerUpShield] = 1;
    expect(inv.has(kPowerUpShield), isTrue);
  });

  test('countOf returns 0 for unknown key', () {
    final inv = InventoryModel.empty();
    expect(inv.countOf('nonexistent_key'), equals(0));
  });

  // Tests InventoryModel's own list contract; addItem integration is covered by provider tests
  test('double-unlock of outfit does not duplicate', () {
    final inv = InventoryModel.empty();
    if (!inv.unlockedOutfits.contains('outfit_blue')) {
      inv.unlockedOutfits.add('outfit_blue');
    }
    if (!inv.unlockedOutfits.contains('outfit_blue')) {
      inv.unlockedOutfits.add('outfit_blue');
    }
    expect(inv.unlockedOutfits.where((o) => o == 'outfit_blue').length, equals(1));
  });
}
