import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Large animated countdown number in Codystar (bulb-dot font).
///
/// Each tick the number pulses: scale 0.6 → 1.15 → 1.0.
/// Calls [onDone] when the counter reaches zero.
class CountdownWidget extends StatefulWidget {
  const CountdownWidget({
    super.key,
    required this.from,
    this.interval = const Duration(seconds: 1),
    this.onDone,
    this.onTick,
    this.fontSize = 140,
  });

  final int from;
  final Duration interval;
  final VoidCallback? onDone;
  final ValueChanged<int>? onTick;
  final double fontSize;

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget>
    with SingleTickerProviderStateMixin {
  late int _n;
  late AnimationController _pulse;
  late Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _n = widget.from;
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.15), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 80),
    ]).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeOut));
    _pulse.forward();
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownWidget old) {
    super.didUpdateWidget(old);
    if (old.from != widget.from) {
      _timer?.cancel();
      _n = widget.from;
      _pulse.forward(from: 0);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      widget.onTick?.call(_n);
      if (_n <= 1) {
        _timer?.cancel();
        setState(() => _n = 0);
        widget.onDone?.call();
        return;
      }
      setState(() => _n--);
      _pulse.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: Text(
        '$_n',
        style: GoogleFonts.codystar(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w700,
          color: AppColors.bulbOn,
          shadows: [
            Shadow(
              color: AppColors.bulbOn.withValues(alpha: 0.95),
              blurRadius: 12,
            ),
            Shadow(
              color: const Color(0xFFF58C1E).withValues(alpha: 0.5),
              blurRadius: 28,
            ),
          ],
        ),
      ),
    );
  }
}
