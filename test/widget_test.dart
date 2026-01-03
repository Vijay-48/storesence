import 'package:flutter_test/flutter_test.dart';
import 'package:storesence/main.dart';

void main() {
  testWidgets('StoreSence app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StoreSenceApp());

    // Verify splash screen appears
    expect(find.text('StoreSence'), findsOneWidget);
  });
}
