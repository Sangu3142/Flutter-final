/// daily_routine_provider.dart
/// Purpose: Manages the 3-part daily financial routine — morning tip,
///          midday quiz, and evening reflection. Tracks perfect day streaks.
library;

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/daily_routine/models/daily_routine_record.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Morning Tips Pool (60 Zambian-specific tips)
// ─────────────────────────────────────────────────────────────────────────────

const List<String> kMorningTips = [
  'The Bank of Zambia recommends saving at least 10% of your monthly income — that\'s ZMW 650 for every ZMW 6,500 earned.',
  'NAPSA contributions give you a pension AND can be used as loan collateral at some Zambian banks.',
  'ZRA\'s turnover tax is only 4% for businesses earning under ZMW 800,000 per year — far lower than income tax.',
  'LuSE-listed government bonds have historically returned 12–15% per annum — more than most bank savings accounts.',
  'A chilimba (savings group) with 10 members saving ZMW 200/month each gives every member ZMW 2,000 once per year.',
  'MTN MoMo and Airtel Money both offer savings pockets that earn interest on your mobile wallet balance.',
  'CEEC youth grants of up to ZMW 100,000 are available for Zambians aged 18–35 with a registered business.',
  'DBZ (Development Bank of Zambia) offers SME loans at rates lower than commercial banks — worth exploring.',
  'The average Zambian saves less than 5% of income. Targeting 15% puts you ahead of 90% of your peers.',
  'PACRA business registration can be done online at pacra.org.zm for under ZMW 500.',
  'Every ZMW 100 invested at 12% annual return becomes ZMW 311 in 10 years without adding anything extra.',
  'Inflation at 14% means your ZMW 1,000 today needs to grow to ZMW 1,140 next year just to maintain its value.',
  'ZRA allows small businesses to file and pay tax online through eTax — no queues required.',
  'A formal bank account creates a financial track record that makes you eligible for larger loans in future.',
  'Food inflation in Zambia often runs higher than headline inflation — budget for food costs to rise 15–20% yearly.',
  'Agro-input subsidies from FISP are available to smallholder farmers — register at your district agriculture office.',
  'Medical costs are the number one cause of unexpected debt in Zambia. A micro-insurance policy for ZMW 30/month can protect you.',
  'The minimum monthly NAPSA contribution is 10% of your gross salary — but you own the full amount at retirement.',
  'Zambia Revenue Authority offers tax amnesty periods — check ZRA.org.zm for current programmes.',
  'A budget is a spending plan, not a restriction. It gives every kwacha a purpose before it arrives.',
  'Compound interest works for you in savings and against you in debt. Understand which side you\'re on.',
  'The average Zambian spends 60% of income on food. Reducing this to 40% can free ZMW 600+ per month to invest.',
  'ZANACO, Atlas Mara, and Absa all offer business accounts with features tailored for SMEs.',
  'The kwacha has lost 40% of its value against the USD in the last decade — your ZMW savings need to outpace this.',
  'Green bonds and environmental investment funds are now available on LuSE for sustainability-focused investors.',
  'A smartphone with a mobile money app is a bank in your pocket — use the savings and payment features, not just calls.',
  'NAPSA accepts contributions from self-employed workers — you can register and contribute voluntarily.',
  'School fees paid in advance often attract a 5–10% discount. A school fees savings pot makes this possible.',
  'Rental income from a single room can add ZMW 1,000–3,000/month to your income with minimal management.',
  'ZMW 50 saved daily = ZMW 18,250 per year. That\'s enough for a small business, a skills course, or a laptop.',
  'The LuSE All Share Index has outperformed inflation in 7 of the last 10 years.',
  'Bank of Zambia\'s financial literacy resources are free at boz.zm — designed specifically for Zambian consumers.',
  'An emergency fund covering 3 months of expenses is the single most protective financial move you can make.',
  'Joint savings accounts with a spouse can double your savings rate — negotiate and align your goals together.',
  'ZICTA\'s Digital Zambia grants support entrepreneurs building digital businesses and solutions.',
  'Buying airtime in bulk or data bundles almost always costs less per unit than buying daily.',
  'A clear 5-year financial plan increases your probability of achieving it by 42% (financial behaviour research).',
  'Government infrastructure bonds often carry no withholding tax — ask your stockbroker about eligibility.',
  'FSDZ (Financial Sector Deepening Zambia) publishes free research on Zambian household finance — very useful reading.',
  'ZMW 1,000 in a 12% savings product becomes ZMW 3,106 in 10 years. Patience is a financial strategy.',
  'Paying yourself first — transferring savings before any spending — is the #1 habit of wealthy Zambians.',
  'Most micro-finance institutions in Zambia lend to groups, not individuals. Joining a group improves your loan access.',
  'The ZABS (Zambia Bureau of Standards) certification can open export markets for your products.',
  'Price negotiation is financial skill. Negotiate rent, supplier prices, and loan rates — many Zambians pay more than needed.',
  'Maize meal, cooking oil, and fuel account for over 60% of basic budget costs. Track these specifically.',
  'ZRA\'s presumptive tax for small transport operators is assessed per vehicle, not per profit — know what applies to you.',
  'Zambia\'s National Financial Inclusion Strategy targets 80% financial inclusion by 2026 — more products are coming.',
  'Solar energy investments can reduce electricity bills by 60–80% — the return on a solar system can be under 3 years.',
  'Life insurance premiums in Zambia start from ZMW 50/month for ZMW 50,000 coverage — it\'s affordable protection.',
  'Dividend reinvestment plans on LuSE automatically reinvest your dividends into more shares — compounding made easy.',
  'The Rule of 72: divide 72 by your interest rate to find how many years it takes to double your money. At 12%, it\'s 6 years.',
  'Property management companies can manage your rental property for 10% of rent — turning passive income truly passive.',
  'Electricity cost-saving appliances reduce monthly utility bills by ZMW 200–500 in most Lusaka households.',
  'Zambia\'s formal banking sector serves only 30% of adults — mobile money is bridging this gap rapidly.',
  'A will ensures your assets reach your family. Legal aid and PACRA resources make it affordable to write one.',
  'The best time to invest was 10 years ago. The second best time is today. Start with whatever you have.',
  'Supplier credit — buying goods now and paying in 30 days — is a form of interest-free financing if managed well.',
  'ZMW 200/month invested from age 25 grows to ZMW 702,000 by age 60 at 12% annual return.',
  'Transport cost is often a hidden budget item — tracking it reveals savings opportunities of ZMW 300–600/month.',
  'Agricultural value-addition (processing, packaging) multiplies farm income by 2–5x with the same raw product.',
  'ZRA has a taxpayer education unit — call them or visit your nearest ZRA office for free advice on your obligations.',
];

// ─────────────────────────────────────────────────────────────────────────────
// Evening Reflection Prompts Pool
// ─────────────────────────────────────────────────────────────────────────────

const List<String> kEveningPrompts = [
  'Did you spend money on a want today? What was it, and was it worth it?',
  'What is one financial habit you want to improve this week?',
  'If you earned ZMW 1,000 extra today, what would you do with it?',
  'What was the most valuable thing you learned about money this week?',
  'Name one expense from today that you could have avoided. How much would that save per month?',
  'What financial goal feels closest to being achieved? What would it take to reach it this month?',
  'Did you check your wallet or bank balance today? What surprised you?',
  'What is one thing your parents taught you about money — good or bad?',
  'If you had to cut ZMW 500 from your monthly spending, what would go first?',
  'What does financial freedom mean to you, and what is one step you can take towards it tomorrow?',
];

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class DailyRoutineState {
  const DailyRoutineState({this.record, this.isLoading = false});
  final DailyRoutineRecord? record;
  final bool                isLoading;

  bool get morningDone  => record?.morningDoneToday  ?? false;
  bool get middayDone   => record?.middayDoneToday   ?? false;
  bool get eveningDone  => record?.eveningDoneToday  ?? false;
  bool get perfectToday => record?.perfectDayToday   ?? false;

  int get completedCount => [morningDone, middayDone, eveningDone]
      .where((b) => b)
      .length;

  int get perfectDaysTotal  => record?.perfectDaysTotal  ?? 0;
  int get perfectDayStreak  => record?.currentPerfectDayStreak ?? 0;
  List<String> get journal  => record?.reflectionJournal ?? [];

  String get todaysMorningTip {
    final day = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return kMorningTips[day % kMorningTips.length];
  }

  String get todaysEveningPrompt {
    final day = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return kEveningPrompts[day % kEveningPrompts.length];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class DailyRoutineNotifier extends StateNotifier<DailyRoutineState> {
  DailyRoutineNotifier(this._ref) : super(const DailyRoutineState(isLoading: true)) {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.currentUser?.uid != next.currentUser?.uid) { _load(); }
    });
    _load();
  }

  final Ref _ref;
  Box<DailyRoutineRecord> get _box => Hive.box<DailyRoutineRecord>(kDailyRoutineBox);
  String? get _uid => _ref.read(currentUserProvider)?.uid;

  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      state = const DailyRoutineState();
      return;
    }
    var record = _box.get(uid);
    if (record == null) {
      record = DailyRoutineRecord(
        uid: uid,
        lastMorningDateStr: '',
        lastMiddayDateStr: '',
        lastEveningDateStr: '',
        lastPerfectDayDateStr: '',
        reflectionJournal: [],
        perfectDaysTotal: 0,
        currentPerfectDayStreak: 0,
        lastStreakDateStr: '',
      );
      await _box.put(uid, record);
    }
    state = DailyRoutineState(record: _box.get(uid));
  }

  Future<void> completeMorningTip() async {
    final record = state.record;
    if (record == null || record.morningDoneToday) { return; }
    record.lastMorningDateStr = _todayStr();
    await record.save();
    await _ref.read(authProvider.notifier).addXp(kMorningTipXp);
    await _checkPerfectDay(record);
    state = DailyRoutineState(record: _box.get(record.uid));
  }

  Future<void> completeMiddayQuiz() async {
    final record = state.record;
    if (record == null || record.middayDoneToday) { return; }
    record.lastMiddayDateStr = _todayStr();
    await record.save();
    await _ref.read(authProvider.notifier).addXp(kMiddayQuizXp);
    await _checkPerfectDay(record);
    state = DailyRoutineState(record: _box.get(record.uid));
  }

  Future<void> submitEveningReflection(String text) async {
    final record = state.record;
    if (record == null || record.eveningDoneToday || text.trim().isEmpty) { return; }
    final today = _todayStr();
    final entry = '[$today] ${text.trim()}';
    record.reflectionJournal.add(entry);
    record.lastEveningDateStr = today;
    await record.save();
    await _ref.read(authProvider.notifier).addXp(kEveningReflectionXp);
    await _checkPerfectDay(record);
    state = DailyRoutineState(record: _box.get(record.uid));
  }

  Future<void> _checkPerfectDay(DailyRoutineRecord record) async {
    if (!record.morningDoneToday || !record.middayDoneToday || !record.eveningDoneToday) { return; }
    if (record.perfectDayToday) { return; }

    record.lastPerfectDayDateStr = _todayStr();
    record.perfectDaysTotal += 1;
    await record.save();
    await _ref.read(authProvider.notifier).addXp(kPerfectDayXp);
    await _ref.read(authProvider.notifier).addWalletCoins(kPerfectDayCoins);

    // Update streak
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yStr =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2,'0')}-${yesterday.day.toString().padLeft(2,'0')}';
    if (record.lastStreakDateStr == yStr) {
      record.currentPerfectDayStreak += 1;
    } else {
      record.currentPerfectDayStreak = 1;
    }
    record.lastStreakDateStr = _todayStr();
    await record.save();

    // Perfect week bonus
    if (record.currentPerfectDayStreak >= kPerfectWeekStreak &&
        record.currentPerfectDayStreak % kPerfectWeekStreak == 0) {
      await _ref.read(authProvider.notifier).addWalletCoins(kPerfectWeekCoins);
    }
  }

  /// Returns the last 30 days as a list of (dateStr, completionCount 0-3).
  List<({String date, int count})> last30Days() {
    final record = state.record;
    final result = <({String date, int count})>[];
    for (int i = 29; i >= 0; i--) {
      final d = DateTime.now().subtract(Duration(days: i));
      final ds = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
      int count = 0;
      if (record != null) {
        // Approximate: only perfect days are persisted precisely
        if (record.lastPerfectDayDateStr == ds) { count = 3; }
      }
      result.add((date: ds, count: count));
    }
    return result;
  }

  Future<void> refresh() => _load();

  // Expose a random tip for the morning section
  String get randomTip => kMorningTips[Random().nextInt(kMorningTips.length)];
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final dailyRoutineProvider =
    StateNotifierProvider<DailyRoutineNotifier, DailyRoutineState>(
  (ref) => DailyRoutineNotifier(ref),
);
