import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/avatar_config.dart';
import '../../../core/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

class AvatarWidget extends StatelessWidget {
  final String avatarId;
  final int auraLevel; // 0=none, 1=silver, 2=gold
  final double size;

  const AvatarWidget({
    super.key,
    required this.avatarId,
    this.auraLevel = 0,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final config = avatarConfigById(avatarId);

    Color? glowColor;
    double glowBlur = 0;
    if (auraLevel == 1) {
      glowColor = const Color(0xFFC0C0C0);
      glowBlur = 14;
    } else if (auraLevel >= 2) {
      glowColor = kGold;
      glowBlur = 20;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: glowColor != null
            ? [BoxShadow(color: glowColor.withValues(alpha: 0.65), blurRadius: glowBlur, spreadRadius: 4)]
            : null,
      ),
      child: ClipOval(
        child: CustomPaint(
          painter: _AvatarPainter(config: config),
          size: Size(size, size),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarPainter extends CustomPainter {
  final AvatarConfig config;
  const _AvatarPainter({required this.config});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Layout constants
    final headR = w * 0.295;
    final headCy = h * 0.415;

    // ── 1. Cream/warm-white background ──────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFF5EFE6),
    );

    // Subtle inner glow from avatar body color
    canvas.drawCircle(
      Offset(cx, h / 2),
      w / 2,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [
            config.bodyColor.withValues(alpha: 0.10),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // ── 2. Body / shirt ─────────────────────────────────────────────────────
    _drawBody(canvas, w, h, cx, headCy, headR);

    // ── 3. Neck ─────────────────────────────────────────────────────────────
    _drawNeck(canvas, cx, headCy, headR, w);

    // ── 4. Head shadow (depth) ──────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, headCy + headR * 0.06),
      headR * 1.04,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // ── 5. Head ─────────────────────────────────────────────────────────────
    _drawHead(canvas, cx, headCy, headR);

    // ── 6. Ears (before hair so hair overlaps) ───────────────────────────────
    if (config.hairStyle != HairStyle.hijab && config.hairStyle != HairStyle.keffiyeh) {
      _drawEar(canvas, Offset(cx - headR * 0.93, headCy + headR * 0.06), headR * 0.195);
      _drawEar(canvas, Offset(cx + headR * 0.93, headCy + headR * 0.06), headR * 0.195);
    }

    // ── 7. Hair / head covering ──────────────────────────────────────────────
    _drawHair(canvas, w, h, cx, headCy, headR);

    // ── 8. Beard (behind face details) ──────────────────────────────────────
    if (config.hasBeard) _drawBeard(canvas, cx, headCy, headR, w);

    // ── 9. Face features ────────────────────────────────────────────────────
    _drawEyebrows(canvas, cx, headCy, headR, w);
    _drawEyes(canvas, cx, headCy, headR);
    _drawNose(canvas, cx, headCy, headR, w);
    _drawMouth(canvas, cx, headCy, headR, w);
    _drawCheeks(canvas, cx, headCy, headR);

    // ── 10. Glasses (on top of everything) ──────────────────────────────────
    if (config.hasGlasses) _drawGlasses(canvas, cx, headCy, headR, w);
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  void _drawBody(Canvas canvas, double w, double h, double cx, double headCy, double headR) {
    final bodyTop = headCy + headR * 0.70;
    final bodyPaint = Paint()..color = config.bodyColor;

    // Rounded shoulder shape that fills the bottom of the circle
    final bodyPath = Path()
      ..moveTo(cx - w * 0.46, h)
      ..lineTo(cx - w * 0.46, bodyTop + w * 0.08)
      ..quadraticBezierTo(cx - w * 0.38, bodyTop, cx - w * 0.22, bodyTop)
      ..quadraticBezierTo(cx, bodyTop - w * 0.03, cx + w * 0.22, bodyTop)
      ..quadraticBezierTo(cx + w * 0.38, bodyTop, cx + w * 0.46, bodyTop + w * 0.08)
      ..lineTo(cx + w * 0.46, h)
      ..close();

    canvas.drawPath(bodyPath, bodyPaint);

    // Subtle collar shadow on shirt top
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 4),
    );
  }

  // ── Neck ───────────────────────────────────────────────────────────────────

  void _drawNeck(Canvas canvas, double cx, double headCy, double headR, double w) {
    if (config.hairStyle == HairStyle.hijab) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, headCy + headR * 0.76),
          width: w * 0.155,
          height: headR * 0.42,
        ),
        const Radius.circular(5),
      ),
      Paint()..color = config.skinTone,
    );
  }

  // ── Head ───────────────────────────────────────────────────────────────────

  void _drawHead(Canvas canvas, double cx, double headCy, double headR) {
    // Slightly oval (taller than wide) for a natural cartoon head
    canvas.save();
    canvas.translate(cx, headCy);
    canvas.scale(1.0, 1.07);
    canvas.drawCircle(Offset.zero, headR, Paint()..color = config.skinTone);
    canvas.restore();
  }

  // ── Ear ────────────────────────────────────────────────────────────────────

  void _drawEar(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(center, r, Paint()..color = config.skinTone);
    // Inner ear
    canvas.drawCircle(
      Offset(center.dx, center.dy + r * 0.06),
      r * 0.52,
      Paint()..color = _darken(config.skinTone, 0.08),
    );
  }

  // ── Hair ───────────────────────────────────────────────────────────────────

  void _drawHair(Canvas canvas, double w, double h, double cx, double headCy, double headR) {
    final hair = Paint()..color = config.hairColor;

    switch (config.hairStyle) {
      // ── Short neat (male) ─────────────────────────────────────────────
      case HairStyle.shortNeat:
        // Tight cap over top of head
        final capPath = Path()
          ..addArc(
            Rect.fromCircle(center: Offset(cx, headCy), radius: headR * 1.03),
            math.pi * 1.08,
            math.pi * 0.84,
          )
          ..lineTo(cx + headR * 0.80, headCy - headR * 0.10)
          ..lineTo(cx + headR * 0.82, headCy - headR * 0.02)
          ..quadraticBezierTo(cx, headCy - headR * 0.18, cx - headR * 0.82, headCy - headR * 0.02)
          ..close();
        canvas.drawPath(capPath, hair);
        break;

      // ── Afro ─────────────────────────────────────────────────────────
      case HairStyle.afro:
        // Large poofy circle
        canvas.drawCircle(Offset(cx, headCy - headR * 0.18), headR * 1.26, hair);
        // Bottom cap to merge with head cleanly
        canvas.drawRect(
          Rect.fromLTWH(cx - headR * 1.30, headCy, headR * 2.60, headR * 0.60),
          hair,
        );
        // Highlight sheen
        canvas.drawCircle(
          Offset(cx - headR * 0.30, headCy - headR * 0.70),
          headR * 0.30,
          Paint()..color = Colors.white.withValues(alpha: 0.08),
        );
        break;

      // ── Long wavy (female) ────────────────────────────────────────────
      case HairStyle.longWavy:
        // Top cap
        final wavyTop = Path()
          ..addArc(
            Rect.fromCircle(center: Offset(cx, headCy), radius: headR * 1.05),
            math.pi,
            math.pi,
          )
          ..lineTo(cx + headR * 1.05, headCy)
          ..close();
        canvas.drawPath(wavyTop, hair);

        // Left panel — wavy bottom
        final leftWave = Path()
          ..moveTo(cx - headR * 0.98, headCy - headR * 0.20)
          ..lineTo(cx - headR * 1.18, headCy + headR * 0.40)
          ..quadraticBezierTo(cx - headR * 1.28, headCy + headR * 0.80,
              cx - headR * 1.10, headCy + headR * 1.15)
          ..quadraticBezierTo(cx - headR * 0.90, headCy + headR * 1.40,
              cx - headR * 0.72, headCy + headR * 1.20)
          ..lineTo(cx - headR * 0.70, headCy + headR * 0.20)
          ..close();
        canvas.drawPath(leftWave, hair);

        // Right panel — wavy bottom
        final rightWave = Path()
          ..moveTo(cx + headR * 0.98, headCy - headR * 0.20)
          ..lineTo(cx + headR * 1.18, headCy + headR * 0.40)
          ..quadraticBezierTo(cx + headR * 1.28, headCy + headR * 0.80,
              cx + headR * 1.10, headCy + headR * 1.15)
          ..quadraticBezierTo(cx + headR * 0.90, headCy + headR * 1.40,
              cx + headR * 0.72, headCy + headR * 1.20)
          ..lineTo(cx + headR * 0.70, headCy + headR * 0.20)
          ..close();
        canvas.drawPath(rightWave, hair);

        // Highlight streak
        canvas.drawLine(
          Offset(cx - headR * 0.14, headCy - headR * 0.95),
          Offset(cx - headR * 0.06, headCy - headR * 0.30),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.18)
            ..strokeWidth = w * 0.032
            ..strokeCap = StrokeCap.round,
        );
        break;

      // ── Long straight (female) ────────────────────────────────────────
      case HairStyle.longStraight:
        // Top cap
        final straightTop = Path()
          ..addArc(
            Rect.fromCircle(center: Offset(cx, headCy), radius: headR * 1.04),
            math.pi,
            math.pi,
          )
          ..lineTo(cx + headR * 1.04, headCy)
          ..close();
        canvas.drawPath(straightTop, hair);

        // Left straight panel
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - headR * 1.14, headCy - headR * 0.10,
                headR * 0.28, headR * 1.45),
            const Radius.circular(10),
          ),
          hair,
        );

        // Right straight panel
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx + headR * 0.86, headCy - headR * 0.10,
                headR * 0.28, headR * 1.45),
            const Radius.circular(10),
          ),
          hair,
        );

        // Highlight streak
        canvas.drawLine(
          Offset(cx - headR * 0.10, headCy - headR * 0.96),
          Offset(cx - headR * 0.08, headCy - headR * 0.20),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.20)
            ..strokeWidth = w * 0.030
            ..strokeCap = StrokeCap.round,
        );
        break;

      // ── Medium curly ─────────────────────────────────────────────────
      case HairStyle.curlyMed:
        // Several overlapping circles
        for (final off in [
          Offset(cx, headCy - headR * 1.02),
          Offset(cx - headR * 0.58, headCy - headR * 0.82),
          Offset(cx + headR * 0.58, headCy - headR * 0.82),
          Offset(cx - headR * 0.92, headCy - headR * 0.32),
          Offset(cx + headR * 0.92, headCy - headR * 0.32),
          Offset(cx - headR * 0.68, headCy - headR * 1.02),
          Offset(cx + headR * 0.68, headCy - headR * 1.02),
        ]) {
          canvas.drawCircle(off, headR * 0.38, hair);
        }
        canvas.drawCircle(Offset(cx, headCy - headR * 0.60), headR * 0.58, hair);
        break;

      // ── Faded (male) ─────────────────────────────────────────────────
      case HairStyle.faded:
        // Low fade: only a strip on top
        final fadeTop = Path()
          ..addArc(
            Rect.fromCircle(center: Offset(cx, headCy), radius: headR * 1.02),
            math.pi * 1.12,
            math.pi * 0.76,
          )
          ..lineTo(cx, headCy - headR * 0.24)
          ..close();
        canvas.drawPath(fadeTop, hair);

        // Fade strip (stroke)
        canvas.drawPath(
          Path()
            ..addArc(
              Rect.fromCircle(center: Offset(cx, headCy), radius: headR * 1.01),
              math.pi * 1.12,
              math.pi * 0.76,
            ),
          Paint()
            ..color = config.hairColor
            ..strokeWidth = w * 0.055
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );
        break;

      // ── Hijab ─────────────────────────────────────────────────────────
      case HairStyle.hijab:
        // White/light hijab wrapping
        const hijabColor = Color(0xFFEFEFEF);
        const hijabAccent = Color(0xFFCFCFCF);

        // Main hijab shape — large rounded blob covering head and falling to shoulders
        final hijabPath = Path()
          ..addOval(Rect.fromCenter(
            center: Offset(cx, headCy - headR * 0.05),
            width: headR * 2.45,
            height: headR * 2.25,
          ));
        canvas.drawPath(hijabPath, Paint()..color = hijabColor);

        // Under-chin fold
        final foldPath = Path()
          ..moveTo(cx - headR * 0.68, headCy + headR * 0.62)
          ..quadraticBezierTo(cx, headCy + headR * 0.78, cx + headR * 0.68, headCy + headR * 0.62)
          ..quadraticBezierTo(cx + headR * 0.82, headCy + headR * 0.72, cx + headR * 0.90, headCy + headR * 0.85)
          ..quadraticBezierTo(cx, headCy + headR * 1.00, cx - headR * 0.90, headCy + headR * 0.85)
          ..quadraticBezierTo(cx - headR * 0.82, headCy + headR * 0.72, cx - headR * 0.68, headCy + headR * 0.62)
          ..close();
        canvas.drawPath(foldPath, Paint()..color = hijabAccent);

        // Face opening oval (cut out the skin area)
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, headCy - headR * 0.04),
            width: headR * 1.32,
            height: headR * 1.50,
          ),
          Paint()..color = config.skinTone,
        );

        // Hijab border/edge around face
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, headCy - headR * 0.04),
            width: headR * 1.32,
            height: headR * 1.50,
          ),
          Paint()
            ..color = hijabAccent
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.020,
        );
        break;

      // ── Keffiyeh ──────────────────────────────────────────────────────
      case HairStyle.keffiyeh:
        const kefColor = Color(0xFFF5F5F5);
        // Main cloth
        canvas.drawCircle(
          Offset(cx, headCy - headR * 0.10),
          headR * 1.18,
          Paint()..color = kefColor,
        );
        // Agal (black rope ring on top)
        canvas.drawCircle(
          Offset(cx, headCy - headR * 0.10),
          headR * 1.18,
          Paint()
            ..color = const Color(0xFF1A1A1A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.055,
        );
        canvas.drawCircle(
          Offset(cx, headCy - headR * 0.10),
          headR * 0.95,
          Paint()
            ..color = const Color(0xFF1A1A1A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.022,
        );
        // Face opening
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, headCy + headR * 0.04),
            width: headR * 1.30,
            height: headR * 1.45,
          ),
          Paint()..color = config.skinTone,
        );
        break;

      // ── Bun / topknot ────────────────────────────────────────────────
      case HairStyle.bun:
        // Side cap
        final bunCap = Path()
          ..addArc(
            Rect.fromCircle(center: Offset(cx, headCy), radius: headR * 1.04),
            math.pi,
            math.pi,
          )
          ..lineTo(cx + headR, headCy)
          ..close();
        canvas.drawPath(bunCap, hair);
        // Bun circle on top
        canvas.drawCircle(Offset(cx, headCy - headR * 1.10), headR * 0.36, hair);
        // Bun wrap ring
        canvas.drawCircle(
          Offset(cx, headCy - headR * 1.10),
          headR * 0.36,
          Paint()
            ..color = _lighten(config.hairColor, 0.15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.018,
        );
        break;

      // ── Pixie cut ─────────────────────────────────────────────────────
      case HairStyle.pixie:
        final pixiePath = Path()
          ..addArc(
            Rect.fromCircle(center: Offset(cx, headCy), radius: headR * 1.04),
            math.pi * 1.05,
            math.pi * 0.90,
          )
          ..lineTo(cx + headR * 0.88, headCy + headR * 0.14)
          ..quadraticBezierTo(cx, headCy + headR * 0.04, cx - headR * 0.88, headCy + headR * 0.14)
          ..close();
        canvas.drawPath(pixiePath, hair);
        break;
    }
  }

  // ── Eyebrows ───────────────────────────────────────────────────────────────

  void _drawEyebrows(Canvas canvas, double cx, double headCy, double headR, double w) {
    // Slightly darker than hair or skin-contrasting
    final browColor = config.hairColor == const Color(0xFFF5EFE6)
        ? const Color(0xFF5C3317)
        : config.hairColor;

    final browPaint = Paint()
      ..color = browColor.withValues(alpha: 0.85)
      ..strokeWidth = w * 0.028
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Left brow — slight arch
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx - headR * 0.30, headCy - headR * 0.27),
        width: headR * 0.42,
        height: headR * 0.16,
      ),
      math.pi,
      math.pi,
      false,
      browPaint,
    );
    // Right brow
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx + headR * 0.30, headCy - headR * 0.27),
        width: headR * 0.42,
        height: headR * 0.16,
      ),
      math.pi,
      math.pi,
      false,
      browPaint,
    );
  }

  // ── Eyes ───────────────────────────────────────────────────────────────────

  void _drawEyes(Canvas canvas, double cx, double headCy, double headR) {
    final leftCenter = Offset(cx - headR * 0.30, headCy - headR * 0.05);
    final rightCenter = Offset(cx + headR * 0.30, headCy - headR * 0.05);
    const eyeW = 1.0; // multiplier
    final ew = headR * 0.42 * eyeW;
    final eh = headR * 0.32 * eyeW;

    // White sclera
    for (final c in [leftCenter, rightCenter]) {
      canvas.drawOval(Rect.fromCenter(center: c, width: ew, height: eh),
          Paint()..color = Colors.white);
    }

    // Colored iris
    final irisPaint = Paint()..color = config.eyeColor;
    canvas.drawCircle(leftCenter, headR * 0.125, irisPaint);
    canvas.drawCircle(rightCenter, headR * 0.125, irisPaint);

    // Dark pupil
    final pupilPaint = Paint()..color = const Color(0xFF0A0604);
    canvas.drawCircle(leftCenter, headR * 0.070, pupilPaint);
    canvas.drawCircle(rightCenter, headR * 0.070, pupilPaint);

    // White highlight — large Duolingo-style dot
    final hiPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
        Offset(leftCenter.dx - headR * 0.044, leftCenter.dy - headR * 0.044),
        headR * 0.046, hiPaint);
    canvas.drawCircle(
        Offset(rightCenter.dx - headR * 0.044, rightCenter.dy - headR * 0.044),
        headR * 0.046, hiPaint);

    // Upper eyelid line
    final lidPaint = Paint()
      ..color = const Color(0xFF1A0A00).withValues(alpha: 0.35)
      ..strokeWidth = headR * 0.040
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final c in [leftCenter, rightCenter]) {
      canvas.drawArc(
        Rect.fromCenter(center: c, width: ew * 1.05, height: eh * 1.05),
        math.pi * 1.12,
        math.pi * 0.76,
        false,
        lidPaint,
      );
    }

    // Subtle eye outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF1A0A00).withValues(alpha: 0.18)
      ..strokeWidth = headR * 0.020
      ..style = PaintingStyle.stroke;
    for (final c in [leftCenter, rightCenter]) {
      canvas.drawOval(Rect.fromCenter(center: c, width: ew, height: eh), outlinePaint);
    }
  }

  // ── Nose ───────────────────────────────────────────────────────────────────

  void _drawNose(Canvas canvas, double cx, double headCy, double headR, double w) {
    // Two small nostril dots (flat vector style — very minimal)
    final nostrilPaint = Paint()
      ..color = _darken(config.skinTone, 0.14).withValues(alpha: 0.70);
    canvas.drawCircle(
        Offset(cx - headR * 0.085, headCy + headR * 0.24), headR * 0.055, nostrilPaint);
    canvas.drawCircle(
        Offset(cx + headR * 0.085, headCy + headR * 0.24), headR * 0.055, nostrilPaint);
  }

  // ── Mouth ──────────────────────────────────────────────────────────────────

  void _drawMouth(Canvas canvas, double cx, double headCy, double headR, double w) {
    final mouthPaint = Paint()
      ..color = _darken(config.skinTone, 0.28).withValues(alpha: 0.80)
      ..strokeWidth = w * 0.028
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Simple happy arc
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, headCy + headR * 0.42),
        width: headR * 0.46,
        height: headR * 0.24,
      ),
      0,
      math.pi,
      false,
      mouthPaint,
    );
  }

  // ── Cheeks ─────────────────────────────────────────────────────────────────

  void _drawCheeks(Canvas canvas, double cx, double headCy, double headR) {
    final blushPaint = Paint()
      ..color = const Color(0xFFFF8FA3).withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(
        Offset(cx - headR * 0.55, headCy + headR * 0.28), headR * 0.22, blushPaint);
    canvas.drawCircle(
        Offset(cx + headR * 0.55, headCy + headR * 0.28), headR * 0.22, blushPaint);
  }

  // ── Beard ──────────────────────────────────────────────────────────────────

  void _drawBeard(Canvas canvas, double cx, double headCy, double headR, double w) {
    final beardPaint = Paint()..color = config.hairColor.withValues(alpha: 0.90);

    // Short beard shape
    final beardPath = Path()
      ..moveTo(cx - headR * 0.54, headCy + headR * 0.44)
      ..quadraticBezierTo(cx - headR * 0.56, headCy + headR * 0.85,
          cx, headCy + headR * 0.92)
      ..quadraticBezierTo(cx + headR * 0.56, headCy + headR * 0.85,
          cx + headR * 0.54, headCy + headR * 0.44)
      ..quadraticBezierTo(cx + headR * 0.30, headCy + headR * 0.56,
          cx, headCy + headR * 0.58)
      ..quadraticBezierTo(cx - headR * 0.30, headCy + headR * 0.56,
          cx - headR * 0.54, headCy + headR * 0.44)
      ..close();
    canvas.drawPath(beardPath, beardPaint);

    // Moustache
    final moustachePath = Path()
      ..moveTo(cx - headR * 0.30, headCy + headR * 0.42)
      ..quadraticBezierTo(cx - headR * 0.16, headCy + headR * 0.52,
          cx, headCy + headR * 0.46)
      ..quadraticBezierTo(cx + headR * 0.16, headCy + headR * 0.52,
          cx + headR * 0.30, headCy + headR * 0.42)
      ..quadraticBezierTo(cx + headR * 0.14, headCy + headR * 0.48,
          cx, headCy + headR * 0.45)
      ..quadraticBezierTo(cx - headR * 0.14, headCy + headR * 0.48,
          cx - headR * 0.30, headCy + headR * 0.42)
      ..close();
    canvas.drawPath(moustachePath, beardPaint);
  }

  // ── Glasses ────────────────────────────────────────────────────────────────

  void _drawGlasses(Canvas canvas, double cx, double headCy, double headR, double w) {
    final eyeY = headCy - headR * 0.05;
    final lensW = headR * 0.44;
    final lensH = headR * 0.32;

    // Lens tint
    for (final dx in [-headR * 0.30, headR * 0.30]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + dx, eyeY), width: lensW, height: lensH),
        Paint()..color = const Color(0xFF1A73E8).withValues(alpha: 0.07),
      );
    }

    // Frame stroke
    final framePaint = Paint()
      ..color = const Color(0xFF1A2A3A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.027
      ..strokeJoin = StrokeJoin.round;

    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - headR * 0.30, eyeY), width: lensW, height: lensH),
        framePaint);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + headR * 0.30, eyeY), width: lensW, height: lensH),
        framePaint);

    // Bridge
    canvas.drawLine(
        Offset(cx - headR * 0.08, eyeY), Offset(cx + headR * 0.08, eyeY), framePaint);

    // Temples
    canvas.drawLine(
        Offset(cx - headR * 0.52, eyeY), Offset(cx - headR * 0.92, eyeY - headR * 0.04),
        framePaint);
    canvas.drawLine(
        Offset(cx + headR * 0.52, eyeY), Offset(cx + headR * 0.92, eyeY - headR * 0.04),
        framePaint);
  }

  // ── Colour helpers ─────────────────────────────────────────────────────────

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(_AvatarPainter old) => old.config.id != config.id;
}
