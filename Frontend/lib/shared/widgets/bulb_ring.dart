import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animation modes for the circular bulb ring around the buzzer.
enum BulbRingMode { off, alt, allOn, cascadeOn, chase, flash }

/// Circular ring of incandescent bulbs drawn around a child widget.
///
/// Animates according to [mode]:
/// - [BulbRingMode.off]        – all bulbs dark
/// - [BulbRingMode.alt]        – alternating on/off (static)
/// - [BulbRingMode.allOn]      – all bulbs bright (static)
/// - [BulbRingMode.cascadeOn]  – bulbs light up sequentially then stay on
/// - [BulbRingMode.chase]      – rotating bright segment (loop)
/// - [BulbRingMode.flash]      – all bulbs pulse together (loop)
class BulbRingWidget extends StatefulWidget {
  const BulbRingWidget({
    super.key,
    required this.child,
    this.size = 260,
    this.count = 22,
    this.mode = BulbRingMode.off,
    this.bulbRadius = 6,
    this.startKey,
  });

  final Widget child;
  final double size;
  final int count;
  final BulbRingMode mode;
  final double bulbRadius;

  /// Changing this value restarts cascade / chase animations.
  final Object? startKey;

  @override
  State<BulbRingWidget> createState() => _BulbRingWidgetState();
}

class _BulbRingWidgetState extends State<BulbRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _cascadeProgress = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
    _setupAnimation();
  }

  @override
  void didUpdateWidget(BulbRingWidget old) {
    super.didUpdateWidget(old);
    if (old.mode != widget.mode || old.startKey != widget.startKey) {
      _cascadeProgress = 0;
      _ctrl.stop();
      _ctrl.reset();
      _setupAnimation();
    }
  }

  void _setupAnimation() {
    switch (widget.mode) {
      case BulbRingMode.chase:
        _ctrl.duration = const Duration(milliseconds: 1600);
        _ctrl.repeat();
      case BulbRingMode.flash:
        _ctrl.duration = const Duration(milliseconds: 600);
        _ctrl.repeat(reverse: true);
      case BulbRingMode.cascadeOn:
        _ctrl.duration = Duration(milliseconds: widget.count * 40);
        _ctrl.addListener(() {
          final next =
              (_ctrl.value * widget.count).floor().clamp(0, widget.count);
          if (next != _cascadeProgress) {
            setState(() => _cascadeProgress = next);
          }
        });
        _ctrl.forward();
      default:
        break;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _isOn(int i) {
    switch (widget.mode) {
      case BulbRingMode.off:
        return false;
      case BulbRingMode.alt:
        return i % 2 == 0;
      case BulbRingMode.allOn:
        return true;
      case BulbRingMode.cascadeOn:
        return i < _cascadeProgress;
      case BulbRingMode.chase:
        // Rotating window of ~30% of bulbs
        final pos = (_ctrl.value * widget.count) % widget.count;
        final dist = (i - pos).abs() % widget.count;
        final wrap = widget.count - dist;
        return math.min(dist, wrap) < (widget.count * 0.28);
      case BulbRingMode.flash:
        return _ctrl.value > 0.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _BulbRingPainter(
                  count: widget.count,
                  isOn: _isOn,
                  bulbRadius: widget.bulbRadius,
                  flashBrightness: widget.mode == BulbRingMode.flash
                      ? _ctrl.value
                      : 1.0,
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class _BulbRingPainter extends CustomPainter {
  _BulbRingPainter({
    required this.count,
    required this.isOn,
    required this.bulbRadius,
    this.flashBrightness = 1.0,
  });

  final int count;
  final bool Function(int) isOn;
  final double bulbRadius;
  final double flashBrightness;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2 - bulbRadius - 2;

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2 - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      final on = isOn(i);

      if (on) {
        // Glowing bulb — radial gradient + blur shadow
        final glowPaint = Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
          ..color = AppColors.bulbOn.withValues(alpha: 0.7 * flashBrightness);
        canvas.drawCircle(Offset(x, y), bulbRadius + 2, glowPaint);

        final shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          colors: [
            AppColors.bulbOnBright,
            AppColors.bulbOn,
            AppColors.bulbOnEdge,
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(x, y),
          radius: bulbRadius,
        ));

        canvas.drawCircle(
          Offset(x, y),
          bulbRadius,
          Paint()..shader = shader,
        );
      } else {
        // Dim bulb
        canvas.drawCircle(
          Offset(x, y),
          bulbRadius,
          Paint()..color = AppColors.bulbOff,
        );
      }

      // Stroke
      canvas.drawCircle(
        Offset(x, y),
        bulbRadius,
        Paint()
          ..color = on
              ? AppColors.goldDeep.withValues(alpha: 0.8)
              : const Color(0xFF2A1C00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
    }
  }

  @override
  bool shouldRepaint(_BulbRingPainter old) =>
      old.count != count ||
      old.bulbRadius != bulbRadius ||
      old.flashBrightness != flashBrightness;
}
