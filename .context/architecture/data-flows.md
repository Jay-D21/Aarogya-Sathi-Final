# Data Flow — User Query to Response

## Main Query Flow

1. **User** types query in Flutter app (Hindi/Marathi/English)
2. **Flutter** sends POST to `/api/chat` with query + user_id + language
3. **FastAPI** receives request
4. **Semantic Router** classifies intent:
   - Emergency → return 112 message immediately
   - Prescription request → return refusal message
   - Medical query → continue pipeline
5. **Bhashini API** translates HI/MR → EN (if needed)
6. **OKF Navigator** (primary retrieval):
   - Reads `index.md` from OKF bundle
   - Identifies relevant condition files
   - Reads concept files + follows hyperlinks
   - Collects 2-4 related concept documents
7. **CRAG Relevance Check**:
   - Llama 3.1 evaluates: "Do these docs answer the question?"
   - YES → continue
   - NO → fallback to BGE-M3 + Qdrant vector search
   - Still NO → Google Search API
8. **Context Builder** assembles:
   - System prompt + safety rules
   - User health profile (from SQLite via API)
   - AQI data (from WAQI + Open-Meteo)
   - Retrieved OKF/RAG documents
   - User query
9. **Ollama (Llama 3.1 8B)** generates response with [Doc] citations
10. **Bhashini API** translates EN → HI/MR (if needed)
11. **FastAPI** streams response via SSE to Flutter app
12. **Flutter** displays streaming text with disclaimer

## AQI Data Flow
1. Flutter sends user's GPS coordinates
2. FastAPI queries WAQI API + Open-Meteo
3. Data injected into LLM context as XML block
4. LLM cross-references AQI with user's conditions

## Health Profile Flow
1. User fills profile in Flutter (age, gender, conditions, medications)
2. Stored locally in SQLite via sqflite (DPDP compliant)
3. Sent with each chat request as context
4. Never stored server-side — only on-device