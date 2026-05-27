import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/l10n/strings.dart';
import '../../shared/state/game_state.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/bulb_row.dart';
import 'widgets/leaderboard_widget.dart';
import 'widgets/timer_display.dart';

class HostPanelScreen extends StatefulWidget {
  const HostPanelScreen({super.key});

  @override
  State<HostPanelScreen> createState() => _HostPanelScreenState();
}

class _HostPanelScreenState extends State<HostPanelScreen> {
  int _selectedTimer = 5;
  static const _presets = [3, 5, 10, 20];

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final t = AppStrings.of(game.lang);
    final isBusy = game.buzzerState == BuzzerState.ready ||
        game.buzzerState == BuzzerState.enabled;
    final isChasing = isBusy;

    return Stack(
      children: [
        // ── Wood grain background ──────────────────────────────────────
        Positioned.fill(
          child: CustomPaint(painter: _WoodGrainPainter()),
        ),

        // ── Gold inset border ──────────────────────────────────────────
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.goldDeep, width: 1.5),
            ),
          ),
        ),

        // ── Content ────────────────────────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t['director']!,
                      style: AppTextStyles.hand(
                          size: 12,
                          color: AppColors.gold,
                          letterSpacing: 3),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5A121B),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '${t['rndShort']}${game.round} / 12',
                        style: AppTextStyles.hand(
                            size: 11,
                            color: AppColors.textLight,
                            letterSpacing: 2),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Timer display
                TimerDisplay(game: game, selectedSeconds: _selectedTimer),

                const SizedBox(height: 10),

                // Timer preset chips
                Row(
                  children: _presets.map((v) {
                    final selected = v == _selectedTimer;
                    return Expanded(
                      child: GestureDetector(
                        onTap: isBusy
                            ? null
                            : () => setState(() => _selectedTimer = v),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.gold
                                : AppColors.lcdBg,
                            border: Border.all(
                                color: const Color(0xFF5A4014), width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${v}s',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.hand(
                              size: 14,
                              color: selected ? AppColors.ink : AppColors.textLight,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),

                // FLASH + TIMER buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: t['flash']!,
                        gradient: AppColors.goldButton,
                        textColor: AppColors.ink,
                        enabled: !isBusy,
                        onTap: () =>
                            context.read<GameState>().activateNow(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: t['timer']!,
                        gradient: AppColors.crimsonButton,
                        textColor: AppColors.paper,
                        enabled: !isBusy,
                        onTap: () => context
                            .read<GameState>()
                            .startTimer(_selectedTimer),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Bulb separator
                BulbRowWidget(
                  count: 20,
                  mode: isChasing ? BulbRowMode.chase : BulbRowMode.alt,
                ),

                const SizedBox(height: 8),

                // Leaderboard label
                Text(t['leaderboard']!, style: AppTextStyles.sectionLabel),

                const SizedBox(height: 6),

                Expanded(
                  child: LeaderboardWidget(game: game),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Wood grain background ─────────────────────────────────────────────────────

class _WoodGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.woodDark,
    );

    final stripePaint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    double x = -size.height;
    while (x < size.width + size.height) {
      stripePaint.color = AppColors.woodLight.withValues(alpha: 0.6);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * 0.18, size.height),
        stripePaint,
      );
      x += 6;
      stripePaint.color = AppColors.woodDark.withValues(alpha: 0.8);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * 0.18, size.height),
        Paint()
          ..color = AppColors.woodDark
          ..strokeWidth = 3,
      );
      x += 3;
    }
  }

  @override
  bool shouldRepaint(_WoodGrainPainter _) => false;
}

// ── Action button (FLASH / TIMER) ─────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.gradient,
    required this.textColor,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final LinearGradient gradient;
  final Color textColor;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.goldDeep, width: 1.5),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.theater(
                size: 14, color: textColor, letterSpacing: 1),
          ),
        ),
      ),
    );
  }
}
