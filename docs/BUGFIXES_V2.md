# ZamWealth Quest — Bug Fix Log V2

All 4 bugs fixed. `flutter analyze` passes with zero issues. Release APK builds clean at 57.2 MB.

---

## BUG 1 — Investment Portfolio Overflow (19px portrait, 158px landscape)

**Symptom:** BOTTOM OVERFLOWED BY 19 PIXELS in portrait and 158 PIXELS in landscape on the Investment Portfolio screen.

**Root cause:** `_buildEmptyView` used `Center > Padding > Column` with no `SingleChildScrollView` and no layout awareness. In landscape, the available vertical height drops dramatically, making the column overflow the viewport. The filled (non-empty) path also had fixed heights for the pie chart (200px) and line chart (140px) that did not adapt to orientation.

**Fix:**
- `_buildBody` now wraps everything in `LayoutBuilder` to compute `isLandscape = constraints.maxWidth > constraints.maxHeight`.
- `_buildEmptyView` converted from `Center > Padding > Column` to `SingleChildScrollView(physics: AlwaysScrollableScrollPhysics())` with orientation-responsive top padding and `SizedBox` spacers (`isLandscape ? half : full`).
- `_buildPieChart` height: `isLandscape ? 120 : 200`.
- `_buildLineChart` height: `isLandscape ? 80 : 140`.
- All fixed `SizedBox(height: 16)` spacers in the filled path replaced with `SizedBox(height: isLandscape ? 8 : 16)`.

**Files changed:** `lib/features/portfolio/screens/portfolio_screen.dart`

---

## BUG 2 — Avatar Change Freeze + BLACK Screen

**Symptom:** Tapping "Change Avatar" caused the app to freeze for ~1-2 seconds then show a BLACK screen. The Navigator stack was broken. Had to restart the app. (Different from Session 1's red crash — that was a lifecycle assertion; this was a navigator stack corruption.)

**Root cause:** `showDialog` + `AlertDialog` placed the avatar picker inside a dialog route. After `await setAvatarId(id)` completed and `Navigator.of(context).pop()` was called, the dialog's route was being popped while the shell route's `AnimatedSwitcher` was in mid-animation, corrupting the navigator stack on physical devices.

**Fix:**
- Created `lib/features/avatar/screens/change_avatar_screen.dart` — a full-screen `ConsumerStatefulWidget` with:
  - Local `_selectedId` state (set from current avatar on `initState`).
  - `_isSaving` bool with `CircularProgressIndicator` shown in AppBar actions during save.
  - `onSelect` only updates `_selectedId` locally; saving happens on "Save" tap.
  - `if (mounted) context.pop()` after `await setAvatarId(_selectedId)`.
  - "Save" button disabled until the avatar differs from the current one.
- Added `AppRoutes.changeAvatar = '/change-avatar'` and GoRoute in `router.dart`.
- `profile_screen.dart`: replaced `showDialog(...)` with `context.push(AppRoutes.changeAvatar)`. Removed now-unused `AvatarSelector` import.

**Files changed:**
- `lib/features/avatar/screens/change_avatar_screen.dart` (new)
- `lib/core/router.dart`
- `lib/features/profile/screens/profile_screen.dart`

---

## BUG 3 — Property Ladder BLACK Screen After Payment

**Symptom:** After tapping any payment button in Property Ladder (initial deposit, mortgage instalment, upgrade), the screen turned BLACK. Data was saved correctly (re-navigating back showed the updated state), but the current screen became unresponsive.

**Root cause:** During the `purchaseProperty` async flow, two intermediate auth state emissions fired (`spendWalletCoins` and `addXp`) before `state = PropertyState(property: prop)` was set. Each auth emission triggered a `PropertyScreen` rebuild. Since `propState.property` was still `null` during those rebuilds, the screen briefly re-rendered `_buildSetupView`. On physical Android devices with gesture navigation, this double-rebuild within the same frame cycle caused the GPU thread to produce a black frame that persisted. A secondary issue: no guard prevented double-tapping the CTA during the async gap, which could trigger a second purchase attempt.

**Fix:**
- `PropertyNotifier.purchaseProperty`: sets `state = const PropertyState(isLoading: true)` immediately, preventing mid-async rebuilds from showing `_buildSetupView`. On spend failure, resets to `const PropertyState()`.
- `PropertyNotifier.payMortgage`: sets `state = PropertyState(property: prop, isLoading: true)` before the async spend, resets to `PropertyState(property: prop)` on failure.
- `PropertyNotifier.upgradeProperty`: same pattern as `payMortgage`.
- `_PropertyScreenState`: added `_isProcessing` bool guard — `_purchase` early-returns if already processing, sets flag around the async call, and clears it after.
- `_buildStartCTA` button: disabled when `_isProcessing` is true.
- `_buildDashboard`: changed `padding: const EdgeInsets.all(20)` to `EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.paddingOf(context).bottom)` for proper bottom nav bar clearance.

**Files changed:**
- `lib/features/property/providers/property_provider.dart`
- `lib/features/property/screens/property_screen.dart`

---

## BUG 4 — ZamCoins Wallet Not Shared Across All Features

**Symptom:** Dashboard, Portfolio, Property, Loans, and Savings screens showed stale wallet balances — the display did not update after spending or earning ZamCoins in another feature. Portfolio and Chronicles could show a different balance from what was shown on the Home screen.

**Root cause:** `UserProfile.walletBalance` is a mutable field on a HiveObject. All wallet mutations call `user.walletBalance = newValue` (in-place mutation on the same object) then `state = state.copyWith(currentUser: user)`. Because the `currentUser` object reference is unchanged, Riverpod's `Provider<UserProfile?>` (`currentUserProvider`) sees `newValue == oldValue` (same reference → same identity) and does **not** notify its watchers. Any screen watching `currentUserProvider` to read wallet balance would therefore never rebuild on balance changes.

`walletProvider` (`lib/features/wallet/providers/wallet_provider.dart`) already existed and correctly watches `authProvider` (a `StateNotifier`) directly — which always fires on any `state =` assignment regardless of reference equality. Only `ShopScreen` was using it.

**Fix:** Switch every wallet-display screen from `ref.watch(currentUserProvider)?.walletBalance` to `ref.watch(walletProvider)`:
- `portfolio_screen.dart`: removed `authProvider` import, added `wallet_provider` import, replaced `user?.walletBalance ?? 0` with `ref.watch(walletProvider)`.
- `property_screen.dart`: same substitution, removed `currentUserProvider` watch.
- `loans_screen.dart`: same substitution.
- `savings_screen.dart`: same substitution.
- `dashboard_screen.dart`: added `wallet_provider` import, changed `'${dash.user.walletBalance}'` to `'${ref.watch(walletProvider)}'` in `_buildHudBar` so the HUD ZamCoins cell rebuilds reactively.

**Files changed:**
- `lib/features/portfolio/screens/portfolio_screen.dart`
- `lib/features/property/screens/property_screen.dart`
- `lib/features/loans/screens/loans_screen.dart`
- `lib/features/savings/screens/savings_screen.dart`
- `lib/features/dashboard/screens/dashboard_screen.dart`
