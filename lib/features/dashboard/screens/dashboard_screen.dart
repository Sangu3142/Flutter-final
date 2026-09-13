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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/core/tips.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/daily_challenge/models/challenge.dart';
import 'package:zamwealth_quest/features/daily_challenge/providers/daily_challenge_provider.dart';
import 'package:zamwealth_quest/features/dashboard/providers/dashboard_provider.dart';
import 'package:zamwealth_quest/features/seasonal/providers/seasonal_event_provider.dart';
import 'package:zamwealth_quest/shared/painters/dot_grid_painter.dart';
import 'package:zamwealth_quest/shared/widgets/animated_gradient_background.dart';
import 'package:zamwealth_quest/shared/widgets/offline_banner.dart';
import 'package:zamwealth_quest/shared/widgets/sparkle_overlay.dart';
import '../../avatar/widgets/avatar_painter.dart';
import '../../wallet/widgets/wallet_badge.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../../flash_challenge/widgets/flash_challenge_banner.dart';
import '../../xp_boost/widgets/xp_boost_banner.dart';
import '../../xp_boost/widgets/boost_timer_chip.dart';
import '../../coop/widgets/zamu_companion_widget.dart';
import '../../seasons/widgets/season_progress_bar.dart';
import '../../seasons/widgets/holiday_event_banner.dart';
import '../../badges/providers/badge_provider.dart';
import '../../family/providers/family_provider.dart';
import '../../business/providers/business_provider.dart';
import '../../life_events/providers/life_events_provider.dart';
import '../../property/models/property_model.dart';
import '../../property/providers/property_provider.dart';
import '../../portfolio/providers/portfolio_provider.dart';
import '../../loans/providers/loans_provider.dart';
import '../../savings/providers/savings_provider.dart';
import '../../networth/providers/networth_provider.dart';
import '../../news/providers/news_provider.dart';
import '../../health/providers/health_provider.dart';
import '../../health/screens/health_screen.dart';
import '../../mentors/providers/mentor_provider.dart';
import '../../daily_routine/providers/daily_routine_provider.dart';
import '../../streak/providers/streak_provider.dart';
import '../../../widgets/tutorial_overlay.dart';

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

  // XP bar glow — flashes and fades when XP is gained
  late final AnimationController _xpGlowCtrl;
  late final Animation<double> _xpGlowAnim;

  // Streak pulse
  late final AnimationController _streakCtrl;
  late final Animation<double> _streakScale;

  // SparkleOverlay key — trigger() is called whenever XP increases
  final GlobalKey<SparkleOverlayState> _xpSparkleKey =
      GlobalKey<SparkleOverlayState>();

  // Tutorial GlobalKeys — public, defined in widgets/tutorial_overlay.dart.
  // Locally we keep small finals for sections not covered by the tutorial.
  final GlobalKey _myFinancesKey = GlobalKey();
  final GlobalKey _spinWheelKey = GlobalKey();

  // Scroll controller shared with tutorial overlay
  final ScrollController _scrollCtrl = ScrollController();

  bool _budgetExpanded = false;
  bool _myLifeExpanded = true;
  bool _myFinancesExpanded = true;
  bool _challengeDialogShown = false;
  bool _tutorialTriggered = false;

  // Screen entry
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  // Daily-challenge pulsing border glow
  late final AnimationController _challengeGlowCtrl;
  late final Animation<double> _challengeGlow;

  @override
  void initState() {
    super.initState();

    _xpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _xpAnim = CurvedAnimation(parent: _xpCtrl, curve: Curves.easeOutCubic);
    _xpCtrl.forward();

    _xpGlowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    // Peaks quickly at 25% of duration, then fades slowly for the rest.
    _xpGlowAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 75,
      ),
    ]).animate(_xpGlowCtrl);

    _streakCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _streakScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _streakCtrl, curve: Curves.easeInOut),
    );

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _entryFade  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    _challengeGlowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _challengeGlow = CurvedAnimation(
      parent: _challengeGlowCtrl,
      curve: Curves.easeInOut,
    );

    _entryCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybShowChallengeDialog();
    });
  }

  @override
  void dispose() {
    _xpCtrl.dispose();
    _xpGlowCtrl.dispose();
    _streakCtrl.dispose();
    _entryCtrl.dispose();
    _challengeGlowCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _maybStartTutorial() {
    if (!mounted) return;
    if (isTutorialDone()) return;
    context.go(AppRoutes.tutorial);
  }

  void _maybShowChallengeDialog() {
    // Don't pop the Daily Challenge over the tutorial — let new players
    // finish the walkthrough first.
    final tutorialDone = Hive.box(kSettingsBox)
        .get(kTutorialCompletedKey, defaultValue: false) as bool;
    if (!tutorialDone) return;
    if (_challengeDialogShown || !mounted) return;
    final dcState = ref.read(dailyChallengeProvider);
    if (dcState.todaysChallenge == null ||
        (dcState.record?.completedToday ?? false) ||
        dcState.isLoading) {
      return;
    }

    // Persist shown-state in Hive so navigating away and back doesn't re-trigger.
    final uid = ref.read(currentUserProvider)?.uid ?? '';
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final settingsBox = Hive.box(kSettingsBox);
    if (settingsBox.get('dc_dialog_shown_$uid') == todayStr) return;

    _challengeDialogShown = true;
    settingsBox.put('dc_dialog_shown_$uid', todayStr);
    _showChallengeDialog(dcState.todaysChallenge!);
  }

  void _showChallengeDialog(DailyChallenge challenge) {
    showDialog(
      context: context,
      builder: (ctx) {
        final mq = MediaQuery.of(ctx);
        return LayoutBuilder(
          builder: (lbCtx, constraints) {
            final isCompact = constraints.maxHeight < 500;
            // Tighten vertical spacing in landscape so the question, CTA button
            // and "Remind me later" all remain visible without overflow.
            final s1 = isCompact ? 4.0 : 8.0;
            final s2 = isCompact ? 8.0 : 14.0;
            final s3 = isCompact ? 10.0 : 20.0;
            const padH = 24.0;
            final padV = isCompact ? 14.0 : 24.0;
            return Dialog(
              backgroundColor: _kDeepNavy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              insetPadding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: isCompact ? 16 : 40,
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  padH,
                  padV,
                  padH,
                  padV + mq.viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📅', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'DAILY CHALLENGE',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _kNeonMint,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: _kSoftGray, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: s1),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _kPrimaryBlue.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _kPrimaryBlue.withValues(alpha: 0.50)),
                      ),
                      child: Text(
                        '📚 ${challenge.topic}',
                        style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _kNeonMint,
                        ),
                      ),
                    ),
                    SizedBox(height: s2),
                    Text(
                      challenge.question,
                      style: GoogleFonts.inter(
                        fontSize: isCompact ? 14 : 15,
                        color: Colors.white,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: s3),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push(AppRoutes.dailyChallenge);
                      },
                      child: Container(
                        height: isCompact ? 42 : 48,
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
                              blurRadius: 10,
                              offset: const Offset(0, 3),
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
                    SizedBox(height: s1),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: isCompact ? 4 : 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Remind me later',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: _kSoftGray),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fire sparkle + glow whenever XP increases, re-animate the fill bar
    ref.listen<DashboardState?>(dashboardProvider, (prev, next) {
      if (prev != null && next != null && next.xp > prev.xp) {
        _xpSparkleKey.currentState?.trigger();
        _xpCtrl.forward(from: 0);
        _xpGlowCtrl.forward(from: 0);
      }
    });

    // Show challenge dialog once the provider finishes loading.
    ref.listen<DailyChallengeState>(dailyChallengeProvider, (prev, next) {
      if (!next.isLoading && next.todaysChallenge != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _maybShowChallengeDialog();
        });
      }
    });

    final dash = ref.watch(dashboardProvider);
    final challengeStreak = ref.watch(streakProvider);

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

    if (!_tutorialTriggered) {
      _tutorialTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _maybStartTutorial();
      });
    }

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: SafeArea(
          child: RefreshIndicator(
            color: _kNeonMint,
            backgroundColor: _kDeepNavy,
            onRefresh: () async =>
                ref.read(authProvider.notifier).refreshUser(),
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const XpBoostBanner(),
                  const OfflineBanner(),
                  const FlashChallengeBanner(),
                  const HolidayEventBanner(),
                  Builder(builder: (ctx) {
                    final nw = ref.watch(netWorthProvider);
                    if (nw.netWorthZMW >= 0) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Net Worth: -ZMW ${nw.netWorthZMW.abs()}',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const Text(
                                  'Complete simulations and pay off loans to recover',
                                  style: TextStyle(
                                      color: Color(0xFFB0B8C1), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                ctx.push(AppRoutes.recoveryPlan),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Get Help',
                              style: TextStyle(
                                  color: Color(0xFF36ECDE), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  const SeasonProgressBar(),
                  const SizedBox(height: 16),
                  _buildHeaderWithHud(context, dash, challengeStreak),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildXpCard(context, dash),
                        const SizedBox(height: 16),
                        _buildLeagueCard(context, dash),
                        const SizedBox(height: 16),
                        _buildDailyChallengeCard(context),
                        const SizedBox(height: 16),
                        _buildBudgetCard(context, dash),
                        const SizedBox(height: 16),
                        _buildQuizCard(context),
                        const SizedBox(height: 16),
                        _buildStoryCard(context),
                        const SizedBox(height: 16),
                        _buildMentorTipCard(context),
                        const SizedBox(height: 16),
                        _buildDailyRoutineCard(context),
                        const SizedBox(height: 16),
                        _buildMyLifeSection(context),
                        const SizedBox(height: 16),
                        KeyedSubtree(
                          key: _myFinancesKey,
                          child: _buildMyFinancesSection(context),
                        ),
                        const SizedBox(height: 16),
                        _buildNewsTicker(context),
                        const SizedBox(height: 16),
                        _buildSeasonalCard(context),
                        const SizedBox(height: 16),
                        KeyedSubtree(
                          key: _spinWheelKey,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => context.push(AppRoutes.spin),
                              icon: const Text('🎡', style: TextStyle(fontSize: 18)),
                              label: const Text('Spin the Wheel'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kNeonMint.withValues(alpha: 0.10),
                                foregroundColor: _kNeonMint,
                                side: const BorderSide(color: _kNeonMint, width: 1.5),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor: _kNeonMint.withValues(alpha: 0.30),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push(AppRoutes.miniGames),
                            icon: const Text('🎮', style: TextStyle(fontSize: 18)),
                            label: const Text('Mini-Games'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _kPrimaryBlue.withValues(alpha: 0.10),
                              foregroundColor: _kPrimaryBlue,
                              side: const BorderSide(
                                  color: _kPrimaryBlue, width: 1.5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              shadowColor:
                                  _kPrimaryBlue.withValues(alpha: 0.30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLevelCTA(context, dash),
                        const SizedBox(height: 20),
                        _buildBadgesSection(context),
                        const SizedBox(height: 20),
                        _buildTipCard(context),
                        SizedBox(height: 32 + MediaQuery.of(context).padding.bottom),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
              ),
            ),
            const Positioned(
              bottom: 80,
              right: 16,
              child: ZamuCompanionWidget(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header + HUD overlap ─────────────────────────────────────────────────────

  Widget _buildHeaderWithHud(BuildContext context, DashboardState dash, int challengeStreak) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context, dash, challengeStreak),
        Transform.translate(
          offset: const Offset(0, -20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildHudBar(dash),
          ),
        ),
      ],
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, DashboardState dash, int challengeStreak) {
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(dash),
                const SizedBox(width: 10),
                Expanded(child: _buildWelcomeText(dash)),
                // Right-side pills capped so they never crowd the welcome text
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 190),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BoostTimerChip(),
                        const SizedBox(width: 6),
                        _buildStreakPill(challengeStreak),
                        const SizedBox(width: 6),
                        const WalletBadge(),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined,
                              color: _kSoftGray),
                          onPressed: () => context.push(AppRoutes.shop),
                          tooltip: 'Shop',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(DashboardState dash) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _kNeonMint, width: 2),
        boxShadow: [
          BoxShadow(
            color: _kNeonMint.withValues(alpha: 0.35),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: AvatarWidget(
        avatarId: dash.user.avatarId,
        size: 52,
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
            fontSize: 12,
            color: _kSoftGray,
            fontStyle: FontStyle.italic,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Text(
          dash.name,
          style: GoogleFonts.rajdhani(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildStreakPill(int challengeStreak) {
    final gs = ref.watch(globalStreakProvider);
    return AnimatedBuilder(
      animation: _streakScale,
      builder: (_, child) =>
          Transform.scale(scale: _streakScale.value, child: child),
      child: GestureDetector(
        onTap: () => _showStreakSheet(gs.streak, gs.shieldCount),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department,
                  color: _kNeonMint, size: 16),
              const SizedBox(width: 4),
              Text(
                '${gs.streak > 0 ? gs.streak : challengeStreak}',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (gs.shieldCount > 0) ...[
                const SizedBox(width: 6),
                const Icon(Icons.shield, color: _kNeonMint, size: 13),
                const SizedBox(width: 2),
                Text(
                  '${gs.shieldCount}',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kNeonMint,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showStreakSheet(int streak, int shields) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _StreakSheet(streak: streak, shields: shields),
    );
  }

  // ── HUD Stat Bar ─────────────────────────────────────────────────────────────

  Widget _buildHudBar(DashboardState dash) {
    final nw = ref.watch(netWorthProvider);
    final nwZMW = nw.netWorthZMW;
    final nwStr = nwZMW.abs() >= 1000000
        ? '${nwZMW < 0 ? '-' : ''}ZMW ${(nwZMW.abs() / 1000000).toStringAsFixed(1)}M'
        : nwZMW.abs() >= 1000
            ? '${nwZMW < 0 ? '-' : ''}ZMW ${(nwZMW.abs() / 1000).toStringAsFixed(0)}K'
            : '${nwZMW < 0 ? '-' : ''}ZMW ${nwZMW.abs()}';

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
            child: _AnimatedHudCounter(
              value: ref.watch(walletProvider),
              label: 'ZAMCOINS',
              cellBuilder: _hudCell,
            ),
          ),
          _hudDivider(),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.netWorth),
              child: _hudCell(value: nwStr, label: 'NET WORTH'),
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
            child: AnimatedBuilder(
              animation: Listenable.merge([_xpAnim, _xpGlowAnim]),
              builder: (_, __) {
                final g = _xpGlowAnim.value;
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: g > 0.01
                        ? [
                            BoxShadow(
                              color: const Color(0xFF36ECDE)
                                  .withValues(alpha: g * 0.85),
                              blurRadius: 22 * g,
                              spreadRadius: 3 * g,
                            ),
                            BoxShadow(
                              color: Colors.white
                                  .withValues(alpha: g * 0.35),
                              blurRadius: 10 * g,
                            ),
                          ]
                        : [],
                  ),
                  child: CustomPaint(
                    painter: _XpBarPainter(
                      progress: dash.progressPercent * _xpAnim.value,
                      glowIntensity: g,
                    ),
                    child: const SizedBox(
                        width: double.infinity, height: 16),
                  ),
                );
              },
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

  // ── League Card ──────────────────────────────────────────────────────────────

  static const _leagueTiers = [
    (name: 'Bronze', minXp: 0,    maxXp: 299,  color: Color(0xFFCD7F32), icon: FontAwesomeIcons.medal),
    (name: 'Silver', minXp: 300,  maxXp: 799,  color: Color(0xFFC0C0C0), icon: FontAwesomeIcons.medal),
    (name: 'Gold',   minXp: 800,  maxXp: 1999, color: Color(0xFFFFB703), icon: FontAwesomeIcons.trophy),
    (name: 'Sapphire', minXp: 2000, maxXp: 3999, color: Color(0xFF1A73E8), icon: FontAwesomeIcons.gem),
    (name: 'Diamond',  minXp: 4000, maxXp: 999999, color: Color(0xFF36ECDE), icon: FontAwesomeIcons.crown),
  ];

  Widget _buildLeagueCard(BuildContext context, DashboardState dash) {
    final xp = dash.xp;
    final tierIdx = _leagueTiers.indexWhere((t) => xp < t.maxXp);
    final idx = tierIdx < 0 ? _leagueTiers.length - 1 : tierIdx;
    final tier = _leagueTiers[idx];
    final nextIdx = idx < _leagueTiers.length - 1 ? idx + 1 : idx;
    final nextTier = _leagueTiers[nextIdx];

    final tierXp = xp - tier.minXp;
    final tierRange = tier.maxXp - tier.minXp;
    final progress = idx == _leagueTiers.length - 1
        ? 1.0
        : (tierXp / tierRange).clamp(0.0, 1.0);
    final xpToNext = idx == _leagueTiers.length - 1 ? 0 : (tier.maxXp - xp + 1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tier.color.withValues(alpha: 0.40), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: tier.color.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 3),
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
          Row(
            children: [
              // League icon in a glowing circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tier.color.withValues(alpha: 0.15),
                  border: Border.all(color: tier.color.withValues(alpha: 0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: tier.color.withValues(alpha: 0.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: FaIcon(tier.icon, color: tier.color, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEAGUE',
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: _kNeonMint,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '${tier.name} League',
                      style: GoogleFonts.rajdhani(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: tier.color,
                      ),
                    ),
                  ],
                ),
              ),
              // Tier badge row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_leagueTiers.length, (i) {
                  final active = i <= idx;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: FaIcon(
                      _leagueTiers[i].icon,
                      color: active
                          ? _leagueTiers[i].color
                          : _kSoftGray.withValues(alpha: 0.15),
                      size: 11,
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(tier.color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$xp XP',
                style: GoogleFonts.inter(fontSize: 11, color: _kSoftGray),
              ),
              if (idx < _leagueTiers.length - 1)
                Text(
                  '$xpToNext XP to ${nextTier.name}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: tier.color,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Text(
                  'Max League!',
                  style: GoogleFonts.inter(
                    fontSize: 11,
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

    return AnimatedBuilder(
      animation: _challengeGlow,
      builder: (_, child) {
        final g = completedToday ? 0.0 : _challengeGlow.value;
        return Container(
          decoration: BoxDecoration(
            color: _kDeepNavy,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color.lerp(
                Colors.white.withValues(alpha: 0.06),
                _kFreshGreen.withValues(alpha: 0.55),
                g,
              )!,
              width: 1.0 + g * 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _kFreshGreen.withValues(alpha: 0.04 + g * 0.16),
                blurRadius: 12 + g * 8,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child!,
        );
      },
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: Container(
              width: 3,
              decoration: const BoxDecoration(
                color: _kNeonMint,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
          Column(
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

          // ── Question preview ────────────────────────────────────────
          if (challenge != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2D40),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _kNeonMint.withValues(alpha: 0.20),
                  ),
                ),
                child: Text(
                  challenge.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _kSoftGray,
                    height: 1.45,
                  ),
                ),
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
                        Flexible(
                          child: Text(
                            'Challenge complete — come back tomorrow',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: _kFreshGreen,
                            ),
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
    final box = Hive.box(kSettingsBox);
    final raw = box.get('budget_alloc_$uid');
    final Map<String, double>? alloc = raw == null
        ? null
        : Map<String, double>.fromEntries(
            (raw as Map).entries.map(
              (e) => MapEntry(e.key as String, (e.value as num).toDouble()),
            ),
          );
    final rawIncome = box.get('budget_income_$uid');
    final double savedIncome =
        rawIncome != null ? (rawIncome as num).toDouble() : 3500.0;

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
                              : 'ZMW ${savedIncome.toStringAsFixed(0)} / month',
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
                  final zmw = (pct / 100) * savedIncome;
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

  // ── My Life Section ──────────────────────────────────────────────────────────

  Widget _buildMyLifeSection(BuildContext context) {
    final familyState  = ref.watch(familyProvider);
    final bizState     = ref.watch(businessProvider);
    final eventsState  = ref.watch(lifeEventsProvider);

    // Trigger the life event overlay once per day if a pending event exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (eventsState.pendingEvent != null && mounted) {
        context.push(AppRoutes.lifeEvent);
      }
    });

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
          // ── Header ────────────────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _myLifeExpanded = !_myLifeExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  const Text('🌍', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'MY LIFE',
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _kNeonMint,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _myLifeExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: _kNeonMint, size: 22),
                  ),
                ],
              ),
            ),
          ),

          if (_myLifeExpanded) ...[
            Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                children: [
                  // ── Family card ──────────────────────────────────────
                  _myLifeCard(
                    emoji: '👨‍👩‍👧',
                    label: 'FAMILY',
                    accentColor: const Color(0xFFFFB703),
                    title: familyState.hasFamily
                        ? 'The ${familyState.family!.spouseName.split(' ').last} Family'
                        : 'No family yet',
                    subtitle: familyState.hasFamily
                        ? 'Happiness ${familyState.family!.happinessScore}/100  ·  ${familyState.family!.housingName}'
                        : 'Tap to start your virtual family',
                    onTap: () => context.push(AppRoutes.family),
                  ),
                  const SizedBox(height: 8),

                  // ── Business card ────────────────────────────────────
                  _myLifeCard(
                    emoji: '🏢',
                    label: 'BUSINESS',
                    accentColor: _kFreshGreen,
                    title: bizState.hasBusiness
                        ? bizState.business!.businessName
                        : 'No business yet',
                    subtitle: bizState.hasBusiness
                        ? '${bizState.business!.stageName}  ·  ZMW ${bizState.business!.weeklyProfit}/week profit'
                        : 'Tap to launch your virtual business',
                    onTap: () => context.push(AppRoutes.business),
                  ),
                  const SizedBox(height: 8),

                  // ── Last life event card ─────────────────────────────
                  _myLifeCard(
                    emoji: eventsState.lastEvent?.emoji ?? '⚡',
                    label: 'LAST LIFE EVENT',
                    accentColor: const Color(0xFF9C6FDE),
                    title: eventsState.lastEvent?.title ?? 'No events yet',
                    subtitle: eventsState.lastEvent != null
                        ? 'Events challenge your financial decisions daily'
                        : 'Life events trigger daily — stay prepared!',
                    onTap: eventsState.pendingEvent != null
                        ? () => context.push(AppRoutes.lifeEvent)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _myLifeCard({
    required String emoji,
    required String label,
    required Color accentColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: accentColor.withValues(alpha: 0.30)),
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
                    label,
                    style: GoogleFonts.orbitron(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _kSoftGray.withValues(alpha: 0.60),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: accentColor.withValues(alpha: 0.60), size: 18),
          ],
        ),
      ),
    );
  }

  // ── My Finances Section ───────────────────────────────────────────────────────

  Widget _buildMyFinancesSection(BuildContext context) {
    final propState    = ref.watch(propertyProvider);
    final portState    = ref.watch(portfolioProvider);
    final loansState   = ref.watch(loansProvider);
    final savState     = ref.watch(savingsProvider);
    final healthState  = ref.watch(healthProvider);
    final healthScore  = healthState.data?.totalScore ?? 0;

    final prop    = propState.property;
    final port    = portState.portfolio;
    final loans   = loansState.record;
    final savings = savState.record;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          GestureDetector(
            onTap: () =>
                setState(() => _myFinancesExpanded = !_myFinancesExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  const Text('💰',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'MY FINANCES',
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFB703),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.health),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: HealthMiniGauge(score: healthScore, size: 28),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _myFinancesExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFFFFB703), size: 22),
                  ),
                ],
              ),
            ),
          ),

          if (_myFinancesExpanded) ...[
            Container(
                height: 1, color: Colors.white.withValues(alpha: 0.06)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                children: [
                  // ── Property card ─────────────────────────────────
                  _myLifeCard(
                    emoji: prop != null
                        ? PropertyModel.tierEmojis[prop.tier]
                        : '🏗️',
                    label: 'PROPERTY',
                    accentColor: const Color(0xFFE76F51),
                    title: prop != null
                        ? PropertyModel.tierNames[prop.tier]
                        : 'No property yet',
                    subtitle: prop != null
                        ? 'ZMW ${(prop.currentValueZMW / 1000).toStringAsFixed(0)}K  •  ${prop.hasMortgage ? "${prop.mortgageMonthsRemaining}m left" : "paid off"}'
                        : 'Tap to start the ladder',
                    onTap: () => context.push(AppRoutes.property),
                  ),
                  const SizedBox(height: 8),

                  // ── Portfolio card ────────────────────────────────
                  _myLifeCard(
                    emoji: '📊',
                    label: 'PORTFOLIO',
                    accentColor: const Color(0xFFFFB703),
                    title: port != null && port.totalValueZamCoins > 0
                        ? '${port.totalValueZamCoins} ZC total'
                        : 'No investments yet',
                    subtitle: port != null && port.totalValueZamCoins > 0
                        ? '${port.returnsPercent >= 0 ? '+' : ''}${port.returnsPercent.toStringAsFixed(1)}% returns'
                        : 'Invest in LUSE, bonds & more',
                    onTap: () => context.push(AppRoutes.portfolio),
                  ),
                  const SizedBox(height: 8),

                  // ── Loans card ────────────────────────────────────
                  _myLifeCard(
                    emoji: '🏦',
                    label: 'LOANS & DEBT',
                    accentColor: const Color(0xFF0077B6),
                    title: loans != null
                        ? 'Credit: ${loans.creditScore} / 850'
                        : 'No loan record',
                    subtitle: loans != null
                        ? '${loans.loans.where((l) => !l.isPaidOff).length} active loan(s)  •  ${loans.totalMonthlyPayments} ZC/month'
                        : 'Tap to manage loans',
                    onTap: () => context.push(AppRoutes.loans),
                  ),
                  const SizedBox(height: 8),

                  // ── Savings card ──────────────────────────────────
                  _myLifeCard(
                    emoji: '🎯',
                    label: 'SAVINGS GOALS',
                    accentColor: _kFreshGreen,
                    title: savings != null && savings.goals.isNotEmpty
                        ? '${savings.totalSavedZamCoins} ZC saved'
                        : 'No goals yet',
                    subtitle: savings != null && savings.goals.isNotEmpty
                        ? '${savings.goals.length} goal(s)  •  ${savings.completedGoals} completed'
                        : 'Set a goal and start saving',
                    onTap: () => context.push(AppRoutes.savings),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── News Ticker ──────────────────────────────────────────────────────────────

  Widget _buildNewsTicker(BuildContext context) {
    final headlines = ref.watch(currentHeadlinesProvider);
    if (headlines.isEmpty) return const SizedBox.shrink();
    final h = headlines.first;
    return GestureDetector(
      onTap: () => context.push(AppRoutes.news),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Text('📰', style: TextStyle(fontSize: 15)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _kNeonMint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'NEWS',
                style: TextStyle(
                    color: _kNeonMint,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${h.emoji}  ${h.title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: _kSoftGray.withValues(alpha: 0.8), fontSize: 12),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 16),
          ],
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

  // ── Badges Earned Nav Row ────────────────────────────────────────────────────
  // Compact summary row mirroring the My Badges row on the Profile screen.
  // Reads from badgeMapProvider so the earned/total figures match Profile exactly.

  Widget _buildBadgesSection(BuildContext context) {
    final badgeMap = ref.watch(badgeMapProvider);
    final earnedCount = badgeMap.values.where((v) => v).length;
    final totalCount = badgeMap.length;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.badges),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _kDeepNavy,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
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
            const Icon(Icons.military_tech, color: _kNeonMint, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Badges Earned',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: _kSoftGray,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _kNeonMint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: _kNeonMint.withValues(alpha: 0.4)),
              ),
              child: Text(
                '$earnedCount/$totalCount',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _kNeonMint,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: _kNeonMint, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Mentor Tip Card ───────────────────────────────────────────────────────────

  Widget _buildMentorTipCard(BuildContext context) {
    final state  = ref.watch(mentorProvider);
    final mentor = state.featuredMentor;
    if (mentor == null) return const SizedBox.shrink();
    final tip = state.dailyTipFor(mentor.id);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.mentors),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kDeepNavy,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.35)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mentor.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MENTOR TIP — ${mentor.name.toUpperCase()}',
                    style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFD700), letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 6),
                  Text(tip, style: GoogleFonts.inter(fontSize: 13, color: _kSoftGray, height: 1.5)),
                  const SizedBox(height: 8),
                  Text('Tap to see all mentors →',
                      style: GoogleFonts.inter(fontSize: 11, color: _kNeonMint)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Daily Routine Card ────────────────────────────────────────────────────────

  Widget _buildDailyRoutineCard(BuildContext context) {
    final state = ref.watch(dailyRoutineProvider);
    final done  = state.completedCount;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.dailyRoutine),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kDeepNavy,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kNeonMint.withValues(alpha: 0.30)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📅', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text('DAILY ROUTINE',
                    style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.w700,
                        color: _kNeonMint, letterSpacing: 1.2)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kNeonMint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$done/3 done',
                      style: GoogleFonts.inter(fontSize: 11, color: _kNeonMint, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              state.isLoading ? 'Loading...' : state.todaysMorningTip,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 13, color: _kSoftGray, height: 1.5),
            ),
            const SizedBox(height: 8),
            Text('Tap to continue your routine →',
                style: GoogleFonts.inter(fontSize: 11, color: _kNeonMint)),
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
  const _XpBarPainter({required this.progress, this.glowIntensity = 0.0});

  final double progress;
  final double glowIntensity;

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

      // In-bar white flash overlay when XP is gained
      if (glowIntensity > 0) {
        canvas.drawRRect(
          RRect.fromLTRBR(0, 0, fillW, h, radius),
          Paint()
            ..color = Colors.white.withValues(alpha: glowIntensity * 0.55)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _XpBarPainter old) =>
      old.progress != progress || old.glowIntensity != glowIntensity;
}

// ─────────────────────────────────────────────────────────────────────────────
// Day-of-year extension
// ─────────────────────────────────────────────────────────────────────────────

extension on DateTime {
  int get _dayOfYear => difference(DateTime(year, 1, 1)).inDays;
}

// ─────────────────────────────────────────────────────────────────────────────
// Streak bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _StreakSheet extends StatelessWidget {
  const _StreakSheet({required this.streak, required this.shields});
  final int streak;
  final int shields;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0D1B2A);
    const mint = Color(0xFF36ECDE);
    const gold = Color(0xFFFFB703);

    // Build 7-day dot row: last `min(streak, 7)` dots active
    final activeDots = streak.clamp(0, 7);
    final today = DateTime.now();
    final dayNames = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][d.weekday % 7];
    });

    return Container(
      decoration: const BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.paddingOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Icon(Icons.local_fire_department, color: mint, size: 36),
          const SizedBox(height: 8),
          Text(
            '$streak-Day Streak',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            streak == 0
                ? 'Complete a quiz to start your streak!'
                : 'Keep it going — learn every day!',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // 7-day calendar dots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final active = i >= (7 - activeDots);
              final isToday = i == 6;
              return Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? (isToday ? mint : mint.withValues(alpha: 0.55))
                          : Colors.white.withValues(alpha: 0.08),
                      border: isToday
                          ? Border.all(color: mint, width: 2)
                          : null,
                    ),
                    child: active
                        ? const Icon(Icons.check,
                            color: Color(0xFF0D1B2A), size: 16)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(dayNames[i],
                      style: TextStyle(
                          color: active ? Colors.white : Colors.white38,
                          fontSize: 11)),
                ],
              );
            }),
          ),
          if (shields > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gold.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield, color: gold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$shields streak shield${shields > 1 ? 's' : ''} active',
                    style: const TextStyle(
                        color: gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// HUD counter that animates the integer transitioning from the previous
/// value to the new value over 600ms (Curves.easeOutCubic). Avoids the
/// "snap to 0 then count up" jank caused by `IntTween(begin: 0, end: x)`
/// in TweenAnimationBuilder on every rebuild.
class _AnimatedHudCounter extends StatefulWidget {
  const _AnimatedHudCounter({
    required this.value,
    required this.label,
    required this.cellBuilder,
  });

  final int value;
  final String label;
  final Widget Function({required String value, required String label})
      cellBuilder;

  @override
  State<_AnimatedHudCounter> createState() => _AnimatedHudCounterState();
}

class _AnimatedHudCounterState extends State<_AnimatedHudCounter> {
  late int _previous;

  @override
  void initState() {
    super.initState();
    _previous = widget.value;
  }

  @override
  void didUpdateWidget(_AnimatedHudCounter old) {
    super.didUpdateWidget(old);
    _previous = old.value;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: _previous.toDouble(),
        end: widget.value.toDouble(),
      ),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) =>
          widget.cellBuilder(value: '${v.round()}', label: widget.label),
    );
  }
}
