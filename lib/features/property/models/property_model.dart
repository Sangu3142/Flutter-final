/// property_model.dart
/// Purpose: Hive model for a player's virtual property investment.
library;

import 'package:hive/hive.dart';

part 'property_model.g.dart';

@HiveType(typeId: 7)
class PropertyModel extends HiveObject {
  PropertyModel({
    required this.uid,
    required this.tier,
    required this.isOwned,
    required this.purchaseDateStr,
    required this.currentValueZMW,
    required this.totalInvestedZamCoins,
    required this.monthlyMortgageZamCoins,
    required this.mortgageMonthsRemaining,
    required this.isRentedOut,
    required this.lastAppreciationStr,
    required this.lastRentalStr,
    required this.recentEvents,
  });

  @HiveField(0) String uid;
  @HiveField(1) int tier; // 1=Plot, 2=Maisonette, 3=Town House, 4=Villa
  @HiveField(2) bool isOwned;
  @HiveField(3) String purchaseDateStr;
  @HiveField(4) int currentValueZMW;
  @HiveField(5) int totalInvestedZamCoins;
  @HiveField(6) int monthlyMortgageZamCoins;
  @HiveField(7) int mortgageMonthsRemaining;
  @HiveField(8) bool isRentedOut;
  @HiveField(9) String lastAppreciationStr;
  @HiveField(10) String lastRentalStr;
  @HiveField(11) List<String> recentEvents;

  // ── Static tier configuration (5-tier Zambian Property Ladder) ──────────
  // Index 0 is a sentinel; tiers are 1–5.
  static const List<String> tierNames = [
    '',
    'Plot of Land',
    'Foundation',
    'Shell Structure',
    'Complete House',
    'Investment Property',
  ];
  static const List<String> tierEmojis = ['', '🏗️', '🧱', '🏚️', '🏠', '🏘️'];
  static const List<String> tierDescriptions = [
    '',
    'Own land in Zambia — your first step on the property ladder',
    'Lay the foundation — real property law now protects your asset',
    'Walls and roof up — a sellable asset with real market value',
    'Fully finished home — live in it or rent rooms out',
    'Investment property — earn ZamCoin rental income every week',
  ];

  // ZMW values at 1 ZC = ZMW 1,000
  static const List<int> tierBaseZMW = [
    0, 50000, 120000, 280000, 500000, 1200000,
  ];

  // ZamCoins deposit (down payment) to purchase each tier
  static const List<int> tierDepositZamCoins = [0, 50, 30, 80, 100, 200];

  // Monthly mortgage instalments in ZamCoins (0 = no mortgage for tier 1)
  static const List<int> tierMortgageZamCoins = [0, 0, 10, 20, 40, 100];
  static const List<int> tierMortgageMonths   = [0, 0,  9, 10, 10,  10];

  // Weekly rental income for Investment Property (tier 5) only
  static const int tier5RentalZamCoins = 50;

  // ── Computed helpers ──────────────────────────────────────────────────────
  bool get hasMortgage => mortgageMonthsRemaining > 0;
  bool get canRentOut  => tier == 5;
  bool get canUpgrade  => tier < 5;
  int  get weeklyRentalZamCoins =>
      (tier == 5 && isRentedOut) ? tier5RentalZamCoins : 0;

  // Full ZamCoin cost = deposit + all monthly payments
  static int totalCostZC(int t) =>
      tierDepositZamCoins[t] + tierMortgageZamCoins[t] * tierMortgageMonths[t];
}
