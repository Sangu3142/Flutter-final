/// dashboard_screen.dart
/// Purpose: Home tab of the bottom navigation shell — shows the player's
///          name, rank badge, XP bar, ZamCoins, streak, total savings, and
///          badge collection. Provides a CTA button to the Level Map.
/// Reads from: dashboardProvider, authProvider
/// Writes to: nothing (read-only)
/// Navigation: → /levels (Level Map button)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/tips.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/daily_challenge/providers/daily_challenge_provider.dart';
import 'package:zamwealth_quest/features/dashboard/providers/dashboard_provider.dart';
import 'package:zamwealth_quest/shared/widgets/offline_banner.dart';
import 'package:zamwealth_quest/shared/widgets/xp_bar.dart';

/// [DashboardScreen] is the home tab of the main shell.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(dashboardProvider);

    if (dash == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.read(authProvider.notifier).refreshUser(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Offline Banner ─────────────────────────────────────
                const OfflineBanner(),

                // ── Header ────────────────────────────────────────────
                _buildHeader(context, dash),

                const SizedBox(height: 20),

                // ── XP Progress Card ───────────────────────────────────
                _buildXpCard(context, dash),

                const SizedBox(height: 16),

                // ── Stats Row ─────────────────────────────────────────
                _buildStatsRow(context, dash),

                const SizedBox(height: 20),

                // ── Daily Challenge ────────────────────────────────────
                _buildDailyChallengeCard(context, ref),

                const SizedBox(height: 20),

                // ── Level Map CTA ──────────────────────────────────────
                _buildLevelCTA(context, dash),

                const SizedBox(height: 20),

                // ── Badges ────────────────────────────────────────────
                _buildBadgesSection(context, dash),

                const SizedBox(height: 20),

                // ── Financial Tip of the Day ───────────────────────────
                _buildTipCard(context),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, DashboardState dash) {
    return Row(
      children: [
        // Avatar circle
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            gradient: kZamGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              dash.name.isNotEmpty ? dash.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kCharcoalLight,
                    ),
              ),
              Text(
                dash.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: kCharcoal,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              // Rank badge
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: kCopper.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kCopper.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '⚔️ ${dash.rankLabel}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: kCopper,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
        // Streak indicator
        Column(
          children: [
            const Text(
              '🔥',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              '${dash.streak}d',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: kWarning,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              'streak',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: kCharcoalLight,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  // ── XP Progress Card ─────────────────────────────────────────────────────

  Widget _buildXpCard(BuildContext context, DashboardState dash) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: zamCard(highlighted: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Experience Points',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${dash.xp} XP',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: kCopper,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          XpBar(
            progress: dash.progressPercent,
            currentXp: dash.xpInCurrentRank,
            maxXp: dash.xpForNextRank,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dash.rankLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kCopper,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (dash.xpToNextRankLabel > 0)
                Text(
                  '${dash.xpToNextRankLabel} XP to next rank',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kCharcoalLight,
                      ),
                )
              else
                Text(
                  '🏆 Max Rank!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kGold,
                        fontWeight: FontWeight.w700,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context, DashboardState dash) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            context,
            icon: '🪙',
            label: 'ZamCoins',
            value: dash.zamCoins.toString(),
            color: kGold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            context,
            icon: '💰',
            label: 'Saved (sim)',
            value: dash.totalSavingsZMW >= 1000
                ? 'ZMW ${(dash.totalSavingsZMW / 1000).toStringAsFixed(1)}k'
                : 'ZMW ${dash.totalSavingsZMW.toStringAsFixed(0)}',
            color: kGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            context,
            icon: '🏅',
            label: 'Badges',
            value: dash.badgeCount.toString(),
            color: kCopper,
          ),
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
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: kCharcoalLight,
                ),
          ),
        ],
      ),
    );
  }

  // ── Level CTA ────────────────────────────────────────────────────────────

  Widget _buildLevelCTA(BuildContext context, DashboardState dash) {
    final meta = kLevelMeta[dash.currentLevel];
    return GestureDetector(
      onTap: () => context.go(AppRoutes.levels),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: kZamGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kCopper.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              meta?.emoji ?? '🗺️',
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Level ${dash.currentLevel}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                  ),
                  Text(
                    meta?.name ?? 'Start Playing',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta?.subtitle ?? 'Open the Level Map to continue',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Badges ────────────────────────────────────────────────────────────────

  Widget _buildBadgesSection(BuildContext context, DashboardState dash) {
    const badgeEmojis = {
      'budget_master': '📊',
      'savings_star': '⭐',
      'debt_slayer': '⚔️',
      'investor_pro': '📈',
      'business_mogul': '🏭',
      'zamcoin_collector': '🪙',
      'level_1_complete': '🌿',
      'level_2_complete': '🏘️',
      'level_3_complete': '📈',
      'level_4_complete': '🏭',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges Earned',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        dash.badges.isEmpty
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: zamCard(),
                child: Row(
                  children: [
                    const Text('🏅', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Text(
                      'Complete simulations to earn badges!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: kCharcoalLight,
                          ),
                    ),
                  ],
                ),
              )
            : Wrap(
                spacing: 10,
                runSpacing: 10,
                children: dash.badges.map((b) {
                  final emoji = badgeEmojis[b] ?? '🏅';
                  final label = b.replaceAll('_', ' ');
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: kGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kGold.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: kCharcoal),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  // ── Daily Challenge Card ──────────────────────────────────────────────────

  Widget _buildDailyChallengeCard(BuildContext context, WidgetRef ref) {
    final dcState = ref.watch(dailyChallengeProvider);
    final record = dcState.record;
    final challenge = dcState.todaysChallenge;
    final completedToday = record?.completedToday ?? false;
    final streak = record?.currentStreak ?? 0;
    final shields = record?.streakShields ?? 0;
    final topic = challenge?.topic ?? '…';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: zamCard(highlighted: !completedToday),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Today: $topic',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: kCharcoal,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Row(
                children: [
                  Text('🔥 $streak',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: kWarning, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 10),
                  Text('🛡️ $shields',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: kCopper, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (completedToday)
            Text(
              '✅ Challenge complete — come back tomorrow',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: kCharcoalLight),
            )
          else
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.dailyChallenge),
              style: ElevatedButton.styleFrom(
                backgroundColor: kCopper,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Take Today\'s Challenge →',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  // ── Tip of the Day ────────────────────────────────────────────────────────

  Widget _buildTipCard(BuildContext context) {
    // Pick a daily tip based on the current day of year
    final tip = kFinancialTips[DateTime.now().dayOfYear % kFinancialTips.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📰', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip of the Day',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: kGreen,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kCharcoal,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Extension to get day of year from a [DateTime].
extension _DayOfYear on DateTime {
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays;
  }
}
