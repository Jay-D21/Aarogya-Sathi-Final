import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/health_connect_service.dart';
import '../models/wearable_data_model.dart';

enum SyncStatus {
  success,
  noData,
  permissionDenied,
  permissionRequired,
  unavailable,
  error,
}

class SyncResult {
  final SyncStatus status;
  final String message;
  final int dataCount;

  const SyncResult({
    required this.status,
    required this.message,
    this.dataCount = 0,
  });
}

class FitnessProvider extends ChangeNotifier {
  // ── SharedPreferences keys ──────────────────────────────────────────────────
  static const _kDate       = 'fit_date';          // 'YYYY-MM-DD'
  static const _kSteps      = 'fit_steps';          // int: today's steps
  static const _kWater      = 'fit_water_ml';       // int: ml logged today
  static const _kSleep      = 'fit_sleep_h';        // double: hours slept
  static const _kHeartRate  = 'fit_heart_rate';     // int: latest bpm
  static const _kCalories   = 'fit_calories';       // int: calories burned
  static const _kSpo2       = 'fit_spo2';           // double: SpO2 %
  static const _kPedoOffset = 'fit_pedo_offset';    // int: pedometer baseline
  static const _kPedoDate   = 'fit_pedo_date';      // String: date offset was set

  // ── Internal state ──────────────────────────────────────────────────────────
  bool _loading = false;
  bool _isSyncing = false;
  bool _healthConnectAuthorized = false;
  bool _isHealthConnectSynced = false;
  StreamSubscription<StepCount>? _stepSub;
  final HealthConnectService _healthConnect = HealthConnectService();

  int    _localSteps = 0;
  int    _localWater = 0;
  double _localSleep = 0.0;
  int?   _heartRate;
  int?   _wearableCalories;
  double? _spo2;

  // ── Public getters ──────────────────────────────────────────────────────────
  bool   get isLoading   => _loading;
  bool   get isSyncing   => _isSyncing;
  bool   get isHealthConnectAuthorized => _healthConnectAuthorized;
  bool   get isHealthConnectSynced => _isHealthConnectSynced;
  int    get steps       => _localSteps;
  int    get waterMl     => _localWater;
  double get sleepHours  => _localSleep;
  int?   get heartRate   => _heartRate;
  double? get spo2       => _spo2;

  /// Calorie estimate: uses wearable synced calories if available,
  /// otherwise weight-aware MET formula: steps × weight(kg) × 0.000516.
  int calories({double weightKg = 70.0}) {
    if (_wearableCalories != null && _wearableCalories! > 0) {
      return _wearableCalories!;
    }
    return (steps * weightKg * 0.000516).toInt();
  }

  // ── Initialisation ──────────────────────────────────────────────────────────

  /// Single init entry-point called from HomeScreen.
  /// Loads local data, syncs Health Connect/Fitbit, starts pedometer, then syncs backend.
  Future<void> init() async {
    await _loadLocalDay();
    notifyListeners();

    // Auto-sync Health Connect / Fitbit if available
    unawaited(syncFromHealthConnect());
    unawaited(initPedometer());
    unawaited(_syncFromBackend());
  }

  /// Load today's data from SharedPreferences.
  /// Resets all counters if the date has changed (midnight rollover).
  Future<void> _loadLocalDay() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _todayStr();
    final savedDate = prefs.getString(_kDate);

    if (savedDate != todayStr) {
      // New day — clear all counters and save today's date
      await prefs.setString(_kDate, todayStr);
      await prefs.setInt(_kSteps, 0);
      await prefs.setInt(_kWater, 0);
      await prefs.setDouble(_kSleep, 0.0);
      await prefs.remove(_kHeartRate);
      await prefs.remove(_kCalories);
      await prefs.remove(_kSpo2);
      _localSteps = 0;
      _localWater = 0;
      _localSleep = 0.0;
      _heartRate = null;
      _wearableCalories = null;
      _spo2 = null;
    } else {
      _localSteps = prefs.getInt(_kSteps) ?? 0;
      _localWater = prefs.getInt(_kWater) ?? 0;
      _localSleep = prefs.getDouble(_kSleep) ?? 0.0;
      _heartRate = prefs.getInt(_kHeartRate);
      _wearableCalories = prefs.getInt(_kCalories);
      _spo2 = prefs.getDouble(_kSpo2);
    }
  }

  // ── Health Connect / Fitbit Synchronization ──────────────────────────────────

  /// Syncs data from Android Health Connect (which bridges Fitbit, Google Fit, Samsung Health, etc.)
  Future<SyncResult> syncFromHealthConnect({bool requestPermissions = false}) async {
    _isSyncing = true;
    notifyListeners();

    try {
      final available = await _healthConnect.isHealthConnectAvailable();
      if (!available) {
        debugPrint('[HealthConnectSync] Health Connect is not available on this device');
        return const SyncResult(
          status: SyncStatus.unavailable,
          message: 'Health Connect is not available or not installed on this device.',
        );
      }

      if (requestPermissions) {
        final ok = await _healthConnect.requestPermissions();
        _healthConnectAuthorized = ok;
        if (!ok) {
          return const SyncResult(
            status: SyncStatus.permissionDenied,
            message: 'Health Connect permissions were not granted. Please allow access to sync your wearable data.',
          );
        }
      } else {
        _healthConnectAuthorized = await _healthConnect.hasPermissions();
        if (!_healthConnectAuthorized) {
          return const SyncResult(
            status: SyncStatus.permissionRequired,
            message: 'Health Connect permissions required.',
          );
        }
      }

      final WearableDataModel data = await _healthConnect.fetchTodayData();
      final prefs = await SharedPreferences.getInstance();

      bool changed = false;
      int dataCount = 0;

      // Steps from wearable
      if (data.todaySteps != null && data.todaySteps! > 0) {
        _localSteps = data.todaySteps!;
        _isHealthConnectSynced = true;
        await prefs.setInt(_kSteps, _localSteps);
        changed = true;
        dataCount++;
      }

      // Calories from wearable
      if (data.caloriesBurned != null && data.caloriesBurned! > 0) {
        _wearableCalories = data.caloriesBurned;
        await prefs.setInt(_kCalories, _wearableCalories!);
        changed = true;
        dataCount++;
      }

      // Heart rate from wearable
      final hr = data.heartRateBpm ?? data.restingHeartRate;
      if (hr != null && hr > 0) {
        _heartRate = hr.toInt();
        await prefs.setInt(_kHeartRate, _heartRate!);
        changed = true;
        dataCount++;
      }

      // Sleep from wearable
      if (data.sleepTotalHours != null && data.sleepTotalHours! > 0) {
        _localSleep = max(_localSleep, data.sleepTotalHours!);
        await prefs.setDouble(_kSleep, _localSleep);
        changed = true;
        dataCount++;
      }

      // SpO2 from wearable
      if (data.spo2Percent != null && data.spo2Percent! > 0) {
        _spo2 = data.spo2Percent;
        await prefs.setDouble(_kSpo2, _spo2!);
        changed = true;
        dataCount++;
      }

      if (changed) notifyListeners();

      if (dataCount > 0) {
        final List<String> summaryParts = [];
        if (data.todaySteps != null && data.todaySteps! > 0) {
          summaryParts.add('${data.todaySteps} steps');
        }
        if (_heartRate != null) {
          summaryParts.add('$_heartRate bpm');
        }
        if (data.sleepTotalHours != null && data.sleepTotalHours! > 0) {
          summaryParts.add('${data.sleepTotalHours}h sleep');
        }
        if (_wearableCalories != null) {
          summaryParts.add('$_wearableCalories kcal');
        }
        final summary = summaryParts.join(' • ');
        return SyncResult(
          status: SyncStatus.success,
          message: summary.isNotEmpty ? summary : 'Health data synced successfully!',
          dataCount: dataCount,
        );
      } else {
        return const SyncResult(
          status: SyncStatus.noData,
          message: 'Connected to Health Connect, but no Fitbit data was found yet. In the Fitbit app, go to Settings → Health Connect and turn sync ON.',
          dataCount: 0,
        );
      }
    } catch (e) {
      debugPrint('[HealthConnectSync] Error: $e');
      return SyncResult(
        status: SyncStatus.error,
        message: 'Sync error: $e',
      );
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // ── Hardware Pedometer Step Tracking ─────────────────────────────────────────

  /// Start listening to the hardware step counter.
  /// Handles the cumulative-count daily offset correctly:
  /// - On the first event of a new day, the current total becomes the offset.
  /// - Steps today = (current total) − (offset).
  Future<void> initPedometer() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    final granted = await Permission.activityRecognition.request().isGranted;
    if (!granted) return;

    await _stepSub?.cancel();
    final prefs = await SharedPreferences.getInstance();

    _stepSub = Pedometer.stepCountStream.listen(
      (StepCount event) async {
        final todayStr = _todayStr();
        final offsetDate = prefs.getString(_kPedoDate);

        int offset;
        if (offsetDate != todayStr) {
          // First event of the day → capture baseline
          offset = event.steps;
          await prefs.setInt(_kPedoOffset, offset);
          await prefs.setString(_kPedoDate, todayStr);
        } else {
          offset = prefs.getInt(_kPedoOffset) ?? event.steps;
        }

        // If Health Connect / Google Fit is authorized and has already synced today,
        // we respect the wearable/Google Fit authoritative count.
        if (_healthConnectAuthorized && _isHealthConnectSynced) {
          return;
        }

        final todaySteps = (event.steps - offset).clamp(0, 999999);

        // Don't overwrite if wearable reported
        if (todaySteps > _localSteps) {
          _localSteps = todaySteps;
          await prefs.setInt(_kSteps, _localSteps);
          notifyListeners();

          // Background sync every 500 steps
          if (_localSteps > 0 && _localSteps % 500 == 0) {
            _fireAndForget(() => ApiService.post('/fitness/steps', {
                  'steps_count': _localSteps,
                  'log_date': todayStr,
                }));
          }
        }
      },
      onError: (err) => debugPrint('[Pedometer] $err'),
    );
  }

  // ── Public actions ──────────────────────────────────────────────────────────

  /// Log water intake in ml. Local-first with background API sync.
  Future<void> logWater(int ml) async {
    _localWater += ml;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWater, _localWater);
    notifyListeners();
    _fireAndForget(() => ApiService.post('/fitness/water', {'water_ml': ml}));
  }

  /// Log sleep hours + quality. Local-first with background API sync.
  Future<void> logSleep(double hours, int quality) async {
    _localSleep = hours;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kSleep, hours);
    notifyListeners();
    _fireAndForget(() => ApiService.post('/fitness/sleep', {
          'sleep_hours': hours,
          'sleep_quality': quality,
        }));
  }

  /// Manually trigger a full sync across Health Connect, Pedometer, and backend
  Future<void> syncAll() async {
    _loading = true;
    notifyListeners();
    await syncFromHealthConnect(requestPermissions: true);
    await _syncFromBackend();
    _loading = false;
    notifyListeners();
  }

  // ── Backward-compat alias ───────────────────────────────────────────────────
  Future<void> loadSummary({String? date}) => _syncFromBackend();

  // ── Backend sync ────────────────────────────────────────────────────────────

  /// Pull today's summary from backend. Takes the higher of server vs. local
  /// so data is never lost even when offline periods occur.
  Future<void> _syncFromBackend() async {
    try {
      final resp = await ApiService.get('/fitness/summary');
      final data = resp['data'] as Map<String, dynamic>?;
      if (data == null) return;

      final sSteps = (data['steps'] as num?)?.toInt() ?? 0;
      final sWater = (data['water_ml'] as num?)?.toInt() ?? 0;
      final sSleep = (data['sleep_hours'] as num?)?.toDouble() ?? 0.0;

      bool changed = false;
      if (sSteps > _localSteps) { _localSteps = sSteps; changed = true; }
      if (sWater > _localWater) { _localWater = sWater; changed = true; }
      if (sSleep > _localSleep) { _localSleep = sSleep; changed = true; }
      if (changed) notifyListeners();
    } catch (_) { /* Offline — local data is already displayed */ }
  }

  // ── Disposal ────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _stepSub?.cancel();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  static String _todayStr() => DateTime.now().toIso8601String().split('T')[0];

  void _fireAndForget(Future<dynamic> Function() fn) {
    fn().catchError((_) {});
  }
}
