/// leaderboard_screen.dart
/// Purpose: Local leaderboard screen — shows the current player ranked by XP
///          alongside 9 fictional Zambian placeholder players whose XP was
///          randomly generated and stored in Hive on first launch.
/// Reads from: Hive box 'leaderboard', authProvider
/// Writes to: nothing
/// Navigation: none
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';

/// [LeaderboardScreen] presents the local XP rankings.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final entries =
        _buildEntries(user?.uid ?? '', user?.xp ?? 0, user?.name ?? 'You');

    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ── Top 3 Podium ──────────────────────────────────────────
          if (entries.length >= 3) _buildPodium(context, entries),

          const SizedBox(height: 8),

          // ── Full List ─────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final e = entries[index];
                return _buildEntryTile(context, e, index + 1,
                    isCurrentUser: e['isCurrentUser'] as bool);
              },
            ),
          ),

          // ── Disclaimer ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '📴 Local leaderboard only — other players are simulated placeholders.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kCharcoalLight,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build Sorted Entries ──────────────────────────────────────────────────

  /// Merges the current user with the Hive placeholder entries and sorts by XP.
  List<Map<String, dynamic>> _buildEntries(
      String uid, int userXp, String userName) {
    try {
      final box = Hive.box(kLeaderboardBox);
      final rawEntries = (box.get('entries') as List? ?? []).cast<Map>();

      final entries = <Map<String, dynamic>>[];

      // Add placeholder players
      for (final e in rawEntries) {
        entries.add({
          'name': e['name'] as String? ?? 'Player',
          'xp': (e['xp'] as int? ?? 0),
          'badge': e['badge'] as String? ?? 'budget_master',
          'isCurrentUser': false,
        });
      }

      // Add current user
      entries.add({
        'name': userName,
        'xp': userXp,
        'badge': 'savings_star',
        'isCurrentUser': true,
      });

      // Sort by XP descending
      entries.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));

      return entries;
    } catch (_) {
      return [
        {
          'name': userName,
          'xp': userXp,
          'badge': 'savings_star',
          'isCurrentUser': true
        }
      ];
    }
  }

  // ── Podium (top 3) ────────────────────────────────────────────────────────

  Widget _buildPodium(
      BuildContext context, List<Map<String, dynamic>> entries) {
    final top3 = entries.take(3).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: const BoxDecoration(gradient: kZamGradient),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          Expanded(child: _podiumColumn(context, top3[1], 2, 80)),
          // 1st place
          Expanded(child: _podiumColumn(context, top3[0], 1, 110)),
          // 3rd place
          Expanded(child: _podiumColumn(context, top3[2], 3, 60)),
        ],
      ),
    );
  }

  Widget _podiumColumn(BuildContext context, Map<String, dynamic> entry,
      int place, double height) {
    final medal = ['🥇', '🥈', '🥉'][place - 1];
    final isCurrentUser = entry['isCurrentUser'] as bool;

    return Column(
      children: [
        Text(medal, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          (entry['name'] as String).split(' ').first,
          style: TextStyle(
            color: isCurrentUser ? kGold : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${entry['xp']} XP',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: [kGold, Colors.grey.shade300, kCopperLight][place - 1]
                .withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '#$place',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: kCharcoal.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Entry Tile ────────────────────────────────────────────────────────────

  Widget _buildEntryTile(
    BuildContext context,
    Map<String, dynamic> entry,
    int rank, {
    required bool isCurrentUser,
  }) {
    final badgeEmojis = {
      'budget_master': '📊',
      'savings_star': '⭐',
      'debt_slayer': '⚔️',
      'investor_pro': '📈',
      'business_mogul': '🏭',
      'zamcoin_collector': '🪙',
    };

    final xp = entry['xp'] as int;
    final rankLabel = xpRankLabel(xp);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: isCurrentUser ? kCopper.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? kCopper : kCopperLight.withValues(alpha: 0.2),
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: kCopper.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: rank <= 3 ? kGold : kCharcoalLight,
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(width: 10),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: isCurrentUser ? kCopper.withValues(alpha: 0.2) : kCream,
            child: Text(
              (entry['name'] as String)[0].toUpperCase(),
              style: TextStyle(
                color: isCurrentUser ? kCopper : kCharcoalLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name and rank label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry['name'] as String,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isCurrentUser ? kCopper : kCharcoal,
                            fontWeight: isCurrentUser
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: kCopper,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  rankLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kCharcoalLight,
                      ),
                ),
              ],
            ),
          ),

          // Badge + XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                badgeEmojis[entry['badge']] ?? '🏅',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                '$xp XP',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: kCopper,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
