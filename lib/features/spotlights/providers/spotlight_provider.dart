/// spotlight_provider.dart
/// Purpose: Manages Zambian entrepreneur spotlight stories — chapter reading,
///          decision tracking, and Hive persistence.
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/levels/providers/level_provider.dart';
import 'package:zamwealth_quest/features/spotlights/models/spotlight_record.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data models (pure Dart — no Hive)
// ─────────────────────────────────────────────────────────────────────────────

class SpotlightDecision {
  const SpotlightDecision({
    required this.prompt,
    required this.choiceA,
    required this.choiceB,
    required this.consequenceA,
    required this.consequenceB,
  });
  final String prompt;
  final String choiceA;
  final String choiceB;
  final String consequenceA;
  final String consequenceB;
}

class SpotlightChapter {
  const SpotlightChapter({required this.title, required this.body});
  final String title;
  final String body;
}

class SpotlightStory {
  const SpotlightStory({
    required this.id,
    required this.title,
    required this.protagonist,
    required this.emoji,
    required this.chapters,
    required this.decisions,
    required this.endingA,
    required this.endingB,
    required this.xpReward,
    required this.unlockLevel,
  });
  final int    id;
  final String title;
  final String protagonist;
  final String emoji;
  final List<SpotlightChapter>  chapters;   // 5 chapters
  final List<SpotlightDecision> decisions;  // 3 decision points
  final String endingA;
  final String endingB;
  final int    xpReward;
  final int    unlockLevel; // min level completion required (1 = always unlocked)
}

const List<SpotlightStory> kAllSpotlights = [
  SpotlightStory(
    id: 1,
    title: "Mwape's Market Stall",
    protagonist: 'Mwape',
    emoji: '🍅',
    xpReward: 100,
    unlockLevel: 1,
    chapters: [
      SpotlightChapter(title: 'A New Beginning', body: "Mwape was 24 when she decided she was done waiting for a job that never came. With ZMW 500 borrowed from her mother and a borrowed chitenge laid out in Soweto Market, she started selling tomatoes.\n\nThe first day she made ZMW 80 in revenue. After costs, she kept ZMW 35. It wasn't much — but it was hers."),
      SpotlightChapter(title: 'The Decision', body: "After two months, Mwape had saved ZMW 600 in profit. Every morning she was at the market by 5am, every evening she counted her stock carefully.\n\nNow a friend offered to sell her a second-hand phone for ZMW 550 — so she could take orders on WhatsApp. Or she could reinvest everything into buying more stock and expanding her variety."),
      SpotlightChapter(title: 'Growing Pains', body: "The market was changing. A bigger supplier started undercutting prices. Mwape's margins shrunk. But her loyal customers kept coming because they trusted her quality.\n\nA local MFI offered her a ZMW 3,000 business loan at 30% interest to stock up before the rainy season rush. The opportunity was real, but so was the risk."),
      SpotlightChapter(title: 'Going Official', body: "Mwape's stall was now one of the busiest in her row. She was earning ZMW 1,800/month in profit. A PACRA official visited the market and explained business registration.\n\nRegistering would cost ZMW 400 and take two days. But it would open doors to a bank account, supplier credit, and the CEEC youth grant she'd heard about."),
      SpotlightChapter(title: 'The Outcome', body: "Mwape made her choices and lived with them. The market taught her that every decision compounds — small wins build big futures, and small mistakes, left uncorrected, build debt.\n\nShe learned that financial success isn't about one big moment. It's about a thousand small, disciplined decisions made in the early mornings when no one is watching."),
    ],
    decisions: [
      SpotlightDecision(
        prompt: 'Mwape has ZMW 600 saved. What should she do?',
        choiceA: 'Buy the phone (ZMW 550) to take WhatsApp orders',
        choiceB: 'Reinvest all ZMW 600 into more stock and variety',
        consequenceA: 'Smart! WhatsApp orders double her customer reach within 6 weeks, adding ZMW 400/month in revenue.',
        consequenceB: 'Steady growth — more stock means more sales, but growth is slower without marketing reach.',
      ),
      SpotlightDecision(
        prompt: 'The MFI is offering a ZMW 3,000 loan at 30% interest. Should Mwape take it?',
        choiceA: 'Take the loan — stock up for the rainy season rush',
        choiceB: 'Grow slowly using only her own savings',
        consequenceA: 'The rainy season rush covers repayments easily. The loan accelerates her growth by months.',
        consequenceB: 'Safe — but she misses the seasonal opportunity. Competitors capture the extra demand.',
      ),
      SpotlightDecision(
        prompt: 'Should Mwape register her business with PACRA?',
        choiceA: 'Register — pay ZMW 400 and go official',
        choiceB: 'Stay informal — save the ZMW 400 for stock',
        consequenceA: 'Mwape accesses a business bank account and applies for a CEEC grant. She\'s on a new trajectory.',
        consequenceB: 'Short-term saving, long-term cost. Without registration, she can\'t access formal credit or grants.',
      ),
    ],
    endingA: 'Mwape registers her business, secures a CEEC grant, and hires a helper. She now earns ZMW 8,000/month running a registered fresh produce SME.',
    endingB: 'Mwape remains at her stall, earning ZMW 1,200/month. Comfortable, but unable to access the financing that would take her to the next level.',
  ),
  SpotlightStory(
    id: 2,
    title: "Chanda's Tailoring Business",
    protagonist: 'Chanda',
    emoji: '🧵',
    xpReward: 100,
    unlockLevel: 1,
    chapters: [
      SpotlightChapter(title: 'The Grant', body: "Chanda had been sewing clothes for neighbours since she was 16, using a borrowed machine. At 28, she heard about a CEEC grant for young women entrepreneurs.\n\nShe applied, submitted her business plan, and received ZMW 15,000. The first thing she bought was a professional sewing machine. The second was fabric. The third: a notebook to record every transaction."),
      SpotlightChapter(title: 'Finding Her Market', body: "Chanda could sew everything — school uniforms, chitenge dresses, suits. But she couldn't serve everyone well at the same prices.\n\nA boutique owner downtown offered her a contract for high-end women's fashion at ZMW 250–500 per piece. Or she could focus on school uniforms at ZMW 50 each, serving families in her neighbourhood."),
      SpotlightChapter(title: 'The Apprentice Question', body: "Orders were coming in faster than Chanda could complete them. She was working 14-hour days and turning down clients.\n\nA young woman asked to apprentice under her — she would work for ZMW 800/month while learning. Taking her on would add costs but potentially double output."),
      SpotlightChapter(title: 'The Shop Decision', body: "Chanda's reputation had grown beyond her neighbourhood. Clients drove across town to find her. A shop space became available near a busy road — ZMW 2,500/month rent.\n\nShe could move out of her home workshop and gain visibility, or stay home where overheads were zero and all profit was hers."),
      SpotlightChapter(title: 'Lessons From the Needle', body: "Chanda learned that a tailoring business is really a people business. Her craft was the product, but her decisions about scale, team, and market were the real business.\n\nEvery stitch she made was capital. Every decision about where to sell, who to hire, and where to operate determined whether her talent became a small job or a real enterprise."),
    ],
    decisions: [
      SpotlightDecision(
        prompt: 'Which market should Chanda focus on?',
        choiceA: 'High-end fashion — ZMW 250–500 per piece, fewer clients',
        choiceB: 'Mass market — school uniforms at ZMW 50, high volume',
        consequenceA: 'Higher margins per piece. Fewer but premium clients who refer others. Revenue grows slower but quality brand builds.',
        consequenceB: 'Steady volume demand, but thin margins and intense price competition. Hard to grow beyond a certain point.',
      ),
      SpotlightDecision(
        prompt: 'Should Chanda hire an apprentice for ZMW 800/month?',
        choiceA: 'Hire her — invest in capacity and training',
        choiceB: 'Stay solo — keep costs zero and protect margins',
        consequenceA: 'Output doubles in 3 months. The apprentice handles basic work while Chanda focuses on premium orders.',
        consequenceB: 'She keeps all profit but hits a ceiling. She\'s trading time for money with no way to scale.',
      ),
      SpotlightDecision(
        prompt: 'Should Chanda open the shop for ZMW 2,500/month rent?',
        choiceA: 'Open the shop — gain visibility and professional credibility',
        choiceB: 'Stay home — keep overheads zero and maximise profit',
        consequenceA: 'New walk-in clients and a professional image. Revenue increase covers rent within 3 months.',
        consequenceB: 'Safe financially, but growth is limited by referrals only. Harder to build a recognisable brand.',
      ),
    ],
    endingA: 'Chanda builds a fashion brand with 3 employees, a shop in a visible location, and a waiting list of clients. She earns ZMW 12,000/month net.',
    endingB: 'Chanda is a talented sole trader working from home, earning ZMW 3,500/month. Comfortable but burned out, with no path to growth.',
  ),
  SpotlightStory(
    id: 3,
    title: "Bwalya's Investment Journey",
    protagonist: 'Bwalya',
    emoji: '📊',
    xpReward: 150,
    unlockLevel: 2,
    chapters: [
      SpotlightChapter(title: 'The Civil Servant Who Saved', body: "Bwalya worked as a government accountant earning ZMW 6,500/month. After rent, food, and family obligations, he had ZMW 500 left at month end.\n\nMost colleagues spent it quickly. Bwalya decided to treat that ZMW 500 like it didn't exist — and put it somewhere it could grow."),
      SpotlightChapter(title: 'Bank or Market?', body: "Bwalya's first question: where does ZMW 500/month go?\n\nHis bank offered a fixed deposit at 8% p.a. Safe, guaranteed. A stockbroker friend explained LuSE — historical returns of 12–18% but with fluctuation. The risk-return tradeoff was real."),
      SpotlightChapter(title: 'Land or Stocks?', body: "After 3 years, Bwalya had accumulated ZMW 25,000. A land broker offered him a plot in Chongwe for ZMW 22,000 — land that had doubled in value every 7 years historically.\n\nOr he could stay invested in LuSE, diversifying into government bonds and blue-chip stocks."),
      SpotlightChapter(title: 'The Mortgage Question', body: "At 38, Bwalya had built solid assets. He was still renting at ZMW 3,000/month — ZMW 36,000/year spent on someone else's mortgage.\n\nA bank offered him a ZMW 400,000 mortgage at 22% interest. The monthly repayment: ZMW 7,500. Could his income support it?"),
      SpotlightChapter(title: 'The Long Game', body: "Bwalya looked back at 20 years of financial decisions. The compounding of small, consistent investments had done more than any single windfall could have.\n\nHe understood now what the wealthy had always known: it's not about earning more. It's about keeping more, and making what you keep work harder than you do."),
    ],
    decisions: [
      SpotlightDecision(
        prompt: 'Where should Bwalya put his ZMW 500/month?',
        choiceA: 'Fixed deposit at 8% — safe and guaranteed',
        choiceB: 'LuSE stocks — higher risk, potentially 12–18% returns',
        consequenceA: 'In 10 years he has ZMW 91,000. Safe, predictable. Beats inflation but doesn\'t build real wealth fast.',
        consequenceB: 'In 10 years he has ZMW 115,000–140,000 depending on market performance. Higher reward for patience.',
      ),
      SpotlightDecision(
        prompt: 'Should Bwalya buy the Chongwe land plot?',
        choiceA: 'Buy the land — tangible asset, strong appreciation',
        choiceB: 'Stay invested in LuSE — liquidity and diversification',
        consequenceA: 'The land doubles in value in 7 years. A good long-term move but illiquid — he can\'t access the money in an emergency.',
        consequenceB: 'His portfolio grows with dividends and capital gains. More liquid but no physical asset to leverage for a mortgage.',
      ),
      SpotlightDecision(
        prompt: 'Should Bwalya take the mortgage?',
        choiceA: 'Take the mortgage — stop paying rent, own an asset',
        choiceB: 'Keep renting — continue building liquid investments',
        consequenceA: 'Tight but manageable with his current income. In 20 years he owns a ZMW 800,000 home outright.',
        consequenceB: 'More investment capital monthly. But 20 years of rent = ZMW 720,000 paid to someone else with nothing to show.',
      ),
    ],
    endingA: 'At 45, Bwalya owns property worth ZMW 800,000, has a LuSE portfolio worth ZMW 180,000, and a net worth over ZMW 900,000.',
    endingB: 'At 45, Bwalya is still renting, has minimal savings, and wonders where 20 years of ZMW 500/month contributions went.',
  ),
  SpotlightStory(
    id: 4,
    title: "Nalukui's Farm",
    protagonist: 'Nalukui',
    emoji: '🌾',
    xpReward: 150,
    unlockLevel: 2,
    chapters: [
      SpotlightChapter(title: 'The Inheritance', body: "Nalukui inherited 2 hectares in Mumbwa from her late grandfather. At 30, she faced a choice: sell it, leave it idle, or farm it herself.\n\nShe chose to farm. With ZMW 2,000 in savings and her grandfather's old tools, she prepared the soil for her first season."),
      SpotlightChapter(title: 'Subsistence or Cash Crop?', body: "Nalukui's neighbours grew maize for themselves and sold the surplus. Predictable, safe, but the margins were thin.\n\nAn agricultural extension officer visited and explained the market for soya beans, groundnuts, and paprika — cash crops with export demand and higher prices per kilogram."),
      SpotlightChapter(title: 'Who to Sell To?', body: "Nalukui's first paprika harvest was 1,200kg — far more than the local market could absorb at a fair price. A local trader offered ZMW 8/kg. A cooperative linked to an export buyer offered ZMW 14/kg but required her to grade and bag the crop herself."),
      SpotlightChapter(title: 'Reinvest or Celebrate?', body: "After her best season yet, Nalukui had ZMW 40,000 in profit. Her family expected a celebration — a party, new furniture, a motorbike.\n\nOr she could invest ZMW 30,000 in a drip irrigation system that would free her from rain dependency and allow two harvests per year."),
      SpotlightChapter(title: 'The Harvest of Decisions', body: "Nalukui learned that farming is a business, not a subsistence activity. Every decision about what to plant, who to sell to, and how to use profit compounded over seasons.\n\nThe farmers who stayed poor made the same decisions year after year. The farmers who built wealth made different ones."),
    ],
    decisions: [
      SpotlightDecision(
        prompt: 'What should Nalukui grow on her 2 hectares?',
        choiceA: 'Cash crops (paprika, soya) — higher prices, more risk',
        choiceB: 'Maize — familiar, safe, lower prices',
        consequenceA: 'First season is risky — a crop disease costs her ZMW 5,000. But by season 3 she\'s earning ZMW 35,000/season.',
        consequenceB: 'Steady but limited. FRA prices are fixed and margins are thin. Difficult to grow beyond subsistence level.',
      ),
      SpotlightDecision(
        prompt: 'Should Nalukui sell to the local trader or the export cooperative?',
        choiceA: 'Export cooperative — ZMW 14/kg but extra work to grade',
        choiceB: 'Local trader — ZMW 8/kg but simple and immediate',
        consequenceA: 'Extra 2 days of work earns her ZMW 7,200 more on the same harvest. The cooperative also provides training.',
        consequenceB: 'Quick cash but ZMW 7,200 left on the table. The trader resells to the export cooperative himself.',
      ),
      SpotlightDecision(
        prompt: 'Nalukui has ZMW 40,000 profit. What should she do?',
        choiceA: 'Invest ZMW 30,000 in drip irrigation — two harvests per year',
        choiceB: 'Buy a motorbike (ZMW 18,000) and celebrate with family',
        consequenceA: 'Two harvests doubles annual income to ZMW 70,000/season. The investment pays back in 18 months.',
        consequenceB: 'The motorbike is useful but depreciates. One harvest per year limits her to ZMW 35,000/season with no growth path.',
      ),
    ],
    endingA: 'Nalukui becomes an agro-exporter earning ZMW 25,000 per season, with irrigation infrastructure that makes her drought-proof.',
    endingB: 'Nalukui remains a subsistence farmer, breaking even each year but unable to invest in the systems that would transform her output.',
  ),
  SpotlightStory(
    id: 5,
    title: "Mutale's Tech Startup",
    protagonist: 'Mutale',
    emoji: '💻',
    xpReward: 200,
    unlockLevel: 3,
    chapters: [
      SpotlightChapter(title: 'The App Idea', body: "Mutale spent 3 years as a software developer at a Lusaka IT firm, earning ZMW 12,000/month. Every day he saw the same problem: small market vendors had no way to manage stock or track sales digitally.\n\nHe built a prototype app in 6 months of evenings and weekends. It worked. Now he had to decide: keep his salary job, or go all-in."),
      SpotlightChapter(title: 'Funding the Dream', body: "Mutale needed ZMW 80,000 to hire one developer, cover 6 months of hosting costs, and handle marketing.\n\nA local angel investor offered ZMW 60,000 for 30% equity. ZICTA had an innovation grant for ZMW 50,000 that required a 6-month application process. His family could lend ZMW 30,000 with no equity strings."),
      SpotlightChapter(title: 'Pricing the Product', body: "The app was ready. Mutale had 50 pilot users who loved it. Now he had to charge.\n\nOption A: ZMW 150/month subscription. Option B: Free with ZMW 5 per transaction. Both models had passionate advocates in his network."),
      SpotlightChapter(title: 'The Partnership Offer', body: "A large Zambian telecom approached Mutale to white-label his app under their brand. They would handle all sales and marketing — Mutale would receive 15% of revenue.\n\nOr he could stay independent, build his own brand, and keep 100% of revenue but fund all growth himself."),
      SpotlightChapter(title: 'The Entrepreneur\'s Paradox', body: "Mutale understood by now that a tech startup is a series of irreversible bets. You bet on your market, your model, your team, your investors.\n\nThe entrepreneurs who succeeded weren't always smarter. They were better at making good bets quickly, learning from bad ones fast, and never running out of money before finding what worked."),
    ],
    decisions: [
      SpotlightDecision(
        prompt: 'How should Mutale fund his startup?',
        choiceA: 'Take the angel investor\'s ZMW 60,000 for 30% equity',
        choiceB: 'Apply for the ZICTA grant (ZMW 50,000, no equity, 6-month wait)',
        consequenceA: 'Fast capital and an experienced investor who opens doors. He gives up 30% but moves 6 months faster.',
        consequenceB: 'Free money with no dilution, but 6 months of zero progress. A competitor launches in month 4.',
      ),
      SpotlightDecision(
        prompt: 'Which pricing model should Mutale choose?',
        choiceA: 'ZMW 150/month subscription — predictable recurring revenue',
        choiceB: 'Free + ZMW 5 per transaction — zero barrier to adoption',
        consequenceA: 'Higher monthly revenue per active user but slower adoption. Needs 100 users to break even.',
        consequenceB: 'Rapid adoption — 500 users in month 1. Revenue is variable but scales with transaction volume.',
      ),
      SpotlightDecision(
        prompt: 'Should Mutale take the telecom partnership?',
        choiceA: 'Partner with the telecom — 15% revenue, massive distribution',
        choiceB: 'Stay independent — 100% revenue, build own brand',
        consequenceA: 'The telecom\'s 2 million customers give him instant scale. 15% of large volume beats 100% of small volume.',
        consequenceB: 'Full control and full margin, but growth is slow without their distribution network.',
      ),
    ],
    endingA: 'Mutale\'s app reaches 50,000 active users through the telecom partnership. He raises a Series A and is building Zambia\'s first fintech unicorn.',
    endingB: 'Mutale builds a sustainable small SaaS business with 800 paying users, earning ZMW 8,000/month — a solid indie business but not a venture.',
  ),
  SpotlightStory(
    id: 6,
    title: "Grace's Salon Empire",
    protagonist: 'Grace',
    emoji: '💇',
    xpReward: 200,
    unlockLevel: 3,
    chapters: [
      SpotlightChapter(title: 'From Chair to Business', body: "Grace started doing hair for neighbours at ZMW 50 per session from her bedroom. By 26, she had a waiting list and was turning away clients.\n\nWith ZMW 8,000 saved, she had enough to rent a small space. She'd been doing hair for 4 years but never called herself a businessperson — until now."),
      SpotlightChapter(title: 'The First Shop', body: "Grace rented a small kiosk in Chilenje for ZMW 1,800/month. She invested ZMW 6,000 in chairs, mirrors, and equipment.\n\nIn month 1, she made ZMW 7,200. In month 3, ZMW 11,500. The demand was there — the question was how fast to grow."),
      SpotlightChapter(title: 'Staff or Solo?', body: "Grace's biggest constraint was time. She could only serve 6 clients per day. A trained stylist asked to work for 40% commission on services they delivered.\n\nOr she could train school leavers herself at ZMW 1,500/month, building a team she shaped from the ground up."),
      SpotlightChapter(title: 'The Second Location', body: "A salon in Woodlands came up for rent — a bigger, busier location but ZMW 4,500/month. Grace's current salon was making ZMW 14,000/month profit.\n\nOpening a second location would test her ability to manage without being present. She'd need a manager she could trust."),
      SpotlightChapter(title: 'The Brand Question', body: "Grace's salons had no name, no logo, no social media. Clients came by word of mouth.\n\nA marketing student offered to build her a brand package — name, logo, Instagram, and a booking system — for ZMW 3,500. Or she could keep growing organically and save the money."),
    ],
    decisions: [
      SpotlightDecision(
        prompt: 'Should Grace hire an experienced stylist or train juniors?',
        choiceA: 'Hire an experienced stylist at 40% commission',
        choiceB: 'Train two school leavers at ZMW 1,500/month each',
        consequenceA: 'Immediate capacity increase with a skilled professional. Higher per-service cost but no training investment.',
        consequenceB: 'Lower cost, Grace controls the culture and techniques. Takes 3 months to get them productive.',
      ),
      SpotlightDecision(
        prompt: 'Should Grace open a second salon in Woodlands?',
        choiceA: 'Open the second salon — invest in growth',
        choiceB: 'Stay at one location — perfect what exists first',
        consequenceA: 'Second salon adds ZMW 10,000/month profit once established. Operational complexity increases significantly.',
        consequenceB: 'Less risk, more focus. But a competitor opens in Woodlands and captures the market Grace could have owned.',
      ),
      SpotlightDecision(
        prompt: 'Should Grace invest in branding for ZMW 3,500?',
        choiceA: 'Invest in branding — build a recognisable name',
        choiceB: 'Save the money — word of mouth is working fine',
        consequenceA: 'Instagram brings 30 new clients in the first month. The brand asset grows in value over time.',
        consequenceB: 'Saves ZMW 3,500 today but misses the compounding value of brand equity in a competitive market.',
      ),
    ],
    endingA: 'Grace operates three branded salons, employs 8 staff, and earns ZMW 35,000/month. She is building a franchise model.',
    endingB: 'Grace runs a single successful salon earning ZMW 14,000/month — a good business, but not yet the empire she imagined.',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class SpotlightState {
  const SpotlightState({this.record, this.isLoading = false});
  final SpotlightRecord? record;
  final bool             isLoading;

  bool isCompleted(int storyId) =>
      record?.completedSpotlightIds.contains(storyId) ?? false;

  int chapterFor(int storyIdx) {
    final cp = record?.chapterProgress;
    if (cp == null || storyIdx >= cp.length) { return 0; }
    return cp[storyIdx];
  }

  Map<String, List<int>> get choices {
    final json = record?.choicesJson ?? '{}';
    try {
      final raw = jsonDecode(json) as Map<String, dynamic>;
      return raw.map((k, v) => MapEntry(k, (v as List).cast<int>()));
    } catch (_) {
      return {};
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class SpotlightNotifier extends StateNotifier<SpotlightState> {
  SpotlightNotifier(this._ref) : super(const SpotlightState(isLoading: true)) {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.currentUser?.uid != next.currentUser?.uid) { _load(); }
    });
    _load();
  }

  final Ref _ref;
  Box<SpotlightRecord> get _box => Hive.box<SpotlightRecord>(kSpotlightsBox);
  String? get _uid => _ref.read(currentUserProvider)?.uid;

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      state = const SpotlightState();
      return;
    }
    var record = _box.get(uid);
    if (record == null) {
      record = SpotlightRecord(
        uid: uid,
        completedSpotlightIds: [],
        chapterProgress: List.filled(kAllSpotlights.length, 0),
        choicesJson: '{}',
      );
      await _box.put(uid, record);
    }
    state = SpotlightState(record: _box.get(uid));
  }

  Future<void> advanceChapter(int storyIdx) async {
    final record = state.record;
    if (record == null) { return; }
    final cp = List<int>.from(record.chapterProgress);
    if (storyIdx < cp.length) {
      cp[storyIdx] = (cp[storyIdx] + 1).clamp(0, 4);
    }
    record.chapterProgress = cp;
    await record.save();
    state = SpotlightState(record: _box.get(record.uid));
  }

  Future<void> makeChoice(int storyId, int decisionIdx, int choiceIdx) async {
    final record = state.record;
    if (record == null) { return; }
    final choices = state.choices;
    final key = storyId.toString();
    final list = List<int>.from(choices[key] ?? []);
    // Ensure list is long enough
    while (list.length <= decisionIdx) { list.add(-1); }
    list[decisionIdx] = choiceIdx;
    choices[key] = list;
    record.choicesJson = jsonEncode(choices);
    await record.save();
    state = SpotlightState(record: _box.get(record.uid));
  }

  Future<void> completeStory(int storyId) async {
    final record = state.record;
    if (record == null) { return; }
    if (!record.completedSpotlightIds.contains(storyId)) {
      record.completedSpotlightIds.add(storyId);
    }
    await record.save();
    final story = kAllSpotlights.firstWhere((s) => s.id == storyId);
    await _ref.read(authProvider.notifier).addXp(story.xpReward);
    state = SpotlightState(record: _box.get(record.uid));
  }

  bool isUnlocked(SpotlightStory story) {
    if (story.unlockLevel <= 1) { return true; }
    final levels = _ref.read(levelProvider).levels;
    final lvl = levels[story.unlockLevel - 1];
    return lvl?.status == kStatusCompleted;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final spotlightProvider = StateNotifierProvider<SpotlightNotifier, SpotlightState>(
  (ref) => SpotlightNotifier(ref),
);
