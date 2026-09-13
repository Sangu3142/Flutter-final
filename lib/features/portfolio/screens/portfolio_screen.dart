/// portfolio_screen.dart
/// Purpose: Investment Portfolio Simulator — invest, market ticks, fl_chart.
/// Palette: gold (#FFB703) + amber (#FB8500)
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zamwealth_quest/features/loans/providers/loans_provider.dart';
import 'package:zamwealth_quest/features/wallet/providers/wallet_provider.dart';
import 'package:zamwealth_quest/features/portfolio/models/portfolio_model.dart';
import 'package:zamwealth_quest/features/portfolio/providers/portfolio_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────

const _kGold = Color(0xFFFFB703);
const _kAmber = Color(0xFFFB8500);
const _kDark = Color(0xFF1A1300);
const _kCard = Color(0xFF2A2000);
const _kText = Color(0xFFFFF8E1);

const _kAssetColors = [
  Color(0xFF4CAF50), // Shares — green
  Color(0xFF2196F3), // Bonds — blue
  Color(0xFF9C27B0), // Money Market — purple
  Color(0xFFFF5722), // Crypto — orange-red
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final portState = ref.watch(portfolioProvider);
    final loansState = ref.watch(loansProvider);
    final wallet = ref.watch(walletProvider);
    final creditScore = loansState.record?.creditScore ?? 650;

    return Scaffold(
      backgroundColor: _kDark,
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: _kText,
        title: const Text('Investment Portfolio',
            style: TextStyle(
                color: _kText, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: _kCard, borderRadius: BorderRadius.circular(20)),
            child: Text('Score: $creditScore',
                style: const TextStyle(
                    color: _kGold, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        child: portState.isLoading
            ? const Center(child: CircularProgressIndicator(color: _kGold))
            : _buildBody(context, portState.portfolio, wallet),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PortfolioModel? port, int wallet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        if (port == null) {
          return _buildEmptyView(context, wallet, isLandscape);
        }
        final sp = isLandscape ? 8.0 : 16.0;
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.paddingOf(context).bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(port),
              SizedBox(height: sp),
              if (port.totalValueZamCoins > 0) ...[
                _buildPieChart(port, isLandscape),
                SizedBox(height: sp),
              ],
              if (port.snapshotValues.length > 1) ...[
                _buildLineChart(port, isLandscape),
                SizedBox(height: sp),
              ],
              _buildAssetCards(port, wallet, isLandscape),
              SizedBox(height: sp),
              _buildEventsCard(port),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyView(BuildContext context, int wallet, bool isLandscape) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 32,
        right: 32,
        top: isLandscape ? 16 : 32,
        bottom: MediaQuery.paddingOf(context).bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📊', style: TextStyle(fontSize: isLandscape ? 40 : 64)),
          SizedBox(height: isLandscape ? 8 : 16),
          const Text('Build Your Portfolio',
              style: TextStyle(
                  color: _kGold, fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: isLandscape ? 4 : 8),
          Text('Invest ZamCoins in 4 asset classes\nand watch them grow daily.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _kText.withValues(alpha: 0.6), fontSize: 14)),
          SizedBox(height: isLandscape ? 12 : 24),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Wallet: $wallet ZamCoins',
                style: const TextStyle(color: _kAmber, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: isLandscape ? 4 : 8),
          Text('Use the asset cards below to invest.',
              style: TextStyle(color: _kText.withValues(alpha: 0.5), fontSize: 12)),
          SizedBox(height: isLandscape ? 16 : 32),
          _buildAssetCards(null, wallet, isLandscape),
        ],
      ),
    );
  }

  // ── Summary card ──────────────────────────────────────────────────────────

  Widget _buildSummaryCard(PortfolioModel port) {
    final isGain = port.returnsPercent >= 0;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kAmber, _kGold],
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
                const Text('Portfolio Value',
                    style: TextStyle(color: Colors.black54, fontSize: 12)),
                Text('${port.totalValueZamCoins} ZC',
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Invested: ${port.totalInvestedZamCoins} ZC',
                    style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                isGain ? Icons.trending_up : Icons.trending_down,
                color: isGain ? Colors.green[800] : Colors.red[800],
                size: 28,
              ),
              Text(
                '${isGain ? '+' : ''}${port.returnsPercent.toStringAsFixed(1)}%',
                style: TextStyle(
                    color: isGain ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Pie chart ─────────────────────────────────────────────────────────────

  Widget _buildPieChart(PortfolioModel port, bool isLandscape) {
    final values = port.assetValues;
    final total = port.totalValueZamCoins;
    if (total == 0) return const SizedBox.shrink();

    return Container(
      height: isLandscape ? 120 : 200,
      decoration: BoxDecoration(
          color: _kCard, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: List.generate(4, (i) {
                  final val = values[i];
                  if (val == 0) return PieChartSectionData(value: 0, radius: 0);
                  return PieChartSectionData(
                    value: val.toDouble(),
                    color: _kAssetColors[i],
                    radius: _touchedIndex == i ? 70 : 56,
                    title: '',
                    badgeWidget: _touchedIndex == i
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text('$val ZC',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          )
                        : null,
                    badgePositionPercentageOffset: 1.3,
                  );
                }),
                pieTouchData: PieTouchData(
                  touchCallback: (event, resp) {
                    setState(() {
                      _touchedIndex =
                          resp?.touchedSection?.touchedSectionIndex ?? -1;
                    });
                  },
                ),
                sectionsSpace: 3,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(4, (i) {
              if (values[i] == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: _kAssetColors[i], shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      '${PortfolioModel.assetEmojis[i]} ${PortfolioModel.assetNames[i]}',
                      style: TextStyle(
                          color: _kText.withValues(alpha: 0.8), fontSize: 11),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Line chart ────────────────────────────────────────────────────────────

  Widget _buildLineChart(PortfolioModel port, bool isLandscape) {
    final spots = port.snapshotValues
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList();

    return Container(
      height: isLandscape ? 80 : 140,
      decoration: BoxDecoration(
          color: _kCard, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: _kGold,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: _kGold.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Asset cards ───────────────────────────────────────────────────────────

  Widget _buildAssetCards(PortfolioModel? port, int wallet, bool isLandscape) {
    final cards = List.generate(4, (i) => _buildAssetCard(port, i, wallet));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assets',
            style: TextStyle(
                color: _kGold, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        if (isLandscape)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 0,
            childAspectRatio: 3.2,
            children: cards,
          )
        else
          ...cards,
      ],
    );
  }

  Widget _buildAssetCard(PortfolioModel? port, int assetIdx, int wallet) {
    final val = port?.assetValues[assetIdx] ?? 0;
    final range = PortfolioModel.assetDailyRange[assetIdx];
    final minPct = (range[0] * 100).toStringAsFixed(1);
    final maxPct = (range[1] * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: _kCard, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Text(PortfolioModel.assetEmojis[assetIdx],
              style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(PortfolioModel.assetNames[assetIdx],
                    style: const TextStyle(
                        color: _kText, fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Held: $val ZC   |   $minPct% to +$maxPct%/day',
                    style: TextStyle(
                        color: _kText.withValues(alpha: 0.55), fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _InvestButton(
            assetIndex: assetIdx,
            wallet: wallet,
          ),
        ],
      ),
    );
  }

  // ── Events card ───────────────────────────────────────────────────────────

  Widget _buildEventsCard(PortfolioModel port) {
    if (port.recentEvents.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
          color: _kCard, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Market Log',
              style: TextStyle(
                  color: _kGold, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ...port.recentEvents.take(6).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(e,
                    style: TextStyle(
                        color: _kText.withValues(alpha: 0.7), fontSize: 12)),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Invest Button Widget
// ─────────────────────────────────────────────────────────────────────────────

class _InvestButton extends ConsumerWidget {
  const _InvestButton({required this.assetIndex, required this.wallet});
  final int assetIndex;
  final int wallet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: wallet > 0
          ? () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) =>
                    _InvestSheet(assetIndex: assetIndex, wallet: wallet),
              )
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _kGold,
        foregroundColor: Colors.black,
        disabledBackgroundColor: Colors.white12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(60, 32),
      ),
      child: const Text('Invest', style: TextStyle(fontSize: 12)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Invest Sheet — owns its own TextEditingController lifecycle
// ─────────────────────────────────────────────────────────────────────────────

class _InvestSheet extends ConsumerStatefulWidget {
  const _InvestSheet({required this.assetIndex, required this.wallet});
  final int assetIndex;
  final int wallet;

  @override
  ConsumerState<_InvestSheet> createState() => _InvestSheetState();
}

class _InvestSheetState extends ConsumerState<_InvestSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2A2000),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Invest in ${PortfolioModel.assetNames[widget.assetIndex]}',
                style: const TextStyle(
                    color: _kGold, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text('Wallet: ${widget.wallet} ZC',
                  style: TextStyle(
                      color: _kText.withValues(alpha: 0.7), fontSize: 13)),
              const SizedBox(height: 14),
              TextField(
                controller: _ctrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: _kText),
                decoration: InputDecoration(
                  hintText: 'Amount (ZamCoins)',
                  hintStyle: TextStyle(color: _kText.withValues(alpha: 0.4)),
                  filled: true,
                  fillColor: const Color(0xFF1A1300),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kGold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: TextStyle(
                              color: _kText.withValues(alpha: 0.5))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final amt = int.tryParse(_ctrl.text.trim()) ?? 0;
                        if (amt <= 0) {
                          Navigator.pop(context);
                          return;
                        }
                        // Capture before pop so they remain valid after dispose.
                        final notifier =
                            ref.read(portfolioProvider.notifier);
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(context);
                        final ok =
                            await notifier.invest(widget.assetIndex, amt);
                        if (!ok) {
                          messenger.showSnackBar(
                            const SnackBar(
                                content: Text('Not enough ZamCoins!')),
                          );
                        }
                      },
                      child: const Text('Invest',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
