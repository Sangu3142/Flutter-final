// lib/features/hearts/screens/hearts_depleted_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/hearts_provider.dart';
import '../../../core/theme.dart';
import '../../../core/tips.dart';

class HeartsDepletedScreen extends ConsumerStatefulWidget {
  const HeartsDepletedScreen({super.key});

  @override
  ConsumerState<HeartsDepletedScreen> createState() =>
      _HeartsDepletedScreenState();
}

class _HeartsDepletedScreenState extends ConsumerState<HeartsDepletedScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _entryCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;
  Timer? _countdownTimer;
  Duration _timeRemaining = Duration.zero;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entryCtrl.forward();

    _startCountdown();
  }

  void _startCountdown() {
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _started = true;
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final notifier = ref.read(heartsProvider.notifier);
    final remaining = notifier.timeUntilNextRefill();
    final hearts = ref.read(heartsProvider);
    if (!mounted) return;
    setState(() {
      _timeRemaining = remaining ?? Duration.zero;
    });
    if (_started && hearts.heartsCount > 0) {
      _countdownTimer?.cancel();
      if (context.mounted && context.canPop()) context.pop();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _readTip() async {
    final tip = kFinancialTips[DateTime.now().second % kFinancialTips.length];
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final claimed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kDeepNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kCharcoalLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Financial Tip',
                  style: TextStyle(
                    color: kNeonMint,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(tip,
                    style: const TextStyle(color: kCharcoal, fontSize: 15)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kNeonMint,
                    foregroundColor: kCoreNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Thanks! (+1 Heart)'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (claimed == true) {
      await ref.read(heartsProvider.notifier).gainHeart();
      if (!mounted) return;
      if (context.canPop()) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: kCoreNavy.withValues(alpha: 0.95),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: mq.padding.bottom + 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: mq.size.height - mq.padding.top - mq.padding.bottom,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RepaintBoundary(
                          child: AnimatedBuilder(
                            animation: _pulseCtrl,
                            builder: (_, child) => Transform.scale(
                              scale: 1.0 + _pulseCtrl.value * 0.15,
                              child: child,
                            ),
                            child: const Icon(Icons.heart_broken,
                                size: 100, color: Colors.red),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Out of Hearts!',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: kCharcoal),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Next heart in ${_formatDuration(_timeRemaining)}',
                          style: const TextStyle(
                              fontSize: 18, color: kCharcoalLight),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _readTip,
                          icon: const Icon(Icons.lightbulb_outline),
                          label: const Text('Read a Tip (+1 Heart)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kNeonMint,
                            foregroundColor: kCoreNavy,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            if (context.canPop()) context.pop();
                          },
                          child: const Text('Go Back',
                              style: TextStyle(color: kCharcoalLight)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
