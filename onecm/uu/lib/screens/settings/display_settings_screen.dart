import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/auto_dark_mode_provider.dart';
import 'package:uu/providers/theme_provider.dart';

class DisplaySettingsScreen extends ConsumerWidget {
  const DisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(darkModeScheduleProvider);
    final manualMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Display Settings')),
      body: ListView(
        children: [
          // Manual theme selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Theme',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          RadioGroup<ThemeMode>(
            groupValue: manualMode,
            onChanged: (v) {
              if (v != null) {
                ref.read(themeModeProvider.notifier).state = v;
              }
            },
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System default'),
                  value: ThemeMode.system,
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
          const Divider(),

          // Auto dark mode section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Auto Dark Mode',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          SwitchListTile(
            title: const Text('Scheduled dark mode'),
            subtitle: schedule.enabled
                ? Text(
                    '${_formatTime(schedule.startHour, schedule.startMinute)}'
                    ' - '
                    '${_formatTime(schedule.endHour, schedule.endMinute)}')
                : const Text('Off'),
            value: schedule.enabled,
            onChanged: (value) {
              ref.read(darkModeScheduleProvider.notifier).state =
                  schedule.copyWith(enabled: value);
            },
          ),
          if (schedule.enabled) ...[
            ListTile(
              title: const Text('Start time'),
              trailing: Text(
                _formatTime(schedule.startHour, schedule.startMinute),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: schedule.startHour,
                    minute: schedule.startMinute,
                  ),
                );
                if (picked != null) {
                  ref.read(darkModeScheduleProvider.notifier).state =
                      schedule.copyWith(
                    startHour: picked.hour,
                    startMinute: picked.minute,
                  );
                }
              },
            ),
            ListTile(
              title: const Text('End time'),
              trailing: Text(
                _formatTime(schedule.endHour, schedule.endMinute),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: schedule.endHour,
                    minute: schedule.endMinute,
                  ),
                );
                if (picked != null) {
                  ref.read(darkModeScheduleProvider.notifier).state =
                      schedule.copyWith(
                    endHour: picked.hour,
                    endMinute: picked.minute,
                  );
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Dark mode activates automatically during the scheduled '
                'window. Brightness is reduced and animations are minimised '
                'to help with nighttime use.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final tod = TimeOfDay(hour: hour, minute: minute);
    final h = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final m = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}
