import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/medication.dart';
import '../services/medication_store.dart';
import '../services/notification_service.dart';
import 'add_medication_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _takeDose(BuildContext context, Medication m) async {
    final updated = m.copyWith(takenDoses: m.takenDoses + 1);
    await MedicationStore.save(updated);
    if (updated.isFinished) {
      await NotificationService.cancel(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('انتهت جرعات ${m.name}')),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, Medication m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف ${m.name}؟'),
        content: const Text('سيتم إيقاف التذكيرات الخاصة بهذا الدواء.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true) return;
    await NotificationService.cancel(m);
    await MedicationStore.delete(m);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أدويتي')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('إضافة دواء'),
      ),
      body: ValueListenableBuilder<Box<String>>(
        valueListenable: MedicationStore.listenable,
        builder: (context, _, __) {
          final meds = MedicationStore.all();
          if (meds.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'لا توجد أدوية بعد.\nأضف أول دواء لتبدأ التذكيرات.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: meds.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _MedicationCard(
              med: meds[i],
              onTake: () => _takeDose(context, meds[i]),
              onDelete: () => _delete(context, meds[i]),
            ),
          );
        },
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication med;
  final VoidCallback onTake;
  final VoidCallback onDelete;

  const _MedicationCard({
    required this.med,
    required this.onTake,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(med.name, style: theme.textTheme.titleMedium),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'حذف',
                ),
              ],
            ),
            Text(med.dosage, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text('المواعيد: ${med.times.join('  ')}',
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: med.progress, minHeight: 8),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    med.isFinished
                        ? 'اكتملت الجرعات'
                        : 'المتبقي ${med.remainingDoses} من ${med.totalDoses} جرعة',
                  ),
                ),
                FilledButton(
                  onPressed: med.isFinished ? null : onTake,
                  child: const Text('أخذت الجرعة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
