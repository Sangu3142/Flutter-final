/// life_events_provider.dart
/// Purpose: Manages the daily life event trigger logic. On app load it checks
///          whether to trigger a new event (70% chance if none shown today),
///          picks one from the pool, and exposes the pending event to the UI.
///          Applying a choice updates family/business/wallet as appropriate.
library;

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/business/providers/business_provider.dart';
import 'package:zamwealth_quest/features/family/providers/family_provider.dart';
import 'package:zamwealth_quest/features/life_events/models/life_event.dart';
import 'package:zamwealth_quest/features/life_events/models/life_event_record.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class LifeEventsState {
  const LifeEventsState({
    this.pendingEvent,
    this.lastEvent,
    this.record,
    this.isLoading = false,
  });

  /// The event waiting for the user to choose (null = no pending event).
  final LifeEvent? pendingEvent;

  /// The most recently completed event (for the home card display).
  final LifeEvent? lastEvent;

  final LifeEventRecord? record;
  final bool isLoading;

  LifeEventsState copyWith({
    LifeEvent? pendingEvent,
    LifeEvent? lastEvent,
    LifeEventRecord? record,
    bool? isLoading,
    bool clearPending = false,
  }) {
    return LifeEventsState(
      pendingEvent: clearPending ? null : (pendingEvent ?? this.pendingEvent),
      lastEvent: lastEvent ?? this.lastEvent,
      record: record ?? this.record,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class LifeEventsNotifier extends StateNotifier<LifeEventsState> {
  LifeEventsNotifier(this._box, this._ref) : super(const LifeEventsState()) {
    _load();
  }

  final Box<LifeEventRecord> _box;
  final Ref _ref;

  String get _uid => _ref.read(currentUserProvider)?.uid ?? '';

  // ── Load & trigger check ───────────────────────────────────────────────────

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    final uid = _uid;
    if (uid.isEmpty) {
      state = const LifeEventsState();
      return;
    }

    LifeEventRecord record = _box.get(uid) ??
        LifeEventRecord(uid: uid);
    if (!_box.containsKey(uid)) await _box.put(uid, record);

    // Restore last event for home card
    LifeEvent? lastEvent;
    if (record.lastEventId >= 0 && record.lastEventId < kLifeEvents.length) {
      lastEvent = kLifeEvents[record.lastEventId];
    }

    // Roll for today's event
    LifeEvent? pendingEvent;
    if (!record.triggeredToday) {
      final roll = Random().nextDouble();
      if (roll < kLifeEventTriggerChance) {
        pendingEvent = _pickEvent(record);
      }
    }

    state = LifeEventsState(
      pendingEvent: pendingEvent,
      lastEvent: lastEvent,
      record: record,
      isLoading: false,
    );
  }

  // ── Pick an event from the pool ────────────────────────────────────────────

  LifeEvent _pickEvent(LifeEventRecord record) {
    final history = record.eventHistory;
    // If we've shown all events, reset history
    if (history.length >= kLifeEvents.length) {
      history.clear();
    }
    final available = kLifeEvents
        .where((e) => !history.contains(e.id))
        .toList();
    return available[Random().nextInt(available.length)];
  }

  // ── Apply a choice ─────────────────────────────────────────────────────────

  Future<void> applyChoice(LifeEvent event, LifeEventChoice choice) async {
    final record = state.record;
    if (record == null) return;

    // Apply the effect
    switch (choice.effect) {
      case LifeEventEffect.walletGain:
        await _ref
            .read(authProvider.notifier)
            .addWalletCoins(choice.effectAmount);
      case LifeEventEffect.walletLoss:
        await _ref
            .read(authProvider.notifier)
            .spendWalletCoins(choice.effectAmount);
      case LifeEventEffect.happinessGain:
        await _ref
            .read(familyProvider.notifier)
            .applyHappinessDelta(
                choice.effectAmount, '${event.emoji} ${event.title}');
      case LifeEventEffect.happinessLoss:
        await _ref
            .read(familyProvider.notifier)
            .applyHappinessDelta(
                -choice.effectAmount, '${event.emoji} ${event.title}');
      case LifeEventEffect.healthGain:
        await _ref
            .read(familyProvider.notifier)
            .applyHappinessDelta(
                choice.effectAmount ~/ 2, '${event.emoji} ${event.title}');
      case LifeEventEffect.healthLoss:
        await _ref
            .read(familyProvider.notifier)
            .applyHappinessDelta(
                -(choice.effectAmount ~/ 2), '${event.emoji} ${event.title}');
      case LifeEventEffect.complianceGain:
        await _ref
            .read(businessProvider.notifier)
            .applyComplianceDelta(
                choice.effectAmount, '${event.emoji} ${event.title}');
      case LifeEventEffect.complianceLoss:
        await _ref
            .read(businessProvider.notifier)
            .applyComplianceDelta(
                -choice.effectAmount, '${event.emoji} ${event.title}');
      case LifeEventEffect.none:
        break;
    }

    // Mark event as shown
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    record
      ..lastEventDateStr = todayStr
      ..lastEventId = event.id;
    if (!record.eventHistory.contains(event.id)) {
      record.eventHistory.add(event.id);
    }
    await record.save();

    state = state.copyWith(
      lastEvent: event,
      record: record,
      clearPending: true,
    );
  }

  /// Dismiss a pending event without applying any effect.
  Future<void> dismissEvent(LifeEvent event) async {
    final record = state.record;
    if (record == null) return;
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    record
      ..lastEventDateStr = todayStr
      ..lastEventId = event.id;
    if (!record.eventHistory.contains(event.id)) {
      record.eventHistory.add(event.id);
    }
    await record.save();
    state = state.copyWith(lastEvent: event, record: record, clearPending: true);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final lifeEventsProvider =
    StateNotifierProvider<LifeEventsNotifier, LifeEventsState>((ref) {
  final box = Hive.box<LifeEventRecord>(kLifeEventsBox);
  final notifier = LifeEventsNotifier(box, ref);

  ref.listen(authProvider, (prev, next) {
    if (next.currentUser?.uid != prev?.currentUser?.uid) {
      notifier._load();
    }
  });

  return notifier;
});
