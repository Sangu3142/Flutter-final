library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/seasonal/providers/seasonal_event_provider.dart';
import 'package:zamwealth_quest/shared/widgets/animated_gradient_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────

const Color _kDeepNavy  = Color(0xFF0D1B2A);
const Color _kNeonMint  = Color(0xFF36ECDE);
const Color _kSoftGray  = Color(0xFFE6E9EC);
const Color _kGold      = Color(0xFFFFB703);
const Color _kFreshGreen = Color(0xFF2BC48A);

// ─────────────────────────────────────────────────────────────────────────────
// Season theme helpers
// ─────────────────────────────────────────────────────────────────────────────

Color _themeAccent(String theme) {
  return switch (theme) {
    kSeasonThemeNewYear    => const Color(0xFFFFD700),
    kSeasonThemeSchoolFees => const Color(0xFF1A73E8),
    kSeasonThemeFarming    => const Color(0xFF2BC48A),
    kSeasonThemeHarvest    => const Color(0xFFFF8C00),
    kSeasonThemeChristmas  => const Color(0xFFE53935),
    _                      => _kNeonMint,
  };
}

String _themeEmoji(String theme) {
  return switch (theme) {
    kSeasonThemeNewYear    => '🎊',
    kSeasonThemeSchoolFees => '🎒',
    kSeasonThemeFarming    => '🌱',
    kSeasonThemeHarvest    => '🌾',
    kSeasonThemeChristmas  => '🎄',
    _                      => '🗓',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// SeasonalEventScreen
// ─────────────────────────────────────────────────────────────────────────────

class SeasonalEventScreen extends ConsumerWidget {
  const SeasonalEventScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(seasonalProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: state.activeEvent == null
                    ? _buildNoEvent()
                    : _buildEvent(context, ref, state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: _kDeepNavy.withValues(alpha: 0.90),
        border: Border(
          bottom:
              BorderSide(color: _kNeonMint.withValues(alpha: 0.20), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios, color: _kNeonMint, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'SEASONAL EVENT',
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _kSoftGray,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ── No active event ────────────────────────────────────────────────────────

  Widget _buildNoEvent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🗓', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'No Active Event',
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seasonal events happen in January, April, June, October, and December. Check back next month!',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _kSoftGray,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Active event ───────────────────────────────────────────────────────────

  Widget _buildEvent(
      BuildContext context, WidgetRef ref, SeasonalState state) {
    final event = state.activeEvent!;
    final accent = _themeAccent(event.theme);
    final emoji = _themeEmoji(event.theme);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent.withValues(alpha: 0.25), _kDeepNavy],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                bottom: BorderSide(color: accent.withValues(alpha: 0.40), width: 2),
              ),
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 52)),
                const SizedBox(height: 12),
                Text(
                  event.title,
                  style: GoogleFonts.rajdhani(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withValues(alpha: 0.50)),
                  ),
                  child: Text(
                    state.isCompleted ? 'COMPLETED ✓' : 'ACTIVE THIS MONTH',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: state.isCompleted ? _kFreshGreen : accent,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // About card
          _sectionCard(
            title: '📋 About This Event',
            content: event.description,
            accentColor: accent,
          ),

          const SizedBox(height: 16),

          // Challenge card
          _sectionCard(
            title: '🎯 Your Challenge',
            content: event.challenge,
            accentColor: accent,
          ),

          const SizedBox(height: 16),

          // Rewards card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kDeepNavy,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kGold.withValues(alpha: 0.30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🏆 Rewards',
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kGold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _rewardChip(
                        label: '+${event.xpBonus} XP',
                        icon: Icons.bolt,
                        color: _kNeonMint,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _rewardChip(
                        label: '+${event.zamCoinBonus} ZamCoins',
                        icon: Icons.monetization_on_outlined,
                        color: _kGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // CTA button
          if (state.isCompleted)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: _kFreshGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kFreshGreen.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: _kFreshGreen, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Challenge completed this month!',
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kFreshGreen,
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () async {
                await ref.read(seasonalProvider.notifier).completeEvent();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🎉 +${event.xpBonus} XP and +${event.zamCoinBonus} ZamCoins earned!',
                      ),
                      backgroundColor: accent,
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.65)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Accept Challenge & Earn Rewards  →',
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String content,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.rajdhani(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _kSoftGray,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
