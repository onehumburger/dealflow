import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/screens/baby/add_baby_screen.dart';

/// A widget that shows the currently selected baby with a dropdown to switch
/// between children. Intended to be used as the AppBar title.
class ChildSelector extends ConsumerWidget {
  const ChildSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babiesAsync = ref.watch(allBabiesProvider);
    final selectedId = ref.watch(selectedBabyIdProvider);

    return babiesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const Text('UU'),
      data: (babies) {
        if (babies.isEmpty || selectedId == null) {
          return const Text('Select Child');
        }

        final selected = babies.cast<Baby?>().firstWhere(
              (b) => b!.id == selectedId,
              orElse: () => null,
            );

        if (selected == null) {
          return const Text('Select Child');
        }

        return GestureDetector(
          onTap: () => _showChildSheet(context, ref, babies, selectedId),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: _genderColor(selected.gender, context),
                child: const Icon(
                  Icons.child_care,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  selected.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        );
      },
    );
  }

  Color _genderColor(String? gender, BuildContext context) {
    switch (gender) {
      case 'female':
        return Colors.pink.shade300;
      case 'male':
        return Colors.blue.shade300;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  void _showChildSheet(
    BuildContext context,
    WidgetRef ref,
    List<Baby> babies,
    int selectedId,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Switch Child',
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...babies.map((baby) => _BabyTile(
                    baby: baby,
                    isSelected: baby.id == selectedId,
                    onTap: () {
                      ref.read(selectedBabyIdProvider.notifier).state = baby.id;
                      Navigator.of(sheetContext).pop();
                    },
                  )),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(sheetContext)
                      .colorScheme
                      .primaryContainer,
                  child: Icon(
                    Icons.add,
                    color: Theme.of(sheetContext).colorScheme.primary,
                  ),
                ),
                title: const Text('Add Child'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProviderScope(
                        parent: ProviderScope.containerOf(context),
                        child: const AddBabyScreen(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _BabyTile extends StatelessWidget {
  const _BabyTile({
    required this.baby,
    required this.isSelected,
    required this.onTap,
  });

  final Baby baby;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final age = _formatAge(baby.dateOfBirth);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _genderColor(baby.gender, context),
        child: const Icon(
          Icons.child_care,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        baby.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(age),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }

  Color _genderColor(String? gender, BuildContext context) {
    switch (gender) {
      case 'female':
        return Colors.pink.shade300;
      case 'male':
        return Colors.blue.shade300;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    final months = (now.year - dateOfBirth.year) * 12 +
        now.month - dateOfBirth.month;

    if (months < 1) {
      final days = now.difference(dateOfBirth).inDays;
      return '$days ${days == 1 ? 'day' : 'days'} old';
    } else if (months < 24) {
      return '$months ${months == 1 ? 'month' : 'months'} old';
    } else {
      final years = months ~/ 12;
      return '$years ${years == 1 ? 'year' : 'years'} old';
    }
  }
}
