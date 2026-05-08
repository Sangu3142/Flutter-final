/// theme.dart
/// Purpose: ZamWealth Quest design system — dark sci-fi financial palette,
///          Orbitron / Rajdhani / Inter typography, card helpers, and the
///          single MaterialTheme used by MaterialApp.router.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Core 8-Colour Palette
// ─────────────────────────────────────────────────────────────────────────────

/// Deepest background — used by the gradient top stop.
const Color kCoreNavy      = Color(0xFF00203F);

/// Card / surface background.
const Color kDeepNavy      = Color(0xFF0D1B2A);

/// Primary accent — neon teal. Actions, selected states, highlights.
const Color kNeonMint      = Color(0xFF36ECDE);

/// Secondary accent — electric blue. Sparkle particles, links, info.
const Color kPrimaryBlue   = Color(0xFF1A73E8);

/// XP, ZamCoins, streak, and reward indicators.
const Color kGold          = Color(0xFFFFB703);

/// Success / completed state.
const Color kGreen         = Color(0xFF2BC48A);

/// Primary text on dark backgrounds — near-white.
const Color kCharcoal      = Color(0xFFE2E8F0);

/// Secondary / muted text on dark backgrounds.
const Color kCharcoalLight = Color(0xFF94A3B8);

// ─────────────────────────────────────────────────────────────────────────────
// Semantic Aliases  (keep file-level references in other widgets compiling)
// ─────────────────────────────────────────────────────────────────────────────

/// Alias: copper accent → neon mint in the dark palette.
const Color kCopper        = kNeonMint;

/// Alias: lighter copper → neon mint (used for borders / chips).
const Color kCopperLight   = kNeonMint;

/// Alias: cream surface → deep navy (used as card fill in light-era widgets).
const Color kCream         = kDeepNavy;

/// Alias: copper surface → core navy.
const Color kCopperSurface = kCoreNavy;

/// Warning / caution — amber orange.
const Color kWarning       = Color(0xFFFB8500);

/// Error / wrong-answer red.
const Color kError         = Color(0xFFEF5350);

/// Lighter success shade.
const Color kGreenLight    = Color(0xFF52D9A4);

/// Locked-state grey.
const Color kLocked        = Color(0xFF475569);

/// Alias kept for router / bottom-nav usage.
const Color kPrimary       = kNeonMint;

/// Alias: background surface.
const Color kBackground    = kCoreNavy;

/// Alias: surface.
const Color kSurface       = kDeepNavy;

// ─────────────────────────────────────────────────────────────────────────────
// Typography Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Orbitron — stat numbers, hero display text, XP values.
TextStyle _orbitron({
  double size = 14,
  FontWeight weight = FontWeight.w700,
  Color color = kCharcoal,
  double? height,
  double? letterSpacing,
}) =>
    GoogleFonts.orbitron(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );

/// Rajdhani — all headings, titles, button labels, nav labels.
TextStyle _rajdhani({
  double size = 14,
  FontWeight weight = FontWeight.w600,
  Color color = kCharcoal,
  double? height,
  double? letterSpacing,
}) =>
    GoogleFonts.rajdhani(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );

/// Inter — body copy, descriptions, form fields, captions.
TextStyle _inter({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color color = kCharcoal,
  double? height,
}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Text Theme
// ─────────────────────────────────────────────────────────────────────────────

final TextTheme _textTheme = TextTheme(
  // Display — Orbitron for large numeric/hero moments
  displayLarge:  _orbitron(size: 32, weight: FontWeight.w800),
  displayMedium: _orbitron(size: 28, weight: FontWeight.w800),
  displaySmall:  _orbitron(size: 24, weight: FontWeight.w700),

  // Headlines — Rajdhani
  headlineLarge:  _rajdhani(size: 22, weight: FontWeight.w700, letterSpacing: 0.5),
  headlineMedium: _rajdhani(size: 20, weight: FontWeight.w600, letterSpacing: 0.4),
  headlineSmall:  _rajdhani(size: 18, weight: FontWeight.w600, letterSpacing: 0.3),

  // Titles — Rajdhani
  titleLarge:  _rajdhani(size: 16, weight: FontWeight.w600),
  titleMedium: _rajdhani(size: 14, weight: FontWeight.w600),
  titleSmall:  _rajdhani(size: 12, weight: FontWeight.w600),

  // Body — Inter
  bodyLarge:  _inter(size: 16, weight: FontWeight.w400, height: 1.55),
  bodyMedium: _inter(size: 14, weight: FontWeight.w400, height: 1.55),
  bodySmall:  _inter(size: 12, weight: FontWeight.w400, color: kCharcoalLight, height: 1.55),

  // Label — Rajdhani
  labelLarge:  _rajdhani(size: 14, weight: FontWeight.w500),
  labelMedium: _rajdhani(size: 12, weight: FontWeight.w500),
  labelSmall:  _rajdhani(size: 10, weight: FontWeight.w500, color: kCharcoalLight),
);

// ─────────────────────────────────────────────────────────────────────────────
// Glassmorphism Card Helper
// ─────────────────────────────────────────────────────────────────────────────

/// Returns a dark-glass [BoxDecoration] for use inside a [ClipRRect] with
/// the given [radius]. Pair with [GlassCard] for a ready-made widget.
BoxDecoration zamCard({
  bool highlighted = false,
  double radius = 16,
}) =>
    BoxDecoration(
      color: kDeepNavy.withValues(alpha: 0.60),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: highlighted
            ? kNeonMint.withValues(alpha: 0.50)
            : Colors.white.withValues(alpha: 0.08),
        width: highlighted ? 1.5 : 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.30),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
    );

/// Drop-in dark-glass card widget. Wraps [child] in a [ClipRRect] +
/// [BackdropFilter] blur + [zamCard] decoration.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.highlighted = false,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
  });

  final Widget child;
  final bool highlighted;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: zamCard(highlighted: highlighted, radius: radius),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme Data
// ─────────────────────────────────────────────────────────────────────────────

/// The single [ThemeData] used by the app's [MaterialApp] — dark sci-fi palette.
final ThemeData zamWealthTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: kNeonMint,
    onPrimary: kCoreNavy,
    primaryContainer: kNeonMint.withValues(alpha: 0.15),
    onPrimaryContainer: kNeonMint,
    secondary: kPrimaryBlue,
    onSecondary: kCoreNavy,
    secondaryContainer: kPrimaryBlue.withValues(alpha: 0.15),
    onSecondaryContainer: kPrimaryBlue,
    tertiary: kGold,
    onTertiary: kCoreNavy,
    tertiaryContainer: kGold.withValues(alpha: 0.15),
    onTertiaryContainer: kGold,
    error: kError,
    onError: Colors.white,
    errorContainer: kError.withValues(alpha: 0.20),
    onErrorContainer: kError,
    surface: kDeepNavy,
    onSurface: kCharcoal,
    surfaceContainerHighest: kCoreNavy,
    onSurfaceVariant: kCharcoalLight,
    outline: kNeonMint.withValues(alpha: 0.25),
    shadow: Colors.black.withValues(alpha: 0.50),
  ),
  scaffoldBackgroundColor: kCoreNavy,
  textTheme: _textTheme,

  // ── AppBar ──────────────────────────────────────────────────────────────────
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: kCharcoal,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: _rajdhani(size: 18, weight: FontWeight.w700, letterSpacing: 0.5),
  ),

  // ── Elevated Button ──────────────────────────────────────────────────────────
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kNeonMint,
      foregroundColor: kCoreNavy,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: _rajdhani(size: 16, weight: FontWeight.w700, letterSpacing: 0.8),
      elevation: 0,
    ),
  ),

  // ── Outlined Button ──────────────────────────────────────────────────────────
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kNeonMint,
      minimumSize: const Size.fromHeight(52),
      side: const BorderSide(color: kNeonMint, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: _rajdhani(size: 16, weight: FontWeight.w600, letterSpacing: 0.5),
    ),
  ),

  // ── Text Button ──────────────────────────────────────────────────────────────
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: kNeonMint,
      textStyle: _rajdhani(size: 14, weight: FontWeight.w600, letterSpacing: 0.3),
      minimumSize: const Size(48, 48),
    ),
  ),

  // ── Input Fields ─────────────────────────────────────────────────────────────
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kDeepNavy,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kNeonMint.withValues(alpha: 0.20)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kNeonMint.withValues(alpha: 0.20)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kNeonMint, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kError),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kError, width: 1.5),
    ),
    labelStyle: _inter(size: 14, color: kCharcoalLight),
    hintStyle: _inter(size: 14, color: kCharcoalLight),
    errorStyle: _inter(size: 12, color: kError),
  ),

  // ── Card ─────────────────────────────────────────────────────────────────────
  cardTheme: CardThemeData(
    color: kDeepNavy,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
    ),
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
  ),

  // ── Bottom Navigation Bar ─────────────────────────────────────────────────────
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: const Color(0xFF0A1628),
    selectedItemColor: kNeonMint,
    unselectedItemColor: kCharcoalLight,
    selectedIconTheme: const IconThemeData(size: 26),
    unselectedIconTheme: const IconThemeData(size: 24),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: _rajdhani(size: 11, weight: FontWeight.w600, color: kNeonMint),
    unselectedLabelStyle: _rajdhani(size: 11, color: kCharcoalLight),
  ),

  // ── Chip ─────────────────────────────────────────────────────────────────────
  chipTheme: ChipThemeData(
    backgroundColor: kDeepNavy,
    selectedColor: kNeonMint.withValues(alpha: 0.20),
    labelStyle: _inter(size: 13, color: kCharcoal),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: kNeonMint.withValues(alpha: 0.25)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  ),

  // ── Slider ───────────────────────────────────────────────────────────────────
  sliderTheme: SliderThemeData(
    activeTrackColor: kNeonMint,
    inactiveTrackColor: kNeonMint.withValues(alpha: 0.20),
    thumbColor: kNeonMint,
    overlayColor: kNeonMint.withValues(alpha: 0.15),
    valueIndicatorColor: kNeonMint,
    valueIndicatorTextStyle: _orbitron(size: 12, color: kCoreNavy),
  ),

  // ── Divider ──────────────────────────────────────────────────────────────────
  dividerTheme: DividerThemeData(
    color: Colors.white.withValues(alpha: 0.08),
    thickness: 1,
    space: 1,
  ),

  // ── SnackBar ─────────────────────────────────────────────────────────────────
  snackBarTheme: SnackBarThemeData(
    backgroundColor: kDeepNavy,
    contentTextStyle: _inter(size: 14, color: kCharcoal),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: kNeonMint.withValues(alpha: 0.30)),
    ),
  ),

  // ── FloatingActionButton ──────────────────────────────────────────────────────
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kNeonMint,
    foregroundColor: kCoreNavy,
    elevation: 4,
  ),

  // ── Icon ─────────────────────────────────────────────────────────────────────
  iconTheme: const IconThemeData(color: kCharcoal),
  primaryIconTheme: const IconThemeData(color: kNeonMint),
);

// ─────────────────────────────────────────────────────────────────────────────
// Gradients
// ─────────────────────────────────────────────────────────────────────────────

/// Core navy → deep navy gradient — used on splash and premium headers.
const LinearGradient kZamGradient = LinearGradient(
  colors: [kCoreNavy, kDeepNavy, Color(0xFF0A2540)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.50, 1.0],
);

/// Teal → blue gradient — used on action buttons and progress fills.
const LinearGradient kAccentGradient = LinearGradient(
  colors: [kNeonMint, kPrimaryBlue],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

/// Gold → amber gradient — used on XP bars and reward cards.
const LinearGradient kGoldGradient = LinearGradient(
  colors: [kGold, Color(0xFFFB8500)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
