import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../hearts/widgets/hearts_hud.dart';
import '../providers/zamu_provider.dart';
import '../widgets/zamu_avatar_widget.dart';
import '../../avatar/widgets/avatar_painter.dart';

const _coopQuestions = [
  _CoopQ('What is compound interest?',
      ['Interest on principal only', 'Interest on principal + prior interest', 'A bank fee', 'Annual-only interest'],
      1),
  _CoopQ('Diversification means:',
      ['One asset class only', 'Spreading investments to reduce risk', 'Maximising one stock', 'Foreign currency only'],
      1),
  _CoopQ('A bull market has:',
      ['Falling prices', 'Rising prices', 'No movement', 'High inflation'],
      1),
  _CoopQ('PAYE stands for:',
      ['Pay As You Earn', 'Personal Annual Yield', 'Public Annual Year Expense', 'Post-Assessment Year End'],
      0),
  _CoopQ('Net worth is:',
      ['Total income minus taxes', 'Total assets minus total liabilities', 'Monthly savings × 12', 'Salary plus bonuses'],
      1),
  _CoopQ('An emergency fund is for:',
      ['Luxury purchases', 'Unexpected expenses', 'Regular bills', 'Investment capital'],
      1),
  _CoopQ('ZRA stands for:',
      ['Zambia Revenue Authority', 'Zambia Regulatory Agency', 'Zambia Retail Association', 'Zambia Revenue Allocation'],
      0),
  _CoopQ('A sole trader\'s liability is:',
      ['Limited to business assets', 'Unlimited — personal assets at risk', 'Zero', 'Capped at ZMW 100,000'],
      1),
];

class _CoopQ {
  final String q;
  final List<String> choices;
  final int correct;
  const _CoopQ(this.q, this.choices, this.correct);
}

class CoopScreen extends ConsumerStatefulWidget {
  const CoopScreen({super.key});

  @override
  ConsumerState<CoopScreen> createState() => _CoopScreenState();
}

class _CoopScreenState extends ConsumerState<CoopScreen> {
  int _index    = 0;
  bool _answered = false;
  int? _chosen;

  @override
  Widget build(BuildContext context) {
    final zamu    = ref.watch(zamuProvider);
    final user    = ref.watch(currentUserProvider);
    final avatarId = user?.avatarId ?? 'av_01';
    final q       = _coopQuestions[_index % _coopQuestions.length];

    return Scaffold(
      backgroundColor: kDeepNavy,
      appBar: AppBar(
        backgroundColor: kDeepNavy,
        title: const Text('Co-op with Zamu', style: TextStyle(color: Colors.white)),
        actions: const [HeartsHUD()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AvatarWidget(avatarId: avatarId, size: 64, auraLevel: 0),
                const Text('VS', style: TextStyle(color: Colors.white54, fontSize: 20)),
                ZamuAvatarWidget(size: 64, zamuLevel: zamu.zamuLevel),
              ],
            ),
            const SizedBox(height: 16),
            if (_answered)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3B2E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kNeonMint),
                ),
                child: Text(
                  zamu.message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1B2D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E3A5F)),
              ),
              child: Text(q.q, style: const TextStyle(color: Colors.white, fontSize: 15)),
            ),
            const SizedBox(height: 12),
            ...List.generate(q.choices.length, (i) {
              Color border = Colors.white24;
              if (_answered && i == q.correct) border = kNeonMint;
              if (_answered && i == _chosen && i != q.correct) border = const Color(0xFFE74C3C);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: _answered ? null : () => _submit(i, q),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2A44),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: border, width: 1.5),
                    ),
                    child: Text(q.choices[i], style: const TextStyle(color: Colors.white)),
                  ),
                ),
              );
            }),
            if (_answered)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kNeonMint),
                  onPressed: () {
                    ref.read(zamuProvider.notifier).reset();
                    setState(() {
                      _index++;
                      _answered = false;
                      _chosen   = null;
                    });
                  },
                  child: const Text('Next Question',
                      style: TextStyle(color: kDeepNavy, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(int idx, _CoopQ q) async {
    setState(() {
      _answered = true;
      _chosen   = idx;
    });
    await ref.read(zamuProvider.notifier).revealZamuAnswer(
          questionHash: q.q.hashCode,
          playerCorrect: idx == q.correct,
          normalXp: 20,
        );
    if (mounted) setState(() {});
  }
}
