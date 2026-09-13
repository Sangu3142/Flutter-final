# Providers

All Riverpod providers in the application. Providers are global (no scoping). Every screen accesses them via `ref.watch()` (reactive) or `ref.read()` (one-shot, typically inside callbacks).

---

## Summary Table

| Provider | Type | Hive Box | Screens That Watch It | Notes |
|---|---|---|---|---|
| `authProvider` | `StateNotifierProvider<AuthNotifier, AuthState>` | `users`, `session`, `settings` | Almost every screen | Source of truth for current user |
| `currentUserProvider` | `Provider<UserProfile?>` | — (derived) | Almost every screen | Derived from authProvider |
| `routerProvider` | `Provider<GoRouter>` | — | ZamWealthApp (root) | GoRouter instance; watches authProvider for redirects |
| `heartsProvider` | `StateNotifierProvider<HeartsNotifier, HeartsModel>` | `hearts` | HeartsHUD, HeartsDepletedScreen, FlashChallengeScreen, BossScreen, DailyChallengeScreen | Auto-refills over time; key `<uid>` |
| `levelProvider` | `StateNotifierProvider<LevelNotifier, LevelState>` | `levels`, `users` | LevelMapScreen, LevelScreen, DashboardScreen | Keys: `<uid>_<levelId>` |
| `singleLevelProvider` | `Provider.family<LevelModel?, int>` | — (derived) | LevelScreen | Derived from levelProvider |
| `inventoryProvider` | `StateNotifierProvider<InventoryNotifier, InventoryModel>` | `inventory` | ShopScreen, FlashChallengeScreen, BossScreen, MysteryBoxScreen, ProfileScreen | Key `<uid>`; mutation-before-replace pattern |
| `proverbProvider` | `StateNotifierProvider<ProverbNotifier, ProverbState>` | `proverbs` | ProverbsScreen | Key `<uid>` |
| `proverbUnlockProvider` | `StateNotifierProvider<ProverbUnlockNotifier, ProverbUnlockState>` | `settings` | ProverbsScreen | Key `proverbs_unlocked_<uid>` |
| `walletProvider` | `Provider<int>` | `users` (derived) | WalletBadge, ShopScreen, SpinScreen | Derived from authProvider.walletBalance |
| `dashboardProvider` | StateNotifier (complex) | `users`, `settings` | DashboardScreen | Aggregates dashboard state |
| `dailyBonusProvider` | Provider | `users` | Router redirect, DailyBonusScreen | `shouldShow` flag drives router redirect |
| `badgeServiceProvider` / `badgeMapProvider` | Provider | `users` | BadgesScreen, ProfileScreen, DashboardScreen | Badge catalogue |
| `familyProvider` | StateNotifier | `family` | FamilyScreen, DashboardScreen | Key `<uid>` |
| `businessProvider` | StateNotifier | `business` | BusinessScreen, DashboardScreen | Key `<uid>` |
| `healthProvider` | StateNotifier | `health` | HealthScreen, DashboardScreen | Key `<uid>` |
| `networthProvider` | Provider / Notifier | Multiple boxes | NetWorthScreen, DashboardScreen | Aggregates balances from 6+ boxes |
| `bossProvider` | StateNotifier | `boss_records` | BossScreen, BossDefeatedScreen | Key `<uid>_<levelId>` |
| `globalStreakProvider` | StateNotifier | `streak` | BossScreen, DashboardScreen | Keys `<uid>_streak`, `<uid>_lastDate`, `<uid>_shields` |
| `quizProvider` | StateNotifier | `users` | QuizScreen | Tracks completed quiz IDs |
| `flashChallengeProvider` | StateNotifier | `users`, `settings` | DashboardScreen, FlashChallengeScreen | Controls challenge availability window |
| `xpBoostProvider` | Provider | `users` | DashboardScreen | Reads xpBoostExpiry from UserProfile |
| `spinProvider` | StateNotifier | `users` | SpinScreen | Reads spinLastDate from UserProfile |
| `dailyChallengeProvider` | StateNotifier | `daily_challenge`, `settings` | DashboardScreen, DailyChallengeScreen | Key `<uid>`; dc_dialog_shown_<uid> in settings |
| `seasonalEventProvider` | Provider / Notifier | `users` | DashboardScreen, SeasonalEventScreen, SeasonScreen | Reads lastSeasonalEventId |
| `lifeEventsProvider` | StateNotifier | `life_events` | DashboardScreen, LifeEventScreen | Key `<uid>` |
| `portfolioProvider` | StateNotifier | `investments` | PortfolioScreen, DashboardScreen, NetWorthScreen | Key `<uid>` |
| `loansProvider` | StateNotifier | `loans` | LoansScreen, DashboardScreen, NetWorthScreen | Key `<uid>` |
| `savingsProvider` | StateNotifier | `savings_goals` | SavingsScreen, DashboardScreen, NetWorthScreen | Key `<uid>` |
| `propertyProvider` | StateNotifier | `property` | PropertyScreen, DashboardScreen, NetWorthScreen | Key `<uid>` |
| `newsProvider` | StateNotifier | `news` | NewsScreen, DashboardScreen | Key `<uid>` |
| `mythProvider` | StateNotifier | `myths` | MythScreen | Key `<uid>` |
| `mentorProvider` | StateNotifier | `mentors` | MentorsScreen, DashboardScreen | Key `<uid>` |
| `dailyRoutineProvider` | StateNotifier | `daily_routine` | DailyRoutineScreen, DashboardScreen | Key `<uid>` |
| `spotlightsProvider` | StateNotifier | `spotlights` | SpotlightsScreen | Key `<uid>` |
| `paymentHistoryProvider` | Provider / FutureProvider | `payments` | ProfileScreen | |

---

## Detailed Provider Notes

### `authProvider` — `StateNotifierProvider<AuthNotifier, AuthState>`

The most widely-used provider. `AuthState` holds:
- `currentUser: UserProfile?` — the logged-in user object
- `isAuthenticated: bool`
- `hasCompletedOnboarding: bool`

The GoRouter `routerProvider` watches `authProvider` and redirects based on auth state. Nearly every other provider reads the current uid from `authProvider` to key their Hive reads.

### `heartsProvider` — `StateNotifierProvider<HeartsNotifier, HeartsModel>`

`HeartsModel` holds:
- `heartsCount: int` — current number of hearts (0–5)
- `lostAt: List<String>` — ISO-8601 timestamps of when each heart was lost

The notifier auto-refills hearts in its **constructor** by calling `_applyRefill()` as a fire-and-forget Future. This means on every cold start, hearts may be silently re-added without any UI feedback until the first frame.

`_applyRefill()` is also called with `// ignore: discarded_futures` comment from `timeUntilNextRefill()`. Any Hive write exception from these calls is silently lost.

**Known issue:** `HeartsHUD.build()` calls `addPostFrameCallback` 3 times on every rebuild, and mutates `_prevHearts` inside build. See [performance.md](performance.md).

### `levelProvider` — `StateNotifierProvider<LevelNotifier, LevelState>`

`LevelState` holds:
- `levels: Map<int, LevelModel>` — map of levelId → LevelModel
- `isLoading: bool`
- `error: String?`

Levels are keyed in Hive as `'<uid>_<levelId>'`. The notifier loads all levels for the current user into memory on initialization. Level status transitions (LOCKED → IN_PROGRESS → COMPLETED) are written back to Hive.

`singleLevelProvider` is a `Provider.family<LevelModel?, int>` that derives a single level from `levelProvider.levels[id]`, preventing screens from watching the entire map when only one level is needed.

### `inventoryProvider` — `StateNotifierProvider<InventoryNotifier, InventoryModel>`

`InventoryModel` holds:
- `powerUpsRaw: Map<dynamic, dynamic>` — raw Hive map of powerUpId → count
- `unlockedOutfits: List<String>`
- `unlockedFrames: List<String>`
- `unlockedStreakIcons: List<String>`
- `activeOutfitId: String?`
- `activeFrameId: String?`
- `activeStreakIconId: String?`

**Known issue:** `addItem()` mutates `state.powerUpsRaw[id] = ...` and `state.unlockedOutfits.add(id)` directly on the current state object before calling `await _save()` which creates a new model. This means Riverpod does not detect the change until `_save()` runs. The current code works because `_save()` is always called synchronously after mutation, but it is fragile.

### `proverbProvider` / `proverbUnlockProvider`

Two separate notifiers for proverbs:
- `proverbProvider`: manages `ProverbRecord` (total seen count, collected IDs) in kProverbsBox
- `proverbUnlockProvider`: manages the Set<String> of unlocked proverb IDs mirrored to kSettingsBox under `'proverbs_unlocked_<uid>'`

**Known issue:** `ProverbsScreen.build` calls `addPostFrameCallback` at line 776 on every rebuild.

### `routerProvider` — `Provider<GoRouter>`

Creates and exposes the singleton `GoRouter` instance. The redirect logic inside `routerProvider` watches `authProvider`, `dailyBonusProvider`, and reads from `kSettingsBox`. The redirect runs on every navigation event.

See [routing.md](routing.md) for the full redirect logic.

---

## Provider Dependency Graph

```
authProvider (root)
  ├── currentUserProvider
  ├── routerProvider (for redirect)
  ├── heartsProvider (reads uid)
  ├── levelProvider (reads uid)
  ├── inventoryProvider (reads uid)
  ├── proverbProvider (reads uid)
  ├── familyProvider (reads uid)
  ├── businessProvider (reads uid)
  ├── bossProvider (reads uid)
  ├── ... (all per-uid feature providers)
  └── walletProvider (derived from currentUser.walletBalance)
```

All per-feature providers depend on `authProvider` to get the current uid for their Hive key lookups. If `authProvider` emits a new user (login/logout), all downstream providers should be re-read (typically via `ref.invalidate()` or re-watch).
