/// myth_provider.dart
/// Purpose: Manages myth-busting card gameplay — 3 cards/day, XP rewards,
///          heart penalties, and Hive persistence of seen/correct myth IDs.
library;

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/hearts/providers/hearts_provider.dart';
import 'package:zamwealth_quest/features/myths/models/myth_record.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

class MythCard {
  const MythCard({
    required this.id,
    required this.myth,
    required this.fact,
    required this.category,
    required this.xpReward,
  });
  final int    id;
  final String myth;
  final String fact;
  final String category;
  final int    xpReward;
}

const List<MythCard> kAllMyths = [
  MythCard(id: 1, myth: 'Keeping money in a tin at home is safe.', fact: 'At 14% inflation, ZMW 1,000 today is worth only ZMW 860 next year. Banks and mobile savings accounts protect your purchasing power.', category: 'Savings', xpReward: 15),
  MythCard(id: 2, myth: 'You need a lot of money to start investing.', fact: 'You can start on LuSE with as little as ZMW 500. Small, consistent investments grow significantly over time.', category: 'Investing', xpReward: 15),
  MythCard(id: 3, myth: 'Loans are always bad and should be avoided.', fact: 'Good debt builds assets — a business loan can generate income exceeding repayments. Bad debt buys depreciating liabilities.', category: 'Debt', xpReward: 20),
  MythCard(id: 4, myth: 'Mobile money is just for sending money to family.', fact: 'MTN MoMo and Airtel Money offer savings accounts, micro-loans, and insurance products directly on your phone.', category: 'Technology', xpReward: 15),
  MythCard(id: 5, myth: 'Only rich people need to budget their money.', fact: 'Budgeting is how you become rich. It works at any income level — even ZMW 500/month benefits from a simple plan.', category: 'Budgeting', xpReward: 10),
  MythCard(id: 6, myth: 'You must pay tax only if you have a formal job.', fact: 'Self-employed traders, farmers, and informal businesses must register with ZRA. The turnover tax rate is just 4% for small businesses.', category: 'Tax', xpReward: 25),
  MythCard(id: 7, myth: 'Insurance is a waste of money if nothing goes wrong.', fact: 'One medical emergency can wipe out years of savings. Insurance transfers catastrophic risk so your savings stay intact.', category: 'Insurance', xpReward: 20),
  MythCard(id: 8, myth: 'A salary is the only source of income worth having.', fact: 'Passive income from rent, dividends, and interest can exceed salary. Many Zambian wealth builders have 3+ income streams.', category: 'Income', xpReward: 20),
  MythCard(id: 9, myth: 'NAPSA deductions are just a government tax you never see again.', fact: 'NAPSA is your pension fund — you receive it at retirement with interest. You can also use it as loan collateral at some banks.', category: 'Retirement', xpReward: 25),
  MythCard(id: 10, myth: 'Businesses always need a physical shop to succeed.', fact: 'Many Zambian businesses operate profitably on WhatsApp and Facebook alone, with zero shop rental costs.', category: 'Business', xpReward: 15),
  MythCard(id: 11, myth: 'Exchange rates don\'t affect you if you don\'t travel abroad.', fact: 'A weak kwacha raises the price of fuel, cooking oil, and imports — affecting your cost of living even without leaving Zambia.', category: 'Economics', xpReward: 20),
  MythCard(id: 12, myth: 'Compound interest only benefits banks, not ordinary savers.', fact: 'A savings account earning 8% p.a. doubles your money in 9 years through compounding — the same principle that works for banks works for you.', category: 'Savings', xpReward: 20),
  MythCard(id: 13, myth: 'You need a formal job history to have a credit score.', fact: 'Mobile money transaction history and consistent loan repayments through MFIs build your creditworthiness even without formal employment.', category: 'Credit', xpReward: 20),
  MythCard(id: 14, myth: 'PACRA registration is just bureaucracy with no real benefit.', fact: 'PACRA registration gives your business legal standing to open bank accounts, access CEEC grants, and sign enforceable contracts.', category: 'Business', xpReward: 25),
  MythCard(id: 15, myth: 'CEEC grants are only available to large, established businesses.', fact: 'CEEC has youth and women-specific grants starting from ZMW 50,000 targeted at small enterprises and first-time entrepreneurs.', category: 'Grants', xpReward: 25),
  MythCard(id: 16, myth: 'Farming is not a reliable investment in Zambia.', fact: 'Agricultural exports earned Zambia over USD 200 million in 2023. FRA floor prices protect smallholders from price crashes.', category: 'Agriculture', xpReward: 20),
  MythCard(id: 17, myth: 'School fees should just come from your monthly salary when due.', fact: 'Setting aside ZMW 150/month in a dedicated savings plan means ZMW 450 school fees arrive stress-free, every term.', category: 'Education', xpReward: 15),
  MythCard(id: 18, myth: 'Emergency funds are pessimistic — nothing bad will happen.', fact: '67% of Zambians surveyed cited unexpected medical costs as their top cause of debt. An emergency fund is your first line of defence.', category: 'Emergency', xpReward: 20),
  MythCard(id: 19, myth: 'Micro-insurance is too expensive for low-income earners.', fact: 'Some micro-insurance products in Zambia cost as little as ZMW 5/month via mobile money — less than a single airtime recharge.', category: 'Insurance', xpReward: 20),
  MythCard(id: 20, myth: 'Cash is always safer than digital payments.', fact: 'Digital payments create a traceable record that protects you in disputes, and your balance can\'t be stolen from your pocket.', category: 'Technology', xpReward: 15),
  MythCard(id: 21, myth: 'Inflation only matters for imported goods, not local prices.', fact: 'Local fuel, transport, maize meal, and vegetables all rise with inflation — even purely local households are affected.', category: 'Economics', xpReward: 20),
  MythCard(id: 22, myth: 'You must be completely debt-free before you can start investing.', fact: 'If investment returns exceed your loan interest rate, investing while repaying debt grows your net worth faster overall.', category: 'Investing', xpReward: 25),
  MythCard(id: 23, myth: 'Bank accounts are only useful for storing your salary.', fact: 'A bank account builds your financial history, makes you eligible for mortgages and business loans, and enables digital payments.', category: 'Banking', xpReward: 15),
  MythCard(id: 24, myth: 'Saving ZMW 20 a day is too small to make any difference.', fact: 'ZMW 20/day = ZMW 7,300/year — enough for a laptop, a skills course, or startup capital for a small business.', category: 'Savings', xpReward: 15),
  MythCard(id: 25, myth: 'Stocks are only for people with economics or finance degrees.', fact: 'LuSE has investor education programs and licensed stockbrokers who guide first-time investors through every step.', category: 'Investing', xpReward: 20),
  MythCard(id: 26, myth: 'You need ZMW 10,000 or more to open a business bank account.', fact: 'Many Zambian banks offer SME accounts with opening balances as low as ZMW 500, plus free mobile banking.', category: 'Banking', xpReward: 15),
  MythCard(id: 27, myth: 'Women cannot own or register land in their own name in Zambia.', fact: 'The Lands Act of Zambia grants every citizen equal right to own land regardless of gender. Women can and do hold title deeds.', category: 'Property', xpReward: 25),
  MythCard(id: 28, myth: 'NAPSA only pays out after you retire at age 65.', fact: 'NAPSA also provides invalidity grants, survivors\' benefits, and early withdrawal provisions if you qualify before retirement.', category: 'Retirement', xpReward: 25),
  MythCard(id: 29, myth: 'Earning a bigger salary automatically makes you wealthier.', fact: 'Lifestyle inflation causes many high earners to save less (as a percentage) than lower earners. Income without discipline creates no wealth.', category: 'Income', xpReward: 20),
  MythCard(id: 30, myth: 'Financial planning is only necessary when you\'re older.', fact: 'Starting at 25 vs 35 can mean double the retirement savings due to compounding. The best time to plan is always now.', category: 'Planning', xpReward: 20),
];

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class MythState {
  const MythState({
    this.record,
    this.isLoading = false,
    this.lastAnswerCorrect,
    this.currentIndex = 0,
    this.showingFact = false,
  });
  final MythRecord? record;
  final bool        isLoading;
  final bool?       lastAnswerCorrect;
  final int         currentIndex;   // index into todaysMyths list
  final bool        showingFact;

  List<MythCard> get todaysMyths {
    final ids = record?.todaysMythIds ?? [];
    return ids.map((id) => kAllMyths.firstWhere((m) => m.id == id)).toList();
  }

  MythCard? get currentMyth {
    final myths = todaysMyths;
    if (currentIndex >= myths.length) { return null; }
    return myths[currentIndex];
  }

  bool get sessionComplete => currentIndex >= todaysMyths.length;

  MythState copyWith({
    MythRecord? record,
    bool? isLoading,
    bool? lastAnswerCorrect,
    int? currentIndex,
    bool? showingFact,
  }) {
    return MythState(
      record: record ?? this.record,
      isLoading: isLoading ?? this.isLoading,
      lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
      currentIndex: currentIndex ?? this.currentIndex,
      showingFact: showingFact ?? this.showingFact,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class MythNotifier extends StateNotifier<MythState> {
  MythNotifier(this._ref) : super(const MythState(isLoading: true)) {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.currentUser?.uid != next.currentUser?.uid) { _load(); }
    });
    _load();
  }

  final Ref _ref;
  Box<MythRecord> get _box => Hive.box<MythRecord>(kMythsBox);
  String? get _uid => _ref.read(currentUserProvider)?.uid;

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      state = const MythState();
      return;
    }
    var record = _box.get(uid);
    if (record == null) {
      record = MythRecord(
        uid: uid,
        seenMythIds: [],
        correctMythIds: [],
        totalMythsAnswered: 0,
        lastDailyDateStr: '',
        todaysMythIds: [],
      );
      await _box.put(uid, record);
    }
    _refreshDailySet(record);
    state = MythState(record: _box.get(uid));
  }

  void _refreshDailySet(MythRecord record) {
    final today = _todayStr();
    if (record.lastDailyDateStr == today && record.todaysMythIds.length == kMythsPerDay) { return; }

    final seen = Set<int>.from(record.seenMythIds);
    final unseen = kAllMyths.where((m) => !seen.contains(m.id)).toList();
    final pool = unseen.isEmpty ? List<MythCard>.from(kAllMyths) : unseen;
    pool.shuffle(Random());
    final chosen = pool.take(kMythsPerDay).map((m) => m.id).toList();

    record.lastDailyDateStr = today;
    record.todaysMythIds = chosen;
    record.save();
  }

  /// Called when player swipes. [answeredIsMyth] = true means LEFT swipe ("it's a myth").
  /// All our cards ARE myths, so correct answer is always true.
  Future<void> submitAnswer({required bool answeredIsMyth}) async {
    final myth = state.currentMyth;
    if (myth == null || state.showingFact) { return; }

    final correct = answeredIsMyth; // all cards are myths so left is always correct
    state = state.copyWith(showingFact: true, lastAnswerCorrect: correct);

    final record = state.record;
    if (record == null) { return; }

    if (!record.seenMythIds.contains(myth.id)) {
      record.seenMythIds.add(myth.id);
    }
    if (correct && !record.correctMythIds.contains(myth.id)) {
      record.correctMythIds.add(myth.id);
    }
    record.totalMythsAnswered += 1;
    await record.save();

    if (correct) {
      await _ref.read(authProvider.notifier).addXp(myth.xpReward);
    } else {
      await _ref.read(heartsProvider.notifier).loseHeart();
    }
    state = state.copyWith(record: _box.get(record.uid));
  }

  void advanceCard() {
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      showingFact: false,
      lastAnswerCorrect: null,
    );
  }

  Future<void> refresh() => _load();

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final mythProvider = StateNotifierProvider<MythNotifier, MythState>(
  (ref) => MythNotifier(ref),
);
