/// mentor_provider.dart
/// Purpose: Manages mentor unlock logic, daily tips, and challenge tracking.
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/health/providers/health_provider.dart';
import 'package:zamwealth_quest/features/levels/providers/level_provider.dart';
import 'package:zamwealth_quest/features/mentors/models/mentor_record.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

class MentorData {
  const MentorData({
    required this.id,
    required this.name,
    required this.role,
    required this.specialty,
    required this.emoji,
    required this.dailyTips,
    required this.challenge,
    required this.badgeId,
    required this.challengeXp,
  });
  final String       id;
  final String       name;
  final String       role;
  final String       specialty;
  final String       emoji;
  final List<String> dailyTips;
  final String       challenge;
  final String       badgeId;
  final int          challengeXp;
}

const List<MentorData> kAllMentors = [
  MentorData(
    id: 'tembo',
    name: 'Tembo Mwanza',
    role: 'Bank Manager',
    specialty: 'Loans, credit scores, and banking products',
    emoji: '🏦',
    challengeXp: 50,
    badgeId: 'tembos_apprentice',
    challenge: 'Calculate the true total cost of a ZMW 5,000 loan at 25% annual interest over 24 months.',
    dailyTips: [
      'Pay more than the minimum on your loan each month — every extra ZMW reduces total interest paid.',
      'Check your credit score every 6 months. Small errors can cost you loan approval.',
      'A savings account with the same bank that holds your loan can improve your interest rate.',
      'Overdue payments hurt your credit for up to 5 years. One missed month costs far more than the payment.',
      'Ask your bank about balance transfer options if your loan interest exceeds 30% — some MFIs offer better rates.',
      'NAPSA contributions can serve as loan collateral at certain banks. Ask your branch manager.',
      'Building a 6-month banking relationship before applying for a loan increases your approval chances significantly.',
    ],
  ),
  MentorData(
    id: 'nalukui',
    name: 'Nalukui Siame',
    role: 'LuSE Stockbroker',
    specialty: 'Stocks, investments, and LuSE market strategy',
    emoji: '📈',
    challengeXp: 75,
    badgeId: 'market_insider',
    challenge: 'Build a ZMW 5,000 portfolio across 3 different asset classes using LuSE tools.',
    dailyTips: [
      'Diversify — never put all your ZMW in one stock. Spread across sectors.',
      'Dividend stocks provide passive income. Reinvest dividends to compound your returns.',
      'LuSE blue-chips have historically outperformed savings accounts over 5-year periods.',
      'Government bonds offer guaranteed 12–15% returns with zero risk. Every portfolio should have some.',
      'Invest consistently, not just when the market is rising. Buy more when prices fall.',
      'A portfolio review every 3 months keeps you aligned with your financial goals.',
      'Long-term thinking beats short-term trading. The best Zambian investors hold for years, not weeks.',
    ],
  ),
  MentorData(
    id: 'bwalya',
    name: 'Bwalya Phiri',
    role: 'PACRA Registration Officer',
    specialty: 'Business registration, compliance, and growth',
    emoji: '📋',
    challengeXp: 75,
    badgeId: 'registered_entrepreneur',
    challenge: 'Complete the PACRA registration simulation and understand what each document does.',
    dailyTips: [
      'A registered business can access bank loans, CEEC grants, and supplier credit.',
      'PACRA registration costs under ZMW 500 and takes as little as 2 business days online.',
      'Registered businesses can sign legally enforceable contracts — protecting you in disputes.',
      'Your business name is protected once registered — competitors cannot trade under it.',
      'Annual returns filing with PACRA costs ZMW 150 and keeps your registration active.',
      'A registered business can employ staff and comply with NAPSA — opening you to formal markets.',
      'CEEC, DBZ, and ZANACO all require PACRA registration as a condition for SME financing.',
    ],
  ),
  MentorData(
    id: 'chanda',
    name: 'Chanda Mutale',
    role: 'ZRA Tax Agent',
    specialty: 'Tax filing, compliance, and ZRA processes',
    emoji: '🧾',
    challengeXp: 75,
    badgeId: 'tax_compliant',
    challenge: 'File a virtual ZRA quarterly return for a simulated small business.',
    dailyTips: [
      'File your ZRA returns on time — the penalty for late filing can exceed what you owe in tax.',
      'Turnover tax is only 4% for businesses earning under ZMW 800,000 per year. It\'s manageable.',
      'Keep all receipts and invoices — they are your defence if ZRA ever audits your business.',
      'PAYE must be remitted to ZRA by the 14th of the following month. Late payments attract 5% interest.',
      'VAT registration is required once your annual turnover exceeds ZMW 800,000. Plan for it.',
      'ZRA\'s eTax portal allows filing and payment online — no queues required.',
      'Tax-deductible expenses reduce your taxable income. Know what qualifies for your business type.',
    ],
  ),
  MentorData(
    id: 'mwansa',
    name: 'Mwansa Kapwepwe',
    role: 'Financial Wellness Coach',
    specialty: 'Overall financial health and holistic wealth-building',
    emoji: '🌟',
    challengeXp: 100,
    badgeId: 'financial_champion',
    challenge: 'Improve your Financial Health Score by at least 10 points over the next two weeks.',
    dailyTips: [
      'Your Financial Health Score reflects your habits, not your luck. Small consistent improvements compound.',
      'Track every ZMW you spend for one week. Awareness alone reduces spending by 15% on average.',
      'Set a spending limit for wants — not zero, but a conscious budget. Joy and discipline coexist.',
      'The emergency fund is your foundation. Without it, every crisis becomes a debt spiral.',
      'Net worth > income. Two people earning ZMW 10,000 can have vastly different net worths based on habits.',
      'Review your budget at the start of each month, not the end. Planning beats reviewing every time.',
      'Every financial habit you build now is compounding quietly. Trust the process.',
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class MentorState {
  const MentorState({this.record, this.isLoading = false});
  final MentorRecord? record;
  final bool          isLoading;

  bool isUnlocked(String mentorId) =>
      record?.unlockedMentorIds.contains(mentorId) ?? false;

  bool isChallengeCompleted(String mentorId) {
    final json = record?.challengesCompletedJson ?? '{}';
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return (map[mentorId] as int? ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }

  String dailyTipFor(String mentorId) {
    final mentor = kAllMentors.firstWhere((m) => m.id == mentorId,
        orElse: () => kAllMentors.first);
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return mentor.dailyTips[dayOfYear % mentor.dailyTips.length];
  }

  MentorData? get featuredMentor {
    final unlocked = record?.unlockedMentorIds ?? [];
    if (unlocked.isEmpty) { return null; }
    // Rotate which mentor is featured each day
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final id = unlocked[dayOfYear % unlocked.length];
    try {
      return kAllMentors.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class MentorNotifier extends StateNotifier<MentorState> {
  MentorNotifier(this._ref) : super(const MentorState(isLoading: true)) {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.currentUser?.uid != next.currentUser?.uid) { _load(); }
    });
    _load();
  }

  final Ref _ref;
  Box<MentorRecord> get _box => Hive.box<MentorRecord>(kMentorsBox);
  String? get _uid => _ref.read(currentUserProvider)?.uid;

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      state = const MentorState();
      return;
    }
    var record = _box.get(uid);
    if (record == null) {
      record = MentorRecord(
        uid: uid,
        unlockedMentorIds: [],
        lastTipDatesJson: '{}',
        challengesCompletedJson: '{}',
      );
      await _box.put(uid, record);
    }
    await _checkUnlocks(record);
    state = MentorState(record: _box.get(uid));
  }

  Future<void> _checkUnlocks(MentorRecord record) async {
    final levels   = _ref.read(levelProvider).levels;
    final health   = _ref.read(healthProvider).data?.totalScore ?? 0;
    final user     = _ref.read(currentUserProvider);
    final unlocked = List<String>.from(record.unlockedMentorIds);
    bool changed   = false;

    bool lvlDone(int id) => levels[id]?.status == kStatusCompleted;

    if (lvlDone(2) && !unlocked.contains('tembo')) {
      unlocked.add('tembo');
      changed = true;
    }
    if (lvlDone(3) && !unlocked.contains('nalukui')) {
      unlocked.add('nalukui');
      changed = true;
    }
    if (lvlDone(4) && !unlocked.contains('bwalya')) {
      unlocked.add('bwalya');
      changed = true;
    }
    // Mentor 4 also requires a registered business (has PACRA compliance)
    if (lvlDone(4) && (user?.badges.contains('business_registered') ?? false) &&
        !unlocked.contains('chanda')) {
      unlocked.add('chanda');
      changed = true;
    }
    if (health >= kMentorHealthScoreUnlock && !unlocked.contains('mwansa')) {
      unlocked.add('mwansa');
      changed = true;
    }

    if (changed) {
      record.unlockedMentorIds = unlocked;
      await record.save();
    }
  }

  Future<void> completeChallenge(String mentorId) async {
    final record = state.record;
    if (record == null) { return; }
    final map = <String, dynamic>{};
    try {
      map.addAll(jsonDecode(record.challengesCompletedJson) as Map<String, dynamic>);
    } catch (_) {}
    map[mentorId] = (map[mentorId] as int? ?? 0) + 1;
    record.challengesCompletedJson = jsonEncode(map);
    await record.save();

    final mentor = kAllMentors.firstWhere((m) => m.id == mentorId,
        orElse: () => kAllMentors.first);
    await _ref.read(authProvider.notifier).addXp(mentor.challengeXp);
    state = MentorState(record: _box.get(record.uid));
  }

  Future<void> refresh() => _load();
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final mentorProvider = StateNotifierProvider<MentorNotifier, MentorState>(
  (ref) => MentorNotifier(ref),
);
