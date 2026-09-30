# Ritesh Pawar — Contributor Context

## Current Assignment
- **Modules**: Mobile Proactive Systems, Sensors & Wearables, Architecture Diagrams, Voice I/O
- **Branch**: main
- **Task**: Proactive Background Notifications, Wearable Health Dashboard, and Capstone Diagrams
- **Status**: Active

## Key Responsibilities
1. **Proactive Background Notifications**: Build `background_health_check.dart` using `workmanager` or periodic alarms for AQI > 200 alerts, abnormal vitals alerts, and 8 AM daily briefings.
2. **Health Dashboard Wearable Integration**: Inject live Health Connect cards (Heart Rate, SpO2, Sleep) into `screens/health/health_dashboard.dart`.
3. **Voice Input/Output**: Connect `speech_to_text` and `flutter_tts` in `chat_screen.dart`.
4. **Architecture Diagrams**: Create 7 capstone diagrams (System overview, ReAct state machine, DPDP privacy boundary, Health Connect flow, Multi-key pool, Safety router, NAQI pipeline) in `docs/diagrams/`.
5. **Demo Video**: Record 5-minute walkthrough (`docs/demo_backup.mp4`).

## What's Done ✅
- Health Connect sync with Google Fit and Fitbit live in `health_connect_service.dart`.
- Pedometer sensor stream and step counter with midnight rollover in `fitness_provider.dart`.
- Local notification service with timezone-aware scheduled reminders in `notification_service.dart`.
- Interactive blood pressure, blood sugar, and symptom logging in `health_dashboard.dart`.

## Next Action Items
1. Implement `background_health_check.dart` for AQI and vital anomaly notifications.
2. Display wearable metrics (HR, SpO2, Sleep) inside `HealthDashboard`.
3. Wire `speech_to_text` mic button in `chat_screen.dart`.
4. Export 7 architecture diagrams to `docs/diagrams/`.
5. Record final demonstration video.

## Files I Own
- `frontend/lib/services/background_health_check.dart` (new)
- `frontend/lib/screens/health/health_dashboard.dart`
- `frontend/lib/screens/chat/chat_screen.dart` (voice input wiring)
- `docs/diagrams/`
