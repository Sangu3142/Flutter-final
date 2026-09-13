library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/story/providers/story_provider.dart';
import 'package:zamwealth_quest/features/wallet/providers/wallet_provider.dart';
import 'package:zamwealth_quest/shared/widgets/animated_gradient_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────

const Color _kDeepNavy   = Color(0xFF0D1B2A);
const Color _kNeonMint   = Color(0xFF36ECDE);
const Color _kFreshGreen  = Color(0xFF2BC48A);
const Color _kGold        = Color(0xFFFFB703);
const Color _kSoftGray    = Color(0xFFE6E9EC);

// ─────────────────────────────────────────────────────────────────────────────
// StoryMapScreen
// ─────────────────────────────────────────────────────────────────────────────

class StoryMapScreen extends ConsumerWidget {
  const StoryMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyState = ref.watch(storyProvider);
    final user = ref.watch(currentUserProvider);
    final userXp = user?.xp ?? 0;
    // Read walletBalance via walletProvider so it stays in sync with the home
    // screen badge and every other coin display in the app.
    final userCoins = ref.watch(walletProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, userXp, userCoins),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  itemCount: kStoryChapters.length,
                  itemBuilder: (context, index) {
                    final chapter = kStoryChapters[index];
                    final isLast = index == kStoryChapters.length - 1;
                    final unlocked = storyState.isUnlocked(chapter.chapterId);
                    final hasChoice = storyState.hasChoice(chapter.chapterId);
                    final canAfford = chapter.zamCoinCost == 0 ||
                        (userXp >= chapter.xpCost &&
                            userCoins >= chapter.zamCoinCost);

                    return Column(
                      children: [
                        _buildChapterRow(
                          context: context,
                          chapter: chapter,
                          unlocked: unlocked,
                          hasChoice: hasChoice,
                          canAfford: canAfford,
                        ),
                        if (!isLast) _buildConnector(unlocked),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, int xp, int coins) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE KWACHA CHRONICLES',
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kSoftGray,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  "Mwansa's entrepreneurial journey",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _kSoftGray.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '⚡ $xp XP',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _kNeonMint,
                ),
              ),
              Text(
                '🪙 $coins',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _kGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Chapter Row ────────────────────────────────────────────────────────────

  Widget _buildChapterRow({
    required BuildContext context,
    required StoryChapterData chapter,
    required bool unlocked,
    required bool hasChoice,
    required bool canAfford,
  }) {
    final numberColor = hasChoice
        ? _kFreshGreen
        : unlocked
            ? _kNeonMint
            : _kSoftGray.withValues(alpha: 0.35);

    return GestureDetector(
      onTap: () => context.push('/story/chapter/${chapter.chapterId}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _kDeepNavy.withValues(alpha: unlocked ? 1.0 : 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasChoice
                ? _kFreshGreen.withValues(alpha: 0.45)
                : unlocked
                    ? _kNeonMint.withValues(alpha: 0.30)
                    : Colors.white.withValues(alpha: 0.06),
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: _kNeonMint.withValues(alpha: 0.07),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Chapter number circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kDeepNavy,
                border: Border.all(color: numberColor, width: 2),
              ),
              child: Center(
                child: hasChoice
                    ? const Icon(Icons.check, color: _kFreshGreen, size: 18)
                    : unlocked
                        ? Text(
                            '${chapter.chapterId}',
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _kNeonMint,
                            ),
                          )
                        : Icon(
                            Icons.lock_outline,
                            color: _kSoftGray.withValues(alpha: 0.40),
                            size: 18,
                          ),
              ),
            ),
            const SizedBox(width: 14),

            // Title + cost
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ch ${chapter.chapterId}: ${chapter.title}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: unlocked ? Colors.white : _kSoftGray.withValues(alpha: 0.45),
                    ),
                  ),
                  if (!unlocked && chapter.zamCoinCost > 0) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (chapter.xpCost > 0) ...[
                          Text(
                            '⚡ ${chapter.xpCost} XP req',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: canAfford
                                  ? _kNeonMint
                                  : const Color(0xFFE53935),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          '🪙 ${chapter.zamCoinCost}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: canAfford ? _kGold : const Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ),
                  ] else if (chapter.zamCoinCost == 0 && !unlocked) ...[
                    const SizedBox(height: 3),
                    Text(
                      'FREE',
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kFreshGreen,
                      ),
                    ),
                  ],
                  if (hasChoice) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Choice recorded ✓',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: _kFreshGreen),
                    ),
                  ],
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: unlocked
                  ? _kNeonMint
                  : _kSoftGray.withValues(alpha: 0.25),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Connector ──────────────────────────────────────────────────────────────

  Widget _buildConnector(bool unlocked) {
    return SizedBox(
      height: 20,
      child: Center(
        child: Container(
          width: 2,
          height: 20,
          color: unlocked
              ? _kNeonMint.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}
