import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/l10n/strings.dart';
import '../../shared/state/game_state.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/animated_marquee.dart';
import '../../shared/widgets/bulb_row.dart';
import 'widgets/participant_chip.dart';

class CreateRoomScreen extends StatelessWidget {
  const CreateRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final t    = AppStrings.of(game.lang);

    return Container(
      color: AppColors.darkBase,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.read<GameState>().goto('home'),
                    child: Text(t['backShort']!,
                        style: AppTextStyles.hand(
                            size: 13, color: AppColors.gold)),
                  ),
                  Text(t['youAreHost']!,
                      style: AppTextStyles.hand(
                          size: 13,
                          color: AppColors.textDim,
                          letterSpacing: 2)),
                  _OnAirPill(label: t['onAir']!),
                ],
              ),

              const SizedBox(height: 14),

              // ── Room code section label ─────────────────────────────────
              Text(t['roomCode']!.toUpperCase(),
                  style: AppTextStyles.sectionLabel),

              const SizedBox(height: 10),

              // ── Marquee banner with code chars ─────────────────────────
              _MarqueeBanner(roomCode: game.roomCode, lang: game.lang),

              const SizedBox(height: 10),

              // ── Copy / Share ghost buttons ──────────────────────────────
              Row(
                children: [
                  Expanded(child: _GhostButton(label: '⎘ ${t['copy']!}')),
                  const SizedBox(width: 8),
                  Expanded(child: _GhostButton(label: '↗ ${t['share']!}')),
                ],
              ),

              const SizedBox(height: 14),

              // ── Participant list ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(t['participants']!,
                      style: AppTextStyles.sectionLabel),
                  Text(
                    '${game.participants.length} ${t['connected']}',
                    style: AppTextStyles.hand(
                        size: 14, color: AppColors.bulbOn),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Expanded(
                child: ListView.separated(
                  itemCount: game.participants.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 5),
                  itemBuilder: (_, i) {
                    final name = game.participants[i];
                    return ParticipantChip(
                      name: name,
                      isNew: game.newlyJoined.contains(name),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // ── START SHOW button ───────────────────────────────────────
              _StartButton(
                label: t['startContest']!,
                enabled: game.participants.isNotEmpty,
                onTap: () => context.read<GameState>().startContest(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── ON AIR pill ───────────────────────────────────────────────────────────────

class _OnAirPill extends StatefulWidget {
  const _OnAirPill({required this.label});
  final String label;
  @override
  State<_OnAirPill> createState() => _OnAirPillState();
}

class _OnAirPillState extends State<_OnAirPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.crimson,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                    alpha: 0.4 + _ctrl.value * 0.6),
              ),
            ),
            const SizedBox(width: 4),
            Text(widget.label, style: AppTextStyles.onAirLabel),
          ],
        ),
      ),
    );
  }
}

// ── Marquee banner (room code display) ───────────────────────────────────────

class _MarqueeBanner extends StatelessWidget {
  const _MarqueeBanner({required this.roomCode, required this.lang});
  final String roomCode;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(lang);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2A0A0E), Color(0xFF170406)],
            ),
            border: Border.all(color: AppColors.goldDeep, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Code characters
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: roomCode.split('').map((ch) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 58,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.codeBg,
                        border: Border.all(
                            color: AppColors.goldDeep, width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedMarquee(
                        text: ch,
                        size: MarqueeSize.huge,
                        stagger: 120,
                        restartKey: 'code_$ch',
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                t['shareCode']!,
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
          top: -4,
          left: 12,
          right: 12,
          child: BulbRowWidget(count: 16, mode: BulbRowMode.alt),
        ),
        // Bottom bulb row
        Positioned(
          bottom: -4,
          left: 12,
          right: 12,
          child: BulbRowWidget(count: 16, mode: BulbRowMode.alt),
        ),
      ],
    );
  }
}

// ── Ghost button ──────────────────────────────────────────────────────────────

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
            color: AppColors.goldDeep,
            width: 1,
            style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.hand(
            size: 13, color: AppColors.textDim),
      ),
    );
  }
}

// ── START SHOW button with chase bulb rows ────────────────────────────────────

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              gradient: enabled
                  ? AppColors.goldButton
                  : const LinearGradient(
                      colors: [Color(0xFF6A5020), Color(0xFF4A3808)]),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.goldDeep, width: 2),
              boxShadow: enabled
                  ? [
                      const BoxShadow(
                        color: AppColors.goldBtnShadow,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      )
                    ]
                  : null,
            ),
            child: Text(
              '▶ $label',
              textAlign: TextAlign.center,
              style: AppTextStyles.theater(
                size: 22,
                color: enabled ? AppColors.ink : AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        Positioned(
          top: -5,
          left: 8,
          right: 8,
          child:
              BulbRowWidget(count: 16, mode: BulbRowMode.chase),
        ),
        Positioned(
          bottom: -5,
          left: 8,
          right: 8,
          child:
              BulbRowWidget(count: 16, mode: BulbRowMode.chase),
        ),
      ],
    );
  }
}
