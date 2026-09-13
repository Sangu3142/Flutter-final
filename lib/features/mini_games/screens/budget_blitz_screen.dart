import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/mini_game_data.dart';
import '../widgets/draggable_expense_card.dart';
import '../widgets/drop_bucket.dart';
import '../../flash_challenge/widgets/countdown_timer_bar.dart';
import '../../hearts/providers/hearts_provider.dart';
import '../../hearts/widgets/hearts_hud.dart';
import '../../shop/providers/inventory_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme.dart';

const int _kBlitzSeconds = 60;
const int kBlitzXpPerCorrect = 20;

class BudgetBlitzScreen extends ConsumerStatefulWidget {
  const BudgetBlitzScreen({super.key});

  @override
  ConsumerState<BudgetBlitzScreen> createState() => _BudgetBlitzScreenState();
}

class _BudgetBlitzScreenState extends ConsumerState<BudgetBlitzScreen> {
  int _round = 0;
  late List<ExpenseCard> _remaining;
  int _score = 0;
  bool _roundComplete = false;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _loadRound();
  }

  void _loadRound() {
    _remaining = List.from(kBudgetBlitzRounds[_round]);
    _roundComplete = false;
  }

  Future<void> _onDrop(ExpenseCard card, bool correct) async {
    if (!mounted) return;
    setState(() => _remaining.remove(card));
    if (correct) {
      _score++;
      ref.read(authProvider.notifier).addXp(kBlitzXpPerCorrect);
    } else {
      await ref.read(heartsProvider.notifier).loseHeart(
            inventory: ref.read(inventoryProvider.notifier),
          );
    }
    if (_remaining.isEmpty) {
      setState(() => _roundComplete = true);
    }
  }

  void _nextRound() {
    if (_round >= kBudgetBlitzRounds.length - 1) {
      setState(() => _gameOver = true);
      return;
    }
    setState(() {
      _round++;
      _loadRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) {
      return Scaffold(
        backgroundColor: kCoreNavy,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆 Budget Blitz Complete!',
                  style: TextStyle(fontSize: 24, color: kGold)),
              const SizedBox(height: 16),
              Text('Score: $_score/${kBudgetBlitzRounds.length * 5}',
                  style: const TextStyle(fontSize: 20, color: kCharcoal)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: kNeonMint,
                    foregroundColor: kCoreNavy),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
    }

    if (_roundComplete) {
      return Scaffold(
        backgroundColor: kCoreNavy,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Round ${_round + 1} Complete! ✅',
                  style: const TextStyle(
                      fontSize: 22,
                      color: kGreen,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _nextRound,
                style: ElevatedButton.styleFrom(
                    backgroundColor: kNeonMint,
                    foregroundColor: kCoreNavy),
                child: const Text('Next Round →'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kCoreNavy,
      appBar: AppBar(
        backgroundColor: kCoreNavy,
        title: Text('Budget Blitz — Round ${_round + 1}',
            style: const TextStyle(color: kCharcoal)),
        actions: const [HeartsHUD(), SizedBox(width: 12)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CountdownTimerBar(
              key: ValueKey('blitz_$_round'),
              durationSeconds: _kBlitzSeconds - (_round * 10).clamp(0, 30),
              onExpired: () {
                if (_roundComplete || _gameOver) return;
                for (final card in List.from(_remaining)) {
                  _onDrop(card, false);
                }
              },
            ),
            const SizedBox(height: 24),
            const Text('Drag cards to the correct bucket',
                style: TextStyle(color: kCharcoalLight)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _remaining
                  .map((c) => DraggableExpenseCard(card: c))
                  .toList(),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropBucket(label: 'NEED', isNeed: true, onDrop: _onDrop),
                DropBucket(label: 'WANT', isNeed: false, onDrop: _onDrop),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
