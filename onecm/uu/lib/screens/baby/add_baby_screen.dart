import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/screens/onboarding/widgets/baby_form.dart';

/// Screen for adding an additional child after onboarding.
/// Reuses the BabyForm widget from onboarding.
class AddBabyScreen extends ConsumerStatefulWidget {
  const AddBabyScreen({super.key});

  @override
  ConsumerState<AddBabyScreen> createState() => _AddBabyScreenState();
}

class _AddBabyScreenState extends ConsumerState<AddBabyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formData = BabyFormData();
  bool _isSaving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(babyRepositoryProvider);
      final baby = await repo.createBaby(
        name: _formData.name,
        dateOfBirth: _formData.dateOfBirth!,
        gender: _formData.gender,
      );

      // Auto-select the newly created baby
      ref.read(selectedBabyIdProvider.notifier).state = baby.id;
      // Invalidate allBabiesProvider so the list refreshes
      ref.invalidate(allBabiesProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Child'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.child_care,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Add a new child',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your child\'s details below.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            BabyForm(formKey: _formKey, formData: _formData),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
