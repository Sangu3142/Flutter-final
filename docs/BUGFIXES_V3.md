# ZamWealth Quest — Bug Fix Log V3

All 4 bugs fixed. `flutter analyze` passes with zero issues.

---

## BUG 1 — Property Ladder Blank Body After Payment

**Symptom:** After tapping any payment button (initial deposit, mortgage instalment, upgrade), the Property Ladder screen header remained visible but the body area was completely blank — no cards, no content.

**Root cause:** `_payMortgage()` and `_upgrade()` in `PropertyScreen` had no `_isProcessing` re-entrancy guard. A double-tap (or rapid second interaction while the first async call was in-flight) could trigger a second overlapping async operation, causing `PropertyState` to be set to `isLoading: true` a second time and then reset incorrectly, leaving the body stuck showing the loading spinner (which could render as blank if the frame compositor dropped it) or transitioning through a state where `property == null && isLoading == false` for a single frame (showing `_buildSetupView` briefly). Additionally, if an exception occurred inside any provider operation, `isLoading` was never reset to false, leaving the body permanently showing the spinner.

**Fix:**
- `property_screen.dart`: Added `_isProcessing` guard to `_payMortgage()` and `_upgrade()`, matching the pattern already used by `_purchase()`. Both methods now early-return if `_isProcessing` is true, set it before the await, check `mounted` after the await, then clear it.
- `property_screen.dart`: Both the mortgage Pay button and upgrade button now disable (`onPressed: null`) when `_isProcessing` is true, preventing user interaction during an in-flight payment.
- `property_provider.dart`: Wrapped `purchaseProperty`, `payMortgage`, and `upgradeProperty` in `try/catch` blocks that reset `state` to a non-loading state if an exception escapes. This guarantees `isLoading` is never permanently stuck at `true` regardless of Hive or auth provider errors.

**Files changed:**
- `lib/features/property/screens/property_screen.dart`
- `lib/features/property/providers/property_provider.dart`

---

## BUG 2 — Change Avatar Loops Back to Avatar Screen After Saving

**Symptom:** After selecting a new avatar and tapping "Save", the app navigated back to the avatar selection screen instead of staying on the profile screen.

**Root cause:** This bug was introduced in the original `showDialog` + `Navigator.pop` implementation (Session 2 bug). The Session 2 fix — replacing it with a full-screen `ChangeAvatarScreen` that uses `context.push` for navigation in and `if (mounted) context.pop()` for navigation out — already resolved the root cause. The GoRouter redirect logic has no path that could send the user back to `/change-avatar` after popping it.

**Fix:** No additional code changes required. Confirmed that:
- `ChangeAvatarScreen._confirm()` calls `if (mounted) context.pop()` after `await setAvatarId(...)`.
- The GoRouter redirect evaluates `/change-avatar` and returns `null` (no redirect) on every auth state emission.
- `setAvatarId` uses `state.copyWith(currentUser: user)` which does not trigger any redirect-worthy state transition.

**Files changed:** None (already fixed in Session 2).

---

## BUG 3 — Savings Goal Dialog Overflow (128px portrait, 8.7px landscape)

**Symptom:** Opening the "New Goal" dialog via the FAB caused `BOTTOM OVERFLOWED BY 128 PIXELS` in portrait and `8.7 PIXELS` in landscape. The three text fields were partially clipped, and the keyboard pushed the dialog content off-screen with no scrolling.

**Root cause:** `_showAddGoalDialog` used `showDialog()` + `AlertDialog` with `Column(mainAxisSize: MainAxisSize.min)`. `AlertDialog` places its content in a fixed-position dialog box that does not respond to keyboard intrusion (`viewInsets.bottom`). When the soft keyboard opened, the dialog stayed centred in the shrinking visible area without scrolling, causing overflow.

**Fix:**
- Replaced `showDialog()` + `AlertDialog` with `showModalBottomSheet(isScrollControlled: true, ...)`. A modal bottom sheet with `isScrollControlled: true` grows above the keyboard automatically when its content padding accounts for `MediaQuery.of(ctx).viewInsets.bottom`.
- Sheet content uses `Padding(EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom))` wrapping `SingleChildScrollView > Column(mainAxisSize: MainAxisSize.min)`.
- Sheet has a rounded top border (`BorderRadius.vertical(top: Radius.circular(20))`) and `_kCard` background.
- Actions (Cancel / Create) are inline at the bottom of the column as a `Row`, not in `AlertDialog.actions`, so they scroll with the content on very small screens.

**Files changed:** `lib/features/savings/screens/savings_screen.dart`

---

## BUG 4 — Kwacha Chronicles Shows ZERO ZamCoins / Cannot Unlock Chapters

**Symptom:** On the Story Chapter screen, the unlock card always showed 0 ZamCoins available regardless of the player's actual wallet balance. The "Unlock Chapter" button was always disabled (or showed "Not enough resources") even when the player had sufficient coins. Spending coins to unlock a chapter had no effect on the HUD wallet display.

**Root cause:** `UserProfile` has two separate coin fields:
- `zamCoins` (HiveField 8) — originally for in-game story/milestone awards, populated via level payment flows
- `walletBalance` (HiveField 20) — the universal spendable gameplay currency, returned by `walletProvider`

The Story system (`story_provider.dart`, `story_chapter_screen.dart`) exclusively used `user.zamCoins` (HiveField 8), while the HUD, shop, and all other spending features use `walletBalance` (HiveField 20) via `walletProvider`. A player could have 500 ZamCoins in their `walletBalance` (shown on the home HUD) but 0 `zamCoins`, making story unlock perpetually impossible. Additionally, the old code did `user.zamCoins -= cost` (in-place mutation) without going through `authProvider.spendWalletCoins`, so `walletProvider` was never notified and the HUD did not update after spending.

**Fix:**
- `story_provider.dart` — `unlockChapter`: Changed gate check from `user.zamCoins < data.zamCoinCost` to `user.walletBalance < data.zamCoinCost`. Changed the deduction from `user.zamCoins -= cost` + `user.save()` to `await _ref.read(authProvider.notifier).spendWalletCoins(data.zamCoinCost)`, which atomically decrements `walletBalance`, persists to Hive, and emits auth state so `walletProvider` fires reactively on all watching screens.
- `story_chapter_screen.dart` — `build`: Added `final wallet = ref.watch(walletProvider)` and passed it as a new `int wallet` parameter to `_buildUnlockCard`.
- `story_chapter_screen.dart` — `_buildUnlockCard`: Added `int wallet` parameter. Changed `hasEnoughCoins = (user?.zamCoins ?? 0) >= chapter.zamCoinCost` to `hasEnoughCoins = wallet >= chapter.zamCoinCost`. Imported `wallet_provider.dart`.

**Files changed:**
- `lib/features/story/providers/story_provider.dart`
- `lib/features/story/screens/story_chapter_screen.dart`
