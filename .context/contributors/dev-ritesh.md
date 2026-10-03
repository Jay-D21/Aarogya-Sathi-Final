# Ritesh Pawar — Contributor Context

## Current Assignment
- **Modules**: Proactive Background Notifications, Architecture Diagrams, Demo Video
- **Branch**: main
- **Status**: Pending (0 commits since project start)

## Key Responsibilities
1. **Proactive Background Notifications**: Build `background_health_check.dart` for AQI > 200 alerts, abnormal vitals alerts, and 8 AM daily briefings.
2. **Architecture Diagrams**: Create 7 capstone diagrams for report/presentation in `docs/diagrams/`.
3. **Demo Video**: Record 5-minute walkthrough (`docs/demo_backup.mp4`).

## Reassigned/Completed By Others
- ~~Health Dashboard Wearable Integration~~ → Abhijit added Medical File Vault banner to HealthDashboard (Session 17).
- ~~Voice Input/Output (STT/TTS)~~ → Abhijit removed `speech_to_text` and `flutter_tts` from pubspec as unused (Session 19). Voice I/O is now dropped from scope.
- ~~Language selector~~ → Jayesh fixed initial persistence (Session 12), Abhijit built full end-to-end wiring with in-chat switcher (Session 16).

## What's Done ✅
- Health Connect sync with Google Fit and Fitbit live in `health_connect_service.dart`.
- Pedometer sensor stream and step counter with midnight rollover in `fitness_provider.dart`.
- Local notification service with timezone-aware scheduled reminders in `notification_service.dart`.
- Interactive blood pressure, blood sugar, and symptom logging in `health_dashboard.dart`.

## Outstanding Work
1. **Proactive background health check service** (`background_health_check.dart`) — NOT STARTED.
2. **7 architecture diagrams** for capstone report — NOT STARTED.
3. **5-minute demo video** — NOT STARTED.

## Files I Own
- `frontend/lib/services/background_health_check.dart` (not yet created)
- `frontend/lib/screens/health/health_dashboard.dart`
- `docs/diagrams/`
