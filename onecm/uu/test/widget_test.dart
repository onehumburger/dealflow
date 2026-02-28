import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/app.dart';

void main() {
  testWidgets('UUApp renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UUApp()));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
