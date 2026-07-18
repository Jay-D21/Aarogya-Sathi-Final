import 'package:intl/intl.dart';

/// Categories supported in the local medical records vault.
/// Represents a single encrypted medical document in the File Vault.
/// Files are stored with AES-256 encryption on device and never
/// transmitted to the backend in plaintext.
class MedicalFileCategory {
  static const String prescription = 'Prescription';
  static const String labReport = 'Lab Report';
  static const String scan = 'Scan & X-Ray';
  static const String vaccination = 'Vaccination';
  static const String other = 'Other';

  static const List<String> all = [
    prescription,
    labReport,
    scan,
    vaccination,
    other,
  ];
}

/// Represents a locally stored medical file (Prescription, Lab Test, Scan).
/// DPDP Act Compliance: Metadata and files are stored strictly on-device in
/// the application's private sandboxed directory.
class MedicalFileModel {
  final String id;
  final String title;
  final String category;
  final String? doctorOrClinic;
  final DateTime recordDate;
  final String localFilePath;
  final String fileType; // 'image', 'pdf', 'document'
  final int fileSizeBytes;
  final String? notes;
  final DateTime createdAt;

  const MedicalFileModel({
    required this.id,
    required this.title,
    required this.category,
    this.doctorOrClinic,
    required this.recordDate,
    required this.localFilePath,
    required this.fileType,
    this.fileSizeBytes = 0,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      if (doctorOrClinic != null) 'doctor_or_clinic': doctorOrClinic,
      'record_date': recordDate.toIso8601String(),
      'local_file_path': localFilePath,
      'file_type': fileType,
      'file_size_bytes': fileSizeBytes,
      if (notes != null) 'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MedicalFileModel.fromJson(Map<String, dynamic> json) {
    return MedicalFileModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Document',
      category: json['category'] as String? ?? MedicalFileCategory.other,
      doctorOrClinic: json['doctor_or_clinic'] as String?,
      recordDate: DateTime.tryParse(json['record_date'] as String? ?? '') ?? DateTime.now(),
      localFilePath: json['local_file_path'] as String? ?? '',
      fileType: json['file_type'] as String? ?? 'image',
      fileSizeBytes: json['file_size_bytes'] as int? ?? 0,
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  MedicalFileModel copyWith({
    String? id,
    String? title,
    String? category,
    String? doctorOrClinic,
    DateTime? recordDate,
    String? localFilePath,
    String? fileType,
    int? fileSizeBytes,
    String? notes,
    DateTime? createdAt,
  }) {
    return MedicalFileModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      doctorOrClinic: doctorOrClinic ?? this.doctorOrClinic,
      recordDate: recordDate ?? this.recordDate,
      localFilePath: localFilePath ?? this.localFilePath,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(recordDate);
  }

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
