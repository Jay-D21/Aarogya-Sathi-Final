# Modules Overview

| # | Module | Owner | Status | Summary |
|---|--------|-------|--------|---------|
| 1 | OKF Knowledge Bundle | Jayesh | 🟡 In Progress (34/50+) | ICMR guidelines as OKF Markdown files — conditions, drugs, lifestyle, emergency, environmental |
| 2 | RAG Pipeline | Jayesh | ✅ Working E2E | CRAGPipeline: OKF Navigator → CRAG Grader → Context Builder → Multi-provider LLM generation |
| 3 | Backend API | Abhijit | ✅ Working | FastAPI + SSE streaming, real CRAG pipeline wired, health + AQI + chat endpoints |
| 4 | Translation | Abhijit | 🟡 Mock Mode | Bhashini API wrapper ready, mock fallback active (API keys arriving in 3-4 days) |
| 5 | Safety Layer | Abhijit | 🟡 Keyword Fallback | Emergency/prescription/non-medical blocking — semantic-router upgrade pending |
| 6 | Environmental Data | Abhijit | 🟡 Partial | Open-Meteo live weather ✅, WAQI mock (token not in .env) |
| 7 | Flutter App | Ritesh | 🟡 UI Only | 4 screens merged (Dashboard, Chat, Register, Reports) — needs backend SSE connection |
| 8 | Evaluation | Jayesh | 🟡 In Progress (32/100 Q&A) | RAGAS pipeline built, 32 gold Q&A pairs, LLM-as-judge scoring |

→ Each module: [modules/{name}/summary.md] and [modules/{name}/detail.md]