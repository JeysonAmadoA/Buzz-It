import 'package:flutter/material.dart';
import '../../../shared/state/game_state.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

/// Sorted score list — leader gets crown + gold color.
class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({super.key, required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    final sorted = game.sortedScores;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.lcdBg,
        border: Border.all(color: const Color(0xFF4A3014), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: List.generate(sorted.length, (i) {
          final entry = sorted[i];
          final isLeader = i == 0;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
            decoration: BoxDecoration(
              border: i < sorted.length - 1
                  ? const Border(
                      bottom: BorderSide(
                          color: Color(0xFF3A2814), width: 1,
                          style: BorderStyle.solid))
                  : null,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${i + 1}.',
                    style: AppTextStyles.hand(
                      size: 14,
                      color: isLeader
                          ? AppColors.bulbOn
                          : AppColors.textMuted,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    entry.key,
                    style: AppTextStyles.hand(size: 14),
                  ),
                ),
                Text(
                  '${entry.value}${isLeader ? '  👑' : ''}',
                  style: AppTextStyles.theater(
                    size: 16,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
