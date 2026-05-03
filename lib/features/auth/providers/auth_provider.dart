/// auth_provider.dart
/// Purpose: Manages all authentication state — login, register, logout,
///          password hashing, and session persistence in Hive.
/// Reads from: Hive boxes 'users', 'session', 'settings'
/// Writes to: Hive boxes 'users', 'session', 'settings'
/// Navigation: triggers GoRouter redirects via state changes
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/models/user_profile.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth State
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable snapshot of the authentication state.
class AuthState {
  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.error,
  });

  /// The currently authenticated [UserProfile], or null if not logged in.
  final UserProfile? currentUser;

  /// True while a login/register operation is in progress.
  final bool isLoading;

  /// Non-null when the last operation failed.
  final String? error;

  /// True when a user is authenticated.
  bool get isAuthenticated => currentUser != null;

  /// True if the user has completed the onboarding flow.
  bool get hasCompletedOnboarding {
    if (currentUser == null) return false;
    final settingsBox = Hive.box(kSettingsBox);
    return settingsBox.get('onboardingDone_${currentUser!.uid}',
        defaultValue: false) as bool;
  }

  AuthState copyWith({
    UserProfile? currentUser,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// [AuthNotifier] owns all authentication logic.
/// No auth logic lives inside any widget build method.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _restoreSession();
  }

  // ── Private Helpers ───────────────────────────────────────────────────────

  /// Simple deterministic password hash using base64 + salt.
  /// NOT cryptographically strong — sufficient for a local offline app.
  String _hashPassword(String password) {
    final salted = 'zmw_quest_2024_$password';
    return base64Encode(utf8.encode(salted));
  }

  /// Returns the Hive 'users' box (must already be open).
  Box<UserProfile> get _userBox => Hive.box<UserProfile>(kUserBox);

  /// Returns the Hive 'session' box.
  Box get _sessionBox => Hive.box(kSessionBox);

  /// Returns the Hive 'settings' box.
  Box get _settingsBox => Hive.box(kSettingsBox);

  // ── Session Restoration ───────────────────────────────────────────────────

  /// Session is never restored across app launches — users must log in each
  /// time the app starts fresh. (In-memory Riverpod state keeps them logged
  /// in while the process is alive, e.g. when backgrounding.)
  void _restoreSession() {
    // Clear any legacy persisted session so old installs also require login.
    _sessionBox.delete('currentUid');
    state = const AuthState();
  }

  /// Checks if the player has logged in today and updates [UserProfile.streak].
  void _updateStreak(UserProfile user) {
    try {
      final lastActive = user.lastActive;
      final now = DateTime.now();
      final daysSince = now.difference(lastActive).inDays;

      if (daysSince == 1) {
        // Consecutive day — increment streak
        user.streak += 1;
      } else if (daysSince > 1) {
        // Streak broken
        user.streak = 1;
      }
      // daysSince == 0: same day, no change

      user.lastActive = now;
      user.save(); // persist to Hive
    } catch (_) {
      // Streak update failures are non-critical — swallow silently.
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  /// Authenticates the player with [username] and [password].
  ///
  /// Sets [AuthState.error] on failure; sets [AuthState.currentUser] on success.
  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final trimmedUsername = username.trim().toLowerCase();

      // Look up the user record
      final user = _userBox.get(trimmedUsername);

      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Account not found. Please register first.',
        );
        return;
      }

      // Verify password hash
      final hash = _hashPassword(password);
      if (user.passwordHash != hash) {
        state = state.copyWith(
          isLoading: false,
          error: 'Incorrect password. Please try again.',
        );
        return;
      }

      // Update streak
      _updateStreak(user);

      state = AuthState(currentUser: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed. Please try again. (${e.toString()})',
      );
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  /// Creates a new [UserProfile] and logs the player in.
  ///
  /// [username] must be unique. Returns false and sets [AuthState.error]
  /// on validation or storage failure.
  Future<bool> register({
    required String name,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final trimmed = username.trim().toLowerCase();

      // Validate username uniqueness
      if (_userBox.containsKey(trimmed)) {
        state = state.copyWith(
          isLoading: false,
          error: 'Username "$trimmed" is already taken. Choose another.',
        );
        return false;
      }

      // Validate input lengths
      if (trimmed.length < 3) {
        state = state.copyWith(
          isLoading: false,
          error: 'Username must be at least 3 characters.',
        );
        return false;
      }

      if (password.length < 6) {
        state = state.copyWith(
          isLoading: false,
          error: 'Password must be at least 6 characters.',
        );
        return false;
      }

      // Build the new profile with sensible defaults
      final profile = UserProfile(
        uid: trimmed,
        name: name.trim(),
        username: trimmed,
        passwordHash: _hashPassword(password),
        incomeCategory: '', // filled in onboarding
        financialGoals: [], // filled in onboarding
        riskAppetite: 'medium', // default, overridden in onboarding
        xp: 0,
        zamCoins: 0,
        currentLevel: 1,
        unlockedLevels: [1], // Level 1 is always free
        badges: [],
        streak: 1,
      );

      // Award first-login badge before persisting
      profile.earnedBadges.add('first_login');

      // Persist to Hive
      await _userBox.put(trimmed, profile);

      state = AuthState(currentUser: profile);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed. Please try again. (${e.toString()})',
      );
      return false;
    }
  }

  // ── Onboarding Complete ───────────────────────────────────────────────────

  /// Saves onboarding preferences and marks onboarding as done.
  Future<void> completeOnboarding({
    required String incomeCategory,
    required List<String> financialGoals,
    required String riskAppetite,
  }) async {
    final user = state.currentUser;
    if (user == null) return;

    try {
      user.incomeCategory = incomeCategory;
      user.financialGoals = financialGoals;
      user.riskAppetite = riskAppetite;
      user.awardBadge('onboarding_complete');
      await user.save();

      // Mark onboarding as done so it is skipped on next launch
      await _settingsBox.put('onboardingDone_${user.uid}', true);

      // Emit updated state so router redirects to dashboard
      state = AuthState(currentUser: user);
    } catch (e) {
      state = state.copyWith(error: 'Could not save preferences: $e');
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  /// Clears the session from Hive and resets state to unauthenticated.
  Future<void> logout() async {
    try {
      await _sessionBox.delete('currentUid');
    } catch (_) {}
    state = const AuthState(currentUser: null);
  }

  // ── Dev Utilities ─────────────────────────────────────────────────────────

  /// Resets all Hive boxes to factory state.
  /// Only callable from the dev screen.
  Future<void> devResetAll() async {
    try {
      await _userBox.clear();
      await _sessionBox.clear();
      await _settingsBox.clear();
      await Hive.box<dynamic>(kLevelBox).clear();
      await Hive.box<dynamic>(kPaymentBox).clear();
      await Hive.box<dynamic>(kLeaderboardBox).clear();
    } catch (_) {}
    state = const AuthState();
  }

  /// Refreshes the in-memory user state from Hive (e.g. after XP changes).
  void refreshUser() {
    final uid = state.currentUser?.uid;
    if (uid == null) return;
    final user = _userBox.get(uid);
    if (user != null) {
      state = AuthState(currentUser: user);
    }
  }

  /// Awards [amount] XP to the current user and persists the change.
  /// Called by the Daily Challenge system on correct answers.
  Future<void> addXp(int amount) async {
    final user = state.currentUser;
    if (user == null) return;
    user.addXp(amount);
    await user.save();
    state = AuthState(currentUser: user);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Global [StateNotifierProvider] for authentication state.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Convenience provider — returns the current [UserProfile] or null.
final currentUserProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authProvider).currentUser;
});
