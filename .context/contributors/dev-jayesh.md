# Jayesh Patil — Contributor Context

## Current Assignment
- **Modules**: OKF Knowledge Bundle, Agentic RAG Pipeline, Session Memory, Evaluation
- **Branch**: main
- **Status**: Active Lead

## Key Responsibilities
1. **Agentic Pipeline**: Maintain `backend/rag/intent.py`, `tools.py`, `pipeline.py` — intent-first routing with ReAct tool-use.
2. **Per-User Session Memory**: Maintain `backend/memory/session.py` — local JSON disk persistence.
3. **Multi-Key LLM Pool**: Maintain 3-key Groq + 7-key Sarvam round-robin rotation in `llm.py` and `bhashini.py`.
4. **Evaluation**: Run full 32-query gold benchmark against the agentic pipeline and expand to 50+ questions.
5. **OKF Bundle Expansion**: Grow from 34 → 50+ concept files covering more conditions, drugs, and lifestyle topics.

## What's Done ✅
- Agentic CRAG pipeline: Intent Classification → Selective Tool Use → Proactive Insights → Generation
- Intent classifier with heuristic fast-path (regex) + 70B LLM fallback for nuanced queries
- Proactive insights engine: vital thresholds (HR, SpO2, BP, glucose), AQI alerts, longitudinal BP/HR trends
- Per-user session memory: in-memory cache + JSON disk persistence, vital history, conversation summaries
- Multi-provider LLM cascade: Groq → SambaNova → Cerebras with multi-key round-robin per provider
- Native multilingual: Hindi/Marathi/Hinglish/Minglish understood directly by Qwen 27B (no translation overhead)
- Response brevity: max 400 tokens, warm conversational tone, bullet points, no essays
- Live deployment on Render (`https://aarogya-sathi-final.onrender.com`)
- First LLM-as-judge benchmark: 4.60/5.00 overall score
- Team sprint roadmap and gap analysis documents

## Still Pending
1. **Evaluation re-run**: Execute full 32-query benchmark through the new agentic pipeline (post-Session 12 upgrade)
2. **OKF expansion**: Add 16+ more concept files (malaria, pneumonia, PCOD, losartan, mental-health)
3. **Proactive notification endpoint testing**: Verify `/api/session/{user_id}/insights` against real wearable data
4. **Final report architecture diagrams**: Update with agentic flow (Ritesh to create, Jayesh to review)

## Session Log
- **2026-09-30 (Session 12)**: Built intent.py, tools.py, insights.py, session.py. Rewrote pipeline.py to agentic flow. Added user_id to ChatRequest. Added /api/session/{user_id}/insights. Fixed language selector persistence. Removed dead deps. Integration test passed.
- **2026-09-30 (Session 11)**: Multi-key rotation, Hinglish optimization, context styling, agentic roadmap.
- **2026-09-27 (Session 10)**: Audit, cleanup, honest README.
