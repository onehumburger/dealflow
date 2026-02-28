import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/providers/timer_provider.dart';
import 'package:uu/services/timer_service.dart';
import 'package:uu/widgets/timer_mini_bar.dart';

void main() {
  group('TimerMiniBar', () {
    testWidgets('shows nothing when no timer active', (tester) async {
      final service = TimerService();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [timerServiceProvider.overrideWithValue(service)],
          child: const MaterialApp(home: Scaffold(body: TimerMiniBar())),
        ),
      );
      await tester.pump();
      // Should show nothing or a SizedBox.shrink
      expect(find.text('Feeding'), findsNothing);
      service.dispose();
    });

    testWidgets('shows timer info when feeding timer is active',
        (tester) async {
      final service = TimerService();
      service.start(TimerType.feeding);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [timerServiceProvider.overrideWithValue(service)],
          child: const MaterialApp(home: Scaffold(body: TimerMiniBar())),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Feeding'), findsOneWidget);
      service.stop();
      service.dispose();
    });

    testWidgets('shows pause and stop buttons when timer active',
        (tester) async {
      final service = TimerService();
      service.start(TimerType.sleep);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [timerServiceProvider.overrideWithValue(service)],
          child: const MaterialApp(home: Scaffold(body: TimerMiniBar())),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
      service.stop();
      service.dispose();
    });

    testWidgets('shows resume button when timer is paused', (tester) async {
      final service = TimerService();
      service.start(TimerType.tummyTime);
      service.pause();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [timerServiceProvider.overrideWithValue(service)],
          child: const MaterialApp(home: Scaffold(body: TimerMiniBar())),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      service.stop();
      service.dispose();
    });

    testWidgets('tapping stop button stops the timer', (tester) async {
      final service = TimerService();
      service.start(TimerType.feeding);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [timerServiceProvider.overrideWithValue(service)],
          child: const MaterialApp(home: Scaffold(body: TimerMiniBar())),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.stop), findsOneWidget);
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pump(const Duration(milliseconds: 100));

      expect(service.isRunning, isFalse);
      service.dispose();
    });

    testWidgets('tapping pause button pauses the timer', (tester) async {
      final service = TimerService();
      service.start(TimerType.sleep);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [timerServiceProvider.overrideWithValue(service)],
          child: const MaterialApp(home: Scaffold(body: TimerMiniBar())),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump(const Duration(milliseconds: 100));

      expect(service.isPaused, isTrue);
      service.stop();
      service.dispose();
    });
  });
}
