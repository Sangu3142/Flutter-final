"""
gen_docs.py
Generates ZamWealthQuest_Codebase_Documentation.docx in the project root.
Run: python gen_docs.py
"""

from docx import Document
from docx.shared import Pt, RGBColor, Inches, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.style import WD_STYLE_TYPE
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
import re

doc = Document()

# ── Page margins ──────────────────────────────────────────────────────────────
for section in doc.sections:
    section.top_margin    = Cm(2.5)
    section.bottom_margin = Cm(2.5)
    section.left_margin   = Cm(2.8)
    section.right_margin  = Cm(2.8)

# ── Style helpers ─────────────────────────────────────────────────────────────

def set_font(run, name="Calibri", size=11, bold=False, italic=False,
             color=None):
    run.font.name  = name
    run.font.size  = Pt(size)
    run.font.bold  = bold
    run.font.italic = italic
    if color:
        run.font.color.rgb = RGBColor(*color)

def h1(text):
    p = doc.add_heading(text, level=1)
    p.runs[0].font.color.rgb = RGBColor(0x00, 0x20, 0x3F)
    return p

def h2(text):
    p = doc.add_heading(text, level=2)
    p.runs[0].font.color.rgb = RGBColor(0x1A, 0x73, 0xE8)
    return p

def h3(text):
    p = doc.add_heading(text, level=3)
    p.runs[0].font.color.rgb = RGBColor(0x2B, 0xC4, 0x8A)
    return p

def h4(text):
    p = doc.add_heading(text, level=4)
    return p

def body(text):
    p = doc.add_paragraph(text)
    p.style.font.size = Pt(11)
    return p

def bullet(text, level=0):
    p = doc.add_paragraph(text, style="List Bullet")
    p.paragraph_format.left_indent = Inches(0.25 * (level + 1))
    return p

def numbered(text, level=0):
    p = doc.add_paragraph(text, style="List Number")
    p.paragraph_format.left_indent = Inches(0.25 * (level + 1))
    return p

def code_block(text):
    p = doc.add_paragraph()
    p.paragraph_format.left_indent  = Inches(0.4)
    p.paragraph_format.right_indent = Inches(0.4)
    pPr = p._p.get_or_add_pPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:val"),   "clear")
    shd.set(qn("w:color"), "auto")
    shd.set(qn("w:fill"),  "F0F4F8")
    pPr.append(shd)
    run = p.add_run(text)
    run.font.name  = "Courier New"
    run.font.size  = Pt(9)
    run.font.color.rgb = RGBColor(0x1A, 0x20, 0x2C)
    return p

def note(text):
    p = doc.add_paragraph()
    run = p.add_run("📝  " + text)
    run.font.italic = True
    run.font.size   = Pt(10)
    run.font.color.rgb = RGBColor(0x44, 0x44, 0x44)
    return p

def add_table(headers, rows, col_widths=None):
    table = doc.add_table(rows=1, cols=len(headers))
    table.style = "Table Grid"
    hdr = table.rows[0].cells
    for i, h in enumerate(headers):
        hdr[i].text = h
        for run in hdr[i].paragraphs[0].runs:
            run.font.bold = True
            run.font.size = Pt(10)
        tc = hdr[i]._tc
        tcPr = tc.get_or_add_tcPr()
        shd = OxmlElement("w:shd")
        shd.set(qn("w:val"),   "clear")
        shd.set(qn("w:color"), "auto")
        shd.set(qn("w:fill"),  "00203F")
        tcPr.append(shd)
        for para in hdr[i].paragraphs:
            for run in para.runs:
                run.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
                run.font.bold = True
    for row_data in rows:
        row = table.add_row().cells
        for i, cell_text in enumerate(row_data):
            row[i].text = cell_text
            for para in row[i].paragraphs:
                for run in para.runs:
                    run.font.size = Pt(10)
    return table

def page_break():
    doc.add_page_break()

# ══════════════════════════════════════════════════════════════════════════════
# TITLE PAGE
# ══════════════════════════════════════════════════════════════════════════════

title_para = doc.add_paragraph()
title_para.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = title_para.add_run("ZamWealth Quest")
run.font.name  = "Calibri"
run.font.size  = Pt(32)
run.font.bold  = True
run.font.color.rgb = RGBColor(0x00, 0x20, 0x3F)

sub_para = doc.add_paragraph()
sub_para.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = sub_para.add_run("Complete Codebase Documentation")
run.font.name  = "Calibri"
run.font.size  = Pt(20)
run.font.color.rgb = RGBColor(0x1A, 0x73, 0xE8)

doc.add_paragraph()

meta_para = doc.add_paragraph()
meta_para.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = meta_para.add_run("Version 1.0.0+1  ·  Flutter / Dart  ·  Offline-First  ·  Zambia")
run.font.size  = Pt(12)
run.font.color.rgb = RGBColor(0x55, 0x55, 0x55)

doc.add_paragraph()

desc_para = doc.add_paragraph()
desc_para.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = desc_para.add_run(
    "A gamified financial literacy platform built for the Zambian market.\n"
    "This document covers every file, class, function, data flow, and design decision."
)
run.font.size   = Pt(11)
run.font.italic = True
run.font.color.rgb = RGBColor(0x33, 0x33, 0x33)

page_break()

# ══════════════════════════════════════════════════════════════════════════════
# TABLE OF CONTENTS (static)
# ══════════════════════════════════════════════════════════════════════════════

h1("Table of Contents")
toc_items = [
    ("1", "Project Overview", ""),
    ("2", "Project Structure", ""),
    ("3", "How to Run the App", ""),
    ("4", "Full Code Breakdown", ""),
    ("  4.1", "Configuration Files", ""),
    ("  4.2", "Core Layer (theme, constants, router, tips)", ""),
    ("  4.3", "Authentication System", ""),
    ("  4.4", "Dashboard & Player Progress", ""),
    ("  4.5", "Level System", ""),
    ("  4.6", "Payment System", ""),
    ("  4.7", "Daily Challenge System", ""),
    ("  4.8", "Badges & Achievements", ""),
    ("  4.9", "Quiz System", ""),
    ("  4.10","Profile & Developer Tools", ""),
    ("  4.11","Story & Seasonal Events", ""),
    ("  4.12","Simulations (all 5)", ""),
    ("  4.13","Shared Widgets", ""),
    ("  4.14","Custom Painters (Canvas)", ""),
    ("  4.15","Supplementary Screens", ""),
    ("  4.16","Generated Hive Adapters", ""),
    ("5", "Data Flow", ""),
    ("6", "Gamification Logic", ""),
    ("7", "Known Limitations & TODOs", ""),
]
for num, title, _ in toc_items:
    p = doc.add_paragraph()
    p.paragraph_format.left_indent = Inches(0.2 if num.startswith(" ") else 0)
    run = p.add_run(f"{num.strip()}.  {title}")
    run.font.size = Pt(11)
    if not num.startswith(" "):
        run.font.bold = True

page_break()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — PROJECT OVERVIEW
# ══════════════════════════════════════════════════════════════════════════════

h1("1. Project Overview")

body(
    "ZamWealth Quest is a mobile application built with Flutter that teaches Zambian "
    "citizens how to manage personal finances through interactive simulations and "
    "game-like mechanics. It targets people at every income level — students, "
    "informal traders, civil servants, and entrepreneurs — and covers practical "
    "topics such as budgeting, debt management, savings, investing on the Lusaka "
    "Stock Exchange, and registering a business through PACRA (Patents and Companies "
    "Registration Agency)."
)

body(
    "The app works entirely offline. There is no cloud backend, no internet "
    "requirement after installation, and no real money changes hands. All user "
    "accounts, progress, and game state are stored locally on the device using "
    "Hive, a lightweight key-value database. This design decision makes the app "
    "accessible to users with limited or expensive mobile data."
)

h2("What the user experiences")
body(
    "When a new user opens ZamWealth Quest for the first time, they are shown a "
    "branded splash screen and then asked to create an account with a username and "
    "password. After logging in, a short onboarding flow asks three questions: "
    "income category (e.g. student, civil servant), financial goals (e.g. buy land, "
    "start a business), and risk appetite (low, medium, or high). These answers "
    "personalise the experience."
)
body(
    "The home screen (Dashboard) shows the player's name, current XP (experience "
    "points) and rank, a daily financial literacy challenge, a budget summary, "
    "shortcuts to the quiz and story features, and any badges earned. From the "
    "Levels tab the player accesses four themed learning zones:"
)
bullet("Level 1 — Kabulonga Gardens: budgeting basics (free to access)")
bullet("Level 2 — Woodlands Heights: debt management and savings (ZMW 25 unlock fee)")
bullet("Level 3 — Levy Financial District: investing and compound growth (ZMW 50)")
bullet("Level 4 — Mukuba Enterprise Park: starting and running a business (ZMW 80)")

body(
    "Each level contains between three and four simulations — hands-on interactive "
    "exercises like dragging sliders to allocate a monthly budget, or calculating "
    "NAPSA and PAYE deductions on a payroll. Completing every simulation in a level "
    "earns XP and unlocks a completion badge. Unlock fees are paid through simulated "
    "mobile money (MTN MoMo or Airtel Money) — no real money is involved."
)
body(
    "Alongside the levels, the app offers a 5-question financial quiz (earning XP "
    "and ZamCoins for correct answers), a branching narrative story called 'Kwacha "
    "Chronicles' following a character named Mwansa, monthly seasonal events with "
    "bonus rewards, a daily challenge question with a streak-and-shield mechanic, "
    "and a local leaderboard showing the player's XP rank against nine fictional "
    "Zambian competitors."
)

h2("Technology stack")
add_table(
    ["Technology", "Package", "Purpose"],
    [
        ["Flutter",        "SDK 3.0+",              "Cross-platform UI framework (Android & iOS)"],
        ["Dart",           "Language",               "Programming language"],
        ["Riverpod",       "flutter_riverpod 2.5.1", "Reactive state management"],
        ["GoRouter",       "go_router 13.0.0",       "Declarative URL-based navigation"],
        ["Hive",           "hive_flutter 1.1.0",     "Local offline key-value database"],
        ["Google Fonts",   "google_fonts 6.2.1",     "Orbitron, Rajdhani, and Inter typefaces"],
        ["fl_chart",       "fl_chart 0.67.0",        "Bar and line charts in stats screen"],
        ["connectivity_plus","6.0.3",                "Detect online/offline status"],
        ["uuid",           "4.3.3",                  "Generate unique payment record IDs"],
        ["intl",           "0.19.0",                 "Number and date formatting"],
    ]
)

page_break()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — PROJECT STRUCTURE
# ══════════════════════════════════════════════════════════════════════════════

h1("2. Project Structure")
body(
    "The project follows Flutter's recommended feature-first folder layout. "
    "Every major feature (auth, levels, quiz, story, etc.) lives in its own "
    "sub-folder under lib/features/, keeping screen code, business logic "
    "(providers), and data models co-located. Shared code that is used across "
    "multiple features lives in lib/shared/ and lib/core/."
)

tree = """
zamwealth_quest/
├── pubspec.yaml                   ← Dependency manifest and app metadata
├── analysis_options.yaml          ← Dart linting rules
├── gen_docs.py                    ← Documentation generator (this script)
├── android/                       ← Android platform project
├── ios/                           ← iOS platform project
└── lib/
    ├── main.dart                  ← App entry point; Hive init and seeding
    ├── core/
    │   ├── constants.dart         ← All app-wide constants, level metadata, quiz bank
    │   ├── router.dart            ← GoRouter graph, redirects, bottom-nav shell
    │   ├── theme.dart             ← Design system: palette, typography, ThemeData
    │   └── tips.dart              ← 73 Zambia-specific financial tips (rotated daily)
    ├── features/
    │   ├── auth/
    │   │   ├── models/
    │   │   │   ├── user_profile.dart     ← Central player data model (Hive typeId 0)
    │   │   │   └── user_profile.g.dart   ← Generated Hive adapter
    │   │   ├── providers/
    │   │   │   └── auth_provider.dart    ← Login, register, onboarding, XP, streak
    │   │   └── screens/
    │   │       ├── splash_screen.dart    ← 2-second branded splash
    │   │       ├── login_screen.dart     ← Username/password login form
    │   │       └── register_screen.dart  ← New account registration
    │   ├── onboarding/
    │   │   └── screens/
    │   │       └── onboarding_screen.dart ← 3-step preference collection
    │   ├── dashboard/
    │   │   ├── providers/
    │   │   │   └── dashboard_provider.dart ← Computed XP rank, streak, progress
    │   │   └── screens/
    │   │       └── dashboard_screen.dart   ← Home tab with all player stats
    │   ├── levels/
    │   │   ├── models/
    │   │   │   ├── level_model.dart       ← Per-user level progress (Hive typeId 1)
    │   │   │   └── level_model.g.dart     ← Generated Hive adapter
    │   │   ├── providers/
    │   │   │   └── level_provider.dart    ← Level state machine, sim completion
    │   │   ├── screens/
    │   │   │   ├── level_map_screen.dart  ← Vertical map of all 4 levels
    │   │   │   └── level_screen.dart      ← Level detail + simulation cards
    │   │   └── simulations/
    │   │       ├── budget_simulation.dart         ← L1: Income allocation sliders
    │   │       ├── savings_simulation.dart        ← L2: Savings goal calculator
    │   │       ├── debt_simulation.dart           ← L2: Debt avalanche calculator
    │   │       ├── investment_simulation.dart     ← L3: Risk/reward, compound, portfolio
    │   │       ├── business_simulation.dart       ← L4: PACRA, payroll, revenue, tax
    │   │       └── quiz_challenge_simulation.dart ← L1: Embedded mini-quiz
    │   ├── payments/
    │   │   ├── models/
    │   │   │   ├── payment_record.dart    ← Payment audit log (Hive typeId 2)
    │   │   │   └── payment_record.g.dart  ← Generated Hive adapter
    │   │   ├── providers/
    │   │   │   └── payment_provider.dart  ← Simulated 2-second payment flow
    │   │   └── screens/
    │   │       └── payment_screen.dart    ← Mobile money payment UI
    │   ├── daily_challenge/
    │   │   ├── models/
    │   │   │   ├── challenge.dart                 ← 30 daily challenge questions
    │   │   │   ├── daily_challenge_record.dart    ← Player streak record (Hive typeId 3)
    │   │   │   └── daily_challenge_record.g.dart  ← Generated Hive adapter
    │   │   ├── providers/
    │   │   │   └── daily_challenge_provider.dart  ← Date-seeded question, streak logic
    │   │   └── screens/
    │   │       └── daily_challenge_screen.dart    ← Full-screen challenge UI
    │   ├── badges/
    │   │   ├── models/
    │   │   │   └── badge_model.dart               ← 21 badge definitions
    │   │   ├── providers/
    │   │   │   └── badge_provider.dart            ← Award logic and badge map
    │   │   ├── screens/
    │   │   │   └── badges_screen.dart             ← Badge gallery
    │   │   └── widgets/
    │   │       └── badge_unlock_toast.dart        ← Toast shown on badge unlock
    │   ├── quiz/
    │   │   ├── providers/
    │   │   │   └── quiz_provider.dart             ← 5-question session, XP+coin awards
    │   │   └── screens/
    │   │       └── quiz_screen.dart               ← Quiz game interface
    │   ├── profile/
    │   │   ├── providers/
    │   │   │   └── profile_provider.dart          ← Payment history, dev tap counter
    │   │   └── screens/
    │   │       ├── profile_screen.dart            ← Profile tab
    │   │       └── dev_screen.dart                ← Developer console (easter egg)
    │   ├── leaderboard/
    │   │   └── screens/
    │   │       └── leaderboard_screen.dart        ← Local XP rankings
    │   ├── stats/
    │   │   └── screens/
    │   │       └── stats_screen.dart             ← Charts and progress stats
    │   ├── story/
    │   │   ├── models/
    │   │   │   ├── story_chapter_progress.dart    ← Chapter unlock/choice (Hive typeId 12)
    │   │   │   └── story_chapter_progress.g.dart  ← Generated Hive adapter
    │   │   ├── providers/
    │   │   │   └── story_provider.dart            ← Chapter unlock and choice recording
    │   │   └── screens/
    │   │       ├── story_map_screen.dart          ← Chapter selection
    │   │       └── story_chapter_screen.dart      ← Narrative + branching choices
    │   └── seasonal/
    │       ├── providers/
    │       │   └── seasonal_event_provider.dart   ← Monthly event state
    │       └── screens/
    │           └── seasonal_event_screen.dart     ← Event UI
    └── shared/
        ├── widgets/
        │   ├── animated_gradient_background.dart  ← Breathing dark gradient
        │   ├── offline_banner.dart                ← Connectivity status bar
        │   ├── sparkle_overlay.dart               ← XP gain particle effect
        │   ├── xp_bar.dart                        ← Reusable animated XP progress bar
        │   ├── sim_card.dart                      ← Simulation entry card widget
        │   ├── level_node.dart                    ← Level map node widget
        │   └── zamcoin_badge.dart                 ← ZamCoin balance display
        └── painters/
            ├── baobab_painter.dart                ← African baobab tree illustration
            ├── dot_grid_painter.dart              ← Subtle texture overlay
            ├── flame_painter.dart                 ← Streak flame animation
            ├── kente_pattern_painter.dart         ← Kente cloth cultural pattern
            ├── kwacha_icon_painter.dart           ← Zambian Kwacha currency icon
            ├── landscape_painter.dart             ← Level environment headers
            ├── segmented_progress_painter.dart    ← Simulation progress circles
            ├── shop_front_painter.dart            ← Business storefront illustration
            └── story/
                ├── building_painter.dart          ← Night-scene skyscraper
                ├── certificate_painter.dart       ← Achievement certificate
                ├── coins_painter.dart             ← Coin illustration
                ├── market_stall_painter.dart      ← Market stall scene
                └── supplier_painter.dart          ← Supplier/warehouse scene
"""
code_block(tree)

page_break()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — HOW TO RUN THE APP
# ══════════════════════════════════════════════════════════════════════════════

h1("3. How to Run the App")
body(
    "These instructions assume Flutter is already installed on your machine. "
    "No cloud services, Firebase, or Supabase accounts are required — the app "
    "is 100% local."
)

h2("Prerequisites")
bullet("Flutter SDK 3.0 or later (run `flutter --version` to check)")
bullet("Dart SDK 3.0+ (bundled with Flutter)")
bullet("Android Studio or Xcode (for device/emulator support)")
bullet("A physical Android or iOS device, or an emulator/simulator")
bullet("Git (to clone the repository)")

h2("Step-by-step setup")

numbered("Clone or open the project folder:")
code_block("cd \"C:\\Users\\sangu\\Documents\\Claude\\Projects\\Flutter final\"")

numbered("Install all Flutter dependencies listed in pubspec.yaml:")
code_block("flutter pub get")

note(
    "This downloads Riverpod, GoRouter, Hive, Google Fonts, fl_chart, and all "
    "other packages. An internet connection is needed only for this step."
)

numbered("Run the Hive code generator to produce the .g.dart adapter files "
         "(only needed if you modify a Hive model):")
code_block("dart run build_runner build --delete-conflicting-outputs")

numbered("Connect a device or start an emulator, then launch the app:")
code_block("flutter run")

body("For a specific device:")
code_block("flutter devices                    # list available devices\nflutter run -d <device_id>         # run on that device")

numbered("Optional — run in release mode for realistic performance:")
code_block("flutter run --release")

h2("First-launch behaviour")
body(
    "On the very first launch, main.dart initialises all Hive boxes and seeds the "
    "leaderboard with nine fictional Zambian player names. This runs automatically "
    "and takes less than one second. No manual database setup is required."
)

h2("Environment notes")
bullet("No .env file or secrets are needed.")
bullet("No Firebase, Supabase, or any remote API keys are used.")
bullet("The only network call is Google Fonts — fonts are cached after first download.")
bullet("Offline mode works fully after the first Google Fonts fetch.")

h2("Running tests")
code_block("flutter test")
note("The project has a minimal test scaffold. Most validation is done manually via the in-app developer console (7-tap easter egg on the version label in the Profile tab).")

page_break()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — FULL CODE BREAKDOWN
# ══════════════════════════════════════════════════════════════════════════════

h1("4. Full Code Breakdown")
body(
    "This section documents every Dart file in the project. Files are grouped by "
    "layer (core, feature, shared). Generated adapter files are noted as boilerplate "
    "and not expanded."
)

# ── 4.1 Configuration Files ───────────────────────────────────────────────────
h2("4.1  Configuration Files")

h3("pubspec.yaml")
body("The Flutter project manifest. Declares the app's name (zamwealth_quest), "
     "version (1.0.0+1), minimum SDK constraints, all third-party dependencies, "
     "and asset declarations. Notably, there are no native asset images — all "
     "illustrations are drawn at runtime using Flutter's Canvas API via CustomPainter "
     "classes.")

h3("analysis_options.yaml")
body("Configures the Dart analyser with the standard flutter_lints ruleset. "
     "Keeps code style consistent across the team. No custom lint overrides are present.")

# ── 4.2 Core Layer ─────────────────────────────────────────────────────────────
h2("4.2  Core Layer")

h3("lib/main.dart  —  App Entry Point")
body("This is the first Dart file that runs when the app launches. It does three things: "
     "initialises Hive, launches the Flutter app, and seeds placeholder leaderboard data.")

h4("Function: main()")
body("The async main function that Flutter calls on startup.")
code_block(
"""Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);

  // Register all Hive TypeAdapters before opening boxes
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(LevelModelAdapter());
  Hive.registerAdapter(PaymentRecordAdapter());
  Hive.registerAdapter(DailyChallengeRecordAdapter());
  Hive.registerAdapter(StoryChapterProgressAdapter());

  // Open all boxes so they are ready before the first screen renders
  await Future.wait([
    Hive.openBox<UserProfile>(kUserBox),
    Hive.openBox<LevelModel>(kLevelBox),
    Hive.openBox<PaymentRecord>(kPaymentBox),
    Hive.openBox(kSessionBox),
    Hive.openBox(kLeaderboardBox),
    Hive.openBox(kSettingsBox),
    Hive.openBox<DailyChallengeRecord>(kDailyChallengeBox),
    Hive.openBox<StoryChapterProgress>(kStoryBox),
  ]);

  await _seedLeaderboard();
  runApp(const ProviderScope(child: ZamWealthApp()));
}""")
note("WidgetsFlutterBinding.ensureInitialized() must be called before any async "
     "work in main() so that Flutter's engine is ready to handle platform channel "
     "calls (which path_provider uses to find the app documents directory).")

h4("Function: _seedLeaderboard()")
body("Creates nine fictional Zambian player entries in the leaderboard Hive box "
     "the first time the app runs. Each entry has a Zambian name, a random XP "
     "value between 50 and 2150, and a random badge. If entries already exist, "
     "the function does nothing.")

h4("Class: ZamWealthApp (ConsumerWidget)")
body("The root widget of the application. Wraps MaterialApp.router with "
     "zamWealthTheme (dark fintech palette) and wires it to the GoRouter instance "
     "from routerProvider. ConsumerWidget allows it to read the Riverpod router "
     "provider.")

h3("lib/core/theme.dart  —  Design System")
body("Defines every visual constant and Flutter ThemeData used across the app. "
     "A teammate who wants to change a colour, font, or component style should "
     "look here first.")

h4("Colour palette (constants)")
add_table(
    ["Constant", "Hex Value", "Used For"],
    [
        ["kCoreNavy",      "#00203F", "Deepest background, gradient top stops"],
        ["kDeepNavy",      "#0D1B2A", "Card and surface backgrounds"],
        ["kNeonMint",      "#36ECDE", "Primary accent — buttons, selected states, XP bar"],
        ["kPrimaryBlue",   "#1A73E8", "Secondary accent — info, links, sparkles"],
        ["kGold",          "#FFB703", "XP rewards, ZamCoins, streak indicators"],
        ["kGreen",         "#2BC48A", "Success states, completed badges"],
        ["kCharcoal",      "#E2E8F0", "Primary text on dark backgrounds"],
        ["kCharcoalLight", "#94A3B8", "Secondary/muted text"],
        ["kWarning",       "#FB8500", "Over-budget and caution alerts"],
        ["kError",         "#EF5350", "Wrong answers, critical errors"],
    ]
)

h4("Typography helper functions")
body("Three private functions produce Google Fonts TextStyles:")
bullet("_orbitron() — futuristic mono-style font for numbers and hero displays")
bullet("_rajdhani() — condensed heading font for all titles and button labels")
bullet("_inter() — clean sans-serif for body copy, descriptions, and form fields")

h4("Function: zamCard()")
body("Returns a BoxDecoration that creates the 'dark glass card' effect used on "
     "every card surface. The highlighted parameter changes the border to neon mint "
     "when a card is in an active or selected state.")
code_block(
"""BoxDecoration zamCard({bool highlighted = false, double radius = 16}) =>
    BoxDecoration(
      color: kDeepNavy.withValues(alpha: 0.60),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: highlighted
            ? kNeonMint.withValues(alpha: 0.50)
            : Colors.white.withValues(alpha: 0.08),
        width: highlighted ? 1.5 : 1.0,
      ),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.30),
                            blurRadius: 20)],
    );""")
note("withValues(alpha:) is a Flutter API that creates a copy of the colour with "
     "a new opacity. It replaces the older withOpacity() call and is more efficient "
     "because it avoids allocating a new Color object at every frame.")

h4("Class: GlassCard (StatelessWidget)")
body("A ready-made widget that applies BackdropFilter blur (10px sigmaX/Y), "
     "ClipRRect rounded corners, and zamCard decoration around any child widget. "
     "Used in simulation sheets and onboarding screens.")

h3("lib/core/constants.dart  —  Central Constants Registry")
body("The single source of truth for every constant in the application. If a number "
     "appears in the code that affects game balance or business rules, it is defined "
     "here. This makes tuning the game (e.g., changing XP rewards or unlock prices) "
     "a one-file change.")

h4("Hive box name constants")
body("String constants like kUserBox = 'users' are used everywhere Hive boxes are "
     "opened or read. They prevent typo bugs from using raw string literals in "
     "multiple files.")

h4("Level pricing and XP rewards")
add_table(
    ["Level", "Name", "Unlock Price", "XP on Completion"],
    [
        ["1", "Kabulonga Gardens",       "Free",    "200 XP"],
        ["2", "Woodlands Heights",       "ZMW 25",  "400 XP"],
        ["3", "Levy Financial District", "ZMW 50",  "600 XP"],
        ["4", "Mukuba Enterprise Park",  "ZMW 80",  "1,000 XP"],
    ]
)

h4("XP rank thresholds and helper functions")
add_table(
    ["XP Range",    "Rank Label"],
    [
        ["0 – 199",    "Kwacha Starter"],
        ["200 – 599",  "ZMW Builder"],
        ["600 – 1,199","Copper Investor"],
        ["1,200 – 2,199","Mukuba Tycoon"],
        ["2,200+",     "ZamWealth Legend"],
    ]
)
body("Three helper functions sit alongside the threshold list:")
bullet("xpRankLabel(xp) — returns the rank label string for a given XP value")
bullet("xpToNextRank(xp) — returns how many XP are needed to reach the next rank")
bullet("xpCurrentRankStart(xp) — returns the XP value at which the current rank began")

h4("Zambia-specific economic constants")
add_table(
    ["Constant",           "Value",  "Meaning"],
    [
        ["kZmwInflationRate",  "0.12",   "12% annual inflation (used in inflation simulation)"],
        ["kBozLendingRate",    "0.26",   "26% Bank of Zambia lending rate"],
        ["kCompoundRates",     "[0.08, 0.15, 0.22]", "Three investment growth rates shown in compound chart"],
        ["NAPSA employee %",   "5%",     "Employee NAPSA contribution (defined in business sim)"],
        ["VAT rate",           "16%",    "Zambia VAT (defined in business sim)"],
        ["Corporate tax",      "35%",    "Zambia corporate income tax (defined in business sim)"],
    ]
)

h4("Class: LevelMeta")
body("An immutable data class that bundles all display information for one level: "
     "id, name, subtitle, price, xpReward, isFree flag, a list of business names "
     "shown as examples, and a list of simulation IDs. The map kLevelMeta<int, LevelMeta> "
     "provides O(1) lookup by level ID.")

h4("Class: QuizQuestion")
body("A const data class with id, question text, a list of four answer options, "
     "the correctIndex (0-based), an explanation paragraph, a category string, and "
     "an xpReward (defaults to kQuizXpCorrect = 30). "
     "The constant kQuizQuestions contains 60 of these, spanning six categories: "
     "Budgeting, Savings, Debt, Investing, Entrepreneurship, and Zambian Finance.")

h3("lib/core/router.dart  —  Navigation Graph")
body("All screen routes, redirect rules, and page transitions are defined in one "
     "place. GoRouter is a URL-based navigation library that makes navigation "
     "predictable and testable.")

h4("Class: AppRoutes")
body("A utility class with static string constants for every route path. "
     "Using these constants instead of raw strings prevents typo bugs when "
     "navigating from any screen.")

h4("Function: _fadeSlidePage()")
body("A factory that returns a CustomTransitionPage combining a fade and a 5% "
     "upward slide over 350 ms with an ease-out curve. Every route in the app "
     "uses this transition for visual consistency.")

h4("Redirect logic in routerProvider")
body("GoRouter evaluates this function before every navigation event:")
code_block(
"""redirect: (context, routerState) {
  final isAuth        = ref.read(authProvider).isAuthenticated;
  final doneOnboarding = ref.read(authProvider).hasCompletedOnboarding;
  final location      = routerState.matchedLocation;

  if (!isAuth)         return AppRoutes.login;         // must log in first
  if (!doneOnboarding) return AppRoutes.onboarding;    // must complete setup
  if (location == AppRoutes.login) return AppRoutes.home; // already logged in
  return null; // no redirect needed
}""")
note("Returning null means 'allow this navigation'. Returning a path string means "
     "'redirect here instead'. The logic is stateless and runs on every route change.")

h4("Class: _MainScaffold (StatelessWidget)")
body("The shell widget that wraps all four tab screens. It renders the bottom "
     "navigation bar and an AnimatedSwitcher that crossfades between tabs. The "
     "_currentIndex getter maps the current URL path to a tab index (0=Home, "
     "1=Levels, 2=Profile, 3=Leaderboard).")

h4("Class: _NavBar (StatelessWidget)")
body("Renders the bottom navigation bar with four items. Wraps the Flutter "
     "BottomNavigationBar in a Container that provides the #0A1628 background "
     "colour and a neon mint top border. Explicitly handles the system gesture "
     "area inset (MediaQuery.padding.bottom) to prevent portrait-mode overflow.")

h3("lib/core/tips.dart  —  Financial Tips")
body("A single constant list (kFinancialTips) containing 73 plain-English financial "
     "literacy tips tailored for Zambia. Topics include mobile money fees, NATSAVE "
     "accounts, the Rule of 72, Zambia Treasury Bills, ZSE-listed stocks, PACRA "
     "registration costs, and NAPSA contributions. The Dashboard rotates tips daily "
     "using DateTime.now()._dayOfYear % kFinancialTips.length as the index.")

page_break()

# ── 4.3 Authentication ─────────────────────────────────────────────────────────
h2("4.3  Authentication System")

h3("lib/features/auth/models/user_profile.dart  —  Player Data Model")
body("UserProfile is the central record for every player in the game. It is stored "
     "in the Hive 'users' box, keyed by the player's username. Every piece of "
     "progress — XP, badges, completed quizzes, story chapters — lives in this object.")

h4("Hive fields at a glance")
add_table(
    ["Field #", "Name",                "Type",          "What It Stores"],
    [
        ["0",  "uid",                 "String",         "Username (also the Hive box key)"],
        ["1",  "name",                "String",         "Display name shown in the UI"],
        ["2",  "username",            "String",         "Login username (lowercased)"],
        ["3",  "passwordHash",        "String",         "Salted base64 hash — never plain text"],
        ["4",  "incomeCategory",      "String",         "student / informal_trader / civil_servant / entrepreneur"],
        ["5",  "financialGoals",      "List<String>",   "Selected goals from onboarding"],
        ["6",  "riskAppetite",        "String",         "low / medium / high"],
        ["7",  "xp",                  "int",            "Total experience points accumulated"],
        ["8",  "zamCoins",            "int",            "In-game currency balance"],
        ["9",  "currentLevel",        "int",            "Highest level entered (1–4)"],
        ["10", "unlockedLevels",      "List<int>",      "Level IDs the player can enter"],
        ["11", "badges",              "List<String>",   "Legacy badge list (deprecated, kept for migration)"],
        ["12", "streak",              "int",            "Consecutive days the app was opened"],
        ["13", "lastActiveStr",       "String",         "ISO-8601 timestamp of last login"],
        ["14", "totalSavingsZMW",     "double",         "Aggregate simulated savings across all exercises"],
        ["15", "earnedBadges",        "List<String>",   "Active badge IDs (replaces field 11)"],
        ["16", "completedQuizIds",    "List<String>",   "Quiz question IDs already answered"],
        ["17", "totalQuizXP",         "int",            "XP earned specifically from the quiz feature"],
        ["18", "unlockedChapterIds",  "List<int>",      "Story chapter IDs the player can read"],
        ["19", "lastSeasonalEventId", "String?",        "ID of most recently completed seasonal event"],
    ]
)

h4("Key methods")
bullet("addXp(amount) — increments xp by amount. Does not save; caller must call user.save().")
bullet("addZamCoins(amount) — increments zamCoins. Caller must save.")
bullet("addQuizXp(amount, questionId) — increments xp and totalQuizXP; adds questionId to completedQuizIds to prevent replaying the same question.")
bullet("awardBadge(badgeId) — adds to earnedBadges if not already present, then calls save().")
bullet("unlockLevel(levelId) — adds levelId to unlockedLevels if not already there.")
bullet("hasUnlocked(levelId) — returns true if levelId is in unlockedLevels.")
bullet("completeSeasonalEvent(eventId, year, month) — records the month-scoped completion key.")

h3("lib/features/auth/providers/auth_provider.dart  —  Authentication State")
body("Manages the currently logged-in user, handles login/registration, and "
     "exposes methods for modifying the user's game state.")

h4("Class: AuthState (@immutable)")
body("An immutable snapshot of authentication state containing: the current "
     "UserProfile (or null if not logged in), an isLoading flag, an optional "
     "error message, and computed getters isAuthenticated and hasCompletedOnboarding.")

h4("Class: AuthNotifier (StateNotifier<AuthState>)")
body("The business logic class that handles all auth operations.")

h4("Method: _hashPassword(username, password)")
body("Produces a deterministic hash by combining username and password with a "
     "fixed salt, then base64-encoding the result. This is not a cryptographic "
     "hash function — it is sufficient for an offline app where no server stores "
     "the passwords, but should be replaced with bcrypt or similar if a backend "
     "is ever added.")

h4("Method: login(username, password)")
body("Looks up the username in the Hive 'users' box, hashes the provided password "
     "and compares it to the stored hash. On success, calls _updateStreak() and "
     "sets the authenticated user in state.")

h4("Method: _updateStreak(user)")
body("Compares today's date to user.lastActive. If the gap is exactly one day, "
     "the streak increments. If the gap is greater than one day and the player has "
     "no streak shields, the streak resets to 1. If a shield exists, it is consumed "
     "and the streak continues.")

h4("Method: register(name, username, password)")
body("Validates that the username is not already taken, creates a new UserProfile "
     "with the hashed password and default values, saves it to Hive, and awards "
     "the 'first_login' badge.")

h4("Method: completeOnboarding(incomeCategory, financialGoals, riskAppetite)")
body("Saves the three onboarding choices to the current user's profile, marks "
     "onboarding as complete in Hive settings (key: 'onboardingDone_<uid>'), "
     "and awards the 'onboarding_complete' badge.")

h4("Provider: currentUserProvider (Provider<UserProfile?>)")
body("A derived Riverpod provider that watches authProvider and simply returns "
     "state.currentUser. Screens that only need the user object can watch this "
     "narrower provider instead of the full AuthState, which reduces unnecessary "
     "rebuilds.")

h3("lib/features/auth/screens/splash_screen.dart")
body("Shows the ZamWealth Quest logo and tagline for approximately 2.2 seconds "
     "with a fade-in and scale-up animation. Navigation is handled entirely by "
     "GoRouter's redirect logic — this screen does not push to any route manually.")

h3("lib/features/auth/screens/login_screen.dart")
body("A form with username and password fields, a show/hide password toggle, "
     "and a link to the registration screen. Calls authProvider.notifier.login() "
     "on submit. Shows a SnackBar with the error message if login fails. "
     "GoRouter's redirect moves the user to /home automatically on success.")

h3("lib/features/auth/screens/register_screen.dart")
body("A form with name, username, password, and password-confirmation fields. "
     "Validates minimum lengths, checks that the two password fields match, and "
     "calls authProvider.notifier.register() on submit.")

h3("lib/features/onboarding/screens/onboarding_screen.dart")
body("A four-step PageView that collects: (1) income category (single choice from "
     "four options), (2) financial goals (multi-select from six options), "
     "(3) risk appetite (low/medium/high slider with descriptions), and "
     "(4) a summary confirm screen. Validation prevents advancing until at least "
     "one goal and an income category are selected. Calls completeOnboarding() "
     "on the final step.")

page_break()

# ── 4.4 Dashboard ──────────────────────────────────────────────────────────────
h2("4.4  Dashboard & Player Progress")

h3("lib/features/dashboard/providers/dashboard_provider.dart")
body("A pure computed provider — it reads the current user from authProvider "
     "and calculates all the values the Dashboard needs to render. No data is "
     "written here.")

h4("Class: DashboardState")
body("Contains: user (the full UserProfile), rankLabel, xpInCurrentRank, "
     "xpForNextRank, xpToNextRankLabel, progressPercent (0.0–1.0 within current "
     "rank tier), and isStreakActive. Short-hand getters expose name, xp, zamCoins, "
     "streak, currentLevel, badgeCount, totalSavingsZMW, and badges directly.")

h4("Rank progress calculation")
code_block(
"""final thresholdIndex = kXpThresholds.indexWhere((t) => xp < t);
final tierSize = kXpThresholds[thresholdIndex] - rankStart;
final progress = tierSize > 0 ? (xpInTier / tierSize).clamp(0.0, 1.0) : 1.0;""")
note("kXpThresholds is [0, 200, 600, 1200, 2200]. If a player has 350 XP, they "
     "are in the ZMW Builder tier (200–599). rankStart = 200, tierSize = 400, "
     "xpInTier = 150, so progress = 150/400 = 0.375 (37.5% through the tier).")

h3("lib/features/dashboard/screens/dashboard_screen.dart  —  Home Tab")
body("The most complex screen in the app. It shows the player's complete status "
     "at a glance and provides entry points to all major features.")

h4("Animations")
bullet("_xpCtrl (1000 ms, easeOutCubic) — animates the XP bar fill from 0 to current progress on screen entry. Also re-plays from 0 whenever XP increases.")
bullet("_xpGlowCtrl (1600 ms, TweenSequence) — peaks in the first 25% (400 ms bright spike) then fades over the remaining 75% (1200 ms). Triggers whenever XP increases, producing a teal outer box-shadow glow and an inner white flash on the XP bar.")
bullet("_streakCtrl (1400 ms, repeating) — pulses the streak pill between scale 1.0 and 1.10 continuously.")
bullet("SparkleOverlay — particle effect triggered simultaneously with the XP glow.")

h4("Daily challenge dialog")
body("When the dashboard loads and the daily challenge has not yet been completed "
     "today, a dialog appears automatically. The shown-state is persisted in Hive "
     "(key: 'dc_dialog_shown_<uid>' = today's date string) so the dialog only "
     "appears once per day even if the user navigates away and returns.")

h4("Budget card")
body("Reads the saved allocation from Hive (key: 'budget_alloc_<uid>') and the "
     "saved income from Hive (key: 'budget_income_<uid>'). If no allocation exists, "
     "it shows a prompt to complete the Budget Allocator simulation. When expanded, "
     "it shows each category's percentage and ZMW amount as a coloured progress bar.")

h4("XP bar visual design")
body("The bar uses a custom CustomPainter (_XpBarPainter) that draws three layers:")
numbered("A white 10%-opacity rounded rectangle as the track background.")
numbered("A linear gradient fill (primary blue → neon mint) covering the progress fraction.")
numbered("A white overlay (55% opacity) during the glow animation for the in-bar flash.")
body("The outer Container (not the painter) provides the animated teal box-shadow "
     "glow, since the glow extends beyond the bar's boundaries and cannot be clipped.")

page_break()

# ── 4.5 Level System ──────────────────────────────────────────────────────────
h2("4.5  Level System")

h3("lib/features/levels/models/level_model.dart")
body("Tracks one player's progress in one level. The Hive key is the composite "
     "string '<uid>_<levelId>' (e.g. 'alice_2'), allowing multiple users on the "
     "same device with independent progress.")

h4("Level status state machine")
body("The status field follows a strict one-way progression:")
code_block(
"""LOCKED  →  UNLOCKED  →  IN_PROGRESS  →  COMPLETED
  (pays)      (enters)    (completes        (all sims
              level)       first sim)        done)""")

h3("lib/features/levels/providers/level_provider.dart")
body("Manages all four LevelModel instances for the current user and drives the "
     "state machine transitions.")

h4("Class: LevelNotifier")
h4("Method: _seedLevels(user)")
body("Creates LevelModel entries in Hive for any level that does not already have "
     "a record. Level 1 always starts as UNLOCKED. Levels 2–4 start as LOCKED "
     "unless they appear in user.unlockedLevels. Also fixes inconsistencies where "
     "Hive says LOCKED but the user model already has the level unlocked (can occur "
     "after a reset or migration).")

h4("Method: unlockLevel(levelId)")
body("Transitions a level from LOCKED to UNLOCKED. Awards 50 ZamCoins bonus "
     "(kPaymentBonusZamCoins), adds the level to user.unlockedLevels, saves both "
     "the LevelModel and UserProfile to Hive, and calls badgeService.checkAndAward().")

h4("Method: markSimulationComplete(levelId, simId)")
body("Records a completed simulation and advances the state machine:")
numbered("Adds simId to the level's completedSimulations list.")
numbered("If this is the first simulation, transitions UNLOCKED → IN_PROGRESS.")
numbered("If all simulations for this level are now complete, transitions IN_PROGRESS → COMPLETED and awards the level's XP reward to the user.")
numbered("Saves to Hive and checks for badge awards.")

h3("lib/features/levels/screens/level_map_screen.dart")
body("The Levels tab. Renders a vertical scrollable list of four level cards "
     "connected by dashed lines. Each card shows the level emoji, name, subtitle, "
     "status badge (LOCKED / IN PROGRESS / COMPLETED), and a preview of the "
     "businesses in that level. Tapping a locked level navigates to the payment "
     "screen; tapping an accessible level navigates to the level detail screen.")

h3("lib/features/levels/screens/level_screen.dart")
body("The level detail screen. Shows a decorative landscape header illustration, "
     "a segmented progress indicator (one circle per simulation, filled when done), "
     "and a list of simulation cards with staggered entrance animations. "
     "Tapping a simulation card opens the corresponding simulation widget as a "
     "bottom sheet. When the simulation calls its onComplete callback, "
     "markSimulationComplete() is called.")

page_break()

# ── 4.6 Payment System ─────────────────────────────────────────────────────────
h2("4.6  Payment System")

h3("lib/features/payments/models/payment_record.dart")
body("An immutable audit log entry for each simulated payment. Fields: paymentId "
     "(UUID), uid, tier (level name string), amountZMW, provider (MTN MoMo or "
     "Airtel Money), timestampStr, and sandboxMode (always true — this is a "
     "simulation). Records are never deleted; they form a complete payment history "
     "viewable on the Profile screen.")

h3("lib/features/payments/providers/payment_provider.dart")
body("Handles the simulated payment flow. When initiatePayment() is called, the "
     "state moves to 'processing' and a 2-second timer simulates network latency. "
     "After the timer, a UUID is generated, a PaymentRecord is written to Hive, "
     "levelProvider.unlockLevel() is called, and the state moves to 'success'. "
     "The payment screen observes this state and shows a success dialog.")

h3("lib/features/payments/screens/payment_screen.dart")
body("Shows the level details, price, and a choice of mobile money provider "
     "(MTN MoMo or Airtel Money) along with a prominent 'SIMULATED PAYMENT' "
     "banner. Tapping confirm triggers the payment flow. The screen watches "
     "paymentProvider and reacts to phase changes.")

page_break()

# ── 4.7 Daily Challenge ────────────────────────────────────────────────────────
h2("4.7  Daily Challenge System")

h3("lib/features/daily_challenge/models/challenge.dart")
body("Contains the DailyChallenge data class and the kDailyChallenges constant "
     "list of 30 questions. Questions are typed as multipleChoice, trueFalse, or "
     "numeric. Numeric questions include a correctNumeric answer and a "
     "numericTolerance margin (e.g. ±10 ZMW).")

h4("Sample questions")
bullet("Rent budget: If your income is ZMW 3,500 and you spend 30% on rent, how much is that? (Answer: ZMW 1,050)")
bullet("MTN MoMo fees: You send ZMW 500 every week for a year at ZMW 8 per transfer. Total fees? (Answer: ZMW 416)")
bullet("NAPSA: Your gross salary is ZMW 6,000. NAPSA is 5% of gross. How much do you contribute monthly? (Answer: ZMW 300)")
bullet("ZRA VAT: True or False — the VAT rate in Zambia is 16%. (Answer: True)")

h3("lib/features/daily_challenge/models/daily_challenge_record.dart")
body("The player's streak and history record. Fields: lastCompletedDateStr, "
     "currentStreak, totalCompleted, streakShields (max 3), bonusXpEarned, and uid. "
     "The completedToday getter returns true if lastCompletedDateStr matches today's "
     "date string, preventing double-awards on the same day.")

h3("lib/features/daily_challenge/providers/daily_challenge_provider.dart")

h4("Method: _computeTodaysChallenge()")
body("Uses a date-seeded Random to deterministically select one question from "
     "kDailyChallenges. The seed is calculated as year * 1000 + dayOfYear, so "
     "every user sees the same question on a given day:")
code_block(
"""final seed = now.year * 1000 + now.difference(DateTime(now.year, 1, 1)).inDays;
final rng   = Random(seed);
return kDailyChallenges[rng.nextInt(kDailyChallenges.length)];""")

h4("Method: submitAnswer(answer)")
body("Validates the answer, awards kDailyChallengeXp (25 XP) on a correct response, "
     "updates the streak, and checks whether the player has earned a new Streak Shield "
     "(every 3 consecutive correct days). The answer validation differs by type: "
     "multipleChoice and trueFalse compare the selected index to correctIndex; "
     "numeric checks whether (answer - correctNumeric).abs() <= numericTolerance.")

h3("lib/features/daily_challenge/screens/daily_challenge_screen.dart")
body("Renders the day's question with the appropriate input widget. After submission, "
     "reveals the explanation and shows streak feedback (current streak, shields "
     "earned/remaining, XP awarded).")

page_break()

# ── 4.8 Badges ────────────────────────────────────────────────────────────────
h2("4.8  Badges & Achievements")

h3("lib/features/badges/models/badge_model.dart")
body("Defines the AppBadge data class and the kAllBadges catalogue of 21 badges. "
     "Each badge has a stable id string (never changes — persisted in Hive), "
     "a title, description, emoji, BadgeTier (bronze/silver/gold/platinum), "
     "and an unlockedBy description.")

add_table(
    ["Badge ID",           "Emoji", "Tier",    "Unlock Condition"],
    [
        ["first_login",         "👣",  "bronze",   "Created an account"],
        ["onboarding_complete", "🎓",  "bronze",   "Finished onboarding"],
        ["budget_done",         "📊",  "silver",   "Completed Budget Allocator"],
        ["savings_emergency",   "☂️",  "silver",   "Completed Emergency Fund sim"],
        ["savings_all_modes",   "🏆",  "gold",     "Completed all 3 savings simulations"],
        ["debt_done",           "⚔️",  "silver",   "Completed Debt Manager sim"],
        ["investment_lusaka_se","📈",  "gold",     "Completed Investment Risk sim"],
        ["investment_all_modes","💼",  "gold",     "Completed all 3 investment sims"],
        ["pacra_done",          "📋",  "silver",   "Completed PACRA registration sim"],
        ["tax_wizard",          "🧙",  "gold",     "Scored 100% on Tax Quiz"],
        ["payroll_done",        "💰",  "silver",   "Completed Payroll sim"],
        ["business_all_modes",  "🦁",  "platinum", "Completed all 4 business sims"],
        ["level_1_done",        "🌱",  "bronze",   "Completed all Level 1 simulations"],
        ["level_2_done",        "🌳",  "silver",   "Completed all Level 2 simulations"],
        ["level_3_done",        "🏙️", "gold",     "Completed all Level 3 simulations"],
        ["level_4_done",        "💎",  "platinum", "Completed all Level 4 simulations"],
        ["xp_500",              "🪙",  "bronze",   "Reached 500 total XP"],
        ["xp_2000",             "💵",  "silver",   "Reached 2,000 total XP"],
        ["xp_5000",             "⭐",  "gold",     "Reached 5,000 total XP"],
        ["streak_3",            "🔥",  "bronze",   "3-day daily challenge streak"],
        ["streak_7",            "🗓️", "silver",   "7-day daily challenge streak"],
        ["streak_30",           "👑",  "platinum", "30-day daily challenge streak"],
    ]
)

h3("lib/features/badges/providers/badge_provider.dart")
body("BadgeService.checkAndAward() is called after any event that could unlock a badge. "
     "It checks every award condition (simulation completion, XP thresholds, streak "
     "milestones) and calls _award() for each newly-earned badge. _award() adds the "
     "badge id to user.earnedBadges, calls refreshUser(), and displays a BadgeUnlockToast.")

h3("lib/features/badges/widgets/badge_unlock_toast.dart")
body("A celebratory overlay shown in the corner of the screen when a badge is "
     "earned. Displays the badge emoji, title, and tier with a brief animation. "
     "The static show(context, badge) method handles display.")

page_break()

# ── 4.9 Quiz ───────────────────────────────────────────────────────────────────
h2("4.9  Quiz System")

h3("lib/features/quiz/providers/quiz_provider.dart")
body("Manages a 5-question quiz session drawn randomly from the 60-question bank.")

h4("Class: QuizSession (@immutable)")
body("State snapshot containing: the shuffled 5-question list, currentIndex (0–4), "
     "selectedAnswer (-1 if not yet answered), revealed (whether to show the "
     "explanation), sessionXP and sessionCoins (cumulative totals for the session), "
     "and correctCount. The isDone getter returns true when currentIndex == 5.")

h4("Method: selectAnswer(index)")
body("Called when the player taps an answer option. If the answer is correct:")
numbered("sessionXP increases by the question's xpReward (default 30).")
numbered("sessionCoins increases by kQuizCoinsCorrect (10).")
numbered("user.addQuizXp() records XP and the question ID.")
numbered("user.addZamCoins() credits the coins.")
numbered("authProvider.refreshUser() re-reads the user from Hive so the Dashboard updates instantly.")
body("The revealed flag is set to true regardless of correctness, causing the "
     "explanation and next-button to appear.")

h3("lib/features/quiz/screens/quiz_screen.dart")
body("A full-screen quiz interface. Shows the category badge, question card, "
     "and four answer buttons. After the player selects an answer, the correct "
     "option turns green, the wrong option (if selected) turns red, and the "
     "explanation appears. The results screen shows two reward tiles side by side: "
     "a teal XP tile (e.g. '+90 XP') and a gold coins tile (e.g. '+30 COINS').")

page_break()

# ── 4.10 Profile & Dev Tools ────────────────────────────────────────────────────
h2("4.10  Profile & Developer Tools")

h3("lib/features/profile/providers/profile_provider.dart")
body("paymentHistoryProvider filters and sorts the Hive 'payments' box by the "
     "current user's uid, returning a newest-first list of PaymentRecords. "
     "DevTapNotifier tracks taps on the version label; at 7 taps it navigates to "
     "the developer console.")

h3("lib/features/profile/screens/profile_screen.dart")
body("The Profile tab. Shows the player's display name, total XP and rank, "
     "ZamCoins balance, earned badges gallery, payment history list, and the "
     "app version label. The version label is the entry point to the developer "
     "console easter egg.")

h3("lib/features/profile/screens/dev_screen.dart  —  Developer Console")
body("Accessed by tapping the version label 7 times (kDevScreenTapCount). "
     "Styled as a green-on-black terminal. Provides:")
bullet("Sandbox mode toggle — changes the payment UI label")
bullet("App info panel — current user, XP, unlocked levels, sandbox status")
bullet("Force unlock buttons — unlock levels 2, 3, or 4 without payment (testing only)")
bullet("Reset all progress — clears all user data and reinitialises from scratch")
bullet("Hive box viewer — dropdown to inspect raw contents of any Hive box as JSON")
bullet("Raw XP adder — text field to add arbitrary XP to the current user immediately")

page_break()

# ── 4.11 Story & Seasonal ───────────────────────────────────────────────────────
h2("4.11  Story & Seasonal Events")

h3("lib/features/story/models/story_chapter_progress.dart")
body("Hive model (typeId 12) for one chapter's unlock and choice state. "
     "Key: '<uid>_<chapterId>'. Fields: uid, chapterId, isUnlocked, playerChoice "
     "(0=no choice, 1=Choice A, 2=Choice B), dateUnlockedStr.")

h3("lib/features/story/providers/story_provider.dart")
body("StoryNotifier.unlockChapter() checks whether the player can afford the "
     "chapter (XP gate and ZamCoin cost), deducts the cost, adds the chapter to "
     "user.unlockedChapterIds, writes a StoryChapterProgress record to Hive, and "
     "refreshes the user. recordChoice() persists the player's narrative decision.")

h3("lib/features/story/screens/story_chapter_screen.dart")
body("Renders chapter narrative text with a custom-painted illustration behind it. "
     "At the end of the chapter, two choice buttons appear. The selected choice is "
     "recorded via storyProvider.recordChoice() and may influence which chapter is "
     "recommended next.")

h3("lib/features/seasonal/providers/seasonal_event_provider.dart")
body("Finds the active event by matching the current calendar month to the events "
     "in kSeasonalEvents (e.g., Christmas in December, School Fees in January). "
     "completeEvent() awards the event's XP and ZamCoin bonuses and marks the event "
     "as done for the current month using user.completeSeasonalEvent().")

page_break()

# ── 4.12 Simulations ───────────────────────────────────────────────────────────
h2("4.12  Simulations")
body("Each simulation is a self-contained Flutter widget mounted as a "
     "DraggableScrollableSheet bottom sheet from the level_screen. They receive an "
     "onComplete callback and call it when the player submits their work. The level "
     "screen then calls markSimulationComplete() to record progress.")

h3("lib/features/levels/simulations/budget_simulation.dart  —  Level 1")
body("The Budget Allocator teaches the 50/30/20 budgeting rule. The player slides "
     "a range selector to choose their monthly income (0–20,000 ZMW, in steps of "
     "500), then drags five sliders to allocate that income across Rent, Food, "
     "Transport, Savings, and Leisure. Five guards protect the player:")
bullet("Savings warning banner — appears when savings allocation drops below 10%")
bullet("Over-budget banner — appears when total allocation exceeds 100%")
bullet("Submit button disabled — when over budget")
bullet("Dynamic 50/30/20 tip card — recalculates example amounts from the chosen income")
bullet("Remaining / unallocated card — shows how much income is still unassigned")
body("On submit, the allocation percentages and the chosen income are saved to "
     "Hive (keys: 'budget_alloc_<uid>' and 'budget_income_<uid>') so the Dashboard's "
     "budget card can display a summary.")

h3("lib/features/levels/simulations/savings_simulation.dart  —  Level 2")
body("Teaches savings goal planning. The player selects a savings goal "
     "(emergency fund, school fees, house deposit, or wedding), sets a target "
     "amount and monthly contribution, and sees a projected timeline with compound "
     "interest applied.")

h3("lib/features/levels/simulations/debt_simulation.dart  —  Level 2")
body("Demonstrates the debt avalanche repayment strategy. The player enters one "
     "or more debts with interest rates and balances. The simulation shows the "
     "difference in total interest paid between making minimum payments versus "
     "aggressively targeting the highest-interest debt first.")

h3("lib/features/levels/simulations/investment_simulation.dart  —  Level 3")
body("Three investment modes in one widget:")
bullet("Risk & Reward — Choose an asset class (ZSE Stocks, Property, Agro Ventures), set investment amount and timeline, see projected min/max returns based on that asset's rate range.")
bullet("Compound Growth Chart — Visualises ZMW 1,000 growing at 8%, 15%, and 22% annual returns over 10 years using fl_chart's LineChart.")
bullet("Portfolio Allocator — Distribute an investment across four asset classes using sliders; the simulation calculates the blended annual return rate.")

h3("lib/features/levels/simulations/business_simulation.dart  —  Level 4")
body("Four business modes in one widget:")
bullet("PACRA Registration — Step-through of the 6 official steps to register a business in Zambia (business structure choice, name reservation, document preparation, PACRA submission, ZRA TPIN, bank account). Shows real fee amounts and processing times.")
bullet("Revenue vs. Profit — Sliders for Revenue, Cost of Goods Sold (COGS), and Operating Expenses. Auto-calculates Gross Profit, Earnings Before Tax, corporate tax (35%), and Net Profit.")
bullet("Payroll Simulator — Enter gross salary and employee count. Auto-deducts NAPSA (5% employee + 5% employer, capped at ZMW 1,221.80/month) and PAYE to show net take-home pay per employee and total payroll cost.")
bullet("Tax Quiz — Multiple-choice questions on ZRA tax concepts. A perfect score unlocks the 'tax_wizard' badge.")

h3("lib/features/levels/simulations/quiz_challenge_simulation.dart  —  Level 1")
body("A mini-quiz embedded within Level 1 using Zambia-specific financial questions "
     "(NAPSA, VAT, mobile money, etc.). Different from the standalone quiz feature — "
     "this is a simulation card within the level, not the full 60-question quiz bank.")

page_break()

# ── 4.13 Shared Widgets ────────────────────────────────────────────────────────
h2("4.13  Shared Widgets")

h3("lib/shared/widgets/animated_gradient_background.dart")
body("Wraps any widget in a slowly breathing gradient that cycles between two dark "
     "navy states over 5 seconds, reversing infinitely. A dot-grid CustomPainter "
     "sits above the gradient at 3% opacity to add subtle texture. Used on every "
     "screen in the app.")

h3("lib/shared/widgets/xp_bar.dart")
body("A reusable animated progress bar widget. Accepts progress (0.0–1.0), optional "
     "current/max XP labels, and a configurable animation duration (default 700 ms). "
     "Re-animates from its current position to the new value whenever progress "
     "changes (handled in didUpdateWidget).")

h3("lib/shared/widgets/sparkle_overlay.dart")
body("Renders tiny animated sparkle particles that burst and fade when trigger() is "
     "called. Used on the Dashboard when XP increases.")

h3("lib/shared/widgets/offline_banner.dart")
body("Reads the device connectivity state via connectivity_plus. Renders a red "
     "warning strip at the top of the screen when offline. Hidden when connected.")

h3("lib/shared/widgets/sim_card.dart")
body("The card widget used in level_screen.dart for each simulation entry. "
     "Shows the simulation's emoji, title, description, XP reward, and a completion "
     "tick or 'Start' button.")

page_break()

# ── 4.14 Custom Painters ──────────────────────────────────────────────────────
h2("4.14  Custom Painters (Canvas)")
body("All illustrations in the app are drawn at runtime using Flutter's Canvas API "
     "via CustomPainter classes. This avoids bundling PNG/SVG assets, keeps the APK "
     "smaller, and allows the illustrations to be tinted or animated in code.")

add_table(
    ["Painter File",                 "What It Draws"],
    [
        ["baobab_painter.dart",         "Stylised African baobab tree (trunk trapezoid + oval canopy)"],
        ["dot_grid_painter.dart",       "Subtle 26px-spaced dot grid texture overlay (0.03 opacity)"],
        ["flame_painter.dart",          "Animated or static flame for streak indicators"],
        ["kente_pattern_painter.dart",  "Kente cloth geometric pattern for cultural decoration"],
        ["kwacha_icon_painter.dart",    "Zambian Kwacha (K) currency symbol"],
        ["landscape_painter.dart",      "Level environment header illustration (varies per level)"],
        ["segmented_progress_painter.dart","Row of N circles, filled for each completed simulation"],
        ["shop_front_painter.dart",     "Simple storefront for business-level aesthetics"],
        ["story/building_painter.dart", "Tall building at night with lit/dark windows and stars"],
        ["story/certificate_painter.dart","Achievement certificate illustration"],
        ["story/coins_painter.dart",    "Stack of ZamCoin or Kwacha coins"],
        ["story/market_stall_painter.dart","Outdoor market stall scene"],
        ["story/supplier_painter.dart", "Warehouse / supplier building"],
    ]
)

# ── 4.15 Supplementary Screens ─────────────────────────────────────────────────
h2("4.15  Supplementary Screens")

h3("lib/features/stats/screens/stats_screen.dart")
body("A statistics dashboard accessed from the Profile tab. Displays: total XP, "
     "ZamCoins, badge count; XP earned per level (bar chart); simulations completed "
     "vs total (progress bar); daily challenge stats (streak, shields, total done, "
     "bonus XP); and total simulated savings in ZMW.")

h3("lib/features/leaderboard/screens/leaderboard_screen.dart")
body("Shows the player's XP rank against nine fictional competitors seeded on first "
     "launch. The current player's row is highlighted. The top three players appear "
     "on a podium with animated medal display. A disclaimer confirms the leaderboard "
     "is local-only and the competitors are placeholders.")

h3("lib/features/badges/screens/badges_screen.dart")
body("Gallery of all 21 badges. Earned badges show full colour with title and "
     "unlock condition. Locked badges are greyed out. Badges are grouped by tier "
     "(bronze, silver, gold, platinum) with tier-colour headings.")

h3("lib/features/story/screens/story_map_screen.dart")
body("Chapter selection screen for 'Kwacha Chronicles'. Shows available chapters "
     "with unlock cost (XP gate and ZamCoin cost). Completed chapters show the "
     "player's recorded narrative choice.")

h3("lib/features/seasonal/screens/seasonal_event_screen.dart")
body("Shows the active monthly event (matched by current calendar month). Displays "
     "the event title, description, and bonus rewards. A 'Complete Event' button "
     "triggers the completeEvent() call.")

# ── 4.16 Generated Adapters ────────────────────────────────────────────────────
h2("4.16  Generated Hive Adapters")
body("The following files are automatically generated by hive_generator when you run "
     "dart run build_runner build. Do not edit them manually — any changes will be "
     "overwritten the next time the generator runs.")
bullet("lib/features/auth/models/user_profile.g.dart — typeId 0")
bullet("lib/features/levels/models/level_model.g.dart — typeId 1")
bullet("lib/features/payments/models/payment_record.g.dart — typeId 2")
bullet("lib/features/daily_challenge/models/daily_challenge_record.g.dart — typeId 3")
bullet("lib/features/story/models/story_chapter_progress.g.dart — typeId 12")
note("TypeId 12 (not 4 or 5) is used for StoryChapterProgress because lower IDs "
     "are reserved for future models. TypeIds must be unique across the entire app "
     "and must never change once data has been stored, or Hive will fail to read "
     "existing records.")

page_break()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — DATA FLOW
# ══════════════════════════════════════════════════════════════════════════════

h1("5. Data Flow")
body("This section explains how data moves through the app, from user action to "
     "storage and back to the screen.")

h2("End-to-end flow: Completing a simulation")

flow_table = [
    ["1", "User action",      "Player taps 'Submit Budget' in Budget Allocator"],
    ["2", "Simulation widget","Calls onComplete() callback passed in from level_screen"],
    ["3", "level_screen",     "Calls ref.read(levelProvider.notifier).markSimulationComplete(levelId, simId)"],
    ["4", "LevelNotifier",    "Updates LevelModel.completedSimulations in memory"],
    ["5", "LevelNotifier",    "If all sims complete: transitions status to COMPLETED, calls user.addXp(kLevel1XpReward)"],
    ["6", "LevelNotifier",    "Calls Hive.box(kLevelBox).put(key, levelModel) to persist"],
    ["7", "LevelNotifier",    "Calls user.save() to persist UserProfile"],
    ["8", "LevelNotifier",    "Calls badgeService.checkAndAward() which checks all badge conditions"],
    ["9", "BadgeService",     "If badge earned: calls user.awardBadge(), shows BadgeUnlockToast"],
    ["10","authProvider",     "refreshUser() re-reads UserProfile from Hive into state"],
    ["11","Riverpod",         "All widgets watching currentUserProvider, dashboardProvider, levelProvider rebuild"],
    ["12","Dashboard",        "XP bar and rank label update; glow animation triggers; SparkleOverlay fires"],
]
add_table(["Step", "Layer", "Action"], flow_table)

h2("Storage architecture")
code_block(
"""USER INPUT
    │
    ▼
RIVERPOD NOTIFIER (in-memory state)
    │  ← reads/writes
    ▼
HIVE (local device storage)
    │
    ├── users/         UserProfile objects (progress, XP, badges)
    ├── levels/        LevelModel objects (sim completion, status)
    ├── payments/      PaymentRecord audit log
    ├── session/       currentUid (login session)
    ├── leaderboard/   Seeded fictional player entries
    ├── settings/      Budget allocations, dialog shown flags
    ├── daily_challenge/ DailyChallengeRecord streak data
    └── story/         StoryChapterProgress objects

NO CLOUD / NO NETWORK (except Google Fonts on first load)""")

h2("How screens receive data")
body("Screens use ref.watch() to subscribe to Riverpod providers. When a notifier "
     "calls state = newState, Riverpod automatically rebuilds every widget that "
     "watches that provider. Screens never read Hive directly — they always go "
     "through a provider.")
code_block(
"""Screen (Widget)
    │  ref.watch(dashboardProvider)
    ▼
dashboardProvider (computed Provider)
    │  ref.watch(currentUserProvider)
    ▼
currentUserProvider (derived from authProvider)
    │  ref.watch(authProvider)
    ▼
AuthState (StateNotifier state)
    │  user = Hive.box(kUserBox).get(uid)
    ▼
Hive 'users' box""")

page_break()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — GAMIFICATION LOGIC
# ══════════════════════════════════════════════════════════════════════════════

h1("6. Gamification Logic")

h2("XP system")
body("Every positive action earns XP. XP accumulates on the UserProfile.xp field "
     "and cannot decrease. When XP crosses a threshold defined in kXpThresholds, "
     "the player's rank label changes. The dashboard XP bar shows progress within "
     "the current rank tier (not total XP).")
add_table(
    ["Action",                       "XP Awarded",  "Where Defined"],
    [
        ["Correct quiz answer",        "30 XP",       "kQuizXpCorrect in constants.dart"],
        ["Correct daily challenge",    "25 XP",       "kDailyChallengeXp"],
        ["Complete Level 1",           "200 XP",      "kLevel1XpReward"],
        ["Complete Level 2",           "400 XP",      "kLevel2XpReward"],
        ["Complete Level 3",           "600 XP",      "kLevel3XpReward"],
        ["Complete Level 4",           "1,000 XP",    "kLevel4XpReward"],
        ["Seasonal event completion",  "event.xpBonus","SeasonalEvent object"],
    ]
)

h2("ZamCoin economy")
body("ZamCoins are the secondary currency. They are awarded for correct quiz answers "
     "(10 coins each) and level payment bonuses (50 coins per unlock). They are spent "
     "to unlock story chapters. The balance lives on UserProfile.zamCoins and is "
     "displayed in the Dashboard HUD bar.")

h2("Level state machine")
body("Each level goes through four states (see section 4.5 for the diagram). The "
     "state is stored in LevelModel.status and transitions are driven by "
     "LevelNotifier in level_provider.dart. The state machine is one-directional — "
     "a level can never go back from COMPLETED to IN_PROGRESS.")

h2("Streak and Streak Shields")
body("The streak counter on UserProfile.streak increments when the player logs in "
     "on consecutive calendar days. The AuthNotifier._updateStreak() method manages "
     "this. If the player misses a day but has a Streak Shield "
     "(DailyChallengeRecord.streakShields > 0), one shield is consumed and the streak "
     "continues. Players earn a new shield every 3 consecutive daily challenge "
     "completions (kStreakShieldInterval), up to a maximum of 3 shields "
     "(kMaxStreakShields).")

h2("Daily challenge seeding")
body("The daily challenge question is chosen deterministically from the 30-question "
     "bank using a date-based seed. This ensures every user on the same device sees "
     "the same question on a given day, making the feature feel coordinated even in "
     "an offline, single-player app. See section 4.7 for the code.")

h2("Badge award logic")
body("BadgeService.checkAndAward() is called after any state-changing event. It "
     "iterates through all 21 badge conditions and awards any that are met and "
     "not already earned. Because it checks all conditions each time, it is safe "
     "to call it redundantly — duplicate awards are prevented by the hasBadge() "
     "check inside awardBadge().")

h2("Simulation completion detection")
body("Each level has a fixed set of simulation IDs defined in its LevelMeta.simulations "
     "list (from constants.dart). LevelNotifier.markSimulationComplete() compares "
     "the updated completedSimulations list against this reference list to determine "
     "whether the level is fully done:")
code_block(
"""final allDone = meta.simulations.every(
  (simId) => updatedModel.completedSimulations.contains(simId),
);
if (allDone) {
  updatedModel.status = kStatusCompleted;
  user.addXp(meta.xpReward);
}""")

page_break()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 7 — KNOWN LIMITATIONS & TODOs
# ══════════════════════════════════════════════════════════════════════════════

h1("7. Known Limitations & TODOs")

h2("No explicit TODO or FIXME comments found")
body("A scan of all Dart files found no TODO, FIXME, HACK, or // temp comments. "
     "The codebase is clean for its v1.0.0 release. The limitations below are "
     "architectural decisions rather than outstanding bugs.")

h2("Known limitations")

h3("1. Password hashing is not cryptographically strong")
body("The _hashPassword() function in auth_provider.dart uses a deterministic "
     "base64 encoding with a fixed salt. This is acceptable for an offline app "
     "where passwords never leave the device, but must be replaced with bcrypt "
     "or Argon2 before any backend or sync feature is added.")

h3("2. Leaderboard is local and fictional")
body("The leaderboard shows only one real player (the current user) alongside nine "
     "fictional Zambian names seeded at install time. There is no multiplayer, "
     "no server, and no real competition. The disclaimer text in the leaderboard "
     "screen acknowledges this.")

h3("3. Quiz question IDs are de-duplicated but not rotated")
body("Once a player has answered a quiz question correctly (tracked in "
     "UserProfile.completedQuizIds), it is never offered again in the quiz flow "
     "at the current quiz provider level. With 60 questions and 5 per session, "
     "a dedicated player will exhaust the novel questions after 12 sessions. "
     "Adding new questions to kQuizQuestions in constants.dart is the intended "
     "expansion path.")

h3("4. No cloud sync or multi-device support")
body("All data lives in local Hive boxes. Uninstalling the app deletes all "
     "progress. There is no backup, export, or restore feature.")

h3("5. Simulated payments only")
body("The payment flow never contacts a real mobile money API. The 'SIMULATED "
     "PAYMENT' banner makes this clear in the UI, but it means the app cannot "
     "generate real revenue from in-app purchases without a backend integration.")

h3("6. Story chapters are partially scaffolded")
body("The story feature (Kwacha Chronicles) has the full provider, model, and "
     "navigation infrastructure in place, but the chapter content (kStoryChapters "
     "constant) and the number of available chapters depend on constants that "
     "were not fully enumerated in the version reviewed.")

h3("7. No analytics or crash reporting")
body("There is no Firebase Analytics, Sentry, or similar tool. Bugs in production "
     "must be reproduced manually or reported by users.")

h2("Suggested next steps")
bullet("Integrate Firebase Auth + Firestore for cloud save, real leaderboards, and multi-device sync")
bullet("Replace _hashPassword() with a proper bcrypt implementation (use the 'bcrypt' Dart package)")
bullet("Add 20+ more quiz questions to the kQuizQuestions bank for long-term engagement")
bullet("Integrate MTN MoMo API or Airtel Money API for real payment processing")
bullet("Add Firebase Crashlytics for production error tracking")
bullet("Expand the story to at least 10 chapters with meaningful branching consequences")
bullet("Add push notifications for daily challenge reminders (using firebase_messaging)")

# ══════════════════════════════════════════════════════════════════════════════
# Save the document
# ══════════════════════════════════════════════════════════════════════════════

output_path = r"c:\Users\sangu\Documents\Claude\Projects\Flutter final\ZamWealthQuest_Codebase_Documentation.docx"
doc.save(output_path)
print(f"✅  Saved: {output_path}")
