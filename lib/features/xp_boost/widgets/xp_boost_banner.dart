import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/xp_boost_provider.dart';

class XpBoostBanner extends ConsumerWidget {
  const XpBoostBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boost = ref.watch(xpBoostProvider);
    if (!boost.isActive) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚡ XP Boost active! All XP earned is doubled for 10 minutes.',
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: const Color(0xFFF1C40F),
        child: const Text(
          '⚡ 2× XP Active! Tap to learn more.',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
