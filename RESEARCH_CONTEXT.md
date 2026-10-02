# Research Project Context: Aarogya Sathi

**Version**: 1.1.0
**Last Full Scan**: 2026-10-02
**Last Incremental Update**: 2026-10-02
**Context Head**: f4cb0b0d5f5abf589b90f84d62f99036908033b7

## §1. Project Identity
- **Name**: Aarogya Sathi — AI-powered Digital Health Assistant
- **Type**: RESEARCH_PROTOTYPE, SOFTWARE, AI/ML
- **Primary Languages**: Python (Backend), Dart (Frontend)
- **Frameworks**: FastAPI, Flutter, Agentic RAG (ReAct)
- **Key Contributors**: Jayesh Patil (RAG & LLM Pipeline), Abhijit Patil (Backend, API Docs & Research), Ritesh Pawar (Frontend & Mobile)
- **Institution**: Dept IT/AIML, MPSTME, SVKM's NMIMS Shirpur

## §2. Problem Statement & Motivation
- **Problem**: Lack of localized, context-aware, and clinically safe digital health assistants for the Indian demographic.
- **Goal**: Build a digital health assistant compliant with ICMR clinical guidelines, capable of providing multilingual (Hindi, Marathi, English) and environment-aware (AQI, weather) advice safely.
- **Ethical & Economic Foundation**: Preventive digital health interventions demonstrate a 14.3:1 ROI. Adheres to ICMR's "Ethical Guidelines for Application of AI in Biomedical Research and Healthcare".

## §3. Technical Approach (C4 Context & Innovation)
- **Architecture**: Flutter Android App → FastAPI (SSE Streaming) → Agentic ReAct Pipeline → Groq Cloud API LLMs.
- **Primary Retrieval Mechanism**: OKF (Open Knowledge Format) Navigator operating on structured ICMR knowledge bundle markdown files.
- **Agentic RAG (ReAct)**: Uses Intent classification to short-circuit to tools (`tool_search_knowledge`, `tool_analyze_vitals`, `tool_get_environmental_data`), injects proactive insights, and maintains local JSON session memory.
- **Safety Framework**: Employs Semantic Router + HuggingFaceEncoder (all-MiniLM-L6-v2) to block emergency, prescription, and non-medical queries. Validated by research showing RAG provides factual guardrails that improve clinical accuracy by 43.8% over standalone medical LLMs (MMed-RAG).
- **Multilingual Support**: Native Hinglish/Marathi response generation via Qwen, with Sarvam AI multi-key pooling for fallback translation.
- **Environmental Context**: Correlates hyper-local air quality (WAQI API) with respiratory and cardiovascular health to provide proactive alerts.

## §4. System Architecture (C4 Component)
- **Frontend App**: Built in Flutter, uses Health Connect SDK to pull wearable data (Steps, HR, SpO2, Sleep, Glucose, BP). Includes ICMR demo fallbacks and persistent language settings.
- **Backend API**: FastAPI running async SSE streaming. Includes endpoints for chat (`/api/chat`), AQI (`/api/aqi`), and real-time proactive insights (`/api/session/{user_id}/insights`).
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
- **Compliance**: DPDP-compliant via on-device processing and retrieval-only backend.

## §6. Limitations & Future Work
- Hardcoded fallback thresholds.
- Requires online connectivity for LLM inference.
- Further clinical validation required beyond the 32 QA pairs.

## §7. Related Work Hooks (For Literature Search)
- **Keywords**: Agentic RAG, ReAct Framework, LLM in Healthcare, Multilingual Health Assistants, ICMR Guidelines AI, Semantic Router safety, Health Connect Integration, Preventive Health ROI.
- **Fields**: Medical Informatics, Applied Machine Learning, Natural Language Processing in Indian Languages.

## §8. File-to-Research Mapping
- `backend/rag/pipeline.py` -> §3 Technical Approach
- `backend/rag/tools.py`, `backend/memory/session.py` -> §4 System Architecture
- `backend/safety/` -> §3 Safety Framework
- `Research/` -> §2 & §3 Clinical Validation
- `evaluation/` -> §5 Evaluation
- `icmr-knowledge-bundle/` -> §3 Primary Retrieval

## §9. Git Baseline
- **HEAD at scan**: `f4cb0b0d5f5abf589b90f84d62f99036908033b7`
