# Aarogya Sathi — Complete Architecture (Every Aspect Decided)
### Based on: 3 Research Rounds + 3 LLM Council Sessions (15 Advisors)
### Constraint: All models < 9B parameters | 3 months | Zero budget
### Team: Jayesh Patil | Abhijit Patil | Ritesh Pawar

---

## ASPECT 1: Base LLM Model

### What is this?
The core AI brain that reads the retrieved ICMR guidelines + user query + AQI data and generates a health response.

### Options Considered
| Model | Params | MedQA (approx) | Hindi Support | Context Window | VRAM (4-bit) |
|-------|--------|----------------|---------------|---------------|-------------|
| Llama 3.1 8B Instruct | 8B | ~60-65% | Limited | **128K** | ~5GB |
| Qwen2.5 7B Instruct | 7B | ~58-62% | **Native** | 32K | ~4.5GB |
| Gemma 2 9B Instruct | 9B | ~62-66% | Limited | 8K | ~5.5GB |
| DeepSeek-R1-Distill-7B | 7B | ~55-60% | None | 32K | ~4.5GB |
| BioMistral 7B | 7B | **50.6%** | None | 8K | ~4.5GB |

### Why NOT BioMistral?
50.6% on MedQA = coin-flip accuracy. Rejected unanimously across all 3 council rounds.

### VERDICT: **Llama 3.1 8B Instruct**
- **HuggingFace ID**: `meta-llama/Llama-3.1-8B-Instruct`
- **GGUF**: `bartowski/Meta-Llama-3.1-8B-Instruct-GGUF` (Q4_K_M)

### WHY this is the best choice:
1. **128K context window** — largest of all sub-9B models. Critical for RAG where we inject multiple ICMR chunks + AQI + user profile
2. **Industry standard** — massive community, most tutorials, most integrations, most tested
3. **Best instruction-following** — in RAG, the LLM is a synthesizer. It must faithfully follow the system prompt ("answer ONLY from context, cite sources"). Llama 3.1 8B is the gold standard for instruction compliance
4. **Ecosystem** — works with Ollama, vLLM, llama.cpp, LangChain, everything
5. **5GB VRAM (4-bit)** — fits on free Colab T4 (16GB) with room for embeddings

### What about Hindi/Marathi?
Llama 3.1 has basic Hindi capability. But more importantly — our RAG pipeline retrieves English ICMR docs and generates English responses. Translation is handled separately by Bhashini API. The LLM doesn't need native Hindi — it needs to be the best English medical synthesizer.

---

## ASPECT 2: Agentic RAG Pipeline Architecture

### What is this?
How the system retrieves relevant ICMR guidelines and generates a response. This is the CORE of the project.

### Options Considered
| Architecture | How it works | Medical Accuracy | Complexity | Latency |
|-------------|-------------|-----------------|------------|---------|
| **Naive RAG** | Retrieve → Generate (no checking) | Low — hallucinates if chunks are irrelevant | Simple | Fast |
| **CRAG (Corrective)** | Retrieve → **Grade relevance** → Generate (re-retrieve if bad) | **High** — catches bad retrievals | Medium | Medium |
| **Self-RAG** | Retrieve → Generate → **Grade hallucination** → Regenerate if needed | High — catches hallucinations | High | Slow |
| **CRAG + Self-RAG** | Both: grade retrieval AND grade generation | Highest | Very High | Very Slow |
| **Adaptive RAG** | Route by complexity: simple → direct, complex → full pipeline | High | High | Variable |

### VERDICT: **CRAG (Corrective RAG)**
### WHY:
1. **Catches the biggest failure mode**: If the retrieved ICMR chunks don't actually answer the user's question, naive RAG hallucinates. CRAG adds a **relevance check** — if chunks are irrelevant, it rewrites the query and re-retrieves (or falls back to web search via Google)
2. **Manageable complexity**: CRAG is one extra LLM call (relevance grading) vs Self-RAG which adds another (hallucination grading). For a 3-month project, CRAG is the sweet spot
3. **Google integration**: When CRAG detects insufficient local docs, it can fall back to **Google Search** (via Programmable Search Engine or Vertex AI grounding) — this is the "Google open knowledge platform" the user wants

### How CRAG Works (Step by Step):

```
USER QUERY: "I have diabetes, is it safe to exercise in high pollution?"
    │
    ▼
[Step 1] TRANSLATE (if Hindi/Marathi)
    Bhashini API: "मला diabetes आहे, प्रदूषणात exercise करू शकतो का?"
    → "I have diabetes, is it safe to exercise in high pollution?"
    │
    ▼
[Step 2] EMBED QUERY
    BGE-M3 converts query → vector (dense + sparse)
    │
    ▼
[Step 3] HYBRID SEARCH (Qdrant)
    Dense search (semantic meaning) + BM25 (exact terms like "diabetes")
    → Returns Top-10 ICMR guideline chunks
    │
    ▼
[Step 4] ★ RELEVANCE GRADING (CRAG's key addition) ★
    Llama 3.1 8B evaluates: "Do these chunks answer the question?"
    
    Prompt: "Given the question '{query}', rate if this document 
    is relevant: '{chunk}'. Answer YES or NO."
    
    ┌──────────┐     ┌──────────┐
    │ RELEVANT │     │ NOT      │
    │ (YES)    │     │ RELEVANT │
    │          │     │ (NO)     │
    └────┬─────┘     └────┬─────┘
         │                │
         ▼                ▼
    [Continue to    [CORRECTIVE ACTION]
     Step 5]        → Rewrite query
                    → Re-retrieve from Qdrant
                    → OR fallback to Google Search API
                    → Then continue to Step 5
    │
    ▼
[Step 5] BUILD CONTEXT
    System Prompt + User Profile + AQI Data + Top-3 Relevant Chunks + Query
    │
    ▼
[Step 6] GENERATE RESPONSE
    Llama 3.1 8B generates answer grounded in ICMR context
    With [Doc X] citations
    │
    ▼
[Step 7] ADD SAFETY DISCLAIMER
    "I am an AI health assistant, not a doctor. For emergencies, call 112."
    + ICMR source citation
    │
    ▼
[Step 8] TRANSLATE BACK (if Hindi/Marathi)
    Bhashini API: EN → HI/MR
    │
    ▼
USER RESPONSE (in their language, with citation)
```

---

## ASPECT 3: Orchestration Framework

### What is this?
The framework that wires all the pipeline steps together.

### Options Considered
| Framework | Learning Curve | CRAG Support | Integration |
|-----------|---------------|-------------|-------------|
| LangChain LCEL | Low | Good (with branching) | Excellent |
| LangGraph | High (state machines) | Excellent (built for this) | Good |
| Raw Python | None | Manual (write everything) | N/A |
| CrewAI | Medium | Overkill for single pipeline | Limited |

### VERDICT: **LangChain LCEL**
- **Package**: `langchain`, `langchain-community`

### WHY:
1. **CRAG is achievable with LCEL** — LCEL supports `RunnableBranch` for conditional routing (relevant → generate / irrelevant → rewrite). You don't need LangGraph's full state machine
2. **1 week to learn** vs LangGraph's 3+ weeks — critical for 3-month timeline
3. **Shows orchestration skill** for capstone (not "just Python scripts")
4. **Massive documentation** — LangChain has the most tutorials, examples, and community support
5. **Native integration** with Qdrant, BGE-M3, Ollama — all our other components

---

## ASPECT 4: Embedding Model

### What is this?
Converts text (ICMR chunks + user queries) into numerical vectors for similarity search.

### Options Considered
| Model | Dimensions | Languages | Search Types | Medical Fit | Size |
|-------|-----------|-----------|-------------|-------------|------|
| **BGE-M3** | 1024 | 100+ (incl Hindi/Marathi) | Dense + Sparse + Multi-vector | Good | ~2.2GB |
| MedCPT | 768 | English only | Dense only | Excellent | ~400MB |
| all-MiniLM-L6-v2 | 384 | English only | Dense only | Poor | ~80MB |
| PubMedBERT | 768 | English only | Dense only | Good (but dated) | ~400MB |

### VERDICT: **BGE-M3**
- **HuggingFace ID**: `BAAI/bge-m3`

### WHY:
1. **Native Hindi/Marathi** — if a user types "मला डोकं दुखतंय" (Marathi), BGE-M3 can embed it directly and find matching English ICMR docs. This is **zero-shot cross-lingual retrieval** — a huge AIML skill to showcase
2. **Hybrid search (Dense + Sparse)** — medical terms like "Paracetamol 500mg" need exact keyword matching (BM25/sparse), not just semantic similarity. BGE-M3 outputs both in one model
3. **Pre-compute offline** — embed all 5,000 ICMR chunks once on your desktop. At runtime, only embed the user query (~100ms). Zero VRAM pressure during inference
4. **State-of-the-art** — consistently top-performing on MTEB retrieval benchmarks

---

## ASPECT 5: Vector Database

### What is this?
Stores the ICMR guideline embeddings and enables fast similarity search.

### Options Considered
| Database | Hybrid Search | Free Tier | Setup Difficulty | LangChain Support |
|----------|-------------|-----------|-----------------|-------------------|
| **Qdrant** | ✅ Native | Qdrant Cloud (1GB free) or self-hosted | Easy (Docker) | ✅ |
| ChromaDB | ❌ Dense only | Local only | Easiest | ✅ |
| FAISS | ❌ Dense only | Local only | Medium | ✅ |
| Pinecone | ✅ (limited) | 2GB free (serverless) | Easy (cloud) | ✅ |

### VERDICT: **Qdrant**
- **Install**: `docker pull qdrant/qdrant` or Qdrant Cloud free tier

### WHY:
1. **Native hybrid search** — Qdrant supports dense vectors + sparse vectors (BM25) in a single query. This pairs perfectly with BGE-M3 which outputs both
2. **Payload filtering** — filter by metadata (e.g., "only search diabetes guidelines" or "only NCD management chapter")
3. **Free** — self-hosted via Docker or Qdrant Cloud free tier (1GB = ~500K vectors, far more than our ~5,000)
4. **LangChain `QdrantVectorStore`** — plug-and-play integration

---

## ASPECT 6: Re-ranking Strategy

### What is this?
After initial retrieval (top-10), a re-ranker re-scores each chunk against the query for precision.

### Options Considered
| Reranker | Type | Accuracy Boost | VRAM | Latency |
|----------|------|---------------|------|---------|
| BGE-Reranker-v2-m3 | Cross-encoder | +15-20% | ~500MB | ~200ms |
| MedCPT Cross-Encoder | Medical cross-encoder | +20-25% (medical) | ~400MB | ~200ms |
| No reranker | N/A | Baseline | 0 | 0 |

### VERDICT: **BGE-Reranker-v2-m3** (add after MVP)
- **HuggingFace ID**: `BAAI/bge-reranker-v2-m3`

### WHY:
1. **+15-20% retrieval accuracy** — significant for medical precision
2. **Multilingual** — handles Hindi/Marathi queries re-ranking against English docs
3. **~500MB VRAM** — fits alongside 5GB Llama 3.1 8B on a T4 (16GB total)
4. **Strategy**: Build MVP without reranker first (Weeks 1-4). Add reranker in Week 5-6. Benchmark the improvement — this is a great AIML experiment for your capstone report

---

## ASPECT 7: Chunking Strategy

### What is this?
How we split ICMR PDF guidelines into searchable pieces.

### VERDICT: **RecursiveCharTextSplitter + Docling for tables**

| Component | Tool | Why |
|-----------|------|-----|
| **PDF → Text** | **Docling** (`ds4sd/docling`) | Preserves tables and dosage charts that regular PDF extractors destroy |
| **Text → Chunks** | `RecursiveCharacterTextSplitter` | Simple, proven, LangChain native |
| **Chunk size** | 500 tokens | Sweet spot: small enough for precise retrieval, large enough for context |
| **Overlap** | 50 tokens | Prevents cutting mid-sentence |
| **Metadata** | Chapter name, condition, page number | Enables Qdrant payload filtering |

### WHY Docling + RecursiveChar (not just RecursiveChar):
ICMR guidelines have dosage tables like:

| Condition | Drug | Dose |
|-----------|------|------|
| Type 2 Diabetes | Metformin | 500mg twice daily |

Regular PDF extractors turn this into gibberish. Docling uses layout analysis to preserve the table as Markdown. Then RecursiveCharTextSplitter chunks the clean Markdown.

---

## ASPECT 8: Translation Pipeline

### What is this?
How we handle Hindi/Marathi ↔ English translation.

### VERDICT: **Bhashini API**
- **API**: https://bhashini.gov.in/ulca/apis
- **Cost**: Free (Government of India)

### WHY:
1. **0 VRAM** — Bhashini is a cloud API. All VRAM stays for Llama 3.1 8B
2. **Free and government-backed** — aligns with "sovereign" narrative
3. **Supports Hindi + Marathi** — our 3 target languages
4. **Good enough for conversational queries** — users say "mujhe sir dard ho raha hai", not clinical jargon
5. **BGE-M3 handles cross-lingual retrieval** — even if Bhashini is slightly less accurate, BGE-M3 can embed the Hindi query directly and find matching English ICMR docs. Translation is a backup, not the primary retrieval mechanism

### Pipeline:
```
User types in Hindi → Bhashini translates → English query → RAG pipeline
                                                              ↓
                                              English response → Bhashini translates → Hindi response
```

---

## ASPECT 9: Safety Architecture

### What is this?
How we prevent the AI from prescribing, diagnosing, or giving dangerous advice.

### VERDICT: **Semantic Router (Layer 1) + System Prompt Guardrails (Layer 2)**

### WHY this layered approach:
| Layer | Tool | Purpose | Latency |
|-------|------|---------|---------|
| **Layer 1: Semantic Router** | `aurelio-labs/semantic-router` | Ultra-fast intent classification: block prescriptions, detect emergencies, filter non-medical | <100ms |
| **Layer 2: System Prompt** | Strict template in Llama 3.1 | "You MUST NOT prescribe. You MUST cite sources. If unsure, say 'consult your doctor'" | 0ms (part of prompt) |
| **Layer 3: Post-generation** | CRAG relevance grading | Ensures response is grounded in retrieved ICMR context | Already in pipeline |

### WHY NOT NeMo Guardrails?
NeMo is excellent but overkill for a 3-month capstone. Colang has a steep learning curve, and debugging NeMo async Python issues will eat weeks. Semantic Router achieves 90% of the safety with 10% of the complexity.

### Semantic Router Setup:
```python
from semantic_router import Route, RouteLayer

emergency = Route(
    name="emergency",
    utterances=[
        "I am having chest pain", "I can't breathe",
        "mujhe saans nahi aa rahi", "seene mein dard",
        "someone is unconscious", "heart attack"
    ]
)

prescription = Route(
    name="prescription",
    utterances=[
        "prescribe me medicine", "which drug should I take",
        "kaunsi dawai leni chahiye", "give me medication"
    ]
)

routes = RouteLayer(routes=[emergency, prescription])
result = routes(user_query)

if result.name == "emergency":
    return "⚠️ EMERGENCY: Call 112 immediately."
elif result.name == "prescription":
    return "I cannot prescribe medication. Please consult your doctor."
```

---

## ASPECT 10: Context Engineering

### What is this?
The exact prompt template sent to Llama 3.1 8B for every query.

### VERDICT: **XML-structured context template**

```xml
<|begin_of_text|><|start_header_id|>system<|end_header_id|>

You are Aarogya Sathi, an AI health assistant built on ICMR clinical guidelines.

STRICT RULES:
1. Answer ONLY using information from the <documents> section below.
2. Cite your sources as [Doc 1], [Doc 2], etc. at the end of EVERY claim.
3. NEVER prescribe medication, diagnose conditions, or recommend specific drugs.
4. If the documents don't contain enough information, say: "I don't have enough 
   information from ICMR guidelines. Please consult your doctor."
5. Consider the user's health profile and current air quality when advising.
6. End every response with: "⚕️ I am an AI assistant, not a doctor."

<user_profile>
Age: {age} | Gender: {gender}
Conditions: {conditions}
Medications: {medications}
</user_profile>

<air_quality>
City: {city} | AQI: {aqi}
PM2.5: {pm25} μg/m³ | NO2: {no2} ppb | O3: {o3} ppb
Temperature: {temp}°C | Humidity: {humidity}%
</air_quality>

<documents>
[Doc 1]: {chunk_1}
[Doc 2]: {chunk_2}  
[Doc 3]: {chunk_3}
</documents>
<|eot_id|><|start_header_id|>user<|end_header_id|>

{user_query}<|eot_id|><|start_header_id|>assistant<|end_header_id|>
```

### Token Budget (within 128K limit — no constraints!):
| Component | Tokens |
|-----------|--------|
| System prompt + rules | ~250 |
| User profile | ~80 |
| Air quality | ~60 |
| Top-3 chunks (500 tokens each) | ~1,500 |
| User query | ~50 |
| **Total input** | **~1,940** |
| **Available for generation** | **~126,000** |

Llama 3.1 8B's 128K context is massive overkill for our needs — which means we can increase to Top-5 or even Top-10 chunks if needed, with zero constraint.

---

## ASPECT 11: Environmental Data Integration

### What is this?
Real-time AQI + weather data injected into the LLM context.

### VERDICT: **WAQI API + Open-Meteo**

| API | Data | Cost | Update |
|-----|------|------|--------|
| **WAQI API** | PM2.5, PM10, NO2, SO2, O3, CO, AQI, Temp, Humidity | Free (1000 req/day) | Real-time |
| **Open-Meteo** | UV Index, Apparent Temp, Pollen, Rain, 3-day Forecast | Free (10K req/day, no key) | Hourly |

### Google Knowledge Graph (Supplementary):
- **API**: `https://kgsearch.googleapis.com/v1/entities:search`
- **Free**: 100K calls/day
- **Use**: When CRAG detects irrelevant local docs, query Google KG for structured medical entity data (disease descriptions, symptom lists) as fallback context
- **Example**: Query "Diabetes Mellitus Type 2" → returns structured definition, symptoms, related conditions from Google's knowledge base

### How AQI changes the response:
```python
def get_environmental_context(lat, lon):
    # WAQI API
    waqi = requests.get(f"https://api.waqi.info/feed/geo:{lat};{lon}/?token={TOKEN}")
    aqi_data = waqi.json()['data']
    
    # Open-Meteo (no API key needed)
    meteo = requests.get(f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=uv_index,apparent_temperature")
    weather = meteo.json()['current']
    
    return {
        "aqi": aqi_data['aqi'],
        "pm25": aqi_data['iaqi'].get('pm25', {}).get('v', 'N/A'),
        "no2": aqi_data['iaqi'].get('no2', {}).get('v', 'N/A'),
        "uv_index": weather['uv_index'],
        "feels_like": weather['apparent_temperature']
    }
```

---

## ASPECT 12: Inference Engine / Model Serving

### What is this?
How we run Llama 3.1 8B for inference.

### Options Considered
| Engine | Best For | Setup Time | Streaming | VRAM |
|--------|---------|-----------|-----------|------|
| **Ollama** | Dev + Demo | 5 minutes | ✅ | Efficient |
| vLLM | Production, high concurrency | 30+ min | ✅ | More overhead |
| llama.cpp | CPU/edge | 15 min | ✅ | Most efficient |

### VERDICT: **Ollama**
- **Install**: `curl -fsSL https://ollama.com/install.sh | sh`
- **Run**: `ollama run llama3.1:8b-instruct-q4_K_M`

### WHY:
1. **5 minutes to set up** — `ollama pull llama3.1` and done. No pip dependency hell
2. **Built-in API server** — `/api/chat` endpoint with streaming. No FastAPI needed for the LLM layer
3. **Memory efficient** — automatic quantization and memory management
4. **Works everywhere** — Colab, local laptop, Linux server
5. **LangChain `ChatOllama`** — native integration, 3 lines of code:
```python
from langchain_ollama import ChatOllama
llm = ChatOllama(model="llama3.1:8b-instruct-q4_K_M", temperature=0)
```

---

## ASPECT 13: Mobile App Architecture

### What is this?
How the Flutter mobile app communicates with the AI backend.

### VERDICT: **Flutter + FastAPI + SSE (Server-Sent Events)**

| Component | Technology | Why |
|-----------|-----------|-----|
| **Frontend** | Flutter (Android) | Cross-platform, `sqflite` for offline profile |
| **API Server** | FastAPI | Async Python, easy SSE support |
| **Communication** | SSE (Server-Sent Events) | One-way streaming (server → client) = perfect for LLM text generation |
| **Local DB** | SQLite via `sqflite` | Health profile stored on-device (DPDP compliant) |

### WHY SSE over WebSocket:
- WebSocket is bidirectional — overkill for "user sends query, server streams response"
- SSE is simpler, works through HTTP (no special protocol), auto-reconnects
- FastAPI's `StreamingResponse` + Flutter's `EventSource` = simple implementation

### Architecture:
```
Flutter App (Android)
    │
    ├── SQLite (local health profile, medication schedule)
    │
    ├── GET /api/aqi?lat=X&lon=Y → FastAPI → WAQI + Open-Meteo
    │
    └── POST /api/chat (SSE stream) → FastAPI → 
            Semantic Router (safety check)
            → Bhashini (translate if needed)
            → BGE-M3 (embed query)
            → Qdrant (hybrid search)
            → CRAG relevance check
            → Ollama/Llama 3.1 (generate)
            → Bhashini (translate back)
            → Stream tokens via SSE
```

---

## ASPECT 14: Evaluation Framework

### What is this?
How we prove the system works for capstone submission.

### VERDICT: **RAGAS + LLM-as-Judge (Gemini via free Vertex AI credits)**

| Metric | Tool | What It Measures | Target |
|--------|------|-----------------|--------|
| **Faithfulness** | RAGAS | Is the answer grounded in retrieved docs? | ≥0.80 |
| **Answer Relevancy** | RAGAS | Does the answer address the question? | ≥0.80 |
| **Context Precision** | RAGAS | Are the retrieved docs relevant? | ≥0.75 |
| **Hallucination Rate** | LLM-as-Judge (Gemini) | % of claims NOT in context | ≤15% |
| **Safety Compliance** | Custom test suite | Does it block emergencies/prescriptions? | 100% |
| **Translation Quality** | Manual review (50 samples) | Are Hindi/Marathi translations accurate? | Qualitative |

### Gold Standard Test Set:
- Manually create **100 medical questions** from ICMR guidelines
- Each has a verified correct answer + the exact ICMR source
- Categories: Diabetes (20), Hypertension (20), COPD/Asthma (20), AQI-related (20), General health (20)
- Use **Gemini API** (free Vertex AI \$300 credits) as impartial judge

### WHY RAGAS:
- Industry standard for RAG evaluation
- Measures retrieval quality AND generation quality separately
- Shows professors you understand evaluation methodology (key AIML skill)

---

## ASPECT 15: Fine-tuning Strategy

### VERDICT: **No fine-tuning for MVP. Optional QLoRA experiment for capstone report.**

### WHY skip fine-tuning:
1. **RAG > fine-tuning for medical accuracy** — RAG grounds answers in real ICMR docs. Fine-tuning bakes knowledge into weights (which can hallucinate)
2. **Time constraint** — QLoRA setup + data prep + training + evaluation = 3-4 weeks. That's 25% of your timeline
3. **Data constraint** — you don't have a medical Q&A dataset based on ICMR guidelines

### Optional experiment (if time allows, Weeks 10-11):
- QLoRA fine-tune on 500 synthetic ICMR Q&As (generated via Gemini API)
- Compare: base model + RAG vs fine-tuned model + RAG
- Document the delta in your capstone report — whether it helps or not, it's valid research

---

## COMPLETE TECH STACK SUMMARY

| # | Component | Technology | Why (one line) |
|---|-----------|-----------|----------------|
| 1 | **LLM** | Llama 3.1 8B Instruct (Q4) | 128K context, best instruction-following, industry standard |
| 2 | **RAG Architecture** | CRAG (Corrective RAG) | Catches bad retrievals, Google Search fallback |
| 3 | **Orchestration** | LangChain LCEL | Simple, CRAG-compatible, massive ecosystem |
| 4 | **Embeddings** | BGE-M3 | Multilingual + hybrid (dense+sparse) in one model |
| 5 | **Vector DB** | Qdrant | Native hybrid search, free, easy |
| 6 | **Reranker** | BGE-Reranker-v2-m3 (Phase 2) | +15-20% retrieval accuracy |
| 7 | **Chunking** | Docling + RecursiveCharTextSplitter | Preserves tables + simple splitting |
| 8 | **Translation** | Bhashini API | Free, 0 VRAM, government-backed |
| 9 | **Safety** | Semantic Router + System Prompt | Fast intent blocking + prompt guardrails |
| 10 | **Context** | XML-structured template | Clean separation of profile/AQI/docs/query |
| 11 | **AQI/Weather** | WAQI + Open-Meteo + Google KG | 15 env parameters, free, real-time |
| 12 | **Inference** | Ollama | 5-min setup, streaming, memory efficient |
| 13 | **Mobile** | Flutter + FastAPI + SSE | Cross-platform, streaming chat, offline profile |
| 14 | **Evaluation** | RAGAS + Gemini (judge) | Industry standard RAG evaluation |
| 15 | **Fine-tuning** | Skip (optional QLoRA experiment) | RAG > fine-tuning for medical accuracy |

### VRAM Budget (Colab T4 = 16GB):
| Component | VRAM |
|-----------|------|
| Llama 3.1 8B (Q4_K_M via Ollama) | ~5GB |
| BGE-M3 (query embedding only) | ~1GB (or CPU) |
| BGE-Reranker (Phase 2) | ~500MB |
| **Total** | **~6.5GB / 16GB** ✅ |

---

## 12-WEEK IMPLEMENTATION TIMELINE

| Phase | Weeks | Owner | Deliverable |
|-------|-------|-------|-------------|
| **1. Core RAG** | W1-2 | Jayesh | ICMR PDFs → Docling → BGE-M3 → Qdrant. Ollama + Llama 3.1. Basic Naive RAG working. |
| **2. CRAG Pipeline** | W3-4 | Jayesh + Abhijit | LCEL pipeline with relevance grading. Google Search fallback. Context template. |
| **3. APIs & Translation** | W3-5 | Abhijit | WAQI + Open-Meteo integration. Bhashini API pipeline. Google KG supplementary. |
| **4. Safety** | W5-6 | Abhijit | Semantic Router setup. Emergency detection. Prescription blocking. |
| **5. Mobile App** | W3-8 | Ritesh | Flutter app. Health profile UI. Chat with SSE streaming. AQI display. |
| **6. Reranker** | W6-7 | Jayesh | BGE-Reranker integration. Benchmark improvement. |
| **7. Integration** | W8-9 | All | Flutter ↔ FastAPI ↔ RAG pipeline end-to-end. |
| **8. Evaluation** | W9-11 | Jayesh + Abhijit | 100 gold Q&As. RAGAS metrics. Safety compliance test. |
| **9. Polish & Docs** | W11-12 | All | Final report. Demo video. Presentation. Edge-case fixes. |

---

## AIML SKILLS DEMONSTRATED (12 Skills)

| # | Skill | Where |
|---|-------|-------|
| 1 | LLM Deployment & Quantization | Llama 3.1 8B Q4 via Ollama |
| 2 | RAG Architecture (Corrective RAG) | CRAG pipeline with relevance grading |
| 3 | Vector Database Engineering | Qdrant hybrid search (dense+sparse) |
| 4 | Multilingual Embedding | BGE-M3 cross-lingual retrieval |
| 5 | Cross-Encoder Re-ranking | BGE-Reranker-v2-m3 |
| 6 | Pipeline Orchestration | LangChain LCEL with conditional routing |
| 7 | AI Safety Engineering | Semantic Router intent classification |
| 8 | Prompt Engineering | XML-structured medical context template |
| 9 | Real-time API Integration | WAQI + Open-Meteo + Google KG |
| 10 | Evaluation Methodology | RAGAS + LLM-as-Judge |
| 11 | Document Processing | Docling PDF → Markdown preservation |
| 12 | Full-Stack AI App | Flutter + FastAPI + SSE streaming |
