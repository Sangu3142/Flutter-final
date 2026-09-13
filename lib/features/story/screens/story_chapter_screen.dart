library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/wallet/providers/wallet_provider.dart';
import 'package:zamwealth_quest/features/story/models/dialogue_moment.dart';
import 'package:zamwealth_quest/features/story/providers/story_provider.dart';
import 'package:zamwealth_quest/features/story/widgets/dialogue_choice_card.dart';
import 'package:zamwealth_quest/shared/painters/story/building_painter.dart';
import 'package:zamwealth_quest/shared/painters/story/certificate_painter.dart';
import 'package:zamwealth_quest/shared/painters/story/coins_painter.dart';
import 'package:zamwealth_quest/shared/painters/story/market_stall_painter.dart';
import 'package:zamwealth_quest/shared/painters/story/supplier_painter.dart';
import 'package:zamwealth_quest/shared/widgets/animated_gradient_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────

const Color _kDeepNavy   = Color(0xFF0D1B2A);
const Color _kCoreNavy   = Color(0xFF00203F);
const Color _kNeonMint   = Color(0xFF36ECDE);
const Color _kFreshGreen = Color(0xFF2BC48A);
const Color _kGold       = Color(0xFFFFB703);
const Color _kSoftGray   = Color(0xFFE6E9EC);

// ─────────────────────────────────────────────────────────────────────────────
// Dialogue moment mapping: chapter key → ordered list of moment IDs
// ─────────────────────────────────────────────────────────────────────────────

const kChapterDialogueMoments = <String, List<String>>{
  'chapter_1': ['ch1_m1', 'ch1_m2', 'ch1_m3'],
  'chapter_2': ['ch2_m1', 'ch2_m2', 'ch2_m3'],
  'chapter_3': ['ch3_m1', 'ch3_m2', 'ch3_m3'],
  'chapter_4': ['ch4_m1', 'ch4_m2', 'ch4_m3'],
};

// ─────────────────────────────────────────────────────────────────────────────
// StoryChapterScreen
// ─────────────────────────────────────────────────────────────────────────────

class StoryChapterScreen extends ConsumerStatefulWidget {
  const StoryChapterScreen({super.key, required this.chapterId});

  final int chapterId;

  @override
  ConsumerState<StoryChapterScreen> createState() => _StoryChapterScreenState();
}

class _StoryChapterScreenState extends ConsumerState<StoryChapterScreen> {
  DialogueMoment? _currentMoment;
  bool _showingDialogue = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryShowNextDialogue();
    });
  }

  void _tryShowNextDialogue() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final chapterKey = 'chapter_${widget.chapterId}';
    final momentIds = kChapterDialogueMoments[chapterKey];
    if (momentIds == null) return;

    final resolved = user.storyChoicesRaw;

    for (final momentId in momentIds) {
      if (!resolved.containsKey(momentId)) {
        final moment = kDialogueMoments[momentId];
        if (moment != null) {
          setState(() {
            _currentMoment = moment;
            _showingDialogue = true;
          });
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapter = kStoryChapters.firstWhere(
      (c) => c.chapterId == widget.chapterId,
      orElse: () => kStoryChapters.first,
    );
    final storyState = ref.watch(storyProvider);
    final user = ref.watch(currentUserProvider);
    final wallet = ref.watch(walletProvider);
    final unlocked = storyState.isUnlocked(widget.chapterId);
    final playerChoice = storyState.playerChoice(widget.chapterId);
    final hasChoice = playerChoice != 0;

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(context, chapter),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Illustration
                          _buildIllustration(chapter.illustrationTag),
                          const SizedBox(height: 20),

                          if (!unlocked)
                            _buildUnlockCard(context, ref, chapter, user, wallet)
                          else ...[
                            // Content
                            _buildContent(chapter.content),
                            const SizedBox(height: 24),

                            // Choice section
                            _buildChoiceSection(
                              context: context,
                              ref: ref,
                              chapter: chapter,
                              hasChoice: hasChoice,
                              playerChoice: playerChoice,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_showingDialogue && _currentMoment != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: DialogueChoiceCard(
                        moment: _currentMoment!,
                        onDismiss: () {
                          setState(() {
                            _showingDialogue = false;
                            _currentMoment = null;
                          });
                        },
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

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, StoryChapterData chapter) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chapter ${chapter.chapterId}',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _kNeonMint,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  chapter.title,
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
    );
  }

  // ── Illustration ───────────────────────────────────────────────────────────

  Widget _buildIllustration(String tag) {
    CustomPainter painter;
    switch (tag) {
      case kIllustSupplier:
        painter = const SupplierPainter();
      case kIllustCoins:
        painter = const CoinsPainter();
      case kIllustBuilding:
        painter = const BuildingPainter();
      case kIllustCertificate:
        painter = const CertificatePainter();
      default:
        painter = const MarketStallPainter();
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: CustomPaint(painter: painter),
      ),
    );
  }

  // ── Chapter content ────────────────────────────────────────────────────────

  Widget _buildContent(String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Text(
        content,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: _kSoftGray,
          height: 1.65,
        ),
      ),
    );
  }

  // ── Unlock card ────────────────────────────────────────────────────────────

  Widget _buildUnlockCard(
    BuildContext context,
    WidgetRef ref,
    StoryChapterData chapter,
    dynamic user,
    int wallet,
  ) {
    final hasEnoughXp = (user?.xp ?? 0) >= chapter.xpCost;
    final hasEnoughCoins = wallet >= chapter.zamCoinCost;
    final canUnlock = hasEnoughXp && hasEnoughCoins;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kGold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔒 Chapter Locked',
            style: GoogleFonts.rajdhani(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kGold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock this chapter to continue Mwansa\'s journey.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _kSoftGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (chapter.xpCost > 0) ...[
                _costChip(
                  label: '⚡ ${chapter.xpCost} XP required',
                  satisfied: hasEnoughXp,
                ),
                const SizedBox(width: 10),
              ],
              _costChip(
                label: '🪙 ${chapter.zamCoinCost} ZamCoins',
                satisfied: hasEnoughCoins,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canUnlock
                  ? () async {
                      final ok = await ref
                          .read(storyProvider.notifier)
                          .unlockChapter(chapter.chapterId);
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Not enough ZamCoins or XP.')),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGold,
                foregroundColor: _kCoreNavy,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                canUnlock
                    ? 'Unlock Chapter  🔓'
                    : 'Not enough resources',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _costChip({required String label, required bool satisfied}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: satisfied
            ? _kFreshGreen.withValues(alpha: 0.12)
            : const Color(0xFFE53935).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: satisfied
              ? _kFreshGreen.withValues(alpha: 0.45)
              : const Color(0xFFE53935).withValues(alpha: 0.45),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: satisfied ? _kFreshGreen : const Color(0xFFE53935),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── Choice section ─────────────────────────────────────────────────────────

  Widget _buildChoiceSection({
    required BuildContext context,
    required WidgetRef ref,
    required StoryChapterData chapter,
    required bool hasChoice,
    required int playerChoice,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kNeonMint.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasChoice ? '📖 Your Choice' : '⚡ What does Mwansa do?',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _kNeonMint,
            ),
          ),
          const SizedBox(height: 12),

          if (!hasChoice) ...[
            _choiceButton(
              context: context,
              ref: ref,
              chapter: chapter,
              choice: 1,
              label: 'A',
              text: chapter.choiceA,
            ),
            const SizedBox(height: 10),
            _choiceButton(
              context: context,
              ref: ref,
              chapter: chapter,
              choice: 2,
              label: 'B',
              text: chapter.choiceB,
            ),
          ] else ...[
            // Show chosen option
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _kFreshGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kFreshGreen.withValues(alpha: 0.30)),
              ),
              child: Row(
                children: [
                  Text(
                    'Option ${playerChoice == 1 ? 'A' : 'B'}:  ',
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kFreshGreen,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      playerChoice == 1 ? chapter.choiceA : chapter.choiceB,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _kSoftGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Outcome
            Text(
              '📜 Outcome',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _kGold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              playerChoice == 1
                  ? chapter.choiceAOutcome
                  : chapter.choiceBOutcome,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _kSoftGray,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _choiceButton({
    required BuildContext context,
    required WidgetRef ref,
    required StoryChapterData chapter,
    required int choice,
    required String label,
    required String text,
  }) {
    return GestureDetector(
      onTap: () async {
        await ref
            .read(storyProvider.notifier)
            .recordChoice(chapter.chapterId, choice);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kCoreNavy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kNeonMint.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: _kNeonMint.withValues(alpha: 0.60)),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _kNeonMint,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _kSoftGray,
                  height: 1.4,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: _kNeonMint, size: 18),
          ],
        ),
      ),
    );
  }
}
