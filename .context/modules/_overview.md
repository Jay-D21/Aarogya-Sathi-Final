# Modules Overview

| # | Module | Owner | Status | Summary |
|---|--------|-------|--------|---------|
| 1 | OKF Knowledge Bundle | Jayesh | 🟡 In Progress (34/50+) | ICMR guidelines as OKF Markdown files — conditions, drugs, lifestyle, emergency, environmental |
| 2 | RAG Pipeline | Jayesh | ✅ Agentic RAG Live | Agentic ReAct flow: Intent classification → short-circuit greetings → selective tool calling → proactive insights → session-aware generation |
| 3 | Backend API | Jayesh/Abhijit | ✅ Working | FastAPI + SSE streaming, per-user session memory, `/api/session/{user_id}/insights` endpoint |
| 4 | Translation | Jayesh | ✅ Live | Native Hinglish/Marathi response generation (Qwen 27B) + Sarvam AI 7-key pooling for fallback |
| 5 | Safety Layer | Abhijit | ✅ 100% Intercept Tested | Semantic Router + HuggingFaceEncoder (all-MiniLM-L6-v2) with max aggregation (threshold 0.70): 42/42 adversarial blocked, 0/32 false positives, 13.8ms latency, 108 EMRI / 102 NHM ambulance dispatch |
| 6 | Environmental Data | Abhijit | ✅ Live | Real WAQI API token + Open-Meteo live weather |
| 7 | Flutter App | Jayesh/Abhijit | ✅ Production Polish | Google Health/Fit Material 3 UI (9 reusable widgets: sparklines, status badges, summary banner), dynamic vitals (mock purged), gold mandala branding & opening motion, Play Store beta ready (`com.aarogyasathi.app`, signing, privacy policy), 23/23 tests pass |
| 8 | Evaluation | Jayesh/Abhijit | ✅ Verified Preliminary | 32 Gold Standard clinical cases (faithfulness 4.56, relevancy 4.63, completeness 4.50, safety 4.72, avg 4.60/5.00), verified router & 23/23 mobile tests |
| 9 | Research Paper | Abhijit | ✅ Complete | Full IEEE-format paper (`paper/paper.md`, 27 tables, 5 ASCII diagrams, 42 refs), `RESEARCH_CONTEXT.md` v1.3.0 |
| 10 | Medical File Vault | Abhijit | ✅ Live + Tested | Google Drive-style folders (`category_folder_card.dart`), storage overview, on-device DPDP-compliant vault for prescriptions/reports via `image_picker` + `file_picker`, 6 unit tests |
| 11 | Health Profile & BMI | Abhijit | ✅ Live + Tested | Asian ICMR BMI calculator, chronic conditions & medications manager, offline profile caching, RAG sync, 6 unit tests |
| 12 | Pedometer Filter | Abhijit | ✅ Live + Tested | Gait cadence filter + 8-step hysteresis bout validation to reject hand movements, 6 unit tests |
| 13 | Proactive Notifications | Jayesh | ✅ Live | HealthAlertService: ICMR vital alerts (BP, sugar, HR, SpO2), CPCB AQI alerts, backend insight polling with 60min cooldowns |
| 14 | Architecture Diagrams | Ritesh | ✅ Complete | 8 publication-grade modular architecture diagrams in `docs/diagrams/images/` and `docs/diagrams/system_architecture_diagrams.md` |
| 15 | Demo Video | Ritesh | ❌ Not Started | 5-minute walkthrough — assigned but not recorded |

→ Each module: [modules/{name}/summary.md] and [modules/{name}/detail.md]
