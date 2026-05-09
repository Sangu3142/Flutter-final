/// budget_simulation.dart
/// Purpose: Level 1 Budget Allocator simulation — drag sliders to allocate
///          ZMW 3,500 monthly income across 5 categories. Warns when savings
///          drops below 10% (ZMW 350). Awards 'budget_master' badge on submit.
/// Reads from: authProvider (uid for Hive key)
/// Writes to: Hive kSettingsBox key 'budget_alloc_<uid>'
/// Navigation: → dismissed via onComplete → level_screen marks sim done
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';

/// [BudgetSimulation] teaches players how to allocate a fixed monthly income.
class BudgetSimulation extends ConsumerStatefulWidget {
  const BudgetSimulation({super.key, required this.onComplete});

  /// Called when the player taps "Submit Budget" — triggers level progression.
  final VoidCallback onComplete;

  @override
  ConsumerState<BudgetSimulation> createState() => _BudgetSimulationState();
}

class _BudgetSimulationState extends ConsumerState<BudgetSimulation> {
  double _monthlyIncome = 3500.0;

  // Allocation percentages per category (must sum ≤ 100)
  final Map<String, double> _allocations = {
    'Rent': 30.0,
    'Food': 25.0,
    'Transport': 15.0,
    'Savings': 15.0,
    'Leisure': 15.0,
  };

  final Map<String, String> _emojis = {
    'Rent': '🏠',
    'Food': '🍽️',
    'Transport': '🚌',
    'Savings': '💰',
    'Leisure': '🎉',
  };

  /// Total percentage allocated across all categories.
  double get _totalPercent => _allocations.values.fold(0, (sum, v) => sum + v);

  /// Remaining unallocated percentage.
  double get _remaining => (100 - _totalPercent).clamp(0, 100);

  /// ZMW amount for a category given its percentage allocation.
  double _zmw(String cat) => (_allocations[cat]! / 100) * _monthlyIncome;

  /// True if savings allocation is below the recommended 10%.
  bool get _savingsWarning => _allocations['Savings']! < 10;

  /// True if total allocation exceeds 100% (overspending).
  bool get _overBudget => _totalPercent > 100;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: kCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              _handle(),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  children: [
                    _header(context),
                    const SizedBox(height: 16),
                    _incomeBanner(context),
                    const SizedBox(height: 16),
                    if (_savingsWarning) _warningBanner(context),
                    if (_overBudget) _overBudgetBanner(context),
                    const SizedBox(height: 8),
                    // Sliders for each category
                    ..._allocations.keys
                        .map((cat) => _categorySlider(context, cat)),
                    const SizedBox(height: 16),
                    _remainingCard(context),
                    const SizedBox(height: 16),
                    _tipCard(context),
                    const SizedBox(height: 20),
                    _submitButton(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Handle Bar ────────────────────────────────────────────────────────────

  Widget _handle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: kCopperLight.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _header(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('📊', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Budget Allocator',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Drag the sliders to allocate your ZMW ${_monthlyIncome.toStringAsFixed(0)} monthly income across categories. '
          'Aim to save at least 10% (ZMW ${(_monthlyIncome * 0.1).toStringAsFixed(0)}).',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: kCharcoalLight,
                height: 1.4,
              ),
        ),
      ],
    );
  }

  // ── Income Banner ─────────────────────────────────────────────────────────

  Widget _incomeBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: kCopper.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCopper.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '💼 Monthly Income',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                'ZMW ${_monthlyIncome.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: kCopper,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          Slider(
            value: _monthlyIncome,
            min: 0,
            max: 20000,
            divisions: 40,
            activeColor: kCopper,
            inactiveColor: kCopper.withValues(alpha: 0.20),
            onChanged: (v) => setState(() => _monthlyIncome = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ZMW 0',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                'ZMW 20,000',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── Warning Banners ───────────────────────────────────────────────────────

  Widget _warningBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kWarning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kWarning),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: kWarning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '⚠️ Savings below 10%! Financial advisors recommend saving at least ZMW ${(_monthlyIncome * 0.1).toStringAsFixed(0)}/month.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kWarning,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overBudgetBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kError.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kError),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: kError, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '🚨 Over budget! Total allocation is ${_totalPercent.toStringAsFixed(0)}% — reduce some categories.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kError,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Slider ───────────────────────────────────────────────────────

  Widget _categorySlider(BuildContext context, String cat) {
    final emoji = _emojis[cat]!;
    final percent = _allocations[cat]!;
    final zmwAmt = _zmw(cat);

    // Highlight savings bar in green; others in copper
    final isActive = cat == 'Savings';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: zamCard(highlighted: isActive),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    cat,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ZMW ${zmwAmt.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isActive ? kGreen : kCopper,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    '${percent.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kCharcoalLight,
                        ),
                  ),
                ],
              ),
            ],
          ),
          Slider(
            value: percent,
            min: 0,
            max: 60,
            divisions: 60,
            activeColor: isActive ? kGreen : kCopper,
            inactiveColor: isActive
                ? kGreenLight.withValues(alpha: 0.25)
                : kCopperLight.withValues(alpha: 0.25),
            onChanged: (v) {
              setState(() => _allocations[cat] = v);
            },
          ),
        ],
      ),
    );
  }

  // ── Remaining Unallocated ─────────────────────────────────────────────────

  Widget _remainingCard(BuildContext context) {
    final remainingZmw = (_remaining / 100) * _monthlyIncome;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            _overBudget ? kError.withValues(alpha: 0.08) : kGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _overBudget ? kError : kGreen,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _overBudget ? '🚨 Over budget by' : '💵 Unallocated',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: _overBudget ? kError : kGreen,
                ),
          ),
          Text(
            _overBudget
                ? '-ZMW ${((_totalPercent - 100) / 100 * _monthlyIncome).toStringAsFixed(0)}'
                : 'ZMW ${remainingZmw.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _overBudget ? kError : kGreen,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  // ── Tip Card ──────────────────────────────────────────────────────────────

  Widget _tipCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 ZamWealth Tip',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: kCharcoal,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'The 50/30/20 rule: spend 50% on needs (rent, food, transport), '
            '30% on wants (leisure), and save/invest 20%. With ZMW ${_monthlyIncome.toStringAsFixed(0)}: '
            'save ZMW ${(_monthlyIncome * 0.20).toStringAsFixed(0)}, spend ZMW ${(_monthlyIncome * 0.50).toStringAsFixed(0)} on needs, ZMW ${(_monthlyIncome * 0.30).toStringAsFixed(0)} on wants.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kCharcoal,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  // ── Submit Button ─────────────────────────────────────────────────────────

  Widget _submitButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _overBudget
          ? null
          : () {
              final uid = ref.read(currentUserProvider)?.uid;
              if (uid != null) {
                final box = Hive.box(kSettingsBox);
                box.put(
                  'budget_alloc_$uid',
                  Map<String, dynamic>.from(_allocations),
                );
                box.put('budget_income_$uid', _monthlyIncome);
              }
              widget.onComplete();
            },
      icon: const Icon(Icons.check_circle_outline),
      label: Text(
        _overBudget ? 'Fix budget to submit' : 'Submit Budget ✓',
      ),
    );
  }
}
