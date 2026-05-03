/// user_profile.dart
/// Purpose: Defines the UserProfile Hive model — the central data object
///          representing a registered player, their progress, and preferences.
/// Reads from: Hive box 'users'
/// Writes to: Hive box 'users'
/// Navigation: none (data model only)
library;

import 'package:hive/hive.dart';

part 'user_profile.g.dart';

/// [UserProfile] is the central player record stored in the 'users' Hive box.
///
/// Key design decisions:
/// - [uid] doubles as the Hive box key (= username), enabling O(1) lookups.
/// - Dates are stored as ISO-8601 [String]s to avoid registering a custom
///   DateTime TypeAdapter, keeping the generated adapter simple and stable.
/// - [passwordHash] stores a salted deterministic hash of the password;
///   never store plain-text passwords.
@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  UserProfile({
    required this.uid,
    required this.name,
    required this.username,
    required this.passwordHash,
    required this.incomeCategory,
    required this.financialGoals,
    required this.riskAppetite,
    this.xp = 0,
    this.zamCoins = 0,
    this.currentLevel = 1,
    List<int>? unlockedLevels,
    List<String>? badges,
    this.streak = 0,
    String? lastActiveStr,
    this.totalSavingsZMW = 0.0,
    List<String>? earnedBadges,
  })  : unlockedLevels = unlockedLevels ?? [1],
        badges = badges ?? [],
        earnedBadges = earnedBadges ?? [],
        lastActiveStr = lastActiveStr ?? DateTime.now().toIso8601String();

  // ── Identity ──────────────────────────────────────────────────────────────

  /// Unique player identifier — same value as the username.
  @HiveField(0)
  String uid;

  /// Player's display name (first name / chosen name).
  @HiveField(1)
  String name;

  /// Login username — must be unique across the Hive box.
  @HiveField(2)
  String username;

  /// Salted hash of the player's password. Never stored as plain text.
  @HiveField(3)
  String passwordHash;

  // ── Onboarding / Profile ──────────────────────────────────────────────────

  /// Income category selected during onboarding.
  /// Valid values: 'student', 'informal_trader', 'civil_servant', 'entrepreneur'.
  @HiveField(4)
  String incomeCategory;

  /// Financial goals selected during onboarding (multi-select).
  /// e.g. ['buy_land', 'start_business', 'invest', 'emergency_fund']
  @HiveField(5)
  List<String> financialGoals;

  /// Risk appetite selected via slider during onboarding.
  /// Valid values: 'low', 'medium', 'high'.
  @HiveField(6)
  String riskAppetite;

  // ── Progress ──────────────────────────────────────────────────────────────

  /// Total XP accumulated across all completed simulations.
  @HiveField(7)
  int xp;

  /// ZamCoins balance — awarded for payments and milestones.
  @HiveField(8)
  int zamCoins;

  /// The highest level the player has entered (1–4).
  @HiveField(9)
  int currentLevel;

  /// List of level IDs that have been unlocked (free or via payment).
  /// Level 1 is always present in this list.
  @HiveField(10)
  List<int> unlockedLevels;

  /// Badge identifiers earned by the player (e.g. 'budget_master').
  @HiveField(11)
  List<String> badges;

  /// Number of consecutive days the player has opened the app.
  @HiveField(12)
  int streak;

  /// ISO-8601 string of the last time the player was active.
  /// Use the [lastActive] getter/setter for [DateTime] access.
  @HiveField(13)
  String lastActiveStr;

  /// Total savings simulated across all budget/savings simulations (ZMW).
  @HiveField(14)
  double totalSavingsZMW;

  /// Badge IDs earned through the Achievement Badge System.
  @HiveField(15)
  List<String> earnedBadges;

  // ── Computed Accessors ────────────────────────────────────────────────────

  /// Returns [lastActiveStr] as a [DateTime] object.
  DateTime get lastActive => DateTime.parse(lastActiveStr);

  /// Updates [lastActiveStr] from a [DateTime] value.
  set lastActive(DateTime value) {
    lastActiveStr = value.toIso8601String();
  }

  /// Returns true if level [levelId] is in the [unlockedLevels] list.
  bool hasUnlocked(int levelId) => unlockedLevels.contains(levelId);

  /// Adds XP and updates [currentLevel] badge if applicable.
  void addXp(int amount) {
    xp += amount;
  }

  /// Awards ZamCoins.
  void addZamCoins(int amount) {
    zamCoins += amount;
  }

  /// Returns true if [badgeId] has been earned.
  bool hasBadge(String badgeId) => earnedBadges.contains(badgeId);

  /// Awards [badgeId] if not already present and persists to Hive.
  void awardBadge(String badgeId) {
    if (!earnedBadges.contains(badgeId)) {
      earnedBadges.add(badgeId);
      save();
    }
  }

  /// Unlocks a level by adding its ID to [unlockedLevels].
  void unlockLevel(int levelId) {
    if (!unlockedLevels.contains(levelId)) {
      unlockedLevels = [...unlockedLevels, levelId];
    }
  }

  @override
  String toString() =>
      'UserProfile(uid: $uid, name: $name, xp: $xp, level: $currentLevel)';
}
