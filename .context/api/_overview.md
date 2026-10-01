# API Overview

| Group | Endpoints | Status | One-liner |
|-------|-----------|--------|-----------|
| Chat | `POST /api/chat` | ✅ Working | Main SSE streaming endpoint for Agentic RAG chat |
| AQI | `GET /api/aqi` | ✅ Working | Real-time CPCB NAQI and Open-Meteo fallback based on lat/lon |
| Memory | `GET /api/session/{user_id}/insights` | ✅ Working | Real-time proactive insights from longitudinal session memory |
| Health | `GET /health` | ✅ Working | Basic backend readiness check |

→ Drill: .context/api/chat-endpoints.md (Pending creation)