import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/xp_boost_provider.dart';

class BoostTimerChip extends ConsumerStatefulWidget {
  const BoostTimerChip({super.key});

  @override
  ConsumerState<BoostTimerChip> createState() => _BoostTimerChipState();
}

class _BoostTimerChipState extends ConsumerState<BoostTimerChip> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(xpBoostProvider.notifier).tick();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boost = ref.watch(xpBoostProvider);
    if (!boost.isActive) return const SizedBox.shrink();

    final rem = boost.remaining;
    final mm = rem.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = rem.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1C40F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '⚡ ${mm}m ${ss}s',
        style: const TextStyle(
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
