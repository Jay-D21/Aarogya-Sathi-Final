# Critical Files

These files have high impact. Modifying them affects many parts of the system.
**Do not change these without understanding downstream effects.**

| File | Impact | Why It's Critical |
|------|--------|-------------------|
| `backend/rag/pipeline.py` | Critical | Core Agentic ReAct orchestrator — routes queries, invokes tools, fetches insights, and streams LLM output. |
| `backend/rag/intent.py` | Critical | Classification engine (regex fast-path + 70B LLM fallback) that gates tool execution and short-circuits greetings. |
| `backend/rag/llm.py` | Critical | Multi-key pool rotation (Groq, SambaNova, Cerebras) and fallback cascade logic. |
| `backend/safety/router.py` | Critical | Semantic Router safety layer (HuggingFace all-MiniLM-L6-v2) filtering emergencies and harmful queries. |
| `backend/memory/session.py` | Critical | Per-user session state, vital history, and conversation context disk persistence. |
| `frontend/lib/config/api_config.dart` | Critical | Central network configuration mapping local development vs. live Render backend (`https://aarogya-sathi-final.onrender.com`). |
| `frontend/lib/providers/auth_provider.dart` | Critical | Root auth state, token persistence, user profile synchronization, and app language state. |
| `frontend/lib/screens/home/home_screen.dart` | High | Main user portal: integrates Google Health status banner, dynamic vitals, AQI environment card, and tab routing. |
| `frontend/lib/screens/onboarding/splash_screen.dart` | High | Initial entry screen orchestrating the 3-phase opening motion and session routing to login/home. |
| `frontend/lib/services/step_filter_service.dart` | High | Rejects desk hand movements via pedestrian status, 3.2 Hz cadence gating, and 8-step hysteresis window. |
| `frontend/android/app/build.gradle.kts` | Critical | Android build configuration, `com.aarogyasathi.app` namespace, SDK targets (36/21), and release keystore signing. |
| `frontend/pubspec.yaml` | Critical | App dependencies, asset registrations, and launcher icon specifications. |