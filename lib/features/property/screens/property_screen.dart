/// property_screen.dart
/// Purpose: Property Ladder — 5-tier Zambian property journey with financial
///          literacy concepts: renting vs owning, the ladder, payment mechanics,
///          and net worth impact.
/// Palette: navy #0A1628 bg, terracotta #C17A5A / sand #E8C99A cards,
///          teal #00BCD4 owned border, gold #FFCC02 badges.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zamwealth_quest/features/property/models/property_model.dart';
import 'package:zamwealth_quest/features/property/providers/property_provider.dart';
import 'package:zamwealth_quest/features/wallet/providers/wallet_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────

const _kNavy   = Color(0xFF0A1628);
const _kCard   = Color(0xFF0F2240);
const _kCard2  = Color(0xFF162D4A);
const _kTeal   = Color(0xFF00BCD4);
const _kTerra  = Color(0xFFC17A5A);
const _kSand   = Color(0xFFE8C99A);
const _kText   = Color(0xFFF0E6D3);
const _kGold   = Color(0xFFFFCC02);
const _kMuted  = Color(0xFF8AAABB);
const _kRed    = Color(0xFFE57373);
const _kGreen  = Color(0xFF81C784);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class PropertyScreen extends ConsumerStatefulWidget {
  const PropertyScreen({super.key});

  @override
  ConsumerState<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends ConsumerState<PropertyScreen>
    with TickerProviderStateMixin {
  final _zmwFmt = NumberFormat('#,###', 'en_US');

  late final AnimationController _entryCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;
  late final Animation<double>   _pulseAnim;

  bool   _isProcessing        = false;
  double _sliderMonthlyZC     = 5.0;
  bool   _showMonthlyOption   = false;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(_pulseCtrl);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final propState = ref.watch(propertyProvider);
    final wallet    = ref.watch(walletProvider);

    final Widget body;

    if (propState.isLoading) {
      body = _buildShimmer();
    } else if (propState.property == null) {
      body = _buildNoPropertyBody(wallet);
    } else {
      final prop = propState.property!;
      if (prop.tier >= 1 && prop.tier <= 5) {
        body = _buildMainBody(prop, wallet);
      } else {
        // Corrupted tier — show graceful fallback, never blank.
        body = _buildNoPropertyBody(wallet);
      }
    }

    return Scaffold(
      backgroundColor: _kNavy,
      appBar: AppBar(
        backgroundColor: _kNavy,
        foregroundColor: _kText,
        title: const Text(
          'Property Ladder',
          style: TextStyle(
            color: _kText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: body,
          ),
        ),
      ),
    );

    // This line is never reached — it exists purely as a blank-screen safety net.
    // ignore: dead_code
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHIMMER LOADING
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16, 16, 16, MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        children: List.generate(
          4,
          (i) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 80,
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _shimmerEffect(),
          ),
        ),
      ),
    );
  }

  Widget _shimmerEffect() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              _kCard,
              _kCard2.withValues(alpha: _pulseAnim.value),
              _kCard,
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NO PROPERTY OWNED — "Start Your Journey"
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildNoPropertyBody(int wallet) {
    final deposit    = PropertyModel.tierDepositZamCoins[1];
    final canAfford  = wallet >= deposit;
    final bottomPad  = MediaQuery.of(context).padding.bottom + 16;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Banner ──────────────────────────────────────────────────────
          _sectionCard(
            child: Column(
              children: [
                const Text('🏗️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                const Text(
                  'Start Your Property Journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _kSand,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Every Zambian homeowner started with a plot.\nYours could be worth ZMW 54,000 next year.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _kText.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Wallet: $wallet ZamCoins',
                  style: const TextStyle(
                    color: _kGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Concept 1 preview: renting drains wealth ─────────────────
          _rentVsOwnCard(ownedTier: 0),

          const SizedBox(height: 16),

          // ── Concept 2: The full ladder ─────────────────────────────────
          _sectionHeader('THE ZAMBIAN PROPERTY LADDER'),
          const SizedBox(height: 10),
          ...List.generate(5, (i) => _buildTierRow(i + 1, ownedTier: 0, wallet: wallet)),

          const SizedBox(height: 20),

          // ── Buy button ───────────────────────────────────────────────
          ElevatedButton.icon(
            onPressed: canAfford && !_isProcessing
                ? () => _showPurchaseSheet(1, wallet)
                : null,
            icon: const Text('🏗️', style: TextStyle(fontSize: 20)),
            label: Text(
              canAfford
                  ? 'Get Your Plot — $deposit ZC'
                  : 'Need $deposit ZC (have $wallet ZC)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kTerra,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.white12,
              disabledForegroundColor: Colors.white38,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Concept 3: Payment calc ───────────────────────────────────
          _instalmentCalculatorCard(nextTier: 1),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MAIN BODY — property owned
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMainBody(PropertyModel prop, int wallet) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 16;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Concept 1: Renting vs Owning ──────────────────────────────
          _rentVsOwnCard(ownedTier: prop.tier),
          const SizedBox(height: 16),

          // ── Concept 2: Property Ladder ─────────────────────────────────
          _sectionHeader('YOUR PROPERTY LADDER'),
          const SizedBox(height: 10),
          ...List.generate(5, (i) => _buildTierRow(i + 1, ownedTier: prop.tier, wallet: wallet)),
          const SizedBox(height: 20),

          // ── Upgrade button (if applicable) ───────────────────────────
          if (prop.canUpgrade) ...[
            _buildUpgradeButton(prop, wallet),
            const SizedBox(height: 16),
          ],

          // ── Rental toggle (tier 5 only) ────────────────────────────────
          if (prop.canRentOut) ...[
            _buildRentalCard(prop),
            const SizedBox(height: 16),
          ],

          // ── Mortgage card (if applicable) ─────────────────────────────
          if (prop.hasMortgage) ...[
            _buildMortgageCard(prop, wallet),
            const SizedBox(height: 16),
          ],

          // ── Concept 3: Instalment calculator ─────────────────────────
          if (prop.canUpgrade) ...[
            _instalmentCalculatorCard(nextTier: prop.tier + 1),
            const SizedBox(height: 16),
          ],

          // ── Concept 4: Net Worth Impact ────────────────────────────────
          _netWorthCard(prop, wallet),
          const SizedBox(height: 16),

          // ── Recent events ─────────────────────────────────────────────
          if (prop.recentEvents.isNotEmpty) _buildEventsCard(prop),

          // ── Fully owned summary (no mortgage, no rental, no upgrade) ──
          if (!prop.hasMortgage && !prop.canRentOut && !prop.canUpgrade)
            _buildFullyOwnedCard(prop),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONCEPT 1 — Renting vs Owning
  // ─────────────────────────────────────────────────────────────────────────

  Widget _rentVsOwnCard({required int ownedTier}) {
    final isOwner     = ownedTier > 0;
    const monthlyRent = 1500; // ZMW example
    const months      = 12;
    const rentPaid    = monthlyRent * months;

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏠', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                isOwner ? 'You Own Property!' : 'Currently Renting',
                style: TextStyle(
                  color: isOwner ? _kGreen : _kRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (isOwner) ...[
            _infoRow('✅', 'No rent payments — you own this!', _kGreen),
            const SizedBox(height: 6),
            _infoRow('📈', 'Property grows ~8% per year in Zambia', _kTeal),
            const SizedBox(height: 6),
            _infoRow('💼', 'Building equity every month', _kSand),
          ] else ...[
            _infoRow('💸', 'ZMW 1,500/month in rent = gone forever', _kRed),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Rent paid this year',
                    style: TextStyle(
                      color: _kText.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  'ZMW ${_zmwFmt.format(rentPaid)}',
                  style: const TextStyle(
                    color: _kRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: const LinearProgressIndicator(
                value: 1.0,
                minHeight: 8,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(_kRed),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'vs. buying a Plot for ZMW 50,000 — it builds equity instead.',
              style: TextStyle(
                color: _kText.withValues(alpha: 0.55),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONCEPT 2 — Tier Row in the Ladder
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTierRow(int tier, {required int ownedTier, required int wallet}) {
    final isOwned   = tier <= ownedTier;
    final isNext    = tier == ownedTier + 1;
    final isLocked  = tier > ownedTier + 1;
    final canAfford = wallet >= PropertyModel.tierDepositZamCoins[tier];
    final zmw       = _zmwFmt.format(PropertyModel.tierBaseZMW[tier]);
    final deposit   = PropertyModel.tierDepositZamCoins[tier];

    Color borderColor;
    if (isOwned) {
      borderColor = _kTeal;
    } else if (isNext) {
      borderColor = _kTeal.withValues(alpha: 0.5);
    } else {
      borderColor = Colors.transparent;
    }

    Widget card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isLocked ? _kCard.withValues(alpha: 0.5) : _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isOwned ? 2 : 1.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Opacity(
        opacity: isLocked ? 0.4 : 1.0,
        child: Row(
          children: [
            Text(
              PropertyModel.tierEmojis[tier],
              style: TextStyle(fontSize: isOwned ? 28 : 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PropertyModel.tierNames[tier],
                    style: TextStyle(
                      color: isOwned ? _kSand : _kText,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ZMW $zmw  •  $deposit ZC deposit',
                    style: TextStyle(
                      color: isOwned
                          ? _kTeal
                          : _kText.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    PropertyModel.tierDescriptions[tier],
                    style: TextStyle(
                      color: _kText.withValues(alpha: 0.45),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _tierBadge(
              isOwned: isOwned,
              isNext: isNext,
              isLocked: isLocked,
              canAfford: canAfford,
            ),
          ],
        ),
      ),
    );

    // Wrap the NEXT tier card in an AnimatedBuilder for the pulse glow effect.
    if (isNext) {
      card = AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _kTeal.withValues(alpha: _pulseAnim.value * 0.35),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
        child: card,
      );
    }

    return card;
  }

  Widget _tierBadge({
    required bool isOwned,
    required bool isNext,
    required bool isLocked,
    required bool canAfford,
  }) {
    if (isOwned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _kTeal.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kTeal, width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: _kTeal, size: 14),
            SizedBox(width: 4),
            Text(
              'OWNED',
              style: TextStyle(
                color: _kTeal,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    if (isNext) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: canAfford
              ? _kGold.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          canAfford ? '⭐ NEXT' : '⭐ GOAL',
          style: TextStyle(
            color: canAfford ? _kGold : _kMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return const Icon(Icons.lock_outline, color: Colors.white24, size: 18);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONCEPT 3 — Instalment Calculator
  // ─────────────────────────────────────────────────────────────────────────

  Widget _instalmentCalculatorCard({required int nextTier}) {
    if (nextTier < 1 || nextTier > 5) return const SizedBox.shrink();

    final fullCost   = PropertyModel.totalCostZC(nextTier);
    final monthly    = _sliderMonthlyZC.round();
    final months     = monthly > 0 ? (fullCost / monthly).ceil() : 0;
    final zmwMonthly = monthly * 1000;

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🧮', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Instalment Calculator',
                style: TextStyle(
                  color: _kSand,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${PropertyModel.tierNames[nextTier]}: $fullCost ZC total',
            style: TextStyle(
              color: _kText.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _sliderMonthlyZC,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  activeColor: _kTeal,
                  inactiveColor: Colors.white12,
                  onChanged: (v) => setState(() => _sliderMonthlyZC = v),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$monthly ZC/mo',
                style: const TextStyle(
                  color: _kTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ZMW ${_zmwFmt.format(zmwMonthly)}/month',
                      style: const TextStyle(
                        color: _kSand,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'saved each month',
                      style: TextStyle(
                        color: _kText.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$months months',
                      style: const TextStyle(
                        color: _kGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'to reach goal',
                      style: TextStyle(
                        color: _kText.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONCEPT 4 — Net Worth Impact
  // ─────────────────────────────────────────────────────────────────────────

  Widget _netWorthCard(PropertyModel prop, int wallet) {
    final propertyZMW    = prop.currentValueZMW;
    final cashZMW        = wallet * 1000;
    final totalZMW       = propertyZMW + cashZMW;
    final propPct        = totalZMW > 0 ? propertyZMW / totalZMW : 0.0;
    final nextYearZMW    = (propertyZMW * 1.08).round();
    final gainZMW        = nextYearZMW - propertyZMW;

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📊', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Net Worth Impact',
                style: TextStyle(
                  color: _kSand,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Net worth totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statChip('Property', 'ZMW ${_zmwFmt.format(propertyZMW)}', _kTerra),
              _statChip('Cash', 'ZMW ${_zmwFmt.format(cashZMW)}', _kMuted),
              _statChip('Total', 'ZMW ${_zmwFmt.format(totalZMW)}', _kSand),
            ],
          ),
          const SizedBox(height: 12),

          // Mini bar chart
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Expanded(
                  flex: (propPct * 100).round().clamp(1, 99),
                  child: Container(height: 12, color: _kTerra),
                ),
                Expanded(
                  flex: ((1 - propPct) * 100).round().clamp(1, 99),
                  child: Container(height: 12, color: _kMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⬛ Property ${(propPct * 100).round()}%',
                style: const TextStyle(
                  color: _kTerra,
                  fontSize: 10,
                ),
              ),
              Text(
                'Cash ${((1 - propPct) * 100).round()}%',
                style: const TextStyle(
                  color: _kMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Appreciation forecast
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _kGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _kGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'Property in Zambia grows ~8%/year. '
              'Your ${PropertyModel.tierNames[prop.tier]} could be worth '
              'ZMW ${_zmwFmt.format(nextYearZMW)} next year '
              '(+ZMW ${_zmwFmt.format(gainZMW)}).',
              style: const TextStyle(color: _kGreen, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Upgrade button
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildUpgradeButton(PropertyModel prop, int wallet) {
    final nextTier  = prop.tier + 1;
    final deposit   = PropertyModel.tierDepositZamCoins[nextTier];
    final canAfford = wallet >= deposit;

    return ElevatedButton.icon(
      onPressed: canAfford && !_isProcessing
          ? () => _showPurchaseSheet(nextTier, wallet)
          : null,
      icon: Text(
        PropertyModel.tierEmojis[nextTier],
        style: const TextStyle(fontSize: 20),
      ),
      label: Text(
        canAfford
            ? 'Upgrade to ${PropertyModel.tierNames[nextTier]} — $deposit ZC'
            : 'Need $deposit ZC for ${PropertyModel.tierNames[nextTier]}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _kTerra,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.white12,
        disabledForegroundColor: Colors.white38,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Rental card (tier 5)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildRentalCard(PropertyModel prop) {
    return _sectionCard(
      child: Row(
        children: [
          const Text('🏘️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rental Income',
                  style: TextStyle(
                    color: _kSand,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  prop.isRentedOut
                      ? '${PropertyModel.tier5RentalZamCoins} ZC/week passive income'
                      : 'Not listed — toggle to earn weekly ZC',
                  style: TextStyle(
                    color: _kText.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: prop.isRentedOut,
            onChanged: (_) =>
                ref.read(propertyProvider.notifier).toggleRental(),
            activeThumbColor: _kTeal,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mortgage card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMortgageCard(PropertyModel prop, int wallet) {
    final total    = PropertyModel.tierMortgageMonths[prop.tier.clamp(1, 5)];
    final progress = total > 0
        ? (total - prop.mortgageMonthsRemaining) / total
        : 1.0;

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '💳 Mortgage',
                style: TextStyle(
                  color: _kSand,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                '${prop.mortgageMonthsRemaining} months left',
                style: TextStyle(
                  color: _kText.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(_kTerra),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: wallet >= prop.monthlyMortgageZamCoins && !_isProcessing
                  ? () => _payMortgageInstalment()
                  : null,
              icon: const Icon(Icons.payment, size: 16),
              label: Text(
                'Pay ${prop.monthlyMortgageZamCoins} ZC instalment',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kTerra,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.white12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Events card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildEventsCard(PropertyModel prop) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              color: _kSand,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...prop.recentEvents.take(6).map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    e,
                    style: TextStyle(
                      color: _kText.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fully owned summary (tier 5 fully paid, or tier 5 renter)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFullyOwnedCard(PropertyModel prop) {
    return _sectionCard(
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: _kTeal, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Property Fully Owned',
                  style: TextStyle(
                    color: _kSand,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'No mortgage remaining. Value grows ~8% yearly.',
                  style: TextStyle(
                    color: _kText.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PURCHASE BOTTOM SHEET
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _showPurchaseSheet(int tier, int wallet) async {
    if (tier < 1 || tier > 5) return;
    _showMonthlyOption = false;

    final deposit     = PropertyModel.tierDepositZamCoins[tier];
    final mortMonthly = PropertyModel.tierMortgageZamCoins[tier];
    final mortMonths  = PropertyModel.tierMortgageMonths[tier];
    final hasMortgage = mortMonthly > 0;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F2240),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.fromLTRB(
              20, 20, 20, math.max(20, MediaQuery.of(ctx).padding.bottom + 20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title + emoji
                Row(
                  children: [
                    Text(
                      PropertyModel.tierEmojis[tier],
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PropertyModel.tierNames[tier],
                            style: const TextStyle(
                              color: _kSand,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ZMW ${_zmwFmt.format(PropertyModel.tierBaseZMW[tier])}',
                            style: TextStyle(
                              color: _kText.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Wallet balance
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _kNavy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your wallet',
                        style: TextStyle(
                          color: _kText.withValues(alpha: 0.65),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '$wallet ZC',
                        style: const TextStyle(
                          color: _kGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Option A: Pay in Full
                _purchaseOption(
                  label: 'Option A — Pay in Full',
                  detail: '$deposit ZC now, no further payments',
                  badge: wallet >= deposit ? '✅ Can afford' : '❌ Need $deposit ZC',
                  badgeColor: wallet >= deposit ? _kGreen : _kRed,
                  selected: !_showMonthlyOption,
                  onTap: () {},
                ),

                if (hasMortgage) ...[
                  const SizedBox(height: 8),
                  // Option B: Monthly Plan
                  _purchaseOption(
                    label: 'Option B — Monthly Instalment',
                    detail: '$deposit ZC deposit + $mortMonthly ZC/month × $mortMonths months',
                    badge: 'Total: ${PropertyModel.totalCostZC(tier)} ZC',
                    badgeColor: _kMuted,
                    selected: _showMonthlyOption,
                    onTap: () {},
                  ),
                ],

                const SizedBox(height: 20),

                // Confirm button
                ElevatedButton(
                  onPressed: wallet >= deposit
                      ? () {
                          Navigator.pop(ctx);
                          _confirmPurchase(tier);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kTerra,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    wallet >= deposit
                        ? 'Confirm — $deposit ZC'
                        : 'Insufficient ZamCoins',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _purchaseOption({
    required String label,
    required String detail,
    required String badge,
    required Color badgeColor,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected
            ? _kTeal.withValues(alpha: 0.1)
            : _kNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? _kTeal : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? _kTeal : _kText,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: TextStyle(
              color: _kText.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _confirmPurchase(int tier) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final propNotifier = ref.read(propertyProvider.notifier);
    final bool ok;

    // Determine if upgrading or making first purchase.
    final current = ref.read(propertyProvider).property;
    if (current == null) {
      ok = await propNotifier.purchaseProperty(tier);
    } else {
      ok = await propNotifier.upgradeProperty();
    }

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (ok) {
      ref.invalidate(walletProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${PropertyModel.tierEmojis[tier]} ${PropertyModel.tierNames[tier]} purchased! Your net worth just grew.',
          ),
          backgroundColor: _kTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough ZamCoins!'),
          backgroundColor: _kRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _payMortgageInstalment() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final ok = await ref.read(propertyProvider.notifier).payMortgage();
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough ZamCoins!')),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _kSand,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _infoRow(String icon, String text, Color color) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _kText.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
