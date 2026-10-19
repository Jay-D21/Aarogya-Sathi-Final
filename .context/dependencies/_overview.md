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
- `provider: ^6.1.5+1` — App-wide reactive state management
- `http: ^1.6.0` — REST API calls and SSE streaming
- `shared_preferences: ^2.5.5` — Key-value persistence (language, cached user profile, vault index)
- `flutter_secure_storage: ^10.0.0` — Encrypted storage for JWT auth tokens
- `google_fonts: ^8.0.2` — Outfit & Inter design system typography
- `intl: ^0.19.0` — Date, time, and number localization
- `uuid: ^4.5.3` — Unique ID generator for medical vault & health records
- `path_provider: ^2.1.5` — Sandboxed app document directory for vault
- `permission_handler: ^12.0.1` — Runtime permissions (location, notifications, sensors)
- `geolocator: ^14.0.2` — GPS coordinates for WAQI environmental data
- `geocoding: ^4.0.0` — Reverse geocoding coordinates to city name
- `flutter_local_notifications: ^21.0.0` — Local scheduled alarms & health alerts
- `timezone: ^0.11.0` — Timezone-aware scheduling for notifications
- `pedometer: ^4.2.0` — Hardware step sensor event stream
- `url_launcher: ^6.3.1` — Emergency 112 calling and external links
- `health: ^11.0.0` — Google Health Connect SDK (Fitbit vitals, SpO2, sleep)
- `image_picker: ^1.2.3` — Camera and gallery photo picker for prescriptions
- `file_picker: ^11.0.3` — PDF lab report and document picker for vault
- `cupertino_icons: ^1.0.8` — Material/Cupertino asset icons

## Frontend Dev Dependencies
- `flutter_launcher_icons: ^0.14.3` — Automatic generation of multi-density Android adaptive launcher icons
- `flutter_lints: ^6.0.0` — Official Flutter recommended lint rules

## Removed / Dead Dependencies (cleaned up)
- `dio`, `fl_chart`, `shimmer` — removed in session 12 (standardized to `http` and Canvas)
- `flutter_riverpod`, `go_router` — replaced by `provider` and native `Navigator`
- `speech_to_text`, `flutter_tts` — removed in session 19 (unused, eliminates unneeded C++ binaries)

→ Critical files: .context/dependencies/critical-files.md
→ Dependency graph: .context/dependencies/dependency-graph.md