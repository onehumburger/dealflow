import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/notification_settings_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _feedingEnabled = true;
  int _feedingInterval = 120;
  bool _diaperEnabled = true;
  int _diaperInterval = 120;
  bool _loaded = false;

  static const _intervalOptions = [30, 60, 90, 120, 180, 240];

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(notificationSettingsProvider);

    settingsAsync.whenData((settings) {
      if (!_loaded) {
        for (final s in settings) {
          if (s.type == 'feeding') {
            _feedingEnabled = s.enabled;
            _feedingInterval = s.intervalMinutes;
          } else if (s.type == 'diaper') {
            _diaperEnabled = s.enabled;
            _diaperInterval = s.intervalMinutes;
          }
        }
        _loaded = true;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          _buildReminderTile(
            label: 'Feeding Reminders',
            enabled: _feedingEnabled,
            interval: _feedingInterval,
            onToggle: (value) {
              setState(() => _feedingEnabled = value);
              _save('feeding', _feedingEnabled, _feedingInterval);
            },
            onIntervalChanged: (value) {
              setState(() => _feedingInterval = value);
              _save('feeding', _feedingEnabled, _feedingInterval);
            },
          ),
          const Divider(),
          _buildReminderTile(
            label: 'Diaper Reminders',
            enabled: _diaperEnabled,
            interval: _diaperInterval,
            onToggle: (value) {
              setState(() => _diaperEnabled = value);
              _save('diaper', _diaperEnabled, _diaperInterval);
            },
            onIntervalChanged: (value) {
              setState(() => _diaperInterval = value);
              _save('diaper', _diaperEnabled, _diaperInterval);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTile({
    required String label,
    required bool enabled,
    required int interval,
    required ValueChanged<bool> onToggle,
    required ValueChanged<int> onIntervalChanged,
  }) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(label),
          value: enabled,
          onChanged: onToggle,
        ),
        if (enabled)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('Remind every '),
                DropdownButton<int>(
                  value: interval,
                  items: _intervalOptions
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(_formatInterval(m)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onIntervalChanged(v);
                  },
                ),
                const Text(' interval'),
              ],
            ),
          ),
      ],
    );
  }

  String _formatInterval(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }

  void _save(String type, bool enabled, int intervalMinutes) {
    final babyId = ref.read(selectedBabyIdProvider);
    if (babyId == null) return;
    ref.read(notificationSettingsActionsProvider).upsertSetting(
          babyId: babyId,
          type: type,
          enabled: enabled,
          intervalMinutes: intervalMinutes,
        );
    ref.invalidate(notificationSettingsProvider);
  }
}
