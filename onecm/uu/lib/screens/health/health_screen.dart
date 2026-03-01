import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/health_provider.dart';
import 'package:uu/services/vaccination_schedule_service.dart';

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Vaccinations'),
            Tab(text: 'Health Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _VaccinationsTab(babyId: babyId),
          _HealthEventsTab(babyId: babyId),
        ],
      ),
    );
  }
}

// ── Vaccinations Tab ──────────────────────────────────────────────────

class _VaccinationsTab extends ConsumerWidget {
  final int babyId;
  const _VaccinationsTab({required this.babyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccinationsAsync = ref.watch(vaccinationsProvider);
    final scheduleService = ref.watch(vaccinationScheduleServiceProvider);

    return vaccinationsAsync.when(
      data: (vaccinations) => _buildVaccinationList(
        context,
        ref,
        vaccinations: vaccinations,
        scheduleService: scheduleService,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildVaccinationList(
    BuildContext context,
    WidgetRef ref, {
    required List<Vaccination> vaccinations,
    required VaccinationScheduleService scheduleService,
  }) {
    // Build the set of administered vaccine keys from database records.
    final administeredKeys = <String>{};
    for (final v in vaccinations) {
      if (v.administeredAt != null && v.doseNumber != null) {
        administeredKeys.add('${v.vaccineName}#${v.doseNumber}');
      }
    }

    // Get the full schedule with statuses.
    // Use 12 months as a reasonable default; in production, compute from baby DOB.
    final statusEntries = scheduleService.getVaccineStatus(
      ageMonths: 12,
      administeredKeys: administeredKeys,
    );

    if (statusEntries.isEmpty) {
      return const Center(child: Text('No vaccinations scheduled.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: statusEntries.length,
      itemBuilder: (context, index) {
        final entry = statusEntries[index];
        return _VaccinationListItem(
          entry: entry,
          onTap: () => _onVaccinationTap(context, ref, entry),
        );
      },
    );
  }

  Future<void> _onVaccinationTap(
    BuildContext context,
    WidgetRef ref,
    VaccineStatusEntry entry,
  ) async {
    if (entry.status == VaccineStatus.administered) return;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'When was this vaccine administered?',
    );
    if (picked == null) return;

    String? provider;
    if (context.mounted) {
      provider = await _showProviderDialog(context);
    }

    // Create a vaccination record in the database.
    await ref.read(vaccinationRepositoryProvider).createVaccination(
          babyId: babyId,
          vaccineName: entry.vaccine.name,
          doseNumber: entry.vaccine.doseNumber,
          administeredAt: picked,
          provider: provider,
        );
  }

  Future<String?> _showProviderDialog(BuildContext context) async {
    String? provider;
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Healthcare Provider'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Provider name (optional)',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => provider = v.isEmpty ? null : v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(provider),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _VaccinationListItem extends StatelessWidget {
  final VaccineStatusEntry entry;
  final VoidCallback onTap;

  const _VaccinationListItem({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vaccine = entry.vaccine;

    final Color statusColor;
    final IconData statusIcon;
    final String statusText;

    switch (entry.status) {
      case VaccineStatus.administered:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Administered';
      case VaccineStatus.overdue:
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        statusText = 'Overdue';
      case VaccineStatus.upcoming:
        statusColor = Colors.amber.shade700;
        statusIcon = Icons.schedule;
        statusText = 'Upcoming';
      case VaccineStatus.future:
        statusColor = Colors.grey;
        statusIcon = Icons.event;
        statusText = 'Future';
    }

    return ListTile(
      leading: Icon(statusIcon, color: statusColor, size: 28),
      title: Text(
        '${vaccine.name} (Dose ${vaccine.doseNumber})',
        style: TextStyle(
          fontWeight: entry.status == VaccineStatus.administered
              ? FontWeight.w600
              : FontWeight.normal,
          color: entry.status == VaccineStatus.future
              ? theme.colorScheme.onSurfaceVariant
              : null,
        ),
      ),
      subtitle: Text(
        '$statusText - Due at ${vaccine.ageMonths} month${vaccine.ageMonths == 1 ? '' : 's'}',
        style: theme.textTheme.bodySmall?.copyWith(color: statusColor),
      ),
      trailing: entry.status != VaccineStatus.administered
          ? Icon(Icons.add_circle_outline,
              color: theme.colorScheme.primary, size: 24)
          : null,
      onTap: onTap,
    );
  }
}

// ── Health Events Tab ─────────────────────────────────────────────────

class _HealthEventsTab extends ConsumerWidget {
  final int babyId;
  const _HealthEventsTab({required this.babyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(healthEventsProvider);

    return Scaffold(
      body: eventsAsync.when(
        data: (events) => events.isEmpty
            ? const Center(child: Text('No health events recorded.'))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _HealthEventListItem(
                    event: event,
                    onTap: () => _showEventDetails(context, ref, event),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddEventDialog(BuildContext context, WidgetRef ref) async {
    String? selectedType;
    String? title;
    String? description;
    DateTime selectedDate = DateTime.now();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Health Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'illness', child: Text('Illness')),
                    DropdownMenuItem(
                        value: 'medication', child: Text('Medication')),
                    DropdownMenuItem(
                        value: 'doctor_visit',
                        child: Text('Doctor Visit')),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => selectedType = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => title = v.isEmpty ? null : v,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (v) => description = v.isEmpty ? null : v,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                  subtitle: const Text('Date'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedType != null && title != null
                  ? () => Navigator.of(ctx).pop(true)
                  : null,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selectedType != null && title != null) {
      await ref.read(healthEventRepositoryProvider).createHealthEvent(
            babyId: babyId,
            type: selectedType!,
            title: title!,
            description: description,
            startedAt: selectedDate,
          );
    }
  }

  Future<void> _showEventDetails(
    BuildContext context,
    WidgetRef ref,
    HealthEvent event,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'Type', value: _formatType(event.type)),
            if (event.startedAt != null)
              _DetailRow(label: 'Started', value: _formatDate(event.startedAt!)),
            if (event.endedAt != null)
              _DetailRow(label: 'Resolved', value: _formatDate(event.endedAt!)),
            if (event.description != null)
              _DetailRow(label: 'Details', value: event.description!),
            if (event.endedAt == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  label: const Text('Active'),
                  backgroundColor: Colors.orange.shade100,
                ),
              ),
          ],
        ),
        actions: [
          if (event.endedAt == null)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('resolve'),
              child: const Text('Mark Resolved'),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    if (result == 'resolve') {
      await ref
          .read(healthEventRepositoryProvider)
          .markResolved(event.id, DateTime.now());
    } else if (result == 'delete') {
      await ref.read(healthEventRepositoryProvider).deleteHealthEvent(event.id);
    }
  }

  String _formatType(String type) {
    switch (type) {
      case 'illness':
        return 'Illness';
      case 'medication':
        return 'Medication';
      case 'doctor_visit':
        return 'Doctor Visit';
      default:
        return type;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _HealthEventListItem extends StatelessWidget {
  final HealthEvent event;
  final VoidCallback onTap;

  const _HealthEventListItem({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = event.endedAt == null;

    final IconData typeIcon;
    final Color iconColor;

    switch (event.type) {
      case 'illness':
        typeIcon = Icons.sick;
        iconColor = isActive ? Colors.red : Colors.grey;
      case 'medication':
        typeIcon = Icons.medication;
        iconColor = isActive ? Colors.blue : Colors.grey;
      case 'doctor_visit':
        typeIcon = Icons.local_hospital;
        iconColor = isActive ? Colors.teal : Colors.grey;
      default:
        typeIcon = Icons.health_and_safety;
        iconColor = isActive ? Colors.purple : Colors.grey;
    }

    return ListTile(
      leading: Icon(typeIcon, color: iconColor, size: 28),
      title: Text(
        event.title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        event.startedAt != null
            ? '${_formatType(event.type)} - ${_formatDate(event.startedAt!)}${isActive ? ' (active)' : ''}'
            : _formatType(event.type),
        style: theme.textTheme.bodySmall,
      ),
      trailing: isActive
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  String _formatType(String type) {
    switch (type) {
      case 'illness':
        return 'Illness';
      case 'medication':
        return 'Medication';
      case 'doctor_visit':
        return 'Doctor Visit';
      default:
        return type;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
