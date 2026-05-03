/// daily_challenge_provider.dart
/// Purpose: Riverpod state management for the Daily Challenge feature.
///          Computes today's challenge via date-seeded Random, loads and
///          persists [DailyChallengeRecord] in Hive, awards XP on correct answers,
///          and manages streak / Streak Shield logic.
/// Reads from: Hive box 'daily_challenge', authProvider (current user + addXp)
/// Writes to: Hive box 'daily_challenge', UserProfile.xp (via authProvider)
/// Navigation: none (state only)
library;

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/badges/providers/badge_provider.dart';
import 'package:zamwealth_quest/features/daily_challenge/models/challenge.dart';
import 'package:zamwealth_quest/features/daily_challenge/models/daily_challenge_record.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable snapshot of the Daily Challenge feature state.
class DailyChallengeState {
  const DailyChallengeState({
    this.todaysChallenge,
    this.record,
    this.isLoading = false,
    this.isAnswered = false,
    this.isCorrect = false,
    this.selectedAnswer,
    this.selectedIndex,
  });

  /// The challenge question shown today (same for all users on a given day).
  final DailyChallenge? todaysChallenge;

  /// The current user's persisted progress record, or null before first load.
  final DailyChallengeRecord? record;

  /// True while Hive I/O is in progress.
  final bool isLoading;

  /// True once the user submits an answer in this session.
  final bool isAnswered;

  /// Whether the submitted answer was correct.
  final bool isCorrect;

  /// String representation of the submitted answer (for display in results).
  final String? selectedAnswer;

  /// Index submitted for multipleChoice / trueFalse answers.
  final int? selectedIndex;

  DailyChallengeState copyWith({
    DailyChallenge? todaysChallenge,
    DailyChallengeRecord? record,
    bool? isLoading,
    bool? isAnswered,
    bool? isCorrect,
    String? selectedAnswer,
    int? selectedIndex,
  }) {
    return DailyChallengeState(
      todaysChallenge: todaysChallenge ?? this.todaysChallenge,
      record: record ?? this.record,
      isLoading: isLoading ?? this.isLoading,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Manages all Daily Challenge business logic.
///
/// Call [getTodaysChallenge] on screen init to load the question and record.
/// Call [submitAnswer] when the player confirms their answer.
class DailyChallengeNotifier extends StateNotifier<DailyChallengeState> {
  DailyChallengeNotifier(this._box, this._ref)
      : super(const DailyChallengeState());

  final Box<DailyChallengeRecord> _box;
  final Ref _ref;

  String get _uid => _ref.read(currentUserProvider)?.uid ?? '';

  // ── Today's challenge index (date-seeded, same for every user) ─────────────

  static DailyChallenge _computeTodaysChallenge() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final seed = now.year * 1000 + dayOfYear;
    final index = Random(seed).nextInt(kDailyChallenges.length);
    return kDailyChallenges[index];
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Loads (or creates) today's challenge and the user's record.
  ///
  /// Idempotent within the same calendar day — safe to call from both the
  /// provider factory and each screen's initState.
  Future<void> getTodaysChallenge() async {
    final challenge = _computeTodaysChallenge();

    // Skip if already loaded for today and not currently loading.
    if (state.todaysChallenge?.id == challenge.id &&
        state.record != null &&
        !state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true);

    final uid = _uid;
    if (uid.isEmpty) {
      state = state.copyWith(todaysChallenge: challenge, isLoading: false);
      return;
    }

    DailyChallengeRecord? record = _box.get(uid);

    if (record == null) {
      // First-ever challenge for this user — create a fresh record.
      record = DailyChallengeRecord(
        lastCompletedDateStr: '',
        currentStreak: 0,
        totalCompleted: 0,
        streakShields: 0,
        bonusXpEarned: 0,
        uid: uid,
      );
      await _box.put(uid, record);
    } else if (record.streakBroken) {
      // Streak has been broken since the last completion.
      if (record.streakShields > 0) {
        // Consume one shield: keep the streak alive, backfill yesterday.
        record.streakShields -= 1;
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        record.lastCompletedDateStr =
            '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      } else {
        // No shields left — reset streak.
        record.currentStreak = 0;
      }
      await record.save();
    }

    state = state.copyWith(
      todaysChallenge: challenge,
      record: record,
      isLoading: false,
    );
  }

  /// Evaluates the player's [answer] and updates state + Hive.
  ///
  /// [answer] must be an [int] index for multipleChoice/trueFalse, or a
  /// [double] for numeric challenges.  Returns immediately if the challenge
  /// has already been completed today or if no challenge is loaded.
  Future<void> submitAnswer(dynamic answer) async {
    final challenge = state.todaysChallenge;
    final record = state.record;
    if (challenge == null || record == null) return;
    if (record.completedToday) return;

    // ── Evaluate correctness ──────────────────────────────────────────────
    final bool isCorrect;
    if (challenge.type == ChallengeType.numeric) {
      isCorrect =
          ((answer as double) - challenge.correctNumeric).abs() <=
              challenge.numericTolerance;
    } else {
      isCorrect = (answer as int) == challenge.correctIndex;
    }

    // ── Award XP and update record on correct answer ──────────────────────
    if (isCorrect) {
      await _ref.read(authProvider.notifier).addXp(kDailyChallengeXp);

      // Build today's date string.
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      record
        ..currentStreak += 1
        ..totalCompleted += 1
        ..bonusXpEarned += kDailyChallengeXp
        ..lastCompletedDateStr = todayStr;

      // Award a Streak Shield every kStreakShieldInterval consecutive days.
      if (record.currentStreak % kStreakShieldInterval == 0 &&
          record.streakShields < kMaxStreakShields) {
        record.streakShields += 1;
      }

      await record.save();

      _ref.read(badgeServiceProvider).checkAndAward(
        newStreak: record.currentStreak,
        newXp: _ref.read(authProvider).currentUser?.xp,
      );
    }

    state = state.copyWith(
      record: record,
      isAnswered: true,
      isCorrect: isCorrect,
      selectedAnswer: answer.toString(),
      selectedIndex: challenge.type != ChallengeType.numeric ? answer as int : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Global provider for Daily Challenge state.
///
/// Initialises immediately on first access and re-initialises when the
/// authenticated user changes (mirrors the pattern in [levelProvider]).
final dailyChallengeProvider =
    StateNotifierProvider<DailyChallengeNotifier, DailyChallengeState>((ref) {
  final box = Hive.box<DailyChallengeRecord>(kDailyChallengeBox);
  final notifier = DailyChallengeNotifier(box, ref);

  // Kick off initial load.
  notifier.getTodaysChallenge();

  // Re-load when the logged-in user changes.
  ref.listen(authProvider, (prev, next) {
    if (next.currentUser?.uid != prev?.currentUser?.uid) {
      notifier.getTodaysChallenge();
    }
  });

  return notifier;
});
