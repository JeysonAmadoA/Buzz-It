import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/buzzer/buzzer_screen.dart';
import 'features/create_room/create_room_screen.dart';
import 'features/home/home_screen.dart';
import 'features/host_panel/host_panel_screen.dart';
import 'features/join_room/join_room_screen.dart';
import 'features/result/result_screen.dart';
import 'features/waiting/waiting_screen.dart';
import 'shared/state/game_state.dart';
import 'shared/theme/app_colors.dart';
import 'shared/widgets/flash_overlay.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const BuzzItApp(),
    ),
  );
}

class BuzzItApp extends StatelessWidget {
  const BuzzItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buzz It',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          secondary: AppColors.crimson,
          surface: AppColors.darkBase,
        ),
        scaffoldBackgroundColor: AppColors.darkBase,
        useMaterial3: true,
      ),
      home: const GameShell(),
    );
  }
}

/// Root shell — watches [GameState.route] and swaps screens with a fade
/// transition. Stacks [FlashOverlay] on top so it covers the full screen.
class GameShell extends StatelessWidget {
  const GameShell({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    return Scaffold(
      body: Stack(
        children: [
          // ── Screen router ─────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: KeyedSubtree(
              key: ValueKey(game.route),
              child: _screenFor(game.route),
            ),
          ),

          // ── Flash overlay (full-screen gold/white burst) ──────────────
          Positioned.fill(
            child: FlashOverlay(trigger: game.flashTrigger),
          ),
        ],
      ),
    );
  }

  Widget _screenFor(String route) {
    switch (route) {
      case 'home'        : return const HomeScreen();
      case 'create-room' : return const CreateRoomScreen();
      case 'join-room'   : return const JoinRoomScreen();
      case 'waiting'     : return const WaitingScreen();
      case 'host-panel'  : return const HostPanelScreen();
      case 'buzzer'      : return const BuzzerScreen();
      case 'result'      : return const ResultScreen();
      default            : return const HomeScreen();
    }
  }
}
