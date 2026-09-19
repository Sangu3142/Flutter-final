/// tutorial_overlay.dart
/// Purpose: Tracks whether a given player has completed the first-run tutorial.
/// Reads from: Hive box 'settings'
/// Writes to: Hive box 'settings'
/// Navigation: none
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';

/// Legacy global completion key, shared by every account on the device.
///
/// Retained only so an existing install can be carried over to the per-user
/// key — see [isTutorialDone]. New writes always go to the per-user key.
const String kTutorialCompletedKey = 'tutorial_completed';

/// Per-user completion key.
///
/// SECURITY (audit issue 9): the flag used to be global, so the first account
/// to finish the tutorial silently marked it complete for every other account
/// on the same device.
String tutorialCompletedKeyFor(String uid) => '${kTutorialCompletedKey}_$uid';

/// Marks the tutorial complete for [uid].
Future<void> markTutorialComplete(String uid) async {
  if (uid.isEmpty) return;
  await Hive.box(kSettingsBox).put(tutorialCompletedKeyFor(uid), true);
}

/// True when [uid] has finished the tutorial.
///
/// Carries over the legacy global flag on first read, so players who completed
/// the tutorial before this change are not made to sit through it again.
bool isTutorialDone(String uid) {
  if (uid.isEmpty) return false;
  final box = Hive.box(kSettingsBox);
  final perUserKey = tutorialCompletedKeyFor(uid);

  final perUser = box.get(perUserKey);
  if (perUser is bool) return perUser;

  final legacy = box.get(kTutorialCompletedKey, defaultValue: false) as bool;
  if (legacy) {
    // One-time carry-over. The legacy key is left in place: a second account
    // on the same device inherits it once and then keeps its own flag.
    box.put(perUserKey, true);
    return true;
  }
  return false;
}

/// Clears the tutorial flag for [uid] so it replays.
///
/// Backs the user-facing "Replay Tutorial" button in Profile.
///
/// SECURITY (audit issue 3): never call this — or any `delete` on the tutorial
/// keys — unconditionally at startup. A dev-only force-reset left in `main()`
/// would push every player through the tutorial on every launch. If one is
/// needed for QA, gate it behind `kDebugMode`.
Future<void> resetTutorial(String uid) async {
  if (uid.isEmpty) return;
  await Hive.box(kSettingsBox).put(tutorialCompletedKeyFor(uid), false);
}
