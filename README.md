# ZamWealth Quest

ZamWealth Quest is a gamified financial literacy and micro-investment simulation app for Zambian users, built in Flutter/Dart. The app is **100% offline** — no internet connection required — and all monetary values are denominated in **ZMW (Zambian Kwacha)**. Players progress through a level-based adventure map, complete quizzes and challenges, manage simulated budgets and investments, and earn rewards while building real financial knowledge.

> Built at UNILUS, Lusaka, Zambia

---

## Tech Stack

| Technology | Role |
|---|---|
| Flutter / Dart | Mobile app (Android + iOS) |
| `flutter_riverpod ^2.5.1` | State management |
| `hive ^2.2.3` + `hive_flutter` | Local offline storage |
| `go_router ^13.0.0` | Navigation / routing |
| `fl_chart ^0.67.0` | Charts (net worth, portfolio) |
| `google_fonts ^6.2.1` | Typography |
| `font_awesome_flutter ^10.7.0` | Icons |
| `confetti ^0.7.0` | Confetti animations |
| `intl ^0.19.0` | Date / number formatting |
| `path_provider ^2.1.2` | File system paths |
| `connectivity_plus ^6.0.3` | Network state detection |
| `uuid ^4.3.3` | Unique ID generation |

---

## Quick Links

| Document | Description |
|---|---|
| [docs/architecture.md](docs/architecture.md) | Widget tree, ProviderScope, ShellRoute, architectural rules |
| [docs/features.md](docs/features.md) | Every feature — screens, providers, Hive boxes |
| [docs/providers.md](docs/providers.md) | Full Riverpod provider catalogue |
| [docs/hive.md](docs/hive.md) | All Hive boxes, keys, and write-safety rules |
| [docs/routing.md](docs/routing.md) | All routes, ShellRoute, redirect logic |
| [docs/bug-history.md](docs/bug-history.md) | 19 documented bugs with root causes and fixes |
| [docs/security.md](docs/security.md) | Security audit: encryption, auth, data integrity |
| [docs/performance.md](docs/performance.md) | Performance audit: rebuilds, animations, Hive patterns |
| [docs/setup.md](docs/setup.md) | Full developer setup guide |

---

## Setup (Quick Start)

```bash
# 1. Clone the repo
git clone <repo-url>
cd zamwealth_quest

# 2. Install dependencies
flutter pub get

# 3. Connect an Android device (API 21+) with USB Debugging enabled
flutter devices

# 4. Run
flutter run
```

Full setup instructions, emulator configuration, and common error fixes are in [docs/setup.md](docs/setup.md).

---

## Architecture Overview

```mermaid
graph TD
    A[main.dart] --> B[ProviderScope]
    B --> C[ZamWealthApp]
    C --> D[MaterialApp.router]
    D --> E[GoRouter — routerProvider]

    E --> F[ShellRoute — _MainScaffold]
    F --> F1[/home — DashboardScreen]
    F --> F2[/levels — LevelMapScreen]
    F --> F3[/profile — ProfileScreen]
    F --> F4[/leaderboard — LeaderboardScreen]

    E --> G[Top-level routes]
    G --> G1[/tutorial — TutorialScreen]
    G --> G2[/splash, /login, /register, /onboarding]
    G --> G3[/quiz, /shop, /spin, /boss, /mini-games ...]

    F1 --> P1[dashboardProvider]
    F1 --> P2[authProvider]
    F1 --> P3[heartsProvider]
    F2 --> P4[levelProvider]
    F3 --> P5[inventoryProvider]
    F4 --> P6[Hive.box kLeaderboardBox]

    P1 --> H1[(Hive: users, settings)]
    P3 --> H2[(Hive: hearts)]
    P4 --> H3[(Hive: levels, users)]
    P5 --> H4[(Hive: inventory)]
```

Every screen talks to Riverpod providers; providers read and write Hive boxes. The app never makes a network call.
