# Architecture Overview

## Project
**Aarogya Sathi** — AI-powered Digital Health Assistant for India

## Tech Stack

| Layer | Technology | Version/ID |
|-------|-----------|------------|
| **LLM** | Llama 3.1 8B Instruct (Q4_K_M) | `meta-llama/Llama-3.1-8B-Instruct` |
| **Inference** | Ollama | Latest |
| **Primary Retrieval** | OKF Bundle (Google Open Knowledge Format) | v0.2 spec |
| **Fallback Retrieval** | BGE-M3 + Qdrant | `BAAI/bge-m3` |
| **Orchestration** | LangChain LCEL | `langchain>=0.3` |
| **Translation** | Bhashini API | Government of India |
| **Safety** | Semantic Router | `aurelio-labs/semantic-router` |
| **AQI** | WAQI API + Open-Meteo | Free tier |
| **Backend** | FastAPI + SSE | Python 3.11 |
| **Frontend** | Flutter (Android) | Dart/Flutter stable |
| **Local DB** | SQLite (sqflite) | On-device |
| **Evaluation** | RAGAS + Gemini API | Free Vertex AI credits |

## Compute
- **Development**: Google Colab T4 (16GB VRAM, free)
- **Demo**: Colab A100 (if available) or local GPU
- **VRAM**: Llama 3.1 8B Q4 (~5GB) + BGE-M3 fallback (~1GB) = **~6GB / 16GB** ✅

→ System diagram: [system-diagram.md](system-diagram.md)
→ Data flows: [data-flows.md](data-flows.md)