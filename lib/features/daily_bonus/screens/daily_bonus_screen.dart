// lib/features/daily_bonus/screens/daily_bonus_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/daily_bonus_provider.dart';
import '../../wallet/widgets/coin_earn_animation.dart';
import '../../../core/constants.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const Color _kDeepNavy  = Color(0xFF0D1B2A);
const Color _kNeonMint  = Color(0xFF36ECDE);
const Color _kGold      = Color(0xFFFFB703);
const Color _kFreshGreen = Color(0xFF2BC48A);
const Color _kSoftGray  = Color(0xFFE6E9EC);

// ── Screen ────────────────────────────────────────────────────────────────────

class DailyBonusScreen extends ConsumerStatefulWidget {
  const DailyBonusScreen({super.key});

  @override
  ConsumerState<DailyBonusScreen> createState() => _DailyBonusScreenState();
}

class _DailyBonusScreenState extends ConsumerState<DailyBonusScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  // Screen entry: fade + slide-up 20 px, 300 ms easeOut.
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  // Reward badge pop-in using elasticOut.
  late final AnimationController _rewardCtrl;
  late final Animation<double> _rewardScale;

  // Tap-feedback flag for the Claim button.
  bool _claimDown = false;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    _rewardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rewardScale = CurvedAnimation(
      parent: _rewardCtrl,
      curve: Curves.elasticOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _entryCtrl.forward();
      _rewardCtrl.forward();
    });
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _entryCtrl.dispose();
    _rewardCtrl.dispose();
    super.dispose();
  }

  // Reward preview icons for day cells
  static const _dayIcons = ['🪙', '🪙', '💡', '🪙', '🛡️', '🪙', '⚡'];

  @override
  Widget build(BuildContext context) {
    final bonus = ref.watch(dailyBonusProvider);
    final schedule = kDailyBonusSchedule[bonus.bonusDay - 1];
    final coins  = schedule['coins'] as int;
    final xp     = schedule['xp'] as int;
    final powerUp = schedule['powerUp'] as String?;

    final day7Schedule = kDailyBonusSchedule[6];
    final day7Coins = day7Schedule['coins'] as int;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // ── Shared widgets ────────────────────────────────────────────────────────

    final header = Padding(
      padding: EdgeInsets.fromLTRB(20, isLandscape ? 8 : 24, 20, 0),
      child: Column(
        children: [
          Text(
            '🎁 Daily Bonus!',
            style: GoogleFonts.rajdhani(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: _kGold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Day ${bonus.bonusDay} of 7',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: _kSoftGray.withValues(alpha: 0.70),
            ),
          ),
        ],
      ),
    );

    final dayCards = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (i) {
          final day = i + 1;
          return _DayCard(
            day: day,
            claimed: day < bonus.bonusDay,
            isToday: day == bonus.bonusDay,
            isFuture: day > bonus.bonusDay,
            rewardIcon: _dayIcons[i],
          );
        }),
      ),
    );

    // Center + mainAxisSize.min lets this widget size to content in a
    // SingleChildScrollView (landscape) and still fill+center in Expanded
    // (portrait).
    final rewardShowcase = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (_, child) {
          final g = _glowAnim.value;
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _kDeepNavy,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _kGold.withValues(alpha: 0.35 + g * 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withValues(alpha: 0.12 + g * 0.12),
                  blurRadius: 20 + g * 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isLandscape ? 8 : 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _rewardScale,
                  child: Text('🪙',
                      style: TextStyle(fontSize: isLandscape ? 36 : 52)),
                ),
                SizedBox(height: isLandscape ? 6 : 10),
                ScaleTransition(
                  scale: _rewardScale,
                  child: Text(
                    'ZMW $coins',
                    style: GoogleFonts.orbitron(
                      fontSize: isLandscape ? 26 : 36,
                      fontWeight: FontWeight.w700,
                      color: _kGold,
                    ),
                  ),
                ),
                if (xp > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kNeonMint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _kNeonMint.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      '+$xp XP',
                      style: GoogleFonts.rajdhani(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _kNeonMint,
                      ),
                    ),
                  ),
                ],
                if (powerUp != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kFreshGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _kFreshGreen.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      '+ 1 ${powerUp.replaceAll('_', ' ').toUpperCase()}',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kFreshGreen,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    final motivationCard = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            horizontal: 16, vertical: isLandscape ? 8 : 12),
        decoration: BoxDecoration(
          color: _kNeonMint.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kNeonMint.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                bonus.bonusDay == 7
                    ? "Today is Day 7 — claim your biggest reward!"
                    : 'Keep going! Day 7 gives Double XP + ZMW $day7Coins!',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _kNeonMint,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final enabledClaim = !bonus.alreadyClaimed;
    final claimButton = Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, isLandscape ? 12 : 24),
      child: Builder(
        builder: (ctx) => GestureDetector(
          onTapDown: enabledClaim
              ? (_) => setState(() => _claimDown = true)
              : null,
          onTapCancel:
              enabledClaim ? () => setState(() => _claimDown = false) : null,
          onTapUp: enabledClaim
              ? (_) async {
                  setState(() => _claimDown = false);
                  await ref
                      .read(dailyBonusProvider.notifier)
                      .claimBonus();
                  if (!ctx.mounted) return;
                  CoinEarnAnimation.show(ctx, coins);
                  await Future.delayed(
                      const Duration(milliseconds: 1500));
                  if (!ctx.mounted) return;
                  ctx.go(AppRoutes.home);
                }
              : null,
          child: AnimatedScale(
            scale: _claimDown ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: Container(
              width: double.infinity,
              height: isLandscape ? 44 : 56,
              decoration: BoxDecoration(
                color: enabledClaim
                    ? _kGold
                    : _kSoftGray.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                boxShadow: enabledClaim
                    ? [
                        BoxShadow(
                          color: const Color(0xFFB7820A)
                              .withValues(alpha: 0.85),
                          offset: const Offset(0, 4),
                          blurRadius: 0,
                        ),
                        BoxShadow(
                          color: _kGold.withValues(alpha: 0.30),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : const [],
              ),
              child: Center(
                child: Text(
                  bonus.alreadyClaimed
                      ? 'Already Claimed ✓'
                      : '🎁  Claim Reward!',
                  style: GoogleFonts.rajdhani(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kCoreNavy,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // ── Layout: portrait uses Column+Expanded; landscape scrolls ─────────────

    return Scaffold(
      backgroundColor: kCoreNavy.withValues(alpha: 0.97),
      body: SafeArea(
        child: FadeTransition(
          opacity: _entryFade,
          child: SlideTransition(
            position: _entrySlide,
            child: isLandscape
                // ClampingScrollPhysics prevents Android overscroll glow from
                // interfering with layout measurement, eliminating the 160 px overflow.
                ? SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom:
                          MediaQuery.of(context).padding.bottom + 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        header,
                        const SizedBox(height: 6),
                        dayCards,
                        const SizedBox(height: 6),
                        rewardShowcase,
                        const SizedBox(height: 8),
                        motivationCard,
                        const SizedBox(height: 8),
                        claimButton,
                      ],
                    ),
                  )
                : Column(
                    children: [
                      header,
                      const SizedBox(height: 20),
                      dayCards,
                      const SizedBox(height: 20),
                      Expanded(child: rewardShowcase),
                      const SizedBox(height: 16),
                      motivationCard,
                      const SizedBox(height: 16),
                      claimButton,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Enhanced Day Card ─────────────────────────────────────────────────────────

class _DayCard extends StatefulWidget {
  final int day;
  final bool claimed;
  final bool isToday;
  final bool isFuture;
  final String rewardIcon;

  const _DayCard({
    required this.day,
    required this.claimed,
    required this.isToday,
    required this.isFuture,
    required this.rewardIcon,
  });

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    if (widget.isToday) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;

    if (widget.claimed) {
      bg = const Color(0xFF36ECDE).withValues(alpha: 0.18);
      border = const Color(0xFF36ECDE).withValues(alpha: 0.55);
      textColor = const Color(0xFF36ECDE);
    } else if (widget.isToday) {
      bg = _kGold.withValues(alpha: 0.15);
      border = _kGold;
      textColor = _kGold;
    } else {
      bg = const Color(0xFF0D1B2A);
      border = Colors.white.withValues(alpha: 0.10);
      textColor = Colors.white.withValues(alpha: 0.35);
    }

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 42,
      height: 60,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: widget.isToday ? 2 : 1),
        boxShadow: widget.isToday
            ? [BoxShadow(color: _kGold.withValues(alpha: 0.30), blurRadius: 10)]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'D${widget.day}',
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          widget.claimed
              ? const Icon(Icons.check_circle,
                  color: Color(0xFF36ECDE), size: 16)
              : Text(
                  widget.rewardIcon,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isFuture ? null : textColor,
                  ),
                ),
        ],
      ),
    );

    if (widget.isToday) {
      return AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) =>
            Transform.scale(scale: _pulse.value, child: child),
        child: card,
      );
    }
    return card;
  }
}
