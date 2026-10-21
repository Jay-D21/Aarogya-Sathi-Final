# Ritesh Pawar — Contributor Context

## Current Assignment
- **Modules**: Proactive Background Notifications, Architecture Diagrams, Demo Video
- **Branch**: main
- **Status**: Active — Interim Report Review 2 Final, 8 modular architecture diagrams completed

## Key Responsibilities
1. **Proactive Background Notifications**: Build `background_health_check.dart` for AQI > 200 alerts, abnormal vitals alerts, and 8 AM daily briefings.
2. **Architecture Diagrams**: Create 7 capstone diagrams for report/presentation in `docs/diagrams/`.
3. **Demo Video**: Record 5-minute walkthrough (`docs/demo_backup.mp4`).

## Reassigned/Completed By Others
- ~~Health Dashboard Wearable Integration~~ → Abhijit added Medical File Vault banner to HealthDashboard (Session 17).
- ~~Voice Input/Output (STT/TTS)~~ → Abhijit removed `speech_to_text` and `flutter_tts` from pubspec as unused (Session 19). Voice I/O is now dropped from scope.
- ~~Language selector~~ → Jayesh fixed initial persistence (Session 12), Abhijit built full end-to-end wiring with in-chat switcher (Session 16).

## What's Done ✅
- **Review 2 Interim Report**: Authored comprehensive academic Interim Report in `docs/interim_report_review2.md` and finalized `Aarogya_Sathi_Interim_Report_Review_Final.docx` with low AI percentage, custom single-app problem statement, revised abstract, and 42 IEEE citations.
- **Table Names & Captions**: Added formal academic numbered captions for all tables (Table 2.1, 3.1, 4.1, 5.1, 6.1, 6.2) and inserted Table 6.1 (Team Work Packages & Member Contributions) plus Table 6.2 (Review 2 Module Status).
- **Front Matter Cataloging**: Added structured `LIST OF TABLES` and `LIST OF FIGURES` to the front matter immediately after the Table of Contents.
- **8 Compact, High-Legibility Diagrams**: Re-architected diagrams into concise, modular block diagrams with large bold typography and compact display dimensions (max height ≤3.5", width ≤4.8") to resolve the faculty's "too far away" feedback and ensure immediate, crisp legibility at 100% zoom without page overflow:
  - Figure 3.1: Overall System Architecture (Flutter ↔ FastAPI ↔ Agentic ReAct ↔ Inference Cascade)
  - Figure 3.2: Agentic ReAct Loop State Machine and Intent-Driven Execution Pipeline
  - Figure 3.3: Data Sovereignty and Zero-Storage Session Boundary under India's DPDP Act 2023
  - Figure 3.4 / 4.1: Multi-Key Pooling and Multi-Provider Failover Waterfall (Groq ↔ SambaNova ↔ Cerebras ↔ Local Fallbacks)
  - Figure 4.2: Safety Router & Sub-100ms Clinical Triage Pipeline with MiniLM Dense Embeddings
  - Figure 4.3: Environmental NAQI Calculation and Clinical Alerting Pipeline
  - Figure 4.4: Wearable Health Connect Synchronization Pipeline with Smart Deduplication
  - Figure 4.5: ICMR Knowledge Bundle Open Knowledge Format (OKF) Concept Hierarchy and Cross-Linking Graph
- Health Connect sync with Google Fit and Fitbit live in `health_connect_service.dart`.
- Pedometer sensor stream and step counter with midnight rollover in `fitness_provider.dart`.
- Local notification service with timezone-aware scheduled reminders in `notification_service.dart`.
- Interactive blood pressure, blood sugar, and symptom logging in `health_dashboard.dart`.

## Outstanding Work
1. **Proactive background health check service** (`background_health_check.dart`) — Build background worker for AQI > 200 alerts, abnormal vitals alerts, and 8 AM daily briefings.
2. **5-minute demo video** (`docs/demo_backup.mp4`) — Walkthrough recording for capstone presentation.

## Files I Own
- `frontend/lib/services/background_health_check.dart` (not yet created)
- `frontend/lib/screens/health/health_dashboard.dart`
- `docs/diagrams/`
