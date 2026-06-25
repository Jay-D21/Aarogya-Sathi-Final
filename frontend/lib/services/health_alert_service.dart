import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Proactive health alert system for Aarogya Sathi.
///
/// Fires local notifications when:
/// - User logs abnormal vitals (BP, blood sugar, HR, SpO2)
/// - AQI at user's location exceeds safe thresholds
/// - Backend generates proactive clinical insights
/// - Daily morning health briefing is due
///
/// WHY on-device: Zero-budget constraint means no push notification server.
/// Local notifications work offline, cost nothing, and keep data private (DPDP).
/// Monitors health vitals and environmental data to fire timely
/// Android notifications when ICMR-defined thresholds are breached.
///
/// Channels:
///   • vital_alerts   – critical BP, glucose, SpO2, HR alerts
///   • env_alerts     – AQI hazard and pollen warnings
///   • insight_alerts – daily AI-generated health insights
class HealthAlertService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  // Notification channel IDs (Android groups alerts by channel)
  static const _channelVitals = 'aarogya_vital_alerts';
  static const _channelAqi = 'aarogya_aqi_alerts';
  static const _channelInsights = 'aarogya_insights';

  // Notification ID ranges to avoid collisions with ReminderProvider
  // (ReminderProvider uses id.hashCode.abs() % 100000)
  static const _idBPAlert = 200001;
  static const _idSugarAlert = 200002;
  static const _idHRAlert = 200003;
  static const _idSpO2Alert = 200004;
  static const _idAQIAlert = 200010;
  static const _idInsightBase = 200020;

  // Cooldown tracking to avoid notification spam
  static const _kLastBPAlert = 'alert_last_bp';
  static const _kLastSugarAlert = 'alert_last_sugar';
  static const _kLastAQIAlert = 'alert_last_aqi';
  static const _kLastInsightPoll = 'alert_last_insight_poll';
  static const _cooldownMinutes = 60; // Min gap between same-type alerts

  // ── Vital Threshold Alerts ────────────────────────────────────────────────

  /// Check BP reading and fire alert if outside safe range (ICMR thresholds).
  /// Call this from HealthProvider whenever a new BP reading is logged.
  static Future<void> checkBP(int systolic, int diastolic) async {
    if (systolic < 90 || systolic >= 180 || diastolic >= 120) {
      // Hypertensive crisis or hypotension — urgent
      await _fireVitalAlert(
        id: _idBPAlert,
        cooldownKey: _kLastBPAlert,
        title: '🚨 Blood Pressure Alert',
        body: systolic < 90
            ? 'Low BP detected: $systolic/$diastolic mmHg. Sit down, drink water. If dizzy, call 108.'
            : 'Critical BP: $systolic/$diastolic mmHg. This needs immediate medical attention. Call your doctor or 108.',
        isUrgent: true,
      );
    } else if (systolic >= 140 || diastolic >= 90) {
      // Stage 2 hypertension — warning
      await _fireVitalAlert(
        id: _idBPAlert,
        cooldownKey: _kLastBPAlert,
        title: '⚠️ High Blood Pressure',
        body: 'BP reading: $systolic/$diastolic mmHg (Stage 2). Rest, avoid salt, and consult your doctor.',
      );
    } else if (systolic >= 130 || diastolic >= 80) {
      // Stage 1 hypertension — informational
      await _fireVitalAlert(
        id: _idBPAlert,
        cooldownKey: _kLastBPAlert,
        title: 'Blood Pressure Notice',
        body: 'BP: $systolic/$diastolic mmHg (elevated). Monitor regularly and maintain a low-salt diet.',
      );
    }
  }

  /// Check blood sugar reading and fire alert if abnormal (ICMR thresholds).
  static Future<void> checkBloodSugar(double value, {String type = 'fasting'}) async {
    if (value >= 300) {
      await _fireVitalAlert(
        id: _idSugarAlert,
        cooldownKey: _kLastSugarAlert,
        title: '🚨 Critical Blood Sugar',
        body: 'Blood glucose: ${value.toStringAsFixed(0)} mg/dL. Seek medical help immediately. Call 108 if feeling dizzy or confused.',
        isUrgent: true,
      );
    } else if (value >= 200) {
      await _fireVitalAlert(
        id: _idSugarAlert,
        cooldownKey: _kLastSugarAlert,
        title: '⚠️ High Blood Sugar',
        body: 'Blood glucose: ${value.toStringAsFixed(0)} mg/dL ($type). Contact your doctor soon.',
      );
    } else if (value >= 126 && type == 'fasting') {
      await _fireVitalAlert(
        id: _idSugarAlert,
        cooldownKey: _kLastSugarAlert,
        title: 'Blood Sugar Notice',
        body: 'Fasting glucose: ${value.toStringAsFixed(0)} mg/dL (diabetes range). Monitor closely.',
      );
    } else if (value < 70) {
      await _fireVitalAlert(
        id: _idSugarAlert,
        cooldownKey: _kLastSugarAlert,
        title: '⚠️ Low Blood Sugar',
        body: 'Blood glucose: ${value.toStringAsFixed(0)} mg/dL. Eat something sweet immediately (juice, glucose tablets).',
        isUrgent: true,
      );
    }
  }

  /// Check heart rate and fire alert if abnormal.
  static Future<void> checkHeartRate(int bpm) async {
    if (bpm >= 150) {
      await _fireVitalAlert(
        id: _idHRAlert,
        cooldownKey: _kLastBPAlert, // Reuse BP cooldown to avoid spam
        title: '🚨 High Heart Rate',
        body: 'Heart rate: $bpm bpm. If resting and not exercising, seek medical attention.',
        isUrgent: true,
      );
    } else if (bpm >= 120) {
      await _fireVitalAlert(
        id: _idHRAlert,
        cooldownKey: _kLastBPAlert,
        title: '⚠️ Elevated Heart Rate',
        body: 'Heart rate: $bpm bpm. Rest, breathe deeply. If persistent, consult your doctor.',
      );
    } else if (bpm < 50) {
      await _fireVitalAlert(
        id: _idHRAlert,
        cooldownKey: _kLastBPAlert,
        title: '⚠️ Low Heart Rate',
        body: 'Heart rate: $bpm bpm (bradycardia). If feeling faint or dizzy, seek medical help.',
      );
    }
  }

  /// Check SpO2 and fire alert if dangerously low.
  static Future<void> checkSpO2(double percent) async {
    if (percent < 90) {
      await _fireVitalAlert(
        id: _idSpO2Alert,
        cooldownKey: _kLastBPAlert,
        title: '🚨 Low Oxygen Level',
        body: 'SpO2: ${percent.toStringAsFixed(0)}%. This is dangerously low. Seek emergency care. Call 108.',
        isUrgent: true,
      );
    } else if (percent < 94) {
      await _fireVitalAlert(
        id: _idSpO2Alert,
        cooldownKey: _kLastBPAlert,
        title: '⚠️ Low Oxygen Level',
        body: 'SpO2: ${percent.toStringAsFixed(0)}%. Monitor closely. If breathing difficulty, see a doctor.',
      );
    }
  }

  // ── AQI Alert ─────────────────────────────────────────────────────────────

  /// Check AQI value and fire alert if air quality is hazardous.
  /// Call this from home_screen.dart after AQI fetch completes.
  static Future<void> checkAQI(int aqi, {String? station}) async {
    if (aqi >= 300) {
      await _fireAQIAlert(
        title: '🚨 Hazardous Air Quality',
        body: 'AQI: $aqi${station != null ? ' near $station' : ''}. Stay indoors. Wear N95 mask if going out. Close all windows.',
        isUrgent: true,
      );
    } else if (aqi >= 200) {
      await _fireAQIAlert(
        title: '⚠️ Very Poor Air Quality',
        body: 'AQI: $aqi${station != null ? ' near $station' : ''}. Avoid outdoor exercise. Use air purifier if available.',
      );
    } else if (aqi >= 150) {
      await _fireAQIAlert(
        title: 'Air Quality Advisory',
        body: 'AQI: $aqi (unhealthy for sensitive groups). Asthma/respiratory patients should limit outdoor activity.',
      );
    }
  }

  // ── Backend Insights Polling ──────────────────────────────────────────────

  /// Poll the backend insights endpoint and convert proactive observations
  /// into local notifications. Call this periodically (e.g., every 30 min
  /// when app is in foreground, or on home screen init).
  static Future<void> pollInsights({
    required String userId,
    double? lat,
    double? lon,
  }) async {
    // Cooldown: don't poll more than once per 30 minutes
    final prefs = await SharedPreferences.getInstance();
    final lastPoll = prefs.getInt(_kLastInsightPoll) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastPoll < 30 * 60 * 1000) return;

    try {
      var url = '${ApiConfig.baseUrl}/api/session/$userId/insights';
      final params = <String>[];
      if (lat != null) params.add('lat=$lat');
      if (lon != null) params.add('lon=$lon');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final resp = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>?;
        if (data != null) {
          final insights = data['insights'] as List? ?? [];
          // Show up to 3 insights as notifications
          for (var i = 0; i < insights.length && i < 3; i++) {
            final insight = insights[i].toString();
            await _showNotification(
              id: _idInsightBase + i,
              channelId: _channelInsights,
              channelName: 'Health Insights',
              title: '💡 Health Insight',
              body: insight,
            );
          }
        }
      }

      await prefs.setInt(_kLastInsightPoll, now);
    } catch (e) {
      debugPrint('[HealthAlertService] Insight poll failed: $e');
    }
  }

  // ── Internal Helpers ──────────────────────────────────────────────────────

  static Future<void> _fireVitalAlert({
    required int id,
    required String cooldownKey,
    required String title,
    required String body,
    bool isUrgent = false,
  }) async {
    if (!await _checkCooldown(cooldownKey)) return;

    await _showNotification(
      id: id,
      channelId: _channelVitals,
      channelName: 'Vital Alerts',
      channelDescription: 'Alerts for abnormal health readings',
      title: title,
      body: body,
      importance: isUrgent ? Importance.max : Importance.high,
      priority: isUrgent ? Priority.max : Priority.high,
    );
  }

  static Future<void> _fireAQIAlert({
    required String title,
    required String body,
    bool isUrgent = false,
  }) async {
    if (!await _checkCooldown(_kLastAQIAlert)) return;

    await _showNotification(
      id: _idAQIAlert,
      channelId: _channelAqi,
      channelName: 'Air Quality Alerts',
      channelDescription: 'Alerts when air quality is unhealthy',
      title: title,
      body: body,
      importance: isUrgent ? Importance.max : Importance.high,
      priority: isUrgent ? Priority.high : Priority.defaultPriority,
    );
  }

  /// Returns true if enough time has passed since the last alert of this type.
  static Future<bool> _checkCooldown(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(key) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastMs < _cooldownMinutes * 60 * 1000) return false;
    await prefs.setInt(key, now);
    return true;
  }

  static Future<void> _showNotification({
    required int id,
    required String channelId,
    required String channelName,
    String? channelDescription,
    required String title,
    required String body,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription ?? channelName,
      importance: importance,
      priority: priority,
      playSound: true,
      styleInformation: BigTextStyleInformation(body),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(id: id, title: title, body: body, notificationDetails: details);
  }
}
