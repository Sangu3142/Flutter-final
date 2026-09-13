import 'package:flutter/material.dart';

class BossHealthBar extends StatefulWidget {
  final int currentHp;
  final int maxHp;

  const BossHealthBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
  });

  @override
  State<BossHealthBar> createState() => _BossHealthBarState();
}

class _BossHealthBarState extends State<BossHealthBar> {
  double _previousPct = 1.0;

  @override
  void didUpdateWidget(BossHealthBar old) {
    super.didUpdateWidget(old);
    _previousPct = (old.currentHp / old.maxHp).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final pct = (widget.currentHp / widget.maxHp).clamp(0.0, 1.0);

    final (gradientColors, labelColor) = switch (pct) {
      > 0.50 => (
          const [Color(0xFF8B0000), Color(0xFFCC0000), Color(0xFFFF3030)],
          const Color(0xFFFF5050),
        ),
      > 0.25 => (
          const [Color(0xFF7A2800), Color(0xFFCC5500), Color(0xFFFF7700)],
          const Color(0xFFFF8800),
        ),
      _ => (
          const [Color(0xFF3D0000), Color(0xFF6B0000), Color(0xFF990000)],
          const Color(0xFFCC2020),
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Boss HP',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5),
            ),
            Text(
              '${widget.currentHp} / ${widget.maxHp}',
              style: TextStyle(
                  color: labelColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 14,
            color: const Color(0xFF0D0010),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: _previousPct, end: pct),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (_, value, __) => Stack(
                    children: [
                      Container(
                        width: totalWidth * value,
                        height: 14,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                      // Shine stripe
                      Positioned(
                        top: 0,
                        left: 0,
                        width: totalWidth * value,
                        height: 6,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.18),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
