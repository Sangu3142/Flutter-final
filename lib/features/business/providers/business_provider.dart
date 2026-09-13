/// business_provider.dart
/// Purpose: Riverpod state management for the Virtual Business Engine.
///          Loads/creates BusinessModel from Hive, exposes weekly decisions,
///          compliance actions, and transfers weekly profit to the wallet.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/business/models/business_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class BusinessState {
  const BusinessState({
    this.business,
    this.isLoading = false,
  });

  final BusinessModel? business;
  final bool isLoading;

  bool get hasBusiness => business != null;

  BusinessState copyWith({BusinessModel? business, bool? isLoading}) {
    return BusinessState(
      business: business ?? this.business,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weekly Decision Model
// ─────────────────────────────────────────────────────────────────────────────

class WeeklyDecision {
  const WeeklyDecision({
    required this.label,
    required this.description,
    required this.revenueDelta,
    required this.expenseDelta,
    required this.lesson,
  });

  final String label;
  final String description;
  final int revenueDelta;
  final int expenseDelta;
  final String lesson;
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class BusinessNotifier extends StateNotifier<BusinessState> {
  BusinessNotifier(this._box, this._ref) : super(const BusinessState()) {
    _load();
  }

  final Box<BusinessModel> _box;
  final Ref _ref;

  String get _uid => _ref.read(currentUserProvider)?.uid ?? '';

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    final uid = _uid;
    if (uid.isEmpty) {
      state = const BusinessState();
      return;
    }
    final biz = _box.get(uid);
    if (biz != null) await _maybeTransferWeeklyProfit(biz);
    state = BusinessState(business: biz, isLoading: false);
  }

  // ── Setup ──────────────────────────────────────────────────────────────────

  Future<void> setupBusiness({
    required String businessName,
    required String businessType,
  }) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    final base = BusinessModel.baseRevenue[businessType] ?? 500;
    final biz = BusinessModel(
      uid: uid,
      businessName: businessName,
      businessType: businessType,
      weeklyRevenue: base,
      weeklyExpenses: (base * 0.65).round(),
    );
    await _box.put(uid, biz);
    state = state.copyWith(business: biz);
  }

  // ── Make weekly decision ───────────────────────────────────────────────────

  Future<void> makeDecision(WeeklyDecision decision) async {
    final biz = state.business;
    if (biz == null) return;

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    biz
      ..weeklyRevenue =
          (biz.weeklyRevenue + decision.revenueDelta).clamp(100, 50000)
      ..weeklyExpenses =
          (biz.weeklyExpenses + decision.expenseDelta).clamp(50, 40000)
      ..totalProfit += biz.weeklyProfit
      ..lastDecisionDateStr = todayStr
      ..addEvent('⚙️ ${decision.label}: ${decision.description}');

    // Stage progression: every 5,000 ZMW total profit = next stage
    final newStage = ((biz.totalProfit / 5000).floor() + 1).clamp(1, 5);
    if (newStage > biz.stage) {
      biz.stage = newStage;
      biz.addEvent('🎉 Business reached ${biz.stageName}!');
      await _ref
          .read(authProvider.notifier)
          .addWalletCoins(kBusinessStageUpReward);
    }

    await biz.save();
    state = state.copyWith(business: biz);
  }

  // ── Register PACRA ─────────────────────────────────────────────────────────

  Future<bool> registerPacra() async {
    final biz = state.business;
    if (biz == null || biz.pacraRegistered) return false;
    const cost = 150;
    final wallet = _ref.read(currentUserProvider)?.walletBalance ?? 0;
    if (wallet < cost) return false;
    await _ref.read(authProvider.notifier).addWalletCoins(-cost);
    biz
      ..pacraRegistered = true
      ..addEvent('🏛️ PACRA registration completed — business is now official!');
    biz.recalcCompliance();
    await biz.save();
    state = state.copyWith(business: biz);
    return true;
  }

  // ── File ZRA tax ───────────────────────────────────────────────────────────

  Future<bool> fileZraTax() async {
    final biz = state.business;
    if (biz == null || biz.zraTaxFiled) return false;
    biz
      ..zraTaxFiled = true
      ..addEvent('📋 ZRA turnover tax filed — staying compliant!');
    biz.recalcCompliance();
    await biz.save();
    state = state.copyWith(business: biz);
    return true;
  }

  // ── Contribute NAPSA ───────────────────────────────────────────────────────

  Future<bool> contributeNapssa() async {
    final biz = state.business;
    if (biz == null || biz.napssaContributed) return false;
    biz
      ..napssaContributed = true
      ..staff = (biz.staff + 1).clamp(1, 99)
      ..addEvent('👷 NAPSA contributions active — staff protected!');
    biz.recalcCompliance();
    await biz.save();
    state = state.copyWith(business: biz);
    return true;
  }

  // ── Apply life event compliance delta ──────────────────────────────────────

  Future<void> applyComplianceDelta(int delta, String eventDesc) async {
    final biz = state.business;
    if (biz == null) return;
    biz
      ..complianceScore = (biz.complianceScore + delta).clamp(0, 100)
      ..addEvent(eventDesc);
    await biz.save();
    state = state.copyWith(business: biz);
  }

  // ── Weekly profit transfer ──────────────────────────────────────────────────

  Future<void> _maybeTransferWeeklyProfit(BusinessModel biz) async {
    final last = DateTime.tryParse(biz.lastWeeklyUpdateStr);
    final now = DateTime.now();
    if (last != null && now.difference(last).inDays < 7) return;

    final profit = biz.weeklyProfit;
    if (profit > 0) {
      await _ref.read(authProvider.notifier).addWalletCoins(profit);
      biz.addEvent('💰 Weekly profit of ZMW $profit transferred to wallet!');
    } else if (profit < 0) {
      await _ref.read(authProvider.notifier).addWalletCoins(profit);
      biz.addEvent('📉 Business made a loss of ZMW ${profit.abs()} this week.');
    }

    biz.lastWeeklyUpdateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await biz.save();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weekly Decisions Pool
// ─────────────────────────────────────────────────────────────────────────────

const List<WeeklyDecision> kWeeklyDecisions = [
  WeeklyDecision(
    label: 'Invest in marketing',
    description: 'Spend on flyers and social media to attract more customers.',
    revenueDelta: 150,
    expenseDelta: 80,
    lesson: 'Marketing ROI in SMEs averages 3:1. Consistent promotion builds customer habit.',
  ),
  WeeklyDecision(
    label: 'Hire a part-time assistant',
    description: 'Add capacity to handle growing demand.',
    revenueDelta: 200,
    expenseDelta: 120,
    lesson: 'Hiring expands capacity but must be matched by revenue growth. Track your labour ratio.',
  ),
  WeeklyDecision(
    label: 'Bulk-buy stock',
    description: 'Buy 3 months of stock at a 10% discount.',
    revenueDelta: 80,
    expenseDelta: -50,
    lesson: 'Bulk purchasing reduces unit costs. Pair it with proper stock management to avoid wastage.',
  ),
  WeeklyDecision(
    label: 'Expand opening hours',
    description: 'Open evenings and weekends to capture more sales.',
    revenueDelta: 120,
    expenseDelta: 40,
    lesson: 'Extended hours increase revenue but require careful energy and staff cost management.',
  ),
  WeeklyDecision(
    label: 'Introduce mobile money payments',
    description: 'Accept MTN MoMo and Airtel Money to reduce cash friction.',
    revenueDelta: 100,
    expenseDelta: 10,
    lesson: 'Mobile money adoption in Zambia is above 60%. Cashless acceptance expands your customer base.',
  ),
  WeeklyDecision(
    label: 'Cut unnecessary subscriptions',
    description: 'Audit and cancel services you no longer use.',
    revenueDelta: 0,
    expenseDelta: -60,
    lesson: 'Regular expense audits are as valuable as revenue growth. Every kwacha saved is a kwacha earned.',
  ),
  WeeklyDecision(
    label: 'Partner with a delivery service',
    description: 'Offer home delivery through a local boda boda network.',
    revenueDelta: 180,
    expenseDelta: 70,
    lesson: 'Last-mile delivery expands your market radius without a physical second location.',
  ),
  WeeklyDecision(
    label: 'Invest in staff training',
    description: 'Send your team to a free TEVETA skills workshop.',
    revenueDelta: 60,
    expenseDelta: 20,
    lesson: 'TEVETA offers free and subsidised training. Skilled staff reduce errors and improve customer satisfaction.',
  ),
  WeeklyDecision(
    label: 'Renegotiate supplier terms',
    description: 'Ask your supplier for 30-day credit instead of cash on delivery.',
    revenueDelta: 0,
    expenseDelta: -80,
    lesson: 'Supplier credit is free working capital. Long-term relationships unlock better terms.',
  ),
  WeeklyDecision(
    label: 'Launch a loyalty programme',
    description: 'Offer a stamp card — buy 9, get 1 free.',
    revenueDelta: 130,
    expenseDelta: 30,
    lesson: 'Loyalty programmes increase repeat purchase rates by 20–30%. Retention is cheaper than acquisition.',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final businessProvider =
    StateNotifierProvider<BusinessNotifier, BusinessState>((ref) {
  final box = Hive.box<BusinessModel>(kBusinessBox);
  final notifier = BusinessNotifier(box, ref);

  ref.listen(authProvider, (prev, next) {
    if (next.currentUser?.uid != prev?.currentUser?.uid) {
      notifier._load();
    }
  });

  return notifier;
});
