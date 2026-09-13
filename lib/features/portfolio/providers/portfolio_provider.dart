/// portfolio_provider.dart
/// Purpose: Manages the investment portfolio — daily market ticks, invest/withdraw.
library;

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/portfolio/models/portfolio_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class PortfolioState {
  const PortfolioState({this.portfolio, this.isLoading = false});
  final PortfolioModel? portfolio;
  final bool isLoading;
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class PortfolioNotifier extends StateNotifier<PortfolioState> {
  PortfolioNotifier(this._ref) : super(const PortfolioState()) {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.currentUser?.uid != next.currentUser?.uid) _load();
    });
    _load();
  }

  final Ref _ref;
  final _rng = Random();

  Box<PortfolioModel> get _box => Hive.box<PortfolioModel>(kInvestmentsBox);
  String? get _uid => _ref.read(currentUserProvider)?.uid;

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      state = const PortfolioState();
      return;
    }
    final port = _box.get(uid);
    if (port != null) {
      await _maybeDailyMarketTick(port);
    }
    state = PortfolioState(portfolio: _box.get(uid));
  }

  // ── Invest in an asset ────────────────────────────────────────────────────

  Future<bool> invest(int assetIndex, int zamCoins) async {
    if (zamCoins <= 0) return false;
    final uid = _uid;
    if (uid == null) return false;
    final spent =
        await _ref.read(authProvider.notifier).spendWalletCoins(zamCoins);
    if (!spent) return false;

    PortfolioModel port = _box.get(uid) ?? _createEmpty(uid);
    port.totalInvestedZamCoins += zamCoins;
    _setAsset(port, assetIndex, _getAsset(port, assetIndex) + zamCoins);

    final today = _todayStr();
    _addSnapshot(port, today);
    _addEvent(port,
        '💸 Invested $zamCoins ZC in ${PortfolioModel.assetNames[assetIndex]}');
    await _box.put(uid, port);
    state = PortfolioState(portfolio: port);
    return true;
  }

  // ── Withdraw from an asset ────────────────────────────────────────────────

  Future<bool> withdraw(int assetIndex, int zamCoins) async {
    final uid = _uid;
    if (uid == null) return false;
    final port = _box.get(uid);
    if (port == null) return false;

    final current = _getAsset(port, assetIndex);
    if (current < zamCoins) return false;

    _setAsset(port, assetIndex, current - zamCoins);
    await _ref.read(authProvider.notifier).addWalletCoins(zamCoins);
    _addEvent(port,
        '💰 Withdrew $zamCoins ZC from ${PortfolioModel.assetNames[assetIndex]}');
    await port.save();
    state = PortfolioState(portfolio: port);
    return true;
  }

  // ── Daily market simulation ───────────────────────────────────────────────

  Future<void> _maybeDailyMarketTick(PortfolioModel port) async {
    final today = _todayStr();
    if (port.lastMarketTickStr == today) return;

    const ranges = PortfolioModel.assetDailyRange;
    final values = port.assetValues;
    bool changed = false;

    for (int i = 0; i < 4; i++) {
      if (values[i] == 0) continue;
      final min = ranges[i][0];
      final max = ranges[i][1];
      final pct = min + _rng.nextDouble() * (max - min);
      final newVal = (values[i] * (1 + pct)).round().clamp(0, 999999);
      if (newVal != values[i]) {
        _setAsset(port, i, newVal);
        changed = true;
      }
    }

    if (changed) {
      final total = port.totalValueZamCoins;
      final isGain = total > (port.snapshotValues.isNotEmpty
          ? port.snapshotValues.last
          : port.totalInvestedZamCoins);
      _addEvent(
          port, isGain ? '📈 Markets up today!' : '📉 Markets dipped today.');
    }

    port.lastMarketTickStr = today;
    _addSnapshot(port, today);
    await port.save();
  }

  void _addSnapshot(PortfolioModel port, String date) {
    port.snapshotDates.add(date);
    port.snapshotValues.add(port.totalValueZamCoins);
    if (port.snapshotDates.length > kPortfolioMaxSnapshots) {
      port.snapshotDates.removeAt(0);
      port.snapshotValues.removeAt(0);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  PortfolioModel _createEmpty(String uid) {
    final today = _todayStr();
    return PortfolioModel(
      uid: uid,
      sharesZamCoins: 0,
      bondsZamCoins: 0,
      moneyMarketZamCoins: 0,
      cryptoZamCoins: 0,
      totalInvestedZamCoins: 0,
      snapshotDates: [today],
      snapshotValues: [0],
      lastMarketTickStr: today,
      recentEvents: [],
    );
  }

  int _getAsset(PortfolioModel p, int i) {
    switch (i) {
      case 0: return p.sharesZamCoins;
      case 1: return p.bondsZamCoins;
      case 2: return p.moneyMarketZamCoins;
      case 3: return p.cryptoZamCoins;
      default: return 0;
    }
  }

  void _setAsset(PortfolioModel p, int i, int val) {
    switch (i) {
      case 0: p.sharesZamCoins = val; break;
      case 1: p.bondsZamCoins = val; break;
      case 2: p.moneyMarketZamCoins = val; break;
      case 3: p.cryptoZamCoins = val; break;
    }
  }

  void _addEvent(PortfolioModel p, String msg) {
    p.recentEvents.insert(0, msg);
    if (p.recentEvents.length > 10) p.recentEvents.removeLast();
  }

  String _todayStr() => DateTime.now().toIso8601String().split('T')[0];
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final portfolioProvider =
    StateNotifierProvider<PortfolioNotifier, PortfolioState>((ref) {
  return PortfolioNotifier(ref);
});
