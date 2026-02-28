import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/timer_provider.dart';
import 'package:uu/services/timer_service.dart';

class TimerMiniBar extends ConsumerStatefulWidget {
  const TimerMiniBar({super.key});

  @override
  ConsumerState<TimerMiniBar> createState() => _TimerMiniBarState();
}

class _TimerMiniBarState extends ConsumerState<TimerMiniBar> {
  Timer? _tickTimer;

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  void _ensureTicking(TimerService service) {
    if (service.isRunning && _tickTimer == null) {
      _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!service.isRunning && _tickTimer != null) {
      _tickTimer?.cancel();
      _tickTimer = null;
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _timerTypeName(TimerType type) {
    switch (type) {
      case TimerType.feeding:
        return 'Feeding';
      case TimerType.sleep:
        return 'Sleep';
      case TimerType.tummyTime:
        return 'Tummy Time';
    }
  }

  IconData _timerTypeIcon(TimerType type) {
    switch (type) {
      case TimerType.feeding:
        return Icons.restaurant;
      case TimerType.sleep:
        return Icons.bedtime;
      case TimerType.tummyTime:
        return Icons.child_care;
    }
  }

  Color _timerTypeColor(TimerType type) {
    switch (type) {
      case TimerType.feeding:
        return const Color(0xFF4CAF50);
      case TimerType.sleep:
        return const Color(0xFF5C6BC0);
      case TimerType.tummyTime:
        return const Color(0xFFFF9800);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(timerServiceProvider);
    final timerState = ref.watch(timerStateProvider);

    return timerState.when(
      data: (state) {
        _ensureTicking(service);
        if (!state.isRunning) return const SizedBox.shrink();
        return _buildBar(context, service, state);
      },
      loading: () {
        // Check the service directly for initial state
        _ensureTicking(service);
        if (!service.isRunning) return const SizedBox.shrink();
        final state = TimerState(
          isRunning: service.isRunning,
          isPaused: service.isPaused,
          type: service.activeTimer?.type,
        );
        return _buildBar(context, service, state);
      },
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBar(
      BuildContext context, TimerService service, TimerState state) {
    final type = state.type!;
    final color = _timerTypeColor(type);
    final elapsed = service.activeTimer?.elapsed ?? Duration.zero;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          border: Border(top: BorderSide(color: color.withAlpha(80))),
        ),
        child: Row(
          children: [
            Icon(_timerTypeIcon(type), color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              _timerTypeName(type),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Text(
              _formatDuration(elapsed),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: color,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                state.isPaused ? Icons.play_arrow : Icons.pause,
                color: color,
              ),
              onPressed: () {
                if (state.isPaused) {
                  service.resume();
                } else {
                  service.pause();
                }
              },
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            IconButton(
              icon: Icon(Icons.stop, color: color),
              onPressed: () {
                service.stop();
              },
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      ),
    );
  }
}
