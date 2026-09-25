class DoseLog {
  final int medId;
  final String medName;
  final DateTime takenAt;

  const DoseLog({
    required this.medId,
    required this.medName,
    required this.takenAt,
  });

  Map<String, dynamic> toJson() => {
        'medId': medId,
        'medName': medName,
        'takenAt': takenAt.toIso8601String(),
      };

  factory DoseLog.fromJson(Map<String, dynamic> json) => DoseLog(
        medId: json['medId'] as int,
        medName: json['medName'] as String,
        takenAt: DateTime.parse(json['takenAt'] as String),
      );
}
