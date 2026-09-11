import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/dashboard/data/environment_repository.dart'; // Reusing dioProvider

class ReportModel {
  final String id;
  final String? fileUrl;
  final String? aiSummary;
  final Map<String, dynamic>? extractedData;
  final bool isProcessed;

  ReportModel({
    required this.id,
    this.fileUrl,
    this.aiSummary,
    this.extractedData,
    required this.isProcessed,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      fileUrl: json['file_url'],
      aiSummary: json['ai_summary'],
      extractedData: json['extracted_data'],
      isProcessed: json['is_processed'] ?? false,
    );
  }
}

class ReportRepository {
  final Dio _dio;

  ReportRepository(this._dio);

  Future<ReportModel> uploadReport(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    try {
      // 10.0.2.2 for Android Emulator localhost
      final response = await _dio.post(
        'http://10.0.2.2:8000/api/v1/reports/upload',
        data: formData,
      );
      return ReportModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to upload report: $e');
    }
  }
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(dioProvider));
});
