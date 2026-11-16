import 'package:flutter_test/flutter_test.dart';
import 'package:snake_game/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BilgeYilanApp());
    expect(find.byType(BilgeYilanApp), findsOneWidget);
  });
}
