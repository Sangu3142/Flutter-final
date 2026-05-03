/// payment_provider.dart
/// Purpose: Manages the simulated payment flow — triggers the 2-second
///          auto-approval delay, writes PaymentRecord to Hive, unlocks the
///          level via LevelNotifier, and awards bonus ZamCoins.
/// Reads from: Hive box 'payments', authProvider, levelProvider
/// Writes to: Hive box 'payments', levelProvider (unlock), authProvider (zamCoins)
/// Navigation: none (UI navigates based on state)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/levels/providers/level_provider.dart';
import 'package:zamwealth_quest/features/payments/models/payment_record.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Payment State
// ─────────────────────────────────────────────────────────────────────────────

/// Describes the phase of the simulated payment flow.
enum PaymentPhase {
  /// No payment in progress — default state.
  idle,

  /// Payment is processing (2-second simulated delay).
  processing,

  /// Payment succeeded — level unlocked.
  success,

  /// Payment failed (only triggered by storage errors in sandbox mode).
  failure,
}

/// Immutable snapshot of the payment flow state.
class PaymentState {
  const PaymentState({
    this.phase = PaymentPhase.idle,
    this.error,
    this.lastPaymentId,
  });

  final PaymentPhase phase;
  final String? error;

  /// UUID of the most recently completed payment record.
  final String? lastPaymentId;

  bool get isProcessing => phase == PaymentPhase.processing;
  bool get isSuccess => phase == PaymentPhase.success;
  bool get isFailure => phase == PaymentPhase.failure;

  PaymentState copyWith({
    PaymentPhase? phase,
    String? error,
    String? lastPaymentId,
    bool clearError = false,
  }) {
    return PaymentState(
      phase: phase ?? this.phase,
      error: clearError ? null : (error ?? this.error),
      lastPaymentId: lastPaymentId ?? this.lastPaymentId,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// [PaymentNotifier] owns the simulated payment flow.
///
/// Flow:
///   1. [initiatePayment] called → state = processing
///   2. 2-second [kPaymentDelayMs] delay (simulating a real MoMo API call)
///   3. [PaymentRecord] written to Hive
///   4. [LevelNotifier.unlockLevel] called → level status → UNLOCKED
///   5. state = success
class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier(this._ref) : super(const PaymentState());

  final Ref _ref;
  final _uuid = const Uuid();

  Box<PaymentRecord> get _paymentBox => Hive.box<PaymentRecord>(kPaymentBox);

  /// Starts the simulated payment flow for the given [levelId] and [provider].
  ///
  /// [provider] must be [kProviderMTN] or [kProviderAirtel].
  Future<void> initiatePayment({
    required int levelId,
    required String provider,
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final meta = kLevelMeta[levelId];
    if (meta == null || meta.isFree) return;

    // Transition to processing state — UI shows spinner + SIMULATED PAYMENT banner
    state = const PaymentState(phase: PaymentPhase.processing);

    try {
      // ── SIMULATED PAYMENT DELAY ─────────────────────────────────────────
      // No real API call is made. This delay mimics a real MoMo payment
      // confirmation flow. The SIMULATED PAYMENT banner is shown in the UI.
      await Future.delayed(const Duration(milliseconds: kPaymentDelayMs));

      // Generate a unique payment ID
      final paymentId = _uuid.v4();

      // Write the payment record to Hive audit log
      final record = PaymentRecord(
        paymentId: paymentId,
        uid: user.uid,
        tier: 'Level $levelId — ${meta.name}',
        amountZMW: meta.price,
        provider: provider,
        sandboxMode: true, // always true in this release
      );

      await _paymentBox.put(paymentId, record);

      // ── Unlock the level via LevelNotifier ─────────────────────────────
      // This triggers the LOCKED → UNLOCKED state machine transition and
      // also awards kPaymentBonusZamCoins to the UserProfile.
      await _ref.read(levelProvider.notifier).unlockLevel(levelId);

      // Transition to success state — UI shows success dialog
      state = state.copyWith(
        phase: PaymentPhase.success,
        lastPaymentId: paymentId,
        clearError: true,
      );
    } catch (e) {
      // Storage or state machine error — report failure
      state = state.copyWith(
        phase: PaymentPhase.failure,
        error: 'Payment processing failed: ${e.toString()}',
      );
    }
  }

  /// Resets the payment state back to idle (e.g. after dismissing the dialog).
  void reset() {
    state = const PaymentState();
  }

  /// Returns all payment records for the current user from Hive.
  List<PaymentRecord> historyForUser(String uid) {
    try {
      return _paymentBox.values.where((r) => r.uid == uid).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (_) {
      return [];
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Global [StateNotifierProvider] for payment state.
final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(ref);
});
