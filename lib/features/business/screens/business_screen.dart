/// business_screen.dart
/// Purpose: Virtual Business Engine — first-time setup then weekly decisions,
///          compliance management, and revenue tracking.
/// Accent palette: fresh green (#2BC48A) on deep-navy base.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/business_provider.dart';
import '../models/business_model.dart';
import '../../../core/theme.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const Color _kGreen  = Color(0xFF2BC48A);
const Color _kMint   = Color(0xFF36ECDE);
const Color _kGold   = Color(0xFFFFB703);
const Color _kNavy   = Color(0xFF0D1B2A);
const Color _kBlue   = Color(0xFF1A73E8);
const Color _kGray   = Color(0xFFE6E9EC);
const Color _kRed    = Color(0xFFE53935);

// ── Screen ────────────────────────────────────────────────────────────────────

class BusinessScreen extends ConsumerStatefulWidget {
  const BusinessScreen({super.key});

  @override
  ConsumerState<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends ConsumerState<BusinessScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(businessProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: kCoreNavy,
        body: Center(
            child: CircularProgressIndicator(color: _kGreen)),
      );
    }

    return state.hasBusiness
        ? _BusinessDashboard(business: state.business!)
        : const _BusinessSetup();
  }
}

// ── Setup Wizard ──────────────────────────────────────────────────────────────

class _BusinessSetup extends ConsumerStatefulWidget {
  const _BusinessSetup();

  @override
  ConsumerState<_BusinessSetup> createState() => _BusinessSetupState();
}

class _BusinessSetupState extends ConsumerState<_BusinessSetup> {
  final _nameCtrl = TextEditingController();
  String _type    = 'retail';
  bool _saving    = false;

  static const _types = [
    ('retail',   '🛒', 'Retail Shop',     'Buy and sell goods'),
    ('services', '🔧', 'Services',        'Plumbing, salon, repair'),
    ('farming',  '🌱', 'Farming/Agro',    'Crops, livestock, produce'),
    ('tech',     '💻', 'Tech & Digital',  'Software, mobile, digital'),
    ('food',     '🍽️', 'Food & Catering', 'Restaurant, takeaway, catering'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a business name.')),
      );
      return;
    }
    setState(() => _saving = true);
    await ref.read(businessProvider.notifier).setupBusiness(
          businessName: name,
          businessType: _type,
        );
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCoreNavy,
      appBar: AppBar(
        backgroundColor: kCoreNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kGreen),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'LAUNCH YOUR BUSINESS',
          style: GoogleFonts.orbitron(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _kGreen,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('🏢', style: TextStyle(fontSize: 64))),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Start Your Virtual Business',
                style: GoogleFonts.rajdhani(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _kGreen,
                ),
              ),
            ),
            Center(
              child: Text(
                'Run a real Zambian business — make decisions, stay compliant, grow.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: _kGray.withValues(alpha: 0.70)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'BUSINESS NAME',
              style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _kMint,
                  letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: GoogleFonts.rajdhani(fontSize: 18, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Mwape\'s Fresh Market',
                hintStyle: GoogleFonts.rajdhani(
                    fontSize: 16,
                    color: _kGray.withValues(alpha: 0.40)),
                filled: true,
                fillColor: _kNavy,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _kGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'BUSINESS TYPE',
              style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _kMint,
                  letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            ...List.generate(_types.length, (i) {
              final (id, emoji, name, desc) = _types[i];
              final selected = _type == id;
              final baseRev = BusinessModel.baseRevenue[id] ?? 500;
              return GestureDetector(
                onTap: () => setState(() => _type = id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? _kGreen.withValues(alpha: 0.12)
                        : _kNavy,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? _kGreen
                          : Colors.white.withValues(alpha: 0.10),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.rajdhani(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color:
                                    selected ? _kGreen : _kGray,
                              ),
                            ),
                            Text(
                              '$desc · ZMW $baseRev/week base',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color:
                                    _kGray.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check_circle,
                            color: _kGreen, size: 20),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Launch My Business  →',
                        style: GoogleFonts.rajdhani(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashboard ─────────────────────────────────────────────────────────────────

class _BusinessDashboard extends ConsumerStatefulWidget {
  const _BusinessDashboard({required this.business});

  final BusinessModel business;

  @override
  ConsumerState<_BusinessDashboard> createState() =>
      _BusinessDashboardState();
}

class _BusinessDashboardState extends ConsumerState<_BusinessDashboard> {
  bool _decisionsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final biz = widget.business;

    return Scaffold(
      backgroundColor: kCoreNavy,
      appBar: AppBar(
        backgroundColor: kCoreNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kGreen),
          onPressed: () => context.pop(),
        ),
        title: Text(
          biz.businessName.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _kGreen,
            letterSpacing: 1.0,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(biz.typeEmoji,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Stage banner ──────────────────────────────────────────────
            _stageBanner(biz),
            const SizedBox(height: 16),

            // ── Revenue / Expenses / Profit row ───────────────────────────
            Row(
              children: [
                Expanded(
                    child: _statCell(
                        label: 'REVENUE',
                        value: 'ZMW ${biz.weeklyRevenue}',
                        color: _kGreen,
                        sub: '/week')),
                Expanded(
                    child: _statCell(
                        label: 'EXPENSES',
                        value: 'ZMW ${biz.weeklyExpenses}',
                        color: _kRed,
                        sub: '/week')),
                Expanded(
                    child: _statCell(
                        label: 'PROFIT',
                        value: 'ZMW ${biz.weeklyProfit}',
                        color: biz.weeklyProfit >= 0 ? _kMint : _kRed,
                        sub: '/week')),
              ],
            ),
            const SizedBox(height: 16),

            // ── Compliance card ───────────────────────────────────────────
            _complianceCard(context, biz),
            const SizedBox(height: 16),

            // ── Total profit ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kNavy,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: _kGold.withValues(alpha: 0.30)),
              ),
              child: Row(
                children: [
                  const Text('💰', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL PROFIT',
                        style: GoogleFonts.orbitron(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _kMint,
                            letterSpacing: 1.0),
                      ),
                      Text(
                        'ZMW ${biz.totalProfit}',
                        style: GoogleFonts.orbitron(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _kGold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'STAFF',
                        style: GoogleFonts.orbitron(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _kMint,
                            letterSpacing: 1.0),
                      ),
                      Text(
                        '${biz.staff} people',
                        style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Weekly decisions ──────────────────────────────────────────
            _decisionsSection(context, biz),
            const SizedBox(height: 16),

            // ── Recent events ─────────────────────────────────────────────
            if (biz.recentEvents.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'RECENT BUSINESS EVENTS',
                  style: GoogleFonts.orbitron(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _kMint,
                      letterSpacing: 1.0),
                ),
              ),
              const SizedBox(height: 8),
              ...biz.recentEvents.take(5).map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _kNavy,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color:
                                  Colors.white.withValues(alpha: 0.07)),
                        ),
                        child: Text(e,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: _kGray)),
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _stageBanner(BusinessModel biz) {
    final stageColors = [_kBlue, _kGreen, _kGold, _kMint, _kRed];
    final color = stageColors[(biz.stage - 1).clamp(0, 4)];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: color.withValues(alpha: 0.40), width: 1.5),
      ),
      child: Row(
        children: [
          Text(biz.typeEmoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STAGE ${biz.stage} OF 5',
                  style: GoogleFonts.orbitron(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: color,
                      letterSpacing: 1.0),
                ),
                Text(
                  biz.stageName,
                  style: GoogleFonts.rajdhani(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: color),
                ),
                Text(
                  '${5000 * biz.stage - biz.totalProfit} ZMW to next stage',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _kGray.withValues(alpha: 0.60)),
                ),
              ],
            ),
          ),
          // Stage pips
          Column(
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < biz.stage
                        ? color
                        : Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCell({
    required String label,
    required String value,
    required Color color,
    required String sub,
  }) =>
      Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _kNavy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.orbitron(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: _kMint,
                  letterSpacing: 1.0),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color),
              textAlign: TextAlign.center,
            ),
            Text(
              sub,
              style: GoogleFonts.inter(
                  fontSize: 10, color: _kGray.withValues(alpha: 0.50)),
            ),
          ],
        ),
      );

  Widget _complianceCard(BuildContext context, BusinessModel biz) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: _kGreen.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COMPLIANCE',
                style: GoogleFonts.orbitron(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _kMint,
                    letterSpacing: 1.0),
              ),
              Text(
                '${biz.complianceScore}%',
                style: GoogleFonts.orbitron(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: biz.complianceScore >= 100
                        ? _kGreen
                        : _kGold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: biz.complianceScore / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                  biz.complianceScore >= 100 ? _kGreen : _kGold),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _complianceBadge(
                label: 'PACRA',
                done: biz.pacraRegistered,
                cost: 'ZMW 150',
                onTap: biz.pacraRegistered
                    ? null
                    : () async {
                        final ok = await ref
                            .read(businessProvider.notifier)
                            .registerPacra();
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Need ZMW 150 to register with PACRA.')),
                          );
                        }
                      },
              ),
              const SizedBox(width: 8),
              _complianceBadge(
                label: 'ZRA',
                done: biz.zraTaxFiled,
                cost: 'Free',
                onTap: biz.zraTaxFiled
                    ? null
                    : () async {
                        await ref
                            .read(businessProvider.notifier)
                            .fileZraTax();
                      },
              ),
              const SizedBox(width: 8),
              _complianceBadge(
                label: 'NAPSA',
                done: biz.napssaContributed,
                cost: 'Free',
                onTap: biz.napssaContributed
                    ? null
                    : () async {
                        await ref
                            .read(businessProvider.notifier)
                            .contributeNapssa();
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _complianceBadge({
    required String label,
    required bool done,
    required String cost,
    required VoidCallback? onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: done
                  ? _kGreen.withValues(alpha: 0.15)
                  : _kGold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: done
                      ? _kGreen.withValues(alpha: 0.50)
                      : _kGold.withValues(alpha: 0.40)),
            ),
            child: Column(
              children: [
                Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: done ? _kGreen : _kGold,
                  size: 18,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.orbitron(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: done ? _kGreen : _kGold),
                ),
                if (!done)
                  Text(
                    cost,
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        color: _kGray.withValues(alpha: 0.55)),
                  ),
              ],
            ),
          ),
        ),
      );

  Widget _decisionsSection(BuildContext context, BusinessModel biz) {
    final canDecide = biz.canMakeWeeklyDecision;
    return Container(
      decoration: BoxDecoration(
        color: _kNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _decisionsExpanded = !_decisionsExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  const Text('⚙️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WEEKLY DECISIONS',
                          style: GoogleFonts.orbitron(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _kMint,
                              letterSpacing: 1.0),
                        ),
                        Text(
                          canDecide
                              ? 'Choose your strategy this week'
                              : 'Next decision available in 7 days',
                          style: GoogleFonts.rajdhani(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: canDecide ? Colors.white : _kGray.withValues(alpha: 0.50)),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _decisionsExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: _kMint, size: 22),
                  ),
                ],
              ),
            ),
          ),
          if (_decisionsExpanded && canDecide) ...[
            const Divider(height: 1, color: Color(0x14FFFFFF)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: kWeeklyDecisions.take(5).map((d) {
                  return GestureDetector(
                    onTap: () async {
                      await ref
                          .read(businessProvider.notifier)
                          .makeDecision(d);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(d.lesson),
                            duration: const Duration(seconds: 5),
                            backgroundColor: _kGreen,
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _kGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _kGreen.withValues(alpha: 0.30)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.label,
                            style: GoogleFonts.rajdhani(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _kGreen),
                          ),
                          Text(
                            d.description,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _kGray.withValues(alpha: 0.70)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _deltaChip('+${d.revenueDelta} rev', _kGreen),
                              const SizedBox(width: 6),
                              _deltaChip('+${d.expenseDelta} exp', _kRed),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (_decisionsExpanded && !canDecide)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kGreen.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: _kGreen.withValues(alpha: 0.20)),
                ),
                child: Text(
                  '✓ Decision made this week. Check back in 7 days for your next strategy choice.',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: _kGray.withValues(alpha: 0.70)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _deltaChip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color),
        ),
      );
}
