import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/growth_provider.dart';
import 'package:uu/screens/growth/widgets/growth_entry_form.dart';
import 'package:uu/screens/growth/widgets/percentile_chart.dart';
import 'package:uu/services/who_growth_standards.dart';

class GrowthChartScreen extends ConsumerWidget {
  const GrowthChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(growthRecordsProvider);
    final babiesAsync = ref.watch(allBabiesProvider);
    final babyId = ref.watch(selectedBabyIdProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Growth Charts'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Weight'),
              Tab(text: 'Height'),
              Tab(text: 'Head'),
            ],
          ),
        ),
        body: recordsAsync.when(
          data: (records) {
            // Get baby's info for gender and date of birth
            return babiesAsync.when(
              data: (babies) {
                final baby = babyId != null
                    ? babies.where((b) => b.id == babyId).firstOrNull ??
                        babies.firstOrNull
                    : babies.firstOrNull;

                if (baby == null) {
                  return const Center(child: Text('No baby selected'));
                }

                final gender = baby.gender?.toLowerCase() == 'female'
                    ? Gender.female
                    : Gender.male;

                return TabBarView(
                  children: [
                    PercentileChart(
                      measurementType: MeasurementType.weight,
                      gender: gender,
                      records: records,
                      dateOfBirth: baby.dateOfBirth,
                    ),
                    PercentileChart(
                      measurementType: MeasurementType.height,
                      gender: gender,
                      records: records,
                      dateOfBirth: baby.dateOfBirth,
                    ),
                    PercentileChart(
                      measurementType: MeasurementType.headCircumference,
                      gender: gender,
                      records: records,
                      dateOfBirth: baby.dateOfBirth,
                    ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddMeasurementSheet(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddMeasurementSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const GrowthEntryForm(),
    );
  }
}
