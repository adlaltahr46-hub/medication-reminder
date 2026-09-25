import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/dose_log_store.dart';

class DoseHistoryScreen extends StatelessWidget {
  const DoseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = DoseLogStore.all();
    final fmt = DateFormat('EEEE، d MMMM  •  hh:mm a', 'ar');

    return Scaffold(
      appBar: AppBar(title: const Text('سجل الجرعات')),
      body: logs.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'لا يوجد سجل بعد.\nكل جرعة تأخذها ستظهر هنا.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final log = logs[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(log.medName),
                    subtitle: Text(fmt.format(log.takenAt)),
                  ),
                );
              },
            ),
    );
  }
}
