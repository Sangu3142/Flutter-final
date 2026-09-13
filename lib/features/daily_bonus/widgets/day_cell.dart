// lib/features/daily_bonus/widgets/day_cell.dart
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class DayCell extends StatelessWidget {
  final int day; // 1-7
  final bool claimed;
  final bool isToday;
  final bool isFuture;

  const DayCell({
    super.key,
    required this.day,
    required this.claimed,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Widget? icon;

    if (claimed) {
      bgColor = kGreen.withValues(alpha: 0.2);
      textColor = kGreen;
      icon = const Icon(Icons.check_circle, color: kGreen, size: 16);
    } else if (isToday) {
      bgColor = kNeonMint.withValues(alpha: 0.2);
      textColor = kNeonMint;
      icon = null;
    } else if (isFuture) {
      bgColor = kDeepNavy;
      textColor = kCharcoalLight;
      icon = null;
    } else {
      // Missed day
      bgColor = Colors.red.withValues(alpha: 0.1);
      textColor = Colors.red.withValues(alpha: 0.5);
      icon = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday ? kNeonMint : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isToday
            ? [BoxShadow(color: kNeonMint.withValues(alpha: 0.3), blurRadius: 8)]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Day\n$day',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(height: 2),
            icon,
          ],
        ],
      ),
    );
  }
}
