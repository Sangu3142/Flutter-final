import 'package:flutter/material.dart';
import '../data/mini_game_data.dart';
import '../../../core/theme.dart';

/// DropBucket
/// - Uses a `ValueNotifier<bool>` for hover state so DragTarget drag-move
///   updates don't trigger a `setState` (and therefore a full rebuild of
///   the parent subtree) on every drag frame.
/// - The visual is wrapped in an `AnimatedBuilder` that only rebuilds the
///   inner container when the hover flag changes.
class DropBucket extends StatefulWidget {
  final String label;
  final bool isNeed;
  final Future<void> Function(ExpenseCard card, bool correct) onDrop;

  const DropBucket({
    super.key,
    required this.label,
    required this.isNeed,
    required this.onDrop,
  });

  @override
  State<DropBucket> createState() => _DropBucketState();
}

class _DropBucketState extends State<DropBucket> {
  final ValueNotifier<bool> _hovering = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _hovering.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DragTarget<ExpenseCard>(
        onWillAcceptWithDetails: (_) {
          _hovering.value = true;
          return true;
        },
        onLeave: (_) => _hovering.value = false,
        onAcceptWithDetails: (details) {
          _hovering.value = false;
          final card = details.data;
          final correct = card.isNeed == widget.isNeed;
          widget.onDrop(card, correct);
        },
        builder: (_, __, ___) {
          return ValueListenableBuilder<bool>(
            valueListenable: _hovering,
            builder: (context, hovering, _) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                width: 140,
                height: 120,
                decoration: BoxDecoration(
                  color: hovering
                      ? (widget.isNeed
                          ? kGreen.withValues(alpha: 0.22)
                          : kError.withValues(alpha: 0.22))
                      : kDeepNavy,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hovering
                        ? (widget.isNeed ? kGreen : kError)
                        : kCharcoalLight.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: hovering
                      ? [
                          BoxShadow(
                            color: (widget.isNeed ? kGreen : kError)
                                .withValues(alpha: 0.35),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.isNeed ? '✅' : '🎭',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: kCharcoal,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
