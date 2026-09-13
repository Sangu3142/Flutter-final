// lib/features/flash_challenge/widgets/flash_challenge_banner.dart
/// Purpose: Collapsible banner shown on the dashboard when a Flash Challenge
///          window is active. Tapping navigates to /flash-challenge.
/// Reads from: flashChallengeProvider
/// Writes to: nothing
/// Navigation: → /flash-challenge
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/flash_challenge_provider.dart';
import '../../../core/router.dart';

class FlashChallengeBanner extends ConsumerWidget {
  const FlashChallengeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(flashChallengeProvider);
    if (!state.isActive) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push(AppRoutes.flashChallenge),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xCCEF5350), // kError @ 80 %
              Color(0xCCFB8500), // kWarning @ 80 %
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Text('⚡', style: TextStyle(fontSize: 24)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flash Challenge LIVE!',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  Text(
                    'Tap to compete for 2x XP + ZMW 50',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
