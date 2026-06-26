class PatientRecord {
  final String id;
  final String name;
  final String? age;
  final String? gender;
  final String? bloodPressure;
  final String? weight;
  final String reason;
  final String? address;
  final String status;
  final DateTime addedAt;

  PatientRecord({
    required this.id,
    required this.name,
    this.age,
    this.gender,
    this.bloodPressure,
    this.weight,
    required this.reason,
    this.address,
    required this.status,
    required this.addedAt,
  });

  factory PatientRecord.fromJson(Map<String, dynamic> json) => PatientRecord(
        id:            json['id'],
        name:          json['name'],
        age:           json['age'],
        gender:        json['gender'],
        bloodPressure: json['bloodPressure'],
        weight:        json['weight'],
        reason:        json['reason'] ?? '',
        address:       json['address'],
        status:        json['status'] ?? 'pending',
        addedAt:       DateTime.parse(json['addedAt']),
      );
}