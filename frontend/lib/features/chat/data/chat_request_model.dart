class ChatRequestModel {
  final String query;
  final String language;
  final UserProfileData? profile;
  final WearableDataModel? wearable;
  final double? lat;
  final double? lon;

  const ChatRequestModel({
    required this.query,
    this.language = 'en',
    this.profile,
    this.wearable,
    this.lat,
    this.lon,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'language': language,
      if (profile != null) 'profile': profile!.toJson(),
      if (wearable != null) 'wearable': wearable!.toJson(),
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    };
  }
}

class UserProfileData {
  final int? age;
  final String? gender;
  final List<String> conditions;
  final List<String> medications;

  const UserProfileData({
    this.age,
    this.gender,
    this.conditions = const [],
    this.medications = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      'conditions': conditions,
      'medications': medications,
    };
  }
}

class WearableDataModel {
  final int? todaySteps;
  final int? caloriesBurned;
  final double? heartRateBpm;
  final double? restingHeartRate;
  final double? spo2Percent;
  final double? bloodGlucoseMgDl;
  final double? bpSystolic;
  final double? bpDiastolic;
  final double? bodyTempCelsius;
  final double? sleepTotalHours;
  final double? sleepRemHours;
  final double? sleepDeepHours;
  final double? sleepLightHours;
  final double? weightKg;

  const WearableDataModel({
    this.todaySteps,
    this.caloriesBurned,
    this.heartRateBpm,
    this.restingHeartRate,
    this.spo2Percent,
    this.bloodGlucoseMgDl,
    this.bpSystolic,
    this.bpDiastolic,
    this.bodyTempCelsius,
    this.sleepTotalHours,
    this.sleepRemHours,
    this.sleepDeepHours,
    this.sleepLightHours,
    this.weightKg,
  });

  Map<String, dynamic> toJson() {
    return {
      if (todaySteps != null) 'today_steps': todaySteps,
      if (caloriesBurned != null) 'calories_burned': caloriesBurned,
      if (heartRateBpm != null) 'heart_rate_bpm': heartRateBpm,
      if (restingHeartRate != null) 'resting_heart_rate': restingHeartRate,
      if (spo2Percent != null) 'spo2_percent': spo2Percent,
      if (bloodGlucoseMgDl != null) 'blood_glucose_mg_dl': bloodGlucoseMgDl,
      if (bpSystolic != null) 'bp_systolic': bpSystolic,
      if (bpDiastolic != null) 'bp_diastolic': bpDiastolic,
      if (bodyTempCelsius != null) 'body_temp_celsius': bodyTempCelsius,
      if (sleepTotalHours != null) 'sleep_total_hours': sleepTotalHours,
      if (sleepRemHours != null) 'sleep_rem_hours': sleepRemHours,
      if (sleepDeepHours != null) 'sleep_deep_hours': sleepDeepHours,
      if (sleepLightHours != null) 'sleep_light_hours': sleepLightHours,
      if (weightKg != null) 'weight_kg': weightKg,
    };
  }
}
