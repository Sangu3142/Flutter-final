import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/season_provider.dart';

class HolidayEventBanner extends ConsumerWidget {
  const HolidayEventBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final season = ref.watch(seasonProvider);
    if (!season.hasActiveHoliday) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF006400), Color(0xFFFF4500)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          const Text('🇿🇲', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  season.holidayName!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (season.isHolidayXpDay)
                  const Text(
                    '🎉 2× XP all day! Happy Independence Day!',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  )
                else
                  const Text(
                    'Special event active today!',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
