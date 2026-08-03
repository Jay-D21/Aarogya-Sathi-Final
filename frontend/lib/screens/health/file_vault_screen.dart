import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/medical_file_model.dart';
import '../../providers/file_vault_provider.dart';
import '../../widgets/category_folder_card.dart';
import '../../widgets/section_header.dart';

/// Secure medical document vault. Displays encrypted files grouped
/// by category (Prescriptions, Lab Reports, Scans, Insurance).
/// All files are AES-256 encrypted before writing to device storage.
class FileVaultScreen extends StatefulWidget {
  const FileVaultScreen({super.key});

  @override
  State<FileVaultScreen> createState() => _FileVaultScreenState();
}

class _FileVaultScreenState extends State<FileVaultScreen> {
  final _searchCtrl = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FileVaultProvider>().loadFiles();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        _showSaveFileDialog(picked.path, isImage: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open camera/gallery: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null && mounted) {
        final path = result.files.single.path!;
        final isPdf = path.toLowerCase().endsWith('.pdf');
        _showSaveFileDialog(path, isImage: !isPdf);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick file: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }

  void _showUploadPickerSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Medical Record',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryOf(c))),
              const SizedBox(height: 6),
              Text(
                'Files are stored locally on your device for privacy.',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppTheme.textSecondaryOf(c)),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppTheme.primaryTeal),
                ),
                title: Text('Take Photo of Prescription',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: const Text('Capture using phone camera'),
                onTap: () {
                  Navigator.pop(c);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: AppTheme.accentBlue),
                ),
                title: Text('Upload from Gallery',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: const Text('Choose existing photo or screenshot'),
                onTap: () {
                  Navigator.pop(c);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentYellow.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded,
                      color: AppTheme.accentYellow),
                ),
                title: Text('Upload PDF / Lab Document',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pick PDF report from device files'),
                onTap: () {
                  Navigator.pop(c);
                  _pickDocument();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSaveFileDialog(String sourcePath, {required bool isImage}) {
    final titleCtrl = TextEditingController();
    final doctorCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedCategory = MedicalFileCategory.prescription;
    DateTime recordDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  isImage ? Icons.image_rounded : Icons.description_rounded,
                  color: AppTheme.primaryTeal,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text('Document Details',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Document Title *',
                      hintText: 'e.g. Blood Sugar Report, Dr. Sharma Rx',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    items: MedicalFileCategory.all.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDlgState(() => selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: doctorCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Doctor / Clinic (Optional)',
                      hintText: 'e.g. City Hospital, Dr. Patil',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Date: ${DateFormat('dd MMM yyyy').format(recordDate)}',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.calendar_today_rounded, size: 18),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: recordDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDlgState(() => recordDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Dosage instructions or test notes',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dlgCtx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                ),
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a title')),
                    );
                    return;
                  }

                  Navigator.pop(dlgCtx);
                  final vault = context.read<FileVaultProvider>();
                  final saved = await vault.addFile(
                    sourcePath: sourcePath,
                    title: title,
                    category: selectedCategory,
                    doctorOrClinic: doctorCtrl.text.trim(),
                    recordDate: recordDate,
                    notes: notesCtrl.text.trim(),
                  );

                  if (mounted && saved != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Saved "${saved.title}" to Secure Vault'),
                        backgroundColor: AppTheme.primaryTeal,
                      ),
                    );
                  }
                },
                child: const Text('Save Document'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFilePreview(MedicalFileModel file) {
    showDialog(
      context: context,
      builder: (dlgCtx) {
        final exists = File(file.localFilePath).existsSync();
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(file.title,
                    style: GoogleFonts.outfit(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(dlgCtx),
                  ),
                ],
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (file.fileType == 'image' && exists)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(file.localFilePath),
                            fit: BoxFit.contain,
                            height: 280,
                            width: double.infinity,
                          ),
                        )
                      else
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                file.fileType == 'pdf'
                                    ? Icons.picture_as_pdf_rounded
                                    : Icons.description_rounded,
                                size: 48,
                                color: AppTheme.primaryTeal,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${file.fileType.toUpperCase()} Document (${file.formattedSize})',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      _detailRow('Category', file.category),
                      if (file.doctorOrClinic != null)
                        _detailRow('Doctor / Clinic', file.doctorOrClinic!),
                      _detailRow('Record Date', file.formattedDate),
                      _detailRow('File Size', file.formattedSize),
                      if (file.notes != null)
                        _detailRow('Notes', file.notes!),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.lock_rounded,
                              size: 14, color: AppTheme.accentGreen),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'DPDP Compliant: Stored on-device in app sandbox',
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: AppTheme.accentGreen),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                  fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, MedicalFileModel file) {
    showDialog(
      context: ctx,
      builder: (dlgCtx) => AlertDialog(
        title: Text('Delete Document?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to permanently delete "${file.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dlgCtx);
              final deleted =
                  await context.read<FileVaultProvider>().deleteFile(file.id);
              if (ctx.mounted && deleted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Document deleted')),
                );
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<FileVaultProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = AppTheme.textPrimaryOf(context);
    final textSec = AppTheme.textSecondaryOf(context);
    final bg = AppTheme.bgOf(context);
    final card = AppTheme.cardBg(context);
    final border = AppTheme.borderColor(context);


    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medical File Vault',
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
            Row(
              children: [
                const Icon(Icons.shield_outlined,
                    size: 11, color: AppTheme.accentGreen),
                const SizedBox(width: 4),
                Text('DPDP Act · 100% On-Device Storage',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.accentGreen,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        onPressed: () => _showUploadPickerSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text('Add Document',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Search Bar ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: vault.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search prescriptions, doctors, reports...',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: textSec),
                      prefixIcon: Icon(Icons.search_rounded, size: 20, color: textSec),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                vault.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // ── Google Drive Reference: Storage Summary Banner ──
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F9D58), Color(0xFF0B8043)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F9D58).withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.folder_shared_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Secure Health Storage',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${vault.files.length} records · 100% on-device sandboxed',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.verified_user_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (vault.files.length / 50).clamp(0.05, 1.0),
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Google Drive Reference: My Folders (2x2 Grid) ──
                SectionHeader(
                  title: 'My Folders',
                  trailing: vault.activeCategory != 'All' ? 'View all' : null,
                  onTrailingTap: () => vault.setCategory('All'),
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: CategoryFolderCard(
                          title: 'Prescriptions',
                          subtitle: '${vault.files.where((f) => f.category == MedicalFileCategory.prescription).length} records',
                          icon: Icons.medication_rounded,
                          accentColor: AppTheme.primaryTeal,
                          isSelected: vault.activeCategory == MedicalFileCategory.prescription,
                          onTap: () {
                            vault.setCategory(
                              vault.activeCategory == MedicalFileCategory.prescription
                                  ? 'All'
                                  : MedicalFileCategory.prescription,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CategoryFolderCard(
                          title: 'Lab Reports',
                          subtitle: '${vault.files.where((f) => f.category == MedicalFileCategory.labReport).length} records',
                          icon: Icons.biotech_rounded,
                          accentColor: AppTheme.accentBlue,
                          isSelected: vault.activeCategory == MedicalFileCategory.labReport,
                          onTap: () {
                            vault.setCategory(
                              vault.activeCategory == MedicalFileCategory.labReport
                                  ? 'All'
                                  : MedicalFileCategory.labReport,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: CategoryFolderCard(
                          title: 'Scans & X-Rays',
                          subtitle: '${vault.files.where((f) => f.category == MedicalFileCategory.scan).length} records',
                          icon: Icons.document_scanner_rounded,
                          accentColor: AppTheme.accentOrange,
                          isSelected: vault.activeCategory == MedicalFileCategory.scan,
                          onTap: () {
                            vault.setCategory(
                              vault.activeCategory == MedicalFileCategory.scan
                                  ? 'All'
                                  : MedicalFileCategory.scan,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CategoryFolderCard(
                          title: 'Vaccinations',
                          subtitle: '${vault.files.where((f) => f.category == MedicalFileCategory.vaccination).length} records',
                          icon: Icons.vaccines_rounded,
                          accentColor: AppTheme.accentGreen,
                          isSelected: vault.activeCategory == MedicalFileCategory.vaccination,
                          onTap: () {
                            vault.setCategory(
                              vault.activeCategory == MedicalFileCategory.vaccination
                                  ? 'All'
                                  : MedicalFileCategory.vaccination,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Recent Files Header ──
                SectionHeader(
                  title: 'Documents (${vault.filteredFiles.length})',
                  trailing: vault.activeCategory != 'All' ? 'Filter: ${vault.activeCategory}' : null,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // ── File Items ──
          if (vault.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (vault.filteredFiles.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: _buildEmptyState(context, textPri, textSec),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final file = vault.filteredFiles[i];
                    return _buildFileCard(
                      context,
                      file,
                      isDark,
                      textPri,
                      textSec,
                      card,
                      border,
                    );
                  },
                  childCount: vault.filteredFiles.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileCard(
    BuildContext context,
    MedicalFileModel file,
    bool isDark,
    Color textPri,
    Color textSec,
    Color card,
    Color border,
  ) {
    IconData icon;
    Color iconColor;

    switch (file.category) {
      case MedicalFileCategory.prescription:
        icon = Icons.medication_rounded;
        iconColor = AppTheme.primaryTeal;
        break;
      case MedicalFileCategory.labReport:
        icon = Icons.biotech_rounded;
        iconColor = AppTheme.accentBlue;
        break;
      case MedicalFileCategory.scan:
        icon = Icons.document_scanner_rounded;
        iconColor = AppTheme.accentYellow;
        break;
      case MedicalFileCategory.vaccination:
        icon = Icons.vaccines_rounded;
        iconColor = AppTheme.accentGreen;
        break;
      default:
        icon = Icons.folder_open_rounded;
        iconColor = textSec;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showFilePreview(file),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.title,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPri,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          file.category,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: iconColor,
                          ),
                        ),
                        if (file.doctorOrClinic != null) ...[
                          Text(' · ', style: TextStyle(color: textSec)),
                          Expanded(
                            child: Text(
                              file.doctorOrClinic!,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: textSec,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${file.formattedDate} · ${file.formattedSize}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: textSec,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    size: 20, color: textSec),
                onPressed: () => _confirmDelete(context, file),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, Color textPri, Color textSec) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_shared_outlined,
                size: 56,
                color: AppTheme.primaryTeal,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Medical Records Yet',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPri,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Safely store your doctor prescriptions, blood test reports, and scans directly on your phone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: textSec,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _showUploadPickerSheet(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Upload Document',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                side: const BorderSide(color: AppTheme.primaryTeal),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
