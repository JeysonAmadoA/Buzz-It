import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/l10n/strings.dart';
import '../../shared/state/game_state.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/animated_marquee.dart';
import '../../shared/widgets/bulb_row.dart';
import 'widgets/code_keypad.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  String _code = '';
  final TextEditingController _nameCtrl = TextEditingController();

  bool get _ready => _code.length >= 4 && _nameCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final t = AppStrings.of(game.lang);

    return Container(
      color: AppColors.joinBg,
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
                  Text(t['youArePart']!,
                      style: AppTextStyles.hand(
                          size: 13,
                          color: AppColors.textDim,
                          letterSpacing: 2)),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 14),

              // ── Title marquee ───────────────────────────────────────────
              Center(
                child: AnimatedMarquee(
                  text: t['joinRoom']!,
                  size: MarqueeSize.lg,
                  restartKey: 'join',
                ),
              ),
              Center(
                child: Text(
                  'tu boleto a la diversión',
                  style: AppTextStyles.hand(
                      size: 14,
                      color: AppColors.textDim,
                      style: FontStyle.italic),
                ),
              ),

              const SizedBox(height: 18),

              // ── Code input box ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.codeBg,
                  border: Border.all(color: AppColors.gold, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['yourCode']!, style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 8),

                    // 4 character display boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        final ch = i < _code.length ? _code[i] : '_';
                        final filled = i < _code.length;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 52,
                            height: 64,
                            decoration: BoxDecoration(
                              color: filled
                                  ? const Color(0xFF2A0A0E)
                                  : const Color(0xFF1A0408),
                              border: Border.all(
                                color: filled
                                    ? AppColors.bulbOn
                                    : AppColors.goldDeep,
                                width: filled ? 1.5 : 1,
                                style: filled
                                    ? BorderStyle.solid
                                    : BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              ch,
                              style: AppTextStyles.marquee(
                                size: 36,
                                color: filled
                                    ? AppColors.bulbOn
                                    : const Color(0xFF5A4A2A),
                              ).copyWith(
                                shadows: filled
                                    ? [
                                        Shadow(
                                          color: AppColors.bulbOn
                                              .withValues(alpha: 0.8),
                                          blurRadius: 8,
                                        )
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 8),

                    // Keypad
                    CodeKeypad(
                      onKey: (k) {
                        if (_code.length < 4) {
                          setState(() => _code += k);
                        }
                      },
                      onDelete: () {
                        if (_code.isNotEmpty) {
                          setState(
                              () => _code = _code.substring(0, _code.length - 1));
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ── Name input ──────────────────────────────────────────────
              Text(t['yourName']!, style: AppTextStyles.sectionLabel),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.codeBg,
                  border: Border.all(color: AppColors.goldDeep, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _nameCtrl,
                  onChanged: (_) => setState(() {}),
                  style: AppTextStyles.hand(size: 18),
                  cursorColor: AppColors.gold,
                  decoration: InputDecoration(
                    hintText: t['namePlaceholder'],
                    hintStyle: AppTextStyles.hand(
                        size: 18, color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              const Spacer(),

              // ── JOIN button ─────────────────────────────────────────────
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: _ready
                        ? () => context
                            .read<GameState>()
                            .joinRoom(_nameCtrl.text.trim())
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      decoration: BoxDecoration(
                        gradient: _ready
                            ? AppColors.crimsonButton
                            : const LinearGradient(
                                colors: [
                                  Color(0xFF4A1A1A),
                                  Color(0xFF2A0A0A)
                                ],
                              ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF4A0A10), width: 2),
                        boxShadow: _ready
                            ? [
                                const BoxShadow(
                                  color: Color(0xFF2A0509),
                                  offset: Offset(0, 3),
                                  blurRadius: 0,
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        '▶ ${t['join']!}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.theater(
                          size: 22,
                          color: _ready
                              ? AppColors.paper
                              : AppColors.textMuted,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -5,
                    left: 8,
                    right: 8,
                    child: BulbRowWidget(
                        count: 18,
                        mode: _ready
                            ? BulbRowMode.chase
                            : BulbRowMode.alt),
                  ),
                  Positioned(
                    bottom: -5,
                    left: 8,
                    right: 8,
                    child: BulbRowWidget(
                        count: 18,
                        mode: _ready
                            ? BulbRowMode.chase
                            : BulbRowMode.alt),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  t['noLogin']!,
                  style: AppTextStyles.hand(
                      size: 13,
                      color: AppColors.textDim,
                      style: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
