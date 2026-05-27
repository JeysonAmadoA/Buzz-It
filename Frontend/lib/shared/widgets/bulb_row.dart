import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Bulb illumination patterns for rows and borders.
enum BulbRowMode { all, alt, chase, off }

/// Horizontal row of small incandescent bulbs used as decorative perimeter borders.
///
/// Matches the prototype's `.pm-row` / `.FrameBulbRow` component.
class BulbRowWidget extends StatefulWidget {
  const BulbRowWidget({
    super.key,
    this.count = 16,
    this.mode = BulbRowMode.alt,
    this.bulbSize = 7.0,
  });

  final int count;
  final BulbRowMode mode;
  final double bulbSize;

  @override
  State<BulbRowWidget> createState() => _BulbRowWidgetState();
}

class _BulbRowWidgetState extends State<BulbRowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _chaseIndex = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.mode == BulbRowMode.chase) _startChase();
  }

  @override
  void didUpdateWidget(BulbRowWidget old) {
    super.didUpdateWidget(old);
    if (old.mode != widget.mode) {
      _ctrl.stop();
      _ctrl.reset();
      if (widget.mode == BulbRowMode.chase) _startChase();
    }
  }

  void _startChase() {
    _ctrl.addListener(() {
      final next = (_ctrl.value * widget.count).floor() % widget.count;
      if (next != _chaseIndex) setState(() => _chaseIndex = next);
    });
    _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _isOn(int i) {
    switch (widget.mode) {
      case BulbRowMode.all:
        return true;
      case BulbRowMode.alt:
        return i % 2 == 0;
      case BulbRowMode.off:
        return false;
      case BulbRowMode.chase:
        final window = (widget.count * 0.28).round();
        final dist = (i - _chaseIndex).abs();
        final wrap = widget.count - dist;
        return dist.compareTo(window) <= 0 || wrap.compareTo(window) <= 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.count, (i) {
          final on = _isOn(i);
          return Container(
            width: widget.bulbSize,
            height: widget.bulbSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: on ? null : AppColors.bulbOff,
              gradient: on
                  ? const RadialGradient(
                      center: Alignment(-0.3, -0.3),
                      colors: [
                        AppColors.bulbOnBright,
                        AppColors.bulbOn,
                        AppColors.bulbOnEdge,
                      ],
                      stops: [0.0, 0.35, 1.0],
                    )
                  : null,
              boxShadow: on
                  ? [
                      BoxShadow(
                        color: AppColors.bulbOn.withValues(alpha: 0.7),
                        blurRadius: 4,
                      )
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
