import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BabyFormData {
  String name = '';
  DateTime? dateOfBirth;
  String? gender;
}

class BabyForm extends StatefulWidget {
  const BabyForm({
    super.key,
    required this.formKey,
    required this.formData,
  });

  final GlobalKey<FormState> formKey;
  final BabyFormData formData;

  @override
  State<BabyForm> createState() => _BabyFormState();
}

class _BabyFormState extends State<BabyForm> {
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.formData.dateOfBirth ?? now,
      firstDate: now.subtract(const Duration(days: 365 * 3)),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        widget.formData.dateOfBirth = picked;
        _dateController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Baby Name',
              hintText: 'Enter your baby\'s name',
              prefixIcon: Icon(Icons.child_care),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name is required';
              }
              return null;
            },
            onSaved: (value) => widget.formData.name = value!.trim(),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _dateController,
            decoration: const InputDecoration(
              labelText: 'Date of Birth',
              hintText: 'Select date of birth',
              prefixIcon: Icon(Icons.cake),
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            onTap: _pickDate,
            validator: (value) {
              if (widget.formData.dateOfBirth == null) {
                return 'Date of birth is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Gender (optional)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              ChoiceChip(
                label: const Text('Boy'),
                selected: widget.formData.gender == 'male',
                onSelected: (selected) {
                  setState(() {
                    widget.formData.gender = selected ? 'male' : null;
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Girl'),
                selected: widget.formData.gender == 'female',
                onSelected: (selected) {
                  setState(() {
                    widget.formData.gender = selected ? 'female' : null;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
