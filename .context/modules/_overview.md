# Modules Overview

| # | Module | Owner | Status | Summary |
|---|--------|-------|--------|---------|
| 1 | OKF Knowledge Bundle | Jayesh | 🟡 In Progress (34/50+) | ICMR guidelines as OKF Markdown files — conditions, drugs, lifestyle, emergency, environmental |
| 2 | RAG Pipeline | Jayesh | ✅ Working E2E | Agentic ReAct flow: Intent classification, short-circuiting, tool calling (`tool_search_knowledge`, `tool_analyze_vitals`, `tool_get_environmental_data`), and proactive insights |
| 3 | Backend API | Abhijit | ✅ Working | FastAPI + SSE streaming, per-user session memory persistence, real-time insights endpoints |
| 4 | Translation | Abhijit | ✅ Live | Native Hinglish/Marathi response generation (skipping translation) + Sarvam AI multi-key pooling for fallback |
| 5 | Safety Layer | Abhijit | ✅ ML Activated | Semantic Router + HuggingFaceEncoder (all-MiniLM-L6-v2) |
| 6 | Environmental Data | Abhijit | ✅ Live | Real WAQI API token integration and Open-Meteo live weather |
| 7 | Flutter App | Ritesh/Jayesh | ✅ Connected | SSE chat, Health Connect, profile, ICMR demo fallbacks, persistent language settings |
| 8 | Evaluation | Jayesh | 🟡 In Progress | RAGAS pipeline built, 32 gold Q&A pairs, LLM-as-judge scoring |
| 9 | Research | Abhijit | ✅ Done | Capstone research validation, 14.3:1 ROI, and MMed-RAG hallucination analysis artifacts |
| 10 | Medical File Vault | Abhijit | ✅ Live | Local DPDP-compliant vault for prescriptions, lab reports, and scans with camera/file picker & on-device sandbox |

→ Each module: [modules/{name}/summary.md] and [modules/{name}/detail.md]