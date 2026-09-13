# ZamWealth Quest — Bug Fix Log

All 7 bugs fixed. `flutter analyze` passes with zero issues. Release APK builds clean.

---

## BUG 1 — Home Screen Overflow (187px and 84px)

**Symptom:** BOTTOM OVERFLOWED BY 187 PIXELS (header) and 84 PIXELS (body) on physical Android devices.

**Root cause:** `_buildHeaderWithHud` in `dashboard_screen.dart` used a fixed `SizedBox(height: 208)` with hard-coded constants (`headerH = 140`, `hudH = 88`, `overlap = 20`). On small-screen physical devices (notches, high-density panels, status bars), the header content exceeded these fixed constraints. The final `SizedBox(height: 32)` spacer also didn't account for the system navigation bar.

**Fix:**
- `_buildHeaderWithHud` rewritten: replaced `SizedBox(height: 208) > Stack > Positioned` with a `Column(mainAxisSize: MainAxisSize.min)` + `Transform.translate(offset: Offset(0, -20))` for the visual HUD overlap — no fixed heights.
- `_buildHeader` bottom padding increased from 24px to 36px to ensure adequate overlap space.
- Final bottom spacer changed to `SizedBox(height: 32 + MediaQuery.of(context).padding.bottom)`.

**Files changed:** `lib/features/dashboard/screens/dashboard_screen.dart`

---

## BUG 2 — Avatar Change Screen Overflow (17px)

**Symptom:** BOTTOM OVERFLOWED BY 17 PIXELS on the Change Avatar dialog on physical devices.

**Root cause:** `AvatarSelector` rendered a 3-column `GridView.count` with default `childAspectRatio: 1.0` (square cells). On small screens (360×640dp), the grid height slightly exceeded the `AlertDialog` content area.

**Fix:**
- `AvatarSelector.build()` now wraps the `GridView` in `SingleChildScrollView(physics: ClampingScrollPhysics())` so the grid can scroll on very small screens.
- Added `childAspectRatio: 1.1` to make cells slightly wider than tall, reducing total grid height by ~10%.

**Files changed:** `lib/features/avatar/widgets/avatar_selector.dart`

---

## BUG 3 — Investment Portfolio Overflow (4.5px)

**Symptom:** BOTTOM OVERFLOWED BY 4.5 PIXELS at the bottom of the Investment Portfolio screen.

**Root cause:** `_buildBody`'s `SingleChildScrollView` used `padding: EdgeInsets.all(20)` — fixed 20px bottom padding with no awareness of the system navigation bar height (~48px on gesture-nav Android).

**Fix:**
- Added `SafeArea(top: false)` wrapper around the Scaffold body (bottom navigation bar inset applied automatically).
- Changed `SingleChildScrollView` padding to `EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.paddingOf(context).bottom)`.
- Added `resizeToAvoidBottomInset: false` to Scaffold (no keyboard input on the main screen body).
- Wrapped "Wallet: X ZamCoins" text in `FittedBox(fit: BoxFit.scaleDown)` for narrow screens.

**Files changed:** `lib/features/portfolio/screens/portfolio_screen.dart`

---

## BUG 4 — Red Crash After Changing Avatar (ElementLifecycleState)

**Symptom:** App shows Red Screen of Death with assertion "element._lifecycleState == _ElementLifecycle.inactive: is not true" after selecting a new avatar.

**Root cause:** The `onSelect` callback in the Change Avatar dialog called `setAvatarId(id)` (which is async — it does `await user.save()` then fires a Riverpod state update) as fire-and-forget, then immediately called `Navigator.of(context).pop()`. The dialog element was removed from the tree while the Hive write was in flight. When `state.copyWith(currentUser: user)` fired, the resulting element lifecycle transitions caused the assertion failure.

**Fix:** Made the `onSelect` callback `async`, added `await` before `setAvatarId(id)`, and added `if (context.mounted)` guard before `pop()`. The dialog now stays open for the ~50ms Hive write, then closes cleanly after the provider state is updated.

**Files changed:** `lib/features/profile/screens/profile_screen.dart`

---

## BUG 5 — Property Ladder Screen Shows Blank

**Symptom:** Tapping the property card in My Finances navigated to the Property screen, which appeared blank.

**Root cause:** The `_buildSetupView` showed tier cards with `_kCard = Color(0xFF2A1A0F)` backgrounds on a `_kDark = Color(0xFF1A0E08)` scaffold — near-black on near-black. The cards were nearly invisible, giving the appearance of a blank screen. There was also no clear header or CTA explaining the property ladder concept.

**Fix:** Replaced `_buildSetupView` with a redesigned layout:
- Prominent header: "🏠 Start Your Property Journey" with subtitle.
- Vertical timeline (`_buildLadderStep`) showing all 4 property tiers, with Tier 1 highlighted in terracotta and a "START HERE" badge.
- Full-width CTA button (`_buildStartCTA`) that calls `purchaseProperty(1)`.
- Proper contrast: sand/cream text on dark background, terracotta borders.
- Removed the old `_buildTierCard` method (no other callers).

**Files changed:** `lib/features/property/screens/property_screen.dart`

---

## BUG 6 — Spin Wheel Countdown Uses Fake/Static Timer

**Symptom:** After spinning, the "Next spin in HH:MM:SS" timer displayed a static value that never counted down and reset when leaving and returning to the screen.

**Root cause:** `SpinScreen` read `spinState.cooldownRemaining` from `ref.watch(spinProvider)`. The `SpinNotifier._checkAvailability()` was called only once in the constructor — `SpinState.cooldownRemaining` was a frozen `Duration` value that never updated.

**Fix:** Added a real-time `Timer.periodic(Duration(seconds: 1))` to `_SpinScreenState`:
- `_initCountdown()` called in `initState` — reads `user.spinLastDate` from `currentUserProvider` and computes time remaining until midnight.
- `_startCountdownTimer()` ticks every second, decrementing `_timeUntilNextSpin` via `setState`.
- `mounted` check guards every `setState` inside the timer callback.
- Timer cancelled in `dispose()` to prevent memory leaks.
- Display switched from `spinState.cooldownRemaining` to local `_timeUntilNextSpin`.
- After a spin completes, `_calculateTimeRemaining()` and `_startCountdownTimer()` are called to start the countdown immediately.

**Files changed:** `lib/features/spin/screens/spin_screen.dart`

---

## BUG 7 — ZamCoins and Net Worth Go Negative

**Symptom:** ZamCoins showing -170 and -440; Net Worth showing -ZMW 2K and -ZMW 4K. No recovery path for the user.

**Root cause (ZamCoins going negative):** `life_events_provider.dart` handled `LifeEventEffect.walletLoss` by calling `addWalletCoins(-choice.effectAmount)`. The `addWalletCoins` function adds directly to `walletBalance` with no floor check — passing a negative amount subtracted without limit.

**Fixes applied:**

*Part A — Prevent ZamCoins going below 0:*
- Changed `LifeEventEffect.walletLoss` to use `spendWalletCoins(choice.effectAmount)` (the guarded function that returns `false` when insufficient).
- Added `.clamp(0, 999999999)` to `addWalletCoins` as a belt-and-suspenders defence against any future negative-amount calls.

*Part B — Fix existing negative balances:*
- In `AuthNotifier.login()`, after loading the user from Hive, zeroes `walletBalance` and saves if it was already negative.

*Part C — Recovery Mode banner:*
- Added a `Builder`-wrapped warning banner in the dashboard's scrollable Column, visible only when `netWorthProvider.netWorthZMW < 0`.
- Shows current deficit and a "Get Help" button that navigates to `/recovery-plan`.

*Part D — Recovery Plan screen:*
- Created `lib/features/recovery/screens/recovery_plan_screen.dart` — shows 3 action cards (Go to Levels, Spin Now, View Loans) and a financial lesson.
- Added `AppRoutes.recoveryPlan = '/recovery-plan'` to `AppRoutes` in `router.dart`.
- Registered the new GoRoute in `router.dart` using `_fadeSlidePage` transition.

**Files changed:**
- `lib/features/life_events/providers/life_events_provider.dart`
- `lib/features/auth/providers/auth_provider.dart`
- `lib/features/dashboard/screens/dashboard_screen.dart`
- `lib/features/recovery/screens/recovery_plan_screen.dart` (new)
- `lib/core/router.dart`
