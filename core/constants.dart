/// constants.dart
/// Purpose: Central registry of all app-wide constants — box names, level IDs,
///          status strings, XP thresholds, level metadata, and simulation IDs.
/// Reads from: nothing (pure constants)
/// Writes to: nothing
/// Navigation: none
library;

// ─────────────────────────────────────────────────────────────────────────────
// Hive Box Names
// ─────────────────────────────────────────────────────────────────────────────

/// Name of the Hive box that stores [UserProfile] objects, keyed by username.
const String kUserBox = 'users';

/// Name of the Hive box that stores [LevelModel] objects,
/// keyed by the composite string `"<uid>_<levelId>"`.
const String kLevelBox = 'levels';

/// Name of the Hive box that stores [PaymentRecord] objects, keyed by paymentId.
const String kPaymentBox = 'payments';

/// Name of the Hive box that stores the current session.
/// Key `'currentUid'` holds the username of the logged-in user (or null).
const String kSessionBox = 'session';

/// Name of the Hive box that stores leaderboard placeholder data.
/// Key `'entries'` holds a `List<Map>` of fictional player entries.
const String kLeaderboardBox = 'leaderboard';

/// Name of the Hive box that stores miscellaneous app settings.
/// Keys: `'sandboxMode'` (bool), `'onboardingDone_<uid>'` (bool).
const String kSettingsBox = 'settings';

// ─────────────────────────────────────────────────────────────────────────────
// Level IDs
// ─────────────────────────────────────────────────────────────────────────────

const int kLevel1Id = 1;
const int kLevel2Id = 2;
const int kLevel3Id = 3;
const int kLevel4Id = 4;

// ─────────────────────────────────────────────────────────────────────────────
// Level Prices (ZMW)
// ─────────────────────────────────────────────────────────────────────────────

const double kLevel1Price = 0.0;
const double kLevel2Price = 25.0;
const double kLevel3Price = 50.0;
const double kLevel4Price = 80.0;

// ─────────────────────────────────────────────────────────────────────────────
// Level Status Strings (state machine values stored in Hive)
// ─────────────────────────────────────────────────────────────────────────────

/// Level has not been purchased. Tapping opens the payment screen.
const String kStatusLocked = 'LOCKED';

/// Level has been purchased (or is free). Player may enter.
const String kStatusUnlocked = 'UNLOCKED';

/// Player has completed at least one simulation but not all of them.
const String kStatusInProgress = 'IN_PROGRESS';

/// All simulations in this level have been completed.
const String kStatusCompleted = 'COMPLETED';

// ─────────────────────────────────────────────────────────────────────────────
// XP Rewards per Level Completion
// ─────────────────────────────────────────────────────────────────────────────

const int kLevel1XpReward = 200;
const int kLevel2XpReward = 400;
const int kLevel3XpReward = 600;
const int kLevel4XpReward = 1000;

/// Bonus ZamCoins awarded after a successful payment unlock.
const int kPaymentBonusZamCoins = 50;

// ─────────────────────────────────────────────────────────────────────────────
// XP Thresholds for Player Rank Badge
// ─────────────────────────────────────────────────────────────────────────────

const List<int> kXpThresholds = [0, 200, 600, 1200, 2200];

/// Returns the player's rank label (1-indexed) based on [xp].
String xpRankLabel(int xp) {
  if (xp < 200) return 'Kwacha Starter';
  if (xp < 600) return 'ZMW Builder';
  if (xp < 1200) return 'Copper Investor';
  if (xp < 2200) return 'Mukuba Tycoon';
  return 'ZamWealth Legend';
}

/// Returns the XP needed to reach the next rank, or 0 if at max.
int xpToNextRank(int xp) {
  for (final threshold in kXpThresholds) {
    if (xp < threshold) return threshold - xp;
  }
  return 0;
}

/// Returns the XP of the current rank's start threshold.
int xpCurrentRankStart(int xp) {
  int start = 0;
  for (final threshold in kXpThresholds) {
    if (xp < threshold) return start;
    start = threshold;
  }
  return start;
}

// ─────────────────────────────────────────────────────────────────────────────
// Simulation IDs  (used as keys inside LevelModel.completedSimulations)
// ─────────────────────────────────────────────────────────────────────────────

/// Level 1 simulations
const String kSimBudget = 'budget_allocator';
const String kSimEmergencyFund = 'emergency_fund';
const String kSimMobileMoneyFee = 'mobile_money_fee';
const String kSimQuizChallenge = 'quiz_challenge';

/// Level 2 simulations
const String kSimDebt = 'debt_manager';
const String kSimSavingsGoal = 'savings_goal';
const String kSimInflation = 'inflation_impact';

/// Level 3 simulations
const String kSimInvestment = 'investment_simulator';
const String kSimCompoundGrowth = 'compound_growth';
const String kSimPortfolio = 'portfolio_allocator';

/// Level 4 simulations
const String kSimPacra = 'pacra_registration';
const String kSimRevenue = 'revenue_profit';
const String kSimPayroll = 'payroll_simulator';
const String kSimTax = 'tax_quiz';

// ─────────────────────────────────────────────────────────────────────────────
// Level Metadata  (immutable descriptor for each level)
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable descriptor for a game level.
class LevelMeta {
  /// Creates a [LevelMeta] descriptor.
  const LevelMeta({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.xpReward,
    required this.businesses,
    required this.simulations,
    required this.emoji,
  });

  final int id;

  /// Neighbourhood name shown on the level map node.
  final String name;

  /// Short tagline shown in the level detail header.
  final String subtitle;

  /// Monthly unlock price in ZMW (0 = free).
  final double price;

  /// XP awarded when all simulations are completed.
  final int xpReward;

  /// List of business names featured in this level.
  final List<String> businesses;

  /// List of simulation IDs belonging to this level (see k*Sim* constants).
  final List<String> simulations;

  /// Emoji used to visually identify the level on the map.
  final String emoji;

  /// True if this level can be accessed without payment.
  bool get isFree => price == 0;
}

/// Central map of all level metadata, keyed by level ID.
const Map<int, LevelMeta> kLevelMeta = {
  1: LevelMeta(
    id: 1,
    name: 'Kabulonga Gardens',
    subtitle: 'Master the basics of budgeting',
    price: kLevel1Price,
    xpReward: kLevel1XpReward,
    emoji: '🌿',
    businesses: [
      'Manda Mini Mart',
      'ZamFresh Market',
      'CityConnect Airtime',
    ],
    simulations: [
      kSimBudget,
      kSimEmergencyFund,
      kSimMobileMoneyFee,
      kSimQuizChallenge
    ],
  ),
  2: LevelMeta(
    id: 2,
    name: 'Woodlands Heights',
    subtitle: 'Conquer debt and build savings',
    price: kLevel2Price,
    xpReward: kLevel2XpReward,
    emoji: '🏘️',
    businesses: [
      'CopperTech Electronics',
      'PrimeWear Boutique',
      'Savanna Fuel Station',
    ],
    simulations: [kSimDebt, kSimSavingsGoal, kSimInflation],
  ),
  3: LevelMeta(
    id: 3,
    name: 'Levy Financial District',
    subtitle: 'Invest and grow your wealth',
    price: kLevel3Price,
    xpReward: kLevel3XpReward,
    emoji: '📈',
    businesses: [
      'Zambezi Capital Investments',
      'Kafue Property Holdings',
      'FutureGrowth Agro Ventures',
    ],
    simulations: [kSimInvestment, kSimCompoundGrowth, kSimPortfolio],
  ),
  4: LevelMeta(
    id: 4,
    name: 'Mukuba Enterprise Park',
    subtitle: 'Launch and run your enterprise',
    price: kLevel4Price,
    xpReward: kLevel4XpReward,
    emoji: '🏭',
    businesses: [
      'CopperRise Manufacturing',
      'ZamTech Innovations',
      'GreenHarvest Exporters',
    ],
    simulations: [kSimPacra, kSimRevenue, kSimPayroll, kSimTax],
  ),
};

// ─────────────────────────────────────────────────────────────────────────────
// Mobile Money Providers
// ─────────────────────────────────────────────────────────────────────────────

const String kProviderMTN = 'MTN MoMo';
const String kProviderAirtel = 'Airtel Money';

// ─────────────────────────────────────────────────────────────────────────────
// Misc
// ─────────────────────────────────────────────────────────────────────────────

/// Number of taps on the version label required to open the dev screen.
const int kDevScreenTapCount = 7;

/// Simulated payment delay in milliseconds (2 seconds).
const int kPaymentDelayMs = 2000;

/// ZMW inflation rate used in simulations (12% per annum as of 2024).
const double kZmwInflationRate = 0.12;

/// Bank of Zambia indicative lending rate (used in savings simulations).
const double kBozLendingRate = 0.26;

/// Compound interest rate options used in Level 3 compound growth chart.
const List<double> kCompoundRates = [0.08, 0.15, 0.22];

// ─────────────────────────────────────────────────────────────────────────────
// Daily Challenge
// ─────────────────────────────────────────────────────────────────────────────

/// Name of the Hive box that stores [DailyChallengeRecord] objects, keyed by uid.
const String kDailyChallengeBox = 'daily_challenge';

/// Key used when storing/fetching the single record per user.
const String kDailyChallengeKey = 'record';

/// XP awarded for a correct daily challenge answer.
const int kDailyChallengeXp = 25;

/// A Streak Shield is earned every [kStreakShieldInterval] consecutive days.
const int kStreakShieldInterval = 3;

/// Maximum number of Streak Shields a user can hold at once.
const int kMaxStreakShields = 3;

// ─────────────────────────────────────────────────────────────────────────────
// Engagement Feature — Hive Box Names
// ─────────────────────────────────────────────────────────────────────────────

/// Hive box for per-user per-chapter story progress (StoryChapterProgress).
const String kStoryBox = 'story';

// ─────────────────────────────────────────────────────────────────────────────
// Gamification — New Hive Box Names (Wave 0)
// ─────────────────────────────────────────────────────────────────────────────

const String kHeartsBox = 'hearts';
const String kInventoryBox = 'inventory';
const String kBossBox = 'boss_records';
const String kStreakBox = 'streak';

// ─────────────────────────────────────────────────────────────────────────────
// My Life Features — Hive Box Names
// ─────────────────────────────────────────────────────────────────────────────

const String kFamilyBox = 'family';
const String kBusinessBox = 'business';
const String kLifeEventsBox = 'life_events';

// ─────────────────────────────────────────────────────────────────────────────
// My Finances Features — Hive Box Names
// ─────────────────────────────────────────────────────────────────────────────

const String kPropertyBox = 'property';
const String kInvestmentsBox = 'investments';
const String kLoansBox = 'loans';
const String kSavingsGoalsBox = 'savings_goals';

// ─────────────────────────────────────────────────────────────────────────────
// Property Feature Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Monthly property value appreciation rate (3% per month, educational display).
const double kPropertyMonthlyAppreciation = 0.03;

// ─────────────────────────────────────────────────────────────────────────────
// Portfolio Feature Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Max snapshots kept for the portfolio line chart.
const int kPortfolioMaxSnapshots = 30;

// ─────────────────────────────────────────────────────────────────────────────
// Loans Feature Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Starting credit score for new players.
const int kCreditScoreDefault = 650;

/// Credit score threshold required to take a business loan.
const int kBusinessLoanMinCreditScore = 700;

/// Credit score penalty for an overdue loan payment.
const int kOverdueCreditPenalty = 50;

/// Credit score reward for an on-time loan payment.
const int kOnTimeCreditReward = 5;

// ─────────────────────────────────────────────────────────────────────────────
// Savings Feature Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Maximum number of savings goals a player can have simultaneously.
const int kMaxSavingsGoals = 5;

// ─────────────────────────────────────────────────────────────────────────────
// Analytics & Visualization Features — Hive Box Names
// ─────────────────────────────────────────────────────────────────────────────

const String kNewsBox   = 'news';
const String kHealthBox = 'health';

// ─────────────────────────────────────────────────────────────────────────────
// Net Worth Constants
// ─────────────────────────────────────────────────────────────────────────────

/// 1 ZamCoin = ZMW 10 (educational exchange rate for net worth display).
const int kZamCoinToZMW = 10;

// ─────────────────────────────────────────────────────────────────────────────
// News Feature Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Number of headlines shown per rotation cycle.
const int kNewsDisplayCount = 5;

/// Days between headline rotations.
const int kNewsRotationDays = 7;

// ─────────────────────────────────────────────────────────────────────────────
// Health Score Constants
// ─────────────────────────────────────────────────────────────────────────────

const int kHealthSubScoreMax = 20; // max per sub-score
const int kHealthHistoryMax  = 12; // weeks of history kept

// ─────────────────────────────────────────────────────────────────────────────
// Educational Content Features — Hive Box Names
// ─────────────────────────────────────────────────────────────────────────────

const String kMythsBox        = 'myths';
const String kSpotlightsBox   = 'spotlights';
const String kMentorsBox      = 'mentors';
const String kProverbsBox     = 'proverbs';
const String kDailyRoutineBox = 'daily_routine';

// ─────────────────────────────────────────────────────────────────────────────
// Myth-Busting Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Myth cards surfaced per day.
const int kMythsPerDay = 3;

// ─────────────────────────────────────────────────────────────────────────────
// Mentor Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Financial Health Score threshold required to unlock Mentor 5 (Mwansa).
const int kMentorHealthScoreUnlock = 70;

// ─────────────────────────────────────────────────────────────────────────────
// Proverb Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Total proverbs in the collection; completing all unlocks "Elder of Wisdom".
const int kTotalProverbs = 25;

// ─────────────────────────────────────────────────────────────────────────────
// Daily Routine Constants
// ─────────────────────────────────────────────────────────────────────────────

const int kMorningTipXp          = 10;
const int kMiddayQuizXp           = 25;
const int kEveningReflectionXp    = 15;
const int kPerfectDayXp           = 50;
const int kPerfectDayCoins        = 15;
const int kPerfectWeekCoins       = 100;
const int kPerfectWeekStreak      = 7;

// ─────────────────────────────────────────────────────────────────────────────
// Family Feature Constants
// ─────────────────────────────────────────────────────────────────────────────

/// School fees cost in ZMW per term.
const int kFamilySchoolFees = 450;

/// Happiness boost (points) from paying school fees.
const int kFamilySchoolFeesHappinessBoost = 8;

/// ZamCoins cost to trigger a family happiness boost outing.
const int kFamilyHappinessBoostCost = 20;

/// Happiness gained from a family outing.
const int kFamilyHappinessBoostAmount = 15;

// ─────────────────────────────────────────────────────────────────────────────
// Business Feature Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Days between available weekly business decisions.
const int kBusinessDecisionIntervalDays = 7;

/// Compliance score fully registered (PACRA + ZRA + NAPSA).
const int kBusinessMaxCompliance = 100;

/// ZamCoins earned when business reaches stage 3+.
const int kBusinessStageUpReward = 30;

// ─────────────────────────────────────────────────────────────────────────────
// Life Events Feature Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Probability (0.0–1.0) that a life event triggers on any given day.
const double kLifeEventTriggerChance = 0.70;

// ─────────────────────────────────────────────────────────────────────────────
// Hearts Config
// ─────────────────────────────────────────────────────────────────────────────

const int kMaxHearts = 5;
const int kHeartRefillMinutes = 30;

// ─────────────────────────────────────────────────────────────────────────────
// Power-up IDs
// ─────────────────────────────────────────────────────────────────────────────

const String kPowerUpHintToken = 'hint_token';
const String kPowerUpShield = 'shield';
const String kPowerUpFreeze = 'freeze';
const String kPowerUpXpMultiplier = 'xp_multiplier';
const String kPowerUpDoubleXp = 'double_xp';
const String kPowerUpMysteryBox = 'mystery_box';

const Map<String, int> kDefaultPowerUps = {
  kPowerUpHintToken: 0,
  kPowerUpShield: 0,
  kPowerUpFreeze: 0,
  kPowerUpXpMultiplier: 0,
  kPowerUpDoubleXp: 0,
  kPowerUpMysteryBox: 0,
};

// ─────────────────────────────────────────────────────────────────────────────
// Avatar IDs
// ─────────────────────────────────────────────────────────────────────────────

const String kAvatarStudent = 'student';
const String kAvatarTrader = 'trader';
const String kAvatarFarmer = 'farmer';
const String kAvatarEntrepreneur = 'entrepreneur';
const String kAvatarCivilServant = 'civil_servant';
const String kAvatarInnovator = 'innovator';

const List<String> kAvatarIds = [
  kAvatarStudent,
  kAvatarTrader,
  kAvatarFarmer,
  kAvatarEntrepreneur,
  kAvatarCivilServant,
  kAvatarInnovator,
];

// ─────────────────────────────────────────────────────────────────────────────
// Daily Bonus Schedule (day 1–7)
// ─────────────────────────────────────────────────────────────────────────────

// powerUp: null = none, otherwise a kPowerUp* constant
const List<Map<String, dynamic>> kDailyBonusSchedule = [
  {'coins': 10, 'xp': 0, 'powerUp': null},
  {'coins': 15, 'xp': 50, 'powerUp': null},
  {'coins': 20, 'xp': 0, 'powerUp': kPowerUpHintToken},
  {'coins': 25, 'xp': 100, 'powerUp': null},
  {'coins': 30, 'xp': 0, 'powerUp': kPowerUpShield},
  {'coins': 40, 'xp': 150, 'powerUp': null},
  {'coins': 60, 'xp': 0, 'powerUp': kPowerUpDoubleXp},
];

// ─────────────────────────────────────────────────────────────────────────────
// Wallet Earn Amounts (ZMW coins per sim level)
// ─────────────────────────────────────────────────────────────────────────────

const int kWalletEarnLevel1 = 5;
const int kWalletEarnLevel2 = 10;
const int kWalletEarnLevel3 = 15;
const int kWalletEarnLevel4 = 20;
const int kWalletEarnBossDefeat = 100;

// ─────────────────────────────────────────────────────────────────────────────
// Quiz System — Category Constants
// ─────────────────────────────────────────────────────────────────────────────

const String kCatBudgeting = 'BUDGETING';
const String kCatSavings = 'SAVINGS';
const String kCatDebt = 'DEBT';
const String kCatInvesting = 'INVESTING';
const String kCatEntrepreneurship = 'ENTREPRENEURSHIP';
const String kCatZambianFinance = 'ZAMBIAN_FINANCE';

const int kQuizXpCorrect = 30;
const int kQuizXpIncorrect = 0;
const int kQuizCoinsCorrect = 10;

// ─────────────────────────────────────────────────────────────────────────────
// Quiz System — QuizQuestion data class
// ─────────────────────────────────────────────────────────────────────────────

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
    this.xpReward = kQuizXpCorrect,
  });

  final String id;
  final String question;
  final List<String> options; // always 4
  final int correctIndex;
  final String explanation;
  final String category;
  final int xpReward;
}

// ─────────────────────────────────────────────────────────────────────────────
// Quiz Bank — 60 questions across 6 categories
// ─────────────────────────────────────────────────────────────────────────────

const List<QuizQuestion> kQuizQuestions = [
  // ── BUDGETING (10) ──────────────────────────────────────────────────────────

  QuizQuestion(
    id: 'q_b_01',
    category: kCatBudgeting,
    question:
        'The 50/30/20 rule recommends allocating what percentage of your income to savings and debt repayment?',
    options: ['10%', '20%', '30%', '50%'],
    correctIndex: 1,
    explanation:
        'The 50/30/20 rule: 50% for needs (rent, food), 30% for wants (leisure), and 20% for savings and debt repayment. It is a simple starting framework for any income level.',
  ),
  QuizQuestion(
    id: 'q_b_02',
    category: kCatBudgeting,
    question:
        'Your monthly income is ZMW 5,000 and your rent is ZMW 1,800. What percentage of your income goes to rent?',
    options: ['28%', '36%', '45%', '18%'],
    correctIndex: 1,
    explanation:
        '1,800 ÷ 5,000 = 0.36 = 36%. Financial advisors recommend keeping housing costs below 30% of gross income. At 36%, this household is slightly over-housed.',
  ),
  QuizQuestion(
    id: 'q_b_03',
    category: kCatBudgeting,
    question: 'What is a discretionary expense?',
    options: [
      'A fixed monthly obligation like rent or loan repayment',
      'Optional spending on wants rather than needs',
      'A tax-deductible business cost',
      'A government-mandated contribution',
    ],
    correctIndex: 1,
    explanation:
        'Discretionary expenses are non-essential wants — entertainment, dining out, new clothes. They are the first category to reduce when building a budget or cutting costs.',
  ),
  QuizQuestion(
    id: 'q_b_04',
    category: kCatBudgeting,
    question: 'What does a zero-based budget mean?',
    options: [
      'Starting each month with zero savings',
      'Every kwacha is assigned a purpose so income minus allocations equals zero',
      'Spending nothing for an entire month',
      'A budget with no fixed expenses',
    ],
    correctIndex: 1,
    explanation:
        'Zero-based budgeting means every kwacha has a job. Income − (all allocations) = 0. This forces intentional decisions about every category and eliminates untracked spending.',
  ),
  QuizQuestion(
    id: 'q_b_05',
    category: kCatBudgeting,
    question: '"Pay yourself first" in personal finance means:',
    options: [
      'Pay the largest bill first each month',
      'Transfer your savings amount before spending anything else',
      'Always keep some cash on your person',
      'Pay suppliers before receiving payment from customers',
    ],
    correctIndex: 1,
    explanation:
        'Paying yourself first means transferring your savings target on payday, before any discretionary spending. Savings become automatic rather than whatever is left over at month end.',
  ),
  QuizQuestion(
    id: 'q_b_06',
    category: kCatBudgeting,
    question: 'A budget deficit means:',
    options: [
      'You saved more than planned this month',
      'You spent more than you earned',
      'You have unallocated surplus funds',
      'A term that only applies to government budgets',
    ],
    correctIndex: 1,
    explanation:
        'A personal budget deficit means your expenses exceeded your income. Persistent deficits lead to debt accumulation. Identifying and eliminating the deficit category is the first step to financial recovery.',
  ),
  QuizQuestion(
    id: 'q_b_07',
    category: kCatBudgeting,
    question: 'What is a sinking fund?',
    options: [
      'An emergency reserve for unexpected events',
      'Savings set aside deliberately for a known future expense',
      'A type of loan with declining interest',
      'A bank account with a withdrawal penalty',
    ],
    correctIndex: 1,
    explanation:
        'A sinking fund is intentional savings for a specific known future cost — school fees in April, car service in June, Christmas gifts in December. Unlike an emergency fund, the timing and amount are predictable.',
  ),
  QuizQuestion(
    id: 'q_b_08',
    category: kCatBudgeting,
    question: 'Which of the following is a FIXED expense?',
    options: [
      'Weekly airtime top-ups',
      'Restaurant meals with friends',
      'Monthly rent',
      'Weekend entertainment',
    ],
    correctIndex: 2,
    explanation:
        'Fixed expenses remain the same amount each month — rent, loan repayments, subscription fees. Variable expenses fluctuate. Understanding this distinction helps predict monthly cash flow accurately.',
  ),
  QuizQuestion(
    id: 'q_b_09',
    category: kCatBudgeting,
    question: 'Personal cash flow refers to:',
    options: [
      'How much physical cash you carry on your person',
      'The actual movement of money into and out of your accounts',
      'Your total net worth at a point in time',
      'The rate at which your salary grows annually',
    ],
    correctIndex: 1,
    explanation:
        'Cash flow tracks real money in versus real money out. Positive cash flow (more in than out) allows saving and investing. Negative cash flow leads to debt. Monitoring it monthly is fundamental to financial health.',
  ),
  QuizQuestion(
    id: 'q_b_10',
    category: kCatBudgeting,
    question:
        'When prioritising your budget, which category should typically be funded LAST?',
    options: [
      'Housing costs',
      'Food and groceries',
      'Debt repayments',
      'Entertainment and leisure'
    ],
    correctIndex: 3,
    explanation:
        'The correct order: needs (housing, food, transport, utilities), then obligations (debt repayments, NAPSA), then savings, then wants (entertainment, leisure). Wants are funded with whatever remains after the essentials.',
  ),

  // ── SAVINGS (10) ────────────────────────────────────────────────────────────

  QuizQuestion(
    id: 'q_s_01',
    category: kCatSavings,
    question: 'Compound interest is best described as:',
    options: [
      'Interest calculated only on the original principal each period',
      'A flat bank fee for holding your savings',
      'Interest calculated on both the principal and previously earned interest',
      'A government surcharge on savings account earnings',
    ],
    correctIndex: 2,
    explanation:
        'Compound interest earns interest on interest. A ZMW 1,000 deposit at 10% earns ZMW 100 in year 1, then in year 2 it earns 10% on ZMW 1,100 = ZMW 110. The growth accelerates over time.',
  ),
  QuizQuestion(
    id: 'q_s_02',
    category: kCatSavings,
    question: 'What does APY (Annual Percentage Yield) measure?',
    options: [
      'The fee charged by a bank per year',
      'The actual annual return including the effect of compounding',
      'The average payment a bank makes yearly',
      'The minimum annual deposit required',
    ],
    correctIndex: 1,
    explanation:
        'APY (Annual Percentage Yield) reflects how much you actually earn per year, accounting for compounding. It is always equal to or higher than APR (Annual Percentage Rate). Use APY to compare savings products accurately.',
  ),
  QuizQuestion(
    id: 'q_s_03',
    category: kCatSavings,
    question:
        'You save ZMW 400 per month for 3 years with no interest. How much do you have at the end?',
    options: ['ZMW 12,000', 'ZMW 14,400', 'ZMW 4,800', 'ZMW 1,200'],
    correctIndex: 1,
    explanation:
        'ZMW 400 × 36 months = ZMW 14,400. This is a simple linear savings calculation. Adding even a modest interest rate would grow this further through compounding.',
  ),
  QuizQuestion(
    id: 'q_s_04',
    category: kCatSavings,
    question:
        'Using the Rule of 72, how long does it take to double money at an 8% annual interest rate?',
    options: ['12 years', '9 years', '6 years', '18 years'],
    correctIndex: 1,
    explanation:
        'Rule of 72: divide 72 by the interest rate. 72 ÷ 8 = 9 years. This quick mental tool helps compare investment options without a calculator.',
  ),
  QuizQuestion(
    id: 'q_s_05',
    category: kCatSavings,
    question: 'A chilimba (rotating savings group) is:',
    options: [
      'A government savings programme for low-income earners',
      'An informal savings club where members contribute regularly and take turns receiving the total pool',
      'A type of bank fixed deposit account',
      'A microfinance loan product',
    ],
    correctIndex: 1,
    explanation:
        'Chilimba is a traditional Zambian rotating savings club (also called a tontine or ROSCA). Members contribute a fixed amount regularly and one member receives the full pool each cycle. It enforces saving discipline through social accountability.',
  ),
  QuizQuestion(
    id: 'q_s_06',
    category: kCatSavings,
    question:
        'If inflation is 12% per year and your savings account pays 5% interest, what is your real return?',
    options: ['+17%', '+5%', '-7%', '0%'],
    correctIndex: 2,
    explanation:
        'Real return = nominal interest rate − inflation rate = 5% − 12% = −7%. Your money is actually losing purchasing power despite earning nominal interest. This is why beating inflation matters.',
  ),
  QuizQuestion(
    id: 'q_s_07',
    category: kCatSavings,
    question:
        'Simple interest on ZMW 5,000 at 10% per year for 2 years equals:',
    options: ['ZMW 500', 'ZMW 1,000', 'ZMW 1,100', 'ZMW 1,500'],
    correctIndex: 1,
    explanation:
        'Simple interest = Principal × Rate × Time = 5,000 × 10% × 2 = ZMW 1,000. Unlike compound interest, simple interest does not earn interest on the interest already accumulated.',
  ),
  QuizQuestion(
    id: 'q_s_08',
    category: kCatSavings,
    question: 'What is the key difference between saving and investing?',
    options: [
      'Saving is only for the wealthy; investing is for everyone',
      'Saving preserves money with low risk; investing grows money with higher risk and potentially higher returns',
      'They are the same — both keep money in a bank',
      'Investing is tax-free; saving is taxed',
    ],
    correctIndex: 1,
    explanation:
        'Saving is conservative (bank accounts, mobile money) — low risk, low return, high liquidity. Investing accepts risk to pursue higher returns (unit trusts, stocks, property). Both have a role in a healthy financial plan.',
  ),
  QuizQuestion(
    id: 'q_s_09',
    category: kCatSavings,
    question:
        'A financial emergency fund should ideally cover how many months of essential expenses?',
    options: ['1 month', '2 months', '3–6 months', '12 months'],
    correctIndex: 2,
    explanation:
        'Financial advisors universally recommend 3–6 months of essential expenses in a liquid emergency fund. This covers job loss, medical emergencies, or major repairs without resorting to high-interest debt.',
  ),
  QuizQuestion(
    id: 'q_s_10',
    category: kCatSavings,
    question:
        'Which savings vehicle typically offers the highest long-term real returns?',
    options: [
      'Cash kept at home in a safe',
      'A standard bank savings account',
      'Diversified investments (unit trusts, stocks)',
      'A mobile money wallet',
    ],
    correctIndex: 2,
    explanation:
        'Over the long term, diversified investments outperform savings accounts and inflation. Cash at home earns nothing and loses value to inflation. Mobile money wallets typically earn no interest.',
  ),

  // ── DEBT (10) ───────────────────────────────────────────────────────────────

  QuizQuestion(
    id: 'q_d_01',
    category: kCatDebt,
    question: 'The debt avalanche method involves:',
    options: [
      'Paying off the smallest debt balance first',
      'Paying off the highest-interest debt first to minimise total interest',
      'Taking a consolidation loan to cover all debts',
      'Ignoring debts until savings reach a target level',
    ],
    correctIndex: 1,
    explanation:
        'The avalanche method attacks the highest-interest debt first. It minimises the total interest paid over time, making it the mathematically optimal repayment strategy.',
  ),
  QuizQuestion(
    id: 'q_d_02',
    category: kCatDebt,
    question: 'The debt snowball method involves:',
    options: [
      'Paying the highest-interest debt first',
      'Paying the smallest debt balance first for quick motivational wins',
      'Combining all debts into one large loan',
      'Freezing spending entirely while in debt',
    ],
    correctIndex: 1,
    explanation:
        'The snowball method eliminates small debts first. The psychological wins of closing accounts keep motivation high. It may cost more interest than the avalanche but works better behaviourally for many people.',
  ),
  QuizQuestion(
    id: 'q_d_03',
    category: kCatDebt,
    question:
        'Annual interest on a ZMW 10,000 loan at 25% interest with no payments made equals:',
    options: ['ZMW 1,500', 'ZMW 2,000', 'ZMW 2,500', 'ZMW 3,000'],
    correctIndex: 2,
    explanation:
        'ZMW 10,000 × 25% = ZMW 2,500 in interest for one year. Your balance after 12 months with no payments would be ZMW 12,500. This illustrates why leaving loans unpaid is so costly.',
  ),
  QuizQuestion(
    id: 'q_d_04',
    category: kCatDebt,
    question:
        'True or False: Paying only the minimum required monthly payment is the fastest way to clear a loan.',
    options: ['True', 'False'],
    correctIndex: 1,
    explanation:
        'False. Minimum payments mostly cover interest, barely reducing the principal. Paying extra above the minimum reduces the principal faster, dramatically cutting both the loan duration and total interest paid.',
  ),
  QuizQuestion(
    id: 'q_d_05',
    category: kCatDebt,
    question: 'A loan guarantor is:',
    options: [
      'A government agency that approves personal loans',
      'A person who legally agrees to repay the loan if the primary borrower cannot',
      'A special type of interest-free loan',
      'The bank officer who processes your application',
    ],
    correctIndex: 1,
    explanation:
        'A guarantor takes on full legal liability if you default. If you miss payments, the lender can pursue the guarantor\'s assets. Being a guarantor is a serious financial commitment that should never be taken lightly.',
  ),
  QuizQuestion(
    id: 'q_d_06',
    category: kCatDebt,
    question: 'A debt-to-income (DTI) ratio of 40% means:',
    options: [
      '40% of your total assets are financed by debt',
      '40% of your monthly income is going toward debt repayments',
      'You have borrowed 40% more than your annual income',
      'Your outstanding interest charges equal 40% of the principal',
    ],
    correctIndex: 1,
    explanation:
        'DTI ratio = monthly debt payments ÷ monthly gross income × 100. At 40%, most lenders consider you near maximum borrowing capacity. Many Zambian banks prefer DTI below 35% for new loan approvals.',
  ),
  QuizQuestion(
    id: 'q_d_07',
    category: kCatDebt,
    question: 'Loan amortisation means:',
    options: [
      'An additional penalty fee for early repayment',
      'Repaying a loan through scheduled instalments that cover both interest and principal',
      'Writing off a debt without making any payment',
      'Converting a loan from one currency to another',
    ],
    correctIndex: 1,
    explanation:
        'An amortising loan has fixed instalments where the proportion of interest vs principal changes each period. Early payments are mostly interest; later payments mostly reduce principal. Understanding amortisation helps plan extra payments strategically.',
  ),
  QuizQuestion(
    id: 'q_d_08',
    category: kCatDebt,
    question:
        'True or False: Missing a loan payment in Zambia has no long-term effect on your ability to borrow in the future.',
    options: ['True', 'False'],
    correctIndex: 1,
    explanation:
        'False. Zambian credit bureaus (such as Compuscan) record your payment history. Missed payments create a negative credit record that can disqualify you from future loans or result in higher interest rates.',
  ),
  QuizQuestion(
    id: 'q_d_09',
    category: kCatDebt,
    question: 'Which type of debt is generally considered "productive"?',
    options: [
      'A loan taken to buy fashionable clothing',
      'A loan taken to invest in income-generating assets or education',
      'A loan taken for a holiday',
      'A loan taken to pay off another loan',
    ],
    correctIndex: 1,
    explanation:
        'Productive debt funds assets that generate returns above the borrowing cost — a business loan, investment property, or skills training. Consumer debt funds depreciating or consumed items and generally reduces net worth.',
  ),
  QuizQuestion(
    id: 'q_d_10',
    category: kCatDebt,
    question: 'The key difference between secured and unsecured debt is:',
    options: [
      'Secured loans require collateral, typically carry lower interest rates; unsecured loans have no collateral and typically higher rates',
      'Secured loans are guaranteed by the government; unsecured are private',
      'Secured loans have no interest; unsecured have variable interest',
      'There is no practical difference for borrowers',
    ],
    correctIndex: 0,
    explanation:
        'Secured loans (mortgage, car loan) are backed by an asset the lender can seize if you default. This reduces lender risk, so rates are lower. Unsecured loans (personal loans, credit cards) carry higher rates because there is no collateral.',
  ),

  // ── INVESTING (10) ──────────────────────────────────────────────────────────

  QuizQuestion(
    id: 'q_i_01',
    category: kCatInvesting,
    question: 'Owning a share of a company means:',
    options: [
      'You have lent the company money at a fixed interest rate',
      'You are a part-owner and may receive dividends and benefit from growth',
      'You have a guaranteed annual payment from the company',
      'You have access to the company\'s bank accounts',
    ],
    correctIndex: 1,
    explanation:
        'Shareholders are partial owners. If the company grows and profits, share value increases and dividends may be paid. If it performs poorly, you can lose money. There is no guarantee — unlike a bond or bank deposit.',
  ),
  QuizQuestion(
    id: 'q_i_02',
    category: kCatInvesting,
    question: 'LuSE in Zambia stands for:',
    options: [
      'A Zambian mobile money product',
      'The Lusaka Securities Exchange — Zambia\'s stock market',
      'A government youth entrepreneurship loan scheme',
      'A type of savings account offered by local banks',
    ],
    correctIndex: 1,
    explanation:
        'LuSE (Lusaka Securities Exchange) is Zambia\'s stock market, established in 1994. It allows companies to raise capital from the public and gives Zambians access to equity investments in listed companies.',
  ),
  QuizQuestion(
    id: 'q_i_03',
    category: kCatInvesting,
    question: 'A dividend is:',
    options: [
      'A stockbroker\'s transaction fee',
      'A portion of company profits distributed to shareholders',
      'The penalty for selling shares before a holding period',
      'The change in price of a share between two periods',
    ],
    correctIndex: 1,
    explanation:
        'Dividends reward shareholders from company profits. Not all companies pay dividends — growth companies often reinvest profits instead. Dividend-paying stocks provide an income stream alongside potential capital appreciation.',
  ),
  QuizQuestion(
    id: 'q_i_04',
    category: kCatInvesting,
    question:
        'True or False: An investment\'s past performance guarantees its future performance.',
    options: ['True', 'False'],
    correctIndex: 1,
    explanation:
        'False. Past performance is not a guarantee of future results — this is a legal disclaimer on every investment product for good reason. Markets are influenced by countless unpredictable factors. Evaluate investments on fundamentals, not just history.',
  ),
  QuizQuestion(
    id: 'q_i_05',
    category: kCatInvesting,
    question: 'Investment liquidity refers to:',
    options: [
      'The proportion of liquid assets to solid physical assets',
      'How quickly and easily an investment can be converted to cash without significant loss',
      'The annual return expressed as a percentage of the investment',
      'A government restriction on foreign investment flows',
    ],
    correctIndex: 1,
    explanation:
        'Liquid investments (cash, publicly traded shares) can be sold quickly. Illiquid investments (property, private business) take time and may require price concessions to sell. Always match investment liquidity to when you may need the funds.',
  ),
  QuizQuestion(
    id: 'q_i_06',
    category: kCatInvesting,
    question: 'A bond is best described as:',
    options: [
      'Partial ownership in a business',
      'A fixed-income debt instrument where you lend money to a government or company in exchange for regular interest payments',
      'A type of share with a guaranteed price',
      'An insurance policy for investment losses',
    ],
    correctIndex: 1,
    explanation:
        'Bonds are essentially IOUs. You lend money to the issuer (government or corporation) for a fixed period. They pay you regular interest (coupon) and return your principal at maturity. Bonds are generally lower risk than equities.',
  ),
  QuizQuestion(
    id: 'q_i_07',
    category: kCatInvesting,
    question: 'Return on Investment (ROI) is calculated as:',
    options: [
      '(Profit ÷ Cost of Investment) × 100%',
      '(Cost of Investment ÷ Profit) × 100%',
      '(Profit + Cost) ÷ Number of Years',
      'Interest Rate × Time Period',
    ],
    correctIndex: 0,
    explanation:
        'ROI = (Net Profit ÷ Cost of Investment) × 100%. If you invest ZMW 1,000 and earn ZMW 200 profit, your ROI is 20%. It is the universal measure for comparing the efficiency of different investments.',
  ),
  QuizQuestion(
    id: 'q_i_08',
    category: kCatInvesting,
    question:
        'True or False: Diversification completely eliminates all investment risk.',
    options: ['True', 'False'],
    correctIndex: 1,
    explanation:
        'False. Diversification reduces unsystematic (company-specific) risk. However, systematic (market-wide) risk — economic downturns, currency crashes, political instability — affects all investments and cannot be diversified away.',
  ),
  QuizQuestion(
    id: 'q_i_09',
    category: kCatInvesting,
    question: 'A unit trust is:',
    options: [
      'A government housing allocation programme',
      'A pooled investment vehicle managed by professionals where many investors share a diversified portfolio',
      'A type of bank loan for small businesses',
      'A government bond with a fixed guaranteed return',
    ],
    correctIndex: 1,
    explanation:
        'Unit trusts pool money from many investors. A professional fund manager invests it across a diversified portfolio. This gives small investors access to diversified holdings that would be unaffordable individually.',
  ),
  QuizQuestion(
    id: 'q_i_10',
    category: kCatInvesting,
    question: 'Investment horizon refers to:',
    options: [
      'The maximum return an investment promises',
      'The length of time you plan to hold an investment before needing the money',
      'The geographic region in which you are investing',
      'The annual management fee charged by investment firms',
    ],
    correctIndex: 1,
    explanation:
        'Investment horizon determines appropriate risk levels. Short horizons (1–3 years) suit low-risk, liquid assets. Long horizons (10+ years) allow higher-risk investments that can ride out volatility and benefit from compound growth.',
  ),

  // ── ENTREPRENEURSHIP (10) ───────────────────────────────────────────────────

  QuizQuestion(
    id: 'q_e_01',
    category: kCatEntrepreneurship,
    question: 'Gross profit margin is calculated as:',
    options: [
      '(Revenue − Cost of Goods Sold) ÷ Revenue × 100%',
      'Net profit divided by total number of employees',
      'Revenue minus all expenses including tax and salaries',
      'Total sales minus marketing and advertising costs only',
    ],
    correctIndex: 0,
    explanation:
        'Gross profit margin = (Revenue − COGS) ÷ Revenue × 100%. It shows how efficiently you produce or buy your goods. A low gross margin leaves little room for operating expenses and profit.',
  ),
  QuizQuestion(
    id: 'q_e_02',
    category: kCatEntrepreneurship,
    question: 'PACRA in Zambia does NOT handle:',
    options: [
      'Registering companies and businesses',
      'Issuing Taxpayer Identification Numbers (TPIN)',
      'Registering trademarks and patents',
      'Maintaining a register of company directors',
    ],
    correctIndex: 1,
    explanation:
        'TPIN is issued by the Zambia Revenue Authority (ZRA), not PACRA. PACRA (Patents and Companies Registration Agency) handles business registration, trademark registration, and company director records.',
  ),
  QuizQuestion(
    id: 'q_e_03',
    category: kCatEntrepreneurship,
    question: 'A business reaches its break-even point when:',
    options: [
      'Total revenue equals total costs — zero profit or loss',
      'Profit equals the amount of tax payable',
      'All business loans have been fully repaid',
      'Monthly cash flow turns positive for the first time',
    ],
    correctIndex: 0,
    explanation:
        'Break-even is where Revenue = Total Fixed Costs + Total Variable Costs. Below break-even you make a loss; above it you make a profit. Knowing your break-even is essential for pricing decisions.',
  ),
  QuizQuestion(
    id: 'q_e_04',
    category: kCatEntrepreneurship,
    question: 'True or False: Business revenue and profit are the same thing.',
    options: ['True', 'False'],
    correctIndex: 1,
    explanation:
        'False. Revenue is the total money received from sales. Profit is what remains after subtracting all costs (COGS, rent, salaries, tax). A business can have high revenue but still make a loss if costs are too high.',
  ),
  QuizQuestion(
    id: 'q_e_05',
    category: kCatEntrepreneurship,
    question: 'Working capital in a business is:',
    options: [
      'The total annual salary bill for all employees',
      'Current assets minus current liabilities — funds available for day-to-day operations',
      'The total value of all company assets combined',
      'The owner\'s personal savings invested in the business',
    ],
    correctIndex: 1,
    explanation:
        'Working capital = Current Assets − Current Liabilities. Positive working capital means the business can pay its short-term obligations. Negative working capital signals a cash flow crisis, even if the business is profitable on paper.',
  ),
  QuizQuestion(
    id: 'q_e_06',
    category: kCatEntrepreneurship,
    question:
        'ZRA\'s turnover tax in Zambia applies to businesses with annual turnover below:',
    options: ['ZMW 200,000', 'ZMW 800,000', 'ZMW 2,000,000', 'ZMW 5,000,000'],
    correctIndex: 1,
    explanation:
        'Zambia\'s turnover tax regime applies to businesses with annual turnover below ZMW 800,000. It is simpler than corporate income tax and is charged as a percentage of gross revenue rather than net profit.',
  ),
  QuizQuestion(
    id: 'q_e_07',
    category: kCatEntrepreneurship,
    question: 'Why can a profitable business still run out of cash?',
    options: [
      'Because profit automatically transfers to a separate account',
      'Because profit is recorded when a sale is made, but cash arrives only when the customer actually pays',
      'Because profitable businesses must pay higher taxes',
      'There is no difference — profit and cash are always the same',
    ],
    correctIndex: 1,
    explanation:
        'Profit and cash are not the same. A business selling on credit may show profit before receiving payment. If suppliers demand cash before customers pay, the business faces a cash shortfall despite being profitable — a common cause of business failure.',
  ),
  QuizQuestion(
    id: 'q_e_08',
    category: kCatEntrepreneurship,
    question:
        'True or False: Having a great product idea alone is enough to guarantee business success.',
    options: ['True', 'False'],
    correctIndex: 1,
    explanation:
        'False. Most failed businesses had good ideas. Execution, pricing, marketing, cash flow management, timing, and customer relationships are equally critical. Many brilliant ideas have failed for lack of financial discipline.',
  ),
  QuizQuestion(
    id: 'q_e_09',
    category: kCatEntrepreneurship,
    question: 'An invoice with "Net 30" payment terms means:',
    options: [
      'The customer pays 30% upfront and the rest upon delivery',
      'The full invoice amount is due within 30 days of the invoice date',
      'A 30% discount applies if the invoice is paid immediately',
      'Payment is due on the 30th of the current month',
    ],
    correctIndex: 1,
    explanation:
        'Net 30 means the buyer must pay the full amount within 30 calendar days of the invoice date. Standard B2B payment terms in Zambia range from Net 7 to Net 60. Late payments are a major cause of cash flow problems for small suppliers.',
  ),
  QuizQuestion(
    id: 'q_e_10',
    category: kCatEntrepreneurship,
    question: 'CEEC in Zambia is:',
    options: [
      'A financial technology startup',
      'The Citizens Economic Empowerment Commission — a government fund providing loans and grants to Zambian entrepreneurs',
      'A bank specialising in agricultural lending',
      'A stock exchange for small and medium businesses',
    ],
    correctIndex: 1,
    explanation:
        'CEEC (Citizens Economic Empowerment Commission) provides accessible financing — grants, loans, and capacity building — to Zambian citizens, particularly previously disadvantaged groups, to start and grow businesses.',
  ),

  // ── ZAMBIAN_FINANCE (10) ────────────────────────────────────────────────────

  QuizQuestion(
    id: 'q_z_01',
    category: kCatZambianFinance,
    question: 'The Bank of Zambia\'s primary mandate is:',
    options: [
      'Maximising government tax revenue',
      'Maintaining price stability and regulating and supervising financial institutions',
      'Managing the Lusaka Stock Exchange',
      'Issuing business licences to financial companies',
    ],
    correctIndex: 1,
    explanation:
        'The Bank of Zambia (BoZ) is Zambia\'s central bank. It controls monetary policy, regulates commercial banks, manages foreign exchange reserves, and issues the Zambian kwacha.',
  ),
  QuizQuestion(
    id: 'q_z_02',
    category: kCatZambianFinance,
    question:
        'When the kwacha depreciates against the US dollar, what typically happens to the price of imported goods?',
    options: [
      'They become cheaper because the kwacha is weaker',
      'They become more expensive because more kwacha are needed per dollar',
      'Their prices remain unchanged because suppliers absorb the difference',
      'They are restricted from import until the kwacha recovers',
    ],
    correctIndex: 1,
    explanation:
        'Currency depreciation makes imports more expensive. If ZMW 25 = USD 1 and the kwacha drops to ZMW 28 = USD 1, an item costing USD 10 rises from ZMW 250 to ZMW 280. Fuel, medicine, and electronics are particularly affected in Zambia.',
  ),
  QuizQuestion(
    id: 'q_z_03',
    category: kCatZambianFinance,
    question: 'Zambia\'s primary foreign exchange earner is:',
    options: [
      'Maize and agriculture',
      'Tourism and hospitality',
      'Copper and mining',
      'Manufacturing and textiles'
    ],
    correctIndex: 2,
    explanation:
        'Copper accounts for approximately 70–80% of Zambia\'s export earnings. This makes the economy highly sensitive to global copper prices. When copper prices fall, the kwacha weakens and government revenues decline.',
  ),
  QuizQuestion(
    id: 'q_z_04',
    category: kCatZambianFinance,
    question: 'NAPSA (National Pension Scheme Authority) is best described as:',
    options: [
      'A commercial bank for government employees',
      'A mandatory defined-contribution pension fund for formal-sector employees',
      'A health insurance provider covering hospitalisation costs',
      'A government grant programme for small businesses',
    ],
    correctIndex: 1,
    explanation:
        'NAPSA is Zambia\'s mandatory pension scheme. Both employees (5%) and employers (5%) contribute monthly, capped at ZMW 1,221.80 each (2024). Benefits are accessible at retirement age, permanent emigration, or death of the contributor.',
  ),
  QuizQuestion(
    id: 'q_z_05',
    category: kCatZambianFinance,
    question:
        'True or False: Self-employed people in Zambia pay tax through the PAYE (Pay As You Earn) system.',
    options: ['True', 'False'],
    correctIndex: 1,
    explanation:
        'False. PAYE applies only to employees whose employers deduct income tax from their salaries. Self-employed individuals and business owners file income tax returns directly with ZRA on a quarterly or annual basis.',
  ),
  QuizQuestion(
    id: 'q_z_06',
    category: kCatZambianFinance,
    question:
        'The primary financial impact of ZESCO load-shedding on small Zambian businesses is:',
    options: [
      'Reduced electricity bills due to less usage',
      'Higher operational costs and lost revenue from running generators and production downtime',
      'Lower internet connectivity costs',
      'Automatic reduction in staff salary obligations',
    ],
    correctIndex: 1,
    explanation:
        'Load-shedding forces businesses to run diesel generators, significantly increasing operational costs. Refrigeration-dependent businesses (butcheries, pharmacies) risk stock losses. Service businesses lose billable hours. It is a major barrier to Zambian SME growth.',
  ),
  QuizQuestion(
    id: 'q_z_07',
    category: kCatZambianFinance,
    question:
        'Businesses in Zambia must register for VAT once their annual turnover exceeds:',
    options: ['ZMW 200,000', 'ZMW 400,000', 'ZMW 800,000', 'ZMW 1,000,000'],
    correctIndex: 2,
    explanation:
        'Zambian law requires VAT registration when annual taxable turnover exceeds ZMW 800,000. Registered businesses charge 16% VAT on eligible sales and can reclaim VAT paid on business inputs.',
  ),
  QuizQuestion(
    id: 'q_z_08',
    category: kCatZambianFinance,
    question:
        'The Financial Intelligence Centre (FIC) in Zambia primarily exists to:',
    options: [
      'Monitor and control consumer price inflation',
      'Receive and analyse suspicious transaction reports to combat money laundering and financial crime',
      'Investigate business license fraud by PACRA registrants',
      'Regulate insider trading on the Lusaka Stock Exchange',
    ],
    correctIndex: 1,
    explanation:
        'The FIC is Zambia\'s financial intelligence unit. Banks and financial institutions must report suspicious transactions. The FIC analyses these reports, identifies financial crime patterns, and shares intelligence with law enforcement.',
  ),
  QuizQuestion(
    id: 'q_z_09',
    category: kCatZambianFinance,
    question:
        'True or False: The Lusaka Securities Exchange (LuSE) is located in Ndola.',
    options: ['True', 'False'],
    correctIndex: 1,
    explanation:
        'False. The Lusaka Securities Exchange (LuSE) is located in Lusaka, Zambia\'s capital. It was established in 1994 and lists a range of Zambian companies. Ndola is Zambia\'s second-largest city and the commercial capital of the Copperbelt.',
  ),
  QuizQuestion(
    id: 'q_z_10',
    category: kCatZambianFinance,
    question: 'A ZRA TPIN (Taxpayer Identification Number) is required for:',
    options: [
      'Buying airtime or mobile data',
      'Purchasing goods at any formal retailer',
      'Filing tax returns, registering a business, and some banking transactions',
      'Applying for a national identity card',
    ],
    correctIndex: 2,
    explanation:
        'A TPIN is mandatory for filing ZRA tax returns, registering a business with PACRA, applying for government tenders, and some banking services. Every formal business in Zambia must have one.',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Kwacha Chronicles — Illustration Tag Constants
// ─────────────────────────────────────────────────────────────────────────────

const String kIllustMarketStall = 'MARKET_STALL';
const String kIllustSupplier = 'SUPPLIER';
const String kIllustCoins = 'COINS';
const String kIllustBuilding = 'BUILDING';
const String kIllustCertificate = 'CERTIFICATE';

// ─────────────────────────────────────────────────────────────────────────────
// Kwacha Chronicles — StoryChapterData class
// ─────────────────────────────────────────────────────────────────────────────

class StoryChapterData {
  const StoryChapterData({
    required this.chapterId,
    required this.title,
    required this.content,
    required this.illustrationTag,
    required this.xpCost,
    required this.zamCoinCost,
    required this.choiceA,
    required this.choiceB,
    required this.choiceAOutcome,
    required this.choiceBOutcome,
  });

  final int chapterId;
  final String title;
  final String content;
  final String illustrationTag;
  final int xpCost;
  final int zamCoinCost;
  final String choiceA;
  final String choiceB;
  final String choiceAOutcome;
  final String choiceBOutcome;
}

// ─────────────────────────────────────────────────────────────────────────────
// Kwacha Chronicles — 20 Chapters
// ─────────────────────────────────────────────────────────────────────────────

const List<StoryChapterData> kStoryChapters = [
  StoryChapterData(
    chapterId: 1,
    title: 'The Inheritance',
    illustrationTag: kIllustMarketStall,
    xpCost: 0,
    zamCoinCost: 0,
    content:
        'Mwansa receives a call on a Tuesday morning that changes everything. Her Aunt Chanda, who ran a small vegetable stall at Soweto Market for twenty years, has passed away peacefully after a short illness. The aunt had no children and left everything to Mwansa — the stall license, a worn notebook filled with supplier contacts, and a tin box containing ZMW 1,400 in cash savings accumulated carefully over many months of disciplined trading.\n\n'
        'Mwansa has never run a business before. She works as a receptionist at a dental clinic in Rhodespark, earning ZMW 3,200 each month. The market stall, when well-stocked with fresh vegetables and tomatoes, generates roughly ZMW 800 in net profit per month — not enough to replace her salary but significant nonetheless.\n\n'
        'Her cousin Bwalya, who sometimes helped Aunt Chanda restock on weekends, calls that same evening. He proposes they run the stall together and split all profits fifty-fifty. Mwansa has 48 hours to decide before market management reassigns the spot to someone on the waiting list.\n\n'
        'Financial lesson: Inherited assets require immediate, clear-headed decisions. Emotion can cloud judgement when evaluating partnership proposals from family members.',
    choiceA: 'Take over the stall alone and manage it after work hours',
    choiceB: 'Partner with Bwalya and split profits fifty-fifty',
    choiceAOutcome:
        'You take on the challenge alone. The first weeks are exhausting — rushing from the clinic to the market before closing time — but you keep 100% of the profit and every decision is yours. Within six weeks you develop a rhythm. Financial lesson: Sole proprietorship gives full control and full reward but demands full personal effort.',
    choiceBOutcome:
        'Bwalya agrees enthusiastically but misses three restocking days in the first month. You spend more time managing conflict than managing customers. The partnership has no written agreement, which makes it legally difficult to separate. Financial lesson: Partnerships need clear written agreements before money is involved.',
  ),
  StoryChapterData(
    chapterId: 2,
    title: 'The First Restock',
    illustrationTag: kIllustSupplier,
    xpCost: 100,
    zamCoinCost: 20,
    content:
        'The tin box holds ZMW 1,400. Mwansa stands at the wholesale market at 5:30 am, surrounded by traders haggling for tomatoes, onions, sweet potatoes, and kapenta. She has never bought stock in bulk before. Her aunt\'s notebook lists three suppliers: Ba Tembo for vegetables, Mama Chileshe for dry goods, and a wholesaler called Greenfield Agro on the edge of the market.\n\n'
        'Ba Tembo offers her two options. She can buy ZMW 600 of fresh produce today and receive a small loyalty discount on her next order if she pays cash immediately. Or she can take ZMW 900 of produce on a seven-day credit arrangement — pay after she sells — at a 12% markup on the credit amount.\n\n'
        'Mwansa does the mathematics. On credit: ZMW 900 + ZMW 108 interest = ZMW 1,008 total cost. Cash: ZMW 600 with a future discount. She has the cash available. But the larger stock might mean more sales.\n\n'
        'Financial lesson: Credit financing for stock has a real cost. Calculate the true cost of credit (principal plus interest) against your expected profit margin before accepting.',
    choiceA: 'Pay ZMW 600 cash for a smaller but debt-free first restock',
    choiceB: 'Take ZMW 900 on credit to maximise first-week stock',
    choiceAOutcome:
        'You buy ZMW 600 of stock and sell everything within four days, netting ZMW 860 after market fees. You restock again with ZMW 700 from your earnings. By end of week two you have ZMW 1,640 total — ZMW 240 ahead of where you started. Financial lesson: Starting small and debt-free allows compounding growth without interest burden.',
    choiceBOutcome:
        'The extra stock sells well but not fast enough. Some tomatoes spoil by day five. You sell ZMW 830 worth and owe ZMW 1,008. After repayment you are left with ZMW 222 — less than if you had bought smaller. Financial lesson: Unsold perishable stock is not an asset. Inventory management is as important as sales volume.',
  ),
  StoryChapterData(
    chapterId: 3,
    title: 'The Loan Decision',
    illustrationTag: kIllustCoins,
    xpCost: 150,
    zamCoinCost: 30,
    content:
        'Two months into running the stall, Mwansa has built steady relationships with suppliers and regulars. Her monthly net profit averages ZMW 950. A microfinance officer visits the market and approaches her directly. The officer explains that Mwansa qualifies for a ZMW 3,000 business loan at 28% annual interest, repayable over six months.\n\n'
        'With ZMW 3,000 she could diversify — add fresh fruit and dry goods — potentially doubling her stock and profit. The monthly repayment would be approximately ZMW 570 including interest, leaving her roughly ZMW 380 per month after the loan payment if profit stays at ZMW 950.\n\n'
        'However, Mwansa has also been saving ZMW 300 per month from the stall profit. By month four she will have ZMW 1,200 in savings. She could wait two more months and use her own money. But the market rainy season is approaching — the best sales period — and timing matters.\n\n'
        'Financial lesson: Debt amplifies both success and failure. Before borrowing, calculate your true ability to service the debt from operational profit, not projected profit.',
    choiceA: 'Take the ZMW 3,000 loan now and expand before rainy season',
    choiceB: 'Wait two more months and self-fund the expansion with savings',
    choiceAOutcome:
        'The rainy season delivers strong sales. Expanded stock sells well and monthly profit rises to ZMW 1,400. After repaying ZMW 570 monthly, you net ZMW 830 — less than before the loan but the expanded customer base stays after the loan is repaid. Total interest paid: ZMW 420. Financial lesson: Debt timing matters — borrowing ahead of a high-revenue season can justify the cost.',
    choiceBOutcome:
        'You wait and save. Month four arrives and you have ZMW 1,200. You expand conservatively using your own money. The expansion is slower but every kwacha of increased profit is fully yours. You miss some rainy-season peak but avoid interest payments. Financial lesson: Patience with self-funding preserves margin. The compounding effect favours those who avoid unnecessary interest costs.',
  ),
  StoryChapterData(
    chapterId: 4,
    title: 'The Bad Debtor',
    illustrationTag: kIllustBuilding,
    xpCost: 200,
    zamCoinCost: 40,
    content:
        'A restaurant owner named Mr Phiri has been buying produce from Mwansa on informal credit for six weeks, always paying by Friday. This week his total outstanding balance is ZMW 750 — nearly a full week of stock cost. On Friday he does not appear. His phone rings without answer. On Monday a fellow vendor tells Mwansa that Mr Phiri has closed his restaurant and moved back to Kitwe.\n\n'
        'ZMW 750 is gone. That is nearly one full month of stall profit. Mwansa is not only financially set back — she is furious. She has no written agreement, no receipt signed by Mr Phiri, and nothing legally enforceable.\n\n'
        'She reflects on her credit policy. Several other market customers ask to buy on account. Ba Tembo the supplier advises her to set a firm credit limit and always get a signature. Her cousin Bwalya says informal credit is just the cost of doing business and she should accept it.\n\n'
        'Financial lesson: Trade credit without documentation is an unsecured gift. Every business needs a credit policy before extending informal loans to customers.',
    choiceA: 'Stop all customer credit entirely — cash only from now on',
    choiceB:
        'Keep offering credit but introduce a ZMW 200 limit and written receipts',
    choiceAOutcome:
        'Two of your best regular customers, small restaurants, move to a competitor who still offers credit. Monthly sales drop ZMW 280 for six weeks before stabilising with a new cash-only customer base. Financial lesson: Eliminating credit entirely can cost loyal customers. Balance risk management with commercial flexibility.',
    choiceBOutcome:
        'You print simple credit receipt forms. Customers sign each time. Your ZMW 200 limit means maximum exposure per customer is manageable. Bad debts drop significantly. Regular restaurant clients stay because the process feels professional and trustworthy. Financial lesson: Systems prevent losses better than blanket refusals. Documentation transforms goodwill credit into enforceable business practice.',
  ),
  StoryChapterData(
    chapterId: 5,
    title: 'School Fees Season',
    illustrationTag: kIllustCoins,
    xpCost: 200,
    zamCoinCost: 40,
    content:
        'It is late March. Mwansa has two children — a daughter in Grade 7 and a son in Grade 3. Their school fees for the April term are ZMW 1,800 combined. The school has a strict policy: no fees, no class entry after April 5th. Mwansa did not save separately for school fees. Her stall has been performing well but the money has gone back into stock, equipment, and her household.\n\n'
        'Her current stall savings account holds ZMW 620. She needs ZMW 1,180 more in two weeks. Options are limited: she could ask a relative for an emergency loan, take stock on extended credit from a supplier to free up the ZMW 620, or take a small personal loan from a microfinance institution at high interest.\n\n'
        'Her neighbour suggests a chilimba group that pays out ZMW 1,500 to one member next week — and that member has offered to swap positions with Mwansa in exchange for a small fee.\n\n'
        'Financial lesson: Seasonal obligations like school fees must be planned as sinking funds, not emergency costs. The stress Mwansa feels today is the price of not planning ahead.',
    choiceA: 'Take a microfinance loan at 35% annual interest for ZMW 1,200',
    choiceB:
        'Swap chilimba positions and pay the fee to access ZMW 1,500 early',
    choiceAOutcome:
        'The loan arrives quickly. Fees are paid on time. Monthly repayments of ZMW 240 over six months stretch your budget but are manageable. Total interest: approximately ZMW 210. Children attend school without disruption. Financial lesson: Planned debt for essential obligations is sometimes rational, but the same ZMW 210 could have been saved in monthly instalments before the deadline.',
    choiceBOutcome:
        'You swap positions for a ZMW 80 fee. Fees are paid. Next month your own chilimba payout does not come because you already received your allocation early. The cycle adjusts but you learn the mechanics of rotating savings. Financial lesson: Informal savings groups offer real financial flexibility when built into a planned routine rather than used as emergency rescue.',
  ),
  StoryChapterData(
    chapterId: 6,
    title: 'The Kwacha Drop',
    illustrationTag: kIllustMarketStall,
    xpCost: 250,
    zamCoinCost: 50,
    content:
        'The news breaks on a Monday morning: the kwacha has depreciated 11% against the dollar over the past two weeks. The radio announcer explains that fuel costs are rising because Zambia imports refined petroleum priced in US dollars. Mwansa listens while setting up her stall.\n\n'
        'By midday she feels it directly. Her regular cooking oil supplier calls: the price of a 20-litre drum is rising from ZMW 380 to ZMW 430. Transport costs for her wholesale supply run have increased. Even plastic bags are slightly more expensive, as they are imported.\n\n'
        'Her stall prices have been fixed for three months. Her regular customers expect consistency. But her margins are shrinking. She must decide: raise her prices and risk losing price-sensitive customers, or absorb the higher input costs and accept lower profit for now while hoping the kwacha recovers.\n\n'
        'Financial lesson: Currency depreciation is an invisible tax on import-dependent businesses. Building a cash buffer during strong periods allows you to absorb currency shocks without making desperate reactive pricing decisions.',
    choiceA: 'Raise stall prices immediately to protect your margin',
    choiceB: 'Absorb the cost increase for now and reassess in 30 days',
    choiceAOutcome:
        'You raise prices moderately — about 7%. Most regulars accept it after you explain honestly that input costs rose. Three price-sensitive customers reduce their orders. Overall profit margin recovers to near-normal levels. Financial lesson: Transparent, reasoned price communication preserves customer relationships better than silent increases.',
    choiceBOutcome:
        'Margin falls from 27% to 19% for the month. But the kwacha partially recovers after three weeks as copper prices strengthen. By the end of the month your costs stabilise without having disrupted customer relationships. Financial lesson: Short-term margin sacrifice can preserve long-term customer loyalty. Building cash reserves makes this strategy viable.',
  ),
  StoryChapterData(
    chapterId: 7,
    title: 'The First Employee',
    illustrationTag: kIllustBuilding,
    xpCost: 300,
    zamCoinCost: 60,
    content:
        'The stall is now generating ZMW 1,300 net profit per month. Mwansa is exhausted. She wakes at 4:30 am to reach the wholesale market before prices rise, runs the stall through the day, and spends evenings on accounts and planning. She is missing important moments with her children and her performance at the dental clinic has begun to slip.\n\n'
        'A young woman named Chisomo approaches her. She is 19 years old, recently finished Grade 12, and lives in the same neighbourhood. She is looking for honest work and has helped at a relative\'s shop. She asks for ZMW 900 per month plus a small sales bonus.\n\n'
        'With Chisomo managing the stall from midday, Mwansa could focus on the clinic and visit the wholesale market only three mornings a week. But ZMW 900 is 69% of current net profit. Can the stall absorb this cost? And what are her legal obligations as an employer in Zambia?\n\n'
        'Financial lesson: Hiring is a leveraged investment. The right employee can multiply your output, but employment in Zambia carries NAPSA obligations, written contract requirements, and notice period rules.',
    choiceA:
        'Hire Chisomo at ZMW 900 per month with a written employment contract',
    choiceB:
        'Continue alone but reduce stall hours to manage workload sustainably',
    choiceAOutcome:
        'Chisomo proves reliable and customers like her. Within six weeks the stall\'s improved consistency grows daily turnover by 18%. Net profit rises to ZMW 1,550. After Chisomo\'s wage the stall nets ZMW 650 — but your time at the clinic improves your performance and you avoid burnout. Financial lesson: Delegation can cost money but protect your most limited resource: your time and health.',
    choiceBOutcome:
        'Reduced hours mean less stock and fewer customers. Profit drops to ZMW 980. You are less exhausted but the business is smaller. A competitor takes some of your former customers. Financial lesson: Sometimes accepting a lower profit ceiling is the right life decision. Not every business must grow if growth costs your wellbeing.',
  ),
  StoryChapterData(
    chapterId: 8,
    title: 'PACRA Registration',
    illustrationTag: kIllustCertificate,
    xpCost: 300,
    zamCoinCost: 60,
    content:
        'A Zambia Revenue Authority officer visits Soweto Market for a compliance exercise. She explains that informal businesses operating under a trading name other than the owner\'s personal name must register with PACRA. Mwansa has been trading as "Chanda\'s Fresh Produce" — her aunt\'s name. She has continued using the name out of respect, but it is not her legal name.\n\n'
        'Registration at PACRA for a Business Name costs ZMW 295 for the certificate. The ZRA officer explains that with a registered business name, Mwansa can open a proper business bank account, apply for formal loans at lower interest rates, bid on institutional supply contracts, and file taxes cleanly.\n\n'
        'Some market neighbours tell Mwansa not to register — it will attract tax attention and cost more money. Others say registration is the first step toward legitimate growth. The PACRA office is a 20-minute minibus ride away.\n\n'
        'Financial lesson: Formalisation has an upfront cost but opens doors to cheaper credit, formal procurement, and legal protection. The informal economy provides safety in obscurity; the formal economy provides access to scale.',
    choiceA: 'Register with PACRA immediately and open a business bank account',
    choiceB:
        'Remain informal for now and revisit registration when profit is higher',
    choiceAOutcome:
        'Registration takes one day and costs ZMW 295. You open a Zanaco business account. Three months later a school nutrition programme issues a tender for vegetable supply. You qualify because you have a registered business name and a business bank account. The contract adds ZMW 600 monthly in reliable income. Financial lesson: Formalisation is an investment, not just a cost.',
    choiceBOutcome:
        'You continue informally. No immediate consequences. But six months later a business banking product launches with preferential loan rates for registered businesses. You cannot access it. Staying informal is a comfortable but limiting choice. Financial lesson: Informal status creates a ceiling on growth. The timing of formalisation should be strategic, not indefinitely deferred.',
  ),
  StoryChapterData(
    chapterId: 9,
    title: 'The Theft',
    illustrationTag: kIllustBuilding,
    xpCost: 350,
    zamCoinCost: 70,
    content:
        'On a Thursday evening, Mwansa stays late to accept a large vegetable delivery. She locks the stall and takes a crowded minibus home. The next morning she arrives to find the padlock cut and ZMW 1,200 worth of stock stolen — primarily high-value tomatoes, cooking oil, and onions. The market security guard saw nothing.\n\n'
        'She has no insurance. Her entire working capital for the week is gone. She owes her vegetable supplier ZMW 600 for credit stock that is now in a thief\'s hands. She has Chisomo to pay at month end. Her stall will stand empty today.\n\n'
        'A fellow trader offers to lend her ZMW 500 informally to restock partially and keep the stall running. A microfinance officer happens to be in the market and offers an emergency loan of ZMW 2,000 at 40% annual interest. Another option is to contact a market stallholders association that offers a small emergency fund to registered members.\n\n'
        'Financial lesson: Every business faces disruption events. Insurance and emergency cash reserves are the professional response. Relying on informal goodwill or expensive emergency credit each time is financially unsustainable.',
    choiceA: 'Accept the informal ZMW 500 loan and restock at a smaller scale',
    choiceB: 'Take the ZMW 2,000 microfinance emergency loan and fully restock',
    choiceAOutcome:
        'You restock partially with ZMW 500 and reopen within 24 hours. Turnover is 60% of normal for two weeks while you rebuild stock. You repay the ZMW 500 to your fellow trader within 10 days. The loss is painful but contained. You immediately research a simple goods insurance policy. Financial lesson: Starting small after a crisis is humbling but manageable. Speed of recovery matters more than scale of recovery.',
    choiceBOutcome:
        'Full restock happens fast. Revenue returns to normal within one week. But the ZMW 2,000 loan at 40% adds approximately ZMW 67 monthly in repayments over 12 months. The total theft cost was ZMW 1,200; the total loan cost is ZMW 1,600 when interest is included. Financial lesson: Emergency debt amplifies loss. The true cost of the theft just became ZMW 400 more expensive through interest.',
  ),
  StoryChapterData(
    chapterId: 10,
    title: 'ZRA Tax Returns',
    illustrationTag: kIllustCertificate,
    xpCost: 350,
    zamCoinCost: 70,
    content:
        'It is June. Mwansa has been registered with PACRA for four months. A ZRA letter arrives at her stall address advising her to file her first annual tax return and obtain a TPIN. The letter is formal and slightly intimidating. She calls the ZRA helpline and learns she qualifies for the presumptive tax regime — a simplified tax for small businesses — because her annual turnover is below ZMW 800,000.\n\n'
        'Presumptive tax is calculated on her taxable turnover, not her profit. A ZRA officer at the office explains this carefully. Mwansa has kept rough records in a notebook but has no formal income statement. She is missing receipts from three months of stock purchases.\n\n'
        'A neighbourhood accountant named Mr Mfula offers to file her returns for ZMW 350. He will also set up a simple record-keeping system going forward. Alternatively, Mwansa can attempt to file herself at the ZRA offices — it is free but will take a full day she cannot easily afford.\n\n'
        'Financial lesson: Tax compliance is an ongoing obligation, not a one-time event. Good record-keeping is the foundation of painless tax filing. The cost of an accountant is often less than the cost of missing records.',
    choiceA: 'Hire Mr Mfula to file professionally and set up record-keeping',
    choiceB:
        'Self-file at ZRA — it is free and she will learn the process herself',
    choiceAOutcome:
        'Mr Mfula files correctly, identifies a deductible expense Mwansa missed, and saves her more than ZMW 350 in tax. He creates a simple spreadsheet she updates weekly. Next year\'s filing takes two hours and costs nothing. Financial lesson: Professional advice pays for itself when it prevents errors and reveals deductions.',
    choiceBOutcome:
        'The ZRA office day is long and confusing. An officer is helpful but the forms require income data Mwansa cannot produce accurately. She estimates and files, worried about errors. She resolves to keep better records next year. Financial lesson: Self-filing is empowering once you understand the process. The learning curve has a real cost in time, uncertainty, and potential errors.',
  ),
  StoryChapterData(
    chapterId: 11,
    title: 'The Second Stall',
    illustrationTag: kIllustMarketStall,
    xpCost: 400,
    zamCoinCost: 80,
    content:
        'Mwansa has been running her stall for fourteen months. Net profit is consistently ZMW 1,200 per month after Chisomo\'s wages. Her business bank account holds ZMW 3,400 in savings. A stall immediately adjacent to hers becomes available when its elderly owner retires. Market management offers it to Mwansa first — ZMW 800 per month rent — because she is a good standing tenant.\n\n'
        'A second stall could double capacity. She could specialise: the first stall for fresh vegetables, the second for dry goods and cooking essentials. Combined potential monthly turnover could reach ZMW 9,000, with projected net profit around ZMW 1,800 after both rent costs, additional stock, and a second part-time worker.\n\n'
        'However, the second stall requires ZMW 1,600 in first-month costs (rent plus deposit plus initial stock). It also demands more management. Mwansa\'s current systems are stable but not yet robust enough to manage two units without direct oversight.\n\n'
        'Financial lesson: Expansion is exciting but must be funded from surplus, not desperation. Ask: do my current systems and people support this, or will growth break what is already working?',
    choiceA: 'Take the second stall immediately and expand aggressively',
    choiceB: 'Decline and consolidate — strengthen systems before expanding',
    choiceAOutcome:
        'You open the second stall. The first two months are chaotic. Stock management across two units strains Chisomo and you personally. By month three, systems stabilise and combined profit exceeds ZMW 1,900. The growth was hard but the location will not come available again. Financial lesson: Controlled chaos during expansion is normal. The key is having enough cash buffer to absorb the transition period.',
    choiceBOutcome:
        'You decline. Another trader takes the stall. It performs well. You feel regret initially but channel the energy into improving your own systems. Six months later a different expansion opportunity arises — you are better prepared for it. Financial lesson: Discipline to wait for readiness creates more sustainable growth than chasing every opportunity.',
  ),
  StoryChapterData(
    chapterId: 12,
    title: 'The Silent Investor',
    illustrationTag: kIllustCoins,
    xpCost: 400,
    zamCoinCost: 80,
    content:
        'A man named Mr Tembo — no relation to her supplier — contacts Mwansa through a market connection. He runs a small investment group and has been watching her business grow. He offers to invest ZMW 8,000 into her stall operations in exchange for a 30% share of monthly profits in perpetuity.\n\n'
        'ZMW 8,000 would allow Mwansa to upgrade her stall structure, purchase a small refrigeration unit for extended produce life, and fund a six-month stock buffer. At current profit of ZMW 1,200 per month, 30% would be ZMW 360 monthly — potentially forever.\n\n'
        'She consults Mr Mfula the accountant. He calculates that ZMW 8,000 at ZMW 360 per month means Mr Tembo recoups his investment in roughly 22 months. After that Mwansa pays ZMW 360 monthly from her profit every month indefinitely unless she buys him out.\n\n'
        'Financial lesson: Equity investment has no maturity date. Unlike a loan with a fixed repayment term, giving away profit share means ongoing cost. Evaluate equity deals by their long-term cost, not their short-term cash injection.',
    choiceA: 'Accept Mr Tembo\'s ZMW 8,000 for a 30% profit share',
    choiceB:
        'Decline and save for the refrigeration unit independently over 8 months',
    choiceAOutcome:
        'The refrigeration unit reduces spoilage by 30%. Monthly profit rises to ZMW 1,600. Mr Tembo\'s 30% takes ZMW 480. You net ZMW 1,120 — slightly less than before, but growth continues. At what point does improved profit make the equity stake cost-effective versus buying him out? Track this carefully. Financial lesson: Equity investors accelerate growth but permanently reduce your margin unless a buyout clause is built into the agreement.',
    choiceBOutcome:
        'Eight months of disciplined saving accumulates ZMW 7,200. You negotiate a ZMW 9,500 refrigeration unit to ZMW 8,800 cash. Purchase made. Spoilage drops. Every kwacha of increased profit is entirely yours. Financial lesson: Patient self-funding preserves 100% equity ownership. The cost is time and the opportunity cost of delayed growth.',
  ),
  StoryChapterData(
    chapterId: 13,
    title: 'Harvest Season Rush',
    illustrationTag: kIllustSupplier,
    xpCost: 450,
    zamCoinCost: 90,
    content:
        'It is October. The harvest arrives from rural provinces and wholesale prices for tomatoes, maize, and sweet potatoes drop 35% compared to June. Mwansa\'s margins improve dramatically. Her stall is busier than ever — demand is high because more people are buying produce for restocking their own pantries and preserving food for the dry season.\n\n'
        'A wholesaler offers Mwansa a bulk deal: ZMW 4,500 buys enough tomatoes to last four weeks at current sales rates, at a 22% discount versus buying weekly. The tomatoes must be used or sold within three weeks. Her refrigeration unit helps but cannot handle the full quantity.\n\n'
        'If she takes the deal, she needs to move stock quickly, potentially selling to other smaller traders at a slight margin to avoid spoilage. If she passes on it, she continues buying weekly at higher prices, protecting her quality but missing the seasonal margin opportunity.\n\n'
        'Financial lesson: Seasonal price drops create bulk buying opportunities. The key constraint is storage capacity and sell-through rate. Buying more than you can sell before expiry is waste, not savings.',
    choiceA:
        'Take the bulk deal and aggressively sell on to neighbouring traders',
    choiceB: 'Stick to weekly buying and maintain quality control',
    choiceAOutcome:
        'You buy in bulk and sell 40% of the excess to three neighbouring small traders at a small markup. They are glad for the convenience. You move all stock within 19 days and net an extra ZMW 680 this month from the margin and bulk discount combined. Financial lesson: Seasonal surplus trading can create a wholesale income stream alongside your retail stall.',
    choiceBOutcome:
        'Quality remains high. No spoilage. Margins are better than the dry season but not exceptional. You miss the bulk opportunity but sleep soundly. Financial lesson: Predictable, quality-focused operations can be more sustainable than aggressive margin-chasing. Know which business model suits your capacity.',
  ),
  StoryChapterData(
    chapterId: 14,
    title: 'The Credit Crisis',
    illustrationTag: kIllustCoins,
    xpCost: 450,
    zamCoinCost: 90,
    content:
        'Mwansa extended ZMW 500 credit to a small tuck shop. That shop has now gone quiet — door padlocked, owner untraceable. Simultaneously, her biggest supplier, Greenfield Agro, changes its credit terms: instead of 14-day payment, all credit must now be settled in 7 days due to their own cash flow pressures.\n\n'
        'Mwansa faces a squeeze. She is owed ZMW 500 that may not come. She owes Greenfield ZMW 1,100 due in seven days. Her bank account holds ZMW 840. She is short ZMW 260, plus she needs ZMW 700 for next week\'s stock reorder.\n\n'
        'Option one: reduce this week\'s stock order to ZMW 400 and operate at half capacity while accumulating enough cash to pay the full Greenfield debt. Option two: ask a relative for a short-term ZMW 300 bridging loan. Option three: sell her refrigeration unit and use the cash.\n\n'
        'Financial lesson: A cash flow crisis is not the same as a business failure. Short-term illiquidity can destroy a profitable business if not managed calmly. The solution is almost always to slow down, conserve cash, and honour the most critical obligations first.',
    choiceA: 'Reduce stock order and operate at half capacity to preserve cash',
    choiceB: 'Borrow ZMW 300 from a relative for a short bridging loan',
    choiceAOutcome:
        'Half-capacity operation for two weeks feels humbling. A few customers buy from a competitor. But you honour the Greenfield debt and maintain the relationship. Within three weeks cash flow normalises. The supplier relationship stays intact. Financial lesson: Protecting your most critical supplier relationship is worth short-term sales loss. Reputation with suppliers is a business asset.',
    choiceBOutcome:
        'Relative lends ZMW 300 graciously. You repay within 10 days from sales. The bridging smooths the crisis without disrupting stock levels or the supplier relationship. Financial lesson: Trusted personal relationships are informal credit lines that cost only the obligation of repayment and relationship maintenance.',
  ),
  StoryChapterData(
    chapterId: 15,
    title: 'Staff Problems',
    illustrationTag: kIllustBuilding,
    xpCost: 500,
    zamCoinCost: 100,
    content:
        'Chisomo has been an excellent employee for eleven months. But recently she has been arriving 30 minutes late three days a week and twice handled customer money incorrectly, resulting in a ZMW 120 discrepancy that Mwansa had to cover personally. When Mwansa raises it privately, Chisomo becomes upset and says the stall\'s working hours are too long.\n\n'
        'Mwansa knows Chisomo well — she was reliable before. Something has changed. She does not want to lose her and the recruitment process for a replacement would take weeks. But the performance issues are affecting the stall directly.\n\n'
        'She must decide whether to give Chisomo a formal written warning (as required by Zambian labour law before any disciplinary action) or to have an informal conversation first to understand what is happening. Acting without following the correct process could expose Mwansa to a labour dispute.\n\n'
        'Financial lesson: Employment relationships in Zambia are governed by the Employment Code Act. Skipping proper disciplinary procedures — even with clear justification — can result in costly wrongful dismissal claims. Good HR practice protects both employer and employee.',
    choiceA: 'Issue a formal written warning as the first official step',
    choiceB:
        'Have a private informal conversation first before any formal action',
    choiceAOutcome:
        'The written warning shocks Chisomo but she takes it seriously. She reveals her mother is ill and she has been leaving early to help at home. You adjust her schedule by one hour. Performance recovers within two weeks. The written record protects you legally if performance does not improve. Financial lesson: Documented, fair process protects the business and respects the employee\'s dignity.',
    choiceBOutcome:
        'The informal conversation reveals Chisomo\'s family situation. You agree on a temporary adjusted schedule. Performance improves immediately. No formal documentation needed. Financial lesson: Not every performance issue requires formal escalation. Understanding context first can resolve conflict faster and preserve a productive working relationship.',
  ),
  StoryChapterData(
    chapterId: 16,
    title: 'Going Digital',
    illustrationTag: kIllustCertificate,
    xpCost: 500,
    zamCoinCost: 100,
    content:
        'An MTN MoMo business account representative visits Soweto Market offering merchant accounts to stall traders. The pitch: customers can pay via mobile money directly to Mwansa\'s business number. Statements are generated automatically, reducing record-keeping effort. Transaction fees are 1.5% per sale.\n\n'
        'Currently Mwansa operates fully in cash. She tracks revenue in a notebook. Cash handling means change problems, risk of theft, and the hassle of depositing at the bank. Going mobile-money-first could streamline operations.\n\n'
        'However, some of her oldest customers — particularly Ba Tembo\'s generation — are uncomfortable with mobile money. They bring exact kwacha amounts in worn envelopes and prefer the simplicity of physical exchange. If she insists on mobile payments, she may alienate a segment of loyal customers.\n\n'
        'Financial lesson: Digital financial tools offer efficiency, transparency, and security. But adoption transitions must consider your specific customer base. Forcing technology on customers who cannot or will not use it trades efficiency for loyalty.',
    choiceA: 'Switch fully to mobile money payments for all transactions',
    choiceB: 'Adopt mobile money as a secondary option alongside cash',
    choiceAOutcome:
        'Full digital transition loses four elderly regulars immediately. But younger customers embrace it. Record-keeping becomes effortless. Cash theft incidents disappear. Digital transaction history helps Mr Mfula prepare the next tax return in half the time. Financial lesson: Full digital transitions create short-term disruption but long-term operational gains in transparency and record quality.',
    choiceBOutcome:
        'Dual system works well. Younger customers use MoMo. Older customers continue with cash. The flexibility keeps everyone. You manually reconcile both streams weekly. Record-keeping improves but not dramatically. Financial lesson: Meeting customers where they are — rather than where you want them to be — retains loyalty while allowing gradual digital migration.',
  ),
  StoryChapterData(
    chapterId: 17,
    title: 'The CEEC Application',
    illustrationTag: kIllustCertificate,
    xpCost: 600,
    zamCoinCost: 120,
    content:
        'Mwansa learns about CEEC — the Citizens Economic Empowerment Commission — through a business workshop held at the market. CEEC offers qualifying Zambian entrepreneurs loans at subsidised interest rates and non-repayable grants for business development. The application requires: a registered business name (she has this), two years of trading history (she has 22 months), basic financial records (she has these thanks to Mr Mfula), and a written business plan.\n\n'
        'She has never written a formal business plan. The CEEC officer says a simple five-page plan is sufficient: describe the business, the market, your current financials, and how you will use the funds. Mwansa wants ZMW 15,000 to fund a proper dry-goods section in her stall, cold storage upgrade, and two months of working capital buffer.\n\n'
        'The application window closes in three weeks. She could write the plan herself with the officer\'s free template, or hire Mr Mfula at ZMW 500 to write it professionally with proper financial projections.\n\n'
        'Financial lesson: Grant and subsidised loan applications reward businesses with documentation. Two years of clean records and formal registration now pay dividends. Every administrative decision Mwansa made earlier — PACRA, ZRA, record-keeping — prepared her for this moment.',
    choiceA: 'Write the business plan yourself using the free CEEC template',
    choiceB: 'Hire Mr Mfula to write a professional business plan',
    choiceAOutcome:
        'Your plan is honest, clear, and reflects two years of real experience. The CEEC officer notes it lacks formal financial projections but appreciates the market knowledge shown. Application is shortlisted. Final outcome: ZMW 8,000 loan at 10% interest — lower than expected but meaningful. Financial lesson: Authentic, experience-based applications resonate. Perfect presentation matters less than credible evidence of viability.',
    choiceBOutcome:
        'Mr Mfula\'s plan is professionally formatted with a five-year revenue projection and cash flow table. Application score is high. Result: ZMW 12,000 loan at 10% and a ZMW 3,000 non-repayable equipment grant. The ZMW 500 fee returned multiples. Financial lesson: Professional presentation of real business strength amplifies grant success. Investing in your application\'s quality is itself a business investment.',
  ),
  StoryChapterData(
    chapterId: 18,
    title: 'The New Competition',
    illustrationTag: kIllustMarketStall,
    xpCost: 600,
    zamCoinCost: 120,
    content:
        'A new trader arrives at Soweto Market. He is young, well-funded, and rents the three-stall unit at the market\'s main entrance that was previously vacant. He sells the same fresh produce as Mwansa — tomatoes, onions, vegetables — and immediately prices everything 8% cheaper than her. He has a generator-powered refrigeration setup twice the size of hers.\n\n'
        'Within two weeks Mwansa\'s daily revenue drops 22%. Customers she has served for two years are shopping at the new stall for the lower prices. Chisomo is worried. The CEEC loan has just been received and Mwansa is committed to monthly repayments.\n\n'
        'She has several options: match his prices and accept lower margin, differentiate by adding products or services he does not offer, build customer loyalty through quality and personal relationships, or diversify her customer base to include institutional buyers who value consistency over price.\n\n'
        'Financial lesson: Competition is permanent. A business that survives only when there is no competitor has no real competitive advantage. The test of a business is how it responds to pressure — through differentiation, loyalty, or niche specialisation.',
    choiceA: 'Match his prices and compete directly on cost',
    choiceB:
        'Differentiate through quality, loyalty, and institutional supply contracts',
    choiceAOutcome:
        'Matching prices recovers some foot traffic but squeezes your margin to unsustainable levels. After six weeks you cannot afford your CEEC repayment comfortably. You must either find another cost reduction or concede the price-sensitive customers and refocus on value buyers. Financial lesson: Competing purely on price requires structural cost advantages. Without them, price wars destroy both competitors.',
    choiceBOutcome:
        'You focus on the school nutrition programme contract (which your competitor cannot access without a registered business) and build a loyal premium customer segment. Revenue recovers to 85% of pre-competition levels within two months — with better customers. Financial lesson: Competing on relationships and reliability rather than price creates a more defensible position.',
  ),
  StoryChapterData(
    chapterId: 19,
    title: 'The Crossroads',
    illustrationTag: kIllustBuilding,
    xpCost: 700,
    zamCoinCost: 140,
    content:
        'Three years after inheriting Aunt Chanda\'s stall, Mwansa faces the biggest decision of her professional life. Her stall is stable. CEEC loan repayments are on track. Monthly net profit from the stall is ZMW 2,100. Her dental clinic salary is still ZMW 3,400. Together she earns ZMW 5,500 per month — more than she has ever made.\n\n'
        'Two offers have arrived simultaneously. First: the dental clinic is expanding and has offered Mwansa a promoted role as Practice Manager at ZMW 4,800 per month — a raise, but a demanding full-time commitment that would make running the stall impossible. Second: a property developer is opening a new commercial complex in Woodlands and is offering ground-floor retail spaces at preferential rates to established market traders who want to formalise.\n\n'
        'Taking the clinic promotion means a secure salary increase, medical benefits, and a career in a stable sector — but gives up the stall she has built. Leasing at Woodlands means committing fully to her business, scaling it into a proper shop, and leaving employment income entirely.\n\n'
        'Financial lesson: This is the classic entrepreneur\'s crossroads — security versus ownership. There is no universally correct answer. The right choice depends on risk tolerance, family obligations, access to emergency funds, and long-term life goals.',
    choiceA: 'Accept the clinic promotion — secure income and career growth',
    choiceB: 'Lease the Woodlands space and commit fully to the business',
    choiceAOutcome:
        'You accept the promotion. The stall is handed over to Chisomo who runs it as a subcontracted arrangement — you supply the stock, she runs operations for a 35% share of profit. You earn ZMW 4,800 as Practice Manager plus approximately ZMW 1,300 from the stall arrangement — ZMW 6,100 total. Security comes with the sacrifice of day-to-day entrepreneurial control. Financial lesson: Structured delegation can preserve business income while you build a parallel career.',
    choiceBOutcome:
        'You sign the Woodlands lease at ZMW 4,500 per month. It is the scariest financial commitment of your life. But the new location and proper shop format attracts both walk-in customers and the institutional buyers you have been building relationships with for two years. By month four, monthly revenue exceeds ZMW 18,000. Financial lesson: The biggest business risks are often taken by those who have earned them through years of disciplined preparation.',
  ),
  StoryChapterData(
    chapterId: 20,
    title: 'The Harvest',
    illustrationTag: kIllustCertificate,
    xpCost: 0,
    zamCoinCost: 0,
    content:
        'It is a Tuesday morning — exactly three years after the phone call that changed everything. Mwansa sits at a small desk in the Woodlands shop before opening time. The CEEC loan is fully repaid. She employs Chisomo full-time and two part-time assistants. The school nutrition programme contract renews annually. Her business bank account holds ZMW 12,400 — the largest balance she has ever held.\n\n'
        'She opens the tin box that held Aunt Chanda\'s ZMW 1,400. It is empty now — that money was the seed. The harvest looks very different from the seed.\n\n'
        'Mwansa is not a wealthy woman by Lusaka\'s standards, but she is financially literate, debt-free on business obligations, has a growing enterprise, three employees who depend on her, and — most importantly — the knowledge that she earned every kwacha of it through deliberate, disciplined financial decision-making.\n\n'
        'She opens a notebook and writes at the top of a new page: "Year 4 Goals." The financial journey Aunt Chanda began twenty years ago at this market is not finished. It has simply changed hands.\n\n'
        'Congratulations on completing The Kwacha Chronicles. Mwansa\'s story teaches that financial success is not a single decision but the accumulated result of hundreds of small, deliberate choices made consistently over time.',
    choiceA: 'Begin Year 4 with an aggressive expansion plan',
    choiceB: 'Consolidate Year 3 gains and build a six-month emergency reserve',
    choiceAOutcome:
        'Expansion continues. New product lines. Possible second location. The story of Mwansa — and of ZamWealth Quest — is never truly finished. Every level you complete and every quiz you answer is a step forward in your own financial literacy journey. Keep going.',
    choiceBOutcome:
        'Consolidation and reserves give you the freedom to take calculated risks from a position of strength. A six-month emergency fund means no crisis can destroy what you have built. This is the foundation of lasting financial security. Well done for choosing patience over speed.',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Seasonal Events — SeasonalEvent data class
// ─────────────────────────────────────────────────────────────────────────────

class SeasonalEvent {
  const SeasonalEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.month,
    required this.theme,
    required this.challenge,
    required this.xpBonus,
    required this.zamCoinBonus,
  });

  final String id;
  final String title;
  final String description;
  final int month;
  final String theme;
  final String challenge;
  final int xpBonus;
  final int zamCoinBonus;
}

// Seasonal theme constants
const String kSeasonThemeNewYear = 'NEW_YEAR';
const String kSeasonThemeSchoolFees = 'SCHOOL_FEES';
const String kSeasonThemeFarming = 'FARMING';
const String kSeasonThemeHarvest = 'HARVEST';
const String kSeasonThemeChristmas = 'CHRISTMAS';

// ─────────────────────────────────────────────────────────────────────────────
// Seasonal Events — 5 Events
// ─────────────────────────────────────────────────────────────────────────────

const List<SeasonalEvent> kSeasonalEvents = [
  SeasonalEvent(
    id: 'se_jan',
    title: 'New Year Financial Reset',
    month: 1,
    theme: kSeasonThemeNewYear,
    description:
        'A new year is a chance to reset bad financial habits. Zambians often receive December bonuses and spend them impulsively, starting January with empty accounts. This event teaches goal-setting and January budget discipline — the most financially vulnerable month of the year.',
    challenge:
        'Set 3 SMART financial goals for the year (Specific, Measurable, Achievable, Relevant, Time-bound). Then complete a fresh budget simulation using your new income targets and the 50/30/20 rule. Allocate your goals as sinking funds within the budget.',
    xpBonus: 200,
    zamCoinBonus: 50,
  ),
  SeasonalEvent(
    id: 'se_apr',
    title: 'School Fees Season',
    month: 4,
    theme: kSeasonThemeSchoolFees,
    description:
        'April hits Zambian families hard. School fees, uniform costs, and stationery can total over ZMW 8,000 per child in private schools. Government schools still charge levies and exam fees. This event teaches planning ahead with a school fees sinking fund — saving monthly so April is not a crisis.',
    challenge:
        'Simulate paying school fees of ZMW 3,500 for two children while maintaining your monthly budget. Identify which categories you will reduce to cover the fees without borrowing. Calculate how much you would need to save monthly starting in January to have ZMW 7,000 ready by April 1st.',
    xpBonus: 250,
    zamCoinBonus: 60,
  ),
  SeasonalEvent(
    id: 'se_jun',
    title: 'Farming and Planting Season',
    month: 6,
    theme: kSeasonThemeFarming,
    description:
        'June marks the start of the planting season in many Zambian provinces. Farmers must spend heavily on inputs — seed, fertiliser, labour, and equipment — and then wait six months until December for harvest income. This event teaches agricultural cash flow management and the timing of farming input loans.',
    challenge:
        'Allocate ZMW 5,000 in farming inputs across seed (25%), fertiliser (40%), labour (25%), and transport (10%). Then simulate managing six months of household cash flow with no farm income. Calculate the minimum monthly household income needed to survive without borrowing during the growing period.',
    xpBonus: 300,
    zamCoinBonus: 75,
  ),
  SeasonalEvent(
    id: 'se_oct',
    title: 'Harvest and Trade Season',
    month: 10,
    theme: kSeasonThemeHarvest,
    description:
        'October brings harvest income for rural Zambians and a trading surge for market vendors. This event teaches the discipline of not spending all harvest income at once, prioritising loan repayment to maintain credit access, and saving a portion for the next planting season — completing the financial cycle responsibly.',
    challenge:
        'You receive ZMW 12,000 from your harvest sale. Allocate it across: repaying your input loan (minimum 40%), restocking for next season (20%), long-term savings (20%), and household expenses (20%). Ensure your loan is repaid in full before allocating to other categories.',
    xpBonus: 300,
    zamCoinBonus: 75,
  ),
  SeasonalEvent(
    id: 'se_dec',
    title: 'Christmas Spending and Saving',
    month: 12,
    theme: kSeasonThemeChristmas,
    description:
        'December is the most financially dangerous month for Zambians. Bonuses evaporate on celebrations, food, clothing, and gifts. January arrives empty-handed. This event teaches the December trap — spending everything and suffering through January — and the discipline of protecting a January survival fund before spending on festivity.',
    challenge:
        'You receive a ZMW 4,000 December bonus. Allocate it: first ring-fence ZMW 1,500 as your January survival fund. With the remaining ZMW 2,500, split between Christmas expenses, gifts, and personal savings. You cannot touch the January fund. Simulate your January budget to confirm you can survive on your regular income plus the ZMW 1,500 ring-fenced.',
    xpBonus: 250,
    zamCoinBonus: 60,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Spin Wheel Segments  (Wave 2)
// ─────────────────────────────────────────────────────────────────────────────

// Wheel segments — 8 entries in display order (index 0 = top after spin)
const List<Map<String, dynamic>> kWheelSegments = [
  {'label': 'ZMW 10', 'type': 'coins', 'value': 10},
  {'label': 'ZMW 25', 'type': 'coins', 'value': 25},
  {'label': '50 XP', 'type': 'xp', 'value': 50},
  {'label': '100 XP', 'type': 'xp', 'value': 100},
  {'label': 'Hint Token', 'type': 'powerup', 'value': kPowerUpHintToken},
  {'label': 'Shield', 'type': 'powerup', 'value': kPowerUpShield},
  {'label': 'Double XP', 'type': 'powerup', 'value': kPowerUpDoubleXp},
  {'label': '+1 Shield', 'type': 'streak_shield', 'value': 1},
];

// ─────────────────────────────────────────────────────────────────────────────
// Shop Catalogue  (Wave 2)
// ─────────────────────────────────────────────────────────────────────────────

// Shop item catalogue
class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price; // ZMW coins
  final String emoji;
  final bool isPowerUp; // false = cosmetic

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.emoji,
    required this.isPowerUp,
  });
}

const List<ShopItem> kShopPowerUps = [
  ShopItem(id: kPowerUpHintToken, name: 'Hint Token', description: 'Reveals one correct answer', price: 15, emoji: '💡', isPowerUp: true),
  ShopItem(id: kPowerUpShield, name: 'Shield', description: 'Protects hearts for one session', price: 25, emoji: '🛡', isPowerUp: true),
  ShopItem(id: kPowerUpFreeze, name: 'Freeze', description: 'Pauses timer for 10 seconds', price: 20, emoji: '❄️', isPowerUp: true),
  ShopItem(id: kPowerUpXpMultiplier, name: 'XP Multiplier 1.5x', description: 'Next simulation gives 1.5x XP', price: 30, emoji: '⚡', isPowerUp: true),
  ShopItem(id: kPowerUpDoubleXp, name: 'Double XP', description: 'Next simulation gives 2x XP', price: 40, emoji: '🔥', isPowerUp: true),
];

const List<ShopItem> kShopCosmetics = [
  ShopItem(id: 'gold_frame', name: 'Gold Frame', description: 'Gold profile badge frame', price: 60, emoji: '🥇', isPowerUp: false),
  ShopItem(id: 'copper_frame', name: 'Copper Frame', description: 'Copper profile badge frame', price: 60, emoji: '🥉', isPowerUp: false),
  ShopItem(id: 'emerald_frame', name: 'Emerald Frame', description: 'Emerald profile badge frame', price: 60, emoji: '💚', isPowerUp: false),
  ShopItem(id: 'flame_blue', name: 'Blue Flame', description: 'Blue flame streak icon', price: 35, emoji: '🔵', isPowerUp: false),
  ShopItem(id: 'flame_purple', name: 'Purple Flame', description: 'Purple flame streak icon', price: 35, emoji: '🟣', isPowerUp: false),
  ShopItem(id: 'flame_rainbow', name: 'Rainbow Flame', description: 'Rainbow flame streak icon', price: 35, emoji: '🌈', isPowerUp: false),
];

// ─────────────────────────────────────────────────────────────────────────────
// Mystery Box Loot Table  (Wave 4)
// ─────────────────────────────────────────────────────────────────────────────

// Mystery box loot tiers
const kMysteryLootCommon = 'common';
const kMysteryLootRare   = 'rare';
const kMysteryLootEpic   = 'epic';

// Weighted loot table: list of (tier, weight) pairs summing to 100
const kMysteryLootWeights = [
  (kMysteryLootCommon, 60),
  (kMysteryLootRare,   30),
  (kMysteryLootEpic,   10),
];

// Common rewards
const kMysteryCommonRewards = ['coins_10', 'coins_20', 'coins_30', 'xp_50'];
// Rare rewards
const kMysteryRareRewards = ['hint_token', 'shield', 'freeze'];
// Epic rewards
const kMysteryEpicRewards = ['double_xp', 'xp_multiplier', 'cosmetic_gold_frame'];

// Story path badge IDs
const kBadgeStorySaver        = 'story_saver';
const kBadgeStoryInvestor     = 'story_investor';
const kBadgeStoryEntrepreneur = 'story_entrepreneur';

// ─────────────────────────────────────────────────────────────────────────────
// Boss level constants  (Wave 5)
// ─────────────────────────────────────────────────────────────────────────────

const int kBossMaxHp = 10;
const int kBossQuestionCount = 10;

class BossConfig {
  final int levelId;
  final String name;
  final String description;
  final String badgeId;
  final int xpReward;
  final int coinsReward;

  const BossConfig({
    required this.levelId,
    required this.name,
    required this.description,
    required this.badgeId,
    required this.xpReward,
    required this.coinsReward,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge IDs — boss  (Wave 5)
// ─────────────────────────────────────────────────────────────────────────────

const kBadgeBoss1 = 'boss_1_defeated';
const kBadgeBoss2 = 'boss_2_defeated';
const kBadgeBoss3 = 'boss_3_defeated';
const kBadgeBoss4 = 'boss_4_defeated';

const kBossConfigs = [
  BossConfig(
    levelId: 1,
    name: 'Chipata the Debt Collector',
    description: 'Grey suit, stern expression. Demands payment.',
    badgeId: kBadgeBoss1,
    xpReward: 500,
    coinsReward: 100,
  ),
  BossConfig(
    levelId: 2,
    name: 'Mulenga the Loan Shark',
    description: 'Sharp suit, coin bag prop. Offers dangerous deals.',
    badgeId: kBadgeBoss2,
    xpReward: 600,
    coinsReward: 100,
  ),
  BossConfig(
    levelId: 3,
    name: 'Kabwe the Gambler',
    description: 'Flashy jacket, dice prop. Tests your risk tolerance.',
    badgeId: kBadgeBoss3,
    xpReward: 800,
    coinsReward: 100,
  ),
  BossConfig(
    levelId: 4,
    name: 'Mutale the Tax Evader',
    description: 'Briefcase overflowing with papers. Hides the truth.',
    badgeId: kBadgeBoss4,
    xpReward: 1000,
    coinsReward: 100,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Season constants  (Wave 5)
// ─────────────────────────────────────────────────────────────────────────────

const kSeasonThemes = [
  'Savings Season',
  'Investment Season',
  'Budget Season',
  'Entrepreneur Season',
  'Tax Season',
  'Insurance Season',
  'Retirement Season',
  'Credit Season',
];

const kSeasonEmojis = ['💰', '📈', '📊', '🏢', '🧾', '🛡', '🏖', '💳'];

// Zambian holiday dates — (month, day) → name
const kZambiaHolidays = <(int, int), String>{
  (10, 24): 'Zambia Independence Day',
  (8, 12): 'Youth Day',
  (5, 1): 'Labour Day',
  (1, 1): 'New Year',
};

// ─────────────────────────────────────────────────────────────────────────────
// Badge IDs — season  (Wave 5)
// ─────────────────────────────────────────────────────────────────────────────

const kBadgeSeasonGold   = 'season_gold';
const kBadgeSeasonSilver = 'season_silver';
const kBadgeSeasonBronze = 'season_bronze';

// ─────────────────────────────────────────────────────────────────────────────
// Badge ID — co-op  (Wave 5)
// ─────────────────────────────────────────────────────────────────────────────

const kBadgeCoopTeacher = 'coop_teacher';
