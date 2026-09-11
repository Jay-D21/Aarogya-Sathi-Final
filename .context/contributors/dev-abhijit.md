# Abhijit Patil — Contributor Context

## Current Assignment
- **Modules**: Backend API, Translation, Safety Layer, Environmental Data
- **Branch**: main
- **Task**: Build backend APIs + safety layer + integrations
- **Started**: 2026-09-08

## Responsibilities
1. Set up FastAPI backend with SSE streaming
2. Integrate Bhashini API for Hindi/Marathi translation
3. Implement Semantic Router for safety (emergency, prescription blocking)
4. Build WAQI + Open-Meteo AQI integration
5. Design XML context template for LLM prompts
6. Help Jayesh with OKF bundle creation (medical content review)
7. Integration testing with all components

## Weekly Plan
| Week | Task | Deliverable |
|------|------|-------------|
| W1-2 | FastAPI skeleton + Bhashini API wrapper | Working translation endpoint |
| W3-4 | WAQI + Open-Meteo integration + context builder | AQI flowing into context |
| W5-6 | Semantic Router safety layer | Emergency/prescription blocking |
| W7-8 | Context engineering + system prompt tuning | XML template finalized |
| W9-10 | Integration testing + safety compliance suite | All APIs working E2E |
| W11-12 | Help with evaluation + documentation | Final report sections |

### Session: 2026-09-11
- Implemented Phase 1-4 (FastAPI skeleton, Bhashini mock, Safety Router, AQI+Weather)
- Created 9 Python files: main.py, models.py, routes.py, bhashini.py, safety/routes.py, safety/router.py, aqi.py, weather.py
- Created 11 mock OKF knowledge bundle files (diabetes, hypertension, metformin, diet, AQI impact, hypoglycemia)
- Bhashini: mock fallback mode (API keys pending 3-4 days)
- Safety: keyword fallback (semantic-router not yet installed)
- AQI: mock mode (WAQI token not configured in .env), Open-Meteo live weather working
- All 9 verification tests passing (health, AQI, chat SSE, safety blocking, translation, wearable data)

## Files I Own
- `backend/api/` (FastAPI endpoints)
- `backend/translation/` (Bhashini wrapper)
- `backend/safety/` (Semantic Router)
- `backend/context/` (AQI + context builder)
