import 'package:flutter/material.dart';

import '../models/medication.dart';
import '../services/medication_store.dart';
import '../services/notification_service.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _days = TextEditingController(text: '7');
  final List<TimeOfDay> _times = [];
  bool _timesError = false;

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    _days.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null) return;
    if (_times.any((t) => t.hour == picked.hour && t.minute == picked.minute)) {
      return;
    }
    setState(() {
      _times
        ..add(picked)
        ..sort((a, b) => (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute));
      _timesError = false;
    });
  }

  Future<void> _save() async {
    final valid = _formKey.currentState!.validate();
    if (_times.isEmpty) setState(() => _timesError = true);
    if (!valid || _times.isEmpty) return;

    final days = int.parse(_days.text);
    final med = Medication(
      id: DateTime.now().millisecondsSinceEpoch % 1000000,
      name: _name.text.trim(),
      dosage: _dosage.text.trim(),
      times: _times.map(_fmt).toList(),
      totalDoses: _times.length * days,
    );

    await MedicationStore.save(med);
    await NotificationService.schedule(med);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة دواء')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'اسم الدواء'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'اكتب اسم الدواء' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dosage,
              decoration: const InputDecoration(
                labelText: 'الجرعة',
                hintText: 'مثال: حبة واحدة أو 500 ملجم',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'اكتب الجرعة' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _days,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'مدة العلاج (بالأيام)'),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return (n == null || n < 1) ? 'اكتب عدد أيام صحيح' : null;
              },
            ),
            const SizedBox(height: 24),
            Text('مواعيد الجرعات في اليوم', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in _times)
                  InputChip(
                    label: Text(_fmt(t)),
                    onDeleted: () => setState(() => _times.remove(t)),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('إضافة موعد'),
                  onPressed: _pickTime,
                ),
              ],
            ),
            if (_timesError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'أضف موعدًا واحدًا على الأقل',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              child: const Text('حفظ الدواء'),
            ),
          ],
        ),
      ),
    );
  }
}
