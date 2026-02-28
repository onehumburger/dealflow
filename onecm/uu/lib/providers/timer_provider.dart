import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/services/timer_service.dart';

final timerServiceProvider = Provider<TimerService>((ref) {
  final service = TimerService();
  ref.onDispose(() => service.dispose());
  return service;
});

final timerStateProvider = StreamProvider<TimerState>((ref) {
  return ref.watch(timerServiceProvider).stateStream;
});
