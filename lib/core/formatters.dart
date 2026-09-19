/// formatters.dart
/// Purpose: Shared value formatting helpers used across screens and providers.
/// Reads from: nothing
/// Writes to: nothing
/// Navigation: none
library;

/// Abbreviates a whole number with a `K` / `M` suffix.
///
/// Thresholds and decimal places are unchanged from the three call sites this
/// replaced (Net Worth screen, Property provider, Dashboard HUD):
///   • `>= 1000000` → one decimal place + `M`  (1500000 → `1.5M`)
///   • `>= 1000`    → no decimal places + `K`  (1500    → `2K`)
///   • otherwise    → the plain integer        (999     → `999`)
///
/// Negative values fall through to the plain-integer branch, so `-5000` returns
/// `-5000`, not `-5K`. Callers that want a signed abbreviation apply the sign
/// themselves and pass `value.abs()` — see the Dashboard HUD net-worth cell.
String compactNumber(int v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
  return '$v';
}
