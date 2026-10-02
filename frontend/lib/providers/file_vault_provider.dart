import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/medical_file_model.dart';

class FileVaultProvider extends ChangeNotifier {
  static const String _prefKey = 'medical_vault_files';
  static const _uuid = Uuid();

  List<MedicalFileModel> _files = [];
  bool _isLoading = false;
  String _activeCategory = 'All';
  String _searchQuery = '';

  List<MedicalFileModel> get files => List.unmodifiable(_files);
  bool get isLoading => _isLoading;
  String get activeCategory => _activeCategory;
  String get searchQuery => _searchQuery;

  List<MedicalFileModel> get filteredFiles {
    return _files.where((f) {
      final matchesCategory =
          _activeCategory == 'All' || f.category == _activeCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          f.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (f.doctorOrClinic != null &&
              f.doctorOrClinic!
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())) ||
          (f.notes != null &&
              f.notes!.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void setCategory(String category) {
    _activeCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadFiles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_prefKey) ?? [];
      _files = rawList
          .map((item) {
            try {
              return MedicalFileModel.fromJson(
                  jsonDecode(item) as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<MedicalFileModel>()
          .toList();

      // Sort newest record first
      _files.sort((a, b) => b.recordDate.compareTo(a.recordDate));
    } catch (e) {
      debugPrint('Error loading vault files: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Saves a picked file into local app storage and records metadata.
  Future<MedicalFileModel?> addFile({
    required String sourcePath,
    required String title,
    required String category,
    String? doctorOrClinic,
    DateTime? recordDate,
    String? notes,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist');
      }

      // Prepare target directory inside app sandbox
      final appDir = await getApplicationDocumentsDirectory();
      final vaultDir = Directory('${appDir.path}/medical_vault');
      if (!await vaultDir.exists()) {
        await vaultDir.create(recursive: true);
      }

      final fileExt = sourcePath.split('.').last.toLowerCase();
      final fileType = (fileExt == 'pdf')
          ? 'pdf'
          : (['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(fileExt)
              ? 'image'
              : 'document');

      final fileId = _uuid.v4();
      final targetPath = '${vaultDir.path}/doc_$fileId.$fileExt';

      // Copy file to persistent sandbox storage
      final savedFile = await sourceFile.copy(targetPath);
      final fileSize = await savedFile.length();

      final newModel = MedicalFileModel(
        id: fileId,
        title: title.trim().isEmpty ? 'Medical Document' : title.trim(),
        category: category,
        doctorOrClinic: doctorOrClinic?.trim().isNotEmpty == true
            ? doctorOrClinic!.trim()
            : null,
        recordDate: recordDate ?? DateTime.now(),
        localFilePath: targetPath,
        fileType: fileType,
        fileSizeBytes: fileSize,
        notes: notes?.trim().isNotEmpty == true ? notes!.trim() : null,
        createdAt: DateTime.now(),
      );

      _files.insert(0, newModel);
      await _persistList();
      notifyListeners();
      return newModel;
    } catch (e) {
      debugPrint('Error adding vault file: $e');
      return null;
    }
  }

  Future<bool> deleteFile(String id) async {
    try {
      final index = _files.indexWhere((f) => f.id == id);
      if (index == -1) return false;

      final target = _files[index];
      final localFile = File(target.localFilePath);
      if (await localFile.exists()) {
        try {
          await localFile.delete();
        } catch (_) {}
      }

      _files.removeAt(index);
      await _persistList();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting vault file: $e');
      return false;
    }
  }

  Future<void> _persistList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _files.map((f) => jsonEncode(f.toJson())).toList();
    await prefs.setStringList(_prefKey, jsonList);
  }
}
