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
    simulations: [kSimBudget, kSimEmergencyFund, kSimMobileMoneyFee],
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
