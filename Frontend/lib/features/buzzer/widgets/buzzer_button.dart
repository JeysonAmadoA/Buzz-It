import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/state/game_state.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

/// The big circular buzzer button — visual state driven by [BuzzerState].
class BuzzerButton extends StatefulWidget {
  const BuzzerButton({
    super.key,
    required this.state,
    required this.onPress,
  });

  final BuzzerState state;
  final VoidCallback onPress;

  @override
  State<BuzzerButton> createState() => _BuzzerButtonState();
}

class _BuzzerButtonState extends State<BuzzerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;
  late Animation<double> _shadow;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale  = Tween(begin: 1.0, end: 1.03)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _shadow = Tween(begin: 28.0, end: 48.0)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _syncAnimation();
  }

  @override
  void didUpdateWidget(BuzzerButton old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.state == BuzzerState.enabled ||
        widget.state == BuzzerState.winner) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.reset();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  _BuzzerStyle get _style => _styleFor(widget.state);

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(
        scale: widget.state == BuzzerState.enabled ? _scale.value : 1.0,
        child: child,
      ),
      child: GestureDetector(
        onTap: () {
          if (widget.state != BuzzerState.enabled) return;
          HapticFeedback.heavyImpact();
          widget.onPress();
        },
        child: Container(
          width: 188,
          height: 188,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: style.gradient,
            border: Border.all(color: style.borderColor, width: 4),
            boxShadow: [
              BoxShadow(
                color: style.glowColor
                    .withValues(alpha: style.glowAlpha),
                blurRadius: widget.state == BuzzerState.enabled
                    ? _shadow.value
                    : widget.state == BuzzerState.winner
                        ? 60
                        : 0,
                spreadRadius: 0,
              ),
              const BoxShadow(
                color: Colors.black54,
                blurRadius: 12,
                offset: Offset(0, -6),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Diagonal band for "locked" state ─────────────────
                if (widget.state == BuzzerState.locked)
                  Transform.rotate(
                    angle: -0.314, // ~-18 degrees
                    child: Container(
                      width: 260,
                      height: 32,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.gold, AppColors.goldDeep],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'YA JUGASTE',
                        style: AppTextStyles.theater(
                          size: 14,
                          color: AppColors.ink,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),

                // ── Label ─────────────────────────────────────────────
                if (widget.state != BuzzerState.locked)
                  Text(
                    _labelFor(widget.state),
                    style: AppTextStyles.theater(
                      size: style.labelSize,
                      color: style.labelColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Style spec ────────────────────────────────────────────────────────────────

class _BuzzerStyle {
  const _BuzzerStyle({
    required this.gradient,
    required this.borderColor,
    required this.glowColor,
    required this.glowAlpha,
    required this.labelColor,
    required this.labelSize,
  });

  final RadialGradient gradient;
  final Color borderColor;
  final Color glowColor;
  final double glowAlpha;
  final Color labelColor;
  final double labelSize;
}

_BuzzerStyle _styleFor(BuzzerState state) {
  switch (state) {
    case BuzzerState.waiting:
      return _BuzzerStyle(
        gradient: AppColors.waitingBuzzer,
        borderColor: const Color(0xFF3A1F1F),
        glowColor: Colors.transparent,
        glowAlpha: 0,
        labelColor: const Color(0xFFA08070),
        labelSize: 22,
      );
    case BuzzerState.ready:
      return _BuzzerStyle(
        gradient: const RadialGradient(
          center: Alignment(-0.4, -0.35),
          radius: 1.2,
          colors: [Color(0xFFD4576A), Color(0xFF8A1A26), Color(0xFF4A0A10)],
          stops: [0.0, 0.4, 1.0],
        ),
        borderColor: const Color(0xFF4A0A10),
        glowColor: AppColors.crimson,
        glowAlpha: 0.4,
        labelColor: AppColors.paper,
        labelSize: 22,
      );
    case BuzzerState.enabled:
      return _BuzzerStyle(
        gradient: AppColors.enabledBuzzer,
        borderColor: const Color(0xFF4A0A10),
        glowColor: AppColors.buzzerEnabled,
        glowAlpha: 0.85,
        labelColor: AppColors.paper,
        labelSize: 22,
      );
    case BuzzerState.winner:
      return _BuzzerStyle(
        gradient: AppColors.winnerBuzzer,
        borderColor: AppColors.goldBtnShadow,
        glowColor: AppColors.bulbOn,
        glowAlpha: 0.95,
        labelColor: AppColors.ink,
        labelSize: 50,
      );
    case BuzzerState.late:
      return _BuzzerStyle(
        gradient: const RadialGradient(
          center: Alignment(-0.4, -0.35),
          radius: 1.2,
          colors: [Color(0xFF5A3030), Color(0xFF4A1A1A), Color(0xFF2A0A0A)],
          stops: [0.0, 0.4, 1.0],
        ),
        borderColor: const Color(0xFF2A0A0A),
        glowColor: Colors.transparent,
        glowAlpha: 0,
        labelColor: const Color(0xFF8A5A5A),
        labelSize: 50,
      );
    case BuzzerState.locked:
      return _BuzzerStyle(
        gradient: const RadialGradient(
          center: Alignment(-0.4, -0.35),
          radius: 1.2,
          colors: [Color(0xFF5A4014), Color(0xFF4A3014), Color(0xFF2A1A04)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderColor: const Color(0xFF2A1A04),
        glowColor: Colors.transparent,
        glowAlpha: 0,
        labelColor: const Color(0xFF8A7240),
        labelSize: 46,
      );
  }
}

String _labelFor(BuzzerState state) {
  switch (state) {
    case BuzzerState.waiting : return 'ESPERA';
    case BuzzerState.ready   : return 'LISTO';
    case BuzzerState.enabled : return 'PRESIONA';
    case BuzzerState.winner  : return '★';
    case BuzzerState.late    : return '✕';
    case BuzzerState.locked  : return '';
  }
}
