class Medication {
  final int id;
  final String name;
  final String dosage; // مثال: "500 ملجم" أو "حبة واحدة"
  final List<String> times; // بصيغة "HH:mm"
  final int totalDoses;
  final int takenDoses;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.totalDoses,
    this.takenDoses = 0,
  });

  int get remainingDoses => totalDoses - takenDoses;
  double get progress => totalDoses == 0 ? 0 : takenDoses / totalDoses;
  bool get isFinished => remainingDoses <= 0;

  Medication copyWith({int? takenDoses}) => Medication(
        id: id,
        name: name,
        dosage: dosage,
        times: times,
        totalDoses: totalDoses,
        takenDoses: takenDoses ?? this.takenDoses,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'times': times,
        'totalDoses': totalDoses,
        'takenDoses': takenDoses,
      };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'] as int,
        name: json['name'] as String,
        dosage: json['dosage'] as String,
        times: List<String>.from(json['times'] as List),
        totalDoses: json['totalDoses'] as int,
        takenDoses: json['takenDoses'] as int,
      );
}
