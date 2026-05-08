library;

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';

@immutable
class QuizSession {
  const QuizSession({
    required this.questions,
    this.currentIndex = 0,
    this.selectedAnswer = -1,
    this.revealed = false,
    this.sessionXP = 0,
    this.correctCount = 0,
  });

  final List<QuizQuestion> questions;
  final int currentIndex;
  final int selectedAnswer; // -1 = not yet answered
  final bool revealed;
  final int sessionXP;
  final int correctCount;

  bool get isDone => currentIndex >= questions.length;
  QuizQuestion? get current =>
      isDone ? null : questions[currentIndex];
  int get totalQuestions => questions.length;

  QuizSession copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    int? selectedAnswer,
    bool? revealed,
    int? sessionXP,
    int? correctCount,
  }) {
    return QuizSession(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      revealed: revealed ?? this.revealed,
      sessionXP: sessionXP ?? this.sessionXP,
      correctCount: correctCount ?? this.correctCount,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizSession> {
  QuizNotifier(this._ref) : super(_fresh());

  final Ref _ref;

  static QuizSession _fresh() {
    final rng = Random();
    final questions = List<QuizQuestion>.from(kQuizQuestions)..shuffle(rng);
    return QuizSession(questions: questions.take(5).toList());
  }

  void selectAnswer(int index) {
    if (state.revealed) return;
    final q = state.current;
    if (q == null) return;

    final isCorrect = index == q.correctIndex;
    int newSessionXP = state.sessionXP;
    int newCorrect = state.correctCount;

    if (isCorrect) {
      newSessionXP += q.xpReward;
      newCorrect += 1;
      final user = _ref.read(currentUserProvider);
      if (user != null) {
        user.addQuizXp(q.xpReward, q.id);
        user.save();
        _ref.read(authProvider.notifier).refreshUser();
      }
    }

    state = state.copyWith(
      selectedAnswer: index,
      revealed: true,
      sessionXP: newSessionXP,
      correctCount: newCorrect,
    );
  }

  void nextQuestion() {
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      selectedAnswer: -1,
      revealed: false,
    );
  }

  void restart() {
    state = _fresh();
  }
}

final quizProvider =
    StateNotifierProvider.autoDispose<QuizNotifier, QuizSession>((ref) {
  return QuizNotifier(ref);
});
