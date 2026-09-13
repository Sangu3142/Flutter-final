import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../providers/season_provider.dart';

class SeasonScreen extends ConsumerWidget {
  const SeasonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final season = ref.watch(seasonProvider);
    final s      = season.currentSeason;

    return Scaffold(
      backgroundColor: kDeepNavy,
      appBar: AppBar(
        backgroundColor: kDeepNavy,
        title: Text('${s.emoji} ${s.theme}', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2A44),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kNeonMint, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.theme,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(s.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    '${season.daysRemainingInWeek} day${season.daysRemainingInWeek == 1 ? '' : 's'} remaining this season',
                    style: const TextStyle(color: kNeonMint, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Monthly Challenge',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1B2D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: season.monthlyChallengeCompleted ? kNeonMint : Colors.white24,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    season.monthlyChallengeCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: season.monthlyChallengeCompleted ? kNeonMint : Colors.white54,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      season.monthlyChallengeDescription,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            if (!season.monthlyChallengeCompleted) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kNeonMint),
                onPressed: () => ref.read(seasonProvider.notifier).completeMonthlyChallenge(),
                child: const Text('Claim Monthly Reward',
                    style: TextStyle(color: kDeepNavy, fontWeight: FontWeight.bold)),
              ),
            ],
            const SizedBox(height: 24),
            const Text('Season Leaderboard',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const _SeasonLeaderboard(),
          ],
        ),
      ),
    );
  }
}

class _SeasonLeaderboard extends StatelessWidget {
  const _SeasonLeaderboard();

  static const _entries = [
    ('Naledi K.', 1420, '🥇'),
    ('Bwalya M.', 1380, '🥈'),
    ('Chanda P.', 1240, '🥉'),
    ('Mwape S.', 1100, ''),
    ('Tembo J.', 980, ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _entries.map((e) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F2A44),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              if (e.$3.isNotEmpty)
                Text(e.$3, style: const TextStyle(fontSize: 18))
              else
                const SizedBox(width: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(e.$1, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
              Text('${e.$2} XP',
                  style: const TextStyle(color: kNeonMint, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
