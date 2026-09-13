/// portfolio_model.dart
/// Purpose: Hive model for a player's investment portfolio.
/// Stores per-asset holdings and a daily snapshot history for line charts.
library;

import 'package:hive/hive.dart';

part 'portfolio_model.g.dart';

@HiveType(typeId: 8)
class PortfolioModel extends HiveObject {
  PortfolioModel({
    required this.uid,
    required this.sharesZamCoins,
    required this.bondsZamCoins,
    required this.moneyMarketZamCoins,
    required this.cryptoZamCoins,
    required this.totalInvestedZamCoins,
    required this.snapshotDates,
    required this.snapshotValues,
    required this.lastMarketTickStr,
    required this.recentEvents,
  });

  @HiveField(0) String uid;
  @HiveField(1) int sharesZamCoins;       // LUSE equity shares
  @HiveField(2) int bondsZamCoins;        // Government bonds (stable)
  @HiveField(3) int moneyMarketZamCoins;  // Money market fund
  @HiveField(4) int cryptoZamCoins;       // Crypto (volatile)
  @HiveField(5) int totalInvestedZamCoins;
  @HiveField(6) List<String> snapshotDates;  // parallel list for chart
  @HiveField(7) List<int> snapshotValues;    // total portfolio value at each date
  @HiveField(8) String lastMarketTickStr;    // YYYY-MM-DD, daily market update
  @HiveField(9) List<String> recentEvents;

  // ── Asset metadata ────────────────────────────────────────────────────────
  static const List<String> assetNames = [
    'LUSE Shares',
    'Gov. Bonds',
    'Money Market',
    'Crypto',
  ];
  static const List<String> assetEmojis = ['📈', '🏛️', '💵', '₿'];
  // Daily return range: [min%, max%] as fractions
  static const List<List<double>> assetDailyRange = [
    [-0.02, 0.025],  // Shares: ±2.5%
    [0.00015, 0.00025], // Bonds: ~0.02% daily (~7% pa)
    [0.00025, 0.00035], // Money Market: ~0.03% daily (~11% pa)
    [-0.05, 0.06],   // Crypto: ±5-6%
  ];
  static const List<int> assetMinDeposit = [10, 10, 10, 10];

  // ── Computed helpers ──────────────────────────────────────────────────────
  int get totalValueZamCoins =>
      sharesZamCoins + bondsZamCoins + moneyMarketZamCoins + cryptoZamCoins;

  double get returnsPercent => totalInvestedZamCoins == 0
      ? 0.0
      : (totalValueZamCoins - totalInvestedZamCoins) /
            totalInvestedZamCoins *
            100;

  List<int> get assetValues =>
      [sharesZamCoins, bondsZamCoins, moneyMarketZamCoins, cryptoZamCoins];
}
