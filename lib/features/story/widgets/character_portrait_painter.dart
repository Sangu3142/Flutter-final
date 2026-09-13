import 'package:flutter/material.dart';

class CharacterPortraitPainter extends CustomPainter {
  final String speakerName;
  final bool happy;

  const CharacterPortraitPainter({required this.speakerName, this.happy = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.4;

    // Skin tone circle
    paint.color = const Color(0xFFD4956B);
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // Eyes
    paint
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.3, cy - r * 0.1), r * 0.1, paint);
    canvas.drawCircle(Offset(cx + r * 0.3, cy - r * 0.1), r * 0.1, paint);

    // Mouth
    paint
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final mouthRect = Rect.fromCenter(
      center: Offset(cx, cy + r * 0.2),
      width: r * 0.5,
      height: r * 0.3,
    );
    canvas.drawArc(
      mouthRect,
      happy ? 0 : 3.14,
      happy ? 3.14 : -3.14,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CharacterPortraitPainter old) =>
      old.speakerName != speakerName || old.happy != happy;
}

class CharacterPortrait extends StatelessWidget {
  final String speakerName;
  final bool happy;

  const CharacterPortrait({
    super.key,
    required this.speakerName,
    this.happy = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: CustomPaint(
            painter: CharacterPortraitPainter(
                speakerName: speakerName, happy: happy),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          speakerName,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
