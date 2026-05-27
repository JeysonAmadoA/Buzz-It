import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

/// Animated participant chip — flashes a gold border for 700ms on first appearance.
class ParticipantChip extends StatefulWidget {
  const ParticipantChip({
    super.key,
    required this.name,
    this.isNew = false,
    this.isYou = false,
  });

  final String name;
  final bool isNew;
  final bool isYou;

  @override
  State<ParticipantChip> createState() => _ParticipantChipState();
}

class _ParticipantChipState extends State<ParticipantChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glow = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    if (widget.isNew) _ctrl.forward();
  }

  @override
  void didUpdateWidget(ParticipantChip old) {
    super.didUpdateWidget(old);
    if (widget.isNew && !old.isNew) _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, _) {
        final glowAlpha = (_glow.value * 0.5).clamp(0.0, 1.0);
        final bgAlpha   = (_glow.value * 0.3).clamp(0.0, 1.0);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isYou
                ? const Color(0xFF5A121B)
                : Color.lerp(
                    const Color(0xFF2A1109),
                    const Color(0xFF5A3A09),
                    bgAlpha,
                  ),
            border: Border.all(
              color: Color.lerp(
                widget.isYou ? AppColors.gold : AppColors.goldDeep,
                AppColors.bulbOn,
                widget.isNew ? _glow.value : 0,
              )!,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: widget.isNew && _glow.value > 0
                ? [
                    BoxShadow(
                      color: AppColors.bulbOn.withValues(alpha: glowAlpha * 0.5),
                      blurRadius: 18,
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Live dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bulbOn,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.bulbOn.withValues(alpha: 0.6),
                      blurRadius: 6,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.name,
                  style: AppTextStyles.hand(size: 15),
                ),
              ),
              if (widget.isNew)
                Text(
                  'just joined',
                  style: AppTextStyles.hand(
                    size: 12,
                    color: AppColors.bulbOn,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
