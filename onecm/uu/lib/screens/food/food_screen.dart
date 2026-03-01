import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/food_provider.dart';
import 'package:uu/services/food_service.dart';

class FoodScreen extends ConsumerStatefulWidget {
  const FoodScreen({super.key});

  @override
  ConsumerState<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends ConsumerState<FoodScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _categories = [
    'All',
    'Fruits',
    'Vegetables',
    'Grains',
    'Proteins',
    'Dairy',
    'Allergens',
  ];

  static const _categoryKeys = [
    null,
    'fruit',
    'vegetable',
    'grain',
    'protein',
    'dairy',
    'allergen',
  ];

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

    final foodsAsync = ref.watch(foodIntroductionsProvider);
    final waitRuleAsync = ref.watch(waitRuleStatusProvider);
    final service = ref.watch(foodServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Tracker'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: Column(
        children: [
          // 3-day wait rule indicator
          waitRuleAsync.when(
            data: (status) => _WaitRuleIndicator(status: status),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Food grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categoryKeys.map((categoryKey) {
                return foodsAsync.when(
                  data: (triedFoods) => _buildFoodGrid(
                    context,
                    category: categoryKey,
                    triedFoods: triedFoods,
                    service: service,
                    babyId: babyId,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodGrid(
    BuildContext context, {
    required String? category,
    required List<FoodIntroduction> triedFoods,
    required FoodService service,
    required int babyId,
  }) {
    final commonFoods = category == null
        ? service.allCommonFoods
        : service.getCommonFoodsByCategory(category);

    final triedFoodNames =
        triedFoods.map((f) => f.foodName.toLowerCase()).toSet();

    // Map tried food names to their records for reaction display.
    final triedFoodMap = <String, FoodIntroduction>{};
    for (final f in triedFoods) {
      triedFoodMap[f.foodName.toLowerCase()] = f;
    }

    if (commonFoods.isEmpty) {
      return const Center(child: Text('No foods in this category.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: commonFoods.length,
      itemBuilder: (context, index) {
        final food = commonFoods[index];
        final isTried = triedFoodNames.contains(food.name.toLowerCase());
        final record = triedFoodMap[food.name.toLowerCase()];

        return _FoodGridItem(
          food: food,
          isTried: isTried,
          record: record,
          onTap: () => _onFoodTap(food, isTried, record, babyId),
        );
      },
    );
  }

  Future<void> _onFoodTap(
    CommonFood food,
    bool isTried,
    FoodIntroduction? record,
    int babyId,
  ) async {
    if (isTried && record != null) {
      // Show details dialog with option to log reaction
      await _showFoodDetailsDialog(food, record);
    } else {
      // Log a new food introduction
      await _showLogFoodDialog(food, babyId);
    }
  }

  Future<void> _showLogFoodDialog(CommonFood food, int babyId) async {
    final now = DateTime.now();
    DateTime selectedDate = now;
    String? notes;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Introduce ${food.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (food.isAllergen)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber,
                          color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is a common allergen. Watch closely for reactions.',
                          style: TextStyle(
                              color: Colors.orange.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                ),
                subtitle: const Text('Date first tried'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: now,
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (v) => notes = v.isEmpty ? null : v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Log Food'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(foodRepositoryProvider).createFoodIntroduction(
            babyId: babyId,
            foodName: food.name,
            category: food.category,
            isAllergen: food.isAllergen,
            firstTriedAt: selectedDate,
            notes: notes,
          );
      // Invalidate wait rule to refresh
      ref.invalidate(waitRuleStatusProvider);
    }
  }

  Future<void> _showFoodDetailsDialog(
    CommonFood food,
    FoodIntroduction record,
  ) async {
    String? selectedSeverity = record.reactionSeverity;
    String? reactionText = record.reaction;

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(food.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'First tried: ${_formatDate(record.firstTriedAt)}',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              if (record.notes != null) ...[
                const SizedBox(height: 4),
                Text('Notes: ${record.notes}',
                    style: Theme.of(ctx).textTheme.bodySmall),
              ],
              const SizedBox(height: 16),
              const Text('Reaction'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedSeverity,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Severity',
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('None')),
                  DropdownMenuItem(value: 'mild', child: Text('Mild')),
                  DropdownMenuItem(
                      value: 'moderate', child: Text('Moderate')),
                  DropdownMenuItem(value: 'severe', child: Text('Severe')),
                ],
                onChanged: (v) =>
                    setDialogState(() => selectedSeverity = v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: reactionText),
                decoration: const InputDecoration(
                  labelText: 'Reaction details',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (v) => reactionText = v.isEmpty ? null : v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Save Reaction'),
            ),
          ],
        ),
      ),
    );

    if (updated == true && mounted) {
      await ref.read(foodRepositoryProvider).updateReaction(
            record.id,
            reaction: reactionText,
            reactionSeverity: selectedSeverity,
          );
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

// ── Wait Rule Indicator Widget ──────────────────────────────────────

class _WaitRuleIndicator extends StatelessWidget {
  final WaitRuleStatus status;

  const _WaitRuleIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (status.canIntroduce) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.green.shade50,
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              'Ready to introduce a new food',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.amber.shade50,
      child: Row(
        children: [
          Icon(Icons.schedule, color: Colors.amber.shade800, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${status.daysRemaining} day${status.daysRemaining == 1 ? '' : 's'} '
              'remaining since ${status.lastFoodName ?? 'last food'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.amber.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Food Grid Item Widget ───────────────────────────────────────────

class _FoodGridItem extends StatelessWidget {
  final CommonFood food;
  final bool isTried;
  final FoodIntroduction? record;
  final VoidCallback onTap;

  const _FoodGridItem({
    required this.food,
    required this.isTried,
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasReaction = record?.reactionSeverity != null &&
        record!.reactionSeverity != 'none';

    Color borderColor;
    if (hasReaction) {
      borderColor = _reactionColor(record!.reactionSeverity!);
    } else if (food.isAllergen) {
      borderColor = Colors.orange;
    } else if (isTried) {
      borderColor = theme.colorScheme.primary;
    } else {
      borderColor = theme.colorScheme.outlineVariant;
    }

    return Material(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isTried ? 2 : 1),
            color: isTried
                ? borderColor.withAlpha(20)
                : theme.colorScheme.surface,
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isTried ? Icons.check_circle : _categoryIcon(food.category),
                color: isTried ? borderColor : theme.colorScheme.onSurfaceVariant,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                food.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isTried ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (food.isAllergen && !isTried) ...[
                const SizedBox(height: 2),
                Icon(Icons.warning_amber,
                    size: 14, color: Colors.orange.shade700),
              ],
              if (hasReaction) ...[
                const SizedBox(height: 2),
                Text(
                  record!.reactionSeverity!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _reactionColor(record!.reactionSeverity!),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'fruit':
        return Icons.apple;
      case 'vegetable':
        return Icons.eco;
      case 'grain':
        return Icons.grain;
      case 'protein':
        return Icons.set_meal;
      case 'dairy':
        return Icons.local_cafe;
      case 'allergen':
        return Icons.warning_amber;
      default:
        return Icons.fastfood;
    }
  }

  Color _reactionColor(String severity) {
    switch (severity) {
      case 'mild':
        return Colors.yellow.shade800;
      case 'moderate':
        return Colors.orange.shade700;
      case 'severe':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }
}
