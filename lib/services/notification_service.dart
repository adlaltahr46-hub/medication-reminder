import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/medication.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    final zoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zoneName));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  // رقم فريد لكل تذكير: رقم الدواء + ترتيب الموعد
  static int _notificationId(int medId, int index) =>
      (medId % 1000000) * 100 + index;

  /// يجدول تذكيرًا يوميًا متكررًا لكل موعد في الدواء.
  static Future<void> schedule(Medication m) async {
    for (var i = 0; i < m.times.length; i++) {
      final parts = m.times[i].split(':');
      await _plugin.zonedSchedule(
        _notificationId(m.id, i),
        'وقت الدواء',
        '${m.name} — ${m.dosage}',
        _nextInstance(int.parse(parts[0]), int.parse(parts[1])),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'تذكير الدواء',
            channelDescription: 'تنبيهات مواعيد الجرعات',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(presentSound: true),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static Future<void> cancel(Medication m) async {
    for (var i = 0; i < m.times.length; i++) {
      await _plugin.cancel(_notificationId(m.id, i));
    }
  }

  static tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var date =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (date.isBefore(now)) date = date.add(const Duration(days: 1));
    return date;
  }
}
