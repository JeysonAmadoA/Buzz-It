import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/l10n/strings.dart';
import '../../shared/state/game_state.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/animated_marquee.dart';
import '../../shared/widgets/bulb_ring.dart';
import '../../shared/widgets/bulb_row.dart';
import '../../shared/widgets/countdown.dart';
import 'widgets/buzzer_button.dart';

class BuzzerScreen extends StatelessWidget {
  const BuzzerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final t = AppStrings.of(game.lang);

    // If someone else won, participant sees "late"
    final isWinnerSomeoneElse = game.buzzerState == BuzzerState.winner &&
        game.winnerName != null &&
        game.winnerName != game.userName;
    final displayState = isWinnerSomeoneElse
        ? BuzzerState.late
        : game.buzzerState;

    final ringMode = _ringModeFor(displayState);
    final bg = _backgroundFor(displayState);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(gradient: bg),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${game.roomCode} · ${t['round']} ${game.round}',
                    style: AppTextStyles.hand(
                        size: 13, color: AppColors.gold),
                  ),
                  Text(
                    '${game.userName} ★',
                    style: AppTextStyles.hand(
                        size: 13, color: AppColors.textDim),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Top bulb row
              BulbRowWidget(
                count: 20,
                mode: (displayState == BuzzerState.enabled ||
                        displayState == BuzzerState.winner)
                    ? BulbRowMode.all
                    : BulbRowMode.alt,
              ),

              const SizedBox(height: 12),

              // ── State-dependent top message ───────────────────────────
              _StateMessage(
                state: displayState,
                game: game,
                t: t,
              ),

              const SizedBox(height: 8),

              // ── Big buzzer with ring ──────────────────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size =
                        constraints.maxHeight.clamp(180.0, 260.0);
                    return Center(
                      child: BulbRingWidget(
                        size: size,
                        count: 22,
                        mode: ringMode,
                        bulbRadius: 6,
                        startKey: '${displayState.name}${game.round}',
                        child: BuzzerButton(
                          state: displayState,
                          onPress: () =>
                              context.read<GameState>().participantBuzz(),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Footer hint ───────────────────────────────────────────
              _FooterHint(state: displayState, game: game, t: t),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Ring mode selector ────────────────────────────────────────────────────────

BulbRingMode _ringModeFor(BuzzerState state) {
  switch (state) {
    case BuzzerState.waiting : return BulbRingMode.off;
    case BuzzerState.ready   : return BulbRingMode.cascadeOn;
    case BuzzerState.enabled : return BulbRingMode.allOn;
    case BuzzerState.winner  : return BulbRingMode.flash;
    case BuzzerState.late    : return BulbRingMode.off;
    case BuzzerState.locked  : return BulbRingMode.alt;
  }
}

// ── Background gradient selector ──────────────────────────────────────────────

RadialGradient _backgroundFor(BuzzerState state) {
  switch (state) {
    case BuzzerState.winner:
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [Color(0xFFE0C97A), Color(0xFFD97920), Color(0xFF6A1018), Color(0xFF2A0509)],
        stops: [0.0, 0.18, 0.55, 0.9],
      );
    case BuzzerState.enabled:
      return const RadialGradient(
        center: Alignment(0, -0.5),
        radius: 1.2,
        colors: [Color(0xFF5A0810), Color(0xFF2A0509)],
      );
    case BuzzerState.late:
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [Color(0xFF1A0808), Color(0xFF0D0405)],
      );
    default:
      return const RadialGradient(
        center: Alignment(0, -0.5),
        radius: 1.2,
        colors: [Color(0xFF2A0D0D), Color(0xFF120203)],
      );
  }
}

// ── State-dependent top message ───────────────────────────────────────────────

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.state,
    required this.game,
    required this.t,
  });

  final BuzzerState state;
  final GameState game;
  final Map<String, String> t;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case BuzzerState.waiting:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedMarquee(
              text: t['waitForStart']!,
              size: MarqueeSize.md,
              dim: true,
              stagger: 70,
              restartKey: 'esp${game.round}',
            ),
            const SizedBox(height: 6),
            Text(
              t['waitingHost']!,
              style: AppTextStyles.hand(
                  size: 13,
                  color: AppColors.textMuted,
                  style: FontStyle.italic),
            ),
          ],
        );

      case BuzzerState.ready:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t['activatesIn']!,
              style: AppTextStyles.hand(
                  size: 13,
                  color: AppColors.textDim,
                  letterSpacing: 3),
            ),
            const SizedBox(height: 4),
            CountdownWidget(
              from: game.timerSeconds ?? 3,
              fontSize: 76,
            ),
          ],
        );

      case BuzzerState.enabled:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t['now']!,
              style: AppTextStyles.hand(
                  size: 13,
                  color: AppColors.textLight,
                  letterSpacing: 4),
            ),
            const SizedBox(height: 4),
            AnimatedMarquee(
              text: t['press']!,
              size: MarqueeSize.xl,
              stagger: 60,
              restartKey: 'hab${game.round}',
            ),
          ],
        );

      case BuzzerState.winner:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedMarquee(
              text: t['first']!,
              size: MarqueeSize.huge,
              stagger: 120,
              restartKey: 'win${game.round}',
            ),
            const SizedBox(height: 6),
            Text(
              '${t['inTime']} · ${game.winnerTime}${t['seconds']}',
              style: AppTextStyles.hand(
                  size: 16, color: AppColors.bulbOnBright),
            ),
          ],
        );

      case BuzzerState.late:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedMarquee(
              text: t['tooLate']!,
              size: MarqueeSize.lg,
              dim: true,
              stagger: 80,
              restartKey: 'late${game.round}',
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${t['yourPos']}: ',
                  style: AppTextStyles.hand(
                      size: 14, color: const Color(0xFF8A5A5A)),
                ),
                Text(
                  '3°',
                  style: AppTextStyles.theater(
                      size: 22, color: AppColors.gold),
                ),
                Text(
                  ' ${t['inTime']} 5',
                  style: AppTextStyles.hand(
                      size: 14, color: const Color(0xFF8A5A5A)),
                ),
              ],
            ),
          ],
        );

      case BuzzerState.locked:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedMarquee(
              text: t['alreadyPlayed']!,
              size: MarqueeSize.md,
              dim: true,
              stagger: 70,
              restartKey: 'blk${game.round}',
            ),
            const SizedBox(height: 6),
            Text(
              t['pressAgain']!,
              style: AppTextStyles.hand(
                  size: 13,
                  color: AppColors.textMuted,
                  style: FontStyle.italic),
            ),
          ],
        );
    }
  }
}

// ── Footer hint ───────────────────────────────────────────────────────────────

class _FooterHint extends StatelessWidget {
  const _FooterHint({
    required this.state,
    required this.game,
    required this.t,
  });

  final BuzzerState state;
  final GameState game;
  final Map<String, String> t;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case BuzzerState.enabled:
        return Text(
          '↯ vibra + tono',
          style: AppTextStyles.hand(size: 16, color: AppColors.bulbOn),
          textAlign: TextAlign.center,
        );
      case BuzzerState.winner:
        return GestureDetector(
          onTap: () => context.read<GameState>().goto('result'),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gold),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ver podio →',
              style:
                  AppTextStyles.hand(size: 14, color: AppColors.bulbOnBright),
            ),
          ),
        );
      case BuzzerState.late:
        return GestureDetector(
          onTap: () => context.read<GameState>().goto('result'),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF5A4014)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ver resultado →',
              style:
                  AppTextStyles.hand(size: 14, color: AppColors.textDim),
            ),
          ),
        );
      case BuzzerState.waiting:
        return Text(
          'guarda el dedo cerca…',
          style: AppTextStyles.hand(
              size: 14,
              color: AppColors.textMuted,
              style: FontStyle.italic),
          textAlign: TextAlign.center,
        );
      case BuzzerState.ready:
        return Text(
          '↯ se acerca…',
          style: AppTextStyles.hand(size: 14, color: AppColors.bulbOn),
          textAlign: TextAlign.center,
        );
      case BuzzerState.locked:
        return Text(
          'reglas: 1 buzz por ronda',
          style: AppTextStyles.hand(
              size: 13,
              color: AppColors.textMuted,
              style: FontStyle.italic),
          textAlign: TextAlign.center,
        );
    }
  }
}
