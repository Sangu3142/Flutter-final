# Features

Every feature in `lib/features/`. Listed alphabetically.

---

## Auth

**What it does:** Handles user registration, login, and session management. Stores a `UserProfile` per user keyed by username (= uid) in the `users` Hive box. A `currentUid` string is persisted in the `session` box so the user stays logged in across app restarts. Onboarding completion is tracked via a per-user flag `'onboardingDone_<uid>'` in the `settings` box.

**Screens:** LoginScreen, RegisterScreen, OnboardingScreen, SplashScreen

**Providers:** `authProvider` (StateNotifier), `currentUserProvider` (derived Provider)

**Hive boxes:** `users` (kUserBox), `session` (kSessionBox), `settings` (kSettingsBox)

**Routes:** `/login`, `/register`, `/onboarding`, `/` (splash)

---

## Avatar

**What it does:** Lets the user choose a character avatar from a predefined set. The selected avatar ID is stored as `avatarId` on `UserProfile`.

**Screens:** ChangeAvatarScreen

**Providers:** `authProvider` (writes avatarId to UserProfile)

**Hive boxes:** `users` (kUserBox)

**Routes:** `/change-avatar`

---

## Badges

**What it does:** Awards achievement badges to the user when milestone conditions are met (e.g., completing a level, reaching a streak). Badge IDs are stored in `earnedBadges` (a List<String>) on `UserProfile`. A badge map service builds the full badge catalogue from hardcoded data.

**Screens:** BadgesScreen

**Providers:** `badgeServiceProvider`, `badgeMapProvider`

**Hive boxes:** `users` (kUserBox)

**Routes:** `/badges`

---

## Boss

**What it does:** Each zone (level group) has a Boss battle — a timed challenge that tests accumulated knowledge. A `BossRecord` is stored per `uid_levelId` combination tracking whether the boss was defeated, the replay count, best score, and defeat timestamp. Hearts are consumed on failure.

**Screens:** BossScreen, BossDefeatedScreen

**Providers:** `bossProvider`, `heartsProvider`, `authProvider`, `streakProvider`, `inventoryProvider`

**Hive boxes:** `boss_records` (kBossBox)

**Routes:** `/levels/:levelId/boss`, `/levels/:levelId/boss/defeat`

---

## Business

**What it does:** Simulates running a small business — the user allocates resources and sees revenue/profit outcomes. A `BusinessModel` tracks the business state. Business metrics feed into the Net Worth calculation.

**Screens:** BusinessScreen

**Providers:** `businessProvider`

**Hive boxes:** `business` (kBusinessBox)

**Routes:** `/business`

---

## Coop

**What it does:** Cooperative savings group simulation (chama/coop). Lets the user join or manage a rotating savings pool, contributing a fixed ZMW amount each cycle.

**Screens:** CoopScreen

**Providers:** (coop-specific provider — not fully catalogued)

**Hive boxes:** Not catalogued separately; may use `settings` or `users`

**Routes:** `/coop`

---

## Daily Bonus

**What it does:** Rewards the player with ZMW coins and/or XP for logging in each day. The router redirect checks `dailyBonusProvider.shouldShow` on every navigation — if true and the user is not already on `/daily-bonus`, they are redirected there automatically. Tracked via `loginBonusDay` and `loginBonusLastDate` on `UserProfile`.

**Screens:** DailyBonusScreen

**Providers:** `dailyBonusProvider`

**Hive boxes:** `users` (kUserBox)

**Routes:** `/daily-bonus`

---

## Daily Challenge

**What it does:** Presents a financial quiz or scenario challenge once per day. A `DailyChallengeRecord` stores the challenge state for the current user. A `'dc_dialog_shown_<uid>'` key in kSettingsBox records the last date the dialog was shown, preventing it from appearing multiple times in the same day. The dialog is suppressed until `tutorial_completed` is true.

**Screens:** DailyChallengeScreen

**Providers:** `dailyChallengeProvider`

**Hive boxes:** `daily_challenge` (kDailyChallengeBox), `settings` (kSettingsBox for dialog-shown date)

**Routes:** `/daily-challenge`

---

## Daily Routine

**What it does:** Tracks a user's daily financial habit checklist (e.g., "check budget", "record expense"). Completing items grants XP. State is stored in `DailyRoutineRecord`.

**Screens:** DailyRoutineScreen

**Providers:** `dailyRoutineProvider`

**Hive boxes:** `daily_routine` (kDailyRoutineBox)

**Routes:** `/daily`

---

## Dashboard

**What it does:** The main home screen — the hub connecting to every other feature. Shows XP, ZAMu level, wallet balance, streak, daily challenge prompt, flash challenge, XP boost timer, net worth summary, budget widget, and quick-access cards for all major features. Watches the largest number of providers of any screen (15+).

**Screens:** DashboardScreen

**Providers:** `dashboardProvider`, `authProvider`, `dailyChallengeProvider`, `seasonalEventProvider`, `walletProvider`, `flashChallengeProvider`, `xpBoostProvider`, `badgeProvider`, `familyProvider`, `businessProvider`, `lifeEventsProvider`, `propertyProvider`, `portfolioProvider`, `loansProvider`, `savingsProvider`, `networthProvider`, `newsProvider`, `healthProvider`, `mentorProvider`, `dailyRoutineProvider`, `streakProvider`

**Hive boxes:** `users`, `settings` (direct reads for `kTutorialCompletedKey`, `dc_dialog_shown_<uid>`, `budget_alloc_<uid>`, `budget_income_<uid>`)

**Routes:** `/home` (inside ShellRoute)

---

## Family

**What it does:** Simulates family financial responsibilities — dependants, school fees, medical costs. A `FamilyModel` tracks the family composition and related expenses. Family expenses feed into the Net Worth calculation.

**Screens:** FamilyScreen

**Providers:** `familyProvider`

**Hive boxes:** `family` (kFamilyBox)

**Routes:** `/family`

---

## Flash Challenge

**What it does:** Short timed quizzes that appear on the dashboard. The player has a limited time window to accept. Completing earns XP and streak bonus. Hearts are consumed on failure. Uses an `xpBoostProvider` multiplier for bonus XP during active XP boosts.

**Screens:** FlashChallengeScreen

**Providers:** `flashChallengeProvider`, `heartsProvider`, `inventoryProvider`, `authProvider`, `streakProvider`

**Hive boxes:** `users` (kUserBox via auth), `inventory` (kInventoryBox)

**Routes:** `/flash-challenge`, `/challenge-expired`

---

## Health

**What it does:** Tracks user health-related financial events (medical expenses, insurance). A `HealthRecord` stores the data. Health costs feed into the Net Worth calculation.

**Screens:** HealthScreen

**Providers:** `healthProvider`

**Hive boxes:** `health` (kHealthBox)

**Routes:** `/health`

---

## Hearts

**What it does:** The lives system. The player has a maximum of 5 hearts. Hearts are lost when failing quizzes or challenges. Hearts refill automatically over time (one per 30 minutes by default — `_applyRefill()` is called in the notifier constructor and on `timeUntilNextRefill()`). When all hearts reach 0, the player is redirected to `/hearts-depleted`. The `HeartsModel` stores `heartsCount` and a list of `lostAt` ISO-8601 timestamps.

**Screens:** HeartsDepletedScreen

**Widgets:** HeartsHUD (ConsumerStatefulWidget shown in many screens)

**Providers:** `heartsProvider` (StateNotifier<HeartsModel>)

**Hive boxes:** `hearts` (kHeartsBox), keyed by uid

**Routes:** `/hearts-depleted`

---

## Investment / Portfolio

**What it does:** Simulates a stock/investment portfolio in ZMW. The user allocates virtual money across investment categories. A `PortfolioModel` tracks holdings. Portfolio value feeds into Net Worth.

**Screens:** PortfolioScreen

**Providers:** `portfolioProvider`

**Hive boxes:** `investments` (kInvestmentsBox)

**Routes:** `/portfolio`

---

## Leaderboard

**What it does:** Shows a ranked list of players by XP. The list is seeded once at app startup with 9 fictional Zambian players stored in the `leaderboard` box under the `'entries'` key. The current user's entry is dynamically inserted at the correct rank position. The leaderboard data is read directly from Hive in the build method (not via a Riverpod provider).

**Screens:** LeaderboardScreen

**Providers:** `authProvider` (for current user XP)

**Hive boxes:** `leaderboard` (kLeaderboardBox) — direct Hive.box() read in build

**Routes:** `/leaderboard` (inside ShellRoute)

---

## Levels

**What it does:** The core progression system. Levels are grouped into Zones (groups of ~3 levels each). Each level is represented by a `LevelModel` stored under the key `'<uid>_<levelId>'`. Level status transitions: LOCKED → IN_PROGRESS → COMPLETED. Completing all levels in a Zone unlocks the Boss for that Zone. The LevelMapScreen renders an animated dot-grid path (via `MapPainter`) with animated zone nodes (`ZoneNodeWidget`).

**Screens:** LevelMapScreen, LevelScreen

**Widgets:** MapPainter (CustomPainter), ZoneNodeWidget

**Providers:** `levelProvider` (StateNotifier), `singleLevelProvider` (family Provider)

**Hive boxes:** `levels` (kLevelBox), `users` (kUserBox for XP updates)

**Routes:** `/levels` (ShellRoute tab), `/levels/:levelId`, `/levels/:levelId/boss`

---

## Life Events

**What it does:** Random life events (e.g., "car breakdown — pay K800 for repairs") that pop up during gameplay, simulating real financial shocks. A `LifeEventRecord` tracks which events have occurred. Life events were originally gated behind a tutorial guard, which caused a regression (see Bug 19 in bug-history.md).

**Screens:** LifeEventScreen

**Providers:** `lifeEventsProvider`

**Hive boxes:** `life_events` (kLifeEventsBox)

**Routes:** `/life-event` (fade transition)

---

## Loans

**What it does:** Simulates borrowing — the user takes a loan in ZMW and must repay it with simulated interest. A `LoanRecord` tracks the outstanding balance. Loan obligations reduce Net Worth.

**Screens:** LoansScreen

**Providers:** `loansProvider`

**Hive boxes:** `loans` (kLoansBox)

**Routes:** `/loans`

---

## Mentors

**What it does:** Provides financial mentor characters who give tips and advice. A `MentorRecord` tracks which mentor interactions have occurred. Mentors surface on the dashboard and via `/mentors`.

**Screens:** MentorsScreen

**Providers:** `mentorProvider`

**Hive boxes:** `mentors` (kMentorsBox)

**Routes:** `/mentors`

---

## Mini Games

**What it does:** Hosts two sub-games: Budget Blitz (drag expense cards into budget buckets) and Investment Flip (card-matching investment facts). `DraggableExpenseCard` and `DropBucket` are the custom drag-and-drop widgets. `DropBucket` uses `ValueNotifier<bool>` for hover state to avoid parent `setState` on every drag frame.

**Screens:** MiniGamesScreen, BudgetBlitzScreen, InvestmentFlipScreen

**Widgets:** DraggableExpenseCard, DropBucket

**Providers:** None (StatefulWidget game logic)

**Hive boxes:** `users` (kUserBox for XP rewards via auth provider)

**Routes:** `/mini-games`, `/mini-games/budget-blitz`, `/mini-games/invest-flip`

---

## Mystery Box

**What it does:** A daily reward mechanism where the player opens a virtual box to receive a random item (power-up, outfit, frame, streak icon) or ZMW coins. Items are added to the `InventoryModel`. Animated reveal sequence using a confetti overlay.

**Screens:** MysteryBoxScreen

**Providers:** `inventoryProvider`, `authProvider`

**Hive boxes:** `inventory` (kInventoryBox), `users` (kUserBox)

**Routes:** `/mystery-box` (slide-up transition)

---

## Net Worth

**What it does:** Calculates and displays the player's total net worth in ZMW by aggregating wallet balance, savings goals, portfolio value, property value, business value, minus outstanding loans and family obligations. Displayed as a chart (fl_chart) over time.

**Screens:** NetWorthScreen

**Providers:** `networthProvider`

**Hive boxes:** Multiple boxes (users, savings_goals, investments, property, business, loans, family)

**Routes:** `/networth`

---

## News

**What it does:** Simulated Zambian financial news feed. News items are stored locally as `NewsRecord` entries. News articles may affect in-game market prices or provide context for investment decisions.

**Screens:** NewsScreen

**Providers:** `newsProvider`

**Hive boxes:** `news` (kNewsBox)

**Routes:** `/news`

---

## Payments

**What it does:** Records simulated ZMW payment transactions when the player "pays" to unlock a level. A `PaymentRecord` is stored per transaction. Payment history is shown in the ProfileScreen.

**Screens:** PaymentScreen

**Providers:** `paymentHistoryProvider`

**Hive boxes:** `payments` (kPaymentBox)

**Routes:** `/payment/:levelId`

---

## Profile

**What it does:** Shows the current user's stats — avatar, name, XP, ZAMu level, streak, wallet balance, earned badges, collected proverbs, and payment history. Lets the user navigate to ChangeAvatar and DevScreen.

**Screens:** ProfileScreen

**Providers:** `currentUserProvider`, `paymentHistoryProvider`, `streakProvider`, `inventoryProvider`, `badgeMapProvider`, `proverbProvider`

**Hive boxes:** `users`, `settings` (for kTutorialCompletedKey)

**Routes:** `/profile` (ShellRoute tab), `/profile/dev`

---

## Proverbs

**What it does:** Collects traditional Zambian financial proverbs in four languages (Bemba, Nyanja, Tonga, Lozi) plus English. Proverbs are unlocked as the player progresses. A `ProverbRecord` tracks which proverbs have been seen (`totalProverbsSeen`) and collected (`collectedProverbIds`). Unlock state is also mirrored to kSettingsBox under `'proverbs_unlocked_<uid>'`.

**Screens:** ProverbsScreen

**Providers:** `proverbProvider`, `proverbUnlockProvider`

**Hive boxes:** `proverbs` (kProverbsBox), `settings` (kSettingsBox for unlock list)

**Routes:** `/proverbs`

---

## Quiz

**What it does:** Multiple-choice financial literacy questions presented during level completion and daily challenges. Correct answers award XP; wrong answers cost a heart. Completed quiz IDs are stored in `completedQuizIds` on `UserProfile` to prevent repetition.

**Screens:** QuizScreen

**Providers:** `quizProvider`

**Hive boxes:** `users` (kUserBox)

**Routes:** `/quiz`

---

## Savings

**What it does:** Lets the player set and track savings goals in ZMW (e.g., "Save K5,000 for school fees"). A `SavingsRecord` tracks goal name, target amount, and current amount. Savings balance feeds into Net Worth.

**Screens:** SavingsScreen

**Providers:** `savingsProvider`

**Hive boxes:** `savings_goals` (kSavingsGoalsBox)

**Routes:** `/savings`

---

## Seasons / Seasonal Events

**What it does:** Time-limited seasonal challenges (e.g., "Harvest Season Challenge") with special rewards. The current season ID is stored in `lastSeasonalEventId` on `UserProfile`. A `SeasonalEventScreen` shows the current seasonal event. A `SeasonScreen` shows the season overview. A season banner on the dashboard shows days remaining; the text changes to "Season ends today!" instead of "0 days remaining" when the final day is reached.

**Screens:** SeasonalEventScreen, SeasonScreen

**Providers:** `seasonalEventProvider`

**Hive boxes:** `users` (kUserBox)

**Routes:** `/seasonal-event`, `/seasons`

---

## Shop

**What it does:** In-game store where the player spends ZMW coins to buy power-ups, character outfits, profile frames, and streak icons. Purchases update `InventoryModel` and deduct from `walletBalance` on `UserProfile`. The `ShopItemCard` widget has glow + pop animation controllers for purchase feedback.

**Screens:** ShopScreen

**Widgets:** ShopItemCard

**Providers:** `inventoryProvider`, `walletProvider`, `authProvider`

**Hive boxes:** `inventory` (kInventoryBox), `users` (kUserBox)

**Routes:** `/shop`

---

## Spin

**What it does:** A daily prize wheel the player can spin once per day (tracked via `spinLastDate` on `UserProfile`). Bonus spins can be earned and are tracked in `bonusSpinsAvailable`. Prizes include ZMW coins, XP, and power-ups.

**Screens:** SpinScreen

**Providers:** `spinProvider`, `authProvider`

**Hive boxes:** `users` (kUserBox)

**Routes:** `/spin`

---

## Spotlights

**What it does:** Featured financial success stories from real Zambian entrepreneurs. Stories are pre-bundled content stored as `SpotlightRecord` entries. The player reads through multi-page story slides in `SpotlightStoryScreen`.

**Screens:** SpotlightsScreen, SpotlightStoryScreen

**Providers:** `spotlightsProvider`

**Hive boxes:** `spotlights` (kSpotlightsBox)

**Routes:** `/spotlights`, `/spotlights/story` (passes storyId and storyIdx via `extra`)

---

## Stats

**What it does:** A summary statistics screen showing total XP earned, quizzes completed, challenges won, coins spent, and other aggregate metrics.

**Screens:** StatsScreen

**Providers:** `authProvider`, `levelProvider`

**Hive boxes:** `users` (kUserBox)

**Routes:** `/stats`

---

## Streak

**What it does:** Tracks the player's consecutive login streak. Streak length is stored in the `streak` box under `'<uid>_streak'`. Last active date is under `'<uid>_lastDate'`. Streak shields (protection items from the shop) are under `'<uid>_shields'`. Streak is displayed in the DashboardScreen and ProfileScreen.

**Screens:** Displayed in DashboardScreen, ProfileScreen

**Providers:** `globalStreakProvider`

**Hive boxes:** `streak` (kStreakBox) with per-uid primitive keys

**Routes:** No dedicated route

---

## Story

**What it does:** A branching narrative that follows a Zambian protagonist through financial life decisions. Chapters are unlocked by level progression. The player's choices are stored as `storyChoicesRaw` (Map<String,String>) on `UserProfile`. Chapter completion is tracked via `unlockedChapterIds`. A `StoryChapterProgress` per chapter tracks the current scene.

**Screens:** StoryMapScreen, StoryChapterScreen

**Providers:** (story-specific provider)

**Hive boxes:** `story` (kStoryBox), `users` (kUserBox for unlockedChapterIds)

**Routes:** `/story`, `/story/chapter/:chapterId`

---

## Tutorial

**What it does:** A one-time first-run tutorial that introduces the app to new users via a full-screen overlay with step-by-step highlights and dialog cards. Implemented as a dedicated full-screen GoRoute (`/tutorial`) with `NoTransitionPage`. Completion is marked by writing `true` to kSettingsBox under `kTutorialCompletedKey`. After completion, the TutorialScreen calls `context.go('/home')`.

**Screens:** TutorialScreen

**Providers:** None (reads/writes Hive directly via `markTutorialComplete()`)

**Hive boxes:** `settings` (kSettingsBox), key: `kTutorialCompletedKey = 'tutorial_completed'`

**Routes:** `/tutorial` (top-level, outside ShellRoute, NoTransitionPage)

---

## Wallet

**What it does:** Displays and manages the player's ZMW coin balance. `walletBalance` is an int field on `UserProfile`. The `WalletBadge` widget shows the balance with an animated count-up on change. `CoinEarnAnimation` shows a floating `+K<amount>` overlay when coins are earned.

**Screens:** Displayed in headers across multiple screens

**Widgets:** WalletBadge, CoinEarnAnimation

**Providers:** `walletProvider`

**Hive boxes:** `users` (kUserBox)

**Routes:** No dedicated route

---

## XP Boost

**What it does:** A consumable power-up (bought from the Shop) that temporarily doubles XP earnings. The expiry timestamp is stored as `xpBoostExpiry` (String ISO-8601) on `UserProfile`. The `xpBoostProvider` checks this timestamp on each quiz/challenge completion to determine the multiplier.

**Screens:** Displayed on DashboardScreen (countdown timer)

**Providers:** `xpBoostProvider`

**Hive boxes:** `users` (kUserBox)

**Routes:** No dedicated route
