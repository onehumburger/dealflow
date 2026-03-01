import 'package:flutter/material.dart';

/// Quick-concern categories for the chat screen.
/// Tapping a chip inserts it as a user message.
class QuickConcernChips extends StatelessWidget {
  final void Function(String concern) onConcernTapped;

  const QuickConcernChips({
    super.key,
    required this.onConcernTapped,
  });

  static const concerns = [
    _Concern('Sleep', Icons.bedtime_outlined),
    _Concern('Feeding', Icons.restaurant_outlined),
    _Concern('Skin/Rash', Icons.healing_outlined),
    _Concern('Behavior', Icons.psychology_outlined),
    _Concern('Growth', Icons.trending_up_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick concerns',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: concerns.map((concern) {
              return ActionChip(
                avatar: Icon(concern.icon, size: 16),
                label: Text(concern.label),
                onPressed: () => onConcernTapped(
                  'I have a concern about my baby\'s ${concern.label.toLowerCase()}. Can you help?',
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Concern {
  final String label;
  final IconData icon;

  const _Concern(this.label, this.icon);
}
