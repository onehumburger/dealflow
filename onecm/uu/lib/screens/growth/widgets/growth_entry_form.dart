import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/growth_provider.dart';

class GrowthEntryForm extends ConsumerStatefulWidget {
  const GrowthEntryForm({super.key});

  @override
  ConsumerState<GrowthEntryForm> createState() => _GrowthEntryFormState();
}

class _GrowthEntryFormState extends ConsumerState<GrowthEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _headController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Measurement',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(dateFormat.format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 12),

              // Weight field
              TextFormField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 7.5',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0 || parsed > 50) {
                      return 'Enter a valid weight (0-50 kg)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Height field
              TextFormField(
                controller: _heightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  prefixIcon: Icon(Icons.straighten),
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 68.0',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0 || parsed > 150) {
                      return 'Enter a valid height (0-150 cm)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Head circumference field
              TextFormField(
                controller: _headController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Head circumference (cm)',
                  prefixIcon: Icon(Icons.circle_outlined),
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 43.0',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0 || parsed > 60) {
                      return 'Enter a valid circumference (0-60 cm)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = _weightController.text.isNotEmpty
        ? double.tryParse(_weightController.text)
        : null;
    final height = _heightController.text.isNotEmpty
        ? double.tryParse(_heightController.text)
        : null;
    final head = _headController.text.isNotEmpty
        ? double.tryParse(_headController.text)
        : null;

    if (weight == null && height == null && head == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one measurement')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final babyId = ref.read(selectedBabyIdProvider);
      if (babyId == null) return;

      await ref.read(growthRepositoryProvider).addRecord(
            babyId: babyId,
            date: _selectedDate,
            weightKg: weight,
            heightCm: height,
            headCircumferenceCm: head,
          );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
