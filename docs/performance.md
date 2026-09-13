# Performance Audit

This document catalogues all performance concerns identified in the ZamWealth Quest codebase. Issues are ordered by severity.

---

## Issue 1 — addPostFrameCallback Called 3× Inside HeartsHUD.build()

**Severity:** HIGH

**Location:** `lib/features/hearts/widgets/hearts_hud.dart` lines ~96, ~104, ~111

**Description:** Three separate `WidgetsBinding.instance.addPostFrameCallback()` calls are made inside the `build()` method of `HeartsHUD`. This means every single time the widget rebuilds (which happens on every `heartsProvider` state change, and also whenever any ancestor rebuilds), three callbacks are queued for the next frame. Each callback then modifies animation controllers, which may trigger additional rebuilds.

In the worst case — if the dashboard screen rebuilds frequently (it watches 15+ providers) — the HeartsHUD is rebuilt many times per second, each time scheduling three post-frame callbacks.

**Additional problem:** `_prevHearts = count` is assigned inside `build()`. Mutating a field in `build()` is fragile — if Flutter calls `build()` multiple times within the same frame (e.g., during layout), `_prevHearts` is updated prematurely, suppressing animation triggers.

**Recommended Fix:**

```dart
// Move all addPostFrameCallback logic into didUpdateWidget or ref.listen
@override
void didUpdateWidget(covariant HeartsHUD oldWidget) {
  super.didUpdateWidget(oldWidget);
  // Not applicable for ConsumerStatefulWidget — use ref.listen instead
}

// In initState or build, register ref.listen ONCE:
// (ref.listen in ConsumerStatefulWidget is registered in build but only fires on change)
ref.listen<HeartsModel>(heartsProvider, (prev, next) {
  if (prev?.heartsCount != next.heartsCount) {
    _prevHearts = prev?.heartsCount ?? next.heartsCount;
    _triggerAnimations(prev?.heartsCount ?? next.heartsCount, next.heartsCount);
  }
});
```

`ref.listen` in a `ConsumerStatefulWidget.build()` is safe — it registers the listener once (not on every rebuild) and fires only when the listened value changes.

---

## Issue 2 — DashboardScreen Watches 15+ Providers

**Severity:** HIGH

**Location:** `lib/features/dashboard/screens/dashboard_screen.dart`

**Description:** `DashboardScreen` calls `ref.watch()` on approximately 15–20 providers. Any state change in any of these providers triggers a full rebuild of the entire dashboard widget tree. Since the dashboard is a `ConsumerStatefulWidget` with `TickerProviderStateMixin`, each rebuild is expensive (the build method is extremely long).

Providers watched include: `dashboardProvider`, `authProvider`, `dailyChallengeProvider`, `seasonalEventProvider`, `walletProvider`, `flashChallengeProvider`, `xpBoostProvider`, `badgeProvider`, `familyProvider`, `businessProvider`, `lifeEventsProvider`, `propertyProvider`, `portfolioProvider`, `loansProvider`, `savingsProvider`, `networthProvider`, `newsProvider`, `healthProvider`, `mentorProvider`, `dailyRoutineProvider`, `streakProvider`.

**Recommended Fix:**

Split the dashboard into smaller `ConsumerWidget` sub-widgets, each watching only the providers it needs. For example:
- `_WalletSection` watches only `walletProvider`
- `_StreakSection` watches only `globalStreakProvider`
- `_NetWorthSummary` watches only `networthProvider`

Each sub-widget rebuilds independently when its specific data changes, instead of the entire screen rebuilding.

Use `select` for providers where only one field is needed:

```dart
// Instead of:
final user = ref.watch(currentUserProvider);
// Use:
final xp = ref.watch(currentUserProvider.select((u) => u?.xp ?? 0));
```

---

## Issue 3 — addPostFrameCallback in DashboardScreen.build

**Severity:** HIGH

**Location:** `lib/features/dashboard/screens/dashboard_screen.dart` lines ~390, ~412

**Description:** Two `addPostFrameCallback` calls exist inside the dashboard's `build()` method. These fire on every rebuild — which is frequent given the 15+ providers the dashboard watches. Each callback may trigger dialog shows, navigation, or state updates that can in turn cause more rebuilds.

**Recommended Fix:** Move these to `initState()` or use `ref.listen()` inside build (which is called on every rebuild but only fires the callback when the listened value changes).

---

## Issue 4 — ProverbsScreen.build addPostFrameCallback

**Severity:** MEDIUM

**Location:** `lib/features/proverbs/screens/proverbs_screen.dart` line ~776

**Description:** `addPostFrameCallback` is called inside the `build()` method of `ProverbsScreen`. Every time the screen rebuilds (e.g., when `proverbUnlockProvider` emits), a callback is queued. If this callback shows a dialog or triggers navigation, it will fire on every rebuild, not just the first.

**Recommended Fix:** Move to `initState()` if it should fire once on screen open. Use `ref.listen()` if it should fire when a specific provider value changes.

---

## Issue 5 — Direct Hive.box() Reads in Build Methods

**Severity:** MEDIUM

**Location:**
- `lib/features/leaderboard/screens/leaderboard_screen.dart` — `Hive.box(kLeaderboardBox).get('entries')` in build
- `lib/features/dashboard/screens/dashboard_screen.dart` — `Hive.box(kSettingsBox).get(kTutorialCompletedKey)` in build
- `lib/features/dashboard/screens/dashboard_screen.dart` — `Hive.box(kSettingsBox).get('dc_dialog_shown_$uid')` in build
- `lib/features/dashboard/screens/dashboard_screen.dart` — `Hive.box(kSettingsBox).get('budget_alloc_$uid')` in build
- `lib/features/dashboard/screens/dashboard_screen.dart` — `Hive.box(kSettingsBox).get('budget_income_$uid')` in build
- `lib/features/profile/screens/profile_screen.dart` — `Hive.box(kSettingsBox).get(kTutorialCompletedKey)` in build

**Description:** Reading from a Hive box directly inside `build()` is not reactive. If the box value changes (e.g., a background process writes a new value), the UI will NOT update until the next unrelated rebuild. Additionally, it bypasses Riverpod's state management, creating two sources of truth.

While Hive reads are fast (O(1) in-memory map lookup), calling `Hive.box()` multiple times per build adds unnecessary overhead.

**Recommended Fix:** Wrap Hive direct reads in a Riverpod provider or use `ValueListenableBuilder(valueListenable: Hive.box(kSettingsBox).listenable(keys: [kTutorialCompletedKey]))` for reactive updates.

---

## Issue 6 — ZoneNodeWidget — 3 AnimationControllers Per Node, 4 Nodes Visible

**Severity:** MEDIUM

**Location:** `lib/features/levels/widgets/zone_node_widget.dart`

**Description:** Each `ZoneNodeWidget` creates 3 `AnimationController` instances (pulse, shake, tap). With 4 zone nodes visible on the level map simultaneously, that is 12 AnimationControllers active at once. The LOCKED and IN_PROGRESS nodes run their pulse controllers on `repeat(reverse: true)` indefinitely — this drives continuous widget rebuilds at 60fps for as long as the level map is visible.

The `RepaintBoundary` wrapping the `AnimatedBuilder` correctly limits the repaint scope to the node widget itself, so this does not cause full-screen repaints. However, the ticker callbacks still fire and consume CPU/battery.

**Recommended Fix:** Pause pulse animations when the `LevelMapScreen` is not the active tab (use `WidgetsBindingObserver.didChangeAppLifecycleState` or listen to the navigator). Stop pulsing for nodes that are fully LOCKED (player cannot interact with them at all).

---

## Issue 7 — MapPainter Static Cache

**Severity:** LOW

**Location:** `lib/features/levels/widgets/map_painter.dart`

**Description:** `MapPainter` uses `static` fields for path caching (`_cachedSize`, `_cachedPath`, `_cachedMetrics`, `_cachedTotalLength`). Static fields in Dart are class-scoped singletons. If `MapPainter` were ever instantiated in two different widget trees simultaneously (e.g., in a multi-window or multi-tab context), they would share and overwrite each other's cached path state.

**Current risk:** Flutter is single-threaded and this screen is a single tab — there is only one `MapPainter` instance at a time. The risk is theoretical.

**Recommended Fix:** Convert the static fields to instance fields. The cache is only valuable within a single animation frame anyway (the `paint` method is called once per frame per instance).

---

## Issue 8 — InventoryModel State Mutation Before Replacement

**Severity:** LOW

**Location:** `lib/features/shop/providers/inventory_provider.dart`

**Description:** `InventoryNotifier.addItem()` calls `state.powerUpsRaw[id] = ...` and `state.unlockedOutfits.add(id)` directly on the current state object before creating a new model and calling `await _save()`. This creates a window where the current `state` object is mutated but Riverpod has not yet been notified.

If Riverpod happens to call `build()` between the mutation and the `state = newModel` assignment (theoretically possible in edge cases), the UI could read inconsistent state.

**Recommended Fix:** Build the new model before mutating any state, then assign atomically:

```dart
// Instead of:
state.powerUpsRaw[id] = (state.powerUpsRaw[id] ?? 0) + 1;
await _save();
state = _buildModel(...);

// Do:
final updatedRaw = Map<dynamic, dynamic>.from(state.powerUpsRaw)
  ..[id] = (state.powerUpsRaw[id] ?? 0) + 1;
final newModel = InventoryModel(powerUpsRaw: updatedRaw, ...);
await _save(newModel);
state = newModel;
```

---

## Issue 9 — HeartsNotifier Fire-and-Forget in Constructor

**Severity:** LOW

**Location:** `lib/features/hearts/providers/hearts_provider.dart` — `HeartsNotifier` constructor

**Description:** `HeartsNotifier` calls `_applyRefill()` from its constructor as a fire-and-forget Future. This is intentional (documented by a comment) but has two side effects:
1. If `_applyRefill()` throws, the exception is silently swallowed.
2. The refill logic runs on every provider initialization — including during hot restart and after logout/login. This is probably correct but should be explicitly documented.

`timeUntilNextRefill()` also calls `_applyRefill()` with `// ignore: discarded_futures`. Any exception from this call is also silently lost.

**Recommended Fix:** Wrap in try/catch and log the error:

```dart
HeartsNotifier(this._box, this._uid) : super(_loadInitial(_box, _uid)) {
  _applyRefill().catchError((e) => debugPrint('HeartsNotifier: refill failed: $e'));
}
```

---

## Summary Table

| Issue | Severity | Location | Type |
|---|---|---|---|
| addPostFrameCallback × 3 in HeartsHUD.build | HIGH | hearts_hud.dart | Rebuild storm |
| DashboardScreen watches 15+ providers | HIGH | dashboard_screen.dart | Excessive rebuilds |
| addPostFrameCallback in DashboardScreen.build | HIGH | dashboard_screen.dart | Callback on rebuild |
| addPostFrameCallback in ProverbsScreen.build | MEDIUM | proverbs_screen.dart | Callback on rebuild |
| Direct Hive reads in build (5 locations) | MEDIUM | Multiple files | Stale data + overhead |
| 12 AnimationControllers on LevelMap (4 nodes × 3) | MEDIUM | zone_node_widget.dart | Continuous CPU drain |
| MapPainter static cache | LOW | map_painter.dart | Theoretical shared state |
| InventoryModel state mutation before replacement | LOW | inventory_provider.dart | Race window |
| HeartsNotifier fire-and-forget in constructor | LOW | hearts_provider.dart | Silent error suppression |
