# Hive

All persistent storage for ZamWealth Quest uses Hive. There is no SQLite, no SharedPreferences, no file I/O outside of Hive. Every box is opened in `main()` before `runApp()` is called.

---

## Why All Hive Writes Must Be Awaited

Hive writes return a `Future<void>`. If you navigate away from a screen before the Future completes, the write may be lost or partially written. The Hive file is flushed to disk asynchronously — calling `Hive.close()` or restarting the app before the flush completes can result in data loss.

**Rule:** Always `await box.put(...)` and `await box.delete(...)` before calling `context.go()` or `context.pop()`.

```dart
// CORRECT
await Hive.box(kHeartsBox).put(uid, model);
if (context.mounted) context.go('/home');

// WRONG — navigation may fire before write completes
Hive.box(kHeartsBox).put(uid, model); // fire-and-forget
context.go('/home');
```

---

## Box Registry

| Box Name | Constant | Type Parameter | TypeAdapter | typeId | Purpose |
|---|---|---|---|---|---|
| `users` | `kUserBox` | `UserProfile` | `UserProfileAdapter` | 0 | User accounts, XP, wallet, progress |
| `levels` | `kLevelBox` | `LevelModel` | `LevelModelAdapter` | 1 | Level completion status per user |
| `payments` | `kPaymentBox` | `PaymentRecord` | `PaymentRecordAdapter` | 2 | Simulated ZMW payment history |
| `session` | `kSessionBox` | untyped | — | — | Current uid (`'currentUid'` key) |
| `leaderboard` | `kLeaderboardBox` | untyped | — | — | Seeded fictional player entries |
| `settings` | `kSettingsBox` | untyped | — | — | App-wide flags and per-uid settings |
| `daily_challenge` | `kDailyChallengeBox` | `DailyChallengeRecord` | `DailyChallengeRecordAdapter` | 3 | Daily challenge state per user |
| `family` | `kFamilyBox` | `FamilyModel` | `FamilyModelAdapter` | 4 | Family financial model per user |
| `business` | `kBusinessBox` | `BusinessModel` | `BusinessModelAdapter` | 5 | Business simulation per user |
| `life_events` | `kLifeEventsBox` | `LifeEventRecord` | `LifeEventRecordAdapter` | 6 | Life event history per user |
| `story` | `kStoryBox` | `StoryChapterProgress` | `StoryChapterProgressAdapter` | 12 | Story chapter progress per user |
| `hearts` | `kHeartsBox` | `HeartsModel` | `HeartsModelAdapter` | 10 | Heart count + refill timestamps |
| `inventory` | `kInventoryBox` | `InventoryModel` | `InventoryModelAdapter` | 11 | Shop items owned by user |
| `boss_records` | `kBossBox` | `BossRecord` | `BossRecordAdapter` | 13 | Boss battle results per level |
| `property` | `kPropertyBox` | `PropertyModel` | `PropertyModelAdapter` | 7 | Property holdings per user |
| `investments` | `kInvestmentsBox` | `PortfolioModel` | `PortfolioModelAdapter` | 8 | Investment portfolio per user |
| `loans` | `kLoansBox` | `LoanRecord` | `LoanRecordAdapter` | 14 | Loan obligations per user |
| `savings_goals` | `kSavingsGoalsBox` | `SavingsRecord` | `SavingsRecordAdapter` | 15 | Savings goals per user |
| `news` | `kNewsBox` | `NewsRecord` | `NewsRecordAdapter` | 16 | News items per user |
| `health` | `kHealthBox` | `HealthRecord` | `HealthRecordAdapter` | 17 | Health records per user |
| `myths` | `kMythsBox` | `MythRecord` | `MythRecordAdapter` | 18 | Financial myth tracking per user |
| `spotlights` | `kSpotlightsBox` | `SpotlightRecord` | `SpotlightRecordAdapter` | 19 | Spotlight story progress per user |
| `mentors` | `kMentorsBox` | `MentorRecord` | `MentorRecordAdapter` | 20 | Mentor interaction state per user |
| `proverbs` | `kProverbsBox` | `ProverbRecord` | `ProverbRecordAdapter` | 21 | Proverb collection per user |
| `daily_routine` | `kDailyRoutineBox` | `DailyRoutineRecord` | `DailyRoutineRecordAdapter` | 22 | Daily habit checklist per user |
| `streak` | `kStreakBox` | untyped | — | — | Streak counter + dates (primitive values) |

> **Note:** typeId 9 is unused — there is a gap in the adapter sequence. Do not assign typeId 9 to a new adapter without first verifying no existing box has a record written with that typeId.

---

## Dynamic Key Patterns

Most typed boxes use a single `<uid>` as their Hive key (one record per user per box). The `settings` and `streak` boxes use string-keyed patterns for multiple per-user values.

| Key Pattern | Box | Value Type | Set By |
|---|---|---|---|
| `<uid>` | `hearts` | `HeartsModel` | `HeartsNotifier` |
| `<uid>` | `inventory` | `InventoryModel` | `InventoryNotifier` |
| `<uid>` | `proverbs` | `ProverbRecord` | `ProverbNotifier` |
| `<uid>` | `family` | `FamilyModel` | `FamilyNotifier` |
| `<uid>` | `business` | `BusinessModel` | `BusinessNotifier` |
| `<uid>` | `daily_challenge` | `DailyChallengeRecord` | `DailyChallengeNotifier` |
| `<uid>` | `health` | `HealthRecord` | `HealthNotifier` |
| `<uid>` | `news` | `NewsRecord` | `NewsNotifier` |
| `<uid>` | `myths` | `MythRecord` | `MythNotifier` |
| `<uid>` | `loans` | `LoanRecord` | `LoansNotifier` |
| `<uid>` | `investments` | `PortfolioModel` | `PortfolioNotifier` |
| `<uid>` | `property` | `PropertyModel` | `PropertyNotifier` |
| `<uid>` | `savings_goals` | `SavingsRecord` | `SavingsNotifier` |
| `<uid>` | `mentors` | `MentorRecord` | `MentorNotifier` |
| `<uid>` | `daily_routine` | `DailyRoutineRecord` | `DailyRoutineNotifier` |
| `<uid>` | `life_events` | `LifeEventRecord` | `LifeEventsNotifier` |
| `<uid>` | `spotlights` | `SpotlightRecord` | `SpotlightsNotifier` |
| `<username>` (= uid) | `users` | `UserProfile` | `AuthNotifier` |
| `'<uid>_<levelId>'` | `levels` | `LevelModel` | `LevelNotifier` |
| `'<uid>_<levelId>'` | `boss_records` | `BossRecord` | `BossNotifier` |
| `'<uid>_streak'` | `streak` | `int` | `StreakService` |
| `'<uid>_lastDate'` | `streak` | `String` (yyyy-MM-dd) | `StreakService` |
| `'<uid>_shields'` | `streak` | `int` | `StreakService` |
| `'currentUid'` | `session` | `String?` | `AuthNotifier` |
| `'entries'` | `leaderboard` | `List<Map<String,dynamic>>` | `main._seedLeaderboard()` |
| `'leaderboardSeeded'` | `settings` | `bool` | `main._seedLeaderboard()` |
| `'tutorial_completed'` (`kTutorialCompletedKey`) | `settings` | `bool` | `tutorial_overlay.markTutorialComplete()` |
| `'onboardingDone_<uid>'` | `settings` | `bool` | `AuthNotifier` |
| `'dc_dialog_shown_<uid>'` | `settings` | `String` (date yyyy-MM-dd) | `DashboardScreen` |
| `'budget_alloc_<uid>'` | `settings` | `dynamic` | `BudgetSimulation` |
| `'budget_income_<uid>'` | `settings` | `dynamic` | `BudgetSimulation` |
| `'proverbs_unlocked_<uid>'` | `settings` | `List<String>` | `ProverbUnlockNotifier` |
| `'sandboxMode'` | `settings` | `bool` | Dev screen |

---

## kSettingsBox Special Keys

| Key | Type | Purpose |
|---|---|---|
| `'tutorial_completed'` | `bool` | Global (not per-uid) flag — tutorial has been completed at least once on this device |
| `'leaderboardSeeded'` | `bool` | One-time flag preventing the 9 fictional players from being re-seeded on restart |
| `'onboardingDone_<uid>'` | `bool` | Per-user flag — this user has completed the onboarding screens |
| `'dc_dialog_shown_<uid>'` | `String` | Date string — the daily challenge dialog was last shown on this date for this user |
| `'budget_alloc_<uid>'` | `dynamic` | Budget allocation data for budget simulation widget on dashboard |
| `'budget_income_<uid>'` | `dynamic` | Income data for budget simulation widget on dashboard |
| `'proverbs_unlocked_<uid>'` | `List<String>` | Mirror of proverb unlock state for faster lookup |
| `'sandboxMode'` | `bool` | Enables dev/sandbox features when true |

---

## Flagged Unawaited Hive Writes

The following are places in the codebase where a Hive write Future is not awaited. These should be reviewed before production release.

| Location | Pattern | Risk |
|---|---|---|
| `HeartsNotifier` constructor → `_applyRefill()` | Fire-and-forget Future in constructor | Hive write exception silently lost on app start |
| `HeartsNotifier.timeUntilNextRefill()` → `_applyRefill()` | `// ignore: discarded_futures` comment present | Hive write exception silently lost on UI query |
| `UserProfile.awardBadge()` | Calls `save()` which is a `Future<void>` returned uncaptured | Badge grant may not persist if app closes immediately after |
| `UserProfile.recordStoryChoice()` | Calls `save()` which is a `Future<void>` returned uncaptured | Story choice may not persist if app closes immediately after |

---

## Adapter Registration Order

Adapters must be registered before their boxes are opened. The registration order in `main.dart` is:

```
typeId 0  — UserProfileAdapter
typeId 1  — LevelModelAdapter
typeId 2  — PaymentRecordAdapter
typeId 3  — DailyChallengeRecordAdapter
typeId 4  — FamilyModelAdapter
typeId 5  — BusinessModelAdapter
typeId 6  — LifeEventRecordAdapter
typeId 7  — PropertyModelAdapter
typeId 8  — PortfolioModelAdapter
typeId 9  — (UNUSED — gap in sequence)
typeId 10 — HeartsModelAdapter
typeId 11 — InventoryModelAdapter
typeId 12 — StoryChapterProgressAdapter
typeId 13 — BossRecordAdapter
typeId 14 — LoanRecordAdapter
typeId 15 — SavingsRecordAdapter
typeId 16 — NewsRecordAdapter
typeId 17 — HealthRecordAdapter
typeId 18 — MythRecordAdapter
typeId 19 — SpotlightRecordAdapter
typeId 20 — MentorRecordAdapter
typeId 21 — ProverbRecordAdapter
typeId 22 — DailyRoutineRecordAdapter
```

If a new model is added, assign it **typeId 23** (the next available). Never reuse a typeId — Hive stores the typeId in the binary format, and reusing an ID will cause deserialization failures on existing devices.
