/// profile_screen.dart
/// Purpose: Profile tab — displays user stats, earned badges, payment history,
///          and a version label with a 7-tap easter egg to the dev screen.
/// Reads from: authProvider, paymentHistoryProvider, devTapProvider
/// Writes to: authProvider (logout)
/// Navigation: → /profile/dev (7-tap easter egg), → /login (logout)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/daily_challenge/providers/daily_challenge_provider.dart';
import 'package:zamwealth_quest/features/profile/providers/profile_provider.dart';
import 'package:zamwealth_quest/features/badges/providers/badge_provider.dart';
import 'package:zamwealth_quest/shared/widgets/xp_bar.dart';
import 'package:zamwealth_quest/shared/widgets/zamcoin_badge.dart';

/// [ProfileScreen] is the profile tab of the main bottom navigation shell.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final payments = ref.watch(paymentHistoryProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: kCream,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: kCopper,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(user.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              background: Container(
                decoration: const BoxDecoration(gradient: kZamGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '@${user.username}',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: kGold.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '⚔️ ${xpRankLabel(user.xp)}',
                                  style: const TextStyle(
                                      color: kGold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ZamCoinBadge(coins: user.zamCoins),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => _confirmLogout(context, ref),
              ),
            ],
          ),

          // ── Body ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── XP Progress ────────────────────────────────────
                  _xpCard(context, user.xp),
                  const SizedBox(height: 16),

                  // ── Daily Challenge Stats ──────────────────────────
                  _dailyChallengeStats(context, ref),
                  const SizedBox(height: 16),

                  // ── Profile Details ────────────────────────────────
                  _detailsCard(context, user),
                  const SizedBox(height: 16),

                  // ── My Progress Stats ──────────────────────────────
                  _statsNavCard(context),
                  const SizedBox(height: 20),

                  // ── Payment History ────────────────────────────────
                  _paymentHistorySection(context, payments),
                  const SizedBox(height: 20),

                  // ── My Badges (above dev easter egg) ───────────────
                  _myBadgesCard(context, ref),
                  const SizedBox(height: 24),

                  // ── Version label (7-tap dev screen easter egg) ────
                  _versionLabel(context, ref),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── XP Card ───────────────────────────────────────────────────────────────

  Widget _xpCard(BuildContext context, int xp) {
    final rankStart = xpCurrentRankStart(xp);
    final remaining = xpToNextRank(xp);
    final tierSize = remaining > 0
        ? (xp - rankStart + remaining)
        : (xp - xpCurrentRankStart(xp - 1));
    final progress =
        tierSize > 0 ? ((xp - rankStart) / tierSize).clamp(0.0, 1.0) : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: zamCard(highlighted: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total XP', style: Theme.of(context).textTheme.titleMedium),
              Text('$xp XP',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: kCopper, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          XpBar(
            progress: progress,
            currentXp: xp - rankStart,
            maxXp: tierSize,
          ),
          const SizedBox(height: 6),
          Text(
            remaining > 0
                ? '$remaining XP to next rank'
                : '🏆 Maximum rank achieved!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: remaining > 0 ? kCharcoalLight : kGold,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  // ── Daily Challenge Stats ─────────────────────────────────────────────────

  Widget _dailyChallengeStats(BuildContext context, WidgetRef ref) {
    final dc = ref.watch(dailyChallengeProvider);
    final record = dc.record;

    final streak = record?.currentStreak ?? 0;
    final shields = record?.streakShields ?? 0;
    final total = record?.totalCompleted ?? 0;
    final bonusXp = record?.bonusXpEarned ?? 0;

    Widget statCell(String emoji, String label, String value) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: zamCard(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: kCopper,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: kCharcoalLight, fontSize: 10),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daily Challenge Stats',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: [
            statCell('🔥', 'Current Streak', '$streak days'),
            statCell('🛡️', 'Streak Shields', '$shields left'),
            statCell('✅', 'Total Completed', '$total'),
            statCell('⚡', 'Bonus XP Earned', '+$bonusXp XP'),
          ],
        ),
      ],
    );
  }

  // ── Details Card ──────────────────────────────────────────────────────────

  Widget _detailsCard(BuildContext context, user) {
    final incomeLabels = {
      'student': '🎓 Student',
      'informal_trader': '🛒 Informal Trader',
      'civil_servant': '🏛️ Civil Servant',
      'entrepreneur': '💼 Entrepreneur',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: zamCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile Details',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _detailRow(context, '👤 Username', '@${user.username}'),
          _detailRow(context, '💼 Income Type',
              incomeLabels[user.incomeCategory] ?? user.incomeCategory),
          _detailRow(
              context, '⚖️ Risk Appetite', user.riskAppetite.toUpperCase()),
          _detailRow(context, '🔥 Streak', '${user.streak} days'),
          _detailRow(
              context, '🎯 Goals', '${user.financialGoals.length} selected'),
          _detailRow(context, '💰 Simulated Savings',
              'ZMW ${user.totalSavingsZMW.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
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
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: kCharcoal, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── My Badges Nav Card ────────────────────────────────────────────────────

  Widget _myBadgesCard(BuildContext context, WidgetRef ref) {
    final badgeMap = ref.watch(badgeMapProvider);
    final earnedCount = badgeMap.values.where((v) => v).length;
    final totalCount = badgeMap.length;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.badges),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: zamCard(),
        child: Row(
          children: [
            const Text('🏅', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'My Badges',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGold.withValues(alpha: 0.5)),
              ),
              child: Text(
                '$earnedCount / $totalCount',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kCharcoal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: kCharcoalLight),
          ],
        ),
      ),
    );
  }

  // ── Stats Nav Card ────────────────────────────────────────────────────────

  Widget _statsNavCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.stats),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: zamCard(),
        child: Row(
          children: [
            const Text('📊', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'My Progress Stats',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const Icon(Icons.chevron_right, color: kCharcoalLight),
          ],
        ),
      ),
    );
  }

  // ── Payment History ───────────────────────────────────────────────────────

  Widget _paymentHistorySection(BuildContext context, List payments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment History', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        if (payments.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: zamCard(),
            child: Text(
              'No payments yet. Unlock a level to see records here.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: kCharcoalLight),
            ),
          )
        else
          ...payments.take(5).map((p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: zamCard(),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kCopper.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.payment, color: kCopper, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.tier,
                            style: Theme.of(context).textTheme.labelMedium),
                        Text(
                          '${p.provider} · ${p.timestamp.day}/${p.timestamp.month}/${p.timestamp.year}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: kCharcoalLight),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ZMW ${p.amountZMW.toStringAsFixed(0)}',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                                color: kCopper, fontWeight: FontWeight.w700),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: kWarning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SANDBOX',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                  color: kWarning,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ── Version Label (7-tap easter egg) ─────────────────────────────────────

  Widget _versionLabel(BuildContext context, WidgetRef ref) {
    final tapCount = ref.watch(devTapProvider);
    final remaining = kDevScreenTapCount - tapCount;

    return Center(
      child: GestureDetector(
        onTap: () {
          final shouldOpen = ref.read(devTapProvider.notifier).tap();
          if (shouldOpen) {
            context.push(AppRoutes.dev);
          } else if (tapCount > 0) {
            // Show hint after 3+ taps
            if (tapCount >= 3) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('🔧 $remaining more taps to open Developer Screen'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          }
        },
        child: Column(
          children: [
            Text(
              'v1.0.0+1',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kCharcoalLight,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              'ZamWealth Quest © 2024',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kCharcoalLight,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Logout Confirmation ───────────────────────────────────────────────────

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text(
            'Your progress is saved locally. You can sign back in anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final router = GoRouter.of(context);
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) router.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: kError),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
