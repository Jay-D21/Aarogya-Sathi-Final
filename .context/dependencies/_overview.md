# Dependencies Overview

## Core Dependencies (breaking if removed)
- `httpx>=0.27.0` — LLM provider API calls (Groq/SambaNova/Cerebras cascade)
- `fastapi>=0.115.0` — Backend API framework
- `uvicorn>=0.30.0` — ASGI server for FastAPI
- `sse-starlette>=2.0.0` — Server-Sent Events for chat streaming
- `python-dotenv>=1.0.0` — Load API keys from .env file
- `pyyaml>=6.0` — OKF bundle YAML frontmatter parsing

## Peripheral Dependencies (replaceable)
- `langchain>=0.3.0` — Used minimally; could remove if going pure httpx
- `langchain-groq>=0.2.0` — Alternative Groq integration (not used in cascade)
- `langgraph>=0.2.0` — State machine framework (pipeline currently uses direct async)
- `langchain-community>=0.3.0` — Community integrations
- `ragas>=0.2.0` — Evaluation framework (not yet used)
- `semantic-router>=0.1.0` — Safety layer upgrade (keyword fallback active for now)

## Frontend Dependencies (pubspec.yaml)
- `flutter_riverpod: ^3.1.0` — State management
- `go_router: ^17.0.1` — Navigation
- `dio: ^5.9.0` — HTTP client (will be used for SSE)
- `speech_to_text: ^7.0.0` — Voice input
- `pedometer: ^4.1.1` — Step counting
- `geolocator: ^14.0.2` — GPS location for AQI
- `fl_chart: ^1.1.1` — Charts for dashboard
- `google_fonts: ^7.0.0` — Outfit font family

→ Critical files: .context/dependencies/critical-files.md
→ Dependency graph: .context/dependencies/dependency-graph.md