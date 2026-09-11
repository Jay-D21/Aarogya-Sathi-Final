import 'dart:convert';

class UserProfileModel {
  final String? name;
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final List<String> conditions;
  final List<String> medications;
  final double? bpSystolic;
  final double? bpDiastolic;
  final double? bloodSugar;
  final String? sugarType;

  const UserProfileModel({
    this.name,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.conditions = const [],
    this.medications = const [],
    this.bpSystolic,
    this.bpDiastolic,
    this.bloodSugar,
    this.sugarType,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'conditions': conditions,
      'medications': medications,
      'bpSystolic': bpSystolic,
      'bpDiastolic': bpDiastolic,
      'bloodSugar': bloodSugar,
      'sugarType': sugarType,
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      name: map['name'] as String?,
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      heightCm: map['heightCm']?.toDouble(),
      weightKg: map['weightKg']?.toDouble(),
      conditions: List<String>.from(map['conditions'] ?? []),
      medications: List<String>.from(map['medications'] ?? []),
      bpSystolic: map['bpSystolic']?.toDouble(),
      bpDiastolic: map['bpDiastolic']?.toDouble(),
      bloodSugar: map['bloodSugar']?.toDouble(),
      sugarType: map['sugarType'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfileModel.fromJson(String source) => 
      UserProfileModel.fromMap(json.decode(source));

  Map<String, dynamic> toApiJson() {
    return {
      'age': age,
      'gender': gender,
      'conditions': conditions,
      'medications': medications,
    };
  }
}
