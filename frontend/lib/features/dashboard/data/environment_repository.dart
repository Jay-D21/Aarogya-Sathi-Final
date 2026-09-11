import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/config/api_config.dart';

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

  /// Parse from backend's { success: true, data: { aqi, temperature, ... } } format
  factory EnvironmentModel.fromApiResponse(Map<String, dynamic> data) {
    final aqi = data['aqi'] ?? 0;
    final temp = (data['temperature'] ?? 0).toDouble();
    final humidity = data['humidity'] ?? 0;

    // Derive AQI status and color from value (NAQI scale)
    String status;
    String color;
    String alert;

    if (aqi <= 50) {
      status = 'Good';
      color = '#4CAF50';
      alert = 'Air quality is excellent. Enjoy outdoor activities!';
    } else if (aqi <= 100) {
      status = 'Satisfactory';
      color = '#8BC34A';
      alert = 'Air quality is acceptable for most people.';
    } else if (aqi <= 200) {
      status = 'Moderate';
      color = '#FF9800';
      alert = 'Sensitive groups should reduce prolonged outdoor exertion.';
    } else if (aqi <= 300) {
      status = 'Poor';
      color = '#F44336';
      alert = 'Everyone should limit outdoor activity. Wear a mask if going out.';
    } else {
      status = 'Severe';
      color = '#9C27B0';
      alert = '🚨 Stay indoors. Close windows. Use air purifier if available.';
    }

    return EnvironmentModel(
      aqi: aqi is int ? aqi : (aqi as num).toInt(),
      condition: '${temp.toStringAsFixed(0)}°C, ${humidity}% humidity',
      aqiStatus: status,
      temperature: temp,
      alertMessage: alert,
      colorCode: color,
    );
  }
}

class EnvironmentRepository {
  final Dio _dio;

  EnvironmentRepository(this._dio);

  Future<EnvironmentModel> getCurrentEnvironment(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.aqiEndpoint}',
        queryParameters: {'lat': lat, 'lon': lon},
      );

      final body = response.data;
      if (body['success'] == true && body['data'] != null) {
        return EnvironmentModel.fromApiResponse(body['data']);
      }

      // API returned success: false
      return _fallbackModel(body['error'] ?? 'Unknown error');
    } catch (e) {
      // Fallback if backend is unreachable during dev
      return _fallbackModel('Could not fetch data');
    }
  }

  EnvironmentModel _fallbackModel(String message) {
    return EnvironmentModel(
      aqi: 0,
      condition: 'Offline',
      aqiStatus: 'Unknown',
      temperature: 0,
      alertMessage: message,
      colorCode: '#9E9E9E',
    );
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
