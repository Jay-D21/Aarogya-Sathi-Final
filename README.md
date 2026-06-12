# Aarogya Sathi — AI-powered Digital Health Assistant

> **Context-aware digital health assistant** for India, built on ICMR clinical guidelines with personalized, multilingual, environment-aware health advice.

## Team
| Name | Roll No | Role |
|------|---------|------|
| Jayesh Patil | C233 | Lead — RAG & LLM Pipeline |
| Abhijit Patil | C263 | Backend & Integration |
| Ritesh Pawar | C276 | Frontend & Mobile |

**Guide**: Dr. Atul V. Dusane | **Dept**: IT/AIML, MPSTME, SVKM's NMIMS Shirpur

## Architecture
```
Flutter App (Android) → FastAPI (SSE) → CRAG Pipeline → Cloud LLM (Groq API)
                                            ↕
                              OKF Bundle (40 ICMR guideline files)
                              + Sarvam AI (Hindi/Marathi translation)
                              + WAQI + Open-Meteo (AQI & weather)
                              + Health Connect SDK (wearable data)
                              + Semantic Router (safety classification)
```

## Tech Stack
| Component | Technology | Details |
|-----------|-----------|---------|
| LLM Inference | Groq Cloud API (cascade: Groq → SambaNova → Cerebras) | `qwen/qwen3.8-27b` (primary), `openai/gpt-oss-20b` (judge) |
| Primary Retrieval | OKF Navigator (ICMR knowledge bundle) | 40 structured Markdown concept files with cross-links |
| RAG Pipeline | CRAG (Corrective RAG) | Navigate → Grade → Build Context → Generate |
| Backend | FastAPI + SSE streaming | Python 3.11, async throughout |
| Frontend | Flutter (Android) | Provider state management, Health Connect SDK |
| Translation | Sarvam AI (`mayura:v1`) | Hindi, Marathi, English — sentence-chunked for long responses |
| Safety | Semantic Router + keyword fallback | 42 utterances: emergency (20), prescription (13), non-medical (9) |
| Wearable | Android Health Connect SDK | Steps, HR, SpO2, sleep, glucose, BP, temperature |
| Environmental | WAQI API + Open-Meteo | AQI, PM2.5, temperature, humidity, UV index |
| Evaluation | LLM-as-Judge | 32 gold QA pairs, 4 metrics: faithfulness, relevancy, completeness, safety |
| Deployment | Render (backend), Local APK (frontend) | Production URL configured |

## Project Structure
```
├── backend/                 # FastAPI backend
│   ├── api/                 # Routes, models, SSE streaming
│   ├── rag/                 # CRAG pipeline, OKF navigator, grader, context builder
│   ├── safety/              # Semantic Router (emergency/prescription blocking)
│   ├── translation/         # Sarvam AI wrapper (Hindi/Marathi ↔ English)
│   ├── context/             # WAQI AQI + Open-Meteo weather
│   └── utils/               # ICMR classifiers (BP, sugar, BMI, AQI thresholds)
├── frontend/                # Flutter Android app
│   └── lib/
│       ├── screens/         # Home, Chat, Health Dashboard, Profile
│       ├── providers/       # Chat, Auth, Health, Fitness state management
│       ├── services/        # API, Location, Health Connect, Notifications
│       └── config/          # API endpoints, theme
├── icmr-knowledge-bundle/   # 40 OKF Markdown files (conditions, drugs, lifestyle, emergency, environmental)
├── evaluation/              # LLM-as-Judge evaluation (32 gold QA pairs)
└── docs/                    # Presentations, interim report, system map
```

## Getting Started

### Prerequisites
- Python 3.11+
- Flutter SDK (stable channel)
- Android device/emulator with Health Connect

### Backend Setup
```bash
cd backend
pip install -r requirements.txt
cp .env.example .env  # Fill in your API keys (see below)
python -m uvicorn backend.main:app --reload
```

### Frontend Setup
```bash
cd frontend
flutter pub get
flutter run --dart-define=GROQ_API_KEY=your_groq_key_here
```

### Required API Keys
| Key | Where to get it | Cost |
|-----|----------------|------|
| `GROQ_API_KEY` | https://console.groq.com | Free |
| `SARVAM_API_KEY` | https://dashboard.sarvam.ai | ₹100 free credits |
| `WAQI_API_TOKEN` | https://aqicn.org/data-platform/token/ | Free |

### Optional API Keys (fallback LLM providers)
| Key | Where to get it |
|-----|----------------|
| `SAMBANOVA_API_KEY` | https://cloud.sambanova.ai |
| `CEREBRAS_API_KEY` | https://cloud.cerebras.ai |

## Design Framework
Built following **ICMR's "Ethical Guidelines for Application of AI in Biomedical Research and Healthcare" (March 2023)** — 10 ethical principles: Autonomy, Accountability, Safety, Trustworthiness, Validity, Non-discrimination, Data Privacy, Inclusiveness, Transparency, Professional Competence.

## License
Academic project — SVKM's NMIMS Shirpur, 2026-27.

<!-- dev-log: 2026-05-28T16:35:48 -->

<!-- dev-log: 2026-05-28T10:18:14 -->

<!-- dev-log: 2026-05-29T17:22:27 -->

<!-- dev-log: 2026-05-30T12:07:46 -->

<!-- dev-log: 2026-06-02T12:47:30 -->

<!-- dev-log: 2026-06-03T12:18:14 -->

<!-- dev-log: 2026-06-04T09:35:18 -->

<!-- dev-log: 2026-06-06T18:18:30 -->

<!-- dev-log: 2026-06-07T22:04:25 -->

<!-- dev-log: 2026-06-08T18:19:05 -->

<!-- dev-log: 2026-06-09T12:49:33 -->

<!-- dev-log: 2026-06-10T18:39:03 -->

<!-- dev-log: 2026-06-11T10:10:15 -->

<!-- dev-log: 2026-06-12T16:18:02 -->
