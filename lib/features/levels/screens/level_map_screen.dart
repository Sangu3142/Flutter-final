/// level_map_screen.dart
/// Purpose: Vertical level map showing 4 nodes — one per neighbourhood.
///          LOCKED nodes open the payment screen; accessible nodes open the
///          level detail screen.
/// Reads from: levelProvider, authProvider
/// Writes to: nothing (navigation triggers state changes elsewhere)
/// Navigation: → /levels/:levelId (unlocked), → /payment/:levelId (locked)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/levels/providers/level_provider.dart';
import 'package:zamwealth_quest/features/levels/models/level_model.dart';
import 'package:zamwealth_quest/shared/widgets/level_node.dart';
import 'package:zamwealth_quest/shared/widgets/offline_banner.dart';

/// [LevelMapScreen] renders the scrollable vertical level map.
class LevelMapScreen extends ConsumerWidget {
  const LevelMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelState = ref.watch(levelProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        title: const Text('Level Map'),
        actions: [
          // ZamCoins display in app bar
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  '${user?.zamCoins ?? 0}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OfflineBanner(),

              // ── Intro Card ───────────────────────────────────────────
              _buildIntroCard(context, user?.xp ?? 0),
              const SizedBox(height: 24),

              // ── Level Nodes ──────────────────────────────────────────
              Text(
                'Your Journey',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Tap a level to enter. 🔒 = unlock required.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kCharcoalLight,
                    ),
              ),
              const SizedBox(height: 20),

              // Render 4 level nodes with connecting lines between them
              ...List.generate(4, (index) {
                final levelId = index + 1;
                final meta = kLevelMeta[levelId]!;
                final model = levelState.levels[levelId];

                return Column(
                  children: [
                    LevelNode(
                      meta: meta,
                      model: model,
                      onTap: () => _handleNodeTap(context, levelId, model),
                    ),
                    // Connecting line between nodes (not after the last one)
                    if (levelId < 4)
                      _buildConnector(
                        context,
                        fromCompleted: model?.isCompleted ?? false,
                      ),
                  ],
                );
              }),

              const SizedBox(height: 24),

              // ── Legend ───────────────────────────────────────────────
              _buildLegend(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles a tap on a level node.
  ///
  /// - Locked → navigate to payment screen
  /// - Accessible → navigate to level detail screen
  void _handleNodeTap(
    BuildContext context,
    int levelId,
    LevelModel? model,
  ) {
    if (model == null) return;

    if (model.isLocked) {
      // Route to payment screen
      context.push('/payment/$levelId');
    } else {
      // Route to level detail
      context.push('/levels/$levelId');
    }
  }

  // ── Connecting Line Between Nodes ────────────────────────────────────────

  Widget _buildConnector(BuildContext context, {required bool fromCompleted}) {
    return SizedBox(
      height: 32,
      child: Center(
        child: Container(
          width: 3,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: fromCompleted
                  ? [kGreen, kGreenLight]
                  : [
                      kCopperLight.withValues(alpha: 0.4),
                      kCopperLight.withValues(alpha: 0.2)
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  // ── Intro Card ────────────────────────────────────────────────────────────

  Widget _buildIntroCard(BuildContext context, int totalXp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: kZamGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ZamWealth Adventure Map',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Progress through 4 Zambian neighbourhoods, each packed with financial simulations.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total XP: $totalXp',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: kGold,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Legend ────────────────────────────────────────────────────────────────

  Widget _buildLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: zamCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: kCopper,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _legendItem(context, '🔓', 'Free / Unlocked', kGreen),
              const SizedBox(width: 16),
              _legendItem(context, '🔒', 'Locked (tap to unlock)', kLocked),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _legendItem(context, '⚙️', 'In Progress', kCopper),
              const SizedBox(width: 16),
              _legendItem(context, '✅', 'Completed', kGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(
      BuildContext context, String emoji, String label, Color color) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
