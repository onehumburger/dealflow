import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/widget_data_provider.dart';
import 'package:uu/services/widget_data_service.dart';

class QuickStatusWidget extends ConsumerWidget {
  const QuickStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(widgetDataProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatusItem(
                    icon: Icons.restaurant,
                    label: 'Last feed',
                    value: data.timeSinceLastFeed != null
                        ? '${WidgetData.formatDuration(data.timeSinceLastFeed)} ago'
                        : 'No feeds',
                    status: data.feedStatus,
                  ),
                ),
                Expanded(
                  child: _StatusItem(
                    icon: Icons.baby_changing_station,
                    label: 'Last diaper',
                    value: data.timeSinceLastDiaper != null
                        ? '${WidgetData.formatDuration(data.timeSinceLastDiaper)} ago'
                        : 'No diapers',
                    status: data.diaperStatus,
                  ),
                ),
                Expanded(
                  child: _StatusItem(
                    icon: Icons.bedtime,
                    label: 'Next nap',
                    value: data.estimatedNextNap != null
                        ? data.estimatedNextNap == Duration.zero
                            ? 'Due now'
                            : '~${WidgetData.formatDuration(data.estimatedNextNap)}'
                        : 'No data',
                    status: data.napStatus,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final WidgetStatus status;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
  });

  Color _statusColor(ColorScheme colorScheme) {
    switch (status) {
      case WidgetStatus.green:
        return Colors.green;
      case WidgetStatus.yellow:
        return Colors.orange;
      case WidgetStatus.red:
        return colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme);

    return Column(
      children: [
        Icon(icon, size: 24, color: statusColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
