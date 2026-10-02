# Changelog
 
## 2026-10-03 (Abhijit — Session 19: Pubspec Dependency Audit & Native Package Pruning)
- [Abhijit] Pruned unused dependencies `speech_to_text: ^7.0.0` and `flutter_tts: ^3.8.3` from `frontend/pubspec.yaml`, removing unused native platform overhead and Windows C++ plugin compilation (`speech_to_text_windows`, `speech_to_text_platform_interface`, `flutter_tts`).
- [Abhijit] Ran `flutter pub get` cleanly updating `frontend/pubspec.lock`.
- [Abhijit] Updated `.context/dependencies/_overview.md` with the full specification of all 19 active frontend packages and historical documentation of removed packages (`dio`, `fl_chart`, `shimmer`, `flutter_riverpod`, `go_router`, `speech_to_text`, `flutter_tts`).
- [Abhijit] Automated Verification: `flutter analyze` reported 0 errors, 0 warnings, 0 infos (`No issues found!`), and all 17 unit and widget tests in `frontend/test/` passed cleanly (`flutter test`).

## 2026-10-03 (Abhijit — Session 18: Edit Profile Screen with Asian ICMR BMI & Conditions Management)
- [Abhijit] Created `EditProfileScreen` (`frontend/lib/screens/profile/edit_profile_screen.dart`): personal info form (First Name, Last Name, Age, Gender dropdown, City with GPS auto-detection via `LocationService.getCityName()`), dynamic Asian ICMR BMI calculation & live classification cards (Normal: 18.5–22.9, Overweight: 23–27.4, Obese: ≥27.5), chronic conditions multi-select filter chips + custom condition addition, and medications list with chip management.
- [Abhijit] Updated `AuthProvider` (`frontend/lib/providers/auth_provider.dart`): extended `updateProfile` with immediate local state sync, local persistence (`guest_profile` or `cached_user_profile`), and backend `PUT /auth/me` with offline resilience; updated `checkAuth` to load `cached_user_profile` during network disconnection.
- [Abhijit] Wired UI Navigation: registered `/edit-profile` in `main.dart`, and embedded accessible "Edit Health Profile" buttons on both the `HomeScreen` profile card and the preferences menu.
- [Abhijit] Wired RAG & Chat Integration: updated `ChatScreen` (`frontend/lib/screens/chat/chat_screen.dart`) to extract conditions, medications, height, and weight from `auth.user` and forward them in `ChatRequest.profile`.
- [Abhijit] Updated Backend Data Model: added `height_cm` and `weight_kg` to `UserProfile` in `backend/api/models.py`, enabling `backend/rag/context_builder.py` to calculate Asian ICMR BMI classification (`BMI: 27.0 → Overweight`) and inject conditions and medications into `<user_profile>` for personalized AI health advice.
- [Abhijit] Automated Verification: created `frontend/test/edit_profile_test.dart` (6/6 tests passed), updated `test/widget_test.dart` with `FileVaultProvider` and proper timer settlement (all 17 frontend tests passing cleanly), and created `scratch/test_profile_backend_wiring.py` validating backend serialization and context builder prompt formatting. `flutter analyze` verified with 0 errors, 0 warnings, and 0 infos.

## 2026-10-03 (Abhijit — Session 17: Medical File Vault Implementation & Testing)
- [Abhijit] Added `image_picker` (1.2.3) and `file_picker` (11.0.3) packages for native camera, photo gallery, and PDF report capture.
- [Abhijit] Created `MedicalFileModel` (`frontend/lib/models/medical_file_model.dart`) supporting DPDP on-device records for prescriptions, lab reports, scans, and vaccinations with file size and date formatting.
- [Abhijit] Built `FileVaultProvider` (`frontend/lib/providers/file_vault_provider.dart`) managing sandbox file persistence (`/medical_vault/`), SharedPreferences metadata indexing, category filtering, search queries, and secure deletion.
- [Abhijit] Built `FileVaultScreen` (`frontend/lib/screens/health/file_vault_screen.dart`) featuring real-time search, category filter chips, upload bottom sheet (camera/gallery/file), file details/image preview dialog, and delete confirmation.
- [Abhijit] Wired `/vault` route in `main.dart`, added settings entry in `HomeScreen`, and integrated an on-device Medical File Vault banner into `HealthDashboard`.
- [Abhijit] Automated Verification: created `frontend/test/file_vault_test.dart` (6/6 tests passed) and re-ran `language_persistence_test.dart` (4/4 passed) with zero regressions; `flutter analyze` verified with 0 errors and 0 warnings.

## 2026-10-02 (Abhijit — Session 16: Language Persistence & Full End-to-End Wiring)
- [Abhijit] Implemented reactive language persistence in `frontend/lib/providers/auth_provider.dart`: `_language` state, `languageLabel`, and `setLanguage(lang)` with `SharedPreferences` persistence (`user_language`) and user session synchronization.
- [Abhijit] Updated `HomeScreen` settings: dynamically bound language subtitle to `context.watch<AuthProvider>().languageLabel` and wired `_showLangSheet` directly to `auth.setLanguage(...)`.
- [Abhijit] Enhanced `ChatScreen`: added an interactive language switcher chip in AppBar (`EN`/`HI`/`MR`) allowing in-chat language switching, and wired `sendMessage` to pass `auth.language`.
- [Abhijit] Enhanced `ChatProvider`: fixed variable scoping for `effectiveLang`, passed `language` parameter to `_callGroqDirectly` with dedicated system prompt guidance for Hindi and Marathi.
- [Abhijit] Automated Verification: authored `frontend/test/language_persistence_test.dart` (4/4 tests passed) and created `scratch/test_language_wiring.py` confirming backend context assembly and localized greeting generation.

## 2026-10-02 (Abhijit — Session 15: Paper Enhancement with Diagrams & Tables)
- [Abhijit] Enhanced `paper/paper.md` from 298 to 710 lines (+687 insertions, +412 net new lines)
- [Abhijit] Added 23 comprehensive tables: NCD burden statistics, RAG comparison, ICMR clinical thresholds, CPCB AQI thresholds, pollutant-health impacts, competitive analysis (7 platforms × 11 features), API specs, Pydantic data models, Health Connect data types, DPDP compliance matrix, module registry, evaluation dataset, safety router results, technology stack decisions, and more
- [Abhijit] Added 5 detailed ASCII architecture diagrams: full system architecture (3-tier), agentic ReAct pipeline workflow (7 phases), data flow/privacy architecture, multi-key LLM pooling with auto-cascade, native vs translation multilingual comparison
- [Abhijit] Added Appendix A (AI/ML Skill Demonstration Matrix — 11 competencies) and Appendix B (Economic Feasibility — zero-cost development stack)
- [Abhijit] Committed and pushed: `f5c974c`

## 2026-10-02 (Abhijit — Session 14: Research Paper Engine Phase 3 & 4)
- [Abhijit] Phase 3 (Literature Search): Searched academic databases for Agentic RAG in Healthcare, Multilingual LLMs, Preventive Health ROI. Created `LITERATURE_DB.md` with 4 HIGH-relevance papers. Generated `Research/academic_literature_review.md` with thematic synthesis and gap analysis.
- [Abhijit] Phase 4 (Structured Writing): Created `paper/outline.md` (section-by-section IMRAD writing plan). Wrote complete `paper/paper.md` — full research paper with Abstract, 8 sections, architecture diagrams, comparative analysis table, and 42 IEEE-formatted references. Applied AI-ism scrubbing (no "leverage", "delve", "robust"). All manuscript sections in flowing prose paragraphs (no bullets).
- [Abhijit] Updated `RESEARCH_CONTEXT.md` to v1.2.0 with new file mappings (paper/, LITERATURE_DB.md) and fresh git baseline.
- [Abhijit] Updated `CHANGE_LOG.md` with Phase 3 and Phase 4 incremental entries per research_paper_engine skill protocol.

## 2026-10-01 (Abhijit — Session 13: Research Validation & Capstone Analysis)
- [Abhijit] Read and analyzed `literature_review.md` and `project_validation.md` from the newly pulled `Research/` directory.
- [Abhijit] Synthesized project claims mapping technical achievements (Agentic RAG, WAQI integration, IndicTrans2) to academic literature and ICMR guidelines.
- [Abhijit] Generated `research_analysis.md` artifact summarizing the 14.3:1 ROI, 43.8% RAG hallucination reduction, DPDP compliance, and competitive gap analysis for capstone presentation.

## 2026-09-30 (Jayesh — Session 12: Complete Agentic RAG Implementation & Integration)
- [Jayesh] Built `backend/rag/intent.py` with regex heuristics fast-path + 70B LLM intent fallback (greeting, health_query, vital_check, aqi_query, lifestyle)
- [Jayesh] Built `backend/rag/insights.py` proactive insights engine (elevated HR, low SpO2, Stage 1/2 BP, CPCB NAQI threshold warnings, and vital delta trends)
- [Jayesh] Built `backend/rag/tools.py` modular tools (`tool_search_knowledge`, `tool_analyze_vitals`, `tool_get_environmental_data`)
- [Jayesh] Built `backend/memory/session.py` per-user session memory manager with disk persistence (`data/sessions/{user_id}.json`)
- [Jayesh] Upgraded `backend/rag/pipeline.py` to Agentic ReAct flow: short-circuits greetings, selects tools by intent, injects proactive insights and longitudinal memory
- [Jayesh] Added `user_id` to `ChatRequest` model and added `/api/session/{user_id}/insights` endpoint to `backend/api/routes.py`
- [Jayesh] Updated Flutter `chat_provider.dart` to automatically send `user_id` and load saved `user_language`
- [Jayesh] Fixed language sheet in `home_screen.dart` with persistent `SharedPreferences` storage and active radio indicators
- [Jayesh] Wired DPDP compliance info dialogs to previously empty 'Privacy Settings' and 'Terms' tiles in `home_screen.dart`
- [Jayesh] Removed dead dependencies (`dio`, `fl_chart`, `shimmer`) from `frontend/pubspec.yaml`
- [Jayesh] Ran integration test confirming intent classification, proactive insights generation, and session persistence

## 2026-09-30 (Jayesh — Session 11: Multi-Key Pooling, Native Hinglish, Context Polishing & Agentic Roadmap)
- [Jayesh] Implemented comma-separated multi-key pooling with round-robin rotation & auto-429 rotation across Groq and Sarvam AI (`llm.py`, `bhashini.py`)
- [Jayesh] Configured Render production environment variables and switched Flutter app `api_config.dart` from emulator to production URL
- [Jayesh] Bypassed Sarvam translation during chat by prompting Qwen 27B to natively understand and reply in Hindi/Marathi/Hinglish/Minglish (saving 100% of credits)
- [Jayesh] Enforced conversational brevity in `context_builder.py` (2-3 sentences for greetings, max 4-5 bullet points, 400 token ceiling, caring companion tone)
- [Jayesh] Disambiguated nearest WAQI monitoring station name from the user's actual GPS city in LLM prompt
- [Jayesh] Conducted comprehensive Flutter frontend and FastAPI backend feature audits
- [Jayesh] Formulated the Agentic RAG ReAct architecture plan and updated team sprint assignments in `HANDOFF.md`

## 2026-09-27 (Jayesh — Session 10: Audit + Cleanup + Honest README)
- [Jayesh] Full project state audit — discovered 0 commits from team since Sep 21
- [Jayesh] Rewrote README.md to match reality (removed false claims: Ollama, Qdrant, BGE-M3, LangChain, Bhashini, RAGAS)
- [Jayesh] Cleaned requirements.txt — removed 6 unused deps (langchain, langchain-groq, langchain-community, langgraph, pyyaml, ragas)
- [Jayesh] Fixed backend/.env — replaced stale Bhashini vars with SARVAM_API_KEY that code actually reads
- [Jayesh] Noted: Groq key still not rotated (same key from before the leak in git history)

## 2026-09-22 (Abhijit — Session 10: Demo Fallbacks + .env Fix)
- [Abhijit] Added 5 ICMR-based demo fallback responses in chat_provider.dart (diabetes, BP, fever, AQI, diet)
- [Abhijit] Added synonym matching (sugar/glucose→diabetes, bp/hypertension→BP, pollution/smog→AQI, etc.)
- [Abhijit] Fallback chain is now: Backend SSE → Groq Direct → Demo Fallbacks → Generic Error
- [Abhijit] Rewrote backend/.env to match new .env.example (Groq/SambaNova/Cerebras/Sarvam placeholders)
- [Abhijit] Preserved live WAQI_API_TOKEN in .env
- [Abhijit] Switched api_config.dart to emulator mode for local-first testing

## 2026-09-21 (Jayesh — Session 9: Sarvam AI + Evaluation + AQI Cleanup)
- [Jayesh] Replaced Bhashini translation with Sarvam AI (mayura:v1, Hindi+Marathi+English, ₹100 free credits)
- [Jayesh] Fixed evaluation pipeline: honest "LLM-as-Judge" docstring, retrieved context passed to judge, robust JSON parsing, removed survivorship bias filter
- [Jayesh] Added hypertension→drug cross-links (Atenolol, Amlodipine) in knowledge bundle
- [Jayesh] Cleaned up AQI module with proper _USE_MOCK env var fallback pattern
- [Jayesh] Updated .env.example: removed Bhashini vars, added SARVAM_API_KEY
- [Jayesh] Created HANDOFF.md with task assignments for Abhijit + Ritesh

## 2026-09-20 (Jayesh — Session 8: Brutal Audit + Context Wiring)
- [Jayesh] Ran LLM Council (5 advisors + peer review + chairman) to validate fix plan
- [Jayesh] Removed leaked Groq API key from chat_provider.dart (security fix)
- [Jayesh] Removed real API key from .env.example (security fix)
- [Jayesh] Fixed temp→temperature key mismatch between weather.py and context_builder.py
- [Jayesh] Fixed broken cross-link: pollution-respiratory.md → aqi-health-impact.md
- [Jayesh] Deleted dead _mock_pipeline() code (40+ lines) from routes.py
- [Jayesh] Fixed lying "740-line prompt" comment → honest "21-line"
- [Jayesh] CRITICAL: Wired profile + wearable + location + chat_history from Flutter to backend
- [Jayesh] Added chat_history field to ChatRequest Pydantic model
- [Jayesh] Propagated chat_history through pipeline → context_builder → LLM prompt
- [Jayesh] Updated chat_screen.dart to pull from AuthProvider/HealthProvider/FitnessProvider
- [Jayesh] Built last-5-messages chat history in chat_provider.dart

## 2026-09-15 (Jayesh — Session 7: Health Connect & Google Fit Sync Precision + Indian CPCB NAQI Air Quality Engine)
- [Jayesh] Upgraded MainActivity.kt to FlutterFragmentActivity for Android 14+ Health Connect registerForActivityResult support
- [Jayesh] Added Health Connect permissions (READ_RESTING_HEART_RATE, READ_TOTAL_CALORIES_BURNED, READ_DISTANCE) and rationale intent filter to AndroidManifest.xml
- [Jayesh] Eliminated double calorie accumulation bug in health_connect_service.dart (separated active vs total calories, matching Google Fit's 738 kcal)
- [Jayesh] Widened Health Connect historical window to 36 hours for seamless retrieval of previous evening/night heart rate, SpO2, and sleep records
- [Jayesh] Fixed pedometer clobbering bug in fitness_provider.dart: verified Health Connect data is protected from uncalibrated accelerometer noise
- [Jayesh] Enhanced LocationService reverse-geocoding to prioritize subAdministrativeArea (Taluka/City e.g. Shirpur) over rural census sub-localities (Babulde)
- [Jayesh] Implemented official Indian National Air Quality Index (CPCB NAQI) calculation with direct Open-Meteo coordinates fallback
- [Jayesh] Added interactive AQI detail bottom sheet with PM2.5/PM10 pollutant breakdown, GPS refresh, and city chips
- [Jayesh] Verified 0 flutter analyze errors and confirmed clean Android assembleDebug APK build

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