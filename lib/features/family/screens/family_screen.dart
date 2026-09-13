/// family_screen.dart
/// Purpose: Virtual Family dashboard — first-time setup wizard then ongoing
///          family management (happiness, health, housing, school fees).
/// Accent palette: amber/gold (#FFB703) on deep-navy base.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/family_provider.dart';
import '../models/family_model.dart';
import '../../../core/theme.dart';
import '../../../widgets/screen_entry.dart';
import '../../../widgets/animated_int.dart';
import '../../../widgets/tap_scale.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const Color _kGold   = Color(0xFFFFB703);
const Color _kAmber  = Color(0xFFFF8C00);
const Color _kNavy   = Color(0xFF0D1B2A);
const Color _kMint   = Color(0xFF36ECDE);
const Color _kGreen  = Color(0xFF2BC48A);
const Color _kGray   = Color(0xFFE6E9EC);

// ── Screen ────────────────────────────────────────────────────────────────────

class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: kCoreNavy,
        body: SafeArea(
          child: Center(
              child: CircularProgressIndicator(color: _kGold)),
        ),
      );
    }

    return ScreenEntry(
      child: state.hasFamily
          ? _FamilyDashboard(family: state.family!)
          : const _FamilySetup(),
    );
  }
}

// ── Setup Wizard ──────────────────────────────────────────────────────────────

class _FamilySetup extends ConsumerStatefulWidget {
  const _FamilySetup();

  @override
  ConsumerState<_FamilySetup> createState() => _FamilySetupState();
}

class _FamilySetupState extends ConsumerState<_FamilySetup> {
  final _spouseCtrl  = TextEditingController();
  final _childCtrl   = TextEditingController();
  int _housingTier   = 1;
  bool _saving       = false;

  @override
  void dispose() {
    _spouseCtrl.dispose();
    _childCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final spouse = _spouseCtrl.text.trim();
    final child  = _childCtrl.text.trim();
    if (spouse.isEmpty || child.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both names.')),
      );
      return;
    }
    setState(() => _saving = true);
    await ref.read(familyProvider.notifier).setupFamily(
          spouseName: spouse,
          childName: child,
          housingTier: _housingTier,
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
          icon: const Icon(Icons.arrow_back, color: _kGold),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'START YOUR FAMILY',
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _kGold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text('👨‍👩‍👧', style: TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Build Your Virtual Family',
                style: GoogleFonts.rajdhani(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _kGold,
                ),
              ),
            ),
            Center(
              child: Text(
                'Your family depends on your financial decisions.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: _kGray.withValues(alpha: 0.70)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            _label('Spouse / Partner Name'),
            const SizedBox(height: 8),
            _textField(
              controller: _spouseCtrl,
              hint: 'e.g. Nalukui',
            ),
            const SizedBox(height: 16),

            _label("Child's Name"),
            const SizedBox(height: 8),
            _textField(
              controller: _childCtrl,
              hint: 'e.g. Chanda',
            ),
            const SizedBox(height: 24),

            _label('Starting Housing'),
            const SizedBox(height: 12),
            ...List.generate(3, (i) {
              final tier = i + 1;
              final name = FamilyModel.housingNames[i];
              final cost = FamilyModel.housingCosts[i];
              final selected = _housingTier == tier;
              return TapScale(
                onTap: () => setState(() => _housingTier = tier),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? _kGold.withValues(alpha: 0.15)
                        : _kNavy,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? _kGold
                          : Colors.white.withValues(alpha: 0.12),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tier == 1
                            ? Icons.bed
                            : tier == 2
                                ? Icons.apartment
                                : Icons.home,
                        color: selected ? _kGold : _kGray.withValues(alpha: 0.50),
                        size: 24,
                      ),
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
                                color: selected ? _kGold : _kGray,
                              ),
                            ),
                            Text(
                              'ZMW $cost/month',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _kGray.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check_circle, color: _kGold, size: 20),
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
                  backgroundColor: _kGold,
                  foregroundColor: _kNavy,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: _kNavy)
                    : Text(
                        'Create My Family  →',
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
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.orbitron(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _kMint,
          letterSpacing: 1.2,
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
  }) =>
      TextField(
        controller: controller,
        style: GoogleFonts.rajdhani(fontSize: 18, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.rajdhani(
              fontSize: 16, color: _kGray.withValues(alpha: 0.40)),
          filled: true,
          fillColor: _kNavy,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kGold, width: 2),
          ),
        ),
      );
}

// ── Dashboard ─────────────────────────────────────────────────────────────────

class _FamilyDashboard extends ConsumerWidget {
  const _FamilyDashboard({required this.family});

  final FamilyModel family;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kCoreNavy,
      appBar: AppBar(
        backgroundColor: kCoreNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kGold),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'MY FAMILY',
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _kGold,
            letterSpacing: 1.2,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '👨‍👩‍👧',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          children: [
            // ── Names banner ──────────────────────────────────────────────
            _nameBanner(family),
            const SizedBox(height: 16),

            // ── Happiness & Health meters ─────────────────────────────────
            Row(
              children: [
                Expanded(
                    child: _scoreMeter(
                        label: 'HAPPINESS',
                        value: family.happinessScore,
                        color: _kGold,
                        emoji: '😊')),
                const SizedBox(width: 12),
                Expanded(
                    child: _scoreMeter(
                        label: 'HEALTH',
                        value: family.healthScore,
                        color: _kGreen,
                        emoji: '💪')),
              ],
            ),
            const SizedBox(height: 16),

            // ── Housing card ──────────────────────────────────────────────
            _infoCard(
              title: 'HOUSING',
              value: family.housingName,
              subtitle:
                  'ZMW ${FamilyModel.housingCosts[family.housingTier - 1]}/month',
              emoji: family.housingTier == 1
                  ? '🛏️'
                  : family.housingTier == 2
                      ? '🏢'
                      : '🏠',
              child: family.housingTier < 3
                  ? _actionButton(
                      label:
                          'Upgrade (${FamilyModel.housingUpgradeCosts[family.housingTier]} coins)',
                      color: _kGold,
                      onTap: () async {
                        final ok =
                            await ref.read(familyProvider.notifier).upgradeHousing();
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Not enough ZamCoins to upgrade.')),
                          );
                        }
                      },
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: _kGreen.withValues(alpha: 0.40)),
                      ),
                      child: Text(
                        '✓ Max Housing Level',
                        style: GoogleFonts.rajdhani(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _kGreen),
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // ── School card ───────────────────────────────────────────────
            _infoCard(
              title: 'SCHOOL',
              value: family.childInSchool
                  ? '${family.childName} is enrolled'
                  : '${family.childName} is not in school',
              subtitle: family.schoolFeesPaid
                  ? 'Fees paid this term ✓'
                  : 'School fees due: ZMW 450',
              emoji: '📚',
              child: !family.schoolFeesPaid
                  ? _actionButton(
                      label: 'Pay School Fees (ZMW 450)',
                      color: _kAmber,
                      onTap: () async {
                        final ok =
                            await ref.read(familyProvider.notifier).paySchoolFees();
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Not enough ZamCoins to pay school fees.')),
                          );
                        }
                      },
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: _kGreen.withValues(alpha: 0.40)),
                      ),
                      child: Text(
                        '✓ Fees Paid',
                        style: GoogleFonts.rajdhani(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _kGreen),
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // ── Happiness boost ───────────────────────────────────────────
            _infoCard(
              title: 'FAMILY TIME',
              value: 'Happiness Boost',
              subtitle: 'Spend 20 ZamCoins for a family outing',
              emoji: '🎉',
              child: _actionButton(
                label: 'Boost Happiness (20 coins)',
                color: _kMint,
                onTap: () async {
                  final ok =
                      await ref.read(familyProvider.notifier).boostHappiness();
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Not enough ZamCoins for a family outing.')),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // ── Monthly expenses ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kNavy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _kGold.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Text('💵', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MONTHLY EXPENSES',
                          style: GoogleFonts.orbitron(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _kMint,
                            letterSpacing: 1.0,
                          ),
                        ),
                        AnimatedInt(
                          value: family.monthlyExpenses,
                          prefix: 'ZMW ',
                          style: GoogleFonts.orbitron(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _kGold,
                          ),
                        ),
                        Text(
                          'Auto-deducted from wallet each month',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _kGray.withValues(alpha: 0.55)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Recent events ─────────────────────────────────────────────
            if (family.recentEvents.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'RECENT FAMILY EVENTS',
                  style: GoogleFonts.orbitron(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _kMint,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...family.recentEvents.take(5).map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _kNavy,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.07)),
                      ),
                      child: Text(
                        e,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: _kGray),
                      ),
                    ),
                  )),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  Widget _nameBanner(FamilyModel f) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kGold.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kGold.withValues(alpha: 0.35), width: 1.5),
        ),
        child: Row(
          children: [
            const Text('👨‍👩‍👧', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The ${f.spouseName.split(' ').last} Family',
                  style: GoogleFonts.rajdhani(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _kGold,
                  ),
                ),
                Text(
                  '${f.spouseName}  ·  ${f.childName}',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: _kGray.withValues(alpha: 0.70)),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _scoreMeter({
    required String label,
    required int value,
    required Color color,
    required String emoji,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kNavy,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: color.withValues(alpha: 0.30), width: 1),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.orbitron(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: _kMint,
                  letterSpacing: 1.0),
            ),
            const SizedBox(height: 4),
            AnimatedInt(
              value: value,
              suffix: ' / 100',
              style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: value / 100),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _infoCard({
    required String title,
    required String value,
    required String subtitle,
    required String emoji,
    required Widget child,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kNavy,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.orbitron(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _kMint,
                          letterSpacing: 1.0),
                    ),
                    Text(
                      value,
                      style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _kGray.withValues(alpha: 0.55)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      TapScale(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.50)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      );
}
