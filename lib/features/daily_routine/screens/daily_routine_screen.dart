/// daily_routine_screen.dart
/// Purpose: 3-part daily financial routine — morning tip, midday quiz,
///          evening reflection — with perfect day tracking.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/features/daily_routine/providers/daily_routine_provider.dart';

class DailyRoutineScreen extends ConsumerStatefulWidget {
  const DailyRoutineScreen({super.key});

  @override
  ConsumerState<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends ConsumerState<DailyRoutineScreen> {
  final _reflectionCtrl = TextEditingController();
  bool _submittingReflection = false;

  static const _navy  = Color(0xFF00203F);
  static const _gold  = Color(0xFFFFD700);
  static const _teal  = Color(0xFF36ECDE);

  @override
  void dispose() {
    _reflectionCtrl.dispose();
    super.dispose();
  }

  int get _currentHour => DateTime.now().hour;
  bool get _isMorning  => _currentHour >= 6  && _currentHour < 12;
  bool get _isMidday   => _currentHour >= 12 && _currentHour < 18;
  bool get _isEvening  => _currentHour >= 18 && _currentHour < 24;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyRoutineProvider);

    return Scaffold(
      backgroundColor: _navy,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Daily Routine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _progressBar(state),
                  const SizedBox(height: 20),
                  if (state.perfectToday) _perfectDayBanner(),
                  const SizedBox(height: 4),
                  _morningSection(state),
                  const SizedBox(height: 12),
                  _middaySection(state),
                  const SizedBox(height: 12),
                  _eveningSection(state),
                  const SizedBox(height: 20),
                  _statsRow(state),
                  const SizedBox(height: 16),
                  if (state.journal.isNotEmpty) _journalSection(state),
                ],
              ),
            ),
    );
  }

  Widget _progressBar(DailyRoutineState state) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: state.completedCount / 3,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(_teal),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${state.completedCount}/3 complete today',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _perfectDayBanner() => Container(
    width: double.infinity, padding: const EdgeInsets.all(14),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: _gold.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _gold.withValues(alpha: 0.5)),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('🌟', style: TextStyle(fontSize: 20)),
        SizedBox(width: 8),
        Text('Perfect Day Achieved! +$kPerfectDayXp XP & $kPerfectDayCoins coins',
            style: TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    ),
  );

  Widget _morningSection(DailyRoutineState state) {
    final active = _isMorning || state.morningDone;
    return _RoutineSection(
      icon: '☀️',
      title: 'Morning Tip',
      timeRange: '6am – 12pm',
      xp: kMorningTipXp,
      active: active,
      done: state.morningDone,
      locked: !active,
      child: active
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Text(state.todaysMorningTip,
                      style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
                ),
                if (!state.morningDone) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => ref.read(dailyRoutineProvider.notifier).completeMorningTip(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.withValues(alpha: 0.8),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Got it! +$kMorningTipXp XP', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            )
          : null,
    );
  }

  Widget _middaySection(DailyRoutineState state) {
    final active = _isMidday || state.middayDone;
    return _RoutineSection(
      icon: '🧠',
      title: 'Daily Challenge Quiz',
      timeRange: '12pm – 6pm',
      xp: kMiddayQuizXp,
      active: active,
      done: state.middayDone,
      locked: !active,
      child: active
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.middayDone
                      ? 'Quiz completed for today! Great work.'
                      : 'Complete today\'s financial quiz challenge.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                ),
                if (!state.middayDone) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await context.push(AppRoutes.dailyChallenge);
                        if (mounted) {
                          await ref.read(dailyRoutineProvider.notifier).completeMiddayQuiz();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: _navy,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Take the Quiz →', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            )
          : null,
    );
  }

  Widget _eveningSection(DailyRoutineState state) {
    final active = _isEvening || state.eveningDone;
    return _RoutineSection(
      icon: '🌙',
      title: 'Evening Reflection',
      timeRange: '6pm – midnight',
      xp: kEveningReflectionXp,
      active: active,
      done: state.eveningDone,
      locked: !active,
      child: active
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!state.eveningDone) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
                    ),
                    child: Text(state.todaysEveningPrompt,
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4, fontStyle: FontStyle.italic)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reflectionCtrl,
                    maxLines: 3,
                    maxLength: 200,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Write your reflection here... (50–200 characters)',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _teal)),
                      counterStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submittingReflection ? null : () async {
                        final text = _reflectionCtrl.text.trim();
                        if (text.length < 50) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Please write at least 50 characters for your reflection.'),
                          ));
                          return;
                        }
                        setState(() => _submittingReflection = true);
                        await ref.read(dailyRoutineProvider.notifier).submitEveningReflection(text);
                        setState(() => _submittingReflection = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.withValues(alpha: 0.7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(_submittingReflection ? 'Submitting...' : 'Submit Reflection +$kEveningReflectionXp XP',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else ...[
                  Text("Great reflection! Players who journal are 40% more likely to save consistently.",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4)),
                ],
              ],
            )
          : null,
    );
  }

  Widget _statsRow(DailyRoutineState state) => Row(
    children: [
      Expanded(child: _StatChip(label: 'Perfect Days', value: '${state.perfectDaysTotal}', color: _gold)),
      const SizedBox(width: 8),
      Expanded(child: _StatChip(label: 'Day Streak', value: '${state.perfectDayStreak}', color: _teal)),
      const SizedBox(width: 8),
      Expanded(child: _StatChip(label: 'Reflections', value: '${state.journal.length}', color: Colors.deepPurpleAccent)),
    ],
  );

  Widget _journalSection(DailyRoutineState state) {
    final recent = state.journal.reversed.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RECENT REFLECTIONS', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        ...recent.map((entry) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(entry, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4)),
        )),
      ],
    );
  }
}

class _RoutineSection extends StatelessWidget {
  const _RoutineSection({
    required this.icon,
    required this.title,
    required this.timeRange,
    required this.xp,
    required this.active,
    required this.done,
    required this.locked,
    this.child,
  });

  final String   icon;
  final String   title;
  final String   timeRange;
  final int      xp;
  final bool     active;
  final bool     done;
  final bool     locked;
  final Widget?  child;

  static const _gold  = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0D1B2A) : const Color(0xFF080F18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: done ? Colors.greenAccent.withValues(alpha: 0.5)
              : active ? _gold.withValues(alpha: 0.3)
              : Colors.white12,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: active ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(timeRange, style: TextStyle(color: active ? Colors.white38 : Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              if (done)
                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20)
              else if (locked)
                const Icon(Icons.lock_outline, color: Colors.white24, size: 18)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text('+$xp XP', style: const TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          if (locked)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Available $timeRange', style: const TextStyle(color: Colors.white24, fontSize: 12)),
            )
          else if (child != null) ...[
            const SizedBox(height: 14),
            child!,
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
