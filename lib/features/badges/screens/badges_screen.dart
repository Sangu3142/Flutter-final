/// badges_screen.dart
/// Purpose: Displays all badges in a tabbed grid — All, Earned, Locked.
/// Reads from: badgeMapProvider
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/badges/models/badge_model.dart';
import 'package:zamwealth_quest/features/badges/providers/badge_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tier colours
// ─────────────────────────────────────────────────────────────────────────────

const _bronze = Color(0xFFCD7F32);
const _silver = Color(0xFFC0C0C0);
const _gold = kGold;
const _platinum = Color(0xFF7B61FF);

Color _tierColor(BadgeTier tier) {
  switch (tier) {
    case BadgeTier.bronze:
      return _bronze;
    case BadgeTier.silver:
      return _silver;
    case BadgeTier.gold:
      return _gold;
    case BadgeTier.platinum:
      return _platinum;
  }
}

String _tierLabel(BadgeTier tier) {
  switch (tier) {
    case BadgeTier.bronze:
      return 'Bronze';
    case BadgeTier.silver:
      return 'Silver';
    case BadgeTier.gold:
      return 'Gold';
    case BadgeTier.platinum:
      return 'Platinum';
  }
}

IconData _tierIcon(BadgeTier tier) {
  switch (tier) {
    case BadgeTier.bronze:
      return FontAwesomeIcons.medal;
    case BadgeTier.silver:
      return FontAwesomeIcons.medal;
    case BadgeTier.gold:
      return FontAwesomeIcons.trophy;
    case BadgeTier.platinum:
      return FontAwesomeIcons.gem;
  }
}

List<Color> _tierGradient(BadgeTier tier) {
  switch (tier) {
    case BadgeTier.bronze:
      return [const Color(0xFF3D2010), const Color(0xFF1A0D00)];
    case BadgeTier.silver:
      return [const Color(0xFF1E2A38), const Color(0xFF0D1520)];
    case BadgeTier.gold:
      return [const Color(0xFF2D2000), const Color(0xFF120D00)];
    case BadgeTier.platinum:
      return [const Color(0xFF1A1050), const Color(0xFF0A0620)];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badges Screen
// ─────────────────────────────────────────────────────────────────────────────

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeMap = ref.watch(badgeMapProvider);
    final earnedCount = badgeMap.values.where((v) => v).length;
    final totalCount = kAllBadges.length;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: kCoreNavy,
        appBar: AppBar(
          backgroundColor: kDeepNavy,
          title: Text(
            'My Badges',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: kCharcoal,
              fontSize: 18,
            ),
          ),
          bottom: TabBar(
            labelColor: kNeonMint,
            unselectedLabelColor: kCharcoalLight,
            indicatorColor: kNeonMint,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Earned'),
              Tab(text: 'Locked'),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
          children: [
            // Progress banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kDeepNavy, kCoreNavy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(
                  bottom: BorderSide(color: kNeonMint, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.trophy, color: kGold, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '$earnedCount / $totalCount Badges Earned',
                    style: GoogleFonts.poppins(
                      color: kCharcoal,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalCount > 0 ? earnedCount / totalCount : 0,
                        backgroundColor: kCharcoalLight.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(kNeonMint),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _BadgeGrid(badges: kAllBadges, badgeMap: badgeMap),
                  _BadgeGrid(
                    badges: kAllBadges.where((b) => badgeMap[b.id] == true).toList(),
                    badgeMap: badgeMap,
                  ),
                  _BadgeGrid(
                    badges: kAllBadges.where((b) => badgeMap[b.id] != true).toList(),
                    badgeMap: badgeMap,
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge Grid
// ─────────────────────────────────────────────────────────────────────────────

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.badges, required this.badgeMap});

  final List<AppBadge> badges;
  final Map<String, bool> badgeMap;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.lockOpen, color: kCharcoalLight, size: 36),
            const SizedBox(height: 12),
            Text(
              'Nothing here yet — keep playing!',
              style: GoogleFonts.poppins(color: kCharcoalLight, fontSize: 13),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      cacheExtent: 200,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.76,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final earned = badgeMap[badge.id] == true;
        return _StaggeredFadeIn(
          index: index,
          child: BadgeTile(
            badge: badge,
            earned: earned,
            onTap: () => _showDetail(context, badge, earned),
          ),
        );
      },
    );
  }

  void _showDetail(BuildContext context, AppBadge badge, bool earned) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BadgeDetailSheet(badge: badge, earned: earned),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge Tile
// ─────────────────────────────────────────────────────────────────────────────

class BadgeTile extends StatefulWidget {
  const BadgeTile({
    super.key,
    required this.badge,
    required this.earned,
    required this.onTap,
  });

  final AppBadge badge;
  final bool earned;
  final VoidCallback onTap;

  @override
  State<BadgeTile> createState() => _BadgeTileState();
}

class _BadgeTileState extends State<BadgeTile>
    with SingleTickerProviderStateMixin {
  AnimationController? _shimmer;
  Animation<double>? _shimmerAnim;

  @override
  void initState() {
    super.initState();
    if (widget.earned && widget.badge.tier == BadgeTier.platinum) {
      _shimmer = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..repeat(reverse: true);
      _shimmerAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_shimmer!);
    }
  }

  @override
  void dispose() {
    _shimmer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.earned) return _lockedTile(context);
    if (_shimmer != null) {
      return AnimatedBuilder(
        animation: _shimmer!,
        builder: (_, __) => _earnedTile(context, _shimmerAnim?.value ?? 0),
      );
    }
    return _earnedTile(context, 0);
  }

  Widget _earnedTile(BuildContext context, double shimmerT) {
    final tc = _tierColor(widget.badge.tier);
    final gradients = _tierGradient(widget.badge.tier);
    // Platinum gets an extra shimmer overlay
    final overlayAlpha = widget.badge.tier == BadgeTier.platinum
        ? (shimmerT * 0.18)
        : 0.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradients,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tc, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: tc.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (overlayAlpha > 0)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: _platinum.withValues(alpha: overlayAlpha),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tier icon badge in top-right corner
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6, right: 6),
                    child: FaIcon(
                      _tierIcon(widget.badge.tier),
                      color: tc,
                      size: 11,
                    ),
                  ),
                ),
                Text(widget.badge.emoji,
                    style: const TextStyle(fontSize: 30)),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    widget.badge.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: kCharcoal,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(_tierIcon(widget.badge.tier), color: tc, size: 8),
                    const SizedBox(width: 3),
                    Text(
                      _tierLabel(widget.badge.tier),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: tc,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _lockedTile(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A1220),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kCharcoalLight.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Opacity(
                  opacity: 0.25,
                  child: Text(widget.badge.emoji,
                      style: const TextStyle(fontSize: 30)),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: kCoreNavy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.lock,
                    color: kCharcoalLight,
                    size: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                widget.badge.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: kCharcoalLight.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                widget.badge.unlockedBy,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8,
                  color: kCharcoalLight.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class BadgeDetailSheet extends StatelessWidget {
  const BadgeDetailSheet({super.key, required this.badge, required this.earned});

  final AppBadge badge;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final tc = _tierColor(badge.tier);
    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.32,
      maxChildSize: 0.78,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kDeepNavy, kCoreNavy],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: tc.withValues(alpha: 0.4), width: 1),
        ),
        child: SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kCharcoalLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Emoji + confetti
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (earned)
                      RepaintBoundary(
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: CustomPaint(painter: _ConfettiPainter(tc)),
                        ),
                      ),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            tc.withValues(alpha: earned ? 0.25 : 0.05),
                            Colors.transparent,
                          ],
                        ),
                        border: earned
                            ? Border.all(color: tc.withValues(alpha: 0.6), width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Opacity(
                          opacity: earned ? 1.0 : 0.3,
                          child: Text(badge.emoji,
                              style: const TextStyle(fontSize: 48)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  badge.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kCharcoal,
                  ),
                ),
                const SizedBox(height: 10),

                // Tier chip with FA icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: tc.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: tc.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(_tierIcon(badge.tier), color: tc, size: 12),
                      const SizedBox(width: 6),
                      Text(
                        _tierLabel(badge.tier),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: tc,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  badge.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: kCharcoalLight,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),

                // Status pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: earned
                        ? kGreen.withValues(alpha: 0.12)
                        : kCharcoalLight.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: earned
                          ? kGreen.withValues(alpha: 0.5)
                          : kCharcoalLight.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        earned ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.lock,
                        color: earned ? kGreen : kCharcoalLight,
                        size: 13,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        earned ? 'Earned!' : badge.unlockedBy,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: earned ? kGreen : kCharcoalLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confetti Painter — 12 coloured dots in a radial fan
// ─────────────────────────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  final Color primaryColor;
  const _ConfettiPainter(this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const radius = 50.0;
    const dotRadius = 4.5;
    const count = 12;

    final colors = [
      primaryColor,
      kNeonMint,
      kGold,
      kGreen,
      kPrimaryBlue,
      primaryColor.withValues(alpha: 0.7),
    ];

    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i) / count;
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.primaryColor != primaryColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// Staggered fade-in for grid items (50ms delay per item, max 600ms)
// ─────────────────────────────────────────────────────────────────────────────

class _StaggeredFadeIn extends StatefulWidget {
  const _StaggeredFadeIn({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<_StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(_fade);

    final delayMs = (widget.index * 50).clamp(0, 600);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
