import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/screens/home/widgets/quick_log_buttons.dart';
import 'package:uu/screens/home/widgets/today_summary_card.dart';
import 'package:uu/screens/home/widgets/growth_snapshot_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyId = ref.watch(selectedBabyIdProvider);
    final babiesAsync = ref.watch(allBabiesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baby header
          babiesAsync.when(
            data: (babies) {
              if (babies.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No baby added yet. Add your baby to get started!',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                );
              }
              final baby = babyId != null
                  ? babies.where((b) => b.id == babyId).firstOrNull ??
                      babies.first
                  : babies.first;
              final age = _formatAge(baby.dateOfBirth);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baby.name,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      age,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 8),

          // Quick-log buttons
          const QuickLogButtons(),

          const SizedBox(height: 16),

          // Today's Summary card
          const TodaySummaryCard(),

          const SizedBox(height: 12),

          // Growth Snapshot card
          const GrowthSnapshotCard(),
        ],
      ),
    );
  }

  String _formatAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    final months =
        (now.year - dateOfBirth.year) * 12 + now.month - dateOfBirth.month;
    if (months < 1) {
      final days = now.difference(dateOfBirth).inDays;
      return '$days day${days == 1 ? '' : 's'} old';
    }
    if (months < 12) {
      return '$months month${months == 1 ? '' : 's'} old';
    }
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (remainingMonths == 0) {
      return '$years year${years == 1 ? '' : 's'} old';
    }
    return '$years year${years == 1 ? '' : 's'}, $remainingMonths month${remainingMonths == 1 ? '' : 's'} old';
  }
}
