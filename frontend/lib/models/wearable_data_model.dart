/// Snapshot of wearable sensor readings at a point in time.
/// Includes raw values from Health Connect alongside computed metrics
/// such as active calories derived from step cadence and user weight.
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

  factory WearableDataModel.empty() {
    return const WearableDataModel();
  }

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

  WearableDataModel copyWith({
    int? todaySteps,
    int? caloriesBurned,
    double? heartRateBpm,
    double? restingHeartRate,
    double? spo2Percent,
    double? bloodGlucoseMgDl,
    double? bpSystolic,
    double? bpDiastolic,
    double? bodyTempCelsius,
    double? sleepTotalHours,
    double? sleepRemHours,
    double? sleepDeepHours,
    double? sleepLightHours,
    double? weightKg,
  }) {
    return WearableDataModel(
      todaySteps: todaySteps ?? this.todaySteps,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      spo2Percent: spo2Percent ?? this.spo2Percent,
      bloodGlucoseMgDl: bloodGlucoseMgDl ?? this.bloodGlucoseMgDl,
      bpSystolic: bpSystolic ?? this.bpSystolic,
      bpDiastolic: bpDiastolic ?? this.bpDiastolic,
      bodyTempCelsius: bodyTempCelsius ?? this.bodyTempCelsius,
      sleepTotalHours: sleepTotalHours ?? this.sleepTotalHours,
      sleepRemHours: sleepRemHours ?? this.sleepRemHours,
      sleepDeepHours: sleepDeepHours ?? this.sleepDeepHours,
      sleepLightHours: sleepLightHours ?? this.sleepLightHours,
      weightKg: weightKg ?? this.weightKg,
    );
  }
}
