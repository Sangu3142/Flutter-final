/// level_map_screen.dart
/// Purpose: Vertical level map — premium dark fintech game aesthetic. Shows
///          4 level cards with connecting dashed lines, a HUD header banner,
///          and unlocked/locked state styling.
/// Reads from: levelProvider, authProvider
/// Writes to: nothing (navigation triggers state changes elsewhere)
/// Navigation: → /levels/:levelId (unlocked), → /payment/:levelId (locked)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/levels/providers/level_provider.dart';
import 'package:zamwealth_quest/features/levels/models/level_model.dart';
import 'package:zamwealth_quest/shared/widgets/animated_gradient_background.dart';
import 'package:zamwealth_quest/shared/widgets/offline_banner.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette constants
// ─────────────────────────────────────────────────────────────────────────────

const Color _kDeepNavy = Color(0xFF0D1B2A);
const Color _kPrimaryBlue = Color(0xFF1A73E8);
const Color _kNeonMint = Color(0xFF36ECDE);
const Color _kFreshGreen = Color(0xFF2BC48A);
const Color _kSoftGray = Color(0xFFE6E9EC);

// ─────────────────────────────────────────────────────────────────────────────
// LevelMapScreen
// ─────────────────────────────────────────────────────────────────────────────

class LevelMapScreen extends ConsumerWidget {
  const LevelMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelState = ref.watch(levelProvider);
    final user = ref.watch(currentUserProvider);
    final totalXp = user?.xp ?? 0;

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OfflineBanner(),

                // ── HUD header banner ──────────────────────────────────────
                _buildHudBanner(context, totalXp),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Section heading ──────────────────────────────────
                      Text(
                        'Your Journey',
                        style: GoogleFonts.rajdhani(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Neon Mint underline rule
                      Container(
                        width: 40,
                        height: 2,
                        decoration: BoxDecoration(
                          color: _kNeonMint,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap a level to enter. Locked levels require unlocking.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _kSoftGray,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Level cards with connectors ──────────────────────
                      ...List.generate(4, (index) {
                        final levelId = index + 1;
                        final meta = kLevelMeta[levelId]!;
                        final model = levelState.levels[levelId];
                        final isLocked = model?.isLocked ?? true;
                        final isCompleted = model?.isCompleted ?? false;

                        return Column(
                          children: [
                            _buildLevelCard(
                              context: context,
                              levelId: levelId,
                              meta: meta,
                              model: model,
                              isLocked: isLocked,
                              isCompleted: isCompleted,
                              onTap: () =>
                                  _handleNodeTap(context, levelId, model),
                            ),
                            if (levelId < 4)
                              _buildConnector(isCompleted: isCompleted),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HUD Banner ───────────────────────────────────────────────────────────────

  Widget _buildHudBanner(BuildContext context, int totalXp) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: _kDeepNavy,
        border: Border(
          left: const BorderSide(color: _kNeonMint, width: 4),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'ZamWealth\nAdventure Map',
                style: GoogleFonts.rajdhani(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.bolt, color: _kNeonMint, size: 22),
                const SizedBox(width: 4),
                Text(
                  '$totalXp XP',
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _kNeonMint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Level Card ───────────────────────────────────────────────────────────────

  Widget _buildLevelCard({
    required BuildContext context,
    required int levelId,
    required LevelMeta meta,
    required LevelModel? model,
    required bool isLocked,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    final double cardOpacity = isLocked ? 0.6 : 1.0;
    final Color borderColor = isLocked
        ? Colors.white.withValues(alpha: 0.08)
        : _kNeonMint;
    final double borderWidth = isLocked ? 1.0 : 1.5;

    return Opacity(
      opacity: cardOpacity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kDeepNavy,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              if (!isLocked)
                BoxShadow(
                  color: _kNeonMint.withValues(alpha: 0.20),
                  blurRadius: 12,
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
              // Icon circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _kDeepNavy,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLocked
                        ? Colors.white.withValues(alpha: 0.20)
                        : _kNeonMint,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isLocked
                      ? const Icon(Icons.lock_outline,
                          color: _kSoftGray, size: 22)
                      : isCompleted
                          ? const Icon(Icons.check_circle,
                              color: _kFreshGreen, size: 26)
                          : Text(
                              '$levelId',
                              style: GoogleFonts.orbitron(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _kNeonMint,
                              ),
                            ),
                ),
              ),

              const SizedBox(width: 14),

              // Level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.name,
                      style: GoogleFonts.rajdhani(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isLocked ? _kSoftGray : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _kSoftGray,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Pill badges row
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Price / FREE pill
                        _pill(
                          label: meta.isFree
                              ? 'FREE'
                              : 'ZMW ${_levelPrice(levelId).toStringAsFixed(0)}',
                          bgColor: meta.isFree
                              ? _kFreshGreen
                              : _kPrimaryBlue,
                          textColor: Colors.white,
                        ),
                        // XP pill
                        _pill(
                          label: '⚡ ${meta.xpReward} XP',
                          bgColor: _kDeepNavy,
                          textColor: _kNeonMint,
                          border: _kNeonMint.withValues(alpha: 0.4),
                        ),
                        // Simulations count pill
                        _pill(
                          label: '${meta.simulations.length} Sims',
                          bgColor: _kSoftGray.withValues(alpha: 0.15),
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(
                isLocked ? Icons.lock_outline : Icons.chevron_right,
                color: isLocked ? _kSoftGray : _kNeonMint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill({
    required String label,
    required Color bgColor,
    required Color textColor,
    Color? border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: border != null ? Border.all(color: border, width: 1) : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.rajdhani(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ── Dashed connector between level cards ──────────────────────────────────────

  Widget _buildConnector({required bool isCompleted}) {
    return SizedBox(
      height: 32,
      child: Center(
        child: CustomPaint(
          size: const Size(2, 32),
          painter: _DashedLinePainter(
            color: _kNeonMint.withValues(alpha: isCompleted ? 0.7 : 0.4),
          ),
        ),
      ),
    );
  }

  // ── Navigation ───────────────────────────────────────────────────────────────

  void _handleNodeTap(BuildContext context, int levelId, LevelModel? model) {
    if (model == null) return;
    if (model.isLocked) {
      context.push('/payment/$levelId');
    } else {
      context.push('/levels/$levelId');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  double _levelPrice(int levelId) {
    return switch (levelId) {
      1 => kLevel1Price,
      2 => kLevel2Price,
      3 => kLevel3Price,
      4 => kLevel4Price,
      _ => 0.0,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashed Line Painter
// ─────────────────────────────────────────────────────────────────────────────

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const dashHeight = 6.0;
    const gapHeight = 4.0;
    final cx = size.width / 2;
    double y = 0;

    while (y < size.height) {
      final end = (y + dashHeight).clamp(0.0, size.height);
      canvas.drawLine(Offset(cx, y), Offset(cx, end), paint);
      y += dashHeight + gapHeight;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) =>
      old.color != color;
}
