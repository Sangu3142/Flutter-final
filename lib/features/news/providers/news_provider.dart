/// news_provider.dart
/// Purpose: Zambian financial news feed — weekly rotation of 5 headlines from
///          a pool of 40+ curated stories covering economy, property, investment,
///          business, and personal finance.
library;

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/news/models/news_record.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Headline Data
// ─────────────────────────────────────────────────────────────────────────────

class NewsHeadline {
  const NewsHeadline({
    required this.category,
    required this.emoji,
    required this.title,
    required this.body,
    required this.impact,
  });

  final String category;
  final String emoji;
  final String title;
  final String body;
  final String impact;
}

const List<NewsHeadline> kAllHeadlines = [
  // Economy
  NewsHeadline(
    category: 'Economy',
    emoji: '📈',
    title: 'Bank of Zambia Holds Policy Rate at 13.5% — Kwacha Stable',
    body: 'The Bank of Zambia Monetary Policy Committee maintained its benchmark rate as inflation eased to 9.6%. The kwacha held firm at K26 per dollar.',
    impact: 'Stable interest rates keep borrowing costs predictable for mortgages and business loans.',
  ),
  NewsHeadline(
    category: 'Economy',
    emoji: '💱',
    title: 'Kwacha Rallies 4% Against Dollar on IMF Optimism',
    body: "Zambia's currency gained ground after the IMF approved the fourth review of its economic recovery programme, unlocking a \$188m disbursement.",
    impact: 'A stronger kwacha reduces import costs — good for consumers but watch copper export revenues.',
  ),
  NewsHeadline(
    category: 'Economy',
    emoji: '⛏️',
    title: 'Copper Production Hits 5-Year High at 840,000 Tonnes',
    body: 'Zambia produced 840,000 tonnes of copper in 2024, the highest since 2019. KCM and Lumwana drove gains with new pit expansions.',
    impact: 'Higher copper output boosts government revenue and creates more employment opportunities.',
  ),
  NewsHeadline(
    category: 'Economy',
    emoji: '📉',
    title: "Zambia's Inflation Eases to 9.2% — Food Prices Stable",
    body: 'Statistics Zambia reported a second consecutive monthly drop in headline inflation, led by lower food and energy prices.',
    impact: 'Lower inflation preserves the purchasing power of your ZamCoins savings and pension.',
  ),
  NewsHeadline(
    category: 'Economy',
    emoji: '🏦',
    title: 'Zambia Completes Eurobond Debt Restructuring — \$500m Saved',
    body: 'Zambia finalised restructuring of its \$3bn Eurobond debt, reducing annual interest payments by \$500m through 2043.',
    impact: 'Improved fiscal position may lead to more government infrastructure investment near you.',
  ),
  NewsHeadline(
    category: 'Economy',
    emoji: '🌧️',
    title: "El Niño Drought Cuts Zambia's Maize Harvest 35%",
    body: 'ZARI forecasts a 2.1m tonne maize crop — well below the 3.2m tonne national requirement. Food imports may be needed by Q3.',
    impact: 'Food inflation rising — strengthen your emergency fund and review household food budgets.',
  ),
  NewsHeadline(
    category: 'Economy',
    emoji: '💧',
    title: 'Kariba Dam at 18% Capacity — ZESCO Load-Shedding Returns to 8 Hours',
    body: 'Critically low water levels at Lake Kariba have forced ZESCO to increase power cuts, affecting businesses and manufacturing.',
    impact: 'Load-shedding raises business costs — investing in solar power now protects future operations.',
  ),
  NewsHeadline(
    category: 'Economy',
    emoji: '✈️',
    title: 'Zambia Tourism Revenue Hits Record \$500m — Safari Sector Booms',
    body: "The Zambia Tourism Agency reported record visitor arrivals to Victoria Falls and Lower Zambezi, boosting hospitality employment by 12%.",
    impact: 'Tourism growth creates business opportunities in hospitality, transport, and crafts.',
  ),
  NewsHeadline(
    category: 'Economy',
    emoji: '🌐',
    title: "Zambia's GDP Growth Forecast Upgraded to 5.2% — IMF Report",
    body: 'The IMF revised its growth estimate upward, citing mining sector recovery, debt relief dividends, and improving infrastructure investment.',
    impact: 'Higher GDP growth signals more business opportunities and stronger employment prospects.',
  ),
  // Property
  NewsHeadline(
    category: 'Property',
    emoji: '🏠',
    title: 'Lusaka Property Prices Up 12% Year-on-Year — Demand Outstrips Supply',
    body: "Average residential property in Lusaka's Kabulonga and Roma rose to ZMW 1.2m from ZMW 1.07m a year ago. Plot scarcity is driving the surge.",
    impact: 'Owning property earlier locks in today\'s prices — appreciation is outpacing savings rates.',
  ),
  NewsHeadline(
    category: 'Property',
    emoji: '🏘️',
    title: 'Government Launches 10,000-Unit Affordable Housing Scheme in Chongwe',
    body: 'The Ministry of Housing unveiled plans for a satellite town with homes priced at ZMW 250,000–350,000, targeting civil servants and SME owners.',
    impact: 'Government-backed mortgage rates of 10% may be available for first-time buyers.',
  ),
  NewsHeadline(
    category: 'Property',
    emoji: '📐',
    title: 'Lusaka City Council Digitises Plot Allocation — Faster Title Deeds',
    body: 'LCC announced a digital plot allocation system that reduces title deed processing from 18 months to 90 days.',
    impact: 'Faster titling reduces legal risk and makes land a more attractive investment.',
  ),
  NewsHeadline(
    category: 'Property',
    emoji: '🏗️',
    title: 'REITs Coming to Zambia by 2026 — Invest in Property from ZMW 500',
    body: 'The Securities and Exchange Commission drafted a REIT framework allowing ordinary Zambians to invest in commercial property for as little as ZMW 500.',
    impact: 'REITs will let investors access property returns without needing to buy a full building.',
  ),
  NewsHeadline(
    category: 'Property',
    emoji: '🏡',
    title: 'Northmead and Woodlands Rental Yields Surge 18%',
    body: "Rental demand in Lusaka's middle-income suburbs is booming as more urban migrants seek quality accommodation close to the CBD.",
    impact: 'Rental income supplements wages — diversifying income sources reduces financial risk.',
  ),
  NewsHeadline(
    category: 'Property',
    emoji: '🗺️',
    title: 'Livingstone Smart City Project Breaks Ground — 5,000 Homes Planned',
    body: 'A mixed-income smart city near Victoria Falls will combine residential, commercial, and tourism infrastructure over 10 years.',
    impact: 'Early property in emerging corridors often yields higher long-term appreciation.',
  ),
  NewsHeadline(
    category: 'Property',
    emoji: '🏙️',
    title: 'Lusaka Mass Transit to Connect Chilenje, Kabulonga, and Garden',
    body: 'A 28km electric bus rapid transit corridor will link eastern and southern Lusaka suburbs, improving connectivity and property values.',
    impact: 'Transit-connected property typically appreciates 10–15% faster than non-connected areas.',
  ),
  // Investment
  NewsHeadline(
    category: 'Investment',
    emoji: '📊',
    title: 'LUSE All-Share Index Gains 22% in 2024 — Finance Sector Leads',
    body: 'The Lusaka Securities Exchange All-Share Index ended 2024 at 10,450 points. Zanaco, Standard Chartered Zambia, and Zambeef led gains.',
    impact: 'Shares in quality Zambian companies have historically outpaced inflation over 5-year periods.',
  ),
  NewsHeadline(
    category: 'Investment',
    emoji: '🏛️',
    title: 'Government Issues ZMW 2bn Treasury Bond at 22% Coupon',
    body: "Zambia's Ministry of Finance issued 5-year treasury bonds at 22% annual coupon. Demand exceeded supply by 1.8 times.",
    impact: 'Government bonds are low-risk savings instruments that beat most bank deposit rates.',
  ),
  NewsHeadline(
    category: 'Investment',
    emoji: '₿',
    title: 'Crypto Trading Volume in Zambia Doubles — BOZ Issues Caution',
    body: 'P2P Bitcoin and USDT trading on local platforms reached \$12m per month. Bank of Zambia reminded citizens crypto is unregulated.',
    impact: 'Crypto offers high potential returns but is highly volatile — limit to what you can afford to lose.',
  ),
  NewsHeadline(
    category: 'Investment',
    emoji: '🌾',
    title: 'Zambian Agri-Bonds Offer 18% Returns — FSD Zambia Promotes Investment',
    body: 'Agricultural development bonds linked to commercial farms in Southern Province are offering above-market returns to retail investors.',
    impact: 'Agriculture-linked investments diversify your portfolio beyond urban assets.',
  ),
  NewsHeadline(
    category: 'Investment',
    emoji: '⚡',
    title: 'ZESCO Green Energy Bonds Oversubscribed — Solar Copperbelt Projects',
    body: 'ZESCO raised ZMW 500m for solar expansion. Green bonds mature in 7 years at 19% per annum with strong retail participation.',
    impact: 'Infrastructure bonds offer stable medium-term income and support national development.',
  ),
  NewsHeadline(
    category: 'Investment',
    emoji: '🏪',
    title: 'Shoprite and Game Announce ZMW 2bn Zambia Expansion',
    body: 'Retail investment is accelerating in Chipata, Solwezi, and Mongu following rising consumer purchasing power in secondary cities.',
    impact: 'Retail expansion creates opportunities for commercial property investors and local suppliers.',
  ),
  NewsHeadline(
    category: 'Investment',
    emoji: '💎',
    title: 'Emerald Prices Surge 40% — Zambia Holds 20% of World Gem Output',
    body: 'Zambian emerald exports jumped as global demand recovers. Kafubu River mines are at full capacity for the first time since 2020.',
    impact: 'Commodity booms can create opportunities in mining sector shares on LUSE.',
  ),
  // Business
  NewsHeadline(
    category: 'Business',
    emoji: '🏢',
    title: 'PACRA Registers Record 45,000 New SMEs in Q1 2025',
    body: "Zambia's Companies Registry saw its busiest quarter ever as formal registrations surged on the back of youth entrepreneurship grants.",
    impact: 'Formalising your business unlocks access to bank credit and government contracts.',
  ),
  NewsHeadline(
    category: 'Business',
    emoji: '📱',
    title: 'MTN and Airtel Waive Mobile Money Fees Under ZMW 500',
    body: 'A six-month promotion to boost digital payment adoption will see zero charges on low-value transfers across the informal sector.',
    impact: 'Digital payments reduce cash handling risk and build a financial record useful for credit.',
  ),
  NewsHeadline(
    category: 'Business',
    emoji: '🌍',
    title: 'COMESA Expands Free Trade — Zambian Exporters Eye DRC Market',
    body: 'A new COMESA protocol reduces tariffs on Zambian goods entering DRC, Rwanda, and Kenya — opening a market of 300m consumers.',
    impact: 'Export diversification grows business revenue beyond the local market.',
  ),
  NewsHeadline(
    category: 'Business',
    emoji: '💡',
    title: 'TEVETA Launches Free Digital Skills Courses for 50,000 SMEs',
    body: 'The Technical Education Authority will train small business owners in digital marketing, bookkeeping, and e-commerce at no cost.',
    impact: 'Free skills training reduces business costs and can directly increase revenue.',
  ),
  NewsHeadline(
    category: 'Business',
    emoji: '🏦',
    title: 'DBZ Disburses ZMW 250m in SME Loans at 12% — Below Market Rate',
    body: "The Development Bank of Zambia's SME Growth Fund provided concessional loans to 1,200 businesses in Q2 2025.",
    impact: 'Government-backed loans are cheaper than commercial banks for qualifying businesses.',
  ),
  NewsHeadline(
    category: 'Business',
    emoji: '🛒',
    title: 'ZamMart E-Commerce Platform Launches — 10,000 SMEs Can Sell Online',
    body: 'The FSD Zambia-backed e-commerce platform connects small traders to urban consumers, with free listings for businesses under ZMW 500,000 turnover.',
    impact: 'Online sales channels expand your customer base beyond your physical location.',
  ),
  NewsHeadline(
    category: 'Business',
    emoji: '☀️',
    title: 'Solar Net Metering — Homeowners Can Now Sell Power Back to ZESCO',
    body: 'A pilot net-metering programme in Lusaka pays ZMW 1.5 per kWh to households that feed surplus solar energy into the grid.',
    impact: 'Solar installation becomes dual-purpose — cost savings plus a new revenue stream.',
  ),
  // Personal Finance
  NewsHeadline(
    category: 'Finance',
    emoji: '💳',
    title: 'NAPSA Announces 15% Pension Increase — 200,000 Retirees Benefit',
    body: 'The National Pension Scheme Authority will increase monthly payouts from October 2025, citing strong fund performance over 3 years.',
    impact: 'Consistent NAPSA contributions compound into meaningful retirement income over time.',
  ),
  NewsHeadline(
    category: 'Finance',
    emoji: '🎓',
    title: 'HELBF Student Loans Now Available Online — ZMW 45,000 Per Year Max',
    body: "Zambia's Higher Education Loans and Bursaries Fund launched an online portal reducing application processing to just 5 days.",
    impact: 'Education investment increases lifetime earning potential by an average of 60%.',
  ),
  NewsHeadline(
    category: 'Finance',
    emoji: '🏥',
    title: 'NHIMA Expands Cover to Specialist Outpatient Visits',
    body: 'The National Health Insurance Management Authority extended benefits under the K72/month employer scheme to include specialist GP visits.',
    impact: 'Health insurance prevents medical emergencies from depleting your savings and investment.',
  ),
  NewsHeadline(
    category: 'Finance',
    emoji: '💰',
    title: 'Bank of Zambia Raises Minimum Savings Rate to 8%',
    body: 'Following a BOZ directive, all commercial banks must offer at least 8% annual interest on savings accounts of ZMW 5,000 and above.',
    impact: 'Higher savings rates reward consistent savers — move idle cash from checking to savings now.',
  ),
  NewsHeadline(
    category: 'Finance',
    emoji: '📋',
    title: 'ZRA Introduces Mobile Tax Filing — Deadline Extended to June 30',
    body: "The Zambia Revenue Authority's new mobile app allows individual taxpayers to file and pay returns directly from their phones.",
    impact: 'On-time tax filing avoids penalties and can unlock access to government contracts.',
  ),
  NewsHeadline(
    category: 'Finance',
    emoji: '🤝',
    title: 'Microfinance Loan Rates Drop to 20% — Down from 35% Last Year',
    body: 'Following central bank regulation, microfinance institutions have reduced lending rates from an average of 35% to 20% annually.',
    impact: 'Lower borrowing costs make emergency credit less punishing for low-income earners.',
  ),
  NewsHeadline(
    category: 'Finance',
    emoji: '📊',
    title: "Zambia's Savings Rate Reaches 14% of GDP — Highest in a Decade",
    body: 'Consistent NAPSA reforms and new bank products have helped gross savings reach 14% of GDP, supporting domestic investment.',
    impact: "A higher national savings rate signals improving financial habits — review your own savings plan.",
  ),
  NewsHeadline(
    category: 'Economy',
    emoji: '🚂',
    title: 'TAZARA Railway Modernisation Begins — ZMW 4bn Investment',
    body: 'Work has begun upgrading the 1,860 km Tanzania-Zambia railway, which will reduce copper export costs and improve regional trade.',
    impact: 'Infrastructure investment typically boosts property values along the rail corridor.',
  ),
  NewsHeadline(
    category: 'Investment',
    emoji: '🔋',
    title: 'Battery Storage Investment Surges in Zambia — \$200m Pledged',
    body: 'Renewable energy investors committed \$200m for utility-scale battery storage to smooth out solar intermittency and complement hydro power.',
    impact: 'Energy independence reduces a major business operating cost risk.',
  ),
  NewsHeadline(
    category: 'Economy',
    emoji: '🌱',
    title: 'Zambia Launches Carbon Credit Market — Forests Now Earn Income',
    body: 'The Environmental Management Agency certified the first carbon credit exchange, allowing landowners to earn from preserved forests.',
    impact: 'Carbon credits are a new asset class — a potential diversification opportunity for investors.',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class NewsState {
  const NewsState({this.record, this.isLoading = false});

  final NewsRecord? record;
  final bool isLoading;
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class NewsNotifier extends StateNotifier<NewsState> {
  NewsNotifier(this._ref) : super(const NewsState(isLoading: true)) {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.currentUser?.uid != next.currentUser?.uid) _load();
    });
    _load();
  }

  final Ref _ref;
  final _rng = Random();

  Box<NewsRecord> get _box => Hive.box<NewsRecord>(kNewsBox);
  String? get _uid => _ref.read(currentUserProvider)?.uid;

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      state = const NewsState();
      return;
    }

    var record = _box.get(uid);
    if (record == null) {
      record = NewsRecord(
        uid: uid,
        lastRotationDateStr: _todayStr(),
        currentHeadlineIndices: _pickIndices(),
      );
      await _box.put(uid, record);
    } else {
      _maybeRotate(record);
    }
    state = NewsState(record: _box.get(uid));
  }

  void _maybeRotate(NewsRecord record) {
    final last = DateTime.tryParse(record.lastRotationDateStr);
    if (last == null ||
        DateTime.now().difference(last).inDays >= kNewsRotationDays) {
      record.currentHeadlineIndices = _pickIndices();
      record.lastRotationDateStr = _todayStr();
      record.save();
    }
  }

  List<int> _pickIndices() {
    final all = List.generate(kAllHeadlines.length, (i) => i);
    all.shuffle(_rng);
    return all.take(kNewsDisplayCount).toList();
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final newsProvider =
    StateNotifierProvider<NewsNotifier, NewsState>((ref) => NewsNotifier(ref));

final currentHeadlinesProvider = Provider<List<NewsHeadline>>((ref) {
  final state = ref.watch(newsProvider);
  final indices = state.record?.currentHeadlineIndices ?? [];
  return indices
      .where((i) => i >= 0 && i < kAllHeadlines.length)
      .map((i) => kAllHeadlines[i])
      .toList();
});
