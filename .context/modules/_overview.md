# Modules Overview

| # | Module | Owner | Status | Summary |
|---|--------|-------|--------|---------|
| 1 | OKF Knowledge Bundle | Jayesh | 🟡 In Progress (34/50+) | ICMR guidelines as OKF Markdown files — conditions, drugs, lifestyle, emergency, environmental |
| 2 | RAG Pipeline | Jayesh | ✅ Agentic RAG Live | Agentic ReAct flow: Intent classification → short-circuit greetings → selective tool calling → proactive insights → session-aware generation |
| 3 | Backend API | Jayesh/Abhijit | ✅ Working | FastAPI + SSE streaming, per-user session memory, `/api/session/{user_id}/insights` endpoint |
| 4 | Translation | Jayesh | ✅ Live | Native Hinglish/Marathi response generation (Qwen 27B) + Sarvam AI 7-key pooling for fallback |
| 5 | Safety Layer | Abhijit | ✅ ML Activated | Semantic Router + HuggingFaceEncoder (all-MiniLM-L6-v2), 42 utterances across 3 categories |
| 6 | Environmental Data | Abhijit | ✅ Live | Real WAQI API token + Open-Meteo live weather |
| 7 | Flutter App | Jayesh/Abhijit | ✅ Production Polish | Google Health/Fit Material 3 UI (9 reusable widgets: sparklines, status badges, summary banner), dynamic vitals (mock purged), gold mandala branding & opening motion, Play Store beta ready (`com.aarogyasathi.app`, signing, privacy policy), 23/23 tests pass |
| 8 | Evaluation | Jayesh | 🟡 Needs Re-run | LLM-as-judge pipeline built, 32 gold Q&A pairs — needs re-run against agentic pipeline |
| 9 | Research Paper | Abhijit | ✅ Complete | Full IEEE-format paper (`paper/paper.md`, 27 tables, 5 ASCII diagrams, 42 refs), `RESEARCH_CONTEXT.md` v1.3.0 |
| 10 | Medical File Vault | Abhijit | ✅ Live + Tested | Google Drive-style folders (`category_folder_card.dart`), storage overview, on-device DPDP-compliant vault for prescriptions/reports via `image_picker` + `file_picker`, 6 unit tests |
| 11 | Health Profile & BMI | Abhijit | ✅ Live + Tested | Asian ICMR BMI calculator, chronic conditions & medications manager, offline profile caching, RAG sync, 6 unit tests |
| 12 | Pedometer Filter | Abhijit | ✅ Live + Tested | Gait cadence filter + 8-step hysteresis bout validation to reject hand movements, 6 unit tests |
| 13 | Proactive Notifications | Ritesh | ❌ Not Started | Background AQI alerts, vital anomaly alerts, daily morning briefings — assigned but no commits |
| 14 | Architecture Diagrams | Ritesh | ❌ Not Started | 7 capstone diagrams for report/presentation — assigned but no commits |
| 15 | Demo Video | Ritesh | ❌ Not Started | 5-minute walkthrough — assigned but not recorded |

→ Each module: [modules/{name}/summary.md] and [modules/{name}/detail.md]