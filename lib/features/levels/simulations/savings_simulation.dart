/// savings_simulation.dart
/// Purpose: Multi-mode savings simulation widget supporting three modes:
///   • emergencyFund — Emergency Fund Builder (Level 1)
///   • mobileMoneyFee — Mobile Money Fee Calculator (Level 1)
///   • savingsGoal — Savings Goal Tracker with compound interest chart (Level 2)
///   • inflation — Inflation Impact Simulator, ZMW purchasing power (Level 2)
/// Reads from: nothing (self-contained)
/// Writes to: nothing directly (onComplete callback)
/// Navigation: closed via onComplete
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/theme.dart';

/// Which savings simulation to render.
enum SavingsMode {
  emergencyFund,
  mobileMoneyFee,
  savingsGoal,
  inflation,
}

/// [SavingsSimulation] is a multi-mode widget covering four savings-related
/// interactive exercises across Levels 1 and 2.
class SavingsSimulation extends StatefulWidget {
  const SavingsSimulation({
    super.key,
    required this.mode,
    required this.onComplete,
  });

  final SavingsMode mode;
  final VoidCallback onComplete;

  @override
  State<SavingsSimulation> createState() => _SavingsSimulationState();
}

class _SavingsSimulationState extends State<SavingsSimulation> {
  // ── Emergency Fund state ─────────────────────────────────────────────────
  double _monthlyExpenses = 2000.0;
  int _targetMonths = 3;
  double _monthlySavings = 300.0;

  // ── Mobile Money Fee state ───────────────────────────────────────────────
  double _transactionAmount = 500.0;
  String _mmProvider = 'MTN MoMo';

  // ── Savings Goal state ───────────────────────────────────────────────────
  double _goalAmount = 10000.0;
  double _monthlyContribution = 500.0;
  double _annualRate = 0.12;

  // ── Inflation state ───────────────────────────────────────────────────────
  double _inflationPurchasingPower = 1000.0;

  @override
  Widget build(BuildContext context) {
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
                    ..._buildContent(context),
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

  List<Widget> _buildContent(BuildContext context) {
    switch (widget.mode) {
      case SavingsMode.emergencyFund:
        return _emergencyFundContent(context);
      case SavingsMode.mobileMoneyFee:
        return _mobileMoneyfeeContent(context);
      case SavingsMode.savingsGoal:
        return _savingsGoalContent(context);
      case SavingsMode.inflation:
        return _inflationContent(context);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mode 1: Emergency Fund Builder
  // ─────────────────────────────────────────────────────────────────────────

  List<Widget> _emergencyFundContent(BuildContext context) {
    final target = _monthlyExpenses * _targetMonths;
    // Months to reach target at the given monthly savings rate
    final monthsToGoal =
        _monthlySavings > 0 ? (target / _monthlySavings).ceil() : 999;

    return [
      _sectionHeader(
          context,
          '🛡️ Emergency Fund Builder',
          'Calculate how long it takes to build your safety net. '
              'Financial experts recommend 3–6 months of expenses.'),
      const SizedBox(height: 16),

      // Monthly expenses slider
      _sliderTile(
        context,
        label: '💸 Monthly Expenses',
        value: _monthlyExpenses,
        min: 500,
        max: 10000,
        divisions: 190,
        display: 'ZMW ${_monthlyExpenses.toStringAsFixed(0)}',
        color: kCopper,
        onChanged: (v) => setState(() => _monthlyExpenses = v),
      ),

      // Target months radio buttons
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎯 Target months of cover',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [3, 4, 5, 6].map((m) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _targetMonths = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _targetMonths == m ? kCopper : kCopperSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kCopperLight),
                      ),
                      child: Text(
                        '$m mo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _targetMonths == m ? Colors.white : kCharcoal,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),

      // Monthly savings slider
      _sliderTile(
        context,
        label: '💰 Monthly Savings',
        value: _monthlySavings,
        min: 50,
        max: 3000,
        divisions: 59,
        display: 'ZMW ${_monthlySavings.toStringAsFixed(0)}',
        color: kGreen,
        onChanged: (v) => setState(() => _monthlySavings = v),
      ),

      const SizedBox(height: 14),

      // Result card
      _resultCard(context, children: [
        _resultRow(
            context, '🎯 Target Fund', 'ZMW ${target.toStringAsFixed(0)}'),
        _resultRow(context, '📅 Time to Goal',
            '$monthsToGoal months (${(monthsToGoal / 12).toStringAsFixed(1)} yrs)'),
        _resultRow(context, '📊 Monthly Savings',
            'ZMW ${_monthlySavings.toStringAsFixed(0)}'),
      ]),

      const SizedBox(height: 12),
      _tipCard(
          context,
          '💡 Bank of Zambia data: Zambian households face an average of ZMW 1.2K '
          'in unexpected costs per year. Your fund covers these shocks without debt.'),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mode 2: Mobile Money Fee Calculator
  // ─────────────────────────────────────────────────────────────────────────

  List<Widget> _mobileMoneyfeeContent(BuildContext context) {
    // Fee structures (approximate 2024 rates)
    double calcFee(double amount, String provider) {
      if (provider == 'MTN MoMo') {
        if (amount <= 50) return 0.7;
        if (amount <= 500) return amount * 0.01;
        if (amount <= 5000) return amount * 0.013;
        return amount * 0.015;
      } else {
        // Airtel Money (slightly lower)
        if (amount <= 50) return 0.5;
        if (amount <= 500) return amount * 0.009;
        if (amount <= 5000) return amount * 0.012;
        return amount * 0.014;
      }
    }

    final fee = calcFee(_transactionAmount, _mmProvider);
    final feePercent =
        (_transactionAmount > 0) ? (fee / _transactionAmount * 100) : 0.0;
    final netReceived = _transactionAmount - fee;

    // Annual fee if this transaction is done weekly
    final annualFee = fee * 52;

    return [
      _sectionHeader(
          context,
          '📱 Mobile Money Fee Calculator',
          'See how much MTN MoMo and Airtel Money charge per transaction '
              'and how fees accumulate over a year.'),
      const SizedBox(height: 16),

      // Provider toggle
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kCopperLight.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: ['MTN MoMo', 'Airtel Money'].map((p) {
            final isActive = _mmProvider == p;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _mmProvider = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isActive ? kCopper : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    p,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? Colors.white : kCharcoalLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),

      const SizedBox(height: 16),

      _sliderTile(
        context,
        label: '💵 Transaction Amount',
        value: _transactionAmount,
        min: 10,
        max: 10000,
        divisions: 999,
        display: 'ZMW ${_transactionAmount.toStringAsFixed(0)}',
        color: kCopper,
        onChanged: (v) => setState(() => _transactionAmount = v),
      ),

      const SizedBox(height: 14),

      _resultCard(context, children: [
        _resultRow(context, '💸 Transaction Fee',
            'ZMW ${fee.toStringAsFixed(2)} (${feePercent.toStringAsFixed(1)}%)'),
        _resultRow(
            context, '✅ Net Received', 'ZMW ${netReceived.toStringAsFixed(2)}'),
        _resultRow(context, '📅 Annual (weekly use)',
            'ZMW ${annualFee.toStringAsFixed(2)}/yr in fees'),
      ]),

      const SizedBox(height: 12),
      _tipCard(
          context,
          '💡 Batching mobile money transactions reduces fees. '
          'Instead of sending ZMW 100 four times, send ZMW 400 once — '
          'you\'ll pay ~${(calcFee(400, _mmProvider)).toStringAsFixed(2)} '
          'vs ~${(calcFee(100, _mmProvider) * 4).toStringAsFixed(2)} in fees.'),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mode 3: Savings Goal Tracker (Compound Interest Chart)
  // ─────────────────────────────────────────────────────────────────────────

  List<Widget> _savingsGoalContent(BuildContext context) {
    // Months to reach goal with compound interest
    // FV = P * ((1+r)^n - 1) / r where r = monthly rate
    final monthlyRate = _annualRate / 12;
    int monthsToGoal = 0;
    double balance = 0;
    if (_monthlyContribution > 0) {
      while (balance < _goalAmount && monthsToGoal < 360) {
        balance = balance * (1 + monthlyRate) + _monthlyContribution;
        monthsToGoal++;
      }
    }

    // Generate chart data points (every 6 months up to 120 months)
    final chartSpots = <FlSpot>[];
    double chartBalance = 0;
    for (int m = 0; m <= 120; m += 3) {
      chartSpots.add(FlSpot(m.toDouble(), chartBalance / 1000));
      if (m < 120) {
        for (int step = 0; step < 3; step++) {
          chartBalance =
              chartBalance * (1 + monthlyRate) + _monthlyContribution;
        }
      }
    }

    return [
      _sectionHeader(
          context,
          '📈 Savings Goal Tracker',
          'Set a savings target and monthly contribution. '
              'The chart shows how compound interest accelerates your progress.'),
      const SizedBox(height: 16),

      _sliderTile(
        context,
        label: '🎯 Goal Amount',
        value: _goalAmount,
        min: 1000,
        max: 100000,
        divisions: 990,
        display: 'ZMW ${_goalAmount.toStringAsFixed(0)}',
        color: kCopper,
        onChanged: (v) => setState(() => _goalAmount = v),
      ),

      _sliderTile(
        context,
        label: '💰 Monthly Contribution',
        value: _monthlyContribution,
        min: 50,
        max: 5000,
        divisions: 99,
        display: 'ZMW ${_monthlyContribution.toStringAsFixed(0)}',
        color: kGreen,
        onChanged: (v) => setState(() => _monthlyContribution = v),
      ),

      _sliderTile(
        context,
        label: '📊 Annual Interest Rate',
        value: _annualRate,
        min: 0.02,
        max: 0.30,
        divisions: 28,
        display: '${(_annualRate * 100).toStringAsFixed(0)}% p.a.',
        color: kGold,
        onChanged: (v) => setState(() => _annualRate = v),
      ),

      const SizedBox(height: 14),

      _resultCard(context, children: [
        _resultRow(
            context,
            '⏳ Months to Goal',
            monthsToGoal < 360
                ? '$monthsToGoal months (${(monthsToGoal / 12).toStringAsFixed(1)} yrs)'
                : '> 30 years — increase contribution'),
        _resultRow(context, '🎯 Goal', 'ZMW ${_goalAmount.toStringAsFixed(0)}'),
        _resultRow(
            context,
            '📈 Rate',
            '${(_annualRate * 100).toStringAsFixed(0)}% p.a. '
                '(BoZ indicative ${(kBozLendingRate * 100).toStringAsFixed(0)}%)'),
      ]),

      const SizedBox(height: 16),

      // Compound growth chart
      _chartCard(
          context, 'Compound Growth Over 10 Years (ZMW \'000)', chartSpots),

      const SizedBox(height: 12),
      _tipCard(
          context,
          '💡 "The 8th wonder of the world is compound interest." — Albert Einstein. '
          'Starting with ZMW 500/month at 12% interest grows to over ZMW 120K in 10 years.'),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mode 4: Inflation Impact Simulator
  // ─────────────────────────────────────────────────────────────────────────

  List<Widget> _inflationContent(BuildContext context) {
    // ZMW purchasing power decay at 12% inflation over 5 years
    final List<Map<String, dynamic>> yearlyData = [];
    double currentPower = _inflationPurchasingPower;
    for (int y = 0; y <= 5; y++) {
      yearlyData.add({'year': y, 'power': currentPower});
      currentPower *= (1 - kZmwInflationRate);
    }

    // Real value in today's ZMW after 5 years
    final finalPower = yearlyData.last['power'] as double;
    final percentLost = ((1 - finalPower / _inflationPurchasingPower) * 100);

    final chartSpots = yearlyData
        .map((d) => FlSpot(
              (d['year'] as int).toDouble(),
              (d['power'] as double),
            ))
        .toList();

    return [
      _sectionHeader(
          context,
          '📉 Inflation Impact Simulator',
          'See how ZMW ${_inflationPurchasingPower.toStringAsFixed(0)} in purchasing power '
              'erodes at Zambia\'s ${(kZmwInflationRate * 100).toStringAsFixed(0)}% annual inflation rate.'),
      const SizedBox(height: 16),

      _sliderTile(
        context,
        label: '💵 Initial Amount (ZMW)',
        value: _inflationPurchasingPower,
        min: 100,
        max: 50000,
        divisions: 499,
        display: 'ZMW ${_inflationPurchasingPower.toStringAsFixed(0)}',
        color: kCopper,
        onChanged: (v) => setState(() => _inflationPurchasingPower = v),
      ),

      const SizedBox(height: 14),

      _resultCard(context, children: [
        _resultRow(context, '📅 Today',
            'ZMW ${_inflationPurchasingPower.toStringAsFixed(0)}'),
        _resultRow(context, '⏩ In 5 Years (real value)',
            'ZMW ${finalPower.toStringAsFixed(0)}'),
        _resultRow(context, '📉 Purchasing Power Lost',
            '${percentLost.toStringAsFixed(1)}%'),
        _resultRow(context, '📊 Inflation Rate',
            '${(kZmwInflationRate * 100).toStringAsFixed(0)}% p.a. (BoZ 2024 estimate)'),
      ]),

      const SizedBox(height: 16),

      // Line chart
      Container(
        height: 200,
        padding: const EdgeInsets.all(14),
        decoration: zamCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Purchasing Power Over 5 Years (ZMW)',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: kCharcoalLight,
                  ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData:
                      const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (v, _) => Text(
                          'ZMW${(v / 1000).toStringAsFixed(0)}K',
                          style: const TextStyle(
                              fontSize: 9, color: kCharcoalLight),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) => Text(
                          'Yr ${v.toInt()}',
                          style: const TextStyle(
                              fontSize: 9, color: kCharcoalLight),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartSpots,
                      isCurved: true,
                      color: kCopper,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: kCopper.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 12),
      _tipCard(
          context,
          '💡 To beat ${(kZmwInflationRate * 100).toStringAsFixed(0)}% inflation, '
          'invest in assets that grow faster: Zambia Stock Exchange (ZSE) averaged '
          '~18% p.a. over the last decade. Idle cash in a pillow loses real value.'),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared UI Helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _sectionHeader(BuildContext context, String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(sub,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kCharcoalLight,
                  height: 1.4,
                )),
      ],
    );
  }

  Widget _sliderTile(
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
              Text(
                display,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
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

  Widget _resultCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: zamCard(highlighted: true),
      child: Column(children: children),
    );
  }

  Widget _resultRow(BuildContext context, String label, String value) {
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
                    color: kCopper,
                    fontWeight: FontWeight.w700,
                  )),
        ],
      ),
    );
  }

  Widget _chartCard(BuildContext context, String title, List<FlSpot> spots) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(14),
      decoration: zamCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: kCharcoalLight)),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toStringAsFixed(0)}K',
                        style:
                            const TextStyle(fontSize: 9, color: kCharcoalLight),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}m',
                        style:
                            const TextStyle(fontSize: 9, color: kCharcoalLight),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: kGreen,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: kGreen.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipCard(BuildContext context, String tip) {
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
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kCharcoal,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
