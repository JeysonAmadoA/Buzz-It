import 'package:flutter/material.dart';
import '../../../shared/state/game_state.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/animated_marquee.dart';
import '../../../shared/widgets/countdown.dart';

/// LCD-style timer display panel.
/// Shows one of three states:
///   1. Preset selected (big Codystar number)
///   2. Countdown active (CountdownWidget)
///   3. Waiting for response (animated marquee)
class TimerDisplay extends StatelessWidget {
  const TimerDisplay({
    super.key,
    required this.game,
    required this.selectedSeconds,
  });

  final GameState game;
  final int selectedSeconds;

  @override
  Widget build(BuildContext context) {
    final isCounting = game.buzzerState == BuzzerState.ready &&
        game.timerSeconds != null;
    final isWaiting  = game.buzzerState == BuzzerState.enabled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: AppColors.lcdBg,
        border: Border.all(color: const Color(0xFF5A4014), width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 18,
            offset: Offset.zero,
            spreadRadius: -4,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            'TIMER',
            style: AppTextStyles.hand(
                size: 10,
                color: const Color(0xFF8A7240),
                letterSpacing: 4),
          ),
          const SizedBox(height: 4),
          if (isCounting)
            CountdownWidget(
              from: game.timerSeconds!,
              fontSize: 100,
              onDone: () => game.timerDone(),
            )
          else if (isWaiting)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: AnimatedMarquee(
                text: 'awaiting response…',
                size: MarqueeSize.md,
                stagger: 60,
                restartKey: 'await${game.round}',
              ),
            )
          else
            Column(
              children: [
                Text(
                  selectedSeconds.toString().padLeft(2, '0'),
                  style: AppTextStyles.marquee(size: 64).copyWith(
                    color: AppColors.bulbOn,
                    shadows: [
                      Shadow(
                        color: AppColors.bulbOn.withValues(alpha: 0.7),
                        blurRadius: 12,
                      )
                    ],
                  ),
                ),
                Text(
                  'preset · ${selectedSeconds}s',
                  style: AppTextStyles.hand(
                      size: 13,
                      color: AppColors.textDim,
                      style: FontStyle.italic),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
