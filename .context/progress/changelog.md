# Changelog

## 2026-09-12 (Jayesh — Session 6: Complete UI & Feature Restoration)
- [Jayesh] Restored full premium Aarogya Sathi UI & features from original complete codebase
- [Jayesh] Brought over full 4-tab bottom navigation (Home Dashboard, AI Chat, Health Tracking, Profile)
- [Jayesh] Enabled LocationService with auto GPS detection and reverse geocoding to city name for live AQI
- [Jayesh] Restored HealthScoreRing, AnimatedMetricCards, GlassCard, AarogyaLogoDynamic widgets
- [Jayesh] Restored HealthDashboard with interactive Blood Pressure and Blood Sugar charts and vital logging
- [Jayesh] Restored NotificationService for scheduled daily medication/water reminders
- [Jayesh] Connected ChatProvider to deployed Render backend (/api/chat) with SSE streaming + direct Groq fallback + emergency 108 detection
- [Jayesh] Integrated Health Connect & Fitbit wearable model alongside pedometer and local trackers
- [Jayesh] Restored SplashScreen with glowing ring animation, Login/Register with Guest Explore mode, and ProfileSetupScreen
- [Jayesh] Fixed greeting time boundaries to correctly show 'Good night' from 22:00 to 04:59 (e.g. at 00:42)
- [Jayesh] Upgraded AQI loading to use real GPS coordinates with backend /api/aqi and Open-Meteo fallback (resolves small cities like Shirpur-Warwade)
- [Jayesh] Connected Health Connect & Fitbit sync into FitnessProvider and added sync action & pull-to-refresh
- [Jayesh] Added live BPM to HealthScoreRing and included heart rate in dynamic score calculation
- [Jayesh] Clean Flutter build with zero errors, zero warnings

## 2026-09-11 (Jayesh — Session 5: Deployment & CI/CD)
- [Jayesh] Created multi-stage Dockerfile for backend (Python 3.11 slim, copies icmr-knowledge-bundle)
- [Jayesh] Created render.yaml blueprint for one-click Render deployment (Singapore region, free tier)
- [Jayesh] Created `.github/workflows/backend-ci-cd.yml` — lint (Ruff), test (pytest), Docker build + verify, deploy to Render
- [Jayesh] Created `.github/workflows/flutter-ci-cd.yml` — flutter analyze, build release APK, GitHub Releases on version tags
- [Jayesh] Updated `api_config.dart` to support 3 environments (emulator/physical/production)
- [Jayesh] Updated `.gitignore` with Flutter build artifacts and Docker ignores
- [Jayesh] Created `.dockerignore` to keep image lean

## 2026-09-11 (Jayesh — Session 4: Full App Integration)
- [Jayesh] Phase 1: Created centralized API config (`api_config.dart`), fixed AQI endpoint URL from `/api/v1/environment/current` → `/api/aqi`
- [Jayesh] Phase 2: Built real SSE chat — `chat_service.dart` with Dio streaming, `chat_request_model.dart`, rewrote `chat_screen.dart` with Riverpod + streaming tokens + typing indicator
- [Jayesh] Phase 3: Health profile system — `user_profile_model.dart`, `profile_service.dart` (SharedPreferences), `health_profile_screen.dart` with ICMR BP/sugar classifications + BMI calc
- [Jayesh] Phase 4: Health Connect integration — `health_connect_service.dart` reads from Fitbit/Google Fit/Samsung Health via Android Health Connect, `wearable_data_model.dart` matching backend
- [Jayesh] Phase 5: Dashboard shows live Heart Rate, Sleep, SpO2, Calories from Health Connect instead of hardcoded values
- [Jayesh] Phase 6: Chat sends real profile + wearable data + GPS location with every message — AI knows your HR, steps, conditions when answering
- [Jayesh] Phase 7: Removed register screen (no auth for now), replaced with `/profile` route for health profile
- [Jayesh] Phase 8: Fixed backend `context_builder.py` wearable field mismatch, dynamic greeting, Health Connect setup banner
- [Jayesh] Added `health: ^11.0.0` to pubspec, Health Connect permissions to AndroidManifest.xml

## 2026-09-11 (Jayesh — Session 3)
- [Jayesh] OKF bundle expanded 13→34 concept files (21 new: 8 conditions, 6 drugs, 4 lifestyle, 5 emergency, 3 environmental)
- [Jayesh] Rebuilt root index.md to list all 34 files with descriptions (fixed navigator empty response)
- [Jayesh] Expanded keyword fallback from 12→80+ keywords covering all categories
- [Jayesh] Built RAGAS evaluation pipeline: `evaluation/evaluate.py` + 32 gold Q&A pairs in `gold_qa.json`
- [Jayesh] Tested E2E pipeline: correct doc retrieval + medically accurate responses verified

## 2026-09-11 (Jayesh — Session 2)
- [Jayesh] Fixed Groq model names (API changed): openai/gpt-oss-20b + qwen/qwen3.8-27b
- [Jayesh] Merged Flutter app from Aarogya Sathi Antigravity into `frontend/` (11 Dart files, 4 screens)
- [Jayesh] Tested full CRAG pipeline E2E with Groq API key — working
- [Jayesh] Created GitHub issue #6 for Ritesh: Flutter app upgrade (SSE, AQI fix, profile screen)
- [Jayesh] Updated all .context files: contributors (3), architecture, dependencies, modules, changelog

## 2026-09-11 (Jayesh — Session 1)
- [Jayesh] Phase 1: Multi-provider LLM factory (Groq→SambaNova→Cerebras cascade) in `backend/rag/llm.py`
- [Jayesh] Phase 2: OKF Navigator (`backend/rag/okf_navigator.py`) — LLM-driven file traversal with keyword fallback
- [Jayesh] Phase 3: CRAG Grader (`backend/rag/grader.py`) — parallel relevance scoring using 8B model
- [Jayesh] Phase 4: Context Builder (`backend/rag/context_builder.py`) — ICMR system prompt + OKF docs + profile + AQI assembly
- [Jayesh] Phase 5: CRAGPipeline (`backend/rag/pipeline.py`) — main pipeline, wired into Abhijit's routes.py (replaced mock)
- [Jayesh] Phase 6: ICMR utils (`backend/utils/icmr.py`) — Asian-cutoff classifiers for BP, sugar, BMI, AQI
- [Jayesh] Added OKF files: `conditions/asthma.md`, `lifestyle/exercise-guidelines.md`
- [Jayesh] Updated requirements.txt (replaced langchain-ollama→langchain-groq, added langgraph)
- [Jayesh] Created GitHub issue #5 for Ritesh (7 architecture diagrams)

## 2026-09-11 (Abhijit)
- [Abhijit] Phase 1: FastAPI skeleton — main.py, models.py (with WearableData), routes.py
- [Abhijit] Phase 2: Bhashini translation wrapper with mock fallback (API keys pending)
- [Abhijit] Phase 3: Safety router — emergency/prescription/non-medical blocking with keyword fallback
- [Abhijit] Phase 4: AQI (WAQI mock) + Weather (Open-Meteo live) integration
- [Abhijit] Created 11 mock OKF knowledge bundle files for testing
- [Abhijit] Full SSE streaming chat pipeline working end-to-end (mock RAG)
- [Abhijit] All 9 verification tests passing

## 2026-09-08
- [Developer] Project initialized with iLabs context system

_Format: [Developer] What was done (PR #XX)_