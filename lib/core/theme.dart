/// theme.dart
/// Purpose: Defines the complete ZamWealth Quest design system — colours,
///          typography (Google Fonts), card styles, button themes, and the
///          full MaterialTheme used by MaterialApp.router.
/// Reads from: nothing
/// Writes to: nothing
/// Navigation: none
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Brand Colours
// ─────────────────────────────────────────────────────────────────────────────

/// Primary brand colour — Copper. Used for headings, primary buttons,
/// selected bottom-nav items, and interactive accents.
const Color kCopper = Color(0xFFB87333);

/// Light copper tone for card borders and secondary accents.
const Color kCopperLight = Color(0xFFD4956A);

/// Very light copper tint for pressed states.
const Color kCopperSurface = Color(0xFFF5E6D8);

/// Success / progress colour — Malachite Green.
const Color kGreen = Color(0xFF2E8B57);

/// Light green for progress fills and success chips.
const Color kGreenLight = Color(0xFF5BA882);

/// Background colour — warm Cream.
const Color kCream = Color(0xFFFFF8E7);

/// Primary text colour — Dark Charcoal.
const Color kCharcoal = Color(0xFF2C2C2C);

/// Secondary text colour — lighter charcoal.
const Color kCharcoalLight = Color(0xFF6B6B6B);

/// Highlight colour — Gold. Used for ZamCoins, badges, and streak indicators.
const Color kGold = Color(0xFFFFD700);

/// Locked level node colour.
const Color kLocked = Color(0xFFB0B0B0);

/// Warning / caution colour (e.g. savings below 10%).
const Color kWarning = Color(0xFFE57C00);

/// Error colour.
const Color kError = Color(0xFFD32F2F);

// ─────────────────────────────────────────────────────────────────────────────
// Typography
// ─────────────────────────────────────────────────────────────────────────────

/// Poppins is used for all headings and display text.
TextStyle _poppins({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color color = kCharcoal,
  double? height,
}) =>
    GoogleFonts.poppins(
        fontSize: size, fontWeight: weight, color: color, height: height);

/// Inter is used for all body text, captions, and form fields.
TextStyle _inter({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color color = kCharcoal,
  double? height,
}) =>
    GoogleFonts.inter(
        fontSize: size, fontWeight: weight, color: color, height: height);

// ─────────────────────────────────────────────────────────────────────────────
// Text Theme
// ─────────────────────────────────────────────────────────────────────────────

final TextTheme _textTheme = TextTheme(
  // Display — large hero text
  displayLarge: _poppins(size: 32, weight: FontWeight.w700, color: kCharcoal),
  displayMedium: _poppins(size: 28, weight: FontWeight.w700, color: kCharcoal),
  displaySmall: _poppins(size: 24, weight: FontWeight.w600, color: kCharcoal),

  // Headlines
  headlineLarge: _poppins(size: 22, weight: FontWeight.w700, color: kCharcoal),
  headlineMedium: _poppins(size: 20, weight: FontWeight.w600, color: kCharcoal),
  headlineSmall: _poppins(size: 18, weight: FontWeight.w600, color: kCharcoal),

  // Titles
  titleLarge: _poppins(size: 16, weight: FontWeight.w600, color: kCharcoal),
  titleMedium: _poppins(size: 14, weight: FontWeight.w600, color: kCharcoal),
  titleSmall: _poppins(size: 12, weight: FontWeight.w600, color: kCharcoal),

  // Body — Inter
  bodyLarge:
      _inter(size: 16, weight: FontWeight.w400, color: kCharcoal, height: 1.5),
  bodyMedium:
      _inter(size: 14, weight: FontWeight.w400, color: kCharcoal, height: 1.5),
  bodySmall: _inter(
      size: 12, weight: FontWeight.w400, color: kCharcoalLight, height: 1.4),

  // Label — Inter
  labelLarge: _inter(size: 14, weight: FontWeight.w500, color: kCharcoal),
  labelMedium: _inter(size: 12, weight: FontWeight.w500, color: kCharcoal),
  labelSmall: _inter(size: 10, weight: FontWeight.w500, color: kCharcoalLight),
);

// ─────────────────────────────────────────────────────────────────────────────
// Card Decoration Helper
// ─────────────────────────────────────────────────────────────────────────────

/// Returns a standard ZamWealth card [BoxDecoration] with a 12 px radius
/// and a subtle copper-tinted drop shadow.
BoxDecoration zamCard({
  Color background = Colors.white,
  double radius = 12,
  bool highlighted = false,
}) =>
    BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
      border: highlighted
          ? Border.all(color: kCopper.withValues(alpha: 0.6), width: 1.5)
          : null,
      boxShadow: [
        BoxShadow(
          color: kCopper.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

// ─────────────────────────────────────────────────────────────────────────────
// Theme Data
// ─────────────────────────────────────────────────────────────────────────────

/// The central [ThemeData] used by the app's [MaterialApp].
final ThemeData zamWealthTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: kCopper,
    onPrimary: Colors.white,
    primaryContainer: kCopperSurface,
    onPrimaryContainer: kCharcoal,
    secondary: kGreen,
    onSecondary: Colors.white,
    secondaryContainer: kGreen.withValues(alpha: 0.15),
    onSecondaryContainer: kCharcoal,
    tertiary: kGold,
    onTertiary: kCharcoal,
    tertiaryContainer: kGold.withValues(alpha: 0.15),
    onTertiaryContainer: kCharcoal,
    error: kError,
    onError: Colors.white,
    errorContainer: kError.withValues(alpha: 0.1),
    onErrorContainer: kError,
    surface: Colors.white,
    onSurface: kCharcoal,
    surfaceContainerHighest: kCream,
    onSurfaceVariant: kCharcoalLight,
    outline: kCopperLight.withValues(alpha: 0.4),
    shadow: kCopper.withValues(alpha: 0.12),
  ),
  scaffoldBackgroundColor: kCream,
  textTheme: _textTheme,

  // ── AppBar ──
  appBarTheme: AppBarTheme(
    backgroundColor: kCopper,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle:
        _poppins(size: 18, weight: FontWeight.w700, color: Colors.white),
  ),

  // ── Elevated Button ──
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kCopper,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: _poppins(size: 15, weight: FontWeight.w600),
      elevation: 2,
      shadowColor: kCopper.withValues(alpha: 0.4),
    ),
  ),

  // ── Outlined Button ──
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kCopper,
      minimumSize: const Size.fromHeight(52),
      side: const BorderSide(color: kCopper, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: _poppins(size: 15, weight: FontWeight.w600, color: kCopper),
    ),
  ),

  // ── Text Button ──
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: kCopper,
      textStyle: _poppins(size: 14, weight: FontWeight.w600, color: kCopper),
      minimumSize: const Size(48, 48),
    ),
  ),

  // ── Input Fields ──
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kCopperLight.withValues(alpha: 0.4)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kCopperLight.withValues(alpha: 0.4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kCopper, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kError),
    ),
    labelStyle: _inter(size: 14, color: kCharcoalLight),
    hintStyle: _inter(size: 14, color: kCharcoalLight),
  ),

  // ── Card ──
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
  ),

  // ── Bottom Navigation Bar ──
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: kCopper,
    unselectedItemColor: kCharcoalLight,
    selectedIconTheme: IconThemeData(size: 26),
    unselectedIconTheme: IconThemeData(size: 24),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),

  // ── Chip ──
  chipTheme: ChipThemeData(
    backgroundColor: kCopperSurface,
    selectedColor: kCopper.withValues(alpha: 0.2),
    labelStyle: _inter(size: 13, color: kCharcoal),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  ),

  // ── Slider ──
  sliderTheme: SliderThemeData(
    activeTrackColor: kCopper,
    inactiveTrackColor: kCopperLight.withValues(alpha: 0.3),
    thumbColor: kCopper,
    overlayColor: kCopper.withValues(alpha: 0.15),
    valueIndicatorColor: kCopper,
    valueIndicatorTextStyle: _inter(size: 12, color: Colors.white),
  ),

  // ── Divider ──
  dividerTheme: DividerThemeData(
    color: kCopperLight.withValues(alpha: 0.25),
    thickness: 1,
    space: 1,
  ),

  // ── SnackBar ──
  snackBarTheme: SnackBarThemeData(
    backgroundColor: kCharcoal,
    contentTextStyle: _inter(size: 14, color: Colors.white),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),

  // ── FloatingActionButton ──
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kCopper,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Gradient
// ─────────────────────────────────────────────────────────────────────────────

/// The copper-to-green gradient used as the splash/onboarding background
/// and on premium level header cards.
const LinearGradient kZamGradient = LinearGradient(
  colors: [kCopper, Color(0xFF8A5A1F), kGreen],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.5, 1.0],
);

/// A subtle cream-to-white gradient for section backgrounds.
const LinearGradient kCreamGradient = LinearGradient(
  colors: [kCream, Colors.white],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
