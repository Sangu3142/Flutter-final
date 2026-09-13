/// proverbs_screen.dart
/// Purpose: Wisdom Book — card grid of Zambian proverbs, theme filter, detail sheet.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/proverbs/providers/proverb_provider.dart';
import 'package:zamwealth_quest/models/zam_proverb.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class ProverbsScreen extends ConsumerStatefulWidget {
  const ProverbsScreen({super.key});

  @override
  ConsumerState<ProverbsScreen> createState() => _ProverbsScreenState();
}

class _ProverbsScreenState extends ConsumerState<ProverbsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  ProverbTheme? _filter;

  static const _bg = Color(0xFF0A1628);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1550),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  List<ZamProverb> get _filtered => _filter == null
      ? zamProverbs
      : zamProverbs.where((p) => p.theme == _filter).toList();

  void _setFilter(ProverbTheme? theme) {
    setState(() => _filter = theme);
    _animCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final unlockState = ref.watch(proverbUnlockProvider);
    final unlockedCount = unlockState.unlockedIds.length;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Wisdom Book',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$unlockedCount/$kTotalProverbs',
                style: const TextStyle(
                  color: Color(0xFF00BCD4),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: unlockState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _ProgressBar(unlockedCount: unlockedCount),
                  _FilterRow(selected: _filter, onSelect: _setFilter),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (ctx, constraints) {
                        final cols = constraints.maxWidth > 600 ? 3 : 2;
                        return GridView.builder(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            MediaQuery.of(context).padding.bottom + 16,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final proverb = filtered[i];
                            final unlocked =
                                unlockState.isUnlocked(proverb.id);
                            final start = (i * 0.033).clamp(0.0, 0.8);
                            final end = (start + 0.2).clamp(0.0, 1.0);
                            final anim = CurvedAnimation(
                              parent: _animCtrl,
                              curve: Interval(
                                start,
                                end,
                                curve: Curves.easeOut,
                              ),
                            );
                            return AnimatedBuilder(
                              animation: anim,
                              builder: (_, child) => Opacity(
                                opacity: anim.value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - anim.value)),
                                  child: child,
                                ),
                              ),
                              child: _ProverbCard(
                                proverb: proverb,
                                unlocked: unlocked,
                                onTap: unlocked
                                    ? () => _showDetail(context, proverb)
                                    : null,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showDetail(BuildContext context, ZamProverb proverb) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ProverbDetailSheet(proverb: proverb),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress Bar
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.unlockedCount});
  final int unlockedCount;

  static const _teal = Color(0xFF00BCD4);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: unlockedCount / kTotalProverbs,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(_teal),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            unlockedCount >= kTotalProverbs
                ? '🏆 Elder of Wisdom — all proverbs unlocked!'
                : '${kTotalProverbs - unlockedCount} proverbs locked — complete levels to unlock!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: unlockedCount >= kTotalProverbs ? _teal : Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Row
// ─────────────────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onSelect});
  final ProverbTheme? selected;
  final void Function(ProverbTheme?) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Chip(
            label: 'All',
            selected: selected == null,
            color: const Color(0xFF00BCD4),
            onTap: () => onSelect(null),
          ),
          ...ProverbTheme.values.map((theme) {
            final sample = zamProverbs.firstWhere((p) => p.theme == theme);
            return _Chip(
              label: sample.themeLabel,
              selected: selected == theme,
              color: sample.themeColor,
              onTap: () => onSelect(theme),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.white24,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : Colors.white54,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid Card
// ─────────────────────────────────────────────────────────────────────────────

class _ProverbCard extends StatefulWidget {
  const _ProverbCard({
    required this.proverb,
    required this.unlocked,
    required this.onTap,
  });
  final ZamProverb proverb;
  final bool unlocked;
  final VoidCallback? onTap;

  @override
  State<_ProverbCard> createState() => _ProverbCardState();
}

class _ProverbCardState extends State<_ProverbCard>
    with TickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _flipCtrl;
  late final Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnim = CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut);
    // If the card starts unlocked, skip the flip so we don't animate every
    // grid load — only run on locked → unlocked transitions.
    _flipCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_ProverbCard old) {
    super.didUpdateWidget(old);
    if (!old.unlocked && widget.unlocked) {
      _flipCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  Widget _cardFace(Widget child) {
    final color = widget.proverb.themeColor;
    return Container(
      decoration: BoxDecoration(
        color: widget.unlocked
            ? const Color(0xFF142038)
            : const Color(0xFF0D1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.unlocked
              ? color.withValues(alpha: 0.5)
              : Colors.white12,
        ),
        boxShadow: widget.unlocked
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final inner = widget.unlocked
        ? _Unlocked(proverb: widget.proverb)
        : _LockedShimmer(proverb: widget.proverb);

    return GestureDetector(
      onTapDown:
          widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp:
          widget.onTap != null ? (_) => setState(() => _pressed = false) : null,
      onTapCancel:
          widget.onTap != null ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: _flipAnim,
          builder: (_, child) {
            // Rotate 0→π around Y. When _flipAnim.value < 0.5 we'd be showing
            // the back, so we always render the front face but flipped only
            // during the animation to mimic a card flip reveal.
            final t = _flipAnim.value;
            final angle = (1 - t) * 3.14159; // π → 0
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: child,
            );
          },
          child: _cardFace(inner),
        ),
      ),
    );
  }
}

/// Locked card with an animated shimmer sweep — repaints only itself thanks
/// to RepaintBoundary at the call site.
class _LockedShimmer extends StatefulWidget {
  const _LockedShimmer({required this.proverb});
  final ZamProverb proverb;

  @override
  State<_LockedShimmer> createState() => _LockedShimmerState();
}

class _LockedShimmerState extends State<_LockedShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _shimmerCtrl,
        builder: (_, __) {
          final t = _shimmerCtrl.value;
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(-1 + 2 * t, -1 + 2 * t),
                end: Alignment(t, t),
                colors: const [
                  Colors.transparent,
                  Color(0x33FFFFFF),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            child: _Locked(proverb: widget.proverb),
          );
        },
      ),
    );
  }
}

class _Unlocked extends StatelessWidget {
  const _Unlocked({required this.proverb});
  final ZamProverb proverb;

  @override
  Widget build(BuildContext context) {
    final color = proverb.themeColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(proverb.emoji, style: const TextStyle(fontSize: 28)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Text(
                proverb.languageLabel,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          proverb.localText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.4,
            fontStyle: FontStyle.italic,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          proverb.english,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              proverb.themeLabel,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Locked extends StatelessWidget {
  const _Locked({required this.proverb});
  final ZamProverb proverb;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline, color: Colors.white24, size: 32),
        const SizedBox(height: 8),
        Text(
          proverb.id.toUpperCase(),
          style: const TextStyle(
            color: Colors.white24,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ProverbDetailSheet extends StatelessWidget {
  const _ProverbDetailSheet({required this.proverb});
  final ZamProverb proverb;

  @override
  Widget build(BuildContext context) {
    final color = proverb.themeColor;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF142038),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          28,
          20,
          28,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(proverb.emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Badge(
                    label: proverb.languageLabel.toUpperCase(), color: color),
                const SizedBox(width: 8),
                _Badge(
                    label: proverb.themeLabel.toUpperCase(),
                    color: color.withValues(alpha: 0.7)),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              proverb.localText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '"${proverb.english}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: color.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FINANCIAL LESSON',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    proverb.lesson,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(
                  text:
                      '${proverb.localText}\n"${proverb.english}"\n\n${proverb.lesson}',
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wisdom copied to clipboard!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy, color: color, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Copy Wisdom',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProverbTransitionCard — shown between level transitions. DO NOT MODIFY.
// ─────────────────────────────────────────────────────────────────────────────

/// Full-screen proverb transition card — shown between level transitions.
class ProverbTransitionCard extends ConsumerWidget {
  const ProverbTransitionCard({super.key, required this.onContinue});
  final VoidCallback onContinue;

  static const _teal  = Color(0xFF2D9B8A);
  static const _earth = Color(0xFF8B5E3C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(proverbProvider.notifier);
    final proverb  = notifier.nextProverb();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(proverbProvider.notifier).collectProverb(proverb.id);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),
      body: GestureDetector(
        onTap: onContinue,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0D9B5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _teal, width: 3),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _teal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _teal.withValues(alpha: 0.5)),
                    ),
                    child: Text(proverb.language.toUpperCase(),
                        style: const TextStyle(
                            color: _teal,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 24),
                  Text(proverb.original,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFF3A1F0A),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          height: 1.4)),
                  const SizedBox(height: 14),
                  Text('"${proverb.translation}"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: _earth.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          height: 1.4)),
                  const SizedBox(height: 20),
                  Container(height: 1, color: _teal.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _teal.withValues(alpha: 0.4)),
                    ),
                    child: Text(proverb.lesson,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFF2A1A0A),
                            fontSize: 13,
                            height: 1.5)),
                  ),
                  const SizedBox(height: 20),
                  Text('Tap anywhere to continue',
                      style: TextStyle(
                          color: _earth.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
