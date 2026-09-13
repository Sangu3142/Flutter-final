# Bug History

All documented bugs in ZamWealth Quest, in chronological order. Each entry records the symptom, root cause, fix applied, and the rule to follow to prevent recurrence.

---

## Bug 1 — Hearts State Not Updating UI

**Symptom:** Hearts count displayed in `HeartsHUD` did not update after a heart was lost. The internal Hive state was correct but the UI showed the old count.

**Root Cause:** `HeartsModel` was being mutated directly (`model.heartsCount--`) before calling `box.put()`. Riverpod detects state changes by reference equality — mutating the existing object meant the new state was `==` to the old state, so Riverpod did not notify listeners.

**Fix:** `HeartsNotifier` now creates a new `HeartsModel` instance on every state change using `copyWith()` or a constructor call. Riverpod detects the new object reference and triggers all listeners.

**Lesson:** Never mutate a Hive model object directly. Always create a new model instance and call `state = newModel`. For Riverpod to detect state changes, the new state must be a different object reference (or implement `==` / `hashCode` correctly).

---

## Bug 2 — Level Map Path Re-animating on Every Tab Switch

**Symptom:** Every time the user tapped away from the Levels tab and returned, the animated path connecting level nodes played its entrance animation again from the start.

**Root Cause:** The `_pathCtrl.forward(from: 0)` was called from `initState()` of `LevelMapScreen`. Because the ShellRoute creates a new widget tree on each tab switch (the child is not preserved), `initState()` ran on every visit.

**Fix:** Moved the animation trigger to a `ref.listen()` on `levelProvider`. The animation only plays when a new level is actually unlocked (state changes from LOCKED → IN_PROGRESS), not on every screen initialization.

**Lesson:** Do not start animations in `initState()` for screens inside a ShellRoute — they will replay on every tab switch. Use `ref.listen()` to trigger animations only when meaningful state changes occur.

---

## Bug 3 — Daily Challenge Dialog Appearing Multiple Times Per Day

**Symptom:** The daily challenge prompt appeared every time the user returned to the home screen, even if they had already dismissed it that day.

**Root Cause:** The "dialog shown" check read `kSettingsBox.get('dc_dialog_shown_$uid')` but the key was being written as a `DateTime` object instead of a date string, causing the date comparison to always fail.

**Fix:** Changed the write to store a formatted date string `'yyyy-MM-dd'` and the comparison to parse using the same format.

**Lesson:** Store dates in Hive as formatted strings (`yyyy-MM-dd`), not as `DateTime` objects. Hive does not natively serialize `DateTime` — it stores them as strings anyway via `toString()`, making comparisons fragile.

---

## Bug 4 — Shop Purchase Not Persisting After App Restart

**Symptom:** Items bought in the Shop were visible in the current session but disappeared after restarting the app.

**Root Cause:** `InventoryNotifier.addItem()` mutated `state.unlockedOutfits` (a `List<String>`) directly with `.add(id)` but the `_save()` call was missing an `await`. Navigation away from the ShopScreen happened before the Hive write completed.

**Fix:** Added `await _save()` and ensured the notifier waits for the write before emitting the new state. Navigation in ShopScreen was guarded with `if (!mounted) return` after the await.

**Lesson:** Always await Hive writes before navigating. Use `if (context.mounted)` after every `await` that is followed by navigation.

---

## Bug 5 — Streak Not Incrementing on Second Login

**Symptom:** The streak counter incremented correctly on the first login after a gap but did not increment on the second day.

**Root Cause:** The streak date comparison used `DateTime.now()` which includes time of day. If the user logged in at 11:58pm on Day 1 and 12:02am on Day 2, the difference was still less than 24 hours, so the "new day" condition failed.

**Fix:** Changed the comparison to use date-only strings (`yyyy-MM-dd`) — if today's date string is different from the stored `'<uid>_lastDate'` string, it is a new day regardless of time.

**Lesson:** For "once per day" logic, always compare date strings, not `DateTime` objects. Use `DateFormat('yyyy-MM-dd').format(DateTime.now())`.

---

## Bug 6 — Season Banner Showing "0 Days Remaining"

**Symptom:** The season end banner on the dashboard showed "0 days remaining" on the last day of a season instead of a more informative message.

**Root Cause:** The banner text was `'${daysLeft} days remaining'` where `daysLeft` was computed as `endDate.difference(DateTime.now()).inDays`. On the final day, this computed to 0 and displayed literally as "0 days remaining".

**Fix:** Added a special-case check: if `daysLeft == 0`, display "Season ends today!" instead of "0 days remaining".

**Lesson:** Always handle the zero/edge case in countdown displays. "0 days remaining" is confusing to users — prefer human-readable messages for boundary conditions.

---

## Bug 7 — Hearts State Uses Immutable HeartsModel Updates

**Symptom:** Heart loss in one challenge screen did not reflect in the `HeartsHUD` shown on other screens until the app was restarted.

**Root Cause:** See Bug 1. A second instance of the same direct-mutation pattern was found in a different codepath — the `lostAt` list was being modified with `.add(timestamp)` on the existing model object.

**Fix:** All mutations in `HeartsNotifier` now create new `HeartsModel` instances. The full `lostAt` list is reconstructed via `[...model.lostAt, newTimestamp]` spread syntax.

**Lesson:** Use spread syntax or `List.from()` to create new list instances. Never call `.add()` or `.remove()` on a list that is part of your Riverpod state — create a new list instead.

---

## Bug 8 — Adventure Map Path Re-animates When New Level Unlocks

**Symptom:** When a new level was unlocked (after completing the previous level), the entire adventure map path animation played from the beginning, which was jarring and made it look like the path was resetting.

**Root Cause:** The `_pathCtrl.forward(from: 0)` call that was moved to `ref.listen()` (from Bug 2 fix) was still triggering on every `levelProvider` state emission, including emissions that were not related to a new unlock.

**Fix:** Added a check in the `ref.listen()` callback to only trigger the animation when the number of unlocked levels has actually increased compared to the previous state.

**Lesson:** `ref.listen()` callbacks receive both `previous` and `next` state. Always compare the two before triggering side effects — otherwise any state change (including ones that don't affect your UI) will trigger the animation.

---

## Bug 9 — Season Banner Shows "Season ends today!" Instead of "0 days remaining"

*(This is the resolution to Bug 6 — documenting the fix as its own entry for completeness.)*

**Symptom:** After the Bug 6 fix was applied, the banner correctly shows "Season ends today!" on the last day. This entry confirms the fix is working as intended.

**Root Cause:** N/A — this is the correct behavior.

**Fix:** N/A — behavior is correct.

**Lesson:** Document "this was intentional" cases to prevent future developers from reverting the special-case to a "simpler" calculation.

---

## Bug 10 — XP Not Awarding After Quiz Completion

**Symptom:** Completing a quiz showed the success animation but the XP counter on the dashboard did not update.

**Root Cause:** The `authProvider.notifier.awardXP(amount)` call was being made but the `UserProfile.save()` was not awaited inside the notifier. The state was emitted correctly but the Hive write raced against the navigation away from the quiz screen.

**Fix:** Added `await _user.save()` before emitting the new state in `AuthNotifier.awardXP()`.

**Lesson:** When a Riverpod notifier writes to Hive, the write must complete before the new state is emitted — otherwise the state in memory and the state on disk are temporarily out of sync.

---

## Bug 11 — Provider Rebuild Loop on Dashboard

**Symptom:** The dashboard screen would visually flicker and CPU usage spiked on the home screen, especially after earning coins.

**Root Cause:** `walletProvider` was derived from `authProvider.currentUser?.walletBalance`. Every `authProvider` state change (including XP awards, badge grants, streak updates) triggered a `walletProvider` rebuild even if the wallet balance had not changed. The `WalletBadge` widget then started a count-up animation on every rebuild.

**Fix:** `walletProvider` was changed to use `select` to only rebuild when `walletBalance` specifically changes: `ref.watch(authProvider.select((s) => s.currentUser?.walletBalance ?? 0))`.

**Lesson:** Use `.select()` on providers that derive a single field from a large state object. Without `.select()`, any field change on the parent state causes all derived providers to rebuild.

---

## Bug 12 — Leaderboard Showing Stale Data After Coins Awarded

**Symptom:** The leaderboard screen did not reflect the current user's updated XP rank immediately after earning XP.

**Root Cause:** `LeaderboardScreen.build` reads `Hive.box(kLeaderboardBox).get('entries')` directly without a `ValueListenableBuilder`. Hive box reads in build are not reactive — they return the value at render time and do not subscribe to changes.

**Fix:** The current user's entry is now dynamically computed from `authProvider` (which is reactive) and inserted into the list at render time, so the user's rank updates whenever `authProvider` emits.

**Lesson:** Never read from a Hive box directly in a `build()` method unless the data is truly static (set once and never changed). For reactive data, use Riverpod providers or `ValueListenableBuilder(valueListenable: box.listenable())`.

---

## Bug 13 — Boss Screen Crash After Defeating Boss

**Symptom:** App crashed with "Bad state: no element" after the player defeated the last boss.

**Root Cause:** After defeating the boss, `context.go('/')` was called, which redirected to `/home`. But the `BossRecord.defeatedAt` write was not awaited — the write completed after navigation. On the next launch, reading the partially-written `BossRecord` from Hive threw an exception.

**Fix:** Added `await bossNotifier.markDefeated()` before `context.go('/')` with a `mounted` guard.

**Lesson:** Model writes that contain nullable fields (like `defeatedAt`) must complete before navigation. An incomplete write leaves fields at their default (null) value, which may violate assumptions in the reading code.

---

## Bug 14 — Onboarding Redirect Loop

**Symptom:** After completing onboarding, the user was stuck in an infinite redirect between `/onboarding` and itself.

**Root Cause:** The `'onboardingDone_<uid>'` flag was written to kSettingsBox but `authProvider` still held the old `AuthState` with `hasCompletedOnboarding: false`. The router redirect checks `authProvider.hasCompletedOnboarding` — since it was still false, it kept redirecting back to `/onboarding`.

**Fix:** After writing the Hive flag, `AuthNotifier` now also calls `state = state.copyWith(hasCompletedOnboarding: true)` to update the in-memory state before navigating.

**Lesson:** When both Hive and a Riverpod provider track the same flag, update both atomically. Write to Hive first (await it), then update the provider state. The router redirect reads provider state, not Hive directly.

---

## Bug 15 — context.mounted Check Missing After showDialog

**Symptom:** App threw a "Looking up a deactivated widget's ancestor" exception in `HeartsDepletedScreen` after the user dismissed a dialog and the screen was removed from the tree.

**Root Cause:** After `await showModalBottomSheet(...)`, `context` was used directly without a `mounted` check. If the widget was disposed while the dialog was open (e.g., deep link triggered), the context was stale.

**Fix:** Added `if (!mounted) return;` immediately after every `await showModalBottomSheet(...)` call.

**Lesson:** Every `await` that is followed by `context` usage must have a `if (!mounted) return;` guard. This is non-negotiable for `showDialog`, `showModalBottomSheet`, and any navigation call after an async gap.

---

## Bug 16 — Tutorial Overlay Freezing Entire App

**Symptom:** After launching the app for the first time, the tutorial appeared (showing the "Welcome" chip/step indicator) but the entire app was frozen — no taps registered anywhere, including the tutorial step buttons.

**Root Cause:** `TutorialOverlayHost` was placed in the `MaterialApp.router builder:` callback. The `builder:` context is a **sibling** of the GoRouter's child tree, not a descendant. The `TutorialOverlayHost` called `GoRouterState.of(context)` from this sibling context — there was no `GoRouter` `InheritedWidget` in the ancestor tree, causing a `ProviderNotFoundException` equivalent on every rebuild. Flutter's error recovery left the widget in a partially-rendered state that accepted no input.

**Fix:** Removed `TutorialOverlayHost` from `MaterialApp.router builder:` entirely. The tutorial is now implemented as a dedicated full-screen GoRoute at `/tutorial` with `NoTransitionPage`. The tutorial is triggered by the auth/onboarding flow, not by an overlay.

**Lesson:** Never place navigation-aware widgets in `MaterialApp.router builder:`. The builder context is not inside the GoRouter widget tree. Anything that calls `GoRouterState.of(context)`, `context.go()`, or `context.push()` must be inside a Screen widget, not a builder wrapper.

---

## Bug 17 — Tutorial Dialog Not Appearing (Dim Screen Only)

**Symptom:** The tutorial overlay dimmed the screen but no dialog card appeared — the user saw only a semi-transparent dark background with no content.

**Root Cause:** The tutorial was implemented as a `showDialog()` call triggered from `addPostFrameCallback()` inside `DashboardScreen.build()`. When `showDialog()` was called during the first-frame callback, Flutter's dialog route was created successfully (the barrier rendered), but the dialog's `content` widget crashed silently on first frame due to a layout error. The barrier remained but the content was dismissed before it rendered.

**Fix:** Replaced the `showDialog()` approach entirely. The tutorial is now a dedicated full-screen GoRoute (`/tutorial`). The `TutorialScreen` is a `StatefulWidget` with its own layout, not a dialog. `context.go('/tutorial')` is called from a `postFrameCallback` in the dashboard's `initState()`, not from `build()`.

**Lesson:** Do not use `showDialog()` as the primary mechanism for first-run tutorials. Dialogs are fragile during the first frame. Use a dedicated full-screen route instead — it has a proper lifecycle and cannot be accidentally dismissed by the system.

---

## Bug 18 — Daily Challenge Blocking Tutorial

**Symptom:** Tutorial was frozen because the Daily Challenge dialog launched on top of the tutorial and absorbed all touch input. The tutorial was effectively unreachable.

**Root Cause:** `_maybeShowChallengeDialog()` in `DashboardScreen` fired before the tutorial check. The daily challenge dialog sat on top of the tutorial overlay (at the time, a full-screen Overlay entry), intercepting all taps and making it impossible to progress through tutorial steps.

**Fix:** Added a `tutorial_completed` Hive flag check at the start of `_maybeShowChallengeDialog()`. If `isTutorialDone()` returns false, the daily challenge dialog is suppressed entirely. Once the tutorial is complete, the daily challenge resumes normal behavior.

**Lesson:** Any system-level interrupting dialog (daily challenge, life events, seasonal events) must check whether the tutorial is complete before showing. Interrupting dialogs are never shown during the tutorial. The `isTutorialDone()` helper in `tutorial_overlay.dart` provides the check.

---

## Bug 19 — Life Events Blocked After Tutorial Guard Added

**Symptom:** After adding the `tutorial_completed` guard (Bug 18 fix) to life events as well as the daily challenge, life events stopped appearing entirely — even for users who had completed the tutorial.

**Root Cause:** The tutorial guard `if (!isTutorialDone()) return;` was added to the life events trigger code. However, `isTutorialDone()` reads `kSettingsBox.get(kTutorialCompletedKey)` synchronously. Due to a timing issue in the original tutorial implementation, the `tutorial_completed` flag was never being written — the tutorial overlay was crashing before `markTutorialComplete()` was called. So `isTutorialDone()` always returned `false`, permanently blocking life events.

**Fix:** Removed the tutorial guard from life events entirely. Life events are safe to show at any time because the tutorial is now a full-screen route — it does not conflict with life event navigation. The only dialog that needs the tutorial guard is the daily challenge (which uses a blocking dialog pattern).

**Lesson:** Only add tutorial guards to features that use blocking dialogs that would intercept tutorial input. Full-screen navigations (`context.go()`) do not interfere with the tutorial route, so they do not need a guard. Adding unnecessary guards creates new failure modes.
