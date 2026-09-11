import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:frontend/core/services/sensor_service.dart';

// Services
final sensorServiceProvider = Provider<SensorService>((ref) => SensorService());

// Streams
final stepCountStreamProvider = StreamProvider<StepCount>((ref) async* {
  final sensorService = ref.watch(sensorServiceProvider);
  yield* sensorService.stepCountStream;
});

// State
class FitnessState {
  final int steps;
  final double calories;
  final int heartPoints;
  final String status;

  FitnessState({
    required this.steps,
    required this.calories,
    required this.heartPoints,
    required this.status,
  });

  FitnessState copyWith({
    int? steps,
    double? calories,
    int? heartPoints,
    String? status,
  }) {
    return FitnessState(
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      heartPoints: heartPoints ?? this.heartPoints,
      status: status ?? this.status,
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
}

final fitnessProvider = NotifierProvider<FitnessNotifier, FitnessState>(
  FitnessNotifier.new,
);
