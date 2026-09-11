import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/features/dashboard/data/wearable_data_model.dart';
import 'package:frontend/core/services/health_connect_service.dart';

class SensorService {
  final HealthConnectService _healthConnectService = HealthConnectService();
  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;

  HealthConnectService get healthConnect => _healthConnectService;

  // Initialize Pedometer
  Stream<StepCount> get stepCountStream {
    _stepCountStream ??= Pedometer.stepCountStream;
    return _stepCountStream!;
  }

  Stream<PedestrianStatus> get pedestrianStatusStream {
    _pedestrianStatusStream ??= Pedometer.pedestrianStatusStream;
    return _pedestrianStatusStream!;
  }

  // Fetch wearable data (HealthConnect first, pedometer logic handled by UI/stream otherwise)
  Future<WearableDataModel> getWearableData() async {
    try {
      final isAvailable = await _healthConnectService.isHealthConnectAvailable();
      if (isAvailable) {
        final granted = await _healthConnectService.requestPermissions();
        if (granted) {
          final data = await _healthConnectService.fetchTodayData();
          // If we got steps from HealthConnect, return the data
          if (data.todaySteps != null || data.heartRateBpm != null) {
            return data;
          }
        }
      }
    } catch (e) {
      // Ignore and fallback
    }

    // If Health Connect is not available or failed, return empty model
    // The UI should listen to stepCountStream as a fallback for steps
    return WearableDataModel.empty();
  }

  // Permission Request
  Future<bool> requestActivityPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Location
  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      return null;
    }
  }
}
