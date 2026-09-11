# Modules Overview

| # | Module | Owner | Status | Summary |
|---|--------|-------|--------|---------|
| 1 | OKF Knowledge Bundle | Jayesh | 🟡 Mock Data | ICMR guidelines as OKF Markdown files — 11 mock files created for testing |
| 2 | RAG Pipeline | Jayesh | 🔴 Not Started | CRAG + OKF Navigator + Qdrant fallback |
| 3 | Backend API | Abhijit | ✅ Implemented | FastAPI server with SSE streaming, mock pipeline, health + AQI + chat endpoints |
| 4 | Translation | Abhijit | 🟡 Mock Mode | Bhashini API wrapper ready, running mock (API keys pending) |
| 5 | Safety Layer | Abhijit | 🟡 Keyword Fallback | Route definitions ready, keyword fallback active (semantic-router not yet installed) |
| 6 | Environmental Data | Abhijit | 🟡 Partial | Open-Meteo live weather working, WAQI mock (token not configured in .env) |
| 7 | Flutter App | Ritesh | 🔴 Not Started | Android app with chat, profile, AQI dashboard |

→ Each module: [modules/{name}/summary.md] and [modules/{name}/detail.md]