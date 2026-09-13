# ZamWealth Quest — Feature Inventory

All 15 educational/gamification features implemented in the Flutter app.
100% offline (Hive persistence). No cloud dependency.

---

## Wave 0 — Critical Bug Fixes (Phase 0)

Pre-existing features stabilised before new work began.

---

## Wave 1 — Foundation & Economy

### Feature 1 — Daily Challenge System
**Route:** `/daily-challenge`  
**Provider:** `dailyChallengeProvider` · **Box:** `daily_challenge` (typeId 3)  
Multiple-choice financial quiz that resets each day. Tracks current streak, streak shields (protect streak on a missed day), and bonus XP for multi-day streaks. Dashboard card shows question preview and fires a reminder dialog once per day.

### Feature 2 — Hearts & Lives
**Route:** `/hearts-depleted`  
**Provider:** `heartsProvider` · **Box:** `hearts` (typeId 10)  
5-heart life system. Hearts are lost on wrong quiz/myth answers. Regenerates 1 heart every 4 hours. Full regen wipes the depleted timestamp. When all hearts are gone, a paywall screen blocks progress.

### Feature 3 — Shop & Inventory
**Route:** `/shop`  
**Provider:** `inventoryProvider` · **Box:** `inventory` (typeId 11)  
ZamCoin shop selling XP boosts (2× for 30 min), avatar frames (gold/copper/emerald), and streak icon skins (blue/purple/rainbow flame). Purchases deduct from wallet and are persisted in the inventory model.

### Feature 4 — Spin the Wheel
**Route:** `/spin`  
**Provider:** `spinProvider`  
Daily prize wheel with 8 wedges: XP rewards (50–500 XP), ZamCoin rewards (20–200 ZC), a heart refill, and a mystery box token. One spin per day; results are Hive-persisted via settings box.

### Feature 5 — Flash Challenges
**Route:** `/flash-challenge` · `/challenge-expired`  
**Provider:** `flashChallengeProvider`  
Time-limited pop-up challenges (30-minute window). Appear once per session if the user hasn't already completed one today. Correct answer pays bonus XP; expired challenges show a dedicated screen.

---

## Wave 2 — Map, Shop & Spin (extended)

### Feature 6 — Mini-Games Hub
**Route:** `/mini-games` · `/mini-games/budget-blitz` · `/mini-games/invest-flip`  
**Screens:** `MiniGamesScreen`, `BudgetBlitzScreen`, `InvestmentFlipScreen`  
Hub screen listing two playable mini-games:

- **Budget Blitz** — Drag-and-drop 50/30/20 rule allocation game under time pressure.
- **Investment Flip** — Card-flip memory game matching investment terms to definitions.

Both award XP on completion and penalise hearts on wrong answers.

### Feature 7 — Mystery Box
**Route:** `/mystery-box`  
**Provider:** `mysteryBoxProvider`  
Scratch-card style reward reveal. Tokens earned from the spin wheel. Box contents are seeded from a weighted pool: common (XP/coins), rare (heart refill, frame), legendary (large XP/coin drops).

### Feature 8 — Boss Battles
**Route:** `/levels/:levelId/boss` · `/levels/:levelId/boss/defeat`  
**Provider:** `bossProvider` · **Box:** `boss` (typeId 13)  
Each level gate (2–5) has a boss encounter: 5-round trivia battle with adaptive difficulty. Losing a round costs a heart; winning all 5 unlocks the next level and awards a level badge. Defeated bosses can be replayed.

---

## Wave 3 — Challenges, Mini-Games & Avatar (extended)

### Feature 9 — Co-op Mode (Zamu Companion)
**Route:** `/coop`  
**Widget:** `ZamuCompanionWidget` (floats on dashboard)  
AI companion "Zamu" gives contextual financial nudges. Companion widget sits bottom-right on the dashboard; tapping opens the Co-op screen showing shared challenge history and companion level.

### Feature 10 — Seasonal Events
**Route:** `/seasonal-event`  
**Provider:** `seasonalProvider`  
Calendar-aware event system covering 5 Zambian financial seasons: New Year budgeting, School Fees, Farming Season, Harvest Festival, Christmas. Each event offers unique XP and ZamCoin bonuses and expires at month-end.

---

## Wave 4 — Educational Content (Features 11–15)

### Feature 11 — Financial Myth-Busting Cards
**Route:** `/myths`  
**Provider:** `mythProvider` · **Box:** `myths` (typeId 18)  

Tinder-style swipe game exposing 30 common Zambian financial misconceptions. Each session serves 3 unseen myth cards; the pool resets once all 30 are seen. Cards rotate through 6 categories (Banking, Savings, Investment, Insurance, Credit, Tax).

- **LEFT swipe / "It's a MYTH" button** — correct answer, awards XP (5–15 XP per card)
- **RIGHT swipe / "It's TRUE" button** — wrong answer, costs a heart
- After each answer, the real fact is revealed with a fade-in animation
- Daily limit of 3 cards prevents fatigue
- Progress dots show today's session position

**Hive fields:** uid, seenMythIds, correctMythIds, totalMythsAnswered, lastDailyDateStr, todaysMythIds

---

### Feature 12 — Zambian Entrepreneur Spotlights
**Routes:** `/spotlights` · `/spotlights/story`  
**Provider:** `spotlightProvider` · **Box:** `spotlights` (typeId 19)  

6 interactive branching stories following Zambian entrepreneurs through real financial decisions. Each story has 5 chapters with 3 decision points that alter the ending.

**Stories:**
1. Mwape's Market Stall (unlocks at Level 1) — informal trader expanding to formal business
2. Chanda's Chama Dilemma (Level 1) — rotating savings group vs. bank account
3. Bwalya's Farm Investment (Level 2) — seasonal income planning
4. Nalukui's Salon Loan (Level 2) — debt management and credit scores
5. Mutale's Tech Startup (Level 3) — equity vs. bootstrapping
6. Grace's Salon Chain (Level 3) — scaling a micro-business

**Mechanics:** Chapter progress saved per story. Majority-choice rule determines Ending A (optimal) or Ending B (alternative path). XP awarded on full completion (75–150 XP per story).

**Hive fields:** uid, completedSpotlightIds, chapterProgress (List), choicesJson (JSON-encoded Map)

---

### Feature 13 — Mentor Unlock System
**Route:** `/mentors`  
**Provider:** `mentorProvider` · **Box:** `mentors` (typeId 20)  

5 Zambian financial mentors that unlock as the player progresses. Each mentor provides a daily rotating tip (7 tips per mentor, rotates by day-of-year) and a one-time challenge.

**Mentors & Unlock Conditions:**
| Mentor | Specialty | Unlock Condition |
|--------|-----------|-----------------|
| Mr. Tembo 👨‍💼 | Budgeting | Level 2 complete |
| Nalukui Siame 👩‍💼 | Savings & Chamas | Level 3 complete |
| Dr. Bwalya 👨‍🔬 | Investment | Level 4 complete |
| Chanda Mwale 👩‍🏫 | Business Registration | Level 4 + business_registered badge |
| Mwansa Kapembwa 👴 | Wealth Building | Health Score ≥ 70 |

- Featured mentor rotates daily across unlocked mentors
- Challenge completion awards 50–100 XP
- Dashboard Mentor Tip card shows the featured mentor's daily tip

**Hive fields:** uid, unlockedMentorIds, lastTipDatesJson, challengesCompletedJson

---

### Feature 14 — Zambian Proverbs System
**Route:** `/proverbs` (Wisdom Book)  
**Provider:** `proverbProvider` · **Box:** `proverbs` (typeId 21)  
**Widget:** `ProverbTransitionCard` (shown between level transitions)

25 authentic proverbs in 5 Zambian languages, each paired with a financial lesson.

**Language distribution:**
- Bemba × 7 (e.g., "Akalulu ka mfumu takasebana" — A leader's word is not a joke)
- Nyanja × 5 (e.g., "Phiri siligwa pomwepo" — A mountain does not fall at once)
- Tonga × 5 (e.g., "Ubusuma bwa nkoko" — The fatness of a chicken)
- Lozi × 5 (e.g., "Mutende wa simu" — The peace of the land)
- Kaonde × 3

**Collection mechanics:**
- One proverb revealed between each level transition via `ProverbTransitionCard`
- Bookshelf view (`ProverbsScreen`) — 5-column spine grid, locked spines show a padlock
- Tapping a collected proverb opens a parchment-aesthetic card with original text, translation, and financial lesson
- Collecting all 25 awards the "Elder of Wisdom" title and a 200 XP bonus
- Profile screen shows Wisdom Book card with collection progress

**Hive fields:** uid, collectedProverbIds, totalProverbsSeen

---

### Feature 15 — Enhanced Daily Challenge Routine
**Route:** `/daily`  
**Provider:** `dailyRoutineProvider` · **Box:** `daily_routine` (typeId 22)  

3-part daily financial routine with time-gated sections and perfect day tracking.

**Sections:**
| Section | Time Window | Reward | Activity |
|---------|------------|--------|----------|
| ☀️ Morning Tip | 6am – 12pm | +10 XP | Read one of 60 rotating Zambian financial tips |
| 🧠 Midday Quiz | 12pm – 6pm | +25 XP | Complete the Daily Challenge quiz (piggybacks Feature 1) |
| 🌙 Evening Reflection | 6pm – midnight | +15 XP | Write a 50–200 character financial journal entry |

**Perfect Day System:**
- Complete all 3 sections in one day → **Perfect Day**: +50 XP + 15 ZamCoins
- Maintain a 7-day streak of perfect days → **Perfect Week**: +100 ZamCoins bonus
- Perfect Days and streak count displayed on the routine screen and in the journal

**Content pools:**
- 60 morning tips (rotate by day-of-year, Zambia-specific: mobile money, chamas, ZESCO tariffs, NAPSA, ZRA tax)
- 10 evening reflection prompts (rotate by day-of-year)

**Journal:** Last 5 reflections shown on the routine screen. Full journal persisted in Hive.

**Dashboard integration:** Daily Routine card shows today's morning tip and completion progress (N/3 done).

**Hive fields:** uid, lastMorningDateStr, lastMiddayDateStr, lastEveningDateStr, lastPerfectDayDateStr, reflectionJournal (List\<String\>), perfectDaysTotal, currentPerfectDayStreak, lastStreakDateStr

---

## My Life Simulations

### Family Simulator
**Route:** `/family` · **Box:** `family` (typeId 4)  
Virtual family with spouse, children, housing tier, and happiness score. Housing affects monthly ZMW expenditure.

### Business Simulator
**Route:** `/business` · **Box:** `business` (typeId 5)  
5-stage business lifecycle from side hustle to corporation. Weekly profit, registration milestones, and staff hiring.

### Life Events
**Route:** `/life-event` · **Box:** `life_events` (typeId 6)  
Random daily financial shocks (medical bill, car repair, salary increase). Requires player to make a financial decision.

---

## My Finances Simulations

### Property Ladder
**Route:** `/property` · **Box:** `property` (typeId 7)  
5-tier housing progression (renting → mansion). Mortgage simulation with monthly payments.

### Investment Portfolio
**Route:** `/portfolio` · **Box:** `investments` (typeId 8)  
LUSE equities, government bonds, treasury bills, and unit trusts. Simulated weekly returns.

### Loans & Debt
**Route:** `/loans` · **Box:** `loans` (typeId 14)  
Personal, business, and mortgage loan simulation. Credit score tracking (300–850). Monthly repayment calculator.

### Savings Goals
**Route:** `/savings` · **Box:** `savings_goals` (typeId 15)  
Goal-based saving with target amounts, deadlines, and progress rings.

---

## Analytics & Visualization

### Net Worth Dashboard
**Route:** `/networth`  
Aggregated ZMW net worth across property, portfolio, savings minus loans.

### Financial News Feed
**Route:** `/news` · **Box:** `news` (typeId 16)  
Rotating Zambian financial headlines with simulated market impact on portfolio values.

### Financial Health Score
**Route:** `/health` · **Box:** `health` (typeId 17)  
Composite 0–100 score across 5 pillars: Emergency Fund, Debt Ratio, Savings Rate, Investment Diversity, Income Stability. Mini gauge shown in the dashboard My Finances section header.

---

## TypeId Registry

| typeId | Model | Feature |
|--------|-------|---------|
| 0 | UserProfile | Auth |
| 1 | LevelModel | Levels |
| 2 | PaymentRecord | Payments |
| 3 | DailyChallengeRecord | Feature 1 |
| 4 | FamilyModel | Family |
| 5 | BusinessModel | Business |
| 6 | LifeEventRecord | Life Events |
| 7 | PropertyModel | Property |
| 8 | PortfolioModel | Portfolio |
| 10 | HeartsModel | Feature 2 |
| 11 | InventoryModel | Feature 3 |
| 12 | StoryChapterProgress | Story |
| 13 | BossRecord | Feature 8 |
| 14 | LoanRecord | Loans |
| 15 | SavingsRecord | Savings |
| 16 | NewsRecord | News |
| 17 | HealthRecord | Health Score |
| 18 | MythRecord | Feature 11 |
| 19 | SpotlightRecord | Feature 12 |
| 20 | MentorRecord | Feature 13 |
| 21 | ProverbRecord | Feature 14 |
| 22 | DailyRoutineRecord | Feature 15 |
