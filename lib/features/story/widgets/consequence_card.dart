import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../models/dialogue_moment.dart';

class ConsequenceCard extends StatelessWidget {
  final DialogueOption option;
  final VoidCallback onDismiss;

  const ConsequenceCard({
    super.key,
    required this.option,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D3B2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kNeonMint, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '📊 Financial Outcome',
                style: TextStyle(
                  color: kNeonMint,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                option.financialConsequence,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '+${option.xpDelta} XP',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kNeonMint),
                onPressed: onDismiss,
                child: const Text(
                  'Continue Story',
                  style: TextStyle(
                      color: kDeepNavy, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
