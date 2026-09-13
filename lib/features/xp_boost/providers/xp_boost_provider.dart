/// xp_boost_provider.dart
/// Purpose: Manages the temporary 2× XP boost state — activated on app open
///          (30% chance) or on a login-streak milestone.
/// Reads from: auth state (persisted xpBoostExpiry on UserProfile)
/// Writes to: auth state via AuthNotifier.setXpBoostExpiry
/// Navigation: none (provider only)
library;

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// XpBoost State
// ─────────────────────────────────────────────────────────────────────────────

class XpBoostState {
  final bool isActive;
  final DateTime? expiry;

  const XpBoostState({this.isActive = false, this.expiry});

  /// How long until the boost expires. Returns [Duration.zero] if inactive.
  Duration get remaining =>
      expiry != null ? expiry!.difference(DateTime.now()) : Duration.zero;
}

// ─────────────────────────────────────────────────────────────────────────────
// XpBoost Notifier
// ─────────────────────────────────────────────────────────────────────────────

class XpBoostNotifier extends StateNotifier<XpBoostState> {
  final Ref _ref;

  XpBoostNotifier(this._ref) : super(const XpBoostState()) {
    _init();
  }

  void _init() {
    final user = _ref.read(currentUserProvider);
    if (user?.xpBoostExpiry != null) {
      final expiry = DateTime.tryParse(user!.xpBoostExpiry!);
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        state = XpBoostState(isActive: true, expiry: expiry);
        return;
      }
      _clearExpiry();
    }
    // 30% chance on app open to grant a 10-minute boost
    if (Random().nextDouble() < 0.3) {
      _activateBoost();
    }
  }

  void _activateBoost() {
    final expiry = DateTime.now().add(const Duration(minutes: 10));
    state = XpBoostState(isActive: true, expiry: expiry);
    _ref.read(authProvider.notifier).setXpBoostExpiry(expiry.toIso8601String());
  }

  void _clearExpiry() {
    _ref.read(authProvider.notifier).setXpBoostExpiry(null);
  }

  /// Called by the streak system to award a boost on milestone streaks.
  void triggerStreakBoost() => _activateBoost();

  /// Called periodically (e.g. from a timer or UI rebuild) to expire the boost.
  void tick() {
    if (!state.isActive || state.expiry == null) return;
    if (DateTime.now().isAfter(state.expiry!)) {
      state = const XpBoostState(isActive: false);
      _clearExpiry();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final xpBoostProvider =
    StateNotifierProvider<XpBoostNotifier, XpBoostState>(
  (ref) => XpBoostNotifier(ref),
);
