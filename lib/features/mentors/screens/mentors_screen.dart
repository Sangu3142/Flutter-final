/// mentors_screen.dart
/// Purpose: Mentor grid — shows locked/unlocked mentors, daily tips,
///          challenges, and contextual financial advice cards.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/features/mentors/providers/mentor_provider.dart';

class MentorsScreen extends ConsumerWidget {
  const MentorsScreen({super.key});

  static const _navy = Color(0xFF00203F);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mentorProvider);

    return Scaffold(
      backgroundColor: _navy,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Mentors', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Unlock mentors by completing levels and improving your finances.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: kAllMentors.length,
                    itemBuilder: (context, i) {
                      final mentor   = kAllMentors[i];
                      final unlocked = state.isUnlocked(mentor.id);
                      return _MentorCard(
                        mentor: mentor,
                        unlocked: unlocked,
                        challengeDone: state.isChallengeCompleted(mentor.id),
                        onTap: unlocked ? () => _showMentorDetail(context, ref, mentor, state) : null,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showMentorDetail(BuildContext context, WidgetRef ref, MentorData mentor, MentorState state) {
    final tip  = state.dailyTipFor(mentor.id);
    final done = state.isChallengeCompleted(mentor.id);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, ctrl) => _MentorDetailSheet(
          mentor: mentor,
          tip: tip,
          challengeDone: done,
          scrollCtrl: ctrl,
          onChallengeComplete: () async {
            await ref.read(mentorProvider.notifier).completeChallenge(mentor.id);
            if (context.mounted) { Navigator.of(context).pop(); }
          },
        ),
      ),
    );
  }
}

class _MentorCard extends StatelessWidget {
  const _MentorCard({
    required this.mentor,
    required this.unlocked,
    required this.challengeDone,
    this.onTap,
  });
  final MentorData   mentor;
  final bool         unlocked;
  final bool         challengeDone;
  final VoidCallback? onTap;

  static const _gold = Color(0xFFFFD700);
  static const _teal = Color(0xFF36ECDE);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: unlocked ? const Color(0xFF0D2137) : const Color(0xFF091520),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: challengeDone ? _teal.withValues(alpha: 0.6)
                : unlocked ? _gold.withValues(alpha: 0.35)
                : Colors.white12,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji badge
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: unlocked ? _gold.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                  border: Border.all(
                    color: unlocked ? _gold.withValues(alpha: 0.5) : Colors.white12,
                  ),
                ),
                child: Center(
                  child: ColorFiltered(
                    colorFilter: unlocked
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.saturation)
                        : const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0,      0,      0,      1, 0,
                          ]),
                    child: Text(mentor.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(mentor.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: unlocked ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Text(mentor.role,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: unlocked ? Colors.white54 : Colors.white24, fontSize: 10)),
              const SizedBox(height: 8),
              if (unlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (challengeDone ? _teal : _gold).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(challengeDone ? '✓ Challenge Done' : 'Tap to learn',
                      style: TextStyle(color: challengeDone ? _teal : _gold, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              else
                const Icon(Icons.lock_outline, color: Colors.white24, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _MentorDetailSheet extends StatelessWidget {
  const _MentorDetailSheet({
    required this.mentor,
    required this.tip,
    required this.challengeDone,
    required this.scrollCtrl,
    required this.onChallengeComplete,
  });
  final MentorData     mentor;
  final String         tip;
  final bool           challengeDone;
  final ScrollController scrollCtrl;
  final VoidCallback   onChallengeComplete;

  static const _gold = Color(0xFFFFD700);
  static const _teal = Color(0xFF36ECDE);
  static const _navy = Color(0xFF00203F);

  static const List<String> _adviceCards = [
    'Financial discipline beats financial intelligence. Consistent habits outperform brilliant strategies.',
    'The best investment you can make in Zambia right now is your own financial education.',
    'Every kwacha saved is a kwacha working for you while you sleep. Start tonight.',
    'Track your net worth every 3 months. Watching it grow is the best motivation to keep going.',
    'Debt is a tool. Like any tool, it can build or destroy — depending on how you use it.',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        // Handle
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        // Header
        Row(
          children: [
            Text(mentor.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mentor.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(mentor.role, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: _teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(mentor.specialty, style: const TextStyle(color: _teal, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Today's tip
        _section("Today's Tip", Icons.lightbulb_outline, _gold),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _gold.withValues(alpha: 0.3)),
          ),
          child: Text(tip, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
        ),
        const SizedBox(height: 20),
        // Challenge
        _section('Active Challenge', Icons.emoji_events_outlined, _teal),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _teal.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _teal.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mentor.challenge, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
              const SizedBox(height: 12),
              Text('+${mentor.challengeXp} XP on completion',
                  style: TextStyle(color: _gold.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.bold)),
              if (!challengeDone) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onChallengeComplete,
                    style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: _navy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('Mark Challenge Complete', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                const Row(children: [Icon(Icons.check_circle, color: Colors.greenAccent, size: 16), SizedBox(width: 6), Text('Challenge completed!', style: TextStyle(color: Colors.greenAccent, fontSize: 12))]),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Advice cards
        _section("${mentor.name.split(' ').first}'s Advice", Icons.chat_bubble_outline, Colors.white54),
        const SizedBox(height: 8),
        ..._adviceCards.map((advice) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mentor.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(child: Text(advice, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4))),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _section(String label, IconData icon, Color color) => Row(
    children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 6),
      Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
    ],
  );
}
