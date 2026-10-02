import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/medical_file_model.dart';
import 'package:frontend/providers/file_vault_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MedicalFileModel Tests', () {
    test('Serializes to JSON and deserializes correctly', () {
      final now = DateTime(2026, 10, 3, 10, 30);
      final model = MedicalFileModel(
        id: 'test-uuid-123',
        title: 'Dr. Sharma Prescription',
        category: MedicalFileCategory.prescription,
        doctorOrClinic: 'Apollo Hospital',
        recordDate: now,
        localFilePath: '/mock/path/doc_123.jpg',
        fileType: 'image',
        fileSizeBytes: 204800,
        notes: 'Take with warm milk before sleep',
        createdAt: now,
      );

      final json = model.toJson();
      expect(json['id'], 'test-uuid-123');
      expect(json['title'], 'Dr. Sharma Prescription');
      expect(json['category'], 'Prescription');
      expect(json['doctor_or_clinic'], 'Apollo Hospital');
      expect(json['file_size_bytes'], 204800);
      expect(json['notes'], 'Take with warm milk before sleep');

      final reconstructed = MedicalFileModel.fromJson(json);
      expect(reconstructed.id, model.id);
      expect(reconstructed.title, model.title);
      expect(reconstructed.category, model.category);
      expect(reconstructed.doctorOrClinic, model.doctorOrClinic);
      expect(reconstructed.formattedDate, '03 Oct 2026');
      expect(reconstructed.formattedSize, '200.0 KB');
    });

    test('Formatted size formats Bytes, KB, and MB appropriately', () {
      final byteModel = MedicalFileModel(
        id: '1',
        title: 'Small',
        category: MedicalFileCategory.other,
        recordDate: DateTime.now(),
        localFilePath: '/a',
        fileType: 'document',
        fileSizeBytes: 512,
        createdAt: DateTime.now(),
      );
      expect(byteModel.formattedSize, '512 B');

      final kbModel = byteModel.copyWith(fileSizeBytes: 1024 * 50);
      expect(kbModel.formattedSize, '50.0 KB');

      final mbModel = byteModel.copyWith(fileSizeBytes: 1024 * 1024 * 3);
      expect(mbModel.formattedSize, '3.0 MB');
    });
  });

  group('FileVaultProvider Filtering and Search Tests', () {
    test('Initializes with empty list and loads cleanly', () async {
      final vault = FileVaultProvider();
      await vault.loadFiles();

      expect(vault.files.isEmpty, true);
      expect(vault.filteredFiles.isEmpty, true);
      expect(vault.activeCategory, 'All');
      expect(vault.searchQuery, '');
    });

    test('Filters files by category correctly', () async {
      // Seed SharedPreferences with mock records
      final file1 = MedicalFileModel(
        id: 'f1',
        title: 'Diabetes Rx',
        category: MedicalFileCategory.prescription,
        recordDate: DateTime(2026, 9, 1),
        localFilePath: '/mock/1.jpg',
        fileType: 'image',
        createdAt: DateTime.now(),
      );

      final file2 = MedicalFileModel(
        id: 'f2',
        title: 'Lipid Profile',
        category: MedicalFileCategory.labReport,
        recordDate: DateTime(2026, 9, 2),
        localFilePath: '/mock/2.pdf',
        fileType: 'pdf',
        createdAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('medical_vault_files', [
        '{"id":"f1","title":"Diabetes Rx","category":"Prescription","record_date":"2026-09-01T00:00:00.000","local_file_path":"/mock/1.jpg","file_type":"image","file_size_bytes":100,"created_at":"2026-09-01T00:00:00.000"}',
        '{"id":"f2","title":"Lipid Profile","category":"Lab Report","record_date":"2026-09-02T00:00:00.000","local_file_path":"/mock/2.pdf","file_type":"pdf","file_size_bytes":200,"created_at":"2026-09-02T00:00:00.000"}',
      ]);

      final vault = FileVaultProvider();
      await vault.loadFiles();

      expect(vault.files.length, 2);
      expect(vault.filteredFiles.length, 2);

      // Select 'Prescription'
      vault.setCategory(MedicalFileCategory.prescription);
      expect(vault.filteredFiles.length, 1);
      expect(vault.filteredFiles.first.title, 'Diabetes Rx');

      // Select 'Lab Report'
      vault.setCategory(MedicalFileCategory.labReport);
      expect(vault.filteredFiles.length, 1);
      expect(vault.filteredFiles.first.title, 'Lipid Profile');

      // Select 'All'
      vault.setCategory('All');
      expect(vault.filteredFiles.length, 2);
    });

    test('Searches by title and notes', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('medical_vault_files', [
        '{"id":"f1","title":"Metformin 500mg","category":"Prescription","doctor_or_clinic":"Dr. Kulkarni","record_date":"2026-09-01T00:00:00.000","local_file_path":"/mock/1.jpg","file_type":"image","file_size_bytes":100,"notes":"Twice daily","created_at":"2026-09-01T00:00:00.000"}',
        '{"id":"f2","title":"Chest X-Ray","category":"Scan & X-Ray","doctor_or_clinic":"NMIMS Clinic","record_date":"2026-09-02T00:00:00.000","local_file_path":"/mock/2.jpg","file_type":"image","file_size_bytes":500,"created_at":"2026-09-02T00:00:00.000"}',
      ]);

      final vault = FileVaultProvider();
      await vault.loadFiles();

      // Search by title substring
      vault.setSearchQuery('metformin');
      expect(vault.filteredFiles.length, 1);
      expect(vault.filteredFiles.first.title, 'Metformin 500mg');

      // Search by doctor name
      vault.setSearchQuery('kulkarni');
      expect(vault.filteredFiles.length, 1);

      // Search by clinic name
      vault.setSearchQuery('NMIMS');
      expect(vault.filteredFiles.length, 1);
      expect(vault.filteredFiles.first.title, 'Chest X-Ray');

      // Non-matching query
      vault.setSearchQuery('neurology');
      expect(vault.filteredFiles.isEmpty, true);
    });

    test('Deletes file metadata and updates persistent storage', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('medical_vault_files', [
        '{"id":"del-1","title":"Old Prescription","category":"Prescription","record_date":"2026-01-01T00:00:00.000","local_file_path":"/nonexistent/old.jpg","file_type":"image","file_size_bytes":50,"created_at":"2026-01-01T00:00:00.000"}',
      ]);

      final vault = FileVaultProvider();
      await vault.loadFiles();
      expect(vault.files.length, 1);

      final deleted = await vault.deleteFile('del-1');
      expect(deleted, true);
      expect(vault.files.isEmpty, true);

      final updatedList = prefs.getStringList('medical_vault_files');
      expect(updatedList?.isEmpty, true);
    });
  });
}
