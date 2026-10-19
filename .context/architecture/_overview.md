# Architecture Overview

## Project
**Aarogya Sathi** — AI-powered Personal Health Agent for India

## Tech Stack (Updated 2026-10-19)

| Layer | Technology | Status |
|-------|-----------|--------|
| **LLM (navigation/grading)** | Groq → `openai/gpt-oss-20b` (3 keys pooled, round-robin) | ✅ Working |
| **LLM (generation)** | Groq → `qwen/qwen3.8-27b` (3 keys pooled, round-robin) | ✅ Working |
| **LLM Fallback** | SambaNova → Cerebras (auto-cascade on provider failure) | ✅ Configured |
| **Primary Retrieval** | OKF Knowledge Bundle (34 Markdown concept files) | ✅ Working, target 50+ |
| **Agentic Framework** | Custom ReAct — Intent classifier → Tool calling → Proactive insights | ✅ Working E2E |
| **Session Memory** | Local JSON persistence (`backend/data/sessions/{user_id}.json`) | ✅ Working |
| **Proactive Insights** | Vital threshold alerts, longitudinal trends, CPCB NAQI warnings | ✅ Working |
| **Pipeline** | Agentic: intent → short-circuit/tools → insights → session-context → generate | ✅ Working E2E |
| **Translation** | Native generation (Qwen 27B) + Sarvam AI 7-key backup | ✅ Live |
| **Safety** | Semantic-router + HuggingFaceEncoder (all-MiniLM-L6-v2) | ✅ ML Activated |
| **AQI** | WAQI API (real token) + Open-Meteo weather | ✅ Live |
| **Backend** | FastAPI + SSE streaming on Render | ✅ Working |
| **Frontend** | Flutter (Android `com.aarogyasathi.app`) — Material 3 Expressive, Google Health/Fit UI, Slate theme, dynamic vitals | ✅ Production Polish (23 tests pass) |
| **Medical File Vault** | On-device sandboxed storage via image_picker + file_picker, Drive-style folders | ✅ Live |
| **Health Profile** | Asian ICMR BMI + conditions/medications + offline caching | ✅ Live |
| **Pedometer Filter** | Gait cadence + 8-step hysteresis bout validation | ✅ Live |
| **Evaluation** | LLM-as-Judge + 32 gold Q&A | 🟡 Needs re-run |
| **Research Paper** | IEEE format, 27 tables, 5 architecture diagrams, 42 refs | ✅ Complete |

## Compute
- **Development**: Free Groq API (no GPU needed — cloud inference)
- **Fallback**: SambaNova (240 RPM), Cerebras (1M TPD)
- **Token budget per query**: ~6,500 tokens across 4-5 LLM calls (3-4 for health queries, 1 for greetings)
- **Groq free tier**: ~250 queries/day with 27B model (3 keys × ~80 per key)

## Key Architecture Decisions
1. Using **free cloud LLM providers** (Groq/SambaNova/Cerebras) instead of local Ollama — no GPU dependency, faster inference (500+ tok/s), automatic failover cascade.
2. **Agentic RAG** instead of linear pipeline — intent-first routing saves 60-70% LLM calls for non-medical queries.
3. **Native multilingual** instead of translate→process→translate — Qwen 27B understands Hinglish/Minglish natively, saving 100% Sarvam credits during chat.
4. **On-device file storage** for DPDP Act compliance — no cloud uploads of medical documents.
5. **Pure on-device vitals evaluation & zero-mock transparency**: Only real recorded measurements generate clinical status and sparklines; honest zero-states with fast "+ Log" actions prevent synthetic clinical reassurance.
6. **DPDP & Play Store compliance**: Package applicationId `com.aarogyasathi.app`, explicit release signing with `key.properties`, elimination of unneeded permissions (`RECORD_AUDIO`), and publicly accessible privacy policy (`docs/privacy-policy.html`).

→ System diagram: [system-diagram.md](system-diagram.md)
→ Data flows: [data-flows.md](data-flows.md)