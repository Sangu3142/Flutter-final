/// level_model.dart
/// Purpose: Defines the LevelModel Hive model — stores per-user, per-level
///          progress including status, completed simulations, and XP earned.
/// Reads from: Hive box 'levels'
/// Writes to: Hive box 'levels'
/// Navigation: none (data model only)
library;

import 'package:hive/hive.dart';
import 'package:zamwealth_quest/core/constants.dart';

part 'level_model.g.dart';

/// [LevelModel] tracks a single player's progress within one game level.
///
/// The Hive box key for a LevelModel is `"<uid>_<levelId>"`, e.g. `"chanda_1"`.
///
/// State machine transitions (managed exclusively by [LevelProvider]):
/// ```
/// LOCKED → UNLOCKED  (payment processed, or free level on first launch)
/// UNLOCKED → IN_PROGRESS  (first simulation completed)
/// IN_PROGRESS → COMPLETED  (all simulations for the level completed)
/// ```
@HiveType(typeId: 1)
class LevelModel extends HiveObject {
  LevelModel({
    required this.levelId,
    required this.status,
    List<String>? completedSimulations,
    this.xpEarned = 0,
  }) : completedSimulations = completedSimulations ?? [];

  /// The game-level ID (1–4).
  @HiveField(0)
  int levelId;

  /// Current state of this level for the owning player.
  /// Valid values: [kStatusLocked], [kStatusUnlocked],
  ///               [kStatusInProgress], [kStatusCompleted].
  @HiveField(1)
  String status;

  /// List of simulation IDs the player has completed in this level.
  /// Simulation IDs are defined as `kSim*` constants in constants.dart.
  @HiveField(2)
  List<String> completedSimulations;

  /// Total XP awarded to the player for this level (0 until fully completed).
  @HiveField(3)
  int xpEarned;

  // ── Computed Helpers ──────────────────────────────────────────────────────

  /// True if this level is currently locked (requires payment).
  bool get isLocked => status == kStatusLocked;

  /// True if the player may enter this level.
  bool get isAccessible =>
      status == kStatusUnlocked ||
      status == kStatusInProgress ||
      status == kStatusCompleted;

  /// True if every simulation in the level has been completed.
  bool get isCompleted => status == kStatusCompleted;

  /// Returns true if [simulationId] has been marked complete.
  bool hasCompletedSim(String simulationId) =>
      completedSimulations.contains(simulationId);

  @override
  String toString() => 'LevelModel(levelId: $levelId, status: $status, '
      'completed: ${completedSimulations.length} sims, xp: $xpEarned)';
}
