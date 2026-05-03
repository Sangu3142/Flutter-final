/// profile_provider.dart
/// Purpose: Provides the Profile tab's state — user details, payment history,
///          and the dev-screen tap counter for the easter egg.
/// Reads from: authProvider, paymentProvider, Hive 'payments'
/// Writes to: nothing directly (delegates to authProvider)
/// Navigation: none
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/payments/models/payment_record.dart';

/// Returns payment history for the current user, sorted newest first.
final paymentHistoryProvider = Provider<List<PaymentRecord>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  try {
    final box = Hive.box<PaymentRecord>(kPaymentBox);
    return box.values.where((r) => r.uid == user.uid).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  } catch (_) {
    return [];
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// Dev Screen Tap Counter
// ─────────────────────────────────────────────────────────────────────────────

/// State notifier tracking how many times the version label has been tapped.
/// After [kDevScreenTapCount] taps, the dev screen is unlocked.
class DevTapNotifier extends StateNotifier<int> {
  DevTapNotifier() : super(0);

  /// Increments the tap count. Returns true if the dev screen should open.
  bool tap() {
    state++;
    if (state >= kDevScreenTapCount) {
      state = 0; // reset counter
      return true;
    }
    return false;
  }

  void reset() => state = 0;
}

/// Provider for the dev screen tap counter.
final devTapProvider = StateNotifierProvider<DevTapNotifier, int>((ref) {
  return DevTapNotifier();
});
