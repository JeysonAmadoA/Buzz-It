import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

/// Theater podium — 3 columns aligned at bottom.
/// Center = 1st (gold, 116px), left = 2nd (bronze, 80px), right = 3rd (brown, 60px).
class PodiumWidget extends StatelessWidget {
  const PodiumWidget({
    super.key,
    this.first,
    this.second,
    this.third,
  });

  final String? first;
  final String? second;
  final String? third;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place (left)
        Expanded(child: _PodiumStep(rank: 2, name: second, height: 80)),
        const SizedBox(width: 6),
        // 1st place (center)
        Expanded(child: _PodiumStep(rank: 1, name: first, height: 116)),
        const SizedBox(width: 6),
        // 3rd place (right)
        Expanded(child: _PodiumStep(rank: 3, name: third, height: 60)),
      ],
    );
  }
}

class _PodiumStep extends StatelessWidget {
  const _PodiumStep({
    required this.rank,
    required this.name,
    required this.height,
  });

  final int rank;
  final String? name;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name above step
        if (name != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              isFirst ? '★ $name ★' : (name ?? '—'),
              style: AppTextStyles.hand(
                size: 13,
                color: isFirst ? AppColors.gold : AppColors.ink,
                weight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('—', style: AppTextStyles.hand(size: 13)),
          ),

        // Step block
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: isFirst
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.bulbOn, AppColors.goldBtnBot],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF8A6C1F), Color(0xFF4A3608)],
                  ),
            border: Border.all(
                color: const Color(0xFF2A1C00), width: 1.5),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(6)),
          ),
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '$rank',
              style: AppTextStyles.theater(
                size: isFirst ? 40 : rank == 2 ? 28 : 22,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
