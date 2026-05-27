import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/l10n/strings.dart';
import '../../shared/state/game_state.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/animated_marquee.dart';
import '../../shared/widgets/bulb_row.dart';
import '../../shared/widgets/corner_ornament.dart';
import '../../shared/widgets/oval_bulb_frame.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final t = AppStrings.of(game.lang);

    return Stack(
      children: [
        // ── Velvet background ───────────────────────────────────────────
        Positioned.fill(child: _VelvetBackground()),

        // ── Corner ornaments ────────────────────────────────────────────
        const Positioned(top: 28, left: 22,
            child: CornerOrnament(position: OrnamentPosition.topLeft)),
        const Positioned(top: 28, right: 22,
            child: CornerOrnament(position: OrnamentPosition.topRight)),
        const Positioned(bottom: 28, left: 22,
            child: CornerOrnament(position: OrnamentPosition.bottomLeft)),
        const Positioned(bottom: 28, right: 22,
            child: CornerOrnament(position: OrnamentPosition.bottomRight)),

        // ── Top perimeter bulb row ──────────────────────────────────────
        Positioned(
          top: 40, left: 22, right: 22,
          child: BulbRowWidget(count: 18, mode: BulbRowMode.alt),
        ),

        // ── Bottom perimeter bulb row ───────────────────────────────────
        Positioned(
          bottom: 32, left: 22, right: 22,
          child: BulbRowWidget(count: 18, mode: BulbRowMode.alt),
        ),

        // ── Main content ────────────────────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // TONIGHT label
                Text(
                  '· ${t['tonight']} ·',
                  style: AppTextStyles.hand(
                    size: 13,
                    color: AppColors.textDim,
                    letterSpacing: 5,
                  ),
                ),

                const Spacer(),

                // Oval bulb frame + "BUZZ IT" marquee
                OvalBulbFrame(
                  width: 300,
                  height: 170,
                  count: 32,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedMarquee(
                        text: 'BUZZ IT',
                        size: MarqueeSize.xl,
                        stagger: 120,
                        restartKey: 'home',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t['appTag']!,
                        style: AppTextStyles.hand(
                          size: 13,
                          color: AppColors.textDim,
                          style: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Choose role label
                Text(
                  t['chooseRole']!,
                  style: AppTextStyles.hand(
                    size: 14,
                    color: AppColors.textLight,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 22),

                // CREATE ROOM button
                _GoldButton(
                  label: t['createRoom']!,
                  gradient: AppColors.goldButton,
                  onTap: () => context.read<GameState>().chooseHost(),
                ),

                const SizedBox(height: 14),

                // JOIN ROOM button (slightly darker gold)
                _GoldButton(
                  label: t['joinRoom']!,
                  gradient: AppColors.goldButtonDarker,
                  onTap: () => context.read<GameState>().chooseParticipant(),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Velvet textured background ────────────────────────────────────────────────

class _VelvetBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _VelvetPainter(),
    );
  }
}

class _VelvetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Radial gradient base
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = const RadialGradient(
      center: Alignment(0, -0.8),
      radius: 1.4,
      colors: [AppColors.velvetBg, AppColors.velvetBgDeep],
    ).createShader(rect);

    canvas.drawRect(rect, Paint()..shader = gradient);

    // Vertical stripe overlay (velvet texture)
    final stripePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), stripePaint);
    }
  }

  @override
  bool shouldRepaint(_VelvetPainter _) => false;
}

// ── Gold button ───────────────────────────────────────────────────────────────

class _GoldButton extends StatelessWidget {
  const _GoldButton({
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.goldDeep, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldBtnShadow,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
            const BoxShadow(
              color: Color(0x73FFFFFF),
              offset: Offset(0, 1),
              blurRadius: 0,
              spreadRadius: -1,
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.theater(
            size: 22,
            color: AppColors.ink,
            letterSpacing: 0.08 * 22,
          ),
        ),
      ),
    );
  }
}
