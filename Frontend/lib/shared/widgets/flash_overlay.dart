import 'package:flutter/material.dart';

/// Full-screen gold/white flash overlay.
///
/// Invisible at rest. Triggered by incrementing [trigger]:
/// fades in instantly, fades out over 700ms.
class FlashOverlay extends StatefulWidget {
  const FlashOverlay({super.key, required this.trigger});

  final int trigger;

  @override
  State<FlashOverlay> createState() => _FlashOverlayState();
}

class _FlashOverlayState extends State<FlashOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _active = false);
      }
    });
  }

  @override
  void didUpdateWidget(FlashOverlay old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger && widget.trigger > 0) {
      setState(() => _active = true);
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_active) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => IgnorePointer(
        child: Opacity(
          // 1.0 → 0.0 as controller goes 0 → 1
          opacity: (1.0 - _ctrl.value).clamp(0.0, 1.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                colors: [
                  Color(0xFFFFF7C2),
                  Color(0xFFF58C28),
                  Color(0x006A1016),
                ],
                stops: [0.0, 0.3, 0.7],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
