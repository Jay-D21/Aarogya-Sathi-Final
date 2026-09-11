# Architecture Overview

## Project
**Aarogya Sathi** — AI-powered Digital Health Assistant for India

## Tech Stack (Updated 2026-09-11)

| Layer | Technology | Status |
|-------|-----------|--------|
| **LLM (navigation/grading)** | Groq → `openai/gpt-oss-20b` | ✅ Working |
| **LLM (generation)** | Groq → `qwen/qwen3.8-27b` | ✅ Working |
| **LLM Fallback** | SambaNova → Cerebras (auto-cascade) | Configured, untested |
| **Primary Retrieval** | OKF Bundle (Markdown knowledge files) | ✅ 13 files, target 50+ |
| **Fallback Retrieval** | Qdrant + BGE-M3 | 🔴 Phase 2 (not started) |
| **Pipeline** | CRAGPipeline (navigate → grade → build → generate) | ✅ Working E2E |
| **Translation** | Bhashini API | 🟡 Mock (keys pending) |
| **Safety** | Keyword-based router | 🟡 Semantic-router upgrade pending |
| **AQI** | WAQI API + Open-Meteo | 🟡 WAQI mock, weather live |
| **Backend** | FastAPI + SSE streaming | ✅ Working |
| **Frontend** | Flutter (Android) — Riverpod + Material3 | 🟡 UI done, backend not connected |
| **Evaluation** | RAGAS + Gemini API | 🔴 Not started |

## Compute
- **Development**: Free Groq API (no GPU needed — cloud inference)
- **Fallback**: SambaNova (240 RPM), Cerebras (1M TPD)
- **Token budget per query**: ~6,500 tokens across 4-5 LLM calls
- **Groq free tier**: ~250 queries/day with 27B model

## Key Architecture Decision
Using **free cloud LLM providers** (Groq/SambaNova/Cerebras) instead of local Ollama.
Rationale: No GPU dependency, faster inference (500+ tok/s), automatic failover cascade.

→ System diagram: [system-diagram.md](system-diagram.md)
→ Data flows: [data-flows.md](data-flows.md)