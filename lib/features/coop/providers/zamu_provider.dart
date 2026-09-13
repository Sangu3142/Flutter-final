import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../badges/providers/badge_provider.dart';

const _zamuAnsweredCorrectSentinel = Object();

class ZamuState {
  final int zamuLevel;
  final int teachMoments;
  final bool? zamuAnsweredCorrect;
  final String message;

  const ZamuState({
    this.zamuLevel = 1,
    this.teachMoments = 0,
    this.zamuAnsweredCorrect,
    this.message = 'Let\'s learn together! 📚',
  });

  ZamuState copyWith({
    int? zamuLevel,
    int? teachMoments,
    Object? zamuAnsweredCorrect = _zamuAnsweredCorrectSentinel,
    String? message,
  }) =>
      ZamuState(
        zamuLevel: zamuLevel ?? this.zamuLevel,
        teachMoments: teachMoments ?? this.teachMoments,
        zamuAnsweredCorrect: identical(zamuAnsweredCorrect, _zamuAnsweredCorrectSentinel)
            ? this.zamuAnsweredCorrect
            : zamuAnsweredCorrect as bool?,
        message: message ?? this.message,
      );
}

class ZamuNotifier extends StateNotifier<ZamuState> {
  final Ref _ref;

  ZamuNotifier(this._ref) : super(const ZamuState()) {
    _syncLevel();
  }

  void _syncLevel() {
    final user = _ref.read(currentUserProvider);
    if (user != null) {
      state = state.copyWith(zamuLevel: user.currentLevel);
    }
  }

  Future<void> revealZamuAnswer({
    required int questionHash,
    required bool playerCorrect,
    required int normalXp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final zamuCorrect = Random(questionHash).nextDouble() < 0.7;
    String msg;
    int xpToAward;

    if (playerCorrect && zamuCorrect) {
      msg = '🎉 Perfect teamwork! Both correct!';
      xpToAward = normalXp * 2;
    } else if (playerCorrect && !zamuCorrect) {
      msg = '🎓 You taught Zamu! Great job!';
      xpToAward = (normalXp * 1.5).round();
      state = state.copyWith(teachMoments: state.teachMoments + 1);
      _checkCoopTeacherBadge();
    } else if (!playerCorrect && zamuCorrect) {
      msg = _zamuExplanation();
      xpToAward = normalXp;
    } else {
      msg = '📖 Let\'s study this one together…';
      xpToAward = 0;
    }

    state = state.copyWith(zamuAnsweredCorrect: zamuCorrect, message: msg);
    await _ref.read(authProvider.notifier).addXp(xpToAward);
  }

  String _zamuExplanation() {
    const explanations = [
      'Zamu got it right! The key is to read carefully 🤓',
      'Zamu says: always check the financial impact first 💡',
      'Zamu got it! Remember your lessons from the sim 📚',
    ];
    return explanations[Random().nextInt(explanations.length)];
  }

  void _checkCoopTeacherBadge() {
    if (state.teachMoments >= 5) {
      _ref.read(badgeServiceProvider).awardById(kBadgeCoopTeacher);
    }
  }

  void reset() {
    state = state.copyWith(
      zamuAnsweredCorrect: null,
      message: 'Let\'s learn together! 📚',
    );
  }
}

final zamuProvider =
    StateNotifierProvider<ZamuNotifier, ZamuState>((ref) => ZamuNotifier(ref));
