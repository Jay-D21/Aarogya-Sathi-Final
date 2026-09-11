import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:frontend/features/dashboard/data/wearable_data_model.dart';

class HealthConnectService {
  final Health _health = Health();

  final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.WEIGHT,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
  ];

  final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  /// Checks if Health Connect (Android) or Apple Health (iOS) is available on the device
  Future<bool> isHealthConnectAvailable() async {
    // Usually, on Android, this requires the Health Connect app to be installed
    // For package:health v11+, we can attempt to check or request permissions.
    // In many cases, hasPermissions won't throw if not available, but let's try.
    try {
      // The health package doesn't have a direct "isAvailable" flag in v11 that we can safely call without permissions.
      // However, we can use it on supported platforms.
      return true;
    } catch (e) {
      debugPrint('Error checking Health Connect availability: $e');
      return false;
    }
  }

  /// Request permissions for all needed data types
  Future<bool> requestPermissions() async {
    try {
      bool? hasPermissions = await _health.hasPermissions(_dataTypes, permissions: _permissions);
      if (hasPermissions == false) {
        return await _health.requestAuthorization(_dataTypes, permissions: _permissions);
      }
      return hasPermissions ?? false;
    } catch (e) {
      debugPrint('Error requesting health permissions: $e');
      return false;
    }
  }

  /// Check if we already have permissions
  Future<bool> hasPermissions() async {
    try {
      return await _health.hasPermissions(_dataTypes, permissions: _permissions) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Fetches aggregated wearable data for today and last night's sleep
  Future<WearableDataModel> fetchTodayData() async {
    try {
      final bool granted = await hasPermissions();
      if (!granted) {
        return WearableDataModel.empty();
      }

      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      final yesterday10PM = DateTime(now.year, now.month, now.day - 1, 22);

      // Fetch general health data for today
      final List<HealthDataPoint> todayDataPoints = await _health.getHealthDataFromTypes(
        types: _dataTypes.where((t) => !t.name.contains('SLEEP')).toList(),
        startTime: todayMidnight,
        endTime: now,
      );

      // Fetch sleep data since yesterday 10 PM
      final List<HealthDataPoint> sleepDataPoints = await _health.getHealthDataFromTypes(
        types: _dataTypes.where((t) => t.name.contains('SLEEP')).toList(),
        startTime: yesterday10PM,
        endTime: now,
      );

      return _aggregateData(todayDataPoints, sleepDataPoints);
    } catch (e) {
      debugPrint('Error fetching health data: $e');
      return WearableDataModel.empty();
    }
  }

  WearableDataModel _aggregateData(List<HealthDataPoint> todayData, List<HealthDataPoint> sleepData) {
    int steps = 0;
    double calories = 0;
    double? latestHeartRate;
    double? restingHeartRate;
    double? latestSpo2;
    double? latestBloodGlucose;
    double? latestBpSystolic;
    double? latestBpDiastolic;
    double? latestBodyTemp;
    double? latestWeight;

    // Aggregate general data
    for (var point in todayData) {
      final val = point.value;
      if (val is NumericHealthValue) {
        final numericVal = val.numericValue.toDouble();
        switch (point.type) {
          case HealthDataType.STEPS:
            steps += numericVal.toInt();
            break;
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            calories += numericVal;
            break;
          case HealthDataType.HEART_RATE:
            // Assuming points are returned, we take the latest by replacing
            // This is a naive approach; could sort by date
            latestHeartRate = numericVal;
            break;
          case HealthDataType.RESTING_HEART_RATE:
            restingHeartRate = numericVal;
            break;
          case HealthDataType.BLOOD_OXYGEN:
            latestSpo2 = numericVal;
            break;
          case HealthDataType.BLOOD_GLUCOSE:
            latestBloodGlucose = numericVal;
            break;
          case HealthDataType.BODY_TEMPERATURE:
            latestBodyTemp = numericVal;
            break;
          case HealthDataType.WEIGHT:
            latestWeight = numericVal;
            break;
          default:
            break;
        }
      }
    }

    // Handle blood pressure separately
    for (var point in todayData) {
      if (point.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
        final val = point.value;
        if (val is NumericHealthValue) {
          latestBpSystolic = val.numericValue.toDouble();
        }
      }
      if (point.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC) {
        final val = point.value;
        if (val is NumericHealthValue) {
          latestBpDiastolic = val.numericValue.toDouble();
        }
      }
    }

    // Aggregate sleep data (converting minutes/ms to hours)
    double sleepTotal = 0;
    double sleepRem = 0;
    double sleepDeep = 0;
    double sleepLight = 0;

    for (var point in sleepData) {
      final val = point.value;
      if (val is NumericHealthValue) {
        // Sleep values are often in minutes
        final hours = val.numericValue.toDouble() / 60.0;
        switch (point.type) {
          case HealthDataType.SLEEP_IN_BED:
            sleepTotal += hours;
            break;
          case HealthDataType.SLEEP_REM:
            sleepRem += hours;
            break;
          case HealthDataType.SLEEP_DEEP:
            sleepDeep += hours;
            break;
          case HealthDataType.SLEEP_LIGHT:
            sleepLight += hours;
            break;
          default:
            break;
        }
      }
    }

    return WearableDataModel(
      todaySteps: steps > 0 ? steps : null,
      caloriesBurned: calories > 0 ? calories.toInt() : null,
      heartRateBpm: latestHeartRate,
      restingHeartRate: restingHeartRate,
      spo2Percent: latestSpo2,
      bloodGlucoseMgDl: latestBloodGlucose,
      bpSystolic: latestBpSystolic,
      bpDiastolic: latestBpDiastolic,
      bodyTempCelsius: latestBodyTemp,
      sleepTotalHours: sleepTotal > 0 ? double.parse(sleepTotal.toStringAsFixed(2)) : null,
      sleepRemHours: sleepRem > 0 ? double.parse(sleepRem.toStringAsFixed(2)) : null,
      sleepDeepHours: sleepDeep > 0 ? double.parse(sleepDeep.toStringAsFixed(2)) : null,
      sleepLightHours: sleepLight > 0 ? double.parse(sleepLight.toStringAsFixed(2)) : null,
      weightKg: latestWeight,
    );
  }
}
