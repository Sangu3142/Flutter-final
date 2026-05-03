/// level_screen.dart
/// Purpose: Level detail screen — shows the neighbourhood header, business
///          showcase, and a list of simulation cards. Routes to each
///          simulation widget when a card is tapped.
/// Reads from: levelProvider, singleLevelProvider, authProvider
/// Writes to: levelProvider (marks simulations complete via callbacks)
/// Navigation: ← back (level map), shows simulation widgets as bottom sheets
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/levels/models/level_model.dart';
import 'package:zamwealth_quest/features/levels/providers/level_provider.dart';
import 'package:zamwealth_quest/features/levels/simulations/budget_simulation.dart';
import 'package:zamwealth_quest/features/levels/simulations/savings_simulation.dart';
import 'package:zamwealth_quest/features/levels/simulations/investment_simulation.dart';
import 'package:zamwealth_quest/features/levels/simulations/debt_simulation.dart';
import 'package:zamwealth_quest/features/levels/simulations/business_simulation.dart';
import 'package:zamwealth_quest/shared/widgets/sim_card.dart';
import 'package:zamwealth_quest/shared/widgets/xp_bar.dart';

/// [LevelScreen] is the full-screen view for a single game level.
class LevelScreen extends ConsumerWidget {
  const LevelScreen({super.key, required this.levelId});

  final int levelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(singleLevelProvider(levelId));
    final meta = kLevelMeta[levelId];

    if (meta == null || model == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Compute level progress for the XP mini-bar at the top
    final totalSims = meta.simulations.length;
    final doneSims = model.completedSimulations.length;
    final simProgress = totalSims > 0 ? doneSims / totalSims : 0.0;

    return Scaffold(
      backgroundColor: kCream,
      body: CustomScrollView(
        slivers: [
          // ── Collapsible Header ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: kCopper,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                meta.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(gradient: kZamGradient),
                child: Stack(
                  children: [
                    // Background emoji
                    Positioned(
                      right: 20,
                      bottom: 40,
                      child: Text(
                        meta.emoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                    // Status badge
                    Positioned(
                      top: 60,
                      left: 20,
                      child: _statusBadge(context, model),
                    ),
                    // Subtitle
                    Positioned(
                      bottom: 60,
                      left: 20,
                      right: 100,
                      child: Text(
                        meta.subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Progress Bar ─────────────────────────────────
                  _buildProgressCard(
                      context, model, simProgress, doneSims, totalSims, meta),

                  const SizedBox(height: 20),

                  // ── Businesses ────────────────────────────────────
                  _buildBusinesses(context, meta),

                  const SizedBox(height: 20),

                  // ── Simulations List ──────────────────────────────
                  Text(
                    'Simulations',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete all simulations to earn ${meta.xpReward} XP',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kCharcoalLight,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Simulation cards
                  ...meta.simulations.map((simId) {
                    final isDone = model.hasCompletedSim(simId);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SimCard(
                        simulationId: simId,
                        isCompleted: isDone,
                        onTap: () => _openSimulation(
                          context,
                          ref,
                          simId,
                          levelId,
                          isDone,
                        ),
                      ),
                    );
                  }),

                  // ── Completion Banner ─────────────────────────────
                  if (model.isCompleted) _buildCompletionBanner(context, meta),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Badge ─────────────────────────────────────────────────────────

  Widget _statusBadge(BuildContext context, LevelModel model) {
    final (label, color) = switch (model.status) {
      kStatusCompleted => ('✅ Completed', kGreen),
      kStatusInProgress => ('⚙️ In Progress', kCopper),
      _ => ('🔓 Unlocked', kGreenLight),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Progress Card ─────────────────────────────────────────────────────────

  Widget _buildProgressCard(
    BuildContext context,
    LevelModel model,
    double progress,
    int done,
    int total,
    LevelMeta meta,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: zamCard(highlighted: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level Progress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '$done / $total simulations',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kCopper,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          XpBar(
            progress: progress,
            currentXp: done,
            maxXp: total,
            activeColor: kGreen,
          ),
          const SizedBox(height: 8),
          Text(
            model.isCompleted
                ? '🏆 ${meta.xpReward} XP earned!'
                : '${meta.xpReward} XP on completion',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: model.isCompleted ? kGreen : kCharcoalLight,
                  fontWeight:
                      model.isCompleted ? FontWeight.w700 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }

  // ── Business Showcase ─────────────────────────────────────────────────────

  Widget _buildBusinesses(BuildContext context, LevelMeta meta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Businesses',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: meta.businesses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final biz = meta.businesses[i];
              return Container(
                width: 140,
                padding: const EdgeInsets.all(10),
                decoration: zamCard(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      meta.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      biz,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: kCharcoal,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Completion Banner ─────────────────────────────────────────────────────

  Widget _buildCompletionBanner(BuildContext context, LevelMeta meta) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kGreen, kGreenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level Complete!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'You earned ${meta.xpReward} XP and a badge!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Open Simulation ───────────────────────────────────────────────────────

  /// Opens the appropriate simulation widget as a full-screen bottom sheet.
  void _openSimulation(
    BuildContext context,
    WidgetRef ref,
    String simId,
    int levelId,
    bool isAlreadyDone,
  ) {
    final widget = _buildSimulationWidget(
      simId: simId,
      levelId: levelId,
      onComplete: () async {
        // Mark the simulation as complete in the level state machine
        await ref
            .read(levelProvider.notifier)
            .markSimulationComplete(levelId, simId, context: context);
        if (context.mounted) Navigator.of(context).pop();
      },
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: kCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => widget,
    );
  }

  /// Maps a [simId] to the correct simulation widget.
  Widget _buildSimulationWidget({
    required String simId,
    required int levelId,
    required VoidCallback onComplete,
  }) {
    return switch (simId) {
      kSimBudget => BudgetSimulation(onComplete: onComplete),
      kSimEmergencyFund => SavingsSimulation(
          mode: SavingsMode.emergencyFund,
          onComplete: onComplete,
        ),
      kSimMobileMoneyFee => SavingsSimulation(
          mode: SavingsMode.mobileMoneyFee,
          onComplete: onComplete,
        ),
      kSimDebt => DebtSimulation(onComplete: onComplete),
      kSimSavingsGoal => SavingsSimulation(
          mode: SavingsMode.savingsGoal,
          onComplete: onComplete,
        ),
      kSimInflation => SavingsSimulation(
          mode: SavingsMode.inflation,
          onComplete: onComplete,
        ),
      kSimInvestment => InvestmentSimulation(
          mode: InvestmentMode.riskReward,
          onComplete: onComplete,
        ),
      kSimCompoundGrowth => InvestmentSimulation(
          mode: InvestmentMode.compoundGrowth,
          onComplete: onComplete,
        ),
      kSimPortfolio => InvestmentSimulation(
          mode: InvestmentMode.portfolio,
          onComplete: onComplete,
        ),
      kSimPacra => BusinessSimulation(
          mode: BusinessMode.pacra,
          onComplete: onComplete,
        ),
      kSimRevenue => BusinessSimulation(
          mode: BusinessMode.revenue,
          onComplete: onComplete,
        ),
      kSimPayroll => BusinessSimulation(
          mode: BusinessMode.payroll,
          onComplete: onComplete,
        ),
      kSimTax => BusinessSimulation(
          mode: BusinessMode.taxQuiz,
          onComplete: onComplete,
        ),
      _ => _FallbackSim(simId: simId, onComplete: onComplete),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fallback Simulation (safety net for unknown IDs)
// ─────────────────────────────────────────────────────────────────────────────

class _FallbackSim extends StatelessWidget {
  const _FallbackSim({required this.simId, required this.onComplete});
  final String simId;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚙️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('Simulation: $simId',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onComplete,
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }
}
