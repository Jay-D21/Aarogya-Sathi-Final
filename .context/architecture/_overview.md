# Architecture Overview

## Project
**Aarogya Sathi** — AI-powered Digital Health Assistant for India

## Tech Stack (Updated 2026-10-01)

| Layer | Technology | Status |
|-------|-----------|--------|
| **LLM (navigation/grading)** | Groq → `openai/gpt-oss-20b` (Multi-key pooling) | ✅ Working |
| **LLM (generation)** | Groq → `qwen/qwen3.8-27b` (Multi-key pooling) | ✅ Working |
| **LLM Fallback** | SambaNova → Cerebras (auto-cascade) | ✅ Configured |
| **Primary Retrieval** | OKF Bundle (Markdown knowledge files) | ✅ 34 files, target 50+ |
| **Agentic Framework** | ReAct Tool Calling & Intent classification | ✅ Working E2E |
| **Memory** | Local JSON session memory persistence | ✅ Working |
| **Pipeline** | Agentic Flow (intent → short-circuit/tools → insights → generation) | ✅ Working E2E |
| **Translation** | Native generation (Qwen) + Sarvam AI multi-key pooling | ✅ Live |
| **Safety** | Semantic-router + HuggingFaceEncoder | ✅ ML Activated |
| **AQI** | WAQI API (real token) + Open-Meteo | ✅ Live |
| **Backend** | FastAPI + SSE streaming | ✅ Working |
| **Frontend** | Flutter (Android) — Riverpod + Material3 | ✅ Connected — SSE chat, Health Connect, profile, ICMR fallbacks |
| **Evaluation** | RAGAS + Gemini API | 🟡 In Progress |

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