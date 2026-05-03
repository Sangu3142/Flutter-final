/// investment_simulation.dart
/// Purpose: Level 3 investment simulations in three modes:
///   • riskReward — Investment Risk & Reward Simulator (stocks vs property vs agro)
///   • compoundGrowth — Compound Growth Chart (ZMW 1000 at 3 rates over 10 years)
///   • portfolio — Portfolio Allocator across asset classes
/// Reads from: nothing (self-contained)
/// Writes to: nothing directly (onComplete callback)
/// Navigation: closed via onComplete
library;

import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/theme.dart';

/// Which investment simulation mode to render.
enum InvestmentMode { riskReward, compoundGrowth, portfolio }

/// [InvestmentSimulation] covers three Level 3 investment exercises.
class InvestmentSimulation extends StatefulWidget {
  const InvestmentSimulation({
    super.key,
    required this.mode,
    required this.onComplete,
  });

  final InvestmentMode mode;
  final VoidCallback onComplete;

  @override
  State<InvestmentSimulation> createState() => _InvestmentSimulationState();
}

class _InvestmentSimulationState extends State<InvestmentSimulation> {
  // ── Risk-Reward state ───────────────────────────────────────────────────
  double _investmentAmount = 5000.0;
  int _timelineYears = 5;
  String _selectedAsset = 'Stocks (ZSE)';

  // Asset profiles: {name: {rate, risk, minReturn, maxReturn}}
  static const _assets = {
    'Stocks (ZSE)': {
      'rate': 0.18,
      'risk': 'High',
      'emoji': '📈',
      'minReturn': 0.05,
      'maxReturn': 0.35,
      'desc': 'Zambia Stock Exchange — volatile but high long-term gains'
    },
    'Property': {
      'rate': 0.12,
      'risk': 'Medium',
      'emoji': '🏠',
      'minReturn': 0.06,
      'maxReturn': 0.20,
      'desc': 'Lusaka residential property — stable, illiquid'
    },
    'Agro Ventures': {
      'rate': 0.15,
      'risk': 'Medium-High',
      'emoji': '🌾',
      'minReturn': 0.02,
      'maxReturn': 0.30,
      'desc': 'Kafue agro-investments — seasonal variability'
    },
  };

  // ── Portfolio state ──────────────────────────────────────────────────────
  double _pStocks = 40.0;
  double _pProperty = 30.0;
  double _pAgro = 20.0;
  double _pCash = 10.0;

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
      case InvestmentMode.riskReward:
        return _riskRewardContent(context);
      case InvestmentMode.compoundGrowth:
        return _compoundGrowthContent(context);
      case InvestmentMode.portfolio:
        return _portfolioContent(context);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mode 1: Risk & Reward Simulator
  // ─────────────────────────────────────────────────────────────────────────

  List<Widget> _riskRewardContent(BuildContext context) {
    final asset = _assets[_selectedAsset]!;
    final rate = asset['rate'] as double;
    final minR = asset['minReturn'] as double;
    final maxR = asset['maxReturn'] as double;

    // Compound growth calculations
    double compound(double r) => _investmentAmount * pow(1 + r, _timelineYears);

    final expected = compound(rate);
    final bestCase = compound(maxR);
    final worstCase = compound(minR);

    // Chart: year-by-year for all 3 assets
    final spotsPerAsset = _assets.entries.map((e) {
      final r = e.value['rate'] as double;
      return MapEntry(
        e.key,
        List.generate(
          _timelineYears + 1,
          (y) => FlSpot(
            y.toDouble(),
            _investmentAmount * pow(1 + r, y) / 1000,
          ),
        ),
      );
    }).toList();

    return [
      _header(
          context,
          '📊 Risk & Reward Simulator',
          'Compare stocks, property, and agro investments over time. '
              'Higher returns come with higher risk.'),
      const SizedBox(height: 16),

      // Asset selector
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Asset Class',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ..._assets.entries.map((e) {
            final isSelected = _selectedAsset == e.key;
            return GestureDetector(
              onTap: () => setState(() => _selectedAsset = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: zamCard(highlighted: isSelected),
                child: Row(
                  children: [
                    Text(e.value['emoji'] as String,
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.key,
                              style: Theme.of(context).textTheme.titleSmall),
                          Text(
                            e.value['desc'] as String,
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
                          '${((e.value['rate'] as double) * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: kCopper),
                        ),
                        Text(
                          'Risk: ${e.value['risk']}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: kCharcoalLight, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),

      _sliderTile(context,
          label: '💵 Investment Amount',
          value: _investmentAmount,
          min: 500,
          max: 50000,
          divisions: 99,
          display: 'ZMW ${_investmentAmount.toStringAsFixed(0)}',
          color: kCopper,
          onChanged: (v) => setState(() => _investmentAmount = v)),

      _sliderTile(context,
          label: '📅 Timeline',
          value: _timelineYears.toDouble(),
          min: 1,
          max: 15,
          divisions: 14,
          display: '$_timelineYears years',
          color: kGreen,
          onChanged: (v) => setState(() => _timelineYears = v.round())),

      const SizedBox(height: 14),

      _resultCard(context, children: [
        _row(context, '📈 Expected Value', 'ZMW ${expected.toStringAsFixed(0)}',
            valueColor: kGreen),
        _row(context, '🚀 Best Case (${(maxR * 100).toStringAsFixed(0)}%)',
            'ZMW ${bestCase.toStringAsFixed(0)}'),
        _row(context, '⚠️ Worst Case (${(minR * 100).toStringAsFixed(0)}%)',
            'ZMW ${worstCase.toStringAsFixed(0)}',
            valueColor: kWarning),
        _row(context, '💰 Initial Investment',
            'ZMW ${_investmentAmount.toStringAsFixed(0)}'),
        _row(context, '📊 Profit (expected)',
            'ZMW ${(expected - _investmentAmount).toStringAsFixed(0)}',
            valueColor: kGreen),
      ]),

      const SizedBox(height: 16),

      // Growth comparison chart
      _growthChart(context, spotsPerAsset),

      const SizedBox(height: 12),
      _tipBox(
          context,
          '💡 Diversification is key. Spreading ZMW 5,000 across all three '
          'assets reduces risk while maintaining growth.'),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mode 2: Compound Growth Chart
  // ─────────────────────────────────────────────────────────────────────────

  List<Widget> _compoundGrowthContent(BuildContext context) {
    const initial = 1000.0;
    const years = 10;

    // 3 interest rate scenarios from constants.dart
    final series = kCompoundRates.map((r) {
      return List.generate(years + 1,
          (y) => FlSpot(y.toDouble(), initial * pow(1 + r, y) / 1000));
    }).toList();

    final colors = [kGreenLight, kGreen, kCopper];
    final labels = kCompoundRates
        .map((r) => '${(r * 100).toStringAsFixed(0)}% p.a.')
        .toList();

    return [
      _header(
          context,
          '📈 Compound Growth Chart',
          'ZMW 1,000 invested today at three different rates over 10 years. '
              'This is why starting early matters.'),
      const SizedBox(height: 16),

      // Chart
      Container(
        height: 280,
        padding: const EdgeInsets.all(16),
        decoration: zamCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Growth of ZMW 1,000 (ZMW \'000)',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: kCharcoalLight)),
            const SizedBox(height: 6),
            // Legend
            Row(
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    children: [
                      Container(width: 14, height: 4, color: colors[i]),
                      const SizedBox(width: 4),
                      Text(labels[i],
                          style: const TextStyle(
                              fontSize: 10, color: kCharcoalLight)),
                    ],
                  ),
                );
              }),
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
                        reservedSize: 42,
                        getTitlesWidget: (v, _) => Text(
                          '${v.toStringAsFixed(1)}K',
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
                  lineBarsData: List.generate(
                    3,
                    (i) => LineChartBarData(
                      spots: series[i],
                      isCurved: true,
                      color: colors[i],
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: i == 2
                          ? BarAreaData(
                              show: true, color: colors[i].withValues(alpha: 0.08))
                          : BarAreaData(show: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 16),

      // Final value table
      Container(
        padding: const EdgeInsets.all(14),
        decoration: zamCard(highlighted: true),
        child: Column(
          children: List.generate(3, (i) {
            final finalVal = initial * pow(1 + kCompoundRates[i], years);
            return _row(context, '${labels[i]} → Year 10',
                'ZMW ${finalVal.toStringAsFixed(0)}',
                valueColor: colors[i]);
          }),
        ),
      ),

      const SizedBox(height: 12),
      _tipBox(
          context,
          '💡 At ${(kCompoundRates[1] * 100).toStringAsFixed(0)}% (close to BoZ rate), '
          'ZMW 1,000 becomes ZMW ${(initial * pow(1 + kCompoundRates[1], 10)).toStringAsFixed(0)} '
          'in 10 years — no extra deposits needed!'),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mode 3: Portfolio Allocator
  // ─────────────────────────────────────────────────────────────────────────

  List<Widget> _portfolioContent(BuildContext context) {
    // Weighted average expected return
    final weightedReturn =
        (_pStocks * 0.18 + _pProperty * 0.12 + _pAgro * 0.15 + _pCash * 0.05) /
            100;

    final riskScore =
        (_pStocks * 3 + _pProperty * 2 + _pAgro * 2.5 + _pCash * 1) / 100;

    String riskLabel(double r) {
      if (r < 1.5) return 'Low';
      if (r < 2.2) return 'Medium';
      return 'High';
    }

    return [
      _header(
          context,
          '🥧 Portfolio Allocator',
          'Drag sliders to allocate your investment portfolio. '
              'See your blended expected return and risk score.'),
      const SizedBox(height: 16),

      _sliderTile(context,
          label: '📈 Stocks (ZSE) — 18% expected',
          value: _pStocks,
          min: 0,
          max: 100,
          divisions: 20,
          display: '${_pStocks.toStringAsFixed(0)}%',
          color: kCopper,
          onChanged: (v) => setState(() => _pStocks = v)),

      _sliderTile(context,
          label: '🏠 Property — 12% expected',
          value: _pProperty,
          min: 0,
          max: 100,
          divisions: 20,
          display: '${_pProperty.toStringAsFixed(0)}%',
          color: kGreen,
          onChanged: (v) => setState(() => _pProperty = v)),

      _sliderTile(context,
          label: '🌾 Agro Ventures — 15% expected',
          value: _pAgro,
          min: 0,
          max: 100,
          divisions: 20,
          display: '${_pAgro.toStringAsFixed(0)}%',
          color: kGold,
          onChanged: (v) => setState(() => _pAgro = v)),

      _sliderTile(context,
          label: '💵 Cash / Savings — 5% expected',
          value: _pCash,
          min: 0,
          max: 100,
          divisions: 20,
          display: '${_pCash.toStringAsFixed(0)}%',
          color: kCharcoalLight,
          onChanged: (v) => setState(() => _pCash = v)),

      const SizedBox(height: 10),

      // Donut-like allocation display
      Container(
        padding: const EdgeInsets.all(14),
        decoration: zamCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Allocation Breakdown',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            _allocationBar(context),
            const SizedBox(height: 8),
            Row(
              children: [
                _allocationLegend(context, '📈 Stocks', _pStocks, kCopper),
                _allocationLegend(context, '🏠 Property', _pProperty, kGreen),
                _allocationLegend(context, '🌾 Agro', _pAgro, kGold),
                _allocationLegend(context, '💵 Cash', _pCash, kCharcoalLight),
              ],
            ),
          ],
        ),
      ),

      const SizedBox(height: 14),

      _resultCard(context, children: [
        _row(context, '📊 Blended Return',
            '${(weightedReturn * 100).toStringAsFixed(1)}% p.a.',
            valueColor: kGreen),
        _row(context, '⚠️ Risk Score', '${riskScore.toStringAsFixed(1)}/3.0'),
        _row(context, '🎯 Risk Level', riskLabel(riskScore)),
        _row(context, '📈 Total Allocation',
            '${(_pStocks + _pProperty + _pAgro + _pCash).toStringAsFixed(0)}%',
            valueColor: (_pStocks + _pProperty + _pAgro + _pCash) > 100
                ? kError
                : kGreen),
      ]),

      const SizedBox(height: 12),
      _tipBox(
          context,
          '💡 Modern Portfolio Theory suggests diversification reduces risk '
          'without proportionally reducing return. A mix of 60% growth + 40% stable '
          'is a common balanced strategy.'),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _header(BuildContext context, String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(sub,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: kCharcoalLight, height: 1.4)),
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
              Expanded(
                  child: Text(label,
                      style: Theme.of(context).textTheme.titleSmall)),
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

  Widget _resultCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: zamCard(highlighted: true),
      child: Column(children: children),
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
                    color: valueColor ?? kCopper,
                    fontWeight: FontWeight.w700,
                  )),
        ],
      ),
    );
  }

  Widget _growthChart(BuildContext context,
      List<MapEntry<String, List<FlSpot>>> spotsPerAsset) {
    final colors = [kCopper, kGreen, kGold];
    return Container(
      height: 220,
      padding: const EdgeInsets.all(14),
      decoration: zamCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Asset Growth Comparison (ZMW \'000)',
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
                        'Yr ${v.toInt()}',
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
                lineBarsData: List.generate(
                  spotsPerAsset.length,
                  (i) => LineChartBarData(
                    spots: spotsPerAsset[i].value,
                    isCurved: true,
                    color: colors[i],
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _allocationBar(BuildContext context) {
    final total = _pStocks + _pProperty + _pAgro + _pCash;
    if (total == 0) return const SizedBox(height: 16);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Row(
        children: [
          if (_pStocks > 0)
            Flexible(
              flex: _pStocks.round(),
              child: Container(height: 16, color: kCopper),
            ),
          if (_pProperty > 0)
            Flexible(
              flex: _pProperty.round(),
              child: Container(height: 16, color: kGreen),
            ),
          if (_pAgro > 0)
            Flexible(
              flex: _pAgro.round(),
              child: Container(height: 16, color: kGold),
            ),
          if (_pCash > 0)
            Flexible(
              flex: _pCash.round(),
              child: Container(height: 16, color: kCharcoalLight),
            ),
        ],
      ),
    );
  }

  Widget _allocationLegend(
      BuildContext context, String label, double pct, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(height: 2),
          Text(
            '${pct.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 8, color: kCharcoalLight),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
