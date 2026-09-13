/// level_map_screen.dart
/// Purpose: Animated adventure map — CustomPainter path with confetti on unlock.
/// Reads from: levelProvider, authProvider
/// Writes to: nothing (navigation triggers state changes elsewhere)
/// Navigation: → /levels/:levelId
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/level_provider.dart';
import '../widgets/map_painter.dart';
import '../widgets/zone_node_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../wallet/widgets/wallet_badge.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';

class LevelMapScreen extends ConsumerStatefulWidget {
  const LevelMapScreen({super.key});

  @override
  ConsumerState<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends ConsumerState<LevelMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pathCtrl;
  late Animation<double> _pathAnim;
  late ConfettiController _confettiCtrl;
  int _prevUnlockedCount = 0;

  @override
  void initState() {
    super.initState();
    _pathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pathAnim = CurvedAnimation(parent: _pathCtrl, curve: Curves.easeInOut);
    _confettiCtrl =
        ConfettiController(duration: const Duration(seconds: 2));
    _pathCtrl.forward();
  }

  @override
  void dispose() {
    _pathCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  int _countUnlocked(Map<int, dynamic> levels) =>
      levels.values.where((l) => l.status != kStatusLocked).length;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    // Detect newly unlocked levels via listen — side-effect-free build.
    ref.listen<LevelState>(levelProvider, (prev, next) {
      final newCount = _countUnlocked(next.levels);
      if (_prevUnlockedCount == 0) {
        _prevUnlockedCount = newCount;
        return;
      }
      if (newCount > _prevUnlockedCount) {
        _confettiCtrl.play();
        _pathCtrl.forward(from: 0);
      }
      _prevUnlockedCount = newCount;
    });

    final levelState = ref.watch(levelProvider);
    final levelStates = levelState.levels;

    if (user == null) {
      return const Scaffold(
        backgroundColor: kCoreNavy,
        body: Center(child: CircularProgressIndicator(color: kNeonMint)),
      );
    }

    final unlockedCount = _countUnlocked(levelStates);
    final pathProgress = (unlockedCount / 4).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: kCoreNavy,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ADVENTURE MAP',
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF36ECDE),
            letterSpacing: 1.5,
          ),
        ),
        actions: const [WalletBadge(), SizedBox(width: 12)],
      ),
      body: FadeTransition(
        opacity: _pathAnim,
        child: Stack(
        alignment: Alignment.topCenter,
        children: [
          LayoutBuilder(
            builder: (ctx, constraints) {
              final size =
                  Size(constraints.maxWidth, constraints.maxHeight);
              // Responsive map height — at least 720px, scaled up for tall
              // screens so the snaking path always has room to breathe.
              final mapHeight = math.max(
                720.0,
                MediaQuery.sizeOf(context).height * 1.2,
              );

              return SingleChildScrollView(
                reverse: true,
                child: SizedBox(
                  width: size.width,
                  height: mapHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: AnimatedBuilder(
                            animation: _pathAnim,
                            builder: (_, __) => CustomPaint(
                              painter: MapPainter(
                                pathProgress:
                                    pathProgress * _pathAnim.value,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ...List.generate(4, (i) {
                        final levelId = i + 1;
                        final level = levelStates[levelId];
                        if (level == null) return const SizedBox.shrink();

                        final meta = kLevelMeta[levelId]!;
                        final fixedPositions = [
                          Offset(size.width * 0.35 - 36, mapHeight * 0.85 - 36),
                          Offset(size.width * 0.65 - 36, mapHeight * 0.60 - 36),
                          Offset(size.width * 0.30 - 36, mapHeight * 0.35 - 36),
                          Offset(size.width * 0.60 - 36, mapHeight * 0.10 - 36),
                        ];
                        final pos = fixedPositions[i];

                        final zoneNode = ZoneNodeWidget(
                          levelId: levelId,
                          status: level.status,
                          name: meta.name,
                          emoji: meta.emoji,
                          onTap: () => context.push('/levels/$levelId'),
                          onLockedTap: () {
                            final prevLevelId = levelId - 1;
                            final prevLevel = levelStates[prevLevelId];
                            final prevComplete = prevLevel != null &&
                                prevLevel.status == kStatusCompleted;
                            if (prevComplete) {
                              context.push('/payment/$levelId');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Complete ${kLevelMeta[prevLevelId]?.name ?? "the previous level"} first!',
                                  ),
                                  backgroundColor: const Color(0xFF1A73E8),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        );

                        return Positioned(
                          left: pos.dx,
                          top: pos.dy,
                          child: Column(
                            children: [
                              zoneNode,
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  meta.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: kCharcoal,
                                    fontSize: 10,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [kNeonMint, kGold, kGreen, kPrimaryBlue],
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
      ),
    );
  }
}
