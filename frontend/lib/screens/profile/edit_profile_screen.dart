import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/location_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _customConditionCtrl;
  late TextEditingController _medicationCtrl;

  String _gender = 'Male';
  String _city = 'Delhi';
  bool _isLoading = false;
  bool _isDetectingLocation = false;

  final List<String> _conditions = [];
  final List<String> _medications = [];

  static const List<String> _suggestedConditions = [
    'Type 2 Diabetes',
    'Hypertension',
    'Asthma',
    'COPD',
    'Thyroid Disorder',
    'Coronary Artery Disease',
    'Chronic Kidney Disease',
    'High Cholesterol',
  ];

  static const List<String> _availableCities = [
    'Delhi',
    'Mumbai',
    'Bangalore',
    'Pune',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Ahmedabad',
    'Jaipur',
    'Lucknow',
    'Chandigarh',
    'Nashik',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user ?? {};

    _firstNameCtrl =
        TextEditingController(text: user['first_name'] as String? ?? '');
    _lastNameCtrl =
        TextEditingController(text: user['last_name'] as String? ?? '');
    _ageCtrl = TextEditingController(
        text: (user['age'] as num?)?.toInt().toString() ?? '');
    _heightCtrl = TextEditingController(
        text: (user['height_cm'] as num?)?.toString() ?? '');
    _weightCtrl = TextEditingController(
        text: (user['weight_kg'] as num?)?.toString() ?? '');
    _customConditionCtrl = TextEditingController();
    _medicationCtrl = TextEditingController();

    _gender = (user['gender'] as String?) ?? 'Male';
    _city = (user['preferred_city'] as String?) ?? 'Delhi';

    if (user['conditions'] is List) {
      for (final c in user['conditions']) {
        if (c != null && c.toString().isNotEmpty) {
          _conditions.add(c.toString());
        }
      }
    }

    if (user['medications'] is List) {
      for (final m in user['medications']) {
        if (m != null && m.toString().isNotEmpty) {
          _medications.add(m.toString());
        }
      }
    }

    _heightCtrl.addListener(() => setState(() {}));
    _weightCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _customConditionCtrl.dispose();
    _medicationCtrl.dispose();
    super.dispose();
  }

  double? get _calculatedBmi {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    if (h == null || w == null || h <= 0 || w <= 0) return null;
    final hMeters = h / 100.0;
    return double.parse((w / (hMeters * hMeters)).toStringAsFixed(1));
  }

  (String, Color) get _bmiClassification {
    final bmi = _calculatedBmi;
    if (bmi == null) return ('--', Colors.grey);
    // Asian ICMR BMI cutoffs
    if (bmi < 18.5) return ('Underweight', AppTheme.accentBlue);
    if (bmi <= 22.9) return ('Normal (ICMR Target)', AppTheme.accentGreen);
    if (bmi <= 27.4) return ('Overweight (Asian Cutoff)', AppTheme.accentOrange);
    return ('Obese (Asian Cutoff)', AppTheme.accentRed);
  }

  Future<void> _detectLocation() async {
    setState(() => _isDetectingLocation = true);
    try {
      final city = await LocationService.getCityName();
      if (city != null && mounted) {
        setState(() {
          _city = city;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('City updated to $city from GPS'),
            backgroundColor: AppTheme.primaryTeal,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not detect location')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDetectingLocation = false);
    }
  }

  void _addCustomCondition() {
    final text = _customConditionCtrl.text.trim();
    if (text.isEmpty) return;
    if (!_conditions.contains(text)) {
      setState(() => _conditions.add(text));
    }
    _customConditionCtrl.clear();
  }

  void _addMedication() {
    final text = _medicationCtrl.text.trim();
    if (text.isEmpty) return;
    if (!_medications.contains(text)) {
      setState(() => _medications.add(text));
    }
    _medicationCtrl.clear();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final height = double.tryParse(_heightCtrl.text);
    final weight = double.tryParse(_weightCtrl.text);
    final age = int.tryParse(_ageCtrl.text);
    final bmi = _calculatedBmi;

    final updatedData = {
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'age': age,
      'gender': _gender,
      'height_cm': height,
      'weight_kg': weight,
      'bmi': ?bmi,
      'preferred_city': _city,
      'conditions': _conditions,
      'medications': _medications,
    };

    final auth = context.read<AuthProvider>();
    await auth.updateProfile(updatedData);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppTheme.primaryTeal,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPri = AppTheme.textPrimaryOf(context);
    final textSec = AppTheme.textSecondaryOf(context);
    final bg = AppTheme.bgOf(context);
    final card = AppTheme.cardBg(context);
    final border = AppTheme.borderColor(context);

    final (bmiStatus, bmiColor) = _bmiClassification;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        title: Text('Edit Profile',
            style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Save',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryTeal)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // ── Section 1: Personal Details ──
            _sectionHeader('Personal Details', textPri),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameCtrl,
                          decoration: const InputDecoration(labelText: 'First Name *'),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameCtrl,
                          decoration: const InputDecoration(labelText: 'Last Name'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Age (Years) *'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final a = int.tryParse(v);
                            if (a == null || a <= 0 || a > 120) return 'Invalid age';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _gender,
                          decoration: const InputDecoration(labelText: 'Gender'),
                          items: ['Male', 'Female', 'Other'].map((g) {
                            return DropdownMenuItem(value: g, child: Text(g));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _gender = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(_city),
                          initialValue: _availableCities.contains(_city) ? _city : null,
                          hint: Text(_city),
                          decoration: const InputDecoration(labelText: 'Preferred City'),
                          items: _availableCities.map((c) {
                            return DropdownMenuItem(value: c, child: Text(c));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _city = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: _isDetectingLocation ? null : _detectLocation,
                        icon: _isDetectingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.my_location_rounded, size: 20),
                        tooltip: 'Detect via GPS',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Section 2: Body Measurements & BMI ──
            _sectionHeader('Body Measurements & BMI', textPri),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Height (cm) *',
                            suffixText: 'cm',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final h = double.tryParse(v);
                            if (h == null || h < 40 || h > 260) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _weightCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Weight (kg) *',
                            suffixText: 'kg',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final w = double.tryParse(v);
                            if (w == null || w < 2 || w > 350) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Dynamic BMI Calculator Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bmiColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: bmiColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: bmiColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _calculatedBmi != null
                                ? _calculatedBmi!.toStringAsFixed(1)
                                : '--',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Calculated BMI: $bmiStatus',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textPri,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ICMR Asian Target: 18.5 – 22.9 kg/m²',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: textSec,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Section 3: Chronic Health Conditions ──
            _sectionHeader('Chronic Health Conditions', textPri),
            const SizedBox(height: 4),
            Text(
              'Used by the AI assistant to tailor health precautions and alerts.',
              style: GoogleFonts.inter(fontSize: 12, color: textSec),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestedConditions.map((cond) {
                      final isSelected = _conditions.contains(cond);
                      return FilterChip(
                        label: Text(cond),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryTeal.withValues(alpha: 0.18),
                        checkmarkColor: AppTheme.primaryTeal,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 12,
                          color: isSelected ? AppTheme.primaryTeal : textPri,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryTeal : border,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _conditions.add(cond);
                            } else {
                              _conditions.remove(cond);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customConditionCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Add another condition...',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onSubmitted: (_) => _addCustomCondition(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: _addCustomCondition,
                        icon: const Icon(Icons.add_rounded),
                        tooltip: 'Add Condition',
                      ),
                    ],
                  ),
                  if (_conditions
                      .any((c) => !_suggestedConditions.contains(c))) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _conditions
                          .where((c) => !_suggestedConditions.contains(c))
                          .map((custom) {
                        return Chip(
                          label: Text(custom),
                          labelStyle: GoogleFonts.inter(fontSize: 12),
                          deleteIcon: const Icon(Icons.close_rounded, size: 16),
                          onDeleted: () =>
                              setState(() => _conditions.remove(custom)),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Section 4: Current Medications ──
            _sectionHeader('Current Medications', textPri),
            const SizedBox(height: 4),
            Text(
              'Helps prevent adverse drug-nutrient interactions in dietary guidance.',
              style: GoogleFonts.inter(fontSize: 12, color: textSec),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _medicationCtrl,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Metformin 500mg, Amlodipine 5mg',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onSubmitted: (_) => _addMedication(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: _addMedication,
                        icon: const Icon(Icons.add_rounded),
                        tooltip: 'Add Medication',
                      ),
                    ],
                  ),
                  if (_medications.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _medications.map((med) {
                        return Chip(
                          avatar: const Icon(Icons.medication_rounded,
                              size: 16, color: AppTheme.primaryTeal),
                          label: Text(med),
                          labelStyle: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w500),
                          deleteIcon: const Icon(Icons.close_rounded, size: 16),
                          onDeleted: () =>
                              setState(() => _medications.remove(med)),
                        );
                      }).toList(),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      'No medications added yet.',
                      style: GoogleFonts.inter(fontSize: 12, color: textSec),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Submit Button ──
            FilledButton.icon(
              onPressed: _isLoading ? null : _saveProfile,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text('Save Profile Changes',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color textPri) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textPri,
      ),
    );
  }
}
