import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/services/profile_service.dart';
import 'package:frontend/features/profile/data/user_profile_model.dart';

class HealthProfileScreen extends ConsumerStatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  ConsumerState<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends ConsumerState<HealthProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();
  
  bool _isLoading = true;
  
  // Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _medicationController = TextEditingController();
  final _bpSystolicController = TextEditingController();
  final _bpDiastolicController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedSugarType;
  
  final List<String> _conditionsOptions = [
    'Diabetes Type 1', 'Diabetes Type 2', 'Hypertension', 
    'Asthma', 'Heart Disease', 'Thyroid', 'PCOD/PCOS', 'Arthritis', 'None'
  ];
  
  List<String> _selectedConditions = [];
  List<String> _medications = [];
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _profileService.loadProfile();
      if (profile != null) {
        _nameController.text = profile.name ?? '';
        _ageController.text = profile.age?.toString() ?? '';
        _selectedGender = profile.gender;
        _heightController.text = profile.heightCm?.toString() ?? '';
        _weightController.text = profile.weightKg?.toString() ?? '';
        _selectedConditions = List.from(profile.conditions);
        _medications = List.from(profile.medications);
        _bpSystolicController.text = profile.bpSystolic?.toString() ?? '';
        _bpDiastolicController.text = profile.bpDiastolic?.toString() ?? '';
        _bloodSugarController.text = profile.bloodSugar?.toString() ?? '';
        _selectedSugarType = profile.sugarType;
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _medicationController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _bloodSugarController.dispose();
    super.dispose();
  }
  
  // BMI calculation
  double? _calculateBMI() {
    final hStr = _heightController.text;
    final wStr = _weightController.text;
    if (hStr.isEmpty || wStr.isEmpty) return null;
    
    final h = double.tryParse(hStr);
    final w = double.tryParse(wStr);
    
    if (h == null || w == null || h == 0) return null;
    final hMetres = h / 100;
    return w / (hMetres * hMetres);
  }
  
  // BP classification
  (String, Color) _getBpClassification() {
    final sysStr = _bpSystolicController.text;
    final diaStr = _bpDiastolicController.text;
    if (sysStr.isEmpty || diaStr.isEmpty) return ('', Colors.transparent);
    
    final sys = double.tryParse(sysStr);
    final dia = double.tryParse(diaStr);
    
    if (sys == null || dia == null) return ('', Colors.transparent);
    
    if (sys >= 140 || dia >= 90) return ('Stage 2', Colors.red);
    if (sys >= 130 || dia >= 80) return ('Stage 1', Colors.orange);
    if (sys >= 120 && dia < 80) return ('Elevated', Colors.amber);
    return ('Normal', Colors.green);
  }
  
  // Blood sugar classification
  (String, Color) _getBloodSugarClassification() {
    final bsStr = _bloodSugarController.text;
    if (bsStr.isEmpty || _selectedSugarType == null) return ('', Colors.transparent);
    
    final bs = double.tryParse(bsStr);
    if (bs == null) return ('', Colors.transparent);
    
    if (_selectedSugarType == 'Fasting') {
      if (bs >= 126) return ('Diabetes', Colors.red);
      if (bs >= 100) return ('Pre-diabetes', Colors.orange);
      return ('Normal', Colors.green);
    } else if (_selectedSugarType == 'Post-meal') {
      if (bs >= 200) return ('Diabetes', Colors.red);
      if (bs >= 140) return ('Pre-diabetes', Colors.orange);
      return ('Normal', Colors.green);
    }
    
    return ('', Colors.transparent);
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final profile = UserProfileModel(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text),
      gender: _selectedGender,
      heightCm: double.tryParse(_heightController.text),
      weightKg: double.tryParse(_weightController.text),
      conditions: _selectedConditions,
      medications: _medications,
      bpSystolic: double.tryParse(_bpSystolicController.text),
      bpDiastolic: double.tryParse(_bpDiastolicController.text),
      bloodSugar: double.tryParse(_bloodSugarController.text),
      sugarType: _selectedSugarType,
    );
    
    await _profileService.saveProfile(profile);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  void _addMedication(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !_medications.contains(trimmed)) {
      setState(() {
        _medications.add(trimmed);
        _medicationController.clear();
      });
    }
  }

  void _removeMedication(String value) {
    setState(() {
      _medications.remove(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final bmi = _calculateBMI();
    final bpClass = _getBpClassification();
    final bsClass = _getBloodSugarClassification();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
            tooltip: 'Save Profile',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Basic Information'),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Age',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                border: OutlineInputBorder(),
                              ),
                              items: ['Male', 'Female', 'Other'].map((g) {
                                return DropdownMenuItem(value: g, child: Text(g));
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedGender = val),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Body Metrics'),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Height (cm)',
                                border: OutlineInputBorder(),
                                suffixText: 'cm',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                border: OutlineInputBorder(),
                                suffixText: 'kg',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      if (bmi != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Calculated BMI:'),
                              Text(
                                bmi.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Chronic Conditions'),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _conditionsOptions.map((condition) {
                      final isSelected = _selectedConditions.contains(condition);
                      return FilterChip(
                        label: Text(condition),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (condition == 'None') {
                              _selectedConditions = selected ? ['None'] : [];
                            } else {
                              _selectedConditions.remove('None');
                              if (selected) {
                                _selectedConditions.add(condition);
                              } else {
                                _selectedConditions.remove(condition);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Medications'),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _medicationController,
                        decoration: InputDecoration(
                          labelText: 'Add Medication (Press Enter)',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _addMedication(_medicationController.text),
                          ),
                        ),
                        onFieldSubmitted: _addMedication,
                      ),
                      if (_medications.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _medications.map((med) {
                            return Chip(
                              label: Text(med),
                              onDeleted: () => _removeMedication(med),
                            );
                          }).toList(),
                        ),
                      ]
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('Vitals & Readings'),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _bpSystolicController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'BP Systolic',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('/', style: TextStyle(fontSize: 24)),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _bpDiastolicController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'BP Diastolic',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      if (bpClass.$1.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            label: Text(
                              'BP: ${bpClass.$1}', 
                              style: const TextStyle(color: Colors.white)
                            ),
                            backgroundColor: bpClass.$2,
                          ),
                        ),
                      ],
                      
                      const Divider(height: 32),
                      
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _bloodSugarController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Blood Sugar',
                                border: OutlineInputBorder(),
                                suffixText: 'mg/dL',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedSugarType,
                              decoration: const InputDecoration(
                                labelText: 'Type',
                                border: OutlineInputBorder(),
                              ),
                              items: ['Fasting', 'Post-meal', 'Random'].map((t) {
                                return DropdownMenuItem(value: t, child: Text(t));
                              }).toList(),
                              onChanged: (val) {
                                setState(() => _selectedSugarType = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      if (bsClass.$1.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            label: Text(
                              'Sugar: ${bsClass.$1}',
                              style: const TextStyle(color: Colors.white)
                            ),
                            backgroundColor: bsClass.$2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Profile',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
