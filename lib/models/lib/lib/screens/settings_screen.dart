import 'package:flutter/material.dart';

import '../services/medication_store.dart';
import '../services/dose_log_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmClearAll(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مسح كل البيانات؟'),
        content: const Text(
            'سيتم حذف كل الأدوية وسجل الجرعات، وإيقاف كل التذكيرات. لا يمكن التراجع عن هذا.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('مسح الكل',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true) return;
    await MedicationStore.clearAll();
    await DoseLogStore.clearAll();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم مسح كل البيانات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('عن التطبيق'),
              subtitle: const Text(
                  'أدويتي يذكّرك بمواعيد أدويتك ويتابع الجرعات المتبقية. '
                  'أداة تذكير فقط، ولا تغني عن استشارة الطبيب أو الصيدلي.'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('مسح كل البيانات'),
              subtitle: const Text('يحذف الأدوية وسجل الجرعات نهائيًا'),
              onTap: () => _confirmClearAll(context),
            ),
          ),
        ],
      ),
    );
  }
}
