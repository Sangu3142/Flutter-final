/// season_config.dart
/// Purpose: Defines the SeasonConfig model and catalogue of 8 rotating seasons,
///          plus the monthly challenge descriptions keyed by month number.
/// Reads from: nothing (pure constants)
/// Writes to: nothing (pure constants)
library;

class SeasonConfig {
  final int index;
  final String theme;
  final String emoji;
  final String description;

  const SeasonConfig({
    required this.index,
    required this.theme,
    required this.emoji,
    required this.description,
  });
}

const kSeasonConfigs = [
  SeasonConfig(
    index: 0,
    theme: 'Savings Season',
    emoji: '💰',
    description: 'Earn bonus XP for completing savings-related sims',
  ),
  SeasonConfig(
    index: 1,
    theme: 'Investment Season',
    emoji: '📈',
    description: 'Double XP on investment-focused content',
  ),
  SeasonConfig(
    index: 2,
    theme: 'Budget Season',
    emoji: '📊',
    description: 'Bonus coins for budget mastery activities',
  ),
  SeasonConfig(
    index: 3,
    theme: 'Entrepreneur Season',
    emoji: '🏢',
    description: 'Extra rewards for business sim completion',
  ),
  SeasonConfig(
    index: 4,
    theme: 'Tax Season',
    emoji: '🧾',
    description: 'Special tax knowledge challenges and rewards',
  ),
  SeasonConfig(
    index: 5,
    theme: 'Insurance Season',
    emoji: '🛡',
    description: 'Insurance and risk management content bonuses',
  ),
  SeasonConfig(
    index: 6,
    theme: 'Retirement Season',
    emoji: '🏖',
    description: 'Long-term planning focus with special content',
  ),
  SeasonConfig(
    index: 7,
    theme: 'Credit Season',
    emoji: '💳',
    description: 'Credit score and debt management mastery',
  ),
];

const kMonthlyChallenge = <int, String>{
  1: 'Complete 3 budget simulations in January',
  2: 'Earn 500 XP in February — love your finances!',
  3: 'Complete Level 1 in March',
  4: 'Achieve a 7-day login streak in April',
  5: 'Defeat a boss level in May',
  6: 'Complete 5 daily challenges in June',
  7: 'Read 5 story chapters in July',
  8: 'Play both mini-games in August',
  9: 'Spin the wheel 5 times in September',
  10: 'Earn the Independence Day badge in October',
  11: 'Complete 10 quizzes in November',
  12: 'Reach a 7-day streak and claim Day 7 bonus in December',
};
