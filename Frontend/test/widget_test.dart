import 'package:flutter_test/flutter_test.dart';
import 'package:buzz_it/main.dart';
import 'package:provider/provider.dart';
import 'package:buzz_it/shared/state/game_state.dart';

void main() {
  testWidgets('App renders home screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameState(),
        child: const BuzzItApp(),
      ),
    );
    // App should render without throwing
    expect(find.byType(BuzzItApp), findsOneWidget);
  });
}
