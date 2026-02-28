import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uu/providers/growth_provider.dart';

class GrowthSnapshotCard extends ConsumerWidget {
  const GrowthSnapshotCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(growthRecordsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Growth Snapshot',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            recordsAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No growth records yet. Add your first measurement!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  );
                }
                final latest = records.last;
                final dateStr = DateFormat.yMMMd().format(latest.date);
                return Row(
                  children: [
                    if (latest.weightKg != null)
                      _GrowthStat(
                        label: 'Weight',
                        value: '${latest.weightKg!.toStringAsFixed(1)} kg',
                      ),
                    if (latest.heightCm != null)
                      _GrowthStat(
                        label: 'Height',
                        value: '${latest.heightCm!.toStringAsFixed(1)} cm',
                      ),
                    if (latest.headCircumferenceCm != null)
                      _GrowthStat(
                        label: 'Head',
                        value:
                            '${latest.headCircumferenceCm!.toStringAsFixed(1)} cm',
                      ),
                    const Spacer(),
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                );
              },
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
}

class _GrowthStat extends StatelessWidget {
  final String label;
  final String value;

  const _GrowthStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
