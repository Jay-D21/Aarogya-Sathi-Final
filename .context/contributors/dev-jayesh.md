# Jayesh Patil — Contributor Context

## Current Assignment
- **Modules**: OKF Knowledge Bundle, Agentic RAG Pipeline, Session Memory, Evaluation
- **Branch**: main
- **Task**: Upgrade to Agentic RAG with ReAct tool-use & Per-User Session Memory
- **Status**: Active Lead

## Key Responsibilities
1. **Agentic Pipeline**: Build `backend/rag/intent.py` (8B intent classifier) and `backend/rag/tools.py` (ReAct tools).
2. **Per-User Session Memory**: Build `backend/memory/session.py` to persist vital trends and conversation summaries.
3. **Multi-Key LLM Pool**: Maintain 3-key Groq + 7-key Sarvam round-robin rotation in `backend/rag/llm.py` and `bhashini.py`.
4. **Evaluation**: Run full 32-query gold benchmark against the agentic pipeline and record metrics.

## What's Done ✅
- Complete CRAG pipeline: OKF Navigate → CRAG Grade → Context Build → Generate
- Multi-provider LLM cascade: Groq (openai/gpt-oss-20b + qwen/qwen3.8-27b) → SambaNova → Cerebras
- Multi-key rotation with round-robin and auto-429 rotation across 3 Groq keys and 7 Sarvam keys
- Native multilingual support for Hindi, Marathi, and Hinglish/Minglish without translation latency
- Response conciseness and conversational style prompts (max 400 tokens, caring tone, bullet points)
- Clean WAQI station vs actual location distinction in context builder
- Live deployment verified on Render (`https://aarogya-sathi-final.onrender.com`)
- First real LLM-as-judge benchmark run: 4.60 / 5.00 overall score
- Team gap analysis and sprint roadmap documented in `HANDOFF.md`

## Next Action Items
1. Create `backend/rag/intent.py` for pre-RAG query classification.
2. Build `backend/rag/tools.py` and implement ReAct tool loop in `backend/rag/pipeline.py`.
3. Build `backend/memory/session.py` for per-user history tracking.
4. Execute full evaluation benchmark: `python -m evaluation.evaluate`.

## Session Log
- **2026-09-30 (Session 11 — Multi-Key Rotation, Hinglish Optimization, Context Styling & Agentic Roadmap)**:
  - Added multi-key round-robin rotation to `llm.py` and `bhashini.py` supporting comma-separated env keys.
  - Resolved Render production environment and fixed Flutter `api_config.dart` URL target.
  - Eliminated Sarvam translation dependency for conversational chat by prompting Qwen 27B to understand Hinglish/Minglish natively.
  - Injected response brevity guidelines into `context_builder.py` and capped output tokens at 400.
  - Clarified WAQI station reporting to prevent misleading city attributions.
  - Conducted comprehensive frontend and backend feature audits and produced the Agentic RAG implementation plan.
