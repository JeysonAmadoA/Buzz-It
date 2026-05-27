import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Oval ring of incandescent bulbs with a centered child widget.
///
/// Matches the prototype's `OvalBulbAnim` / `OvalBulbFrame` component.
/// Used on the Home screen to frame the "BUZZ IT" marquee.
class OvalBulbFrame extends StatelessWidget {
  const OvalBulbFrame({
    super.key,
    required this.child,
    this.width = 320,
    this.height = 180,
    this.count = 32,
    this.pattern = OvalBulbPattern.cascade,
  });

  final Widget child;
  final double width;
  final double height;
  final int count;
  final OvalBulbPattern pattern;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(width, height),
            painter: _OvalBulbPainter(count: count, pattern: pattern),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }
}

enum OvalBulbPattern { all, alt, cascade, chase }

class _OvalBulbPainter extends CustomPainter {
  _OvalBulbPainter({required this.count, required this.pattern});

  final int count;
  final OvalBulbPattern pattern;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width / 2 - 10;
    final ry = size.height / 2 - 10;

    // Dashed inner ellipse guide
    final guidePaint = Paint()
      ..color = AppColors.goldDeep.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: (rx - 8) * 2,
        height: (ry - 8) * 2,
      ),
      guidePaint,
    );

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2 - math.pi / 2;
      final x = cx + rx * math.cos(angle);
      final y = cy + ry * math.sin(angle);

      bool on;
      switch (pattern) {
        case OvalBulbPattern.all:
          on = true;
        case OvalBulbPattern.alt:
          on = i % 2 == 0;
        case OvalBulbPattern.chase:
          on = i % 3 != 0;
        case OvalBulbPattern.cascade:
          // Simulate cascade — all lit for the static frame
          on = true;
      }

      if (on) {
        // Glow
        canvas.drawCircle(
          Offset(x, y),
          6.5,
          Paint()
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
            ..color = AppColors.bulbOn.withValues(alpha: 0.6),
        );

        // Bulb body
        final shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [AppColors.bulbOnBright, AppColors.bulbOn, AppColors.bulbOnEdge],
          stops: [0.0, 0.4, 1.0],
        ).createShader(
            Rect.fromCircle(center: Offset(x, y), radius: 4.5));
        canvas.drawCircle(Offset(x, y), 4.5, Paint()..shader = shader);
      } else {
        canvas.drawCircle(Offset(x, y), 4.5, Paint()..color = AppColors.bulbOff);
      }

      // Stroke
      canvas.drawCircle(
        Offset(x, y),
        4.5,
        Paint()
          ..color = on
              ? AppColors.goldDeep.withValues(alpha: 0.9)
              : const Color(0xFF2A1C00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
    }
  }

  @override
  bool shouldRepaint(_OvalBulbPainter old) =>
      old.count != count || old.pattern != pattern;
}
