/// savings_screen.dart
/// Purpose: Savings Goal Tracker — create goals, deposit weekly, earn interest.
/// Palette: green (#2BC48A) + mint (#57CC99)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/savings/models/savings_record.dart';
import 'package:zamwealth_quest/features/wallet/providers/wallet_provider.dart';
import 'package:zamwealth_quest/features/savings/providers/savings_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────

const _kGreen = Color(0xFF2BC48A);
const _kMint = Color(0xFF57CC99);
const _kDark = Color(0xFF060F0A);
const _kCard = Color(0xFF0D1F14);
const _kText = Color(0xFFE0FFF0);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class SavingsScreen extends ConsumerStatefulWidget {
  const SavingsScreen({super.key});

  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {
  @override
  Widget build(BuildContext context) {
    final savingsState = ref.watch(savingsProvider);
    final wallet = ref.watch(walletProvider);
    final record = savingsState.record;

    return Scaffold(
      backgroundColor: _kDark,
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: _kText,
        title: const Text('Savings Goals',
            style: TextStyle(
                color: _kText, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context, record),
        backgroundColor: _kGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
      body: record == null
          ? const Center(child: CircularProgressIndicator(color: _kGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(record),
                  const SizedBox(height: 20),
                  _buildGoalsList(context, record, wallet),
                  if (record.recentEvents.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildEventsCard(record),
                  ],
                  const SizedBox(height: 16),
                  _buildEducationCard(),
                ],
              ),
            ),
    );
  }

  // ── Summary card ──────────────────────────────────────────────────────────

  Widget _buildSummaryCard(SavingsRecord record) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kGreen, _kMint],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Saved',
                    style: TextStyle(color: Colors.black54, fontSize: 12)),
                Text('${record.totalSavedZamCoins} ZC',
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${record.goals.length} / $kMaxSavingsGoals goals active',
                    style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          Column(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 32)),
              Text('${record.completedGoals} done',
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Goals list ────────────────────────────────────────────────────────────

  Widget _buildGoalsList(
      BuildContext context, SavingsRecord record, int wallet) {
    final goals = record.goals;
    if (goals.isEmpty) {
      return Container(
        decoration: BoxDecoration(
            color: _kCard, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('No goals yet',
                  style: TextStyle(
                      color: _kText.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 6),
              Text('Tap "New Goal" to start saving!',
                  style: TextStyle(
                      color: _kText.withValues(alpha: 0.45), fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Goals',
            style: TextStyle(
                color: _kGreen, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        ...goals.map((g) => _buildGoalCard(context, g, wallet)),
      ],
    );
  }

  Widget _buildGoalCard(
      BuildContext context, SavingsGoalModel goal, int wallet) {
    final isComplete = goal.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete
              ? _kGreen.withValues(alpha: 0.6)
              : Colors.white12,
          width: isComplete ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(isComplete ? '🏆' : '🎯',
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(goal.goalName,
                      style: TextStyle(
                          color: isComplete ? _kGreen : _kText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
                if (!isComplete)
                  GestureDetector(
                    onTap: () => _confirmDelete(context, goal.goalId),
                    child: Icon(Icons.close,
                        color: _kText.withValues(alpha: 0.3), size: 18),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Fill bar
            Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(6)),
                ),
                FractionallySizedBox(
                  widthFactor: goal.progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: isComplete
                              ? [_kGreen, _kMint]
                              : [_kGreen.withValues(alpha: 0.7), _kMint.withValues(alpha: 0.7)]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.savedZamCoins} / ${goal.targetZamCoins} ZC  (${(goal.progress * 100).round()}%)',
                  style: TextStyle(
                      color: _kText.withValues(alpha: 0.6), fontSize: 12),
                ),
                if (!isComplete)
                  Text(
                    '${goal.remaining} ZC to go',
                    style: TextStyle(
                        color: _kMint.withValues(alpha: 0.8), fontSize: 11),
                  ),
              ],
            ),
            if (!isComplete) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weekly deposit: ${goal.weeklyDepositZamCoins} ZC',
                          style: TextStyle(
                              color: _kText.withValues(alpha: 0.5),
                              fontSize: 11)),
                      Text('Interest: 8% pa applied weekly',
                          style: TextStyle(
                              color: _kText.withValues(alpha: 0.4),
                              fontSize: 10)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: goal.canDeposit &&
                            wallet >= goal.weeklyDepositZamCoins
                        ? () => _deposit(context, goal.goalId)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      minimumSize: const Size(80, 32),
                    ),
                    child: Text(
                      goal.canDeposit ? 'Deposit' : 'Next week',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            if (isComplete)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Goal achieved! 🎉',
                    style: TextStyle(
                        color: _kGreen, fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _deposit(BuildContext context, String goalId) async {
    final ok = await ref.read(savingsProvider.notifier).deposit(goalId);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough ZamCoins or deposit not due yet!')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, String goalId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kCard,
        title: const Text('Delete Goal?',
            style: TextStyle(color: _kText, fontSize: 16)),
        content: const Text('This will remove the goal and any saved amount.',
            style: TextStyle(color: Colors.white54, fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep', style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(savingsProvider.notifier).deleteGoal(goalId);
    }
  }

  // ── Add goal dialog ───────────────────────────────────────────────────────

  void _showAddGoalDialog(BuildContext context, SavingsRecord? record) {
    if ((record?.goals.length ?? 0) >= kMaxSavingsGoals) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Maximum $kMaxSavingsGoals goals reached.')),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final weeklyCtrl = TextEditingController();

    // showModalBottomSheet with isScrollControlled + viewInsets padding
    // prevents the 51 px overflow that occurred when the keyboard appeared
    // over the old AlertDialog.
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text('New Savings Goal',
                      style: TextStyle(
                          color: _kGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _field(nameCtrl, 'Goal name (e.g. Emergency Fund)'),
                  const SizedBox(height: 10),
                  _field(targetCtrl, 'Target (ZamCoins)', isNumber: true),
                  const SizedBox(height: 10),
                  _field(weeklyCtrl, 'Weekly deposit (ZamCoins)',
                      isNumber: true),
                  const SizedBox(height: 6),
                  Text('8% pa interest applied weekly automatically.',
                      style: TextStyle(
                          color: _kText.withValues(alpha: 0.4),
                          fontSize: 11)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: _kText.withValues(alpha: 0.5))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            final name = nameCtrl.text.trim();
                            final target =
                                int.tryParse(targetCtrl.text.trim()) ?? 0;
                            final weekly =
                                int.tryParse(weeklyCtrl.text.trim()) ?? 0;
                            Navigator.pop(ctx);
                            if (name.isEmpty || target <= 0 || weekly <= 0) {
                              return;
                            }
                            await ref
                                .read(savingsProvider.notifier)
                                .createGoal(
                                  goalName: name,
                                  targetZamCoins: target,
                                  weeklyDepositZamCoins: weekly,
                                );
                          },
                          child: const Text('Create'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _field(TextEditingController ctrl, String hint,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: _kText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _kText.withValues(alpha: 0.4)),
        filled: true,
        fillColor: _kDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ── Events ────────────────────────────────────────────────────────────────

  Widget _buildEventsCard(SavingsRecord record) {
    return Container(
      decoration:
          BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity',
              style: TextStyle(
                  color: _kGreen, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ...record.recentEvents.take(6).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(e,
                    style: TextStyle(
                        color: _kText.withValues(alpha: 0.7), fontSize: 12)),
              )),
        ],
      ),
    );
  }

  // ── Education card ────────────────────────────────────────────────────────

  Widget _buildEducationCard() {
    return Container(
      decoration: BoxDecoration(
        color: _kGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: _kGreen.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: _kMint, size: 18),
              SizedBox(width: 6),
              Text('Saving Wisdom',
                  style: TextStyle(
                      color: _kMint, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          _tip('Compound interest (8% pa) rewards consistent savers — even small amounts grow over time.'),
          _tip('Set a weekly deposit you can afford. Consistency beats amount.'),
          _tip('Emergency fund goal: save 3–6 months of monthly expenses.'),
          _tip('Completing a goal earns +100 XP and 20 bonus ZamCoins!'),
        ],
      ),
    );
  }

  Widget _tip(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ',
                style: TextStyle(
                    color: _kMint.withValues(alpha: 0.7), fontSize: 13)),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: _kText.withValues(alpha: 0.65), fontSize: 12)),
            ),
          ],
        ),
      );
}
