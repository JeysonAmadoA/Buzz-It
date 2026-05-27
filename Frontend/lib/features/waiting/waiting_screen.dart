import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/l10n/strings.dart';
import '../../shared/state/game_state.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/animated_marquee.dart';
import '../../shared/widgets/bulb_row.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({super.key});

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _dotCtrls;
  late List<Animation<double>> _dotOpacity;

  @override
  void initState() {
    super.initState();
    _dotCtrls = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..repeat(reverse: true),
    );
    _dotOpacity = List.generate(3, (i) {
      _dotCtrls[i].forward(from: i * 0.33);
      return Tween(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _dotCtrls[i], curve: Curves.easeInOut),
      );
    });
  }

  @override
  void dispose() {
    for (final c in _dotCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final t = AppStrings.of(game.lang);

    final demoParticipants = [
      '${game.userName} (you)',
      'Lucia',
      'Mateo',
      'Carmen',
      'Sofia',
    ];

    return Stack(
      children: [
        // ── Dark velvet background ──────────────────────────────────────
        Positioned.fill(child: _DarkVelvetBackground()),

        // ── Curtain top ─────────────────────────────────────────────────
        Positioned(
          top: 0, left: 0, right: 0,
          child: CustomPaint(
            painter: _CurtainPainter(),
            size: const Size(double.infinity, 84),
          ),
        ),

        // ── Content ─────────────────────────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Separator bulb row
                BulbRowWidget(count: 18, mode: BulbRowMode.alt),

                const SizedBox(height: 24),

                // Room code label
                Text(
                  '· SALA ${game.roomCode} ·',
                  style: AppTextStyles.hand(
                      size: 13,
                      color: AppColors.gold,
                      letterSpacing: 5),
                ),

                const SizedBox(height: 14),

                // Animated WAITING marquee
                AnimatedMarquee(
                  text: t['waiting']!,
                  size: MarqueeSize.xl,
                  stagger: 120,
                  restartKey: 'waiting',
                ),

                const SizedBox(height: 10),

                // Pulsing dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return AnimatedBuilder(
                      animation: _dotOpacity[i],
                      builder: (_, _) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Opacity(
                          opacity: _dotOpacity[i].value,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.bulbOn,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.bulbOn
                                      .withValues(alpha: 0.8),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                Text(
                  t['waitingMsg']!,
                  style: AppTextStyles.hand(
                      size: 16,
                      color: AppColors.textDim,
                      style: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // ── Participant list ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(t['inTheRoom']!, style: AppTextStyles.sectionLabel),
                    Text(
                      '${demoParticipants.length}',
                      style: AppTextStyles.hand(
                          size: 14, color: AppColors.bulbOn),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Expanded(
                  child: ListView.separated(
                    itemCount: demoParticipants.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (_, i) {
                      final name = demoParticipants[i];
                      final isYou = i == 0;
                      return _WaitingChip(name: name, isYou: isYou);
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Leave room ghost button
                GestureDetector(
                  onTap: () => context.read<GameState>().goto('home'),
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
                      t['leaveRoom']!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.hand(
                          size: 14, color: AppColors.textDim),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Dark velvet background ────────────────────────────────────────────────────

class _DarkVelvetBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DarkVelvetPainter());
  }
}

class _DarkVelvetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final shader = const RadialGradient(
      center: Alignment(0, -0.8),
      radius: 1.4,
      colors: [AppColors.darkVelvet, AppColors.darkVelvetDeep],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = shader);

    final stripePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), stripePaint);
    }
  }

  @override
  bool shouldRepaint(_DarkVelvetPainter _) => false;
}

// ── Curtain top painter ───────────────────────────────────────────────────────

class _CurtainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()..color = const Color(0xFF5A0810);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.71)
      ..quadraticBezierTo(w * 0.887, h, w * 0.733, h * 0.71)
      ..quadraticBezierTo(w * 0.579, h * 1.1, w * 0.503, h * 0.71)
      ..quadraticBezierTo(w * 0.426, h * 1.1, w * 0.272, h * 0.71)
      ..quadraticBezierTo(w * 0.113, h, 0, h * 0.71)
      ..close();
    canvas.drawPath(path, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF3A0408)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final x in [
      w * 0.113,
      w * 0.272,
      w * 0.503,
      w * 0.733,
      w * 0.887,
    ]) {
      canvas.drawLine(Offset(x, 0), Offset(x, h * 0.75), linePaint);
    }
  }

  @override
  bool shouldRepaint(_CurtainPainter _) => false;
}

// ── Waiting participant chip ──────────────────────────────────────────────────

class _WaitingChip extends StatelessWidget {
  const _WaitingChip({required this.name, required this.isYou});

  final String name;
  final bool isYou;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isYou ? const Color(0xFF5A121B) : const Color(0xFF2A1109),
        border: Border.all(
          color: isYou ? AppColors.gold : AppColors.goldDeep,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
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
          Text(name, style: AppTextStyles.hand(size: 15)),
        ],
      ),
    );
  }
}
