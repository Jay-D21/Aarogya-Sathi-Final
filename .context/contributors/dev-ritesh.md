# Ritesh Pawar — Contributor Context

## Current Assignment
- **Modules**: Flutter App, UI/UX, Architecture Diagrams
- **Branch**: main
- **Task**: Upgrade Flutter app to connect to CRAG backend + create diagrams
- **Started**: 2026-09-08

## Responsibilities
1. Upgrade chat screen to use real SSE streaming from backend
2. Fix AQI endpoint URL mismatch
3. Create health profile screen (new)
4. Centralize API base URL config
5. Connect register screen to backend (when Abhijit adds auth)
6. Create 7 professional architecture diagrams for capstone report
7. UI polish + demo recording + APK build

## Assigned GitHub Issues
- **[#5](https://github.com/Jay-D21/Aarogya-Sathi-Final/issues/5)** — Convert Architecture Docs to 7 Professional Diagrams
- **[#6](https://github.com/Jay-D21/Aarogya-Sathi-Final/issues/6)** — Upgrade Flutter App — SSE + Backend Connection

## What's Done ✅
- Flutter app exists in `frontend/` with 4 working screens (merged from Antigravity)
  - Dashboard: Activity rings, AQI strip, vitals grid, pedometer stream
  - Chat: STT (speech-to-text), message list (currently mock responses)
  - Register: Form UI (not connected to backend)
  - Upload Reports: File picker UI (not connected)

## What's Next 🔜 (Priority Order)
1. **Chat Screen SSE** (HIGH) — Replace mock `_sendMessage()` with real `POST /api/chat` SSE stream
   - Parse `{"token": "word", "done": false}` events, concatenate for streaming effect
   - Use `dio` with `responseType: ResponseType.stream`
   - Send full `ChatRequest` body with profile, location, wearable data
2. **AQI Endpoint Fix** (MEDIUM) — Change `/api/v1/environment/current` → `/api/aqi`
3. **API Config** (MEDIUM) — Create `lib/core/config/api_config.dart` with centralized base URL
4. **Health Profile Screen** (MEDIUM) — New screen for age, conditions, BP, sugar → SharedPreferences
5. **Architecture Diagrams** (PARALLEL) — 7 diagrams using draw.io/Figma
6. **Register Screen** (LOW) — Connect when Abhijit adds auth endpoints

## Weekly Plan (Updated)
| Week | Task | Deliverable |
|------|------|-------------|
| W1-2 | Chat SSE integration + AQI fix | Real AI chat working on phone |
| W3-4 | Health profile screen + API config | Personalized responses |
| W5-6 | Architecture diagrams (7 total) | SVG/PNG for report |
| W7-8 | UI polish + integration testing | Smooth UX |
| W9-10 | Demo recording + APK build | Play Store ready |

## Recent Activity
_No commits yet — issues assigned, awaiting start._

## Files I Own
- `frontend/` (entire Flutter app)
- `frontend/lib/features/chat/` (chat screen + SSE client)
- `frontend/lib/features/dashboard/` (dashboard + AQI)
- `frontend/lib/features/auth/` (registration)
- `frontend/lib/features/reports/` (report upload)
- `frontend/lib/core/` (theme, services, config)
