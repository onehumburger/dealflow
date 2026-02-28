import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/daily_log_provider.dart';
import 'package:uu/screens/logs/widgets/log_timeline_item.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Feeding', 'Sleep', 'Diaper', 'Mood'];

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(todayLogsProvider);

    return Column(
      children: [
        // Filter chips row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedFilter = filter);
                  },
                );
              },
            ),
          ),
        ),

        // Logs list
        Expanded(
          child: logsAsync.when(
            data: (logs) {
              final filteredLogs = _applyFilter(logs);
              if (filteredLogs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 48,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withAlpha(100),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No logs yet today',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: filteredLogs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return LogTimelineItem(log: filteredLogs[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }

  List<DailyLog> _applyFilter(List<DailyLog> logs) {
    if (_selectedFilter == 'All') return logs;
    return logs
        .where(
            (log) => log.type.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }
}
