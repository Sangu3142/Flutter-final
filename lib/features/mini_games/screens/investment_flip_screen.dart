import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/mini_game_data.dart';
import '../widgets/flip_card_widget.dart';
import '../../flash_challenge/widgets/countdown_timer_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme.dart';

const int kFlipTimerSeconds = 90;
const int kFlipCoinReward = 5;
const int kFlipBonusXp = 100;

class InvestmentFlipScreen extends ConsumerStatefulWidget {
  const InvestmentFlipScreen({super.key});

  @override
  ConsumerState<InvestmentFlipScreen> createState() =>
      _InvestmentFlipScreenState();
}

class _InvestmentFlipScreenState
    extends ConsumerState<InvestmentFlipScreen> {
  late List<_FlipCard> _cards;
  String? _firstFlippedId;
  String? _firstFlippedPairId;
  final Set<String> _matchedPairIds = {};
  bool _checking = false;
  int _score = 0;
  bool _timerExpired = false;

  @override
  void initState() {
    super.initState();
    _buildCards();
  }

  void _buildCards() {
    final List<_FlipCard> cards = [];
    for (final pair in kInvestmentFlipPairs) {
      cards.add(_FlipCard(id: '${pair.id}_term', pairId: pair.id, text: pair.term));
      cards.add(_FlipCard(id: '${pair.id}_def', pairId: pair.id, text: pair.definition));
    }
    cards.shuffle();
    _cards = cards;
  }

  Future<void> _onCardTap(String cardId, String pairId) async {
    if (_timerExpired) return;
    if (_checking) return;
    if (_matchedPairIds.contains(pairId)) return;
    final card = _cards.firstWhere((c) => c.id == cardId);
    if (card.isFlipped) return;

    setState(() => card.isFlipped = true);

    if (_firstFlippedId == null) {
      _firstFlippedId = cardId;
      _firstFlippedPairId = pairId;
    } else {
      _checking = true;
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      if (_firstFlippedPairId == pairId && _firstFlippedId != cardId) {
        setState(() => _matchedPairIds.add(pairId));
        _score++;
        await ref.read(authProvider.notifier).addWalletCoins(kFlipCoinReward);
        if (!mounted) return;
        if (_matchedPairIds.length == kInvestmentFlipPairs.length) {
          await ref.read(authProvider.notifier).addXp(kFlipBonusXp);
        }
      } else {
        setState(() {
          for (final c in _cards) {
            if (!_matchedPairIds.contains(c.pairId)) {
              c.isFlipped = false;
            }
          }
        });
      }

      _firstFlippedId = null;
      _firstFlippedPairId = null;
      _checking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allMatched = _matchedPairIds.length == kInvestmentFlipPairs.length;

    return Scaffold(
      backgroundColor: kCoreNavy,
      appBar: AppBar(
        backgroundColor: kCoreNavy,
        title: const Text('Investment Flip',
            style: TextStyle(color: kCharcoal)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!allMatched && !_timerExpired)
              CountdownTimerBar(
                key: const ValueKey('flip_timer'),
                durationSeconds: kFlipTimerSeconds,
                onExpired: () {
                  if (!mounted) return;
                  setState(() => _timerExpired = true);
                },
              ),
            const SizedBox(height: 16),
            if (allMatched)
              Column(
                children: [
                  const Text('All Matched! +100 XP Bonus!',
                      style: TextStyle(
                          color: kGold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kNeonMint,
                        foregroundColor: kCoreNavy),
                    child: const Text('Done'),
                  ),
                ],
              )
            else if (_timerExpired)
              Column(
                children: [
                  Text("Time's up! Matched $_score/8",
                      style: const TextStyle(
                          color: kError,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kCharcoalLight,
                        foregroundColor: kCoreNavy),
                    child: const Text('Back'),
                  ),
                ],
              )
            else
              Text('Matched: $_score/${kInvestmentFlipPairs.length}',
                  style: const TextStyle(color: kCharcoalLight, fontSize: 14)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _cards.length,
                itemBuilder: (_, i) {
                  final card = _cards[i];
                  return FlipCardWidget(
                    key: ValueKey(card.id),
                    frontText: '',
                    backText: card.text,
                    cardId: card.id,
                    isFlipped: card.isFlipped,
                    isMatched: _matchedPairIds.contains(card.pairId),
                    onTap: () => _onCardTap(card.id, card.pairId),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlipCard {
  final String id;
  final String pairId;
  final String text;
  bool isFlipped = false;

  _FlipCard({
    required this.id,
    required this.pairId,
    required this.text,
  });
}
