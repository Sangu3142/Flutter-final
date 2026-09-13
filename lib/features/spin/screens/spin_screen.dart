// lib/features/spin/screens/spin_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/spin_provider.dart';
import '../widgets/spin_wheel_painter.dart';
import '../../wallet/widgets/wallet_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';

class SpinScreen extends ConsumerStatefulWidget {
  const SpinScreen({super.key});

  @override
  ConsumerState<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends ConsumerState<SpinScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinCtrl;
  late AnimationController _resultPopCtrl;
  late Animation<double> _resultPopAnim;
  Animation<double> _rotationAnim = const AlwaysStoppedAnimation<double>(0);
  late ConfettiController _confettiCtrl;
  double _currentRotation = 0;
  bool _isSpinning = false;
  int _spinCount = 0;
  String? _resultLabel;
  Timer? _countdownTimer;
  Duration _timeUntilNextSpin = Duration.zero;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(vsync: this);
    _resultPopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _resultPopAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _resultPopCtrl, curve: Curves.easeOut));
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));
    _initCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _spinCtrl.dispose();
    _resultPopCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  void _initCountdown() {
    _calculateTimeRemaining();
    if (_timeUntilNextSpin.inSeconds > 0) {
      _startCountdownTimer();
    }
  }

  void _calculateTimeRemaining() {
    final user = ref.read(currentUserProvider);
    if (user == null || user.spinLastDate == null) {
      _timeUntilNextSpin = Duration.zero;
      return;
    }

    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (user.spinLastDate != todayStr) {
      _timeUntilNextSpin = Duration.zero;
      return;
    }

    final midnight = DateTime(today.year, today.month, today.day + 1);
    final remaining = midnight.difference(today);
    _timeUntilNextSpin = remaining.isNegative ? Duration.zero : remaining;
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _countdownTimer?.cancel();
        return;
      }
      if (_timeUntilNextSpin.inSeconds <= 0) {
        _countdownTimer?.cancel();
        setState(() => _timeUntilNextSpin = Duration.zero);
      } else {
        setState(() {
          _timeUntilNextSpin -= const Duration(seconds: 1);
        });
      }
    });
  }

  void _spin() {
    if (_isSpinning) return;
    final notifier = ref.read(spinProvider.notifier);
    final winnerIndex = notifier.computeWinner(_spinCount);
    _spinCount++;

    const segmentAngle = 2 * pi / 8;
    final targetSegmentRotation = (8 - winnerIndex) * segmentAngle;
    final totalRotation = _currentRotation +
        (6 * 2 * pi) +
        targetSegmentRotation -
        (_currentRotation % (2 * pi));

    _spinCtrl.duration = const Duration(milliseconds: 3500);
    _rotationAnim = Tween<double>(
      begin: _currentRotation,
      end: totalRotation,
    ).animate(CurvedAnimation(
      parent: _spinCtrl,
      curve: Curves.decelerate,
    ));

    setState(() {
      _isSpinning = true;
      _resultLabel = null;
    });

    _spinCtrl.forward(from: 0).then((_) async {
      _currentRotation = totalRotation;
      await notifier.applyWin(winnerIndex);
      if (mounted) {
        setState(() {
          _isSpinning = false;
          _resultLabel = kWheelSegments[winnerIndex]['label'] as String;
        });
        _resultPopCtrl.forward(from: 0);
        _confettiCtrl.play();
        _calculateTimeRemaining();
        if (_timeUntilNextSpin.inSeconds > 0) {
          _startCountdownTimer();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final spinState = ref.watch(spinProvider);

    return Scaffold(
      backgroundColor: kCoreNavy,
      appBar: AppBar(
        backgroundColor: kCoreNavy,
        title: const Text('Spin the Wheel', style: TextStyle(color: kCharcoal)),
        actions: const [WalletBadge(), SizedBox(width: 12)],
      ),
      body: Stack(
        children: [
          // ── Main layout: wheel centered, actions at bottom ──────────────
          Column(
            children: [
              // Wheel + arrow — size adapts to available space in landscape
              Expanded(
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final wheelSize =
                        (constraints.maxHeight - 48).clamp(80.0, 300.0);
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_drop_down,
                              color: kGold,
                              size: (40 * wheelSize / 300).clamp(20.0, 40.0)),
                          RepaintBoundary(
                            child: SizedBox(
                              width: wheelSize,
                              height: wheelSize,
                              child: AnimatedBuilder(
                                animation: _spinCtrl,
                                builder: (_, __) => CustomPaint(
                                  painter: SpinWheelPainter(
                                    rotation: _spinCtrl.isAnimating
                                        ? _rotationAnim.value
                                        : _currentRotation,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Result card (shown after spin) ─────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _resultLabel != null
                    ? Padding(
                        key: const ValueKey('result'),
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: ScaleTransition(
                          scale: _resultPopAnim,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: kDeepNavy,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: kGold,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: kGold.withValues(alpha: 0.45),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              '🎉 You won: $_resultLabel!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: kGold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey('no-result')),
              ),

              // ── SPIN button or countdown ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: (_timeUntilNextSpin.inSeconds > 0)
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined,
                              color: kCharcoalLight, size: 28),
                          const SizedBox(height: 6),
                          Text(
                            'Next spin in ${_formatDuration(_timeUntilNextSpin)}',
                            style: const TextStyle(
                                color: kCharcoalLight, fontSize: 16),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              (_isSpinning || spinState.canSpin == false)
                                  ? null
                                  : _spin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kNeonMint,
                            foregroundColor: kCoreNavy,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _isSpinning ? 'Spinning...' : 'SPIN!',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 32),
            ],
          ),

          // ── Confetti fires downward from top center ─────────────────────
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirection: pi / 2, // downward
              blastDirectionality: BlastDirectionality.directional,
              colors: const [kNeonMint, kGold, kGreen],
              numberOfParticles: 40,
              emissionFrequency: 0.08,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
