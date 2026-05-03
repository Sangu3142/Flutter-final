/// badge_model.dart
/// Purpose: Defines AppBadge data class and the canonical badge catalogue.
/// All badge IDs are stable — they are persisted in Hive via earnedBadges.
library;

enum BadgeTier { bronze, silver, gold, platinum }

class AppBadge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final BadgeTier tier;
  final String unlockedBy;

  const AppBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.tier,
    required this.unlockedBy,
  });
}

/// The canonical badge catalogue. Never modify IDs — they are stored in Hive.
const List<AppBadge> kAllBadges = [

  // ── ONBOARDING ──────────────────────────────────────────────
  AppBadge(
    id: 'first_login',
    title: 'First Step',
    description: 'You created your ZamWealth Quest account and took the first step toward financial freedom.',
    emoji: '👣',
    tier: BadgeTier.bronze,
    unlockedBy: 'Create your account',
  ),
  AppBadge(
    id: 'onboarding_complete',
    title: 'Orientation Graduate',
    description: 'Completed the onboarding journey and set your financial goals.',
    emoji: '🎓',
    tier: BadgeTier.bronze,
    unlockedBy: 'Complete onboarding',
  ),

  // ── BUDGET ──────────────────────────────────────────────────
  AppBadge(
    id: 'budget_done',
    title: 'Budget Boss',
    description: 'Built your first monthly household budget. Every kwacha counts.',
    emoji: '📊',
    tier: BadgeTier.bronze,
    unlockedBy: 'Complete the Budget Planner simulation',
  ),

  // ── SAVINGS ──────────────────────────────────────────────────
  AppBadge(
    id: 'savings_emergency',
    title: 'Rainy Day Ready',
    description: 'Ran the Emergency Fund simulation. Three months of expenses — sorted.',
    emoji: '☂️',
    tier: BadgeTier.bronze,
    unlockedBy: 'Complete the Emergency Fund mode',
  ),
  AppBadge(
    id: 'savings_all_modes',
    title: 'Savings Champion',
    description: 'Mastered all four savings modes: Emergency Fund, School Fees, House Deposit, and Wedding.',
    emoji: '🏆',
    tier: BadgeTier.gold,
    unlockedBy: 'Complete all four savings simulation modes',
  ),

  // ── DEBT ────────────────────────────────────────────────────
  AppBadge(
    id: 'debt_done',
    title: 'Debt Slayer',
    description: 'Ran the Debt Avalanche simulation and started fighting back against interest.',
    emoji: '⚔️',
    tier: BadgeTier.silver,
    unlockedBy: 'Complete the Debt Avalanche simulation',
  ),

  // ── INVESTMENT ───────────────────────────────────────────────
  AppBadge(
    id: 'investment_lusaka_se',
    title: 'Lusaka SE Rookie',
    description: 'Your first trade on the Lusaka Securities Exchange simulation. Welcome to the markets.',
    emoji: '📈',
    tier: BadgeTier.bronze,
    unlockedBy: 'Complete the LuSE Stock simulation',
  ),
  AppBadge(
    id: 'investment_all_modes',
    title: 'Portfolio Pro',
    description: 'Simulated stocks, Treasury Bills, and Pension — a complete investment portfolio.',
    emoji: '💼',
    tier: BadgeTier.gold,
    unlockedBy: 'Complete all three investment simulation modes',
  ),

  // ── BUSINESS ─────────────────────────────────────────────────
  AppBadge(
    id: 'pacra_done',
    title: 'PACRA Graduate',
    description: 'Completed all six steps of the PACRA business registration simulation.',
    emoji: '📋',
    tier: BadgeTier.silver,
    unlockedBy: 'Complete the PACRA registration simulation',
  ),
  AppBadge(
    id: 'tax_wizard',
    title: 'Tax Wizard',
    description: 'Aced the ZRA tax quiz. You know your VAT from your PAYE.',
    emoji: '🧙',
    tier: BadgeTier.gold,
    unlockedBy: 'Score 100% on the ZRA Tax Quiz',
  ),
  AppBadge(
    id: 'payroll_done',
    title: 'Payroll Master',
    description: 'Ran the NAPSA & PAYE payroll simulation. Your employees thank you.',
    emoji: '💰',
    tier: BadgeTier.silver,
    unlockedBy: 'Complete the Payroll simulation',
  ),
  AppBadge(
    id: 'business_all_modes',
    title: 'Entrepreneur Elite',
    description: 'Completed PACRA registration, revenue forecast, payroll, and tax quiz. A true Zambian entrepreneur.',
    emoji: '🦁',
    tier: BadgeTier.platinum,
    unlockedBy: 'Complete all four business simulation modes',
  ),

  // ── LEVEL MILESTONES ─────────────────────────────────────────
  AppBadge(
    id: 'level_1_done',
    title: 'Kabulonga Starter',
    description: 'Completed all simulations in Level 1 — Kabulonga Gardens. Foundation laid.',
    emoji: '🌱',
    tier: BadgeTier.bronze,
    unlockedBy: 'Complete Level 1',
  ),
  AppBadge(
    id: 'level_2_done',
    title: 'Woodlands Climber',
    description: 'Conquered Level 2 — Woodlands Heights. You\'re building momentum.',
    emoji: '🌳',
    tier: BadgeTier.silver,
    unlockedBy: 'Complete Level 2',
  ),
  AppBadge(
    id: 'level_3_done',
    title: 'Rhodes Park Rising',
    description: 'Mastered Level 3 — Rhodes Park. Real money skills, real results.',
    emoji: '🏙️',
    tier: BadgeTier.gold,
    unlockedBy: 'Complete Level 3',
  ),
  AppBadge(
    id: 'level_4_done',
    title: 'Platinum Ridge Legend',
    description: 'Conquered all four levels of ZamWealth Quest. You are a financial legend.',
    emoji: '💎',
    tier: BadgeTier.platinum,
    unlockedBy: 'Complete Level 4',
  ),

  // ── XP MILESTONES ────────────────────────────────────────────
  AppBadge(
    id: 'xp_500',
    title: 'First Kwacha',
    description: 'Earned 500 XP. The journey of a thousand kwacha begins with a single sim.',
    emoji: '🪙',
    tier: BadgeTier.bronze,
    unlockedBy: 'Earn 500 XP',
  ),
  AppBadge(
    id: 'xp_2000',
    title: 'ZamCoiner',
    description: 'Hit 2,000 XP. You\'re spending more time learning than most spend scrolling.',
    emoji: '💵',
    tier: BadgeTier.silver,
    unlockedBy: 'Earn 2,000 XP',
  ),
  AppBadge(
    id: 'xp_5000',
    title: 'Platinum Grind',
    description: 'Achieved 5,000 XP. Dedication at its finest — Zambia needs more of you.',
    emoji: '⭐',
    tier: BadgeTier.platinum,
    unlockedBy: 'Earn 5,000 XP',
  ),

  // ── DAILY CHALLENGE STREAK ───────────────────────────────────
  AppBadge(
    id: 'streak_3',
    title: '3-Day Flame',
    description: 'Answered the daily challenge 3 days in a row. Consistency is wealth.',
    emoji: '🔥',
    tier: BadgeTier.bronze,
    unlockedBy: 'Maintain a 3-day daily challenge streak',
  ),
  AppBadge(
    id: 'streak_7',
    title: 'Week Warrior',
    description: 'Seven days straight of daily challenges. Your financial knowledge is compounding.',
    emoji: '🗓️',
    tier: BadgeTier.silver,
    unlockedBy: 'Maintain a 7-day daily challenge streak',
  ),
  AppBadge(
    id: 'streak_30',
    title: 'Streak Lord',
    description: 'Thirty consecutive days. You don\'t just learn finance — you live it.',
    emoji: '👑',
    tier: BadgeTier.platinum,
    unlockedBy: 'Maintain a 30-day daily challenge streak',
  ),
];

// Lookup by ID — O(n) is fine for 21 badges
AppBadge? badgeById(String id) {
  try {
    return kAllBadges.firstWhere((b) => b.id == id);
  } catch (_) {
    return null;
  }
}
