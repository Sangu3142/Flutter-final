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
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/shared/widgets/animated_gradient_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette constants
// ─────────────────────────────────────────────────────────────────────────────

const Color _kDeepNavy = Color(0xFF0D1B2A);
const Color _kCoreNavy = Color(0xFF00203F);
const Color _kPrimaryBlue = Color(0xFF1A73E8);
const Color _kNeonMint = Color(0xFF36ECDE);
const Color _kGold = Color(0xFFFFB703);
const Color _kSoftGray = Color(0xFFE6E9EC);

// ─────────────────────────────────────────────────────────────────────────────
// LeaderboardScreen
// ─────────────────────────────────────────────────────────────────────────────

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final entries =
        _buildEntries(user?.uid ?? '', user?.xp ?? 0, user?.name ?? 'You');

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              _buildHeader(context),

              // ── Top 3 Podium ─────────────────────────────────────────
              if (entries.length >= 3) _buildPodium(context, entries),

              const SizedBox(height: 8),

              // ── Full List ──────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final e = entries[index];
                    return _buildEntryTile(
                      context,
                      e,
                      index + 1,
                      isCurrentUser: e['isCurrentUser'] as bool,
                    );
                  },
                ),
              ),

              // ── Disclaimer ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '📴 Local leaderboard only — other players are simulated placeholders.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _kSoftGray.withValues(alpha: 0.45),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: _kDeepNavy.withValues(alpha: 0.80),
        border: Border(
          bottom:
              BorderSide(color: _kNeonMint.withValues(alpha: 0.20), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.leaderboard, color: _kNeonMint, size: 22),
          const SizedBox(width: 10),
          Text(
            'LEADERBOARD',
            style: GoogleFonts.rajdhani(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _kSoftGray,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build Sorted Entries ──────────────────────────────────────────────────

  List<Map<String, dynamic>> _buildEntries(
      String uid, int userXp, String userName) {
    try {
      final box = Hive.box(kLeaderboardBox);
      final rawEntries = (box.get('entries') as List? ?? []).cast<Map>();

      final entries = <Map<String, dynamic>>[];

      for (final e in rawEntries) {
        entries.add({
          'name': e['name'] as String? ?? 'Player',
          'xp': (e['xp'] as int? ?? 0),
          'badge': e['badge'] as String? ?? 'budget_master',
          'isCurrentUser': false,
        });
      }

      entries.add({
        'name': userName,
        'xp': userXp,
        'badge': 'savings_star',
        'isCurrentUser': true,
      });

      entries.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
      return entries;
    } catch (_) {
      return [
        {
          'name': userName,
          'xp': userXp,
          'badge': 'savings_star',
          'isCurrentUser': true,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kCoreNavy, _kPrimaryBlue, _kCoreNavy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _podiumColumn(context, top3[1], 2, 80)),
          Expanded(child: _podiumColumn(context, top3[0], 1, 110)),
          Expanded(child: _podiumColumn(context, top3[2], 3, 60)),
        ],
      ),
    );
  }

  Widget _podiumColumn(
    BuildContext context,
    Map<String, dynamic> entry,
    int place,
    double height,
  ) {
    final medal = ['🥇', '🥈', '🥉'][place - 1];
    final isCurrentUser = entry['isCurrentUser'] as bool;
    final podiumColors = [
      _kGold.withValues(alpha: 0.80),
      _kSoftGray.withValues(alpha: 0.35),
      const Color(0xFFCD7F32).withValues(alpha: 0.70),
    ];

    return Column(
      children: [
        Text(medal, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          (entry['name'] as String).split(' ').first,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isCurrentUser ? _kNeonMint : Colors.white,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${entry['xp']} XP',
          style: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _kSoftGray.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: podiumColors[place - 1],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border(
              top: BorderSide(
                color: isCurrentUser
                    ? _kNeonMint.withValues(alpha: 0.60)
                    : Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
          ),
          child: Center(
            child: Text(
              '#$place',
              style: GoogleFonts.orbitron(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Colors.white,
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
        color: isCurrentUser
            ? _kNeonMint.withValues(alpha: 0.08)
            : _kDeepNavy.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? _kNeonMint.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.07),
          width: isCurrentUser ? 1.5 : 1,
        ),
        boxShadow: [
          if (isCurrentUser)
            BoxShadow(
              color: _kNeonMint.withValues(alpha: 0.12),
              blurRadius: 10,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 34,
            child: Text(
              '#$rank',
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: rank <= 3 ? _kGold : _kSoftGray.withValues(alpha: 0.50),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(width: 10),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: isCurrentUser
                ? _kNeonMint.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.08),
            child: Text(
              (entry['name'] as String)[0].toUpperCase(),
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isCurrentUser ? _kNeonMint : _kSoftGray,
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
                      style: GoogleFonts.rajdhani(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isCurrentUser ? _kNeonMint : _kSoftGray,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kNeonMint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'YOU',
                          style: GoogleFonts.rajdhani(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: _kCoreNavy,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  rankLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _kSoftGray.withValues(alpha: 0.55),
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
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isCurrentUser
                      ? _kNeonMint
                      : _kSoftGray.withValues(alpha: 0.70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
