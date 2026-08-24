import 'package:flutter_test/flutter_test.dart';
import 'package:riceproject/main.dart';

void main() {
  testWidgets('Paddy AI App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PaddyAiApp());
    expect(find.byType(PaddyAiApp), findsOneWidget);
  });
}
