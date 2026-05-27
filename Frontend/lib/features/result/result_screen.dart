import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/l10n/strings.dart';
import '../../shared/state/game_state.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/animated_marquee.dart';
import '../../shared/widgets/bulb_row.dart';
import 'widgets/podium_widget.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game   = context.watch<GameState>();
    final t      = AppStrings.of(game.lang);
    final sorted = game.sortedScores;
    final top3   = sorted.take(3).toList();
    final rest   = sorted.skip(3).toList();

    final firstName  = top3.isNotEmpty ? top3[0].key : game.winnerName ?? '—';
    final secondName = top3.length > 1 ? top3[1].key : null;
    final thirdName  = top3.length > 2 ? top3[2].key : null;

    return Container(
      color: AppColors.darkBase,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Round label ─────────────────────────────────────────
              Center(
                child: Text(
                  '· ${t['endOfRound']} ${game.round} ·',
                  style: AppTextStyles.hand(
                      size: 13,
                      color: AppColors.gold,
                      letterSpacing: 4),
                ),
              ),

              const SizedBox(height: 6),

              BulbRowWidget(count: 20, mode: BulbRowMode.all),

              const SizedBox(height: 14),

              // ── Winner banner ───────────────────────────────────────
              _WinnerBanner(
                label: t['theWinner']!,
                name: firstName,
                time: game.winnerTime,
                inTimeLabel: t['inTime']!,
                seconds: t['seconds']!,
                round: game.round,
              ),

              const SizedBox(height: 14),

              // ── Podium ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PodiumWidget(
                  first: firstName,
                  second: secondName,
                  third: thirdName,
                ),
              ),

              const SizedBox(height: 16),

              // ── Rest of cast ────────────────────────────────────────
              if (rest.isNotEmpty) ...[
                Text('REST OF THE CAST', style: AppTextStyles.sectionLabel),
                const SizedBox(height: 6),
                ...rest.asMap().entries.map((e) {
                  final idx  = e.key;
                  final name = e.value.key;
                  final pts  = e.value.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A0D0D),
                        border: Border.all(
                            color: const Color(0xFF4A3C2A), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${idx + 4}.',
                            style: AppTextStyles.hand(
                                size: 14,
                                color: const Color(0xFF5A4A30)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(name,
                                style: AppTextStyles.hand(
                                    size: 14,
                                    color: const Color(0xFF8A7240))),
                          ),
                          Text(
                            '$pts',
                            style: AppTextStyles.theater(
                                size: 14,
                                color: const Color(0xFF5A4A30)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              const Spacer(),

              // ── NEW ROUND button ────────────────────────────────────
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => context.read<GameState>().nextRound(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldButton,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.goldDeep, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.goldBtnShadow,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Text(
                        '↻ ${t['newRound']}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.theater(
                            size: 20, color: AppColors.ink),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -4, left: 8, right: 8,
                    child: BulbRowWidget(count: 14, mode: BulbRowMode.chase),
                  ),
                  Positioned(
                    bottom: -4, left: 8, right: 8,
                    child: BulbRowWidget(count: 14, mode: BulbRowMode.chase),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── END SHOW ghost button ───────────────────────────────
              GestureDetector(
                onTap: () => context.read<GameState>().endShow(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.goldDeep,
                        width: 1,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '✕ ${t['endShow']}',
                    textAlign: TextAlign.center,
                    style:
                        AppTextStyles.hand(size: 14, color: AppColors.textDim),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Winner banner ──────────────────────────────────────────────────────────────

class _WinnerBanner extends StatelessWidget {
  const _WinnerBanner({
    required this.label,
    required this.name,
    required this.time,
    required this.inTimeLabel,
    required this.seconds,
    required this.round,
  });

  final String label;
  final String name;
  final String time;
  final String inTimeLabel;
  final String seconds;
  final int round;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2A0A0E), Color(0xFF170406)],
            ),
            border: Border.all(color: AppColors.gold, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(label, style: AppTextStyles.sectionLabel),
              const SizedBox(height: 8),
              AnimatedMarquee(
                text: name.toUpperCase(),
                size: MarqueeSize.huge,
                stagger: 140,
                restartKey: 'res$round',
              ),
              const SizedBox(height: 8),
              Text(
                '$inTimeLabel · $time$seconds',
                style: AppTextStyles.hand(
                    size: 14,
                    color: AppColors.textDim,
                    style: FontStyle.italic),
              ),
            ],
          ),
        ),
        // Top bulb row
        Positioned(
          top: -4, left: 12, right: 12,
          child: BulbRowWidget(count: 16, mode: BulbRowMode.all),
        ),
        // Bottom bulb row
        Positioned(
          bottom: -4, left: 12, right: 12,
          child: BulbRowWidget(count: 16, mode: BulbRowMode.all),
        ),
      ],
    );
  }
}
