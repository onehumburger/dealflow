import 'package:flutter_test/flutter_test.dart';
import 'package:uu/services/timer_service.dart';

void main() {
  group('TimerService', () {
    late TimerService service;
    setUp(() => service = TimerService());
    tearDown(() => service.dispose());

    test('starts with no active timer', () {
      expect(service.isRunning, false);
      expect(service.activeTimer, isNull);
    });

    test('can start a feeding timer', () {
      service.start(TimerType.feeding, metadata: {'side': 'left'});
      expect(service.isRunning, true);
      expect(service.activeTimer?.type, TimerType.feeding);
      expect(service.activeTimer?.metadata['side'], 'left');
    });

    test('elapsed time increases', () async {
      service.start(TimerType.feeding);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(service.activeTimer!.elapsed.inMilliseconds, greaterThan(50));
    });

    test('can pause and resume', () async {
      service.start(TimerType.sleep);
      await Future.delayed(const Duration(milliseconds: 100));
      service.pause();
      expect(service.isPaused, true);
      final pausedElapsed = service.activeTimer!.elapsed;
      await Future.delayed(const Duration(milliseconds: 100));
      expect(service.activeTimer!.elapsed.inMilliseconds,
          closeTo(pausedElapsed.inMilliseconds, 20));
      service.resume();
      expect(service.isPaused, false);
    });

    test('stop returns the timer result', () async {
      service.start(TimerType.feeding, metadata: {'side': 'left'});
      await Future.delayed(const Duration(milliseconds: 100));
      final result = service.stop();
      expect(result, isNotNull);
      expect(result!.type, TimerType.feeding);
      expect(result.startedAt, isNotNull);
      expect(result.endedAt, isNotNull);
      expect(result.duration.inMilliseconds, greaterThan(50));
      expect(service.isRunning, false);
    });

    test('emits state changes via stream', () async {
      expectLater(
        service.stateStream,
        emitsInOrder([
          predicate<TimerState>((s) => s.isRunning),
          predicate<TimerState>((s) => !s.isRunning),
        ]),
      );
      service.start(TimerType.feeding);
      await Future.delayed(const Duration(milliseconds: 50));
      service.stop();
    });
  });
}
