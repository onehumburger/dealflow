import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/app.dart';

void main() {
  testWidgets('UUApp renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UUApp()));
    expect(find.text('UU'), findsOneWidget);
  });
}
