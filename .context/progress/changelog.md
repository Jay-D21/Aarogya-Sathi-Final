# Changelog

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