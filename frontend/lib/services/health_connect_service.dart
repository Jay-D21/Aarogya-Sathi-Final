import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import '../models/wearable_data_model.dart';

class HealthConnectService {
  final Health _health = Health();
  bool _configured = false;

  /// Android-supported Health Connect data types
  static final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.WEIGHT,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
  ];

  static final List<HealthDataAccess> _permissions = List.filled(
    _dataTypes.length,
    HealthDataAccess.READ,
  );

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    try {
      await _health.configure();
      _configured = true;
    } catch (e) {
      debugPrint('[HealthConnectService] configure error: $e');
    }
  }

  /// Checks if Health Connect (Android) or Apple Health (iOS) is available
  Future<bool> isHealthConnectAvailable() async {
    await _ensureConfigured();
    if (Platform.isIOS) return true;
    try {
      final status = await _health.getHealthConnectSdkStatus();
      debugPrint('[HealthConnectService] Health Connect SDK status: $status');
      return status == HealthConnectSdkStatus.sdkAvailable;
    } catch (e) {
      debugPrint('[HealthConnectService] isHealthConnectAvailable error: $e');
      return false;
    }
  }

  /// Request permissions for all needed data types
  Future<bool> requestPermissions() async {
    await _ensureConfigured();
    try {
      // First check if already granted
      bool? hasPerms = await _health.hasPermissions(_dataTypes, permissions: _permissions);
      debugPrint('[HealthConnectService] Existing permissions: $hasPerms');
      if (hasPerms == true) return true;

      // Prompt user with Health Connect permission sheet
      bool authorized = await _health.requestAuthorization(_dataTypes, permissions: _permissions);
      debugPrint('[HealthConnectService] requestAuthorization result: $authorized');
      return authorized;
    } catch (e) {
      debugPrint('[HealthConnectService] requestPermissions error: $e');
      return false;
    }
  }

  /// Check if permissions are already granted
  Future<bool> hasPermissions() async {
    await _ensureConfigured();
    try {
      return await _health.hasPermissions(_dataTypes, permissions: _permissions) ?? false;
    } catch (e) {
      debugPrint('[HealthConnectService] hasPermissions error: $e');
      return false;
    }
  }

  /// Fetches aggregated wearable data for today and recent vitals
  Future<WearableDataModel> fetchTodayData() async {
    await _ensureConfigured();
    try {
      final bool granted = await hasPermissions();
      if (!granted) {
        debugPrint('[HealthConnectService] Permissions not granted, returning empty');
        return WearableDataModel.empty();
      }

      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      // Vitals lookback window (last 36 hours to capture latest readings like sleep, resting HR, SpO2)
      final vitalsLookback = now.subtract(const Duration(hours: 36));

      // ── 1. Steps for today ────────────────────────────────────────────────
      int? todaySteps;
      try {
        todaySteps = await _health.getTotalStepsInInterval(todayMidnight, now);
        debugPrint('[HealthConnectService] getTotalStepsInInterval: $todaySteps');
      } catch (e) {
        debugPrint('[HealthConnectService] getTotalStepsInInterval error: $e');
      }

      // If aggregate steps is null or 0, fallback to query step points
      if (todaySteps == null || todaySteps == 0) {
        try {
          final stepPoints = await _health.getHealthDataFromTypes(
            types: [HealthDataType.STEPS],
            startTime: todayMidnight,
            endTime: now,
          );
          int sumSteps = 0;
          for (var pt in stepPoints) {
            if (pt.value is NumericHealthValue) {
              sumSteps += (pt.value as NumericHealthValue).numericValue.toInt();
            }
          }
          if (sumSteps > 0) {
            todaySteps = sumSteps;
            debugPrint('[HealthConnectService] Summed step points: $todaySteps');
          }
        } catch (e) {
          debugPrint('[HealthConnectService] Step points query error: $e');
        }
      }

      // ── 2. Vitals & Calories ──────────────────────────────────────────────
      final vitalTypes = [
        HealthDataType.HEART_RATE,
        HealthDataType.RESTING_HEART_RATE,
        HealthDataType.BLOOD_OXYGEN,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.TOTAL_CALORIES_BURNED,
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
        HealthDataType.BLOOD_GLUCOSE,
        HealthDataType.BODY_TEMPERATURE,
        HealthDataType.WEIGHT,
      ];

      List<HealthDataPoint> vitalPoints = [];
      try {
        vitalPoints = await _health.getHealthDataFromTypes(
          types: vitalTypes,
          startTime: vitalsLookback,
          endTime: now,
        );
        debugPrint('[HealthConnectService] Fetched ${vitalPoints.length} vital points');
      } catch (e) {
        debugPrint('[HealthConnectService] Vital points query error: $e');
      }

      // ── 3. Sleep data ─────────────────────────────────────────────────────
      final sleepTypes = [
        HealthDataType.SLEEP_SESSION,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_REM,
      ];

      List<HealthDataPoint> sleepPoints = [];
      try {
        sleepPoints = await _health.getHealthDataFromTypes(
          types: sleepTypes,
          startTime: vitalsLookback,
          endTime: now,
        );
        debugPrint('[HealthConnectService] Fetched ${sleepPoints.length} sleep points');
      } catch (e) {
        debugPrint('[HealthConnectService] Sleep points query error: $e');
      }

      vitalPoints = _health.removeDuplicates(vitalPoints);
      sleepPoints = _health.removeDuplicates(sleepPoints);

      return _aggregateData(
        steps: todaySteps,
        todayMidnight: todayMidnight,
        vitalPoints: vitalPoints,
        sleepPoints: sleepPoints,
      );
    } catch (e) {
      debugPrint('[HealthConnectService] fetchTodayData general error: $e');
      return WearableDataModel.empty();
    }
  }

  WearableDataModel _aggregateData({
    required int? steps,
    required DateTime todayMidnight,
    required List<HealthDataPoint> vitalPoints,
    required List<HealthDataPoint> sleepPoints,
  }) {
    double todayActiveCalories = 0;
    double? latestHeartRate;
    DateTime? latestHeartRateTime;
    double? restingHeartRate;
    DateTime? latestRestingHeartRateTime;
    double? latestSpo2;
    DateTime? latestSpo2Time;
    double? latestBloodGlucose;
    double? latestBpSystolic;
    double? latestBpDiastolic;
    double? latestBodyTemp;
    double? latestWeight;

    for (var point in vitalPoints) {
      final val = point.value;
      if (val is! NumericHealthValue) continue;
      final numVal = val.numericValue.toDouble();
      final pointTime = point.dateTo;

      switch (point.type) {
        case HealthDataType.ACTIVE_ENERGY_BURNED:
        case HealthDataType.TOTAL_CALORIES_BURNED:
          // Calories burned today only
          if (point.dateFrom.isAfter(todayMidnight) || pointTime.isAfter(todayMidnight)) {
            todayActiveCalories += numVal;
          }
          break;

        case HealthDataType.HEART_RATE:
          if (latestHeartRateTime == null || pointTime.isAfter(latestHeartRateTime)) {
            latestHeartRate = numVal;
            latestHeartRateTime = pointTime;
          }
          break;

        case HealthDataType.RESTING_HEART_RATE:
          if (latestRestingHeartRateTime == null || pointTime.isAfter(latestRestingHeartRateTime)) {
            restingHeartRate = numVal;
            latestRestingHeartRateTime = pointTime;
          }
          break;

        case HealthDataType.BLOOD_OXYGEN:
          if (latestSpo2Time == null || pointTime.isAfter(latestSpo2Time)) {
            latestSpo2 = numVal;
            latestSpo2Time = pointTime;
          }
          break;

        case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
          latestBpSystolic = numVal;
          break;

        case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
          latestBpDiastolic = numVal;
          break;

        case HealthDataType.BLOOD_GLUCOSE:
          latestBloodGlucose = numVal;
          break;

        case HealthDataType.BODY_TEMPERATURE:
          latestBodyTemp = numVal;
          break;

        case HealthDataType.WEIGHT:
          latestWeight = numVal;
          break;

        default:
          break;
      }
    }

    // ── Aggregate Sleep ─────────────────────────────────────────────────────
    double sleepSessionHours = 0;
    double sleepRemHours = 0;
    double sleepDeepHours = 0;
    double sleepLightHours = 0;
    double sleepAsleepHours = 0;

    for (var point in sleepPoints) {
      final val = point.value;
      if (val is! NumericHealthValue) continue;
      // Value in Health Connect is duration in minutes
      final hours = val.numericValue.toDouble() / 60.0;

      switch (point.type) {
        case HealthDataType.SLEEP_SESSION:
          sleepSessionHours += hours;
          break;
        case HealthDataType.SLEEP_REM:
          sleepRemHours += hours;
          break;
        case HealthDataType.SLEEP_DEEP:
          sleepDeepHours += hours;
          break;
        case HealthDataType.SLEEP_LIGHT:
          sleepLightHours += hours;
          break;
        case HealthDataType.SLEEP_ASLEEP:
          sleepAsleepHours += hours;
          break;
        default:
          break;
      }
    }

    double totalSleep = sleepSessionHours > 0
        ? sleepSessionHours
        : (sleepDeepHours + sleepLightHours + sleepRemHours + sleepAsleepHours);

    debugPrint(
      '[HealthConnectService] Aggregated => Steps: $steps, '
      'HR: $latestHeartRate, RestingHR: $restingHeartRate, '
      'Cal: $todayActiveCalories, Sleep: $totalSleep, SpO2: $latestSpo2',
    );

    return WearableDataModel(
      todaySteps: (steps != null && steps > 0) ? steps : null,
      caloriesBurned: todayActiveCalories > 0 ? todayActiveCalories.toInt() : null,
      heartRateBpm: latestHeartRate ?? restingHeartRate,
      restingHeartRate: restingHeartRate,
      spo2Percent: latestSpo2,
      bloodGlucoseMgDl: latestBloodGlucose,
      bpSystolic: latestBpSystolic,
      bpDiastolic: latestBpDiastolic,
      bodyTempCelsius: latestBodyTemp,
      sleepTotalHours: totalSleep > 0 ? double.parse(totalSleep.toStringAsFixed(1)) : null,
      sleepRemHours: sleepRemHours > 0 ? double.parse(sleepRemHours.toStringAsFixed(1)) : null,
      sleepDeepHours: sleepDeepHours > 0 ? double.parse(sleepDeepHours.toStringAsFixed(1)) : null,
      sleepLightHours: sleepLightHours > 0 ? double.parse(sleepLightHours.toStringAsFixed(1)) : null,
      weightKg: latestWeight,
    );
  }
}
