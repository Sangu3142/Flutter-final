/// networth_provider.dart
/// Purpose: Computes net worth by aggregating all financial feature providers.
///          1 ZamCoin = ZMW 10 for cross-currency display.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/business/providers/business_provider.dart';
import 'package:zamwealth_quest/features/loans/providers/loans_provider.dart';
import 'package:zamwealth_quest/features/portfolio/providers/portfolio_provider.dart';
import 'package:zamwealth_quest/features/property/providers/property_provider.dart';
import 'package:zamwealth_quest/features/savings/providers/savings_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Model
// ─────────────────────────────────────────────────────────────────────────────

class NetWorthData {
  const NetWorthData({
    required this.totalAssetsZMW,
    required this.totalLiabilitiesZMW,
    required this.walletAssetsZMW,
    required this.propertyAssetsZMW,
    required this.portfolioAssetsZMW,
    required this.savingsAssetsZMW,
    required this.businessAssetsZMW,
    required this.loanLiabilitiesZMW,
    required this.mortgageLiabilitiesZMW,
    required this.debtRatio,
    required this.baobabStage,
  });

  final int totalAssetsZMW;
  final int totalLiabilitiesZMW;
  final int walletAssetsZMW;
  final int propertyAssetsZMW;
  final int portfolioAssetsZMW;
  final int savingsAssetsZMW;
  final int businessAssetsZMW;
  final int loanLiabilitiesZMW;
  final int mortgageLiabilitiesZMW;
  final double debtRatio; // 0.0 – 1.0
  final int baobabStage; // 1 – 6

  int get netWorthZMW => totalAssetsZMW - totalLiabilitiesZMW;

  String get baobabStageName {
    switch (baobabStage) {
      case 1: return 'Seedling';
      case 2: return 'Sapling';
      case 3: return 'Young Tree';
      case 4: return 'Mature Baobab';
      case 5: return 'Grand Baobab';
      default: return 'Ancient Baobab';
    }
  }

  String get baobabDescription {
    switch (baobabStage) {
      case 1: return 'Your wealth journey is just beginning. Every kwacha counts.';
      case 2: return 'Roots are growing. Keep building your financial foundation.';
      case 3: return 'Your tree is standing tall. Strong habits are paying off.';
      case 4: return 'A mature baobab — resilient and growing. Impressive progress!';
      case 5: return 'Grand and prosperous. You are building lasting wealth.';
      default: return 'Ancient strength. A ZamWealth Legend in the making!';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final netWorthProvider = Provider<NetWorthData>((ref) {
  final user         = ref.watch(currentUserProvider);
  final propState    = ref.watch(propertyProvider);
  final portState    = ref.watch(portfolioProvider);
  final loansState   = ref.watch(loansProvider);
  final savState     = ref.watch(savingsProvider);
  final bizState     = ref.watch(businessProvider);

  final walletZMW   = (user?.walletBalance ?? 0) * kZamCoinToZMW;
  final propertyZMW = propState.property?.currentValueZMW ?? 0;
  final portZMW     = (portState.portfolio?.totalValueZamCoins ?? 0) * kZamCoinToZMW;
  final savZMW      = (savState.record?.totalSavedZamCoins ?? 0) * kZamCoinToZMW;
  final bizZMW      = bizState.business?.totalProfit ?? 0;

  final loanBalZMW = (loansState.record?.loans.fold<int>(
        0,
        (s, l) => s + (l.isPaidOff ? 0 : l.remainingBalanceZamCoins),
      ) ??
      0) *
      kZamCoinToZMW;

  final prop = propState.property;
  final mortgageZMW = (prop != null && prop.hasMortgage)
      ? prop.monthlyMortgageZamCoins * prop.mortgageMonthsRemaining * kZamCoinToZMW
      : 0;

  final totalAssets = walletZMW + propertyZMW + portZMW + savZMW + bizZMW;
  final totalLiab   = loanBalZMW + mortgageZMW;

  final debtRatio = totalAssets == 0
      ? 0.0
      : (totalLiab / totalAssets).clamp(0.0, 1.0);

  final int stage;
  if (totalAssets - totalLiab < 50000) {
    stage = 1;
  } else if (totalAssets - totalLiab < 200000)  { stage = 2; }
  else if (totalAssets - totalLiab < 500000)  { stage = 3; }
  else if (totalAssets - totalLiab < 1000000) { stage = 4; }
  else if (totalAssets - totalLiab < 5000000) { stage = 5; }
  else                                         { stage = 6; }

  return NetWorthData(
    totalAssetsZMW: totalAssets,
    totalLiabilitiesZMW: totalLiab,
    walletAssetsZMW: walletZMW,
    propertyAssetsZMW: propertyZMW,
    portfolioAssetsZMW: portZMW,
    savingsAssetsZMW: savZMW,
    businessAssetsZMW: bizZMW,
    loanLiabilitiesZMW: loanBalZMW,
    mortgageLiabilitiesZMW: mortgageZMW,
    debtRatio: debtRatio,
    baobabStage: stage,
  );
});
