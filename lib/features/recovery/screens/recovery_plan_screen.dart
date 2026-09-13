/// recovery_plan_screen.dart
/// Purpose: Shown when the player's net worth goes negative. Provides
///          actionable steps to recover and a short financial lesson.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router.dart';
import '../../../features/networth/providers/networth_provider.dart';

class RecoveryPlanScreen extends ConsumerWidget {
  const RecoveryPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nw = ref.watch(netWorthProvider);
    final deficit = nw.netWorthZMW.abs();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        title: const Text('Your Recovery Plan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recovery Mode Active',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      'Current Net Worth: -ZMW $deficit',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Small consistent actions will turn this around.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('3 STEPS TO RECOVER',
                  style: TextStyle(
                      color: Color(0xFF36ECDE),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
              const SizedBox(height: 12),
              _actionCard(
                context,
                icon: Icons.school_outlined,
                title: 'Complete Level 1 simulations',
                subtitle: 'Earn ZamCoins by finishing simulations',
                buttonLabel: 'Go to Levels',
                onTap: () {
                  context.pop();
                  context.go(AppRoutes.levels);
                },
              ),
              const SizedBox(height: 12),
              _actionCard(
                context,
                icon: Icons.casino_outlined,
                title: 'Spin the wheel daily',
                subtitle: 'Earn up to 25 ZamCoins per day',
                buttonLabel: 'Spin Now',
                onTap: () {
                  context.pop();
                  context.push(AppRoutes.spin);
                },
              ),
              const SizedBox(height: 12),
              _actionCard(
                context,
                icon: Icons.credit_card_outlined,
                title: 'Pay off your highest-interest loan',
                subtitle: 'Reducing debt improves your net worth',
                buttonLabel: 'View Loans',
                onTap: () {
                  context.pop();
                  context.push(AppRoutes.loans);
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2BC48A).withValues(alpha: 0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Financial Lesson',
                        style: TextStyle(
                            color: Color(0xFF2BC48A),
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    SizedBox(height: 8),
                    Text(
                      'In real life, debt recovery requires consistent small actions. '
                      'The same principle applies here — earn a little, pay a little, daily.',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
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

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF36ECDE), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(buttonLabel,
                style: const TextStyle(
                    color: Color(0xFF36ECDE),
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
