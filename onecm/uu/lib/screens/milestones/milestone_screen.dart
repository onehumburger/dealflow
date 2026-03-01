import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/milestone_provider.dart';
import 'package:uu/services/milestone_service.dart';

class MilestoneScreen extends ConsumerStatefulWidget {
  const MilestoneScreen({super.key});

  @override
  ConsumerState<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends ConsumerState<MilestoneScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _categories = ['All', 'Motor', 'Language', 'Social', 'Cognitive'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final babyId = ref.watch(selectedBabyIdProvider);
    if (babyId == null) {
      return const Center(child: Text('Please select a baby first.'));
    }

    final milestonesAsync = ref.watch(milestonesProvider);
    final service = ref.watch(milestoneServiceProvider);
    final allExpected = service.allExpectedMilestones;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestones'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          return milestonesAsync.when(
            data: (achievedMilestones) => _buildMilestoneList(
              context,
              category: category == 'All' ? null : category.toLowerCase(),
              allExpected: allExpected,
              achievedMilestones: achievedMilestones,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMilestoneList(
    BuildContext context, {
    required String? category,
    required List<ExpectedMilestone> allExpected,
    required List<Milestone> achievedMilestones,
  }) {
    final achievedTitles =
        achievedMilestones.map((m) => m.title).toSet();

    final expected = category == null
        ? allExpected
        : allExpected.where((m) => m.category == category).toList();

    if (expected.isEmpty) {
      return const Center(child: Text('No milestones in this category.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: expected.length,
      itemBuilder: (context, index) {
        final milestone = expected[index];
        final isAchieved = achievedTitles.contains(milestone.title);
        final achievedRecord = isAchieved
            ? achievedMilestones
                .where((m) => m.title == milestone.title)
                .firstOrNull
            : null;

        return _MilestoneListItem(
          milestone: milestone,
          isAchieved: isAchieved,
          achievedAt: achievedRecord?.achievedAt,
          onTap: () => _onMilestoneTap(milestone, isAchieved, achievedRecord),
        );
      },
    );
  }

  Future<void> _onMilestoneTap(
    ExpectedMilestone expected,
    bool isAchieved,
    Milestone? record,
  ) async {
    if (isAchieved) return;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'When did this milestone happen?',
    );
    if (picked == null || !mounted) return;

    final babyId = ref.read(selectedBabyIdProvider);
    if (babyId == null) return;

    await ref.read(milestoneRepositoryProvider).createMilestone(
          babyId: babyId,
          category: expected.category,
          title: expected.title,
          description: expected.description,
          achievedAt: picked,
          expectedAgeMonths: expected.expectedAgeMonths,
        );
  }
}

class _MilestoneListItem extends StatelessWidget {
  final ExpectedMilestone milestone;
  final bool isAchieved;
  final DateTime? achievedAt;
  final VoidCallback onTap;

  const _MilestoneListItem({
    required this.milestone,
    required this.isAchieved,
    required this.achievedAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        isAchieved ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isAchieved
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant.withAlpha(100),
        size: 28,
      ),
      title: Text(
        milestone.title,
        style: TextStyle(
          fontWeight: isAchieved ? FontWeight.w600 : FontWeight.normal,
          color: isAchieved ? null : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        isAchieved && achievedAt != null
            ? 'Achieved ${_formatDate(achievedAt!)}'
            : 'Expected around ${milestone.expectedAgeMonths} months',
        style: theme.textTheme.bodySmall,
      ),
      trailing: _categoryIcon(milestone.category, theme),
      onTap: onTap,
    );
  }

  Widget _categoryIcon(String category, ThemeData theme) {
    final IconData icon;
    switch (category) {
      case 'motor':
        icon = Icons.directions_run;
      case 'language':
        icon = Icons.record_voice_over;
      case 'social':
        icon = Icons.people;
      case 'cognitive':
        icon = Icons.psychology;
      default:
        icon = Icons.star;
    }
    return Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant);
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
