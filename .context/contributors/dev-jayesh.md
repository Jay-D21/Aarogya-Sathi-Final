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
- **OKF bundle expanded: 13 → 34 concept files** (11 conditions, 7 drugs, 6 lifestyle, 6 emergency, 4 environmental)
- **Root index rebuilt** to list all files with descriptions (fixed navigator returning 0 docs)
- **Keyword fallback expanded** from 12 → 80+ keywords covering all 34 files
- **RAGAS evaluation pipeline** built: `evaluation/evaluate.py` + 32 gold Q&A pairs
- E2E test passing with real Groq API — correct doc retrieval and medical responses
- GitHub issues #5 (diagrams) and #6 (Flutter upgrade) created for Ritesh

## What's Next 🔜
1. **OKF Bundle to 50+** — Create 16+ more concept files for edge cases
   - Missing conditions: malaria, pneumonia, hepatitis, gastritis, PCOD
   - Missing drugs: losartan, ramipril, omeprazole, cetirizine
   - Missing lifestyle: alcohol-impact, mental-health-basics, women-health
   - Missing environmental: flood-safety, earthquake-preparedness
2. **RAGAS Full Run** — Run all 32 Q&A pairs (need to pace Groq rate limits), expand to 100
3. **Report Writing** — Document architecture, evaluation results, ICMR compliance

## Session Log

### Session 3 — 2026-09-11 (afternoon, continued)
- Created 21 new OKF concept files (conditions: 8, drugs: 6, lifestyle: 4, emergency: 5, environmental: 3)
- Rebuilt root index.md to list all 34 files (fixed navigator returning 0 docs)
- Expanded keyword fallback from 12 → 80+ keywords
- Built RAGAS evaluation pipeline: evaluate.py + 32 gold Q&A pairs
- Tested E2E: diabetes+AQI and BP queries correctly retrieve docs and generate accurate responses
- Updated all context files

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
