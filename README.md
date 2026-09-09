# Aarogya Sathi — AI-powered Digital Health Assistant

> **Digital Health Assistant** for India, built on ICMR clinical guidelines with personalized, multilingual, environment-aware health advice.

## Team
| Name | Roll No | Role |
|------|---------|------|
| Jayesh Patil | C233 | Lead — RAG & LLM Pipeline |
| Abhijit Patil | C263 | Backend & Integration |
| Ritesh Pawar | C276 | Frontend & Mobile |

**Guide**: Dr. Atul V. Dusane | **Dept**: IT/AIML, MPSTME, SVKM's NMIMS Shirpur

## Architecture
```
Flutter App → FastAPI (SSE) → CRAG Pipeline → Llama 3.1 8B (Ollama)
                                    ↕
                         OKF Bundle (ICMR guidelines)
                         + Qdrant fallback (BGE-M3)
                         + Bhashini (HI/MR translation)
                         + WAQI/Open-Meteo (AQI)
                         + Health Connect (wearable data)
                         + Semantic Router (safety)
```

## Tech Stack
| Component | Technology |
|-----------|-----------|
| LLM | Llama 3.1 8B Instruct (Ollama) |
| Primary Retrieval | Google OKF (Open Knowledge Format) |
| Fallback Retrieval | BGE-M3 + Qdrant |
| Orchestration | LangChain LCEL + CRAG |
| Backend | FastAPI + SSE |
| Frontend | Flutter (Android) |
| Translation | Bhashini API (HI/MR/EN) |
| Safety | Semantic Router |
| Wearable | Health Connect SDK |
| AQI | WAQI + Open-Meteo |
| Evaluation | RAGAS |

## Getting Started

### Dev Setup
```bash
git clone https://github.com/Jay-D21/Aarogya-Sathi-Final.git
cd Aarogya-Sathi-Final
```

### For Jayesh (RAG Pipeline)
```bash
cd backend
pip install -r requirements.txt
ollama pull llama3.1:8b-instruct-q4_K_M
```

### For Abhijit (Backend)
```bash
cd backend
pip install -r requirements.txt
cp .env.example .env  # Fill in API keys
uvicorn main:app --reload --port 8000
```

### For Ritesh (Mobile)
```bash
cd mobile
flutter pub get
flutter run
```

## Project Structure
```
├── .context/                    ← iLabs context system
├── .agents/                     ← Agent rules
├── Research/                    ← Research documents
├── icmr-knowledge-bundle/       ← OKF knowledge base (Jayesh)
├── backend/                     ← Python backend (Jayesh + Abhijit)
│   ├── api/                     ← FastAPI routes
│   ├── rag/                     ← CRAG pipeline
│   ├── translation/             ← Bhashini wrapper
│   ├── safety/                  ← Semantic Router
│   └── context/                 ← AQI + context builder
├── mobile/                      ← Flutter app (Ritesh)
├── evaluation/                  ← RAGAS evaluation
└── docs/                        ← Reports
```

## Documentation
- **Implementation Plan**: [docs/implementation_plan.md](docs/implementation_plan.md)
- **Architecture**: [docs/okf_architecture.md](docs/okf_architecture.md)
- **Context System**: [.context/INDEX.md](.context/INDEX.md)
- **Research**: [Research/](Research/)
