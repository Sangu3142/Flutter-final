# Routing

Navigation is handled exclusively by go_router. The `GoRouter` instance is exposed as `routerProvider` and consumed by `MaterialApp.router`. All navigation must go through go_router — `Navigator.push()` is forbidden.

---

## Route Table

| Constant | Path | Screen | Inside ShellRoute? | Transition |
|---|---|---|---|---|
| `AppRoutes.splash` | `/` | SplashScreen | No | `_fadeSlidePage` |
| `AppRoutes.login` | `/login` | LoginScreen | No | Default |
| `AppRoutes.register` | `/register` | RegisterScreen | No | Default |
| `AppRoutes.onboarding` | `/onboarding` | OnboardingScreen | No | Default |
| `AppRoutes.home` | `/home` | DashboardScreen | **YES** | Shell |
| `AppRoutes.levels` | `/levels` | LevelMapScreen | **YES** | Shell |
| `AppRoutes.profile` | `/profile` | ProfileScreen | **YES** | Shell |
| `AppRoutes.leaderboard` | `/leaderboard` | LeaderboardScreen | **YES** | Shell |
| `AppRoutes.levelDetail` | `/levels/:levelId` | LevelScreen(levelId) | No | Default |
| `AppRoutes.payment` | `/payment/:levelId` | PaymentScreen(levelId) | No | Default |
| `AppRoutes.dev` | `/profile/dev` | DevScreen | No | Default |
| `AppRoutes.badges` | `/badges` | BadgesScreen | No | Default |
| `AppRoutes.dailyChallenge` | `/daily-challenge` | DailyChallengeScreen | No | Default |
| `AppRoutes.stats` | `/stats` | StatsScreen | No | Default |
| `AppRoutes.quiz` | `/quiz` | QuizScreen | No | Default |
| `AppRoutes.story` | `/story` | StoryMapScreen | No | Default |
| `AppRoutes.storyChapter` | `/story/chapter/:chapterId` | StoryChapterScreen | No | Default |
| `AppRoutes.seasonalEvent` | `/seasonal-event` | SeasonalEventScreen | No | Default |
| `AppRoutes.heartsDepleted` | `/hearts-depleted` | HeartsDepletedScreen | No | Default |
| `AppRoutes.dailyBonus` | `/daily-bonus` | DailyBonusScreen | No | Default |
| `AppRoutes.shop` | `/shop` | ShopScreen | No | Default |
| `AppRoutes.spin` | `/spin` | SpinScreen | No | Default |
| `AppRoutes.flashChallenge` | `/flash-challenge` | FlashChallengeScreen | No | Default |
| `AppRoutes.challengeExpired` | `/challenge-expired` | ChallengeExpiredScreen | No | Default |
| `AppRoutes.miniGames` | `/mini-games` | MiniGamesScreen | No | Default |
| `AppRoutes.budgetBlitz` | `/mini-games/budget-blitz` | BudgetBlitzScreen | No | Default |
| `AppRoutes.investFlip` | `/mini-games/invest-flip` | InvestmentFlipScreen | No | Default |
| `AppRoutes.mysteryBox` | `/mystery-box` | MysteryBoxScreen | No | Slide-up |
| `AppRoutes.boss` | `/levels/:levelId/boss` | BossScreen(levelId) | No | Slide-right |
| `AppRoutes.bossDefeat` | `/levels/:levelId/boss/defeat` | BossDefeatedScreen | No | Fade |
| `AppRoutes.coop` | `/coop` | CoopScreen | No | Slide-right |
| `AppRoutes.seasons` | `/seasons` | SeasonScreen | No | Slide-right |
| `AppRoutes.family` | `/family` | FamilyScreen | No | Default |
| `AppRoutes.business` | `/business` | BusinessScreen | No | Default |
| `AppRoutes.lifeEvent` | `/life-event` | LifeEventScreen | No | Fade |
| `AppRoutes.property` | `/property` | PropertyScreen | No | Default |
| `AppRoutes.portfolio` | `/portfolio` | PortfolioScreen | No | Default |
| `AppRoutes.loans` | `/loans` | LoansScreen | No | Default |
| `AppRoutes.savings` | `/savings` | SavingsScreen | No | Default |
| `AppRoutes.netWorth` | `/networth` | NetWorthScreen | No | Default |
| `AppRoutes.news` | `/news` | NewsScreen | No | Default |
| `AppRoutes.health` | `/health` | HealthScreen | No | Default |
| `AppRoutes.myths` | `/myths` | MythScreen | No | Default |
| `AppRoutes.spotlights` | `/spotlights` | SpotlightsScreen | No | Default |
| `AppRoutes.spotlightStory` | `/spotlights/story` | SpotlightStoryScreen | No | Default; storyId and storyIdx passed via `extra` |
| `AppRoutes.mentors` | `/mentors` | MentorsScreen | No | Default |
| `AppRoutes.proverbs` | `/proverbs` | ProverbsScreen | No | Default |
| `AppRoutes.dailyRoutine` | `/daily` | DailyRoutineScreen | No | Default |
| `AppRoutes.changeAvatar` | `/change-avatar` | ChangeAvatarScreen | No | Default |
| `AppRoutes.recoveryPlan` | `/recovery-plan` | RecoveryPlanScreen | No | Default |
| `AppRoutes.tutorial` | `/tutorial` | TutorialScreen | **No** (top-level) | `NoTransitionPage` |

---

## ShellRoute

The `ShellRoute` wraps the four main tab screens with `_MainScaffold`. The scaffold provides a persistent `BottomNavigationBar` (`_NavBar`) with four tabs:

| Tab Index | Route | Screen |
|---|---|---|
| 0 | `/home` | DashboardScreen |
| 1 | `/levels` | LevelMapScreen |
| 2 | `/profile` | ProfileScreen |
| 3 | `/leaderboard` | LeaderboardScreen |

The active tab index is computed from the current location string using prefix matching:
- location starts with `/home` → tab 0
- location starts with `/levels` → tab 1
- location starts with `/profile` → tab 2
- location starts with `/leaderboard` → tab 3

---

## Top-Level Routes (Outside ShellRoute)

These routes render without the bottom navigation bar:

- `/tutorial` — TutorialScreen. Full-screen, `NoTransitionPage`. This is the most important top-level route — it covers everything including the nav bar area.
- `/` — SplashScreen
- `/login` — LoginScreen
- `/register` — RegisterScreen
- `/onboarding` — OnboardingScreen
- All feature sub-routes listed in the table above

---

## Redirect Logic

The `redirect` callback in `routerProvider` runs on every navigation event. It is synchronous and reads state from `authProvider` and `dailyBonusProvider`.

```
1. If location == '/' (splash):
   → Allow through (splash handles its own navigation)

2. If location == '/register':
   → Allow through (anyone can register)

3. If NOT authenticated AND location != '/login':
   → Redirect to '/login'

4. If authenticated AND onboarding NOT done AND location != '/onboarding':
   → Redirect to '/onboarding'

5. If authenticated AND onboarding done AND (location == '/login' OR location == '/onboarding'):
   → Redirect to '/home'

6. If authenticated AND onboarding done AND dailyBonusProvider.shouldShow == true
   AND location != '/daily-bonus':
   → Redirect to '/daily-bonus'

7. Otherwise:
   → Allow through (null return = no redirect)
```

The daily bonus redirect (step 6) fires on every navigation. This means if the user has not yet claimed today's bonus, every `context.go()` call will redirect them to `/daily-bonus` instead of the intended destination.

---

## Navigation Rules

| Situation | Method | Reason |
|---|---|---|
| Switching between tabs | `context.go('/home')` | Replaces stack — keeps nav history clean |
| Navigating to a sub-screen | `context.push('/quiz')` | Adds to stack — back button returns to previous screen |
| After completing a challenge | `context.go('/home')` | Pop-to-root pattern |
| After async operations | `if (context.mounted) context.go(...)` | Context may be invalid after await |
| Passing non-path data | `context.push('/spotlights/story', extra: {...})` | For data that can't go in path params |
| From a callback / postFrameCallback | `context.go(...)` | Safe from postFrameCallback; do NOT use from build() directly |

**Never use `Navigator.push()`.** It bypasses the GoRouter redirect logic. Auth guards and daily bonus redirects will not fire.

---

## Custom Page Transitions

| Route | Transition Type |
|---|---|
| `/` (splash) | `_fadeSlidePage` — custom fade + upward slide |
| `/mystery-box` | Slide up from bottom |
| `/levels/:levelId/boss` | Slide right |
| `/levels/:levelId/boss/defeat` | Fade |
| `/coop` | Slide right |
| `/seasons` | Slide right |
| `/life-event` | Fade |
| `/tutorial` | `NoTransitionPage` — instant, no animation |
| All others | Default platform transition (slide on Android, none on iOS) |

---

## Known Routing Lessons

### Lesson 1: GoRouterState.of(context) context location matters

`GoRouterState.of(context)` can only be called from a `BuildContext` that is a **descendant** of the GoRouter's widget subtree. The `MaterialApp.router builder:` context is a **sibling**, not a descendant. Calling `GoRouterState.of(context)` from the builder context throws an exception.

**Fix:** Move any widget that needs router state into a screen-level widget, not into `builder:`.

### Lesson 2: context.go() is safe from postFrameCallback

Calling `context.go()` directly inside `build()` will trigger a redirect during a rebuild, causing a `setState() called during build` assertion. Use `WidgetsBinding.instance.addPostFrameCallback(() => context.go(...))` instead, or trigger navigation from callbacks/event handlers.

### Lesson 3: showDialog cannot be safely called from build methods

`showDialog(context: context, ...)` opens a new route on the navigator. Calling it from inside a `build()` method (even via `addPostFrameCallback`) during the first frame can cause the dialog barrier to render but the dialog content to fail silently. Use a dedicated full-screen route instead.

### Lesson 4: context.go() replaces the stack

`context.go('/home')` after completing a challenge pops all intermediate routes. If you want the back button to return to a previous screen, use `context.push()` instead. Be deliberate about which pattern you choose for each navigation.
