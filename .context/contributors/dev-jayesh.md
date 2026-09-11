# Jayesh Patil — Contributor Context

## Current Assignment
- **Modules**: OKF Knowledge Bundle, RAG Pipeline, Evaluation
- **Branch**: main
- **Task**: Build OKF bundle + CRAG pipeline
- **Started**: 2026-09-08

## Responsibilities
1. Convert ICMR guidelines → OKF Markdown bundle (50+ concept files)
2. Build OKF Navigator agent (Python class that reads/traverses files)
3. Implement CRAG pipeline (LangGraph state machine)
4. Set up multi-provider LLM cascade (Groq → SambaNova → Cerebras)
5. Build RAGAS evaluation pipeline
6. Create 100 gold-standard test questions

## Weekly Plan
| Week | Task | Deliverable |
|------|------|-------------|
| W1-2 | ICMR PDFs → OKF Markdown bundle | 50+ concept files in Git |
| W3-4 | OKF Navigator + CRAG pipeline | Working query → response |
| W5-6 | Integration with Abhijit's backend | Full pipeline E2E |
| W7-8 | RAGAS evaluation + 100 test questions | Evaluation report |
| W9-10 | Polish, edge cases, final demo | Submission-ready |

## Session: 2026-09-11
- Built complete CRAG pipeline: OKF Navigator → Grader → Context Builder → 70B Generation
- Created `backend/rag/llm.py` — multi-provider cascade (Groq → SambaNova → Cerebras)
- Created `backend/rag/okf_navigator.py` — LLM-driven file traversal with keyword fallback
- Created `backend/rag/grader.py` — CRAG relevance grading (parallel, 8B model)
- Created `backend/rag/context_builder.py` — prompt assembly (system prompt + docs + profile + AQI + wearable)
- Created `backend/rag/pipeline.py` — CRAGPipeline main class (replaces Abhijit's mock)
- Created `backend/utils/icmr.py` — ICMR threshold classifiers (BP, sugar, BMI, AQI — Asian cutoffs)
- Updated `backend/api/routes.py` — swapped mock pipeline for real CRAGPipeline
- Updated `backend/requirements.txt` — replaced langchain-ollama with langchain-groq + langgraph
- Updated `backend/.env.example` — added GROQ/SambaNova/Cerebras key slots
- Added OKF files: `conditions/asthma.md`, `lifestyle/exercise-guidelines.md`
- Created GitHub issue #5 for Ritesh (7 architecture diagrams)
- Architecture plan updated with OmniRoute/freellmapi analysis

## Files I Own
- `icmr-knowledge-bundle/` (entire OKF bundle)
- `backend/rag/` (RAG pipeline code)
- `backend/utils/icmr.py`
- `evaluation/`
