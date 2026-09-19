/// app_flags.dart
/// Purpose: Build-mode gated feature flags. Anything that must never be
///          reachable in a release build is decided here and nowhere else.
/// Reads from: Hive box 'settings' (sandbox toggle only)
/// Writes to: nothing
/// Navigation: none
library;

import 'package:flutter/foundation.dart' show kDebugMode, kProfileMode;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';

/// True only in debug and profile builds.
///
/// Gates every developer-facing surface: the `/profile/dev` route, the 7-tap
/// easter egg that opens it, and the sandbox toggle. Because `kDebugMode` and
/// `kProfileMode` are compile-time constants, the Dart compiler tree-shakes
/// the guarded code out of a release build entirely — a release APK does not
/// merely hide the dev console, it does not contain a route to it.
bool get isDevSurfaceEnabled => kDebugMode || kProfileMode;

/// True when payment sandbox mode is active.
///
/// Requires **both** a non-release build and the stored settings flag. A user
/// who flips the Hive value on a release build gets nothing: the build-mode
/// check short-circuits first. (Security audit issue 7.)
bool get isSandboxMode {
  if (!isDevSurfaceEnabled) return false;
  try {
    return Hive.box(kSettingsBox).get(kSandboxModeKey, defaultValue: false)
        as bool;
  } catch (_) {
    // Box not open yet (e.g. called before init) — fail closed.
    return false;
  }
}

/// Persists the sandbox toggle. No-op outside debug/profile builds.
Future<void> setSandboxMode(bool enabled) async {
  if (!isDevSurfaceEnabled) return;
  await Hive.box(kSettingsBox).put(kSandboxModeKey, enabled);
}
