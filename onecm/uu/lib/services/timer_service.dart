import 'dart:async';

enum TimerType { feeding, sleep, tummyTime }

class ActiveTimer {
  final TimerType type;
  final DateTime startedAt;
  final Map<String, dynamic> metadata;
  DateTime? _pausedAt;
  Duration _pausedDuration = Duration.zero;

  ActiveTimer({
    required this.type,
    required this.startedAt,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  bool get isPaused => _pausedAt != null;

  Duration get elapsed {
    final now = _pausedAt ?? DateTime.now();
    return now.difference(startedAt) - _pausedDuration;
  }

  void pause() {
    if (_pausedAt == null) {
      _pausedAt = DateTime.now();
    }
  }

  void resume() {
    if (_pausedAt != null) {
      _pausedDuration += DateTime.now().difference(_pausedAt!);
      _pausedAt = null;
    }
  }
}

class TimerResult {
  final TimerType type;
  final DateTime startedAt;
  final DateTime endedAt;
  final Duration duration;
  final Map<String, dynamic> metadata;

  TimerResult({
    required this.type,
    required this.startedAt,
    required this.endedAt,
    required this.duration,
    required this.metadata,
  });
}

class TimerState {
  final bool isRunning;
  final bool isPaused;
  final TimerType? type;

  TimerState({
    required this.isRunning,
    this.isPaused = false,
    this.type,
  });
}

class TimerService {
  ActiveTimer? _activeTimer;
  final StreamController<TimerState> _stateController =
      StreamController<TimerState>.broadcast();

  Stream<TimerState> get stateStream => _stateController.stream;

  ActiveTimer? get activeTimer => _activeTimer;

  bool get isRunning => _activeTimer != null;

  bool get isPaused => _activeTimer?.isPaused ?? false;

  void start(TimerType type, {Map<String, dynamic>? metadata}) {
    _activeTimer = ActiveTimer(
      type: type,
      startedAt: DateTime.now(),
      metadata: metadata,
    );
    _emitState();
  }

  void pause() {
    _activeTimer?.pause();
    _emitState();
  }

  void resume() {
    _activeTimer?.resume();
    _emitState();
  }

  TimerResult? stop() {
    if (_activeTimer == null) return null;
    final timer = _activeTimer!;
    if (timer.isPaused) {
      timer.resume();
    }
    final endedAt = DateTime.now();
    final result = TimerResult(
      type: timer.type,
      startedAt: timer.startedAt,
      endedAt: endedAt,
      duration: timer.elapsed,
      metadata: timer.metadata,
    );
    _activeTimer = null;
    _emitState();
    return result;
  }

  void _emitState() {
    _stateController.add(TimerState(
      isRunning: isRunning,
      isPaused: isPaused,
      type: _activeTimer?.type,
    ));
  }

  void dispose() {
    _stateController.close();
  }
}
