import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';

const _encouragements = [
  'Ready to learn? 📚',
  'Let\'s beat the boss! ⚔️',
  'Your finances, your future! 💡',
  'One more quiz? 🎯',
  'Zamu believes in you! ✨',
];

class ZamuCompanionWidget extends StatefulWidget {
  const ZamuCompanionWidget({super.key});

  @override
  State<ZamuCompanionWidget> createState() => _ZamuCompanionWidgetState();
}

class _ZamuCompanionWidgetState extends State<ZamuCompanionWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;
  Timer? _msgTimer;
  int _msgIdx = 0;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    _msgTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() => _msgIdx = (_msgIdx + 1) % _encouragements.length);
      }
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _msgTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.coop),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kNeonMint.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _encouragements[_msgIdx],
              style: const TextStyle(color: kDeepNavy, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _bounceAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, -_bounceAnim.value),
              child: child,
            ),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F2A44),
                border: Border.all(color: kNeonMint, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: kNeonMint.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 24))),
            ),
          ),
        ],
      ),
    );
  }
}
