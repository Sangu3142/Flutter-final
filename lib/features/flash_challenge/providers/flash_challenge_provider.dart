// lib/features/flash_challenge/providers/flash_challenge_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlashChallengeState {
  final bool isActive;
  final DateTime? windowStart;
  final DateTime? windowEnd;

  const FlashChallengeState({
    required this.isActive,
    this.windowStart,
    this.windowEnd,
  });
}

class FlashChallengeNotifier extends StateNotifier<FlashChallengeState> {
  FlashChallengeNotifier() : super(const FlashChallengeState(isActive: false)) {
    _checkWindow();
  }

  // Active windows: 08:00-10:00 and 18:00-20:00 local time
  static final List<(int startHour, int endHour)> _windows = [
    (8, 10),
    (18, 20),
  ];

  void _checkWindow() {
    final now = DateTime.now();
    for (final (start, end) in _windows) {
      final windowStart =
          DateTime(now.year, now.month, now.day, start);
      final windowEnd =
          DateTime(now.year, now.month, now.day, end);
      if (now.isAfter(windowStart) && now.isBefore(windowEnd)) {
        state = FlashChallengeState(
          isActive: true,
          windowStart: windowStart,
          windowEnd: windowEnd,
        );
        return;
      }
    }
    state = const FlashChallengeState(isActive: false);
  }

  void refresh() => _checkWindow();

  Duration? timeUntilNextWindow() {
    final now = DateTime.now();
    for (final (start, _) in _windows) {
      final windowStart =
          DateTime(now.year, now.month, now.day, start);
      if (windowStart.isAfter(now)) {
        return windowStart.difference(now);
      }
    }
    final tomorrowWindow = DateTime(
        now.year, now.month, now.day + 1, _windows.first.$1);
    return tomorrowWindow.difference(now);
  }
}

final flashChallengeProvider =
    StateNotifierProvider<FlashChallengeNotifier, FlashChallengeState>(
        (ref) => FlashChallengeNotifier());
