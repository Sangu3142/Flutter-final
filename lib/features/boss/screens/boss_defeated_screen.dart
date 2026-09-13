import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../wallet/widgets/wallet_badge.dart';

class BossDefeatedScreen extends StatefulWidget {
  final int levelId;
  final bool isReplay;

  const BossDefeatedScreen({
    super.key,
    required this.levelId,
    this.isReplay = false,
  });

  @override
  State<BossDefeatedScreen> createState() => _BossDefeatedScreenState();
}

class _BossDefeatedScreenState extends State<BossDefeatedScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3))..play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = kBossConfigs.firstWhere(
      (c) => c.levelId == widget.levelId,
      orElse: () => kBossConfigs.first,
    );
    final xp    = widget.isReplay ? (config.xpReward * 0.5).round() : config.xpReward;
    final coins = widget.isReplay ? 50 : config.coinsReward;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.03,
            numberOfParticles: 25,
            gravity: 0.2,
            colors: const [kNeonMint, Color(0xFFFFD700), Colors.white],
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚔️', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    widget.isReplay ? 'Rematch Won!' : 'Boss Defeated!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${config.name} has been vanquished!',
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2A44),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kNeonMint, width: 1),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '+$xp XP',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+$coins ZMW Coins',
                          style: const TextStyle(color: kNeonMint, fontSize: 16),
                        ),
                        if (!widget.isReplay) ...[
                          const SizedBox(height: 4),
                          const Text(
                            '+1 Bonus Spin 🎡',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const WalletBadge(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kNeonMint),
                    onPressed: () => context.go('/'),
                    child: const Text(
                      'Return Home',
                      style: TextStyle(color: kDeepNavy, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),       // Column
            ),         // Center
          ),           // ConstrainedBox
        ),             // SingleChildScrollView
      ),               // SafeArea
        ],
      ),
    );
  }
}
