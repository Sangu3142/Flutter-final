/// stats_screen.dart
/// Purpose: Player progress statistics — visualises XP per level, simulations
///          completed, daily challenge stats, and total simulated savings.
/// Reads from: currentUserProvider, levelProvider, dailyChallengeProvider
/// Writes to: nothing (read-only)
/// Navigation: ← back button (AppBar)
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/daily_challenge/providers/daily_challenge_provider.dart';
import 'package:zamwealth_quest/features/levels/providers/level_provider.dart';

/// [StatsScreen] visualises the player's overall progress across levels,
/// simulations, daily challenges, and savings.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final levelState = ref.watch(levelProvider);
    final record = ref.watch(dailyChallengeProvider).record;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalSims =
        kLevelMeta.values.fold<int>(0, (sum, m) => sum + m.simulations.length);
    final doneSims = kLevelMeta.keys.fold<int>(
      0,
      (sum, id) =>
          sum + (levelState.levels[id]?.completedSimulations.length ?? 0),
    );

    final challengeStreak = record?.currentStreak ?? 0;
    final challengeTotal = record?.totalCompleted ?? 0;
    final challengeShields = record?.streakShields ?? 0;
    final challengeBonusXp = record?.bonusXpEarned ?? 0;

    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(title: const Text('My Progress')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section 1: Summary Cards ───────────────────────────────
              _summaryRow(
                context,
                xp: user.xp,
                zamCoins: user.zamCoins,
                badgeCount: user.earnedBadges.length,
              ),
              const SizedBox(height: 24),

              // ── Section 2: XP per Level ────────────────────────────────
              Text('XP per Level',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              _xpBarChart(context, levelState),
              const SizedBox(height: 24),

              // ── Section 3: Simulations Completed per Level ─────────────
              Text('Simulations Completed',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '$doneSims / $totalSims simulations complete',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: kCharcoalLight),
              ),
              const SizedBox(height: 10),
              _simsBarChart(context, levelState),
              const SizedBox(height: 24),

              // ── Section 4: Daily Challenge Stats ───────────────────────
              Text('Daily Challenge',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              _dailyChallengeCard(
                context,
                streak: challengeStreak,
                total: challengeTotal,
                shields: challengeShields,
                bonusXp: challengeBonusXp,
              ),
              const SizedBox(height: 24),

              // ── Section 5: Simulated Savings ───────────────────────────
              Text('Simulated Savings',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              _savingsCard(context, user.totalSavingsZMW),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section 1: Summary Cards ─────────────────────────────────────────────

  Widget _summaryRow(
    BuildContext context, {
    required int xp,
    required int zamCoins,
    required int badgeCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _statCard(context,
              icon: '🌟', label: 'Total XP', value: '$xp', color: kCopper),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(context,
              icon: '🪙', label: 'ZamCoins', value: '$zamCoins', color: kGold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(context,
              icon: '🏅',
              label: 'Badges',
              value: '$badgeCount / 10',
              color: kGold),
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: zamCard(),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: kCharcoalLight),
          ),
        ],
      ),
    );
  }

  // ── Section 2: XP per Level ──────────────────────────────────────────────

  Widget _xpBarChart(BuildContext context, LevelState levelState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: zamCard(),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            maxY: 1100.0,
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 200,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}',
                    style: const TextStyle(fontSize: 9, color: kCharcoalLight),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    const labels = ['Lvl 1', 'Lvl 2', 'Lvl 3', 'Lvl 4'];
                    final i = v.toInt();
                    if (i < 0 || i >= labels.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(labels[i],
                          style: const TextStyle(
                              fontSize: 9, color: kCharcoalLight)),
                    );
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: List.generate(4, (i) {
              final model = levelState.levels[i + 1];
              final xp = (model?.xpEarned ?? 0).toDouble();
              final isCompleted = model?.isCompleted ?? false;
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: xp,
                    color: isCompleted
                        ? kCopper
                        : kCharcoalLight.withValues(alpha: 0.5),
                    width: 28,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── Section 3: Simulations Completed per Level ───────────────────────────

  Widget _simsBarChart(BuildContext context, LevelState levelState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: zamCard(),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            maxY: 5.0,
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}',
                    style: const TextStyle(fontSize: 9, color: kCharcoalLight),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    const labels = ['Lvl 1', 'Lvl 2', 'Lvl 3', 'Lvl 4'];
                    final i = v.toInt();
                    if (i < 0 || i >= labels.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(labels[i],
                          style: const TextStyle(
                              fontSize: 9, color: kCharcoalLight)),
                    );
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: List.generate(4, (i) {
              final levelId = i + 1;
              final meta = kLevelMeta[levelId]!;
              final total = meta.simulations.length.toDouble();
              final completed =
                  (levelState.levels[levelId]?.completedSimulations.length ?? 0)
                      .toDouble()
                      .clamp(0.0, total);
              final remaining = total - completed;
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: total,
                    color: Colors.transparent,
                    width: 28,
                    borderRadius: BorderRadius.circular(4),
                    rodStackItems: [
                      if (completed > 0)
                        BarChartRodStackItem(0, completed, kGreen),
                      if (remaining > 0)
                        BarChartRodStackItem(
                          completed,
                          total,
                          kCharcoalLight.withValues(alpha: 0.35),
                        ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── Section 4: Daily Challenge Stats ────────────────────────────────────

  Widget _dailyChallengeCard(
    BuildContext context, {
    required int streak,
    required int total,
    required int shields,
    required int bonusXp,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: zamCard(),
      child: Column(
        children: [
          _statRow(context, '🔥 Current streak', '$streak days'),
          _statRow(context, '📅 Total completed', '$total challenges'),
          _statRow(context, '🛡️ Streak shields', '$shields / 3'),
          _statRow(context, '⚡ Bonus XP earned', '+$bonusXp XP',
              valueColor: kCopper),
        ],
      ),
    );
  }

  Widget _statRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: kCharcoalLight)),
          Text(value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: valueColor ?? kCharcoal,
                    fontWeight: FontWeight.w600,
                  )),
        ],
      ),
    );
  }

  // ── Section 5: Simulated Savings ─────────────────────────────────────────

  Widget _savingsCard(BuildContext context, double totalSavingsZMW) {
    final fmt = NumberFormat('#,##0.00');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: zamCard(highlighted: true),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💰', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ZMW ${fmt.format(totalSavingsZMW)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: kGreen,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Simulated savings across all levels',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: kCharcoalLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
