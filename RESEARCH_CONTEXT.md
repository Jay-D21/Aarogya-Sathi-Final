# Research Project Context: Aarogya Sathi

**Version**: 1.3.0
**Last Full Scan**: 2026-10-02
**Last Incremental Update**: 2026-10-03
**Context Head**: 355ef4b396e95c1a7a4bf0049ceba030438cf11d

## §1. Project Identity
- **Name**: Aarogya Sathi — AI-powered Digital Health Assistant
- **Type**: RESEARCH_PROTOTYPE, SOFTWARE, AI/ML
- **Primary Languages**: Python (Backend), Dart (Frontend)
- **Frameworks**: FastAPI, Flutter, Agentic RAG (ReAct)
- **Key Contributors**: Jayesh Patil (RAG & LLM Pipeline), Abhijit Patil (Backend, API Docs, Research & Frontend Vault/Profile/Lang), Ritesh Pawar (Frontend & Mobile)
- **Institution**: Dept IT/AIML, MPSTME, SVKM's NMIMS Shirpur

## §2. Problem Statement & Motivation
- **Problem**: Lack of localized, context-aware, and clinically safe digital health assistants for the Indian demographic.
- **Goal**: Build a digital health assistant compliant with ICMR clinical guidelines, capable of providing multilingual (Hindi, Marathi, English) and environment-aware (AQI, weather) advice safely.
- **Ethical & Economic Foundation**: Preventive digital health interventions demonstrate a 14.3:1 ROI. Adheres to ICMR's "Ethical Guidelines for Application of AI in Biomedical Research and Healthcare" and DPDP Act 2023 principles (on-device vault storage, zero biometric cloud persistence).

## §3. Technical Approach (C4 Context & Innovation)
- **Architecture**: Flutter Android App → FastAPI (SSE Streaming) → Agentic ReAct Pipeline → Groq Cloud API LLMs.
- **Primary Retrieval Mechanism**: OKF (Open Knowledge Format) Navigator operating on structured ICMR knowledge bundle markdown files.
- **Agentic RAG (ReAct)**: Uses Intent classification to short-circuit to tools (`tool_search_knowledge`, `tool_analyze_vitals`, `tool_get_environmental_data`), injects proactive insights, and maintains local JSON session memory.
- **Safety Framework**: Employs Semantic Router + HuggingFaceEncoder (all-MiniLM-L6-v2) to block emergency, prescription, and non-medical queries. Validated by research showing RAG provides factual guardrails that improve clinical accuracy by 43.8% over standalone medical LLMs (MMed-RAG).
- **Multilingual Support**: Native Hinglish/Marathi response generation via Qwen, with Sarvam AI multi-key pooling for fallback translation. In-chat AppBar switcher allows real-time toggle between English, Hindi, and Marathi with instant SharedPreferences persistence.
- **Environmental Context**: Correlates hyper-local air quality (WAQI API) with respiratory and cardiovascular health to provide proactive alerts.
- **DPDP On-Device Medical Vault**: Encrypted sandboxed on-device directory storage (`/medical_vault/`) for prescriptions, lab reports, scans, and vaccinations via `image_picker` and `file_picker`, ensuring zero cloud transmission of sensitive health records.
- **Asian ICMR BMI Engine & Profile**: Dynamic BMI calculation with Asian/ICMR cutoffs (Normal: 18.5–22.9, Overweight: 23–27.4, Obese: ≥27.5 kg/m²). Chronic conditions and medications are synchronized directly to the RAG context `<user_profile>`.

## §4. System Architecture (C4 Component)
- **Frontend App**: Built in Flutter, uses Health Connect SDK to pull wearable data (Steps, HR, SpO2, Sleep, Glucose, BP). 
  - `FileVaultProvider` & `MedicalFileModel`: Local document storage, category filtering, search, and secure deletion.
  - `EditProfileScreen`: Dynamic personal info, Asian ICMR BMI calculation, chronic conditions and medications management, and GPS city detection.
  - `AuthProvider`: Reactive language selection, offline caching (`cached_user_profile`), and backend `PUT /auth/me` sync.
  - `ChatScreen`: Streaming SSE client, in-chat language chip switcher, and aggregated condition/medication forwarding.
  - Pruned Dependency Tree: 19 core active packages, zero dead dependencies.
- **Backend API**: FastAPI running async SSE streaming. Includes endpoints for chat (`/api/chat`), AQI (`/api/aqi`), and real-time proactive insights (`/api/session/{user_id}/insights`).
  - `models.py`: Updated `UserProfile` with `height_cm` and `weight_kg` supporting automated BMI classification in `context_builder.py`.
- **Context Engines**: 
  - *Environmental*: Real WAQI token + Open-Meteo.
  - *Translation*: Sarvam API wrapper (multi-key pooling).
- **LLM Pipeline (Agentic RAG Engine)**:
  - `llm.py`: Connects to Groq (`qwen/qwen3.8-27b`) with fallback to SambaNova/Cerebras (multi-key pooling).
  - `intent.py`: Heuristics + LLM intent fallback.
  - `insights.py`: Proactive insights engine.
  - `tools.py`: Modular tools.
  - `session.py`: Per-user memory persistence.
  - `pipeline.py`: Orchestrates the Agentic ReAct flow.

## §5. Evaluation & Results
- **Methodology**: LLM-as-Judge approach using `openai/gpt-oss-20b`.
- **Dataset**: 32 Gold Standard QA pairs.
- **Metrics Evaluated**: Faithfulness, Relevancy, Completeness, Safety.
- **Automated Verification**:
  - Full Flutter test suite: 17/17 unit and widget tests passing (100% pass rate).
  - Static analysis: `flutter analyze` with 0 errors, 0 warnings, 0 infos (`No issues found!`).
  - Backend integration tests: `test_profile_backend_wiring.py` confirming Pydantic serialization, context builder BMI classification, and proactive insights under high AQI.
- **Compliance**: DPDP-compliant via on-device processing and retrieval-only backend.

## §6. Limitations & Future Work
- Hardcoded fallback thresholds.
- Requires online connectivity for LLM inference.
- Further clinical validation required beyond the 32 QA pairs.
- Full local speech-to-text / text-to-speech integration pending for future hands-free accessibility.

## §7. Related Work Hooks (For Literature Search)
- **Keywords**: Agentic RAG, ReAct Framework, LLM in Healthcare, Multilingual Health Assistants, ICMR Guidelines AI, Semantic Router safety, Health Connect Integration, Preventive Health ROI, DPDP On-Device Vault.
- **Fields**: Medical Informatics, Applied Machine Learning, Natural Language Processing in Indian Languages.

## §8. File-to-Research Mapping
- `backend/rag/pipeline.py` -> §3 Technical Approach
- `backend/rag/tools.py`, `backend/memory/session.py` -> §4 System Architecture
- `backend/safety/` -> §3 Safety Framework
- `frontend/lib/models/medical_file_model.dart`, `frontend/lib/providers/file_vault_provider.dart` -> §3 DPDP On-Device Medical Vault
- `frontend/lib/screens/profile/edit_profile_screen.dart` -> §3 Asian ICMR BMI Engine & Profile
- `frontend/test/` -> §5 Automated Verification
- `Research/` -> §2 & §3 Clinical Validation
- `paper/paper.md` -> Full IMRAD Research Paper (710 lines, 23 tables, 5 ASCII architecture diagrams)
- `paper/outline.md` -> Phase 4 Writing Plan
- `LITERATURE_DB.md` -> Phase 3 Literature Database
- `evaluation/` -> §5 Evaluation
- `icmr-knowledge-bundle/` -> §3 Primary Retrieval

## §9. Git Baseline
- **HEAD at scan**: `355ef4b396e95c1a7a4bf0049ceba030438cf11d`

## §10. Contributor Activity Map
| Contributor | Files Owned | Last Active | Key Contributions |
|:---|:---|:---|:---|
| Abhijit Patil | `frontend/lib/models/`, `frontend/lib/providers/file_vault_provider.dart`, `frontend/lib/screens/profile/`, `frontend/lib/screens/health/file_vault_screen.dart`, `frontend/lib/screens/home/`, `frontend/test/`, `paper/paper.md` | 2026-10-03 | Medical File Vault, Edit Profile with Asian ICMR BMI, Language Persistence, Pubspec cleanup, Paper enhancement |
| Jayesh Patil | `backend/rag/`, `backend/memory/`, `backend/context/`, `backend/llm.py` | 2026-09-30 | Agentic RAG ReAct pipeline, intent routing, proactive insights, session persistence |
| Ritesh Pawar | `frontend/lib/screens/`, `frontend/lib/providers/fitness_provider.dart` | 2026-09-30 | Health Connect wearable sync, Dashboard UI, Step sensor tracking |
