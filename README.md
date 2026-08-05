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

<!-- dev-log: 2026-06-13T12:59:16 -->

<!-- dev-log: 2026-06-14T17:14:41 -->

<!-- dev-log: 2026-06-14T13:38:47 -->

<!-- dev-log: 2026-06-15T20:25:17 -->

<!-- dev-log: 2026-06-16T20:20:38 -->

<!-- dev-log: 2026-06-17T09:48:43 -->

<!-- dev-log: 2026-06-18T19:28:58 -->

<!-- dev-log: 2026-06-20T14:26:21 -->

<!-- dev-log: 2026-06-22T13:42:25 -->

<!-- dev-log: 2026-06-24T10:49:25 -->

<!-- dev-log: 2026-06-24T09:12:33 -->

<!-- dev-log: 2026-06-25T13:35:08 -->

<!-- dev-log: 2026-06-26T21:15:45 -->

<!-- dev-log: 2026-06-28T10:29:07 -->

<!-- dev-log: 2026-06-29T13:26:53 -->

<!-- dev-log: 2026-06-30T18:32:47 -->

<!-- dev-log: 2026-07-01T21:32:17 -->

<!-- dev-log: 2026-07-02T16:55:09 -->

<!-- dev-log: 2026-07-05T16:59:20 -->

<!-- dev-log: 2026-07-06T15:02:20 -->

<!-- dev-log: 2026-07-07T19:09:31 -->

<!-- dev-log: 2026-07-07T16:06:33 -->

<!-- dev-log: 2026-07-08T16:50:16 -->

<!-- dev-log: 2026-07-09T19:54:34 -->

<!-- dev-log: 2026-07-12T09:39:04 -->

<!-- dev-log: 2026-07-13T21:40:45 -->

<!-- dev-log: 2026-07-15T21:03:18 -->

<!-- dev-log: 2026-07-16T21:11:10 -->

<!-- dev-log: 2026-07-17T18:09:14 -->

<!-- dev-log: 2026-07-18T16:57:18 -->

<!-- dev-log: 2026-07-20T15:44:16 -->

<!-- dev-log: 2026-07-21T15:36:22 -->

<!-- dev-log: 2026-07-21T09:36:55 -->

<!-- dev-log: 2026-07-23T13:49:51 -->

<!-- dev-log: 2026-07-24T19:48:46 -->

<!-- dev-log: 2026-07-25T19:02:19 -->

<!-- dev-log: 2026-07-27T13:20:47 -->

<!-- dev-log: 2026-07-27T13:53:10 -->

<!-- dev-log: 2026-07-28T21:07:29 -->

<!-- dev-log: 2026-07-29T22:51:35 -->

<!-- dev-log: 2026-07-30T14:43:47 -->

<!-- dev-log: 2026-07-30T12:30:01 -->

<!-- dev-log: 2026-07-31T19:52:29 -->

<!-- dev-log: 2026-08-02T16:07:06 -->

<!-- dev-log: 2026-08-03T20:34:26 -->

<!-- dev-log: 2026-08-03T16:39:26 -->

<!-- dev-log: 2026-08-04T14:06:43 -->

<!-- dev-log: 2026-08-05T10:54:52 -->
