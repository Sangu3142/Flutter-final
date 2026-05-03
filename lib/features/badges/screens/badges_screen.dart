/// badges_screen.dart
/// Purpose: Displays all badges in a tabbed grid — All, Earned, Locked.
/// Reads from: badgeMapProvider
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
const _platinum = Color(0xFFE5E4E2);

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
        backgroundColor: kCream,
        appBar: AppBar(
          backgroundColor: kCopper,
          title: Text(
            'My Badges',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Earned'),
              Tab(text: 'Locked'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Earned count banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: kGreen,
              child: Text(
                '$earnedCount / $totalCount Badges Earned',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
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
        child: Text(
          'Nothing here yet!',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: kCharcoalLight),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final earned = badgeMap[badge.id] == true;
        return BadgeTile(
          badge: badge,
          earned: earned,
          onTap: () => _showDetail(context, badge, earned),
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
  Animation<Color?>? _shimmerColor;

  @override
  void initState() {
    super.initState();
    if (widget.earned && widget.badge.tier == BadgeTier.platinum) {
      _shimmer = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..repeat(reverse: true);
      _shimmerColor = ColorTween(
        begin: Colors.white,
        end: kGold.withValues(alpha: 0.2),
      ).animate(_shimmer!);
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
        builder: (_, __) => _earnedTile(context, _shimmerColor?.value),
      );
    }
    return _earnedTile(context, null);
  }

  Widget _earnedTile(BuildContext context, Color? shimmerBg) {
    final tc = _tierColor(widget.badge.tier);
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: shimmerBg ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tc, width: 2),
          boxShadow: [
            BoxShadow(
              color: tc.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.badge.emoji,
                style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                widget.badge.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: kCharcoal,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _tierLabel(widget.badge.tier),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: tc,
              ),
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
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kCharcoalLight.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Opacity(
                  opacity: 0.5,
                  child: Text(widget.badge.emoji,
                      style: const TextStyle(fontSize: 32)),
                ),
                const Text('🔒', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                widget.badge.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: kCharcoalLight,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                widget.badge.unlockedBy,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 8, color: kCharcoalLight),
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
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.75,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CustomPaint(painter: _ConfettiPainter()),
                      ),
                    Text(badge.emoji, style: const TextStyle(fontSize: 64)),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  badge.title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kCharcoal,
                  ),
                ),
                const SizedBox(height: 10),

                // Tier chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: tc.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: tc),
                  ),
                  child: Text(
                    _tierLabel(badge.tier),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: tc == _platinum ? kCharcoalLight : tc,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  badge.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: kCharcoal,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      earned ? '✅ Earned' : '🔒 ${badge.unlockedBy}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: earned ? kGreen : kCharcoalLight,
                      ),
                    ),
                  ],
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
  static const _colors = [
    Color(0xFFFFD700),
    Color(0xFFCD7F32),
    Color(0xFF2E8B57),
    Color(0xFFB87333),
    Color(0xFFC0C0C0),
    Color(0xFFE57C00),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const radius = 48.0;
    const dotRadius = 5.0;
    const count = 12;

    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i) / count;
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      final paint = Paint()
        ..color = _colors[i % _colors.length]
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
