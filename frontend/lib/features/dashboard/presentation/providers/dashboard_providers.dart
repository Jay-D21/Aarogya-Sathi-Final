import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:frontend/core/services/sensor_service.dart';
import 'package:frontend/core/services/health_connect_service.dart';
import 'package:frontend/features/dashboard/data/wearable_data_model.dart';

// Services
final sensorServiceProvider = Provider<SensorService>((ref) => SensorService());

final healthConnectServiceProvider = Provider<HealthConnectService>((ref) {
  return ref.watch(sensorServiceProvider).healthConnect;
});

// Streams
final stepCountStreamProvider = StreamProvider<StepCount>((ref) async* {
  final sensorService = ref.watch(sensorServiceProvider);
  yield* sensorService.stepCountStream;
});

// Wearable data from Health Connect — refreshes on each watch
final wearableDataProvider = FutureProvider<WearableDataModel>((ref) async {
  final sensorService = ref.watch(sensorServiceProvider);
  return sensorService.getWearableData();
});

// State — expanded to include Health Connect metrics
class FitnessState {
  final int steps;
  final double calories;
  final int heartPoints;
  final String status;
  // Health Connect fields
  final double? heartRateBpm;
  final double? restingHeartRate;
  final double? spo2Percent;
  final double? sleepTotalHours;
  final double? sleepDeepHours;
  final double? sleepRemHours;
  final double? sleepLightHours;
  final double? bloodGlucoseMgDl;
  final double? weightKg;
  final double? bodyTempCelsius;

  FitnessState({
    required this.steps,
    required this.calories,
    required this.heartPoints,
    required this.status,
    this.heartRateBpm,
    this.restingHeartRate,
    this.spo2Percent,
    this.sleepTotalHours,
    this.sleepDeepHours,
    this.sleepRemHours,
    this.sleepLightHours,
    this.bloodGlucoseMgDl,
    this.weightKg,
    this.bodyTempCelsius,
  });

  FitnessState copyWith({
    int? steps,
    double? calories,
    int? heartPoints,
    String? status,
    double? heartRateBpm,
    double? restingHeartRate,
    double? spo2Percent,
    double? sleepTotalHours,
    double? sleepDeepHours,
    double? sleepRemHours,
    double? sleepLightHours,
    double? bloodGlucoseMgDl,
    double? weightKg,
    double? bodyTempCelsius,
  }) {
    return FitnessState(
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      heartPoints: heartPoints ?? this.heartPoints,
      status: status ?? this.status,
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      spo2Percent: spo2Percent ?? this.spo2Percent,
      sleepTotalHours: sleepTotalHours ?? this.sleepTotalHours,
      sleepDeepHours: sleepDeepHours ?? this.sleepDeepHours,
      sleepRemHours: sleepRemHours ?? this.sleepRemHours,
      sleepLightHours: sleepLightHours ?? this.sleepLightHours,
      bloodGlucoseMgDl: bloodGlucoseMgDl ?? this.bloodGlucoseMgDl,
      weightKg: weightKg ?? this.weightKg,
      bodyTempCelsius: bodyTempCelsius ?? this.bodyTempCelsius,
    );
  }
}

// Riverpod 2.0 Notifier
class FitnessNotifier extends Notifier<FitnessState> {
  @override
  FitnessState build() {
    return FitnessState(
      steps: 0,
      calories: 0,
      heartPoints: 0,
      status: 'Unknown',
    );
  }

  void updateSteps(int steps) {
    // Simple calc: 0.04 kcal per step
    final cals = steps * 0.04;
    // Simple calc: 1 heart point per 100 steps
    final pts = (steps / 100).floor();

    state = state.copyWith(steps: steps, calories: cals, heartPoints: pts);
  }

  void updateStatus(String status) {
    state = state.copyWith(status: status);
  }

  /// Update state from Health Connect wearable data
  void updateFromWearable(WearableDataModel data) {
    state = state.copyWith(
      steps: data.todaySteps ?? state.steps,
      calories: data.caloriesBurned?.toDouble() ?? state.calories,
      heartRateBpm: data.heartRateBpm,
      restingHeartRate: data.restingHeartRate,
      spo2Percent: data.spo2Percent,
      sleepTotalHours: data.sleepTotalHours,
      sleepDeepHours: data.sleepDeepHours,
      sleepRemHours: data.sleepRemHours,
      sleepLightHours: data.sleepLightHours,
      bloodGlucoseMgDl: data.bloodGlucoseMgDl,
      weightKg: data.weightKg,
      bodyTempCelsius: data.bodyTempCelsius,
    );
  }
}

final fitnessProvider = NotifierProvider<FitnessNotifier, FitnessState>(
  FitnessNotifier.new,
);
