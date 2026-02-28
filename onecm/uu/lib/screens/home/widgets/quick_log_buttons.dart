import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/daily_log_provider.dart';

class _QuickLogItem {
  final String label;
  final IconData icon;
  final String type;

  const _QuickLogItem({
    required this.label,
    required this.icon,
    required this.type,
  });
}

const _quickLogItems = [
  _QuickLogItem(label: 'Fed', icon: Icons.restaurant, type: 'feeding'),
  _QuickLogItem(label: 'Diaper', icon: Icons.baby_changing_station, type: 'diaper'),
  _QuickLogItem(label: 'Sleep', icon: Icons.bedtime, type: 'sleep'),
  _QuickLogItem(label: 'Mood', icon: Icons.mood, type: 'mood'),
];

class QuickLogButtons extends ConsumerWidget {
  const QuickLogButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyId = ref.watch(selectedBabyIdProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _quickLogItems.map((item) {
        return _QuickLogButton(
          label: item.label,
          icon: item.icon,
          onTap: babyId == null
              ? null
              : () async {
                  await ref
                      .read(dailyLogRepositoryProvider)
                      .quickLog(babyId: babyId, type: item.type);
                  ref.invalidate(todayLogsProvider);
                  ref.invalidate(todaySummaryProvider);
                },
        );
      }).toList(),
    );
  }
}

class _QuickLogButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _QuickLogButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: colorScheme.primary),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
