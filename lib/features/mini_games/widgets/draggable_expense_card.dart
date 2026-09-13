import 'package:flutter/material.dart';
import '../data/mini_game_data.dart';
import '../../../core/theme.dart';

class DraggableExpenseCard extends StatelessWidget {
  final ExpenseCard card;

  const DraggableExpenseCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Draggable<ExpenseCard>(
        data: card,
        // Feedback is its own layer driven by Overlay — wrap in Material so
        // text styling is correct and keep it in a RepaintBoundary.
        feedback: Material(
          color: Colors.transparent,
          child: RepaintBoundary(
            child: _CardBody(card: card, isDragging: true),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _CardBody(card: card),
        ),
        child: _CardBody(card: card),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  final ExpenseCard card;
  final bool isDragging;

  const _CardBody({required this.card, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 80,
      decoration: BoxDecoration(
        color: isDragging ? kNeonMint.withValues(alpha: 0.9) : kDeepNavy,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDragging ? kNeonMint : kNeonMint.withValues(alpha: 0.3)),
        boxShadow: isDragging
            ? const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.label,
            style: TextStyle(
              color: isDragging ? kCoreNavy : kCharcoal,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ZMW ${card.amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: isDragging ? kCoreNavy : kNeonMint,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
