import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/medication.dart';

/// تخزين محلي بسيط: كل دواء يُحفظ كنص JSON.
class MedicationStore {
  static late Box<String> _box;

  static Future<void> open() async {
    _box = await Hive.openBox<String>('medications');
  }

  static ValueListenable<Box<String>> get listenable => _box.listenable();

  static List<Medication> all() => _box.values
      .map((s) => Medication.fromJson(jsonDecode(s) as Map<String, dynamic>))
      .toList();

  static Future<void> save(Medication m) =>
      _box.put(m.id.toString(), jsonEncode(m.toJson()));

  static Future<void> delete(Medication m) => _box.delete(m.id.toString());
}
