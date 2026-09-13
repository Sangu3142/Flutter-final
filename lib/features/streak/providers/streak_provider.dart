/// streak_provider.dart
/// Purpose: Exposes current streak, shield count, and last active date
///          so any widget can reactively display streak UI.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/services/streak_service.dart';

class StreakState {
  const StreakState({
    this.streak = 0,
    this.shieldCount = 0,
    this.lastActiveDate = '',
  });

  final int streak;
  final int shieldCount;
  final String lastActiveDate;

  StreakState copyWith({int? streak, int? shieldCount, String? lastActiveDate}) =>
      StreakState(
        streak: streak ?? this.streak,
        shieldCount: shieldCount ?? this.shieldCount,
        lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      );
}

class StreakNotifier extends StateNotifier<StreakState> {
  StreakNotifier(this._ref) : super(const StreakState()) {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.currentUser?.uid != next.currentUser?.uid) _load();
    });
    _load();
  }

  final Ref _ref;

  String? get _uid => _ref.read(currentUserProvider)?.uid;

  void _load() {
    final uid = _uid;
    if (uid == null) {
      state = const StreakState();
      return;
    }
    final data = StreakService.read(uid);
    state = StreakState(
      streak: data.streak,
      shieldCount: data.shields,
      lastActiveDate: data.lastDate,
    );
  }

  /// Called by quiz/challenge completions after StreakService.recordActivity().
  void refresh() => _load();
}

final globalStreakProvider =
    StateNotifierProvider<StreakNotifier, StreakState>((ref) {
  return StreakNotifier(ref);
});
