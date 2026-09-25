import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/dose_log.dart';

class DoseLogStore {
  static late Box<String> _box;

  static Future<void> open() async {
    _box = await Hive.openBox<String>('dose_logs');
  }

  /// أحدث السجلات أولًا
  static List<DoseLog> all() {
    final list = _box.values
        .map((s) => DoseLog.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return list;
  }

  static Future<void> add(DoseLog log) =>
      _box.add(jsonEncode(log.toJson()));

  static Future<void> clearAll() => _box.clear();
}
