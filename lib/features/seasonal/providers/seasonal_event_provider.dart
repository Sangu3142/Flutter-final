library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';

@immutable
class SeasonalState {
  const SeasonalState({
    required this.activeEvent,
    required this.isCompleted,
  });

  final SeasonalEvent? activeEvent;
  final bool isCompleted;
}

class SeasonalNotifier extends StateNotifier<SeasonalState> {
  SeasonalNotifier(this._ref) : super(_buildInitial(_ref)) {
    _ref.listen<AuthState>(authProvider, (_, __) => _refresh());
  }

  final Ref _ref;

  static SeasonalState _buildInitial(Ref ref) {
    final now = DateTime.now();
    final event = kSeasonalEvents
        .where((e) => e.month == now.month)
        .cast<SeasonalEvent?>()
        .firstOrNull;

    final user = ref.read(currentUserProvider);
    final completed = event != null &&
        (user?.hasCompletedSeasonalEvent(event.id, now.year, now.month) ??
            false);

    return SeasonalState(activeEvent: event, isCompleted: completed);
  }

  void _refresh() {
    final now = DateTime.now();
    final event = kSeasonalEvents
        .where((e) => e.month == now.month)
        .cast<SeasonalEvent?>()
        .firstOrNull;

    final user = _ref.read(currentUserProvider);
    final completed = event != null &&
        (user?.hasCompletedSeasonalEvent(event.id, now.year, now.month) ??
            false);

    state = SeasonalState(activeEvent: event, isCompleted: completed);
  }

  Future<void> completeEvent() async {
    final event = state.activeEvent;
    if (event == null || state.isCompleted) return;

    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final now = DateTime.now();
    user.xp += event.xpBonus;
    user.zamCoins += event.zamCoinBonus;
    user.completeSeasonalEvent(event.id, now.year, now.month);
    await user.save();

    _ref.read(authProvider.notifier).refreshUser();
    _refresh();
  }
}

final seasonalProvider =
    StateNotifierProvider<SeasonalNotifier, SeasonalState>((ref) {
  return SeasonalNotifier(ref);
});
