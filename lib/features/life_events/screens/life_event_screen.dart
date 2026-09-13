/// life_event_screen.dart
/// Purpose: Full-screen life event overlay — presents the event narrative,
///          two or three choice buttons, and reveals the financial lesson
///          after the player makes their choice.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/life_event.dart';
import '../providers/life_events_provider.dart';
import '../../../core/theme.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const Color _kNavy  = Color(0xFF0D1B2A);
const Color _kMint  = Color(0xFF36ECDE);
const Color _kGold  = Color(0xFFFFB703);
const Color _kGreen = Color(0xFF2BC48A);
const Color _kGray  = Color(0xFFE6E9EC);

Color _categoryColor(LifeEventCategory cat) => switch (cat) {
      LifeEventCategory.financial  => const Color(0xFF1A73E8),
      LifeEventCategory.family     => _kGold,
      LifeEventCategory.business   => _kGreen,
      LifeEventCategory.health     => const Color(0xFFE53935),
      LifeEventCategory.community  => const Color(0xFF9C6FDE),
    };

String _categoryLabel(LifeEventCategory cat) => switch (cat) {
      LifeEventCategory.financial  => 'FINANCIAL',
      LifeEventCategory.family     => 'FAMILY',
      LifeEventCategory.business   => 'BUSINESS',
      LifeEventCategory.health     => 'HEALTH',
      LifeEventCategory.community  => 'COMMUNITY',
    };

// ── Screen ────────────────────────────────────────────────────────────────────

class LifeEventScreen extends ConsumerStatefulWidget {
  const LifeEventScreen({super.key});

  @override
  ConsumerState<LifeEventScreen> createState() => _LifeEventScreenState();
}

class _LifeEventScreenState extends ConsumerState<LifeEventScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  LifeEventChoice? _chosenChoice;
  bool _revealing = false;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _choose(LifeEvent event, LifeEventChoice choice) async {
    if (_revealing) return;
    setState(() {
      _chosenChoice = choice;
      _revealing = true;
    });
    await ref.read(lifeEventsProvider.notifier).applyChoice(event, choice);
  }

  Future<void> _dismiss(LifeEvent event) async {
    await ref.read(lifeEventsProvider.notifier).dismissEvent(event);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lifeEventsProvider);
    final event = state.pendingEvent;

    if (event == null) {
      // Event was already dismissed — pop back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
      return const Scaffold(backgroundColor: Color(0xFF0D1B2A));
    }

    final accentColor = _categoryColor(event.category);

    return Scaffold(
      backgroundColor: kCoreNavy.withValues(alpha: 0.97),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar ───────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: accentColor.withValues(alpha: 0.50)),
                      ),
                      child: Text(
                        '⚡ LIFE EVENT · ${_categoryLabel(event.category)}',
                        style: GoogleFonts.orbitron(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    if (!_revealing)
                      IconButton(
                        icon: Icon(Icons.close,
                            color: _kGray.withValues(alpha: 0.55), size: 20),
                        onPressed: () => _dismiss(event),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Event emoji + title ───────────────────────────────────
                Center(
                  child: Text(event.emoji,
                      style: const TextStyle(fontSize: 60)),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    event.title,
                    style: GoogleFonts.rajdhani(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Narrative ─────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _kNavy,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: accentColor.withValues(alpha: 0.30),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.08),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Text(
                    event.narrative,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: _kGray,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Choices or Reveal ─────────────────────────────────────
                if (!_revealing) ...[
                  Text(
                    'WHAT DO YOU DO?',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _kMint,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...event.choices.map((choice) => _ChoiceCard(
                        choice: choice,
                        accentColor: accentColor,
                        onTap: () => _choose(event, choice),
                      )),
                ] else ...[
                  // ── Result reveal ─────────────────────────────────────
                  _RevealCard(
                    event: event,
                    choice: _chosenChoice!,
                    accentColor: accentColor,
                    onContinue: () {
                      if (mounted) context.pop();
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Choice Card ───────────────────────────────────────────────────────────────

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.choice,
    required this.accentColor,
    required this.onTap,
  });

  final LifeEventChoice choice;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.18),
                border: Border.all(color: accentColor.withValues(alpha: 0.60)),
              ),
              child: const Center(
                child: Icon(Icons.touch_app,
                    color: Colors.white, size: 15),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    choice.label,
                    style: GoogleFonts.rajdhani(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    choice.description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _kGray.withValues(alpha: 0.75),
                      height: 1.4,
                    ),
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

// ── Reveal Card ───────────────────────────────────────────────────────────────

class _RevealCard extends StatefulWidget {
  const _RevealCard({
    required this.event,
    required this.choice,
    required this.accentColor,
    required this.onContinue,
  });

  final LifeEvent event;
  final LifeEventChoice choice;
  final Color accentColor;
  final VoidCallback onContinue;

  @override
  State<_RevealCard> createState() => _RevealCardState();
}

class _RevealCardState extends State<_RevealCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  String _effectSummary() {
    final c = widget.choice;
    return switch (c.effect) {
      LifeEventEffect.walletGain    => '+ZMW ${c.effectAmount} to wallet',
      LifeEventEffect.walletLoss    => '-ZMW ${c.effectAmount} from wallet',
      LifeEventEffect.happinessGain => '+${c.effectAmount} family happiness',
      LifeEventEffect.happinessLoss => '-${c.effectAmount} family happiness',
      LifeEventEffect.healthGain    => '+${c.effectAmount ~/ 2} family happiness',
      LifeEventEffect.healthLoss    => '-${c.effectAmount ~/ 2} family happiness',
      LifeEventEffect.complianceGain => '+${c.effectAmount}% business compliance',
      LifeEventEffect.complianceLoss => '-${c.effectAmount}% business compliance',
      LifeEventEffect.none          => 'No financial impact',
    };
  }

  Color _effectColor() {
    final e = widget.choice.effect;
    if (e == LifeEventEffect.walletGain ||
        e == LifeEventEffect.happinessGain ||
        e == LifeEventEffect.healthGain ||
        e == LifeEventEffect.complianceGain) { return _kGreen; }
    if (e == LifeEventEffect.none) { return _kMint; }
    return const Color(0xFFE53935);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Chosen ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.40)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: _kGreen, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You chose: ${widget.choice.label}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Effect ────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _effectColor().withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _effectColor().withValues(alpha: 0.40)),
            ),
            child: Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  _effectSummary(),
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _effectColor(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Lesson ────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kMint.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kMint.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📰',
                        style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'FINANCIAL LESSON',
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _kMint,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.choice.lesson,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _kGray,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Continue button ───────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: widget.onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              child: Text(
                'Continue  →',
                style: GoogleFonts.rajdhani(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
