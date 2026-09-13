/// offline_banner.dart
/// Purpose: A conditional banner that appears at the top of any screen
///          when the device has no internet connection. Since ZamWealth Quest
///          is designed to work fully offline, this banner is informational
///          (not a blocker) — it simply reassures the player that the app
///          works without connectivity.
/// Reads from: connectivity_plus stream
/// Writes to: nothing
/// Navigation: none
library;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zamwealth_quest/core/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Connectivity Provider
// ─────────────────────────────────────────────────────────────────────────────

/// A [StreamProvider] that emits the current [ConnectivityResult] whenever
/// the device's connectivity status changes.
///
/// Used by [OfflineBanner] to decide whether to render the banner.
final connectivityProvider =
    StreamProvider<List<ConnectivityResult>>((ref) async* {
  // Emit the current status immediately on first listen
  final initial = await Connectivity().checkConnectivity();
  yield initial;

  // Then stream subsequent changes
  yield* Connectivity().onConnectivityChanged;
});

/// Returns true when the app is offline (no WiFi and no mobile data).
bool _isOffline(List<ConnectivityResult> results) {
  return results.isEmpty || results.every((r) => r == ConnectivityResult.none);
}

// ─────────────────────────────────────────────────────────────────────────────
// OfflineBanner Widget
// ─────────────────────────────────────────────────────────────────────────────

/// [OfflineBanner] renders a narrow informational strip when the device
/// is offline. It collapses to zero height when the device is online.
///
/// Drop this widget at the top of any scrollable body:
/// ```dart
/// Column(
///   children: [
///     const OfflineBanner(),
///     // ... rest of screen content
///   ],
/// )
/// ```
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return connectivityAsync.when(
      data: (result) {
        final offline = _isOffline(result);

        // Use AnimatedSize so the banner slides in/out smoothly
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: offline
              ? _buildBanner(context)
              : const SizedBox.shrink(), // collapsed when online
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ── Banner ─────────────────────────────────────────────────────────────

  Widget _buildBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: kCharcoal.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_outlined,
            color: Colors.white70,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '📴 You\'re offline — ZamWealth Quest works fully without internet.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
