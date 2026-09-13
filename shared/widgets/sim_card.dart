/// sim_card.dart
/// Purpose: Reusable simulation card widget used in the Level screen to
///          represent a single simulation — shows its name, description,
///          completion state, and an action button.
/// Reads from: nothing (pure presentational widget)
/// Writes to: nothing (onTap callback delegates to caller)
/// Navigation: none (caller handles opening the simulation bottom sheet)
library;

import 'package:flutter/material.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Simulation Metadata
// ─────────────────────────────────────────────────────────────────────────────

/// Static display metadata for every simulation ID.
/// [SimCardMeta] is used only by [SimCard] — it is never persisted.
class SimCardMeta {
  const SimCardMeta({
    required this.title,
    required this.description,
    required this.emoji,
    required this.xpLabel,
  });

  final String title;
  final String description;
  final String emoji;

  /// Short label shown on the XP chip (e.g. "+50 XP").
  final String xpLabel;
}

/// Maps every simulation ID (defined in constants.dart) to its display metadata.
const Map<String, SimCardMeta> kSimMeta = {
  // Level 1
  kSimBudget: SimCardMeta(
    title: 'Budget Allocator',
    description:
        'Drag sliders to allocate ZMW 3,500 across rent, food, transport, savings & leisure.',
    emoji: '📊',
    xpLabel: '+40 XP',
  ),
  kSimEmergencyFund: SimCardMeta(
    title: 'Emergency Fund Builder',
    description:
        'Calculate how many months of expenses you need and how long to save them.',
    emoji: '🛡️',
    xpLabel: '+40 XP',
  ),
  kSimMobileMoneyFee: SimCardMeta(
    title: 'Mobile Money Fee Calculator',
    description:
        'See how MTN MoMo & Airtel Money fees accumulate and learn to minimise them.',
    emoji: '📱',
    xpLabel: '+40 XP',
  ),

  // Level 2
  kSimDebt: SimCardMeta(
    title: 'Debt & Credit Manager',
    description:
        'Explore loan interest accrual and compare minimum vs. aggressive repayment.',
    emoji: '⚔️',
    xpLabel: '+80 XP',
  ),
  kSimSavingsGoal: SimCardMeta(
    title: 'Savings Goal Tracker',
    description:
        'Set a savings target and watch compound interest accelerate your progress.',
    emoji: '📈',
    xpLabel: '+80 XP',
  ),
  kSimInflation: SimCardMeta(
    title: 'Inflation Impact Simulator',
    description:
        'Watch ZMW purchasing power erode at 12% annual inflation over 5 years.',
    emoji: '📉',
    xpLabel: '+80 XP',
  ),

  // Level 3
  kSimInvestment: SimCardMeta(
    title: 'Risk & Reward Simulator',
    description:
        'Compare stocks vs. property vs. agro investments over a configurable timeline.',
    emoji: '🏦',
    xpLabel: '+120 XP',
  ),
  kSimCompoundGrowth: SimCardMeta(
    title: 'Compound Growth Chart',
    description:
        'See ZMW 1,000 grow at three different interest rates over 10 years.',
    emoji: '🔢',
    xpLabel: '+120 XP',
  ),
  kSimPortfolio: SimCardMeta(
    title: 'Portfolio Allocator',
    description:
        'Drag sliders to allocate your portfolio and see your blended return & risk score.',
    emoji: '🥧',
    xpLabel: '+120 XP',
  ),

  // Level 4
  kSimPacra: SimCardMeta(
    title: 'PACRA Registration',
    description:
        'Step through every official PACRA stage to register a Zambian business.',
    emoji: '🏛️',
    xpLabel: '+200 XP',
  ),
  kSimRevenue: SimCardMeta(
    title: 'Revenue vs. Profit Calculator',
    description:
        'Build a P&L statement and see the difference between gross and net profit.',
    emoji: '💹',
    xpLabel: '+200 XP',
  ),
  kSimPayroll: SimCardMeta(
    title: 'Payroll Simulator',
    description:
        'Calculate PAYE and NAPSA deductions for a Zambian employee payslip.',
    emoji: '👥',
    xpLabel: '+200 XP',
  ),
  kSimTax: SimCardMeta(
    title: 'Tax Fundamentals Quiz',
    description:
        'Test your knowledge of ZRA tax rates, VAT, PAYE, and corporate tax.',
    emoji: '📋',
    xpLabel: '+200 XP',
  ),

  // Quiz Challenge (Level 1)
  kSimQuizChallenge: SimCardMeta(
    title: 'Quiz Challenge',
    description:
        'Test your Zambia financial literacy — NAPSA, VAT, mobile money, savings & more.',
    emoji: '🎯',
    xpLabel: '+40 XP',
  ),
};

// ─────────────────────────────────────────────────────────────────────────────
// SimCard Widget
// ─────────────────────────────────────────────────────────────────────────────

/// [SimCard] is the tappable card used in the Level screen to represent
/// a single simulation exercise.
///
/// Example usage:
/// ```dart
/// SimCard(
///   simulationId: kSimBudget,
///   isCompleted: false,
///   onTap: () => _openSimulation(context, kSimBudget),
/// )
/// ```
class SimCard extends StatelessWidget {
  const SimCard({
    super.key,
    required this.simulationId,
    required this.isCompleted,
    required this.onTap,
  });

  /// The simulation ID — must be one of the `kSim*` constants.
  final String simulationId;

  /// True if the player has already completed this simulation.
  final bool isCompleted;

  /// Called when the player taps the card or its action button.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Resolve display metadata; fall back to a generic card if unknown ID.
    final meta = kSimMeta[simulationId] ??
        SimCardMeta(
          title: simulationId.replaceAll('_', ' '),
          description: 'Interactive financial simulation.',
          emoji: '⚙️',
          xpLabel: '+XP',
        );

    final borderColor = isCompleted ? kGreen : kCopperLight.withValues(alpha: 0.35);
    final bgColor = isCompleted ? kGreen.withValues(alpha: 0.04) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isCompleted ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: kCopper.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Emoji Circle ─────────────────────────────────────────
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isCompleted
                    ? kGreen.withValues(alpha: 0.12)
                    : kCopper.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  isCompleted ? '✅' : meta.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ── Content ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + XP chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          meta.title,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: isCompleted ? kGreen : kCharcoal,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _xpChip(context, meta.xpLabel, isCompleted),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    meta.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kCharcoalLight,
                          height: 1.4,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Action button
                  _actionButton(context, isCompleted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── XP Chip ───────────────────────────────────────────────────────────────

  Widget _xpChip(BuildContext context, String label, bool done) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: done ? kGreen.withValues(alpha: 0.12) : kGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: done ? kGreen.withValues(alpha: 0.4) : kGold.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        done ? '✓ Done' : label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: done ? kGreen : kCharcoal,
        ),
      ),
    );
  }

  // ── Action Button ─────────────────────────────────────────────────────────

  Widget _actionButton(BuildContext context, bool done) {
    return SizedBox(
      height: 34,
      child: done
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.replay, size: 14),
              label: const Text('Replay', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: kGreen,
                side: const BorderSide(color: kGreen),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.play_arrow, size: 14),
              label: const Text('Start', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kCopper,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
    );
  }
}
