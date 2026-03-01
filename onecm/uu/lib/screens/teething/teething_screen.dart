import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/teeth_provider.dart';
import 'package:uu/services/teeth_service.dart';

class TeethingScreen extends ConsumerStatefulWidget {
  const TeethingScreen({super.key});

  @override
  ConsumerState<TeethingScreen> createState() => _TeethingScreenState();
}

class _TeethingScreenState extends ConsumerState<TeethingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final babyId = ref.watch(selectedBabyIdProvider);
    if (babyId == null) {
      return const Scaffold(
        body: Center(child: Text('Please select a baby first.')),
      );
    }

    final teethAsync = ref.watch(teethRecordsProvider);
    final service = ref.watch(teethServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Teething Map')),
      body: teethAsync.when(
        data: (records) => _buildBody(context, service, records, babyId),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TeethService service,
    List<TeethRecord> records,
    int babyId,
  ) {
    final eruptedPositions = <String, TeethRecord>{};
    for (final r in records) {
      eruptedPositions[r.toothPosition] = r;
    }
    final eruptedCount = eruptedPositions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Counter
          _EruptionCounter(erupted: eruptedCount, total: 20),
          const SizedBox(height: 24),
          // Jaw diagram
          _JawDiagram(
            service: service,
            eruptedPositions: eruptedPositions,
            babyId: babyId,
            pulseAnimation: _pulseController,
            onToothTap: (tooth) => _onToothTap(tooth, eruptedPositions, babyId),
          ),
          const SizedBox(height: 24),
          // Legend
          const _Legend(),
          const SizedBox(height: 16),
          // Eruption timeline
          _EruptionTimeline(
            service: service,
            eruptedPositions: eruptedPositions,
          ),
        ],
      ),
    );
  }

  Future<void> _onToothTap(
    ToothInfo tooth,
    Map<String, TeethRecord> eruptedPositions,
    int babyId,
  ) async {
    final existing = eruptedPositions[tooth.position];

    if (existing != null) {
      // Already erupted -- offer to undo
      final shouldClear = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(tooth.name),
          content: Text(
            'Marked as erupted on '
            '${_formatDate(existing.eruptedAt)}.\n\n'
            'Would you like to remove this record?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove'),
            ),
          ],
        ),
      );
      if (shouldClear == true && mounted) {
        await ref.read(teethRepositoryProvider).clearEruption(existing.id);
      }
      return;
    }

    // Not yet erupted -- pick date
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'When did this tooth erupt?',
    );
    if (picked == null || !mounted) return;

    await ref.read(teethRepositoryProvider).markErupted(
          babyId: babyId,
          toothPosition: tooth.position,
          eruptedAt: picked,
        );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

// ── Counter widget ──────────────────────────────────────────────────────────

class _EruptionCounter extends StatelessWidget {
  final int erupted;
  final int total;

  const _EruptionCounter({required this.erupted, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total > 0 ? erupted / total : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '$erupted of $total teeth erupted',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Jaw diagram ─────────────────────────────────────────────────────────────

class _JawDiagram extends StatelessWidget {
  final TeethService service;
  final Map<String, TeethRecord> eruptedPositions;
  final int babyId;
  final AnimationController pulseAnimation;
  final void Function(ToothInfo) onToothTap;

  const _JawDiagram({
    required this.service,
    required this.eruptedPositions,
    required this.babyId,
    required this.pulseAnimation,
    required this.onToothTap,
  });

  @override
  Widget build(BuildContext context) {
    final upperTeeth = service.getTeethForJaw('upper');
    final lowerTeeth = service.getTeethForJaw('lower');

    return Column(
      children: [
        Text('Upper Jaw', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _ToothArch(
          teeth: upperTeeth,
          eruptedPositions: eruptedPositions,
          isUpper: true,
          pulseAnimation: pulseAnimation,
          onToothTap: onToothTap,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        const SizedBox(height: 12),
        _ToothArch(
          teeth: lowerTeeth,
          eruptedPositions: eruptedPositions,
          isUpper: false,
          pulseAnimation: pulseAnimation,
          onToothTap: onToothTap,
        ),
        const SizedBox(height: 8),
        Text('Lower Jaw', style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}

// ── Tooth arch (renders 10 teeth in a curved layout) ────────────────────────

class _ToothArch extends StatelessWidget {
  final List<ToothInfo> teeth;
  final Map<String, TeethRecord> eruptedPositions;
  final bool isUpper;
  final AnimationController pulseAnimation;
  final void Function(ToothInfo) onToothTap;

  const _ToothArch({
    required this.teeth,
    required this.eruptedPositions,
    required this.isUpper,
    required this.pulseAnimation,
    required this.onToothTap,
  });

  @override
  Widget build(BuildContext context) {
    // Layout: arrange 10 teeth in an arch.
    // For upper jaw: molars at edges, incisors in center, curve opens downward.
    // For lower jaw: molars at edges, incisors in center, curve opens upward.
    //
    // Order for upper: E D C B A | F G H I J  (right-to-left then left-to-right)
    // Order for lower: O N M L K | P Q R S T  (left-to-right then right-to-left -- mirrored)

    // Sort teeth for display: for upper, reverse the right side so molars are on the outside
    final rightTeeth =
        teeth.where((t) => t.side == 'right').toList()
          ..sort((a, b) => b.displayOrder.compareTo(a.displayOrder));
    final leftTeeth =
        teeth.where((t) => t.side == 'left').toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final orderedTeeth = [...rightTeeth, ...leftTeeth];

    return SizedBox(
      height: 100,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final centerX = width / 2;
          const archRadius = 140.0;
          // Spread teeth across an arc
          const totalArcAngle = math.pi * 0.7; // ~126 degrees
          final startAngle =
              isUpper ? math.pi + (math.pi - totalArcAngle) / 2 : (math.pi - totalArcAngle) / 2;

          return Stack(
            clipBehavior: Clip.none,
            children: List.generate(orderedTeeth.length, (i) {
              final tooth = orderedTeeth[i];
              final isErupted = eruptedPositions.containsKey(tooth.position);
              final fraction = orderedTeeth.length > 1
                  ? i / (orderedTeeth.length - 1)
                  : 0.5;
              final angle = startAngle + totalArcAngle * fraction;

              final x = centerX + archRadius * math.cos(angle) - 20;
              final y = isUpper
                  ? archRadius * math.sin(angle) - archRadius + 60
                  : -archRadius * math.sin(angle) + archRadius - 60;

              return Positioned(
                left: x,
                top: y,
                child: _ToothWidget(
                  tooth: tooth,
                  isErupted: isErupted,
                  pulseAnimation: pulseAnimation,
                  onTap: () => onToothTap(tooth),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

// ── Individual tooth widget ─────────────────────────────────────────────────

class _ToothWidget extends StatelessWidget {
  final ToothInfo tooth;
  final bool isErupted;
  final AnimationController pulseAnimation;
  final VoidCallback onTap;

  const _ToothWidget({
    required this.tooth,
    required this.isErupted,
    required this.pulseAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = _toothSize(tooth);

    Widget circle = AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isErupted
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: isErupted
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
          width: 2,
        ),
        boxShadow: isErupted
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(60),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          tooth.position,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isErupted
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );

    // Add a gentle pulse animation to pending teeth
    if (!isErupted) {
      circle = AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          final opacity = 0.6 + 0.4 * pulseAnimation.value;
          return Opacity(opacity: opacity, child: child);
        },
        child: circle,
      );
    }

    return Tooltip(
      message: '${tooth.name}\n~${tooth.typicalEruptionMonths} months',
      child: GestureDetector(
        onTap: onTap,
        child: circle,
      ),
    );
  }

  /// Molars are slightly larger than incisors.
  double _toothSize(ToothInfo tooth) {
    if (tooth.name.contains('Molar')) return 40;
    if (tooth.name.contains('Canine')) return 36;
    return 34; // Incisors
  }
}

// ── Legend ───────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: theme.colorScheme.primary,
          filled: true,
          label: 'Erupted',
        ),
        const SizedBox(width: 24),
        _LegendItem(
          color: theme.colorScheme.outline,
          filled: false,
          label: 'Pending',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final bool filled;
  final String label;

  const _LegendItem({
    required this.color,
    required this.filled,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ── Eruption timeline ───────────────────────────────────────────────────────

class _EruptionTimeline extends StatelessWidget {
  final TeethService service;
  final Map<String, TeethRecord> eruptedPositions;

  const _EruptionTimeline({
    required this.service,
    required this.eruptedPositions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teethByAge = service.teethByEruptionOrder;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eruption Timeline',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...teethByAge.map((tooth) {
              final record = eruptedPositions[tooth.position];
              final isErupted = record != null;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isErupted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: isErupted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant.withAlpha(100),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 24,
                      child: Text(
                        tooth.position,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tooth.name,
                        style: TextStyle(
                          color: isErupted
                              ? null
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              isErupted ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                    Text(
                      isErupted
                          ? _formatDate(record.eruptedAt)
                          : '~${tooth.typicalEruptionMonths}mo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isErupted
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
