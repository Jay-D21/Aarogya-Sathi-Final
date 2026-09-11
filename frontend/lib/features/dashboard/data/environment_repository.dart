import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnvironmentModel {
  final int aqi;
  final String condition;
  final String aqiStatus;
  final double temperature;
  final String alertMessage;
  final String colorCode;

  EnvironmentModel({
    required this.aqi,
    required this.condition,
    required this.aqiStatus,
    required this.temperature,
    required this.alertMessage,
    required this.colorCode,
  });

  factory EnvironmentModel.fromJson(Map<String, dynamic> json) {
    return EnvironmentModel(
      aqi: json['aqi'],
      condition: json['condition'],
      aqiStatus: json['aqi_status'],
      temperature: json['temperature'],
      alertMessage: json['alert_message'],
      colorCode: json['color_code'],
    );
  }
}

class EnvironmentRepository {
  final Dio _dio;

  EnvironmentRepository(this._dio);

  Future<EnvironmentModel> getCurrentEnvironment(double lat, double lon) async {
    try {
      // For Emulator to Host localhost access, use 10.0.2.2 on Android
      // Assuming testing on Android Emulator
      final response = await _dio.get(
        'http://10.0.2.2:8000/api/v1/environment/current',
        queryParameters: {'lat': lat, 'lon': lon},
      );

      return EnvironmentModel.fromJson(response.data);
    } catch (e) {
      // Fallback if backend is unreachable during dev
      return EnvironmentModel(
        aqi: 0,
        condition: 'Offline',
        aqiStatus: 'Unknown',
        temperature: 0,
        alertMessage: 'Could not fetch data',
        colorCode: '#9E9E9E',
      );
    }
  }
}

final dioProvider = Provider<Dio>((ref) => Dio());

final environmentRepositoryProvider = Provider<EnvironmentRepository>((ref) {
  return EnvironmentRepository(ref.watch(dioProvider));
});

final currentEnvironmentProvider =
    FutureProvider.family<EnvironmentModel, ({double lat, double lon})>((
      ref,
      coords,
    ) async {
      final repo = ref.watch(environmentRepositoryProvider);
      return repo.getCurrentEnvironment(coords.lat, coords.lon);
    });
