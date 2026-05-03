/// debt_simulation.dart
/// Purpose: Level 2 Debt & Credit Manager simulation — shows loan interest
///          accrual, an amortization schedule, and compares repayment
///          strategies (minimum payment vs. aggressive payoff).
/// Reads from: nothing (self-contained)
/// Writes to: nothing directly (onComplete callback)
/// Navigation: closed via onComplete
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zamwealth_quest/core/theme.dart';

/// [DebtSimulation] teaches debt management and interest accrual using
/// configurable loan parameters grounded in Zambian lending rates.
class DebtSimulation extends StatefulWidget {
  const DebtSimulation({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<DebtSimulation> createState() => _DebtSimulationState();
}

class _DebtSimulationState extends State<DebtSimulation> {
  double _loanAmount = 5000.0;
  double _annualRate = 0.28; // ~28% — typical Zambian personal loan rate
  int _termMonths = 12;

  // ── Calculations ──────────────────────────────────────────────────────────

  double get _monthlyRate => _annualRate / 12;

  /// Monthly EMI using the standard annuity formula.
  double get _emi {
    final r = _monthlyRate;
    final n = _termMonths;
    if (r == 0) return _loanAmount / n;
    return _loanAmount * (r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
  }

  double get _totalRepayment => _emi * _termMonths;
  double get _totalInterest => _totalRepayment - _loanAmount;

  /// Generates the full amortization schedule.
  List<Map<String, double>> _amortizationSchedule() {
    final rows = <Map<String, double>>[];
    double balance = _loanAmount;
    for (int m = 1; m <= _termMonths; m++) {
      final interestCharge = balance * _monthlyRate;
      final principal = _emi - interestCharge;
      balance -= principal;
      rows.add({
        'month': m.toDouble(),
        'payment': _emi,
        'interest': interestCharge,
        'principal': principal,
        'balance': balance < 0 ? 0 : balance,
      });
    }
    return rows;
  }

  /// Aggressive payoff: pay double minimum — how many months to clear?
  int _aggressivePayoffMonths() {
    double balance = _loanAmount;
    int months = 0;
    final doubleEmi = _emi * 1.8;
    while (balance > 0 && months < _termMonths * 2) {
      final interest = balance * _monthlyRate;
      balance -= (doubleEmi - interest);
      months++;
    }
    return months;
  }

  double _aggressiveInterestSaved() {
    final aggressiveMonths = _aggressivePayoffMonths();
    double balance = _loanAmount;
    double totalInt = 0;
    final doubleEmi = _emi * 1.8;
    for (int i = 0; i < aggressiveMonths; i++) {
      final interest = balance * _monthlyRate;
      totalInt += interest;
      balance -= (doubleEmi - interest);
    }
    return _totalInterest - totalInt;
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _amortizationSchedule();
    final aggressiveMonths = _aggressivePayoffMonths();
    final interestSaved = _aggressiveInterestSaved();

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: kCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _handle(),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  children: [
                    // Header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('⚔️ Debt & Credit Manager',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 6),
                        Text(
                          'Configure a loan and see exactly how much interest you pay. '
                          'Learn how paying more now saves thousands later.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: kCharcoalLight, height: 1.4),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Sliders
                    _sliderCard(
                      context,
                      label: '💰 Loan Amount',
                      value: _loanAmount,
                      min: 500,
                      max: 50000,
                      divisions: 99,
                      display: 'ZMW ${_loanAmount.toStringAsFixed(0)}',
                      color: kCopper,
                      onChanged: (v) => setState(() => _loanAmount = v),
                    ),

                    _sliderCard(
                      context,
                      label: '📊 Annual Interest Rate',
                      value: _annualRate,
                      min: 0.05,
                      max: 0.60,
                      divisions: 55,
                      display:
                          '${(_annualRate * 100).toStringAsFixed(0)}% p.a.',
                      color: kError,
                      onChanged: (v) => setState(() => _annualRate = v),
                    ),

                    _sliderCard(
                      context,
                      label: '📅 Loan Term',
                      value: _termMonths.toDouble(),
                      min: 3,
                      max: 60,
                      divisions: 57,
                      display: '$_termMonths months',
                      color: kGreen,
                      onChanged: (v) => setState(() => _termMonths = v.round()),
                    ),

                    const SizedBox(height: 14),

                    // Loan Summary
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: zamCard(highlighted: true),
                      child: Column(
                        children: [
                          _row(context, '💵 Monthly EMI',
                              'ZMW ${_emi.toStringAsFixed(2)}',
                              valueColor: kCopper),
                          _row(context, '📊 Total Repayment',
                              'ZMW ${_totalRepayment.toStringAsFixed(2)}'),
                          _row(context, '🔥 Total Interest Paid',
                              'ZMW ${_totalInterest.toStringAsFixed(2)}',
                              valueColor: kError),
                          _row(context, '📈 Interest %',
                              '${(_totalInterest / _loanAmount * 100).toStringAsFixed(1)}% of principal'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Aggressive vs. Minimum Repayment
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kGreen.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kGreen.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🚀 What if you paid 1.8x the minimum?',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: kGreen),
                          ),
                          const SizedBox(height: 10),
                          _row(context, '⏩ Paid off in',
                              '$aggressiveMonths months instead of $_termMonths',
                              valueColor: kGreen),
                          _row(context, '💰 Interest Saved',
                              'ZMW ${interestSaved.toStringAsFixed(2)}',
                              valueColor: kGreen),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Amortization Schedule (first 6 months shown)
                    Text(
                      'Amortization Schedule (first 6 months)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: zamCard(),
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(40),
                          1: FlexColumnWidth(),
                          2: FlexColumnWidth(),
                          3: FlexColumnWidth(),
                        },
                        children: [
                          // Header row
                          TableRow(
                            decoration: BoxDecoration(
                              color: kCopper.withValues(alpha: 0.08),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                            ),
                            children: [
                              _tableHeader(context, 'Mo.'),
                              _tableHeader(context, 'Interest'),
                              _tableHeader(context, 'Principal'),
                              _tableHeader(context, 'Balance'),
                            ],
                          ),
                          // Data rows (show up to 6)
                          ...schedule.take(6).map((r) {
                            return TableRow(
                              children: [
                                _tableCell(
                                    context, r['month']!.toInt().toString()),
                                _tableCell(
                                    context, r['interest']!.toStringAsFixed(1),
                                    color: kError),
                                _tableCell(
                                    context, r['principal']!.toStringAsFixed(1),
                                    color: kGreen),
                                _tableCell(
                                    context, r['balance']!.toStringAsFixed(0)),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    _tipBox(
                        context,
                        '💡 Zambian commercial bank lending rates average 28% p.a. '
                        'Borrow only what you need, and pay off high-interest debt first '
                        '(the avalanche method).'),

                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: widget.onComplete,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Complete Simulation ✓'),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _handle() => Center(
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

  Widget _sliderCard(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String display,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: zamCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleSmall),
              Text(display,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: color,
            inactiveColor: color.withValues(alpha: 0.2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
                  color: valueColor ?? kCopper, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _tableHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(text,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: kCopper, fontWeight: FontWeight.w700)),
    );
  }

  Widget _tableCell(BuildContext context, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(text,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: color ?? kCharcoal)),
    );
  }

  Widget _tipBox(BuildContext context, String tip) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGold.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(tip,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: kCharcoal, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
