/// payment_record.dart
/// Purpose: Defines the PaymentRecord Hive model — a permanent audit log entry
///          written when a player completes a simulated level-unlock payment.
/// Reads from: Hive box 'payments'
/// Writes to: Hive box 'payments'
/// Navigation: none (data model only)
library;

import 'package:hive/hive.dart';

part 'payment_record.g.dart';

/// [PaymentRecord] is an immutable audit entry created each time a player
/// completes the payment flow to unlock a level.
///
/// Stored in the 'payments' Hive box, keyed by [paymentId].
///
/// [sandboxMode] is always true in the current release — no real API calls
/// are made. The SIMULATED PAYMENT banner in the UI makes this transparent
/// to the user.
@HiveType(typeId: 2)
class PaymentRecord extends HiveObject {
  PaymentRecord({
    required this.paymentId,
    required this.uid,
    required this.tier,
    required this.amountZMW,
    required this.provider,
    String? timestampStr,
    this.sandboxMode = true,
  }) : timestampStr = timestampStr ?? DateTime.now().toIso8601String();

  /// UUID-formatted unique identifier for this payment record.
  @HiveField(0)
  String paymentId;

  /// Username of the player who made the payment.
  @HiveField(1)
  String uid;

  /// The level tier purchased (e.g. 'Level 2 — Woodlands Heights').
  @HiveField(2)
  String tier;

  /// Amount paid in ZMW (e.g. 25.0 for Level 2).
  @HiveField(3)
  double amountZMW;

  /// Payment provider chosen by the player: 'MTN MoMo' or 'Airtel Money'.
  @HiveField(4)
  String provider;

  /// ISO-8601 string of when the payment was processed.
  /// Use the [timestamp] getter for [DateTime] access.
  @HiveField(5)
  String timestampStr;

  /// Always true — payment is simulated. No real money is transferred.
  @HiveField(6)
  bool sandboxMode;

  // ── Computed Accessors ────────────────────────────────────────────────────

  /// Returns [timestampStr] as a [DateTime] object.
  DateTime get timestamp => DateTime.parse(timestampStr);

  @override
  String toString() => 'PaymentRecord(id: $paymentId, uid: $uid, tier: $tier, '
      'amount: ZMW $amountZMW, provider: $provider, sandbox: $sandboxMode)';
}
