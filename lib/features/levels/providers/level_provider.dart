/// level_provider.dart
/// Purpose: Owns the level state machine for all 4 game levels.
///          Handles all transitions: LOCKED → UNLOCKED → IN_PROGRESS → COMPLETED.
///          Seeding, reading, and writing all LevelModel objects in Hive.
/// Reads from: Hive box 'levels', 'users', authProvider
/// Writes to: Hive box 'levels', 'users' (XP, badges, zamCoins, unlockedLevels)
/// Navigation: none (state only — UI reacts via providers)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/models/user_profile.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/badges/providers/badge_provider.dart';
import 'package:zamwealth_quest/features/levels/models/level_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Level State
// ─────────────────────────────────────────────────────────────────────────────

/// Snapshot of all four [LevelModel]s for the current user, plus any error.
class LevelState {
  const LevelState({
    required this.levels,
    this.isLoading = false,
    this.error,
  });

  /// Map from levelId → [LevelModel]. Always contains keys 1–4 after seeding.
  final Map<int, LevelModel> levels;
  final bool isLoading;
  final String? error;

  LevelState copyWith({
    Map<int, LevelModel>? levels,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LevelState(
      levels: levels ?? this.levels,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Level Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// [LevelNotifier] manages all level state transitions.
///
/// State machine transitions are the ONLY place where level [status] changes:
///   LOCKED → UNLOCKED   : [unlockLevel]  (triggered by payment success)
///   UNLOCKED → IN_PROGRESS : [markSimulationComplete] (first sim done)
///   IN_PROGRESS → COMPLETED : [markSimulationComplete] (all sims done)
class LevelNotifier extends StateNotifier<LevelState> {
  LevelNotifier(this._ref) : super(const LevelState(levels: {})) {
    _init();
  }

  final Ref _ref;

  /// Returns the Hive 'levels' box (must be open).
  Box<LevelModel> get _levelBox => Hive.box<LevelModel>(kLevelBox);

  /// Returns the currently authenticated [UserProfile], or null.
  UserProfile? get _user => _ref.read(currentUserProvider);

  // ── Init & Seeding ────────────────────────────────────────────────────────

  /// Loads or seeds level models for the current user.
  void _init() {
    final user = _user;
    if (user == null) return;
    _seedLevels(user);
    _loadLevels(user);
  }

  /// Reloads level state — called after login or when user changes.
  void reload() {
    final user = _user;
    if (user == null) return;
    _seedLevels(user);
    _loadLevels(user);
  }

  /// Creates [LevelModel] entries in Hive for any levels that don't exist yet.
  ///
  /// Level 1 starts UNLOCKED (free). Levels 2–4 start LOCKED.
  void _seedLevels(UserProfile user) {
    for (final levelId in [1, 2, 3, 4]) {
      final key = _hiveKey(user.uid, levelId);
      if (!_levelBox.containsKey(key)) {
        // Determine initial status:
        // - Level 1 is always UNLOCKED (free)
        // - Other levels: UNLOCKED if already in user.unlockedLevels, else LOCKED
        final status = (levelId == 1 || user.hasUnlocked(levelId))
            ? kStatusUnlocked
            : kStatusLocked;

        try {
          _levelBox.put(key, LevelModel(levelId: levelId, status: status));
        } catch (e) {
          // Seeding failure is non-fatal — log and continue
          state =
              state.copyWith(error: 'Could not initialise level $levelId: $e');
        }
      } else {
        // If user has unlocked a level but the Hive model still says LOCKED,
        // correct the inconsistency (e.g. after a dev-screen reset + re-unlock).
        final model = _levelBox.get(key);
        if (model != null && model.isLocked && user.hasUnlocked(levelId)) {
          model.status = kStatusUnlocked;
          try {
            model.save();
          } catch (_) {}
        }
      }
    }
  }

  /// Reads all four [LevelModel]s from Hive into the in-memory state map.
  void _loadLevels(UserProfile user) {
    try {
      final map = <int, LevelModel>{};
      for (final levelId in [1, 2, 3, 4]) {
        final model = _levelBox.get(_hiveKey(user.uid, levelId));
        if (model != null) map[levelId] = model;
      }
      state = state.copyWith(levels: map, clearError: true);
    } catch (e) {
      state = state.copyWith(error: 'Could not load levels: $e');
    }
  }

  // ── State Machine Transitions ─────────────────────────────────────────────

  /// LOCKED → UNLOCKED transition.
  ///
  /// Called by [PaymentProvider] after a successful (simulated) payment.
  /// Also updates [UserProfile.unlockedLevels] and awards bonus ZamCoins.
  Future<void> unlockLevel(int levelId) async {
    final user = _user;
    if (user == null) return;

    final key = _hiveKey(user.uid, levelId);
    try {
      final model = _levelBox.get(key);
      if (model == null) return;

      // Guard: only LOCKED → UNLOCKED is valid here
      if (!model.isLocked) return;

      // Transition: LOCKED → UNLOCKED
      model.status = kStatusUnlocked;
      await model.save();

      // Persist unlock in UserProfile
      user.unlockLevel(levelId);
      user.addZamCoins(kPaymentBonusZamCoins); // bonus ZamCoins for paying
      await user.save();

      // Notify Riverpod of profile changes
      _ref.read(authProvider.notifier).refreshUser();

      // Update in-memory state
      _loadLevels(user);
    } catch (e) {
      state = state.copyWith(error: 'Could not unlock level $levelId: $e');
    }
  }

  /// Dev-only: force-unlock any level without payment.
  Future<void> devForceUnlock(int levelId) async {
    final user = _user;
    if (user == null) return;
    final key = _hiveKey(user.uid, levelId);
    try {
      var model = _levelBox.get(key);
      if (model == null) {
        model = LevelModel(levelId: levelId, status: kStatusUnlocked);
        await _levelBox.put(key, model);
      } else {
        model.status = kStatusUnlocked;
        await model.save();
      }
      user.unlockLevel(levelId);
      await user.save();
      _ref.read(authProvider.notifier).refreshUser();
      _loadLevels(user);
    } catch (e) {
      state = state.copyWith(error: 'Dev unlock failed: $e');
    }
  }

  /// Marks a simulation as completed and advances the level status machine.
  ///
  /// Transitions:
  ///   UNLOCKED → IN_PROGRESS  (first simulation marked complete)
  ///   IN_PROGRESS → COMPLETED (all simulations for the level marked complete)
  ///
  /// Awards XP to the [UserProfile] on full level completion and logs a badge.
  Future<void> markSimulationComplete(
    int levelId,
    String simulationId, {
    int score = 0,
    BuildContext? context,
  }) async {
    final user = _user;
    if (user == null) return;

    final key = _hiveKey(user.uid, levelId);
    try {
      final model = _levelBox.get(key);
      if (model == null) return;

      // Guard: can only progress an accessible level
      if (!model.isAccessible) return;

      // Add simulation to completed list if not already there
      if (!model.hasCompletedSim(simulationId)) {
        model.completedSimulations = [
          ...model.completedSimulations,
          simulationId,
        ];
      }

      // Retrieve the expected list of simulations for this level
      final meta = kLevelMeta[levelId];
      if (meta == null) return;
      final allSims = meta.simulations;

      // Determine new status
      final allDone = allSims.every(model.hasCompletedSim);

      if (allDone && !model.isCompleted) {
        // ── TRANSITION: IN_PROGRESS / UNLOCKED → COMPLETED ──────────────
        model.status = kStatusCompleted;
        model.xpEarned = meta.xpReward;

        // Award XP to the player
        user.addXp(meta.xpReward);

        // Update currentLevel if this is the highest completed level
        if (levelId > user.currentLevel) {
          user.currentLevel = levelId;
        }

        await user.save();
        _ref.read(authProvider.notifier).refreshUser();
      } else if (model.status == kStatusUnlocked) {
        // ── TRANSITION: UNLOCKED → IN_PROGRESS ──────────────────────────
        model.status = kStatusInProgress;
      }
      // If already IN_PROGRESS and not all done, status stays IN_PROGRESS.

      await model.save();

      // ── Collect all sims the user has now completed across all levels ──
      final completedSims = <String>{};
      for (final id in [1, 2, 3, 4]) {
        final r = _levelBox.get(_hiveKey(user.uid, id));
        if (r != null) completedSims.addAll(r.completedSimulations);
      }
      completedSims.add(simulationId);

      // Check if this completes the level
      int? justCompletedLevel;
      if (allDone) justCompletedLevel = meta.id;

      _ref.read(badgeServiceProvider).checkAndAward(
        completedSimId: simulationId,
        newXp: user.xp,
        completedSimIds: completedSims,
        completedLevelNumber: justCompletedLevel,
        taxQuizPerfect: (simulationId == 'tax_quiz' && score == 100),
        context: (context != null && context.mounted) ? context : null,
      );

      _loadLevels(user);
    } catch (e) {
      state = state.copyWith(error: 'Could not save simulation progress: $e');
    }
  }

  // ── Convenience Getters ───────────────────────────────────────────────────

  /// Returns the [LevelModel] for a given [levelId], or null.
  LevelModel? getLevel(int levelId) => state.levels[levelId];

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Composite Hive key — ensures each user has their own level records.
  String _hiveKey(String uid, int levelId) => '${uid}_$levelId';
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Global [StateNotifierProvider] for level state.
final levelProvider = StateNotifierProvider<LevelNotifier, LevelState>((ref) {
  final notifier = LevelNotifier(ref);
  // Re-initialise levels when the auth state changes (e.g. user logs in/out)
  ref.listen(authProvider, (prev, next) {
    if (next.currentUser?.uid != prev?.currentUser?.uid) {
      notifier.reload();
    }
  });
  return notifier;
});

/// Convenience provider — returns a single [LevelModel] by [levelId].
final singleLevelProvider = Provider.family<LevelModel?, int>((ref, levelId) {
  return ref.watch(levelProvider).levels[levelId];
});
