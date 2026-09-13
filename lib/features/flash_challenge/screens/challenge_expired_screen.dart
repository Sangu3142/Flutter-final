// lib/features/flash_challenge/screens/challenge_expired_screen.dart
/// Purpose: Shown when the player navigates to the Flash Challenge
///          outside of an active window. Displays time until the next window.
/// Reads from: flashChallengeProvider
/// Writes to: nothing
/// Navigation: back via context.pop()
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/flash_challenge_provider.dart';
import '../../../core/theme.dart';

class ChallengeExpiredScreen extends ConsumerWidget {
  const ChallengeExpiredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next =
        ref.read(flashChallengeProvider.notifier).timeUntilNextWindow();

    String nextStr = '';
    if (next != null) {
      final h = next.inHours;
      final m = next.inMinutes.remainder(60);
      nextStr = h > 0 ? '${h}h ${m}m' : '${m}m';
    }

    return Scaffold(
      backgroundColor: kCoreNavy,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⏰', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),
              const Text(
                'Challenge Window Closed',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kCharcoalLight),
              ),
              const SizedBox(height: 12),
              Text(
                'Next flash challenge in $nextStr',
                style:
                    const TextStyle(color: kCharcoalLight, fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: kNeonMint, foregroundColor: kCoreNavy),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
