import 'package:flutter_test/flutter_test.dart';
import 'package:prelowear/main.dart';

void main() {
  testWidgets('PreloWear app can be rendered',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PreloWearApp());

    expect(find.byType(PreloWearApp), findsOneWidget);
  });
}
