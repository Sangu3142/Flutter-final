/// dashboard_screen.dart
/// Purpose: Home tab — premium dark fintech game aesthetic. Shows the player's
///          name, XP progress with sparkle animation, HUD stat bar, daily
///          challenge, level CTA, badges, and tip of the day.
/// Reads from: dashboardProvider, authProvider, dailyChallengeProvider
/// Writes to: nothing (read-only)
/// Navigation: → /levels, → /daily-challenge
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/core/tips.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/daily_challenge/providers/daily_challenge_provider.dart';
import 'package:zamwealth_quest/features/dashboard/providers/dashboard_provider.dart';
import 'package:zamwealth_quest/features/seasonal/providers/seasonal_event_provider.dart';
import 'package:zamwealth_quest/shared/painters/dot_grid_painter.dart';
import 'package:zamwealth_quest/shared/painters/kwacha_icon_painter.dart';
import 'package:zamwealth_quest/shared/widgets/animated_gradient_background.dart';
import 'package:zamwealth_quest/shared/widgets/offline_banner.dart';
import 'package:zamwealth_quest/shared/widgets/sparkle_overlay.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette constants
// ─────────────────────────────────────────────────────────────────────────────

const Color _kCoreNavy = Color(0xFF00203F);
const Color _kDeepNavy = Color(0xFF0D1B2A);
const Color _kPrimaryBlue = Color(0xFF1A73E8);
const Color _kNeonMint = Color(0xFF36ECDE);
const Color _kFreshGreen = Color(0xFF2BC48A);
const Color _kSoftGray = Color(0xFFE6E9EC);

// ─────────────────────────────────────────────────────────────────────────────
// DashboardScreen
// ─────────────────────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  // XP bar entrance animation — 0 → current value on first build
  late final AnimationController _xpCtrl;
  late final Animation<double> _xpAnim;

  // Streak pulse
  late final AnimationController _streakCtrl;
  late final Animation<double> _streakScale;

  // SparkleOverlay key — trigger() is called whenever XP increases
  final GlobalKey<SparkleOverlayState> _xpSparkleKey =
      GlobalKey<SparkleOverlayState>();

  bool _budgetExpanded = false;

  @override
  void initState() {
    super.initState();

    _xpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _xpAnim = CurvedAnimation(parent: _xpCtrl, curve: Curves.easeOutCubic);
    _xpCtrl.forward();

    _streakCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _streakScale = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(parent: _streakCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _xpCtrl.dispose();
    _streakCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fire sparkle whenever XP increases
    ref.listen<DashboardState?>(dashboardProvider, (prev, next) {
      if (prev != null && next != null && next.xp > prev.xp) {
        _xpSparkleKey.currentState?.trigger();
      }
    });

    final dash = ref.watch(dashboardProvider);

    if (dash == null) {
      return const AnimatedGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(color: _kNeonMint),
          ),
        ),
      );
    }

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            color: _kNeonMint,
            backgroundColor: _kDeepNavy,
            onRefresh: () async =>
                ref.read(authProvider.notifier).refreshUser(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OfflineBanner(),
                  _buildHeaderWithHud(context, dash),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildXpCard(context, dash),
                        const SizedBox(height: 16),
                        _buildDailyChallengeCard(context),
                        const SizedBox(height: 16),
                        _buildBudgetCard(context, dash),
                        const SizedBox(height: 16),
                        _buildQuizCard(context),
                        const SizedBox(height: 16),
                        _buildStoryCard(context),
                        const SizedBox(height: 16),
                        _buildSeasonalCard(context),
                        const SizedBox(height: 16),
                        _buildLevelCTA(context, dash),
                        const SizedBox(height: 20),
                        _buildBadgesSection(context, dash),
                        const SizedBox(height: 20),
                        _buildTipCard(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header + HUD overlap ─────────────────────────────────────────────────────

  Widget _buildHeaderWithHud(BuildContext context, DashboardState dash) {
    const headerH = 140.0;
    const hudH = 88.0;
    const overlap = 20.0;
    return SizedBox(
      height: headerH + hudH - overlap, // 208
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerH,
            child: _buildHeader(context, dash),
          ),
          Positioned(
            top: headerH - overlap, // 120
            left: 12,
            right: 12,
            child: _buildHudBar(dash),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, DashboardState dash) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kPrimaryBlue, _kCoreNavy],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          // Dot-grid watermark at very low opacity
          Positioned.fill(
            child: CustomPaint(
              painter: DotGridPainter(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(dash),
                const SizedBox(width: 14),
                Expanded(child: _buildWelcomeText(dash)),
                _buildStreakPill(dash),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(DashboardState dash) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _kDeepNavy,
        border: Border.all(color: _kNeonMint, width: 2),
        boxShadow: [
          BoxShadow(
            color: _kNeonMint.withValues(alpha: 0.35),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          dash.name.isNotEmpty ? dash.name[0].toUpperCase() : '?',
          style: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(DashboardState dash) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Welcome back,',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: _kSoftGray,
            fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          dash.name,
          style: GoogleFonts.rajdhani(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStreakPill(DashboardState dash) {
    return AnimatedBuilder(
      animation: _streakScale,
      builder: (_, child) =>
          Transform.scale(scale: _streakScale.value, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department, color: _kNeonMint, size: 16),
            const SizedBox(width: 4),
            Text(
              '${dash.streak}',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HUD Stat Bar ─────────────────────────────────────────────────────────────

  Widget _buildHudBar(DashboardState dash) {
    final savings = dash.totalSavingsZMW >= 1000
        ? '${(dash.totalSavingsZMW / 1000).toStringAsFixed(1)}k'
        : dash.totalSavingsZMW.toStringAsFixed(0);

    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _kNeonMint.withValues(alpha: 0.20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _kNeonMint.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _hudCell(
              value: '${dash.zamCoins}',
              label: 'ZAMCOINS',
            ),
          ),
          _hudDivider(),
          Expanded(
            child: _hudCell(
              value: 'ZMW $savings',
              label: 'SAVED (SIM)',
            ),
          ),
          _hudDivider(),
          Expanded(
            child: _hudCell(
              value: '${dash.badgeCount}',
              label: 'BADGES',
            ),
          ),
        ],
      ),
    );
  }

  Widget _hudCell({required String value, required String label}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _kNeonMint,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: _kSoftGray,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _hudDivider() {
    return Container(
      width: 1,
      height: 44,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }

  // ── XP Progress Card ─────────────────────────────────────────────────────────

  Widget _buildXpCard(BuildContext context, DashboardState dash) {
    return _contentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Experience Points',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _kSoftGray,
                ),
              ),
              Text(
                '${dash.xp} XP',
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kNeonMint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // XP bar with glow and sparkle
          SparkleOverlay(
            key: _xpSparkleKey,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: _kNeonMint.withValues(alpha: 0.50),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AnimatedBuilder(
                  animation: _xpAnim,
                  builder: (_, __) => CustomPaint(
                    painter: _XpBarPainter(
                      progress: dash.progressPercent * _xpAnim.value,
                    ),
                    child: const SizedBox(
                        width: double.infinity, height: 16),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dash.rankLabel,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _kFreshGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (dash.xpToNextRankLabel > 0)
                Text(
                  '${dash.xpToNextRankLabel} XP to next rank',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _kSoftGray,
                  ),
                )
              else
                Text(
                  'Max Rank!',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _kNeonMint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Daily Challenge Card ──────────────────────────────────────────────────────

  Widget _buildDailyChallengeCard(BuildContext context) {
    final dcState = ref.watch(dailyChallengeProvider);
    final record = dcState.record;
    final challenge = dcState.todaysChallenge;
    final completedToday = record?.completedToday ?? false;
    final streak = record?.currentStreak ?? 0;
    final shields = record?.streakShields ?? 0;
    final topic = challenge?.topic ?? 'Financial Literacy';

    return Container(
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: const BorderSide(color: _kNeonMint, width: 3),
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          right: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        boxShadow: [
          BoxShadow(
            color: _kNeonMint.withValues(alpha: 0.06),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Text('📅', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY CHALLENGE',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _kNeonMint,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        topic,
                        style: GoogleFonts.rajdhani(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Streak + Shield stat cells ──────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _dcStatCell(
                    icon: Icons.local_fire_department,
                    iconColor: const Color(0xFFFF6B35),
                    value: '$streak',
                    label: 'STREAK',
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                Expanded(
                  child: _dcStatCell(
                    icon: Icons.shield,
                    iconColor: _kPrimaryBlue,
                    value: '$shields',
                    label: 'SHIELDS',
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                Expanded(
                  child: _dcStatCell(
                    icon: Icons.emoji_events,
                    iconColor: _kNeonMint,
                    value: completedToday ? '✓' : '—',
                    label: 'TODAY',
                  ),
                ),
              ],
            ),
          ),

          // ── Action area ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: completedToday
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _kFreshGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _kFreshGreen.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle,
                            color: _kFreshGreen, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Challenge complete — come back tomorrow',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _kFreshGreen,
                          ),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () => context.push(AppRoutes.dailyChallenge),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A73E8), Color(0xFF36ECDE)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _kNeonMint.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Take Today's Challenge  →",
                          style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _dcStatCell({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: _kSoftGray,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  // ── Budget Allocation Card ────────────────────────────────────────────────────

  static const _budgetEmojis = {
    'Rent': '🏠',
    'Food': '🍽️',
    'Transport': '🚌',
    'Savings': '💰',
    'Leisure': '🎉',
  };

  static const _budgetColors = {
    'Rent': Color(0xFF1A73E8),
    'Food': Color(0xFF2BC48A),
    'Transport': Color(0xFFFFB703),
    'Savings': Color(0xFF36ECDE),
    'Leisure': Color(0xFF9C6FDE),
  };

  Widget _buildBudgetCard(BuildContext context, DashboardState dash) {
    final uid = dash.user.uid;
    final raw = Hive.box(kSettingsBox).get('budget_alloc_$uid');
    final Map<String, double>? alloc = raw == null
        ? null
        : Map<String, double>.fromEntries(
            (raw as Map).entries.map(
              (e) => MapEntry(e.key as String, (e.value as num).toDouble()),
            ),
          );

    return Container(
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with toggle ───────────────────────────────────────
          GestureDetector(
            onTap: alloc == null
                ? null
                : () => setState(() => _budgetExpanded = !_budgetExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MY BUDGET',
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _kNeonMint,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          alloc == null
                              ? 'No allocation saved yet'
                              : 'ZMW 3,500 / month',
                          style: GoogleFonts.rajdhani(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (alloc != null)
                    AnimatedRotation(
                      turns: _budgetExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: _kNeonMint,
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── No-allocation prompt ────────────────────────────────────
          if (alloc == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _kNeonMint.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _kNeonMint.withValues(alpha: 0.20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: _kNeonMint.withValues(alpha: 0.70), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Complete the Budget Allocator simulation to see your allocation here.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _kSoftGray,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Expanded allocation rows ────────────────────────────────
          if (alloc != null && _budgetExpanded) ...[
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: alloc.entries.map((entry) {
                  final cat = entry.key;
                  final pct = entry.value;
                  final zmw = (pct / 100) * 3500;
                  final barColor =
                      _budgetColors[cat] ?? _kNeonMint;
                  final emoji = _budgetEmojis[cat] ?? '💵';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Text(emoji,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    cat,
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _kSoftGray,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'ZMW ${zmw.toStringAsFixed(0)}',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: barColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${pct.toStringAsFixed(0)}%',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: _kSoftGray
                                              .withValues(alpha: 0.50),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (pct / 100).clamp(0.0, 1.0),
                                  minHeight: 6,
                                  backgroundColor: Colors.white
                                      .withValues(alpha: 0.08),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          barColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Quiz Card ─────────────────────────────────────────────────────────────────

  Widget _buildQuizCard(BuildContext context) {
    const quizBlue = Color(0xFF1A73E8);
    return GestureDetector(
      onTap: () => context.push(AppRoutes.quiz),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              quizBlue.withValues(alpha: 0.28),
              _kDeepNavy,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: quizBlue.withValues(alpha: 0.60),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: quizBlue.withValues(alpha: 0.22),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon box with vivid border
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: quizBlue.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: quizBlue, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: quizBlue.withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🧠', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINANCIAL QUIZ',
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _kNeonMint,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '5 Questions · Earn XP',
                      style: GoogleFonts.rajdhani(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Test your Zambian financial knowledge',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _kSoftGray.withValues(alpha: 0.80),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: quizBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PLAY',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Story Card ────────────────────────────────────────────────────────────────

  Widget _buildStoryCard(BuildContext context) {
    const storyGold = Color(0xFFFFB703);
    return GestureDetector(
      onTap: () => context.push(AppRoutes.story),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              storyGold.withValues(alpha: 0.22),
              _kDeepNavy,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: storyGold.withValues(alpha: 0.60),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: storyGold.withValues(alpha: 0.18),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: storyGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: storyGold, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: storyGold.withValues(alpha: 0.30),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('📖', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KWACHA CHRONICLES',
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: storyGold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Mwansa's Journey",
                      style: GoogleFonts.rajdhani(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '20 chapters · Make real choices',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _kSoftGray.withValues(alpha: 0.80),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: storyGold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'READ',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00203F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Seasonal Event Card ───────────────────────────────────────────────────────

  Widget _buildSeasonalCard(BuildContext context) {
    final state = ref.watch(seasonalProvider);
    final event = state.activeEvent;

    if (event == null) return const SizedBox.shrink();

    final accent = switch (event.theme) {
      'NEW_YEAR'    => const Color(0xFFFFD700),
      'SCHOOL_FEES' => const Color(0xFF1A73E8),
      'FARMING'     => const Color(0xFF2BC48A),
      'HARVEST'     => const Color(0xFFFF8C00),
      'CHRISTMAS'   => const Color(0xFFE53935),
      _             => _kNeonMint,
    };
    final emoji = switch (event.theme) {
      'NEW_YEAR'    => '🎊',
      'SCHOOL_FEES' => '🎒',
      'FARMING'     => '🌱',
      'HARVEST'     => '🌾',
      'CHRISTMAS'   => '🎄',
      _             => '🗓',
    };

    return GestureDetector(
      onTap: () => context.push(AppRoutes.seasonalEvent),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              accent.withValues(alpha: 0.26),
              _kDeepNavy,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: accent.withValues(alpha: 0.65),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.20),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.30),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.isCompleted
                          ? 'SEASONAL EVENT · DONE'
                          : 'SEASONAL EVENT · ACTIVE',
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: state.isCompleted ? _kFreshGreen : accent,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.title,
                      style: GoogleFonts.rajdhani(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      state.isCompleted
                          ? 'Completed this month ✓'
                          : '+${event.xpBonus} XP  ·  +${event.zamCoinBonus} ZamCoins',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: state.isCompleted
                            ? _kFreshGreen
                            : _kSoftGray.withValues(alpha: 0.80),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: state.isCompleted ? _kFreshGreen : accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  state.isCompleted ? 'DONE' : 'JOIN',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Level CTA ────────────────────────────────────────────────────────────────

  Widget _buildLevelCTA(BuildContext context, DashboardState dash) {
    final meta = kLevelMeta[dash.currentLevel];

    return GestureDetector(
      onTap: () => context.go(AppRoutes.levels),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kDeepNavy,
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              _kPrimaryBlue.withValues(alpha: 0.20),
              _kDeepNavy,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: _kPrimaryBlue.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kFreshGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      meta?.isFree == true
                          ? 'FREE'
                          : 'LEVEL ${dash.currentLevel}',
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meta?.name ?? 'Start Playing',
                    style: GoogleFonts.rajdhani(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    meta?.subtitle ?? 'Begin your financial journey',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _kSoftGray,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios, color: _kNeonMint, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Badges Section ───────────────────────────────────────────────────────────

  static const _badgeLabels = {
    'budget_master': 'Budget Master',
    'savings_star': 'Savings Star',
    'debt_slayer': 'Debt Slayer',
    'investor_pro': 'Investor Pro',
    'business_mogul': 'Business Mogul',
    'zamcoin_collector': 'ZamCoin Collector',
    'level_1_complete': 'Level 1 Done',
    'level_2_complete': 'Level 2 Done',
    'level_3_complete': 'Level 3 Done',
    'level_4_complete': 'Level 4 Done',
  };

  Widget _buildBadgesSection(BuildContext context, DashboardState dash) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges Earned',
          style: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        if (dash.badges.isEmpty)
          _buildEmptyBadgesPlaceholder()
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: dash.badges.map((b) {
              final label = _badgeLabels[b] ?? b.replaceAll('_', ' ');
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _kDeepNavy,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _kNeonMint.withValues(alpha: 0.35),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.military_tech,
                        color: _kNeonMint, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: _kSoftGray,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyBadgesPlaceholder() {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: _kNeonMint.withValues(alpha: 0.30),
        borderRadius: 16,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CustomPaint(
                painter: StarRosettePainter(color: _kNeonMint),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete a simulation to earn your first badge',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _kSoftGray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Tip of the Day ────────────────────────────────────────────────────────────

  Widget _buildTipCard(BuildContext context) {
    final tip =
        kFinancialTips[DateTime.now()._dayOfYear % kFinancialTips.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kFreshGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kFreshGreen.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📰', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip of the Day',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kFreshGreen,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _kSoftGray,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Content Card Helper ───────────────────────────────────────────────────────

  Widget _contentCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// XP Bar Painter
// ─────────────────────────────────────────────────────────────────────────────

class _XpBarPainter extends CustomPainter {
  const _XpBarPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;
    final radius = Radius.circular(h / 2);

    // Track
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, w, h, radius),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..style = PaintingStyle.fill,
    );

    // Filled gradient
    if (progress > 0) {
      final fillW = (w * progress).clamp(h, w);
      canvas.drawRRect(
        RRect.fromLTRBR(0, 0, fillW, h, radius),
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF1A73E8), Color(0xFF36ECDE)],
          ).createShader(Rect.fromLTWH(0, 0, fillW, h))
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _XpBarPainter old) =>
      old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashed Border Painter
// ─────────────────────────────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
  });

  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final source = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
        Radius.circular(borderRadius),
      ));

    const dashLen = 6.0;
    const gapLen = 4.0;
    final dash = Path();

    for (final m in source.computeMetrics()) {
      double distance = 0;
      while (distance < m.length) {
        final end = (distance + dashLen).clamp(0.0, m.length);
        dash.addPath(m.extractPath(distance, end), Offset.zero);
        distance += dashLen + gapLen;
      }
    }

    canvas.drawPath(dash, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.borderRadius != borderRadius;
}

// ─────────────────────────────────────────────────────────────────────────────
// Day-of-year extension
// ─────────────────────────────────────────────────────────────────────────────

extension on DateTime {
  int get _dayOfYear => difference(DateTime(year, 1, 1)).inDays;
}
