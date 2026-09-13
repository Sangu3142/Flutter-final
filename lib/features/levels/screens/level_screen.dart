/// level_screen.dart
/// Purpose: Level detail screen — premium dark fintech game aesthetic. Shows
///          the landscape header, status badge, segmented progress bar,
///          business showcase, and staggered simulation cards.
/// Reads from: levelProvider, singleLevelProvider, authProvider
/// Writes to: levelProvider (marks simulations complete via callbacks)
/// Navigation: ← back (pop), opens simulations as bottom sheets
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/levels/models/level_model.dart';
import 'package:zamwealth_quest/features/levels/providers/level_provider.dart';
import 'package:zamwealth_quest/features/levels/simulations/budget_simulation.dart';
import 'package:zamwealth_quest/features/levels/simulations/savings_simulation.dart';
import 'package:zamwealth_quest/features/levels/simulations/investment_simulation.dart';
import 'package:zamwealth_quest/features/levels/simulations/debt_simulation.dart';
import 'package:zamwealth_quest/features/levels/simulations/business_simulation.dart';
import 'package:zamwealth_quest/features/levels/simulations/quiz_challenge_simulation.dart';
import 'package:zamwealth_quest/shared/painters/dot_grid_painter.dart';
import 'package:zamwealth_quest/shared/painters/landscape_painter.dart';
import 'package:zamwealth_quest/shared/painters/segmented_progress_painter.dart';
import 'package:zamwealth_quest/shared/painters/shop_front_painter.dart';
import 'package:zamwealth_quest/shared/widgets/animated_gradient_background.dart';
import 'package:zamwealth_quest/shared/widgets/sim_card.dart';

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
// LevelScreen
// ─────────────────────────────────────────────────────────────────────────────

class LevelScreen extends ConsumerStatefulWidget {
  const LevelScreen({super.key, required this.levelId});

  final int levelId;

  @override
  ConsumerState<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends ConsumerState<LevelScreen>
    with TickerProviderStateMixin {
  // One controller per simulation card for staggered fade + slide entrance
  final List<AnimationController> _simControllers = [];
  final List<Animation<double>> _simFades = [];
  final List<Animation<Offset>> _simSlides = [];

  @override
  void initState() {
    super.initState();
    final meta = kLevelMeta[widget.levelId];
    if (meta != null) {
      _initSimAnimations(meta.simulations.length);
    }
  }

  void _initSimAnimations(int count) {
    for (int i = 0; i < count; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
      _simControllers.add(ctrl);
      _simFades.add(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
      _simSlides.add(
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(parent: ctrl, curve: Curves.easeOut),
        ),
      );
    }

    // Wait until after the first frame so the FadeTransition widgets are
    // guaranteed to be in the tree before forward() is called.  Without this
    // the Future.delayed could fire while only the loading indicator was
    // mounted, advancing controllers to 1.0 before the cards existed, then
    // when the model loaded the race meant cards stayed at opacity-0.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _simControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 100), () {
          if (mounted) _simControllers[i].forward();
        });
      }
    });
  }

  @override
  void dispose() {
    for (final c in _simControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(singleLevelProvider(widget.levelId));
    final meta = kLevelMeta[widget.levelId];

    if (meta == null || model == null) {
      return const AnimatedGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(color: _kNeonMint),
          ),
        ),
      );
    }

    final totalSims = meta.simulations.length;
    final doneSims = model.completedSimulations.length;

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomPaint(
          painter: DotGridPainter(
            color: Colors.white.withValues(alpha: 0.03),
          ),
          child: Stack(
            children: [
              // Scrollable content
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildLandscapeHeader(context, meta, model),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildProgressCard(context, model, doneSims,
                            totalSims, meta),
                        const SizedBox(height: 20),
                        _buildBusinesses(context, meta),
                        const SizedBox(height: 20),

                        Text(
                          'Simulations',
                          style: GoogleFonts.rajdhani(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Neon Mint underline rule
                        Container(
                          width: 40,
                          height: 2,
                          decoration: BoxDecoration(
                            color: _kNeonMint,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Complete all simulations to earn ${meta.xpReward} XP',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _kSoftGray,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Staggered simulation cards
                        ...meta.simulations.asMap().entries.map((entry) {
                          final index = entry.key;
                          final simId = entry.value;
                          final isDone = model.hasCompletedSim(simId);
                          return _buildLevelSimCard(
                              context, simId, isDone, index);
                        }),

                        if (model.isCompleted)
                          _buildCompletionBanner(context, meta),

                        if (model.status == kStatusCompleted) ...[
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => context.go('/levels/${widget.levelId}/boss'),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1A0A2E), Color(0xFF2D1B69)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Text('⚔️', style: TextStyle(fontSize: 36)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Boss Challenge',
                                          style: TextStyle(
                                            color: Color(0xFFFFD700),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          kBossConfigs
                                              .firstWhere((c) => c.levelId == widget.levelId,
                                                  orElse: () => kBossConfigs.first)
                                              .name,
                                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Color(0xFFFFD700)),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              ),

              // Floating back button — fixed over the header
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                child: _buildFloatingBackButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Landscape Header ─────────────────────────────────────────────────────────

  Widget _buildLandscapeHeader(
      BuildContext context, LevelMeta meta, LevelModel model) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kPrimaryBlue, _kCoreNavy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Savanna landscape — blue and mint tones
          const Positioned.fill(
            child: CustomPaint(
              painter: LandscapePainter(),
            ),
          ),

          // Level name and status badge — anchored to bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusBadge(model),
                const SizedBox(height: 8),
                Text(
                  meta.name,
                  style: GoogleFonts.rajdhani(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.40),
                        offset: const Offset(2, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                Text(
                  meta.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _kSoftGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Badge ─────────────────────────────────────────────────────────────

  Widget _buildStatusBadge(LevelModel model) {
    final (label, icon, bgColor) = switch (model.status) {
      kStatusCompleted => ('Completed', Icons.check_circle, _kFreshGreen),
      kStatusInProgress => ('In Progress', Icons.bolt, _kNeonMint),
      _ => (
          'Unlocked',
          Icons.lock_open,
          Colors.white.withValues(alpha: 0.25)
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Floating Back Button ──────────────────────────────────────────────────────

  Widget _buildFloatingBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _kDeepNavy.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          border: Border.all(color: _kNeonMint.withValues(alpha: 0.45), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.40),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          size: 16,
          color: _kNeonMint,
        ),
      ),
    );
  }

  // ── Progress Card ─────────────────────────────────────────────────────────────

  Widget _buildProgressCard(
    BuildContext context,
    LevelModel model,
    int done,
    int total,
    LevelMeta meta,
  ) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level Progress',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '$done/$total',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  color: _kNeonMint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Segmented progress bar — Fresh Green fill, white 0.1 empty
          SizedBox(
            height: 20,
            child: CustomPaint(
              painter: SegmentedProgressPainter(
                completedSegments: done,
                totalSegments: total,
              ),
              child: const SizedBox(width: double.infinity, height: 20),
            ),
          ),

          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${meta.xpReward} XP',
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    color: model.isCompleted ? _kFreshGreen : _kNeonMint,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: model.isCompleted ? ' earned!' : ' on completion',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: model.isCompleted ? _kFreshGreen : _kSoftGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Business Showcase ─────────────────────────────────────────────────────────

  Widget _buildBusinesses(BuildContext context, LevelMeta meta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Businesses',
          style: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: meta.businesses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) =>
                _buildBusinessCard(meta.businesses[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessCard(String name) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CustomPaint(
              painter: ShopFrontPainter(),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: _kSoftGray,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Simulation Card ───────────────────────────────────────────────────────────

  Widget _buildLevelSimCard(
    BuildContext context,
    String simId,
    bool isDone,
    int index,
  ) {
    final fade = index < _simFades.length
        ? _simFades[index]
        : const AlwaysStoppedAnimation<double>(1.0);
    final slide = index < _simSlides.length
        ? _simSlides[index]
        : const AlwaysStoppedAnimation<Offset>(Offset.zero);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SimCard(
            simulationId: simId,
            isCompleted: isDone,
            onTap: () => _openSimulation(context, simId, widget.levelId, isDone),
          ),
        ),
      ),
    );
  }

  // ── Completion Banner ─────────────────────────────────────────────────────────

  Widget _buildCompletionBanner(BuildContext context, LevelMeta meta) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kFreshGreen.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: _kFreshGreen.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _kFreshGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events,
                color: _kFreshGreen, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level Complete!',
                  style: GoogleFonts.rajdhani(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'You earned ${meta.xpReward} XP and a badge!',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _kSoftGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Open Simulation ───────────────────────────────────────────────────────────

  void _openSimulation(
    BuildContext context,
    String simId,
    int levelId,
    bool isAlreadyDone,
  ) {
    final simWidget = _buildSimulationWidget(
      simId: simId,
      levelId: levelId,
      onComplete: () async {
        await ref
            .read(levelProvider.notifier)
            .markSimulationComplete(levelId, simId, context: context);
        if (context.mounted) Navigator.of(context).pop();
      },
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _kDeepNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => simWidget,
    );
  }

  Widget _buildSimulationWidget({
    required String simId,
    required int levelId,
    required VoidCallback onComplete,
  }) {
    return switch (simId) {
      kSimBudget => BudgetSimulation(onComplete: onComplete),
      kSimEmergencyFund => SavingsSimulation(
          mode: SavingsMode.emergencyFund,
          onComplete: onComplete,
        ),
      kSimMobileMoneyFee => SavingsSimulation(
          mode: SavingsMode.mobileMoneyFee,
          onComplete: onComplete,
        ),
      kSimDebt => DebtSimulation(onComplete: onComplete),
      kSimSavingsGoal => SavingsSimulation(
          mode: SavingsMode.savingsGoal,
          onComplete: onComplete,
        ),
      kSimInflation => SavingsSimulation(
          mode: SavingsMode.inflation,
          onComplete: onComplete,
        ),
      kSimInvestment => InvestmentSimulation(
          mode: InvestmentMode.riskReward,
          onComplete: onComplete,
        ),
      kSimCompoundGrowth => InvestmentSimulation(
          mode: InvestmentMode.compoundGrowth,
          onComplete: onComplete,
        ),
      kSimPortfolio => InvestmentSimulation(
          mode: InvestmentMode.portfolio,
          onComplete: onComplete,
        ),
      kSimPacra => BusinessSimulation(
          mode: BusinessMode.pacra,
          onComplete: onComplete,
        ),
      kSimRevenue => BusinessSimulation(
          mode: BusinessMode.revenue,
          onComplete: onComplete,
        ),
      kSimPayroll => BusinessSimulation(
          mode: BusinessMode.payroll,
          onComplete: onComplete,
        ),
      kSimTax => BusinessSimulation(
          mode: BusinessMode.taxQuiz,
          onComplete: onComplete,
        ),
      kSimQuizChallenge => QuizChallengeSimulation(onComplete: onComplete),
      _ => _FallbackSim(simId: simId, onComplete: onComplete),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fallback Simulation
// ─────────────────────────────────────────────────────────────────────────────

class _FallbackSim extends StatelessWidget {
  const _FallbackSim({required this.simId, required this.onComplete});

  final String simId;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _kDeepNavy,
              shape: BoxShape.circle,
              border: Border.all(color: _kNeonMint.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.settings, color: _kNeonMint, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            'Simulation: $simId',
            style: GoogleFonts.rajdhani(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onComplete,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: _kPrimaryBlue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _kPrimaryBlue.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Mark Complete',
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
