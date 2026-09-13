// lib/features/wallet/widgets/wallet_badge.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallet_provider.dart';
import '../../../core/theme.dart';

class WalletBadge extends ConsumerWidget {
  const WalletBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(walletProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          _AnimatedBalance(balance: balance),
        ],
      ),
    );
  }
}

/// Counts up/down to [balance] over 600ms with easeOutCubic.
/// Implemented as a StatefulWidget so the previous value can drive the tween.
class _AnimatedBalance extends StatefulWidget {
  const _AnimatedBalance({required this.balance});
  final int balance;

  @override
  State<_AnimatedBalance> createState() => _AnimatedBalanceState();
}

class _AnimatedBalanceState extends State<_AnimatedBalance> {
  late int _previous;

  @override
  void initState() {
    super.initState();
    _previous = widget.balance;
  }

  @override
  void didUpdateWidget(_AnimatedBalance old) {
    super.didUpdateWidget(old);
    _previous = old.balance;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: _previous.toDouble(),
        end: widget.balance.toDouble(),
      ),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) => Text(
        'ZMW ${value.round()}',
        style: const TextStyle(
          color: kGold,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
