import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum OrnamentPosition { topLeft, topRight, bottomLeft, bottomRight }

/// Theater corner flourish drawn with curved paths + dots.
/// Matches the prototype's `CornerOrnP` SVG component.
class CornerOrnament extends StatelessWidget {
  const CornerOrnament({
    super.key,
    this.position = OrnamentPosition.topLeft,
    this.size = 36,
    this.color = AppColors.gold,
  });

  final OrnamentPosition position;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _OrnamentPainter(position: position, color: color),
      ),
    );
  }
}

class _OrnamentPainter extends CustomPainter {
  _OrnamentPainter({required this.position, required this.color});

  final OrnamentPosition position;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Normalised to 40×40 viewport — scale to actual size
    final scale = size.width / 40;
    canvas.scale(scale, scale);

    // Mirror transforms to place ornament in the correct corner
    switch (position) {
      case OrnamentPosition.topLeft:
        break;
      case OrnamentPosition.topRight:
        canvas.translate(40, 0);
        canvas.scale(-1, 1);
      case OrnamentPosition.bottomLeft:
        canvas.translate(0, 40);
        canvas.scale(1, -1);
      case OrnamentPosition.bottomRight:
        canvas.translate(40, 40);
        canvas.scale(-1, -1);
    }

    final paint1 = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final paint2 = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()..color = color;

    // Main Q-curve
    final path1 = Path()
      ..moveTo(2, 38)
      ..quadraticBezierTo(2, 14, 10, 8)
      ..quadraticBezierTo(18, 4, 28, 4);
    canvas.drawPath(path1, paint1);

    // Inner echo curve
    final path2 = Path()
      ..moveTo(6, 38)
      ..quadraticBezierTo(6, 18, 12, 12)
      ..quadraticBezierTo(18, 8, 30, 8);
    canvas.drawPath(path2, paint2);

    // End dot
    canvas.drawCircle(const Offset(30, 4), 2, dotPaint);

    // Small flourish
    final flourish = Path()
      ..moveTo(14, 26)
      ..quadraticBezierTo(18, 24, 20, 22)
      ..quadraticBezierTo(22, 20, 22, 16);
    canvas.drawPath(flourish, paint2);

    canvas.drawCircle(const Offset(22, 16), 1.4, dotPaint);
  }

  @override
  bool shouldRepaint(_OrnamentPainter old) =>
      old.position != position || old.color != color;
}
