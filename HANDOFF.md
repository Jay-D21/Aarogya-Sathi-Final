# 🚀 Aarogya Sathi — Complete Team Task Handoff & Sprint Roadmap

**Date**: September 30, 2026  
**Repository**: https://github.com/Jay-D21/Aarogya-Sathi-Final  
**Guide**: Dr. Atul V. Dusane | **Department**: IT/AIML, MPSTME, SVKM's NMIMS Shirpur Campus  
**Project Goal**: Build an Agentic Personal Health Assistant adhering to ICMR AI in Biomedical Research and Healthcare Guidelines (2023) and DPDP Act compliance.

---

## 📌 Current Project Status (As of September 30, 2026)

All the following core foundational components are **COMMITTED and VERIFIED LIVE on `main`**:
1. **Live Production Deployment**: FastAPI backend running on Render (`https://aarogya-sathi-final.onrender.com`).
2. **Multi-Key LLM & Translation Rotation**:
   - 3 Groq API keys pooled for 3x rate limit throughput (round-robin + auto 429 failover).
   - 7 Sarvam AI API keys pooled for translation redundancy.
3. **Native Multilingual & Hinglish/Minglish Support**:
   - The Qwen 27B model natively understands mixed language queries (`"mujhe sugar hai"`, `"mala BP cha problem aahe"`).
   - Directly responds in Hindi/Marathi/English without wasteful translation roundtrips, saving 100% of Sarvam credits during chat.
4. **Conversational Style & Brevity Rules**:
   - Max 400 token ceiling, friendly and warm companion tone, simple bullet points, no textbook essays.
   - Clean location handling (distinguishes user location from nearest WAQI air monitoring station).
5. **Real Wearable & Context Injection**:
   - Health Connect (Fitbit/Google Fit) live sync for steps, HR, SpO2, sleep, and BP.
   - Profile vitals, live AQI (WAQI), weather (Open-Meteo), and last 5 turns of conversation memory wired end-to-end to LLM prompt.
6. **Robust Safety Layer**:
   - Semantic Router with 42 multilingual utterances (emergency, prescription, non-medical) + 108 dialing shortcut.
7. **Empirical Evaluation**:
   - 32 gold-standard QA benchmark in `evaluation/gold_qa.json`, real LLM-as-judge score: **4.60 / 5.00**.

---

## 👥 Task Assignments by Team Member

---

### 🔵 Jayesh Patil (Lead — AI/ML, Agentic RAG & Backend)
**Roll No:** C233  
**Focus:** Agentic pipeline, per-user memory, proactive insights, and evaluation benchmark.

#### Task J1: Build Intent Classifier (`backend/rag/intent.py`)
- **Objective:** Classify queries before running heavy RAG to save latency and LLM credits.
- **Specification:**
  - Create `classify_intent(query: str) -> str` using the fast 8B model.
  - Intents: `greeting`, `health_query`, `vital_check`, `aqi_query`, `lifestyle`, `followup`, `file_request`.
  - For `greeting`, bypass OKF search and grading entirely and generate an immediate friendly response.
- **Files:** Create `backend/rag/intent.py`.

#### Task J2: Implement Agentic ReAct Pipeline (`backend/rag/pipeline.py` & `backend/rag/tools.py`)
- **Objective:** Upgrade from a fixed linear pipeline to an agent that decides which tools to call.
- **Specification:**
  - Define reusable tools in `backend/rag/tools.py`:
    1. `search_knowledge(query)`: Searches OKF bundle.
    2. `analyze_vitals(wearable_dict)`: Evaluates heart rate, SpO2, sleep, and steps against ICMR/WHO benchmarks.
    3. `get_environmental_context(lat, lon)`: Fetches live AQI and temperature.
    4. `get_user_profile()`: Reads chronic conditions and medications.
  - Implement a concise ReAct loop (max 2–3 iterations) in `CRAGPipeline.run()`.
- **Files:** `backend/rag/tools.py`, `backend/rag/pipeline.py`.

#### Task J3: Implement Per-User Session Memory (`backend/memory/session.py`)
- **Objective:** Enable personalized multi-session memory without requiring an expensive external Redis cluster.
- **Specification:**
  - Create a lightweight `SessionManager` class with in-memory cache and local JSON file persistence.
  - Track: `user_id`, `profile`, `vital_history` (last 10 readings), `chat_summary` (compressed summary of past conversations), `preferences`.
  - Update `backend/api/models.py` to add `user_id: str | None = None` to `ChatRequest`.
- **Files:** Create `backend/memory/session.py`, edit `backend/api/models.py`, `backend/api/routes.py`.

#### Task J4: Run Full 32-Query Evaluation & Document Scores
- **Objective:** Evaluate the upgraded agentic pipeline across all 32 gold-standard cases.
- **Command:**
  ```bash
  python -m evaluation.evaluate --qa-file evaluation/gold_qa.json --output evaluation/results.json
  ```
- **Deliverable:** Update `evaluation/results.json` and prepare the evaluation comparison table for the capstone report.

---

### 🟢 Abhijit Patil (Frontend Lead & User Features)
**Roll No:** C263  
**Focus:** Medical file vault, persistent language selector, post-onboarding profile editing, and UI integration.

#### Task A1: Fix Language Selector Persistence (Urgent — 2 Hours)
- **Problem:** Currently, selecting Hindi or Marathi in `_showLangSheet` pops the modal without saving the locale.
- **Specification:**
  - In `frontend/lib/screens/home/home_screen.dart` (`_showLangSheet`, lines 1152–1181), save the selected language code (`'en'`, `'hi'`, `'mr'`) to `SharedPreferences` under key `'user_language'`.
  - In `frontend/lib/providers/chat_provider.dart`, read the saved `'user_language'` from `SharedPreferences` and send it as `'language'` in `ChatRequest`.
  - Display the currently selected language in the Profile tab preferences list.

#### Task A2: Build Medical File Vault Screen (2–3 Days)
- **Objective:** Give users a secure, on-device vault to store prescriptions, lab reports, and doctor notes.
- **Specification:**
  - Create `frontend/lib/screens/health/file_vault_screen.dart`.
  - Use `image_picker` (camera/gallery) and `file_picker` (PDFs).
  - Store files locally on the device using `path_provider` in an app-private directory (DPDP Act compliance: no unencrypted cloud uploads).
  - Save file metadata (filename, category: `Prescription` / `Lab Report` / `Discharge Summary`, date, file path) in local SQLite or SharedPreferences JSON.
  - Provide a clean thumbnail grid with tap-to-view and swipe-to-delete.
- **Files:**
  - Create `frontend/lib/screens/health/file_vault_screen.dart`
  - Create `frontend/lib/models/medical_file_model.dart`
  - Add navigation entry in `home_screen.dart` under Health Quick Actions.

#### Task A3: Add "Edit Profile" Screen (3 Hours)
- **Problem:** Users can currently only set age, weight, and height during onboarding; there is no way to update vitals later.
- **Specification:**
  - Create an Edit Profile modal or screen allowing users to edit Age, Gender, Height, Weight, City, and Known Conditions.
  - Update `AuthProvider.updateProfile(...)` to persist changes both in local `SharedPreferences` and notify all listening screens.

#### Task A4: Clean Up Dead Dependencies
- **Task:** In `frontend/pubspec.yaml`, remove declared but unused packages: `dio`, `fl_chart`, `shimmer`. Run `flutter pub get`.

---

### 🟡 Ritesh Pawar (Mobile Systems, Sensors & Proactive Engine)
**Roll No:** C276  
**Focus:** Proactive background notifications, Health Dashboard wearable cards, voice I/O, and architectural diagrams.

#### Task R1: Implement Proactive Health & AQI Alerts (2 Days)
- **Objective:** Make Aarogya Sathi a *proactive* health companion rather than a passive chatbot.
- **Specification:**
  - Create `frontend/lib/services/background_health_check.dart` using `workmanager` or periodic timer:
    1. **AQI Alert:** When local AQI exceeds 200 (Poor/Severe), trigger a local notification via `NotificationService`:
       `"⚠️ Poor Air Quality Alert: AQI is {value}. Sensitive groups and cardiac patients should avoid outdoor exertion."`
    2. **Vital Anomaly Alert:** If Health Connect sync reveals resting HR > 100 bpm or SpO2 < 94%, trigger an alert:
       `"⚠️ Vital Check: Your SpO2 reading was {value}%. Rest and consult a healthcare provider if breathless."`
    3. **Daily Morning Briefing:** Trigger at 08:00 AM daily with steps target, sleep duration from previous night, and local AQI.

#### Task R2: Wire Wearable Metrics to Health Dashboard Tab (3 Hours)
- **Problem:** Wearable metrics (steps, HR, SpO2, sleep) currently appear only on the Home Dashboard tab, while the Health Tracking tab (`HealthDashboard`) only shows manual logs.
- **Specification:**
  - In `frontend/lib/screens/health/health_dashboard.dart`, inject cards for Wearable Heart Rate, SpO2, and Sleep from `FitnessProvider` right above the manual logs section so the user has a single unified health cockpit.

#### Task R3: Wire Voice Input/Output (STT & TTS) (4 Hours)
- **Problem:** The microphone icon in the chat screen opens a modal saying "Voice input coming soon."
- **Specification:**
  - Connect `speech_to_text` (already in `pubspec.yaml`) to transcribe voice in English and Hindi directly into the message text field.
  - Connect `flutter_tts` to optionally read AI answers aloud when the user taps a speaker icon on the message bubble.

#### Task R4: Complete 7 Architecture Diagrams for Capstone Submission
- **Deliverables:**
  1. System Architecture Overview (Mobile + FastAPI + OKF + LLM Cascade)
  2. Agentic ReAct State Machine Loop
  3. Context Assembly & DPDP Privacy Boundary
  4. Google Health Connect & Hardware Sensor Ingestion Flow
  5. Multi-Key Round-Robin & Provider Failover Flowchart
  6. Semantic Router Guardrail & 108 Emergency Trigger Flow
  7. CPCB National Air Quality Index (NAQI) Calculation Pipeline
- **Target format:** Export high-resolution PNGs and SVGs into `docs/diagrams/`.

#### Task R5: Record 5-Minute Final Demo Video
- **Deliverable:** Record high-quality screen capture with voiceover demonstrating:
  1. Splash & Profile Setup.
  2. Live Health Connect Fitbit/Google Fit sync.
  3. Asking health questions in English and Hinglish.
  4. Prompt safety interception (e.g., asking for prescription or emergency chest pain).
  5. Medical file vault and medication reminder trigger.
  - Save file to `docs/demo_backup.mp4`.

---

## 📅 Sprint Schedule & Milestones

| Timeline | Milestone | Key Deliverables |
|:---|:---|:---|
| **Oct 1 – Oct 4 (Days 1–4)** | **Foundation & Fixes** | Language selector fixed, dead deps removed, intent classifier & session memory implemented, Health Dashboard wearable cards wired. |
| **Oct 5 – Oct 8 (Days 5–8)** | **Core Features** | Medical File Vault completed, Proactive background notifications live, Agentic ReAct pipeline operational. |
| **Oct 9 – Oct 12 (Days 9–12)** | **Refinement & Testing** | Voice STT/TTS wired, 32-query evaluation run, Edit Profile screen functional, 7 architecture diagrams completed. |
| **Oct 13 – Oct 15 (Days 13–15)**| **Code Freeze & Final Demo** | Comprehensive dry runs, demo video recorded (`demo_backup.mp4`), documentation finalized for final examination. |

---

## 🛠️ Testing & Verification Commands

1. **Test Backend Locally**:
   ```bash
   cd backend
   python -m uvicorn backend.main:app --reload --port 8000
   ```

2. **Verify Multi-Key LLM Pool**:
   ```bash
   python -c "from backend.rag.llm import _init_key_pools, _key_pools; _init_key_pools(); print(_key_pools)"
   ```

3. **Run Full Evaluation Benchmark**:
   ```bash
   python -m evaluation.evaluate --qa-file evaluation/gold_qa.json --output evaluation/results.json
   ```

4. **Run Flutter App on Device**:
   ```bash
   cd frontend
   flutter run --dart-define=GROQ_API_KEY=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
   ```
