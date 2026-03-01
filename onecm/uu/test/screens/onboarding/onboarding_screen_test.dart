import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/screens/onboarding/onboarding_screen.dart';
import 'package:uu/screens/onboarding/widgets/onboarding_page.dart';

void main() {
  group('OnboardingPage widget', () {
    testWidgets('renders icon, title, and description', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingPage(
              icon: Icons.star,
              title: 'Test Title',
              description: 'Test description text',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test description text'), findsOneWidget);
    });

    testWidgets('renders action widget when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingPage(
              icon: Icons.star,
              title: 'Title',
              description: 'Desc',
              action: ElevatedButton(
                onPressed: () {},
                child: const Text('Action'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Action'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('does not render action widget when null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingPage(
              icon: Icons.star,
              title: 'Title',
              description: 'Desc',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  group('OnboardingScreen', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async => await db.close());

    Widget buildTestWidget() {
      return ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: OnboardingScreen()),
      );
    }

    testWidgets('shows welcome page initially', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Welcome to UU'), findsOneWidget);
      expect(
        find.text("Track your baby's growth journey"),
        findsOneWidget,
      );
    });

    testWidgets('shows dot indicators', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Should have dot indicators (one per page)
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('shows Skip button on first page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('shows Next button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('navigates to second page on Next tap', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Features page should now be visible
      expect(find.text('Powerful Features'), findsOneWidget);
    });

    testWidgets('shows Back button on second page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('navigates back to first page on Back tap', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Go to second page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Go back
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to UU'), findsOneWidget);
    });

    testWidgets('can navigate to features page and see feature highlights',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Powerful Features'), findsOneWidget);
      expect(find.text('Growth Tracking'), findsOneWidget);
      expect(find.text('AI Chat'), findsOneWidget);
      expect(find.text('Smart Notifications'), findsOneWidget);
    });

    testWidgets('can navigate to permissions page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Navigate to page 3 (permissions)
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Stay Connected'), findsOneWidget);
    });

    testWidgets('shows baby setup page as last page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Navigate to last page (baby setup)
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Baby setup page should show the form
      expect(find.textContaining('baby'), findsWidgets);
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('Skip button jumps to baby setup page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Should be on the last page with the baby form
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('does not show Skip button on last page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Navigate to last page
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('shows Get Started button on last page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Navigate to last page
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('does not show Next button on last page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Navigate to last page
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsNothing);
    });

    testWidgets('validates empty name on last page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Navigate to last page
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Tap Get Started without entering a name
      await tester.tap(find.text('Get Started'));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('shows gender choice chips on last page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Navigate to last page
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.byType(ChoiceChip), findsWidgets);
    });

    testWidgets('can swipe between pages', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Swipe left to go to next page
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('Powerful Features'), findsOneWidget);
    });
  });
}
