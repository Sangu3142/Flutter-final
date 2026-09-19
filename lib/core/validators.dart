/// validators.dart
/// Purpose: Shared input validation for every user-entered value — credentials,
///          free text, and financial amounts.
/// Reads from: nothing
/// Writes to: nothing (pure functions)
/// Navigation: none
library;

// Every function returns null when the value is acceptable, or a
// user-facing error message when it is not, so it can be dropped straight into
// a TextFormField.validator. Providers call the same functions before writing
// to Hive: a widget validator can be bypassed (dialogs without a Form, direct
// provider calls), so the provider is the last gate.
//
// BACKEND: these rules are UX and local-integrity only. When the API lands,
// every one of them must be re-implemented server-side — client validation is
// never a security control. See BACKEND_SECURITY_REQUIREMENTS.md §4.

// ─────────────────────────────────────────────────────────────────────────────
// Limits
// ─────────────────────────────────────────────────────────────────────────────

const int kUsernameMinLength = 3;
const int kUsernameMaxLength = 20;
const int kDisplayNameMinLength = 2;
const int kDisplayNameMaxLength = 30;
const int kPasswordMinLength = 6;

/// Upper bound on password length. Long inputs are rejected rather than
/// silently truncated, and it caps the work a single PBKDF2 call can be made
/// to do.
const int kPasswordMaxLength = 72;

/// Max length for player-authored free text (family member names, business
/// name, reflection notes).
const int kFreeTextMaxLength = 40;
const int kReflectionMaxLength = 280;

/// Ceiling for any ZamCoin amount a player can type. Well above anything
/// reachable through normal play, low enough that a fat-fingered or malicious
/// entry cannot overflow downstream arithmetic.
const int kMaxZamCoinInput = 1000000;

// ─────────────────────────────────────────────────────────────────────────────
// Credentials
// ─────────────────────────────────────────────────────────────────────────────

/// Validates a username.
///
/// Usernames double as the Hive key for [UserProfile] and appear inside
/// composite keys such as `"<uid>_<levelId>"`, so the charset is restricted to
/// characters that cannot confuse key parsing.
String? validateUsername(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Please choose a username';
  if (v.length < kUsernameMinLength) {
    return 'Username must be at least $kUsernameMinLength characters';
  }
  if (v.length > kUsernameMaxLength) {
    return 'Username must be $kUsernameMaxLength characters or fewer';
  }
  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) {
    return 'Only letters, numbers, and underscores';
  }
  if (v.startsWith('_') || v.endsWith('_')) {
    return 'Username cannot start or end with an underscore';
  }
  return null;
}

/// Validates a display name.
String? validateDisplayName(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Please enter your name';
  if (v.length < kDisplayNameMinLength) {
    return 'Name must be at least $kDisplayNameMinLength characters';
  }
  if (v.length > kDisplayNameMaxLength) {
    return 'Name must be $kDisplayNameMaxLength characters or fewer';
  }
  if (!RegExp(r"^[\p{L} '\-]+$", unicode: true).hasMatch(v)) {
    return 'Letters, spaces, hyphens, and apostrophes only';
  }
  return null;
}

/// Validates a password.
String? validatePassword(String? value) {
  final v = value ?? '';
  if (v.isEmpty) return 'Please create a password';
  if (v.trim().isEmpty) return 'Password cannot be only spaces';
  if (v.length < kPasswordMinLength) {
    return 'Password must be at least $kPasswordMinLength characters';
  }
  if (v.length > kPasswordMaxLength) {
    return 'Password must be $kPasswordMaxLength characters or fewer';
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Free text
// ─────────────────────────────────────────────────────────────────────────────

/// Validates player-authored free text (names, labels, notes).
String? validateFreeText(
  String? value, {
  required String fieldLabel,
  int maxLength = kFreeTextMaxLength,
  bool required = true,
}) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return required ? 'Please enter a $fieldLabel' : null;
  if (v.length > maxLength) {
    return '$fieldLabel must be $maxLength characters or fewer';
  }
  if (_containsControlCharacters(v)) {
    return '$fieldLabel contains invalid characters';
  }
  return null;
}

/// Strips control characters and collapses whitespace before persisting.
///
/// Applied to every free-text value on the way into Hive so stored data stays
/// well-formed regardless of what the keyboard produced.
String sanitizeFreeText(String value, {int maxLength = kFreeTextMaxLength}) {
  final cleaned = value
      .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return cleaned.length <= maxLength
      ? cleaned
      : cleaned.substring(0, maxLength);
}

bool _containsControlCharacters(String v) =>
    RegExp(r'[\x00-\x1F\x7F]').hasMatch(v);

// ─────────────────────────────────────────────────────────────────────────────
// Financial amounts
// ─────────────────────────────────────────────────────────────────────────────

/// Validates a ZamCoin amount typed by the player.
///
/// [max] defaults to [kMaxZamCoinInput]; callers pass a tighter bound where
/// one exists (wallet balance, loan ceiling).
String? validateZamCoinAmount(
  String? value, {
  int min = 1,
  int max = kMaxZamCoinInput,
  String label = 'Amount',
}) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Enter an amount';
  final parsed = int.tryParse(v);
  if (parsed == null) return '$label must be a whole number';
  if (parsed < min) return '$label must be at least $min';
  if (parsed > max) return '$label cannot exceed $max';
  return null;
}

/// Parses a ZamCoin amount, returning null when it fails validation.
///
/// Replaces the `int.tryParse(...) ?? 0` pattern, which silently turned bad
/// input into a no-op the player got no feedback about.
int? parseZamCoinAmount(
  String? value, {
  int min = 1,
  int max = kMaxZamCoinInput,
}) {
  if (validateZamCoinAmount(value, min: min, max: max) != null) return null;
  return int.parse(value!.trim());
}

/// Validates a ZMW amount (financial simulations use fractional kwacha).
String? validateZmwAmount(
  String? value, {
  double min = 0.01,
  double max = 1000000.0,
  String label = 'Amount',
}) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Enter an amount';
  final parsed = double.tryParse(v);
  if (parsed == null) return '$label must be a number';
  if (!parsed.isFinite) return '$label is not a valid number';
  if (parsed < min) return '$label must be at least $min';
  if (parsed > max) return '$label cannot exceed $max';
  return null;
}

/// Validates a Zambian mobile money number: 9 digits after the country code,
/// starting with 9 or 7 (MTN, Airtel, Zamtel ranges).
String? validateZambianPhone(String? value) {
  var v = (value ?? '').trim().replaceAll(RegExp(r'[\s\-]'), '');
  if (v.startsWith('+260')) v = v.substring(4);
  if (v.startsWith('260')) v = v.substring(3);
  if (v.startsWith('0')) v = v.substring(1);
  if (v.isEmpty) return 'Enter your mobile money number';
  if (!RegExp(r'^[97]\d{8}$').hasMatch(v)) {
    return 'Enter a valid Zambian number (e.g. 97 123 4567)';
  }
  return null;
}
