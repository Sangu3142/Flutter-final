/// profile_screen.dart
/// Purpose: Profile tab — premium dark fintech game aesthetic. Displays user
///          stats, income category, risk appetite, HUD bar, badges nav,
///          payment history, settings, and a 7-tap dev screen easter egg.
/// Reads from: authProvider, paymentHistoryProvider, devTapProvider, badgeMapProvider
/// Writes to: authProvider (logout)
/// Navigation: → /profile/dev (7-tap easter egg), → /login (logout), → /badges, → /stats
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/daily_challenge/providers/daily_challenge_provider.dart' show dailyChallengeProvider, streakProvider;
import 'package:zamwealth_quest/features/profile/providers/profile_provider.dart';
import 'package:zamwealth_quest/features/badges/providers/badge_provider.dart';
import 'package:zamwealth_quest/features/avatar/widgets/avatar_painter.dart';
import 'package:zamwealth_quest/features/shop/providers/inventory_provider.dart';
import 'package:zamwealth_quest/features/story/models/dialogue_moment.dart';
import 'package:zamwealth_quest/shared/widgets/animated_gradient_background.dart';
import 'package:zamwealth_quest/widgets/tutorial_overlay.dart'
    show kTutorialCompletedKey;
import 'package:zamwealth_quest/features/proverbs/providers/proverb_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette constants
// ─────────────────────────────────────────────────────────────────────────────

const Color _kDeepNavy = Color(0xFF0D1B2A);
const Color _kPrimaryBlue = Color(0xFF1A73E8);
const Color _kNeonMint = Color(0xFF36ECDE);
const Color _kFreshGreen = Color(0xFF2BC48A);
const Color _kSoftGray = Color(0xFFE6E9EC);

// ─────────────────────────────────────────────────────────────────────────────
// ProfileScreen
// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final payments = ref.watch(paymentHistoryProvider);
    final challengeStreak = ref.watch(streakProvider);
    final inventory = ref.watch(inventoryProvider);

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: SizedBox.shrink(),
      );
    }

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile header + HUD overlap ───────────────────────────
              _buildHeaderWithHud(context, ref, user, challengeStreak,
                  inventory.activeFrameId, inventory.activeStreakIconId),

              // ── Body content ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dailyChallengeStats(context, ref),
                    const SizedBox(height: 16),
                    _detailsCard(context, user, challengeStreak),
                    const SizedBox(height: 16),
                    _statsNavCard(context),
                    const SizedBox(height: 16),
                    _myBadgesCard(context, ref),
                    const SizedBox(height: 16),
                    _wisdomBookCard(context, ref),
                    const SizedBox(height: 16),
                    // ── Your Story So Far ──────────────────────────────────
                    Consumer(builder: (ctx, ref, _) {
                      final storyUser = ref.watch(currentUserProvider);
                      final storyChoices = (storyUser?.storyChoicesRaw ?? {})
                          .map((k, v) => MapEntry(k.toString(), v as int));
                      if (storyChoices.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F2A44),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Story So Far',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...storyChoices.entries.map((e) {
                                  final moment = kDialogueMoments[e.key];
                                  if (moment == null) {
                                    return const SizedBox.shrink();
                                  }
                                  final option = moment.options[e.value];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('📌 ',
                                            style: TextStyle(fontSize: 14)),
                                        Expanded(
                                          child: Text(
                                            option.financialConsequence,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                    _paymentHistorySection(context, payments),
                    const SizedBox(height: 16),
                    _settingsSection(context, ref),
                    const SizedBox(height: 24),
                    _versionLabel(context, ref),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header + HUD overlap ─────────────────────────────────────────────────────

  Widget _buildHeaderWithHud(BuildContext context, WidgetRef ref, user,
      int challengeStreak, String? activeFrameId, String? activeStreakIconId) {
    const headerH = 160.0;
    const hudH = 88.0;
    const overlap = 20.0;

    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: topPadding + headerH + hudH - overlap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding + headerH,
            child: _buildHeader(context, ref, user, activeFrameId),
          ),
          Positioned(
            top: topPadding + headerH - overlap,
            left: 12,
            right: 12,
            child: _buildHudBar(user, challengeStreak, activeStreakIconId),
          ),
        ],
      ),
    );
  }

  static Color? _frameColor(String? frameId) {
    switch (frameId) {
      case 'gold_frame':   return const Color(0xFFFFD700);
      case 'copper_frame': return const Color(0xFFB87333);
      case 'emerald_frame': return const Color(0xFF50C878);
      default: return null;
    }
  }

  static String _streakEmoji(String? iconId) {
    switch (iconId) {
      case 'flame_blue':    return '🔵';
      case 'flame_purple':  return '🟣';
      case 'flame_rainbow': return '🌈';
      default: return '🔥';
    }
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, user, String? activeFrameId) {
    final frameColor = _frameColor(activeFrameId);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kPrimaryBlue, Color(0xFF00203F)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: frameColor != null ? const EdgeInsets.all(3) : EdgeInsets.zero,
                    decoration: frameColor != null
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: frameColor, width: 3),
                          )
                        : null,
                    child: AvatarWidget(
                      avatarId: user.avatarId,
                      auraLevel: user.currentLevel >= 5
                          ? 2
                          : user.currentLevel >= 3
                              ? 1
                              : 0,
                      size: 80,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.changeAvatar),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Change Avatar',
                      style: TextStyle(color: _kNeonMint, fontSize: 11),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.name,
                      style: GoogleFonts.rajdhani(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _incomeLabel(user.incomeCategory),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _kFreshGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildRiskPills(user.riskAppetite),
                  ],
                ),
              ),

              // Logout button
              GestureDetector(
                onTap: () => _showSignOutDialog(context, ref),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskPills(String riskAppetite) {
    final options = ['low', 'medium', 'high'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options.map((option) {
        final isSelected = option == riskAppetite;
        return Container(
          margin: const EdgeInsets.only(right: 4),
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? _kPrimaryBlue
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${option[0].toUpperCase()}${option.substring(1)}',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── HUD Stat Bar ─────────────────────────────────────────────────────────────

  Widget _buildHudBar(user, int challengeStreak, String? activeStreakIconId) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _kNeonMint.withValues(alpha: 0.20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _kNeonMint.withValues(alpha: 0.15),
            blurRadius: 20,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _hudCell(
              value: '${user.xp}',
              label: 'TOTAL XP',
            ),
          ),
          _hudDivider(),
          Expanded(
            child: _hudCell(
              value: 'LVL ${user.currentLevel}',
              label: 'LEVEL',
            ),
          ),
          _hudDivider(),
          Expanded(
            child: _hudCell(
              value: '${_streakEmoji(activeStreakIconId)} $challengeStreak',
              label: 'STREAK',
            ),
          ),
        ],
      ),
    );
  }

  Widget _hudCell({required String value, required String label}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _kNeonMint,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: _kSoftGray,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _hudDivider() {
    return Container(
      width: 1,
      height: 44,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }

  // ── Daily Challenge Stats ─────────────────────────────────────────────────────

  Widget _dailyChallengeStats(BuildContext context, WidgetRef ref) {
    final dc = ref.watch(dailyChallengeProvider);
    final record = dc.record;

    final streak = record?.currentStreak ?? 0;
    final shields = record?.streakShields ?? 0;
    final total = record?.totalCompleted ?? 0;
    final bonusXp = record?.bonusXpEarned ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Challenge Stats',
          style: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            _statCell(icon: Icons.local_fire_department, iconColor: _kNeonMint,
                label: 'Current Streak', value: '$streak days'),
            _statCell(icon: Icons.shield, iconColor: _kPrimaryBlue,
                label: 'Streak Shields', value: '$shields left'),
            _statCell(icon: Icons.check_circle, iconColor: _kFreshGreen,
                label: 'Total Completed', value: '$total'),
            _statCell(icon: Icons.bolt, iconColor: _kNeonMint,
                label: 'Bonus XP Earned', value: '+$bonusXp XP'),
          ],
        ),
      ],
    );
  }

  Widget _statCell({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _kNeonMint,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: _kSoftGray,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile Details Card ──────────────────────────────────────────────────────

  Widget _detailsCard(BuildContext context, user, int challengeStreak) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Details',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _detailRow('@${user.username}', 'Username'),
          _detailRow(_incomeLabel(user.incomeCategory), 'Income Type'),
          _detailRow(user.riskAppetite.toUpperCase(), 'Risk Appetite'),
          _detailRow('$challengeStreak days', 'Streak'),
          _detailRow('${user.financialGoals.length} selected', 'Goals'),
          _detailRow(
            'ZMW ${user.totalSavingsZMW.toStringAsFixed(2)}',
            'Simulated Savings',
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: _kSoftGray,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── My Progress Stats Nav Card ────────────────────────────────────────────────

  Widget _statsNavCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.stats),
      child: _navCard(
        label: 'My Progress Stats',
        icon: Icons.bar_chart,
      ),
    );
  }

  // ── My Badges Nav Card ────────────────────────────────────────────────────────

  Widget _myBadgesCard(BuildContext context, WidgetRef ref) {
    final badgeMap = ref.watch(badgeMapProvider);
    final earnedCount = badgeMap.values.where((v) => v).length;
    final totalCount = badgeMap.length;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.badges),
      child: _navCard(
        label: 'My Badges',
        icon: Icons.military_tech,
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _kNeonMint.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: _kNeonMint.withValues(alpha: 0.4)),
          ),
          child: Text(
            '$earnedCount/$totalCount',
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _kNeonMint,
            ),
          ),
        ),
      ),
    );
  }

  Widget _navCard({
    required String label,
    required IconData icon,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: _kNeonMint, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: _kSoftGray,
              ),
            ),
          ),
          if (trailing != null) ...[
            trailing,
            const SizedBox(width: 8),
          ],
          const Icon(Icons.chevron_right, color: _kNeonMint, size: 20),
        ],
      ),
    );
  }

  // ── Wisdom Book Nav Card ──────────────────────────────────────────────────────

  Widget _wisdomBookCard(BuildContext context, WidgetRef ref) {
    // Read from the same provider the Wisdom Book screen uses
    // (string-ID unlocks stored in the settings box, see proverbs_screen.dart).
    final unlockState = ref.watch(proverbUnlockProvider);
    final count = unlockState.unlockedIds.length;
    return GestureDetector(
      onTap: () => context.push(AppRoutes.proverbs),
      child: _navCard(
        label: 'Wisdom Book',
        icon: Icons.menu_book,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2D9B8A).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2D9B8A).withValues(alpha: 0.4)),
          ),
          child: Text(
            '$count/$kTotalProverbs',
            style: GoogleFonts.orbitron(
              fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF2D9B8A),
            ),
          ),
        ),
      ),
    );
  }

  // ── Payment History ───────────────────────────────────────────────────────────

  Widget _paymentHistorySection(BuildContext context, List payments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment History',
          style: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        if (payments.isEmpty)
          _sectionCard(
            child: Text(
              'No payments yet. Unlock a level to see records here.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _kSoftGray,
                height: 1.5,
              ),
            ),
          )
        else
          ...payments.take(5).map((p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kDeepNavy,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _kPrimaryBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.payment,
                        color: _kNeonMint, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.tier,
                          style: GoogleFonts.rajdhani(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${p.provider} · ${p.timestamp.day}/${p.timestamp.month}/${p.timestamp.year}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _kSoftGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ZMW ${p.amountZMW.toStringAsFixed(0)}',
                        style: GoogleFonts.rajdhani(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _kNeonMint,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SANDBOX',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: _kSoftGray,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ── Settings Section ──────────────────────────────────────────────────────────

  Widget _settingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        _settingsItem(
          icon: Icons.leaderboard,
          label: 'Leaderboard',
          onTap: () => context.push(AppRoutes.leaderboard),
        ),
        const SizedBox(height: 8),
        _settingsItem(
          icon: Icons.play_circle_outline,
          label: 'Replay Tutorial',
          onTap: () async {
            await Hive.box(kSettingsBox).put(kTutorialCompletedKey, false);
            if (!context.mounted) return;
            context.go(AppRoutes.tutorial);
          },
        ),
        const SizedBox(height: 8),
        _settingsItem(
          icon: Icons.logout,
          label: 'Sign Out',
          iconColor: Colors.redAccent.withValues(alpha: 0.8),
          labelColor: Colors.redAccent.withValues(alpha: 0.9),
          onTap: () => _showSignOutDialog(context, ref),
        ),
      ],
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? labelColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _kDeepNavy,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? _kNeonMint, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: labelColor ?? _kSoftGray,
                ),
              ),
            ),
            Icon(Icons.chevron_right,
                color: iconColor ?? _kNeonMint, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Version Label (7-tap easter egg) ─────────────────────────────────────────

  Widget _versionLabel(BuildContext context, WidgetRef ref) {
    final tapCount = ref.watch(devTapProvider);
    final remaining = kDevScreenTapCount - tapCount;

    return Center(
      child: GestureDetector(
        onTap: () {
          final shouldOpen = ref.read(devTapProvider.notifier).tap();
          if (shouldOpen) {
            context.push(AppRoutes.dev);
          } else if (tapCount >= 3) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$remaining more taps to open Developer Screen',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
                duration: const Duration(seconds: 1),
                backgroundColor: const Color(0xFF2F2F2F),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: Column(
          children: [
            Text(
              'v1.0.0+1',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _kSoftGray.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'ZamWealth Quest © 2025',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: _kSoftGray.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Content Card Helper ───────────────────────────────────────────────────────

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kDeepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  String _incomeLabel(String category) {
    return switch (category) {
      'student' => 'Student',
      'informal_trader' => 'Informal Trader',
      'civil_servant' => 'Civil Servant',
      'entrepreneur' => 'Entrepreneur',
      _ => category,
    };
  }

  // ── Sign Out Confirmation Dialog ──────────────────────────────────────────────

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      // Prevents accidental dismissal by tapping outside the dialog.
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _kDeepNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: Text(
            'Sign Out?',
            style: GoogleFonts.rajdhani(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          content: Text(
            'Your progress is saved. You can sign back in anytime.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _kSoftGray,
            ),
          ),
          actions: [
            // ── Cancel ──────────────────────────────────────────────────
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.rajdhani(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _kSoftGray,
                ),
              ),
            ),

            // ── Sign Out ─────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF233C).withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF233C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  // Step 1 — dismiss the dialog synchronously while context
                  // is still valid and the navigator is not locked.
                  Navigator.of(dialogContext).pop();

                  // Step 2 — capture router and messenger from the profile
                  // screen's context before any await so they remain valid
                  // even after the widget is disposed.
                  final router = GoRouter.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  try {
                    // Step 3 — clear Hive session and reset auth state.
                    await ref.read(authProvider.notifier).signOut();

                    // Step 4 — navigate to login, removing the entire back
                    // stack so the user cannot return to an authenticated
                    // screen. Deferred by one frame so the navigation does
                    // not conflict with GoRouter's own redirect rebuild that
                    // fires when auth state becomes null.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      router.go(AppRoutes.login);
                    });
                  } catch (e) {
                    debugPrint('Sign out error: $e');
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sign out failed. Please try again.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: const Color(0xFF1A1A1A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.rajdhani(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
