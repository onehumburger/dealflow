import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/daily_log_provider.dart';

class TodaySummaryCard extends ConsumerWidget {
  const TodaySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(todaySummaryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Summary",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            summaryAsync.when(
              data: (summary) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(
                    icon: Icons.restaurant,
                    label: 'Feedings',
                    value: '${summary.feedingCount}',
                  ),
                  _SummaryItem(
                    icon: Icons.bedtime,
                    label: 'Sleep',
                    value: _formatSleepHours(summary.totalSleepMinutes),
                  ),
                  _SummaryItem(
                    icon: Icons.baby_changing_station,
                    label: 'Diapers',
                    value: '${summary.diaperCount}',
                  ),
                ],
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSleepHours(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, size: 24, color: colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
