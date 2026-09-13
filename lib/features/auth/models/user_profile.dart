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
    List<String>? completedQuizIds,
    this.totalQuizXP = 0,
    List<int>? unlockedChapterIds,
    this.lastSeasonalEventId,
    this.walletBalance = 0,
    this.avatarId = 'av_01',
    Map<dynamic, dynamic>? storyChoicesRaw,
    this.zamuLevel = 1,
    this.spinLastDate,
    this.bonusSpinsAvailable = 0,
    this.loginBonusDay = 1,
    this.loginBonusLastDate,
    this.xpBoostExpiry,
    this.monthlyChallengeDoneMonth,
  })  : unlockedLevels = unlockedLevels ?? [1],
        badges = badges ?? [],
        earnedBadges = earnedBadges ?? [],
        completedQuizIds = completedQuizIds ?? [],
        unlockedChapterIds = unlockedChapterIds ?? [],
        storyChoicesRaw = storyChoicesRaw ?? {},
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

  /// Quiz question IDs the player has answered (for de-duplication).
  @HiveField(16)
  List<String> completedQuizIds;

  /// Total XP earned specifically from the Financial Quiz feature.
  @HiveField(17)
  int totalQuizXP;

  /// Story chapter IDs unlocked in The Kwacha Chronicles.
  @HiveField(18)
  List<int> unlockedChapterIds;

  /// ID of the last seasonal event the player completed (e.g. 'se_dec_2025').
  @HiveField(19)
  String? lastSeasonalEventId;

  // ── Gamification / Wallet / Story ─────────────────────────────────────────

  /// In-app wallet balance (coins earned through gameplay).
  @HiveField(20)
  int walletBalance;

  /// Avatar asset ID selected by the player (e.g. 'student', 'trader').
  @HiveField(21)
  String avatarId;

  /// Raw map of story moment IDs → chosen option index.
  /// Use the [storyChoices] getter for a typed `Map<String, int>` view.
  @HiveField(22)
  Map<dynamic, dynamic> storyChoicesRaw;

  /// The player's current Zamu (mastery) level (1–5).
  @HiveField(23)
  int zamuLevel;

  /// ISO-8601 date string of the last spin-the-wheel play.
  @HiveField(24)
  String? spinLastDate;

  /// Number of bonus spins available to the player.
  @HiveField(25)
  int bonusSpinsAvailable;

  /// Day index within the current login-bonus streak (1-based).
  @HiveField(26)
  int loginBonusDay;

  /// ISO-8601 date string of the last login-bonus claim.
  @HiveField(27)
  String? loginBonusLastDate;

  /// ISO-8601 datetime string when the active XP boost expires.
  @HiveField(28)
  String? xpBoostExpiry;

  /// The calendar month (1–12) in which the monthly challenge was completed,
  /// encoded as `year * 100 + month` (e.g. 202601 = January 2026).
  @HiveField(29)
  int? monthlyChallengeDoneMonth;

  // ── Computed Accessors ────────────────────────────────────────────────────

  /// Typed view of [storyChoicesRaw] as `Map<String, int>`.
  Map<String, int> get storyChoices =>
      storyChoicesRaw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));

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

  /// Awards quiz XP and records the question ID.
  void addQuizXp(int amount, String questionId) {
    xp += amount;
    totalQuizXP += amount;
    if (!completedQuizIds.contains(questionId)) {
      completedQuizIds.add(questionId);
    }
  }

  /// Records an unlocked story chapter.
  void unlockChapter(int chapterId) {
    if (!unlockedChapterIds.contains(chapterId)) {
      unlockedChapterIds.add(chapterId);
    }
  }

  /// Marks a seasonal event as completed for the current year/month.
  void completeSeasonalEvent(String eventId, int year, int month) {
    lastSeasonalEventId = '${eventId}_${year}_$month';
  }

  /// Returns true if [eventId] was completed this calendar month.
  bool hasCompletedSeasonalEvent(String eventId, int year, int month) {
    return lastSeasonalEventId == '${eventId}_${year}_$month';
  }

  // ── Wallet helpers ────────────────────────────────────────────────────────

  /// Adds [amount] coins to [walletBalance].
  /// Caller must await user.save() after calling this.
  void addWalletCoins(int amount) {
    walletBalance += amount;
  }

  /// Deducts [amount] coins from [walletBalance].
  /// Returns `false` (no-op) if the balance is insufficient.
  /// Caller must await user.save() after a successful call.
  bool spendWalletCoins(int amount) {
    if (walletBalance < amount) return false;
    walletBalance -= amount;
    return true;
  }

  // ── Story helpers ─────────────────────────────────────────────────────────

  /// Records the player's choice for a story moment and persists.
  void recordStoryChoice(String momentId, int choiceIndex) {
    storyChoicesRaw[momentId] = choiceIndex;
    save();
  }

  @override
  String toString() =>
      'UserProfile(uid: $uid, name: $name, xp: $xp, level: $currentLevel)';
}
