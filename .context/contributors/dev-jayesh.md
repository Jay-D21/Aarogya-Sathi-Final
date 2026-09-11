# Jayesh Patil — Contributor Context

## Current Assignment
- **Modules**: OKF Knowledge Bundle, RAG Pipeline, Evaluation
- **Branch**: main
- **Task**: Expand OKF bundle (50+ files) + Build RAGAS evaluation
- **Started**: 2026-09-08

## Responsibilities
1. ~~Convert ICMR guidelines → OKF Markdown bundle (50+ concept files)~~ — 13 done, 37+ remaining
2. ~~Build OKF Navigator agent~~ ✅ `backend/rag/okf_navigator.py`
3. ~~Implement CRAG pipeline~~ ✅ `backend/rag/pipeline.py`
4. ~~Set up multi-provider LLM cascade~~ ✅ `backend/rag/llm.py`
5. Build RAGAS evaluation pipeline — NOT STARTED
6. Create 100 gold-standard test questions — NOT STARTED

## What's Done ✅
- Complete CRAG pipeline: OKF Navigate → CRAG Grade → Context Build → Generate
- Multi-provider LLM: Groq (openai/gpt-oss-20b + qwen/qwen3.8-27b) → SambaNova → Cerebras
- ICMR utils with Asian cutoffs (BP, sugar, BMI, AQI)
- Pipeline wired into Abhijit's routes.py — real AI responses via SSE
- Flutter app merged from Antigravity into `frontend/`
- E2E test passing with Groq API key
- GitHub issues #5 (diagrams) and #6 (Flutter upgrade) created for Ritesh

## What's Next 🔜
1. **OKF Bundle Expansion** — Create 37+ more concept files (target 50+)
   - Use MarkItDown on ICMR PDF for auto-extraction as starting point
   - Missing: COPD, obesity, thyroid, anemia, CKD, coronary artery disease
   - Missing drugs: amlodipine, atenolol, insulin, glimepiride, aspirin
   - Missing emergency: chest-pain, stroke-signs, severe-allergic-reaction
2. **RAGAS Evaluation Pipeline** — `evaluation/` module
   - Create 100 gold Q&A pairs (20 per category: conditions, drugs, lifestyle, emergency, env)
   - Build RAGAS evaluator script using Gemini API as judge
   - Metrics: faithfulness, answer relevancy, context precision, context recall
3. **LLM Model Updates** — Groq model roster changes frequently; monitor and update

## Session Log

### Session 2 — 2026-09-11 (afternoon)
- Fixed Groq models (old llama models gone → openai/gpt-oss-20b + qwen/qwen3.8-27b)
- Merged Flutter app from Aarogya Sathi Antigravity into `frontend/`
- Tested full CRAG pipeline E2E with real Groq API — working
- Created GitHub issue #6 for Ritesh (Flutter upgrade: SSE, AQI fix, profile screen)

### Session 1 — 2026-09-11 (morning)
- Built complete CRAG pipeline (6 phases, 8 new files)
- Created `backend/rag/llm.py`, `okf_navigator.py`, `grader.py`, `context_builder.py`, `pipeline.py`
- Created `backend/utils/icmr.py` — ICMR threshold classifiers
- Wired real CRAGPipeline into Abhijit's `routes.py` (replaced mock)
- Updated requirements.txt, .env.example
- Added OKF files: asthma.md, exercise-guidelines.md
- Created GitHub issue #5 for Ritesh (architecture diagrams)

## Files I Own
- `icmr-knowledge-bundle/` (entire OKF bundle)
- `backend/rag/` (all RAG pipeline code)
- `backend/utils/icmr.py`
- `evaluation/` (RAGAS pipeline — to be built)
