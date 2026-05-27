import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Size tiers matching the prototype's CSS classes (sm → giant).
enum MarqueeSize { tiny, sm, md, lg, xl, huge, giant }

extension _MarqueeSizeExt on MarqueeSize {
  double get fontSize => const {
        MarqueeSize.tiny  : 14.0,
        MarqueeSize.sm    : 20.0,
        MarqueeSize.md    : 28.0,
        MarqueeSize.lg    : 40.0,
        MarqueeSize.xl    : 56.0,
        MarqueeSize.huge  : 76.0,
        MarqueeSize.giant : 96.0,
      }[this]!;
}

/// Letter-by-letter animated Codystar marquee text.
///
/// Characters light up sequentially like incandescent bulbs on a marquee sign.
/// Pass a new [restartKey] to re-trigger the animation.
class AnimatedMarquee extends StatefulWidget {
  const AnimatedMarquee({
    super.key,
    required this.text,
    this.size = MarqueeSize.md,
    this.stagger = 70,
    this.dim = false,
    this.restartKey,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final MarqueeSize size;

  /// Milliseconds between each character lighting up.
  final int stagger;

  /// When true the "on" characters use a dimmer gold (used for locked/late states).
  final bool dim;

  /// Changing this value restarts the light-up animation from scratch.
  final Object? restartKey;

  final TextAlign textAlign;

  @override
  State<AnimatedMarquee> createState() => _AnimatedMarqueeState();
}

class _AnimatedMarqueeState extends State<AnimatedMarquee> {
  int _progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(AnimatedMarquee old) {
    super.didUpdateWidget(old);
    if (old.restartKey != widget.restartKey ||
        old.text != widget.text) {
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    setState(() => _progress = 0);
    int i = 0;
    _timer = Timer.periodic(Duration(milliseconds: widget.stagger), (t) {
      i++;
      if (mounted) setState(() => _progress = i);
      if (i >= widget.text.length) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.size.fontSize;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 0,
      children: List.generate(widget.text.length, (idx) {
        final ch = widget.text[idx];
        final isOn = idx < _progress;
        final isSpace = ch == ' ';

        return SizedBox(
          width: isSpace ? fontSize * 0.3 : null,
          child: Text(
            isSpace ? ' ' : ch,
            style: GoogleFonts.codystar(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: isOn
                  ? (widget.dim ? const Color(0xFFB08A3A) : AppColors.bulbOn)
                  : const Color(0xFF5A4628),
              shadows: isOn && !widget.dim
                  ? [
                      Shadow(
                        color: AppColors.bulbOn.withValues(alpha: 0.95),
                        blurRadius: 4,
                      ),
                      Shadow(
                        color: const Color(0xFFF58C28).withValues(alpha: 0.55),
                        blurRadius: 12,
                      ),
                    ]
                  : isOn && widget.dim
                      ? [
                          Shadow(
                            color: const Color(0xFFB08A3A).withValues(alpha: 0.5),
                            blurRadius: 3,
                          )
                        ]
                      : null,
            ),
          ),
        );
      }),
    );
  }
}
