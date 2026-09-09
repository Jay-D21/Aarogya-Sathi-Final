# Aarogya Sathi — Developer Playbooks

> Each dev has a standalone playbook below. Work in parallel.
> ⛔ **BLOCKED BY** tags tell you when you need another dev's output before continuing.

---
---

# 🧠 DEV 1: JAYESH PATIL — RAG & LLM Engineer

> You own: OKF Knowledge Bundle, OKF Navigator, CRAG Pipeline, Qdrant Fallback, Ollama/Llama 3.1, Evaluation

---

## PHASE 1: LLM Setup

### Step 1.1 — Install Ollama
```bash
# Linux/Colab
curl -fsSL https://ollama.com/install.sh | sh

# Windows
# Download from https://ollama.com/download/windows
```

### Step 1.2 — Pull Llama 3.1 8B
```bash
ollama pull llama3.1:8b-instruct-q4_K_M
```

### Step 1.3 — Test it works
```bash
ollama run llama3.1:8b-instruct-q4_K_M "What is Type 2 Diabetes?"
```
✅ **Done when**: You get a coherent medical response.

### Step 1.4 — Test the API server
```bash
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.1:8b-instruct-q4_K_M",
  "messages": [{"role": "user", "content": "What is hypertension?"}],
  "stream": false
}'
```
✅ **Done when**: JSON response with medical answer.

---

## PHASE 2: OKF Knowledge Bundle

> This is your biggest job. You are converting ICMR PDF guidelines into Google's Open Knowledge Format.

### Step 2.1 — Create bundle skeleton
```
mkdir icmr-knowledge-bundle
mkdir icmr-knowledge-bundle/conditions
mkdir icmr-knowledge-bundle/drugs
mkdir icmr-knowledge-bundle/lifestyle
mkdir icmr-knowledge-bundle/environmental
mkdir icmr-knowledge-bundle/emergency
```

### Step 2.2 — Create root `index.md`
File: `icmr-knowledge-bundle/index.md`
```markdown
---
type: Index
title: ICMR Clinical Guidelines Knowledge Base
description: Structured medical knowledge from ICMR guidelines for NCD management in India.
---

# ICMR Clinical Guidelines

## Categories
- [Conditions](conditions/index.md) — 15 NCD conditions (diabetes, hypertension, COPD, etc.)
- [Drugs](drugs/index.md) — 20 commonly prescribed drugs (metformin, amlodipine, etc.)
- [Lifestyle](lifestyle/index.md) — 8 lifestyle modification guides
- [Environmental](environmental/index.md) — 5 AQI/weather health impact guides
- [Emergency](emergency/index.md) — 5 emergency triage protocols
```

### Step 2.3 — Create index.md for each subfolder
Each subfolder needs its own `index.md` listing all files in it. Example for `conditions/index.md`:
```markdown
---
type: Index
title: NCD Conditions
description: Clinical management guidelines for non-communicable diseases.
---
# NCD Conditions
- [Type 2 Diabetes Mellitus](diabetes-type2.md)
- [Hypertension](hypertension.md)
- [COPD](copd.md)
- [Asthma](asthma.md)
- [Coronary Artery Disease](coronary-artery-disease.md)
- [Chronic Kidney Disease](chronic-kidney-disease.md)
- [Obesity](obesity.md)
- [Dyslipidemia](dyslipidemia.md)
- [Stroke](stroke.md)
- [Peripheral Artery Disease](peripheral-artery-disease.md)
- [Heart Failure](heart-failure.md)
- [Thyroid Disorders](thyroid-disorders.md)
- [Osteoporosis](osteoporosis.md)
- [Depression (comorbid with NCD)](depression-comorbid.md)
- [Anemia (Iron Deficiency)](anemia.md)
```

### Step 2.4 — Write condition files (THE MAIN WORK)
For each condition, create a `.md` file following this exact template:

File: `icmr-knowledge-bundle/conditions/diabetes-type2.md`
```markdown
---
type: Clinical Guideline
title: Type 2 Diabetes Mellitus — ICMR Management Protocol
description: Complete management guideline for T2DM based on ICMR 2024 standards.
tags: [diabetes, ncd, metabolic, chronic]
sources:
  - id: icmr-diabetes-2024
    resource: https://main.icmr.nic.in/guidelines/diabetes
    title: ICMR Guidelines for Management of Type 2 Diabetes 2024
    author: process:icmr-committee
    last_modified: 2024-03-15T00:00:00Z
generated:
  by: human:jayesh-patil
  at: 2026-09-10T10:00:00Z
---

# Type 2 Diabetes Mellitus

## Definition
A chronic metabolic disorder characterized by persistent hyperglycemia
resulting from defects in insulin secretion, insulin action, or both.

## Diagnostic Criteria
| Test | Normal | Pre-diabetes | Diabetes |
|------|--------|-------------|----------|
| Fasting Plasma Glucose | <100 mg/dL | 100-125 mg/dL | ≥126 mg/dL |
| 2-hr OGTT | <140 mg/dL | 140-199 mg/dL | ≥200 mg/dL |
| HbA1c | <5.7% | 5.7-6.4% | ≥6.5% |

## Risk Factors
- Family history of diabetes
- BMI >25 kg/m²
- Physical inactivity
- High AQI exposure — See [AQI Health Impact](../environmental/aqi-health-impact.md)
- Age >45 years

## First-Line Treatment
- Lifestyle modification — See [Diet for Diabetes](../lifestyle/diet-diabetes.md)
- [Metformin](../drugs/metformin.md) 500mg twice daily, titrate to 1000mg

## Monitoring
- HbA1c every 3 months
- Fasting glucose daily (self-monitoring)
- Annual eye, foot exam, kidney function

## When to Refer
- HbA1c >9% despite dual therapy
- Recurrent hypoglycemia — See [Hypoglycemia Emergency](../emergency/hypoglycemia.md)
- Diabetic ketoacidosis symptoms

## Environmental Considerations
High AQI (>150) increases insulin resistance. Advise indoor exercise
when AQI is unhealthy. See [Pollution & Respiratory](../environmental/pollution-respiratory.md).
```

### Step 2.5 — Write drug files
Same pattern for each drug. Template:
```markdown
---
type: Drug Reference
title: Metformin
description: First-line oral antidiabetic for T2DM.
tags: [antidiabetic, oral, biguanide]
sources:
  - id: icmr-diabetes-2024
    resource: https://main.icmr.nic.in/guidelines/diabetes
---
# Metformin
## Class
Biguanide (oral antidiabetic)
## Indication
First-line for [Type 2 Diabetes](../conditions/diabetes-type2.md)
## Dosage
- Start: 500mg once daily with meals
- Target: 500mg-1000mg twice daily
- Max: 2550mg/day
## Contraindications
- eGFR <30 mL/min
- Hepatic impairment
- Active alcoholism
## Side Effects
- GI upset (nausea, diarrhea) — usually resolves in 2 weeks
- Lactic acidosis (rare, serious)
## Interactions
- Alcohol: increases lactic acidosis risk
- Contrast dye: hold 48 hours before/after
```

### Step 2.6 — Write environmental, lifestyle, emergency files
Same OKF pattern. Cross-link everything. Every file should have at least 2-3 markdown hyperlinks to related concept files.

### Step 2.7 — Validate the bundle
```bash
# Check all markdown links resolve
cd icmr-knowledge-bundle
# Simple validation: find all links and check files exist
grep -roh '\](\.\.?/[^)]*\.md)' . | sort -u | while read link; do
  path=$(echo "$link" | sed 's/\](\(.*\))/\1/')
  if [ ! -f "$path" ]; then echo "BROKEN: $path"; fi
done
```
✅ **Done when**: 50+ concept files, zero broken links, every file has valid YAML frontmatter.

---

## PHASE 3: OKF Navigator

### Step 3.1 — Create the Navigator class
File: `backend/rag/okf_navigator.py`
```python
import os
import re
import yaml

class OKFNavigator:
    """Navigates an OKF knowledge bundle using LLM-guided file traversal."""

    def __init__(self, bundle_path: str, llm):
        self.bundle_path = bundle_path
        self.llm = llm
        self.visited = set()
        self.collected = []

    def navigate(self, query: str, max_depth: int = 2) -> list[dict]:
        """Entry point: find relevant OKF concept files for a query."""
        self.visited.clear()
        self.collected.clear()

        # Step 1: Read root index
        root_index = self._read_file("index.md")

        # Step 2: Ask LLM which files are relevant
        relevant = self._pick_files(query, root_index)

        # Step 3: Read each file, follow links up to max_depth
        for file_path in relevant:
            self._traverse(file_path, query, depth=0, max_depth=max_depth)

        return self.collected

    def _traverse(self, file_path: str, query: str, depth: int, max_depth: int):
        if file_path in self.visited or depth > max_depth:
            return
        self.visited.add(file_path)

        content = self._read_file(file_path)
        if not content:
            return

        # Parse YAML frontmatter
        meta = self._parse_frontmatter(content)

        self.collected.append({
            "path": file_path,
            "title": meta.get("title", file_path),
            "type": meta.get("type", "Unknown"),
            "content": content,
            "depth": depth
        })

        # Follow hyperlinks in the document
        if depth < max_depth:
            links = self._extract_links(content, file_path)
            for link in links:
                self._traverse(link, query, depth + 1, max_depth)

    def _pick_files(self, query: str, index_content: str) -> list[str]:
        """LLM decides which concept files to read."""
        prompt = f"""You are navigating a medical knowledge base. Given this index:

{index_content}

User's health question: "{query}"

Which files should I read to answer this question? Return ONLY file paths 
relative to the bundle root, one per line. Pick 1-3 most relevant files.
Do NOT include index.md files. Example:
conditions/diabetes-type2.md
drugs/metformin.md"""

        response = self.llm.invoke(prompt)
        paths = []
        for line in response.content.strip().split("\n"):
            line = line.strip().lstrip("- ")
            if line.endswith(".md") and not line.endswith("index.md"):
                paths.append(line)
        return paths[:3]  # Cap at 3 files

    def _extract_links(self, content: str, current_file: str) -> list[str]:
        """Extract relative markdown links and resolve to bundle paths."""
        raw_links = re.findall(r'\[.*?\]\((\.\.?/[^)]+\.md)\)', content)
        current_dir = os.path.dirname(current_file)
        resolved = []
        for link in raw_links:
            full = os.path.normpath(os.path.join(current_dir, link))
            full = full.replace("\\", "/")
            resolved.append(full)
        return resolved

    def _read_file(self, rel_path: str) -> str | None:
        full = os.path.join(self.bundle_path, rel_path)
        if os.path.exists(full):
            with open(full, encoding="utf-8") as f:
                return f.read()
        return None

    def _parse_frontmatter(self, content: str) -> dict:
        if content.startswith("---"):
            parts = content.split("---", 2)
            if len(parts) >= 3:
                try:
                    return yaml.safe_load(parts[1]) or {}
                except yaml.YAMLError:
                    return {}
        return {}
```

### Step 3.2 — Test the Navigator
```python
from langchain_ollama import ChatOllama

llm = ChatOllama(model="llama3.1:8b-instruct-q4_K_M", temperature=0)
nav = OKFNavigator("./icmr-knowledge-bundle", llm)

results = nav.navigate("I have diabetes, is it safe to exercise in high pollution?")
for r in results:
    print(f"[{r['type']}] {r['title']} (depth={r['depth']})")
```
✅ **Done when**: Returns diabetes-type2.md + aqi-health-impact.md + exercise-guidelines.md

---

## PHASE 4: CRAG Pipeline

> ⛔ **BLOCKED BY Abhijit Phase 1** — You need `backend/main.py` and FastAPI structure to exist.
> But you can build the pipeline as a standalone Python module first.

### Step 4.1 — Install dependencies
File: `backend/requirements.txt`
```
langchain>=0.3.0
langchain-ollama>=0.2.0
langchain-community>=0.3.0
qdrant-client>=1.12.0
FlagEmbedding>=1.2.0
pyyaml>=6.0
httpx>=0.27.0
ragas>=0.2.0
fastapi>=0.115.0
uvicorn>=0.30.0
sse-starlette>=2.0.0
semantic-router>=0.1.0
```
```bash
pip install -r requirements.txt
```

### Step 4.2 — Build the relevance grader
File: `backend/rag/grader.py`
```python
from langchain_ollama import ChatOllama

GRADE_PROMPT = """You are a medical document relevance grader.
Given a user question and a retrieved document, decide if the document 
contains information relevant to answering the question.

User Question: {question}

Retrieved Document:
{document}

Answer with ONLY "yes" or "no"."""

class RelevanceGrader:
    def __init__(self, llm=None):
        self.llm = llm or ChatOllama(
            model="llama3.1:8b-instruct-q4_K_M", temperature=0
        )

    def grade(self, question: str, document: str) -> bool:
        prompt = GRADE_PROMPT.format(question=question, document=document)
        response = self.llm.invoke(prompt)
        return "yes" in response.content.lower()
```

### Step 4.3 — Build the CRAG pipeline
File: `backend/rag/pipeline.py`
```python
from langchain_ollama import ChatOllama
from backend.rag.okf_navigator import OKFNavigator
from backend.rag.grader import RelevanceGrader

SYSTEM_PROMPT = """You are Aarogya Sathi, an AI health assistant built on ICMR clinical guidelines.

STRICT RULES:
1. Answer ONLY using information from the <documents> section below.
2. Cite your sources as [Doc 1], [Doc 2] at the end of EVERY claim.
3. NEVER prescribe medication, diagnose, or recommend specific drugs.
4. If documents don't have enough info, say: "I don't have enough 
   information from ICMR guidelines. Please consult your doctor."
5. Consider the user's health profile and current air quality.
6. End every response with: "⚕️ I am an AI assistant, not a doctor."

<user_profile>
Age: {age} | Gender: {gender}
Conditions: {conditions}
Medications: {medications}
</user_profile>

<air_quality>
City: {city} | AQI: {aqi} | PM2.5: {pm25} μg/m³
Temperature: {temp}°C | Humidity: {humidity}%
</air_quality>

<wearable_data>
Steps today: {steps} | Calories burned: {calories}
Heart Rate: {hr} bpm | Resting HR: {resting_hr} bpm | SpO2: {spo2}%
Blood Glucose: {glucose} mg/dL | BP: {bp_sys}/{bp_dia} mmHg
Sleep: {sleep_hours} hrs (Deep: {deep}h, REM: {rem}h, Light: {light}h)
Weight: {weight} kg | Body Temp: {body_temp}°C
</wearable_data>

<documents>
{documents}
</documents>"""

class CRAGPipeline:
    def __init__(self, bundle_path: str):
        self.llm = ChatOllama(
            model="llama3.1:8b-instruct-q4_K_M", temperature=0.1
        )
        self.navigator = OKFNavigator(bundle_path, self.llm)
        self.grader = RelevanceGrader(self.llm)

    async def run(self, query: str, profile: dict, aqi_data: dict):
        """Full CRAG pipeline. Yields tokens for streaming."""
        
        # Step 1: OKF Navigate (primary retrieval)
        docs = self.navigator.navigate(query, max_depth=2)

        # Step 2: Grade relevance (CRAG check)
        relevant_docs = []
        for doc in docs:
            if self.grader.grade(query, doc["content"][:2000]):
                relevant_docs.append(doc)

        # Step 3: If no relevant docs, fallback to Qdrant
        if not relevant_docs:
            relevant_docs = self._qdrant_fallback(query)

        # Step 4: Build context
        doc_text = ""
        for i, doc in enumerate(relevant_docs[:3], 1):
            doc_text += f"\n[Doc {i}] ({doc['title']}):\n{doc['content'][:1500]}\n"

        system = SYSTEM_PROMPT.format(
            age=profile.get("age", "Unknown"),
            gender=profile.get("gender", "Unknown"),
            conditions=", ".join(profile.get("conditions", [])),
            medications=", ".join(profile.get("medications", [])),
            city=aqi_data.get("city", "Unknown"),
            aqi=aqi_data.get("aqi", "N/A"),
            pm25=aqi_data.get("pm25", "N/A"),
            temp=aqi_data.get("temp", "N/A"),
            humidity=aqi_data.get("humidity", "N/A"),
            documents=doc_text
        )

        # Step 5: Stream LLM response
        messages = [
            {"role": "system", "content": system},
            {"role": "user", "content": query}
        ]

        async for chunk in self.llm.astream(messages):
            if chunk.content:
                yield chunk.content

        # Step 6: Append disclaimer
        yield "\n\n⚕️ I am an AI health assistant, not a doctor. For emergencies, call 112."

    def _qdrant_fallback(self, query: str) -> list[dict]:
        """Fallback: BGE-M3 + Qdrant vector search."""
        # Import only when needed (saves memory if OKF works)
        from backend.rag.vector_store import search_qdrant
        return search_qdrant(query, top_k=3)
```

### Step 4.4 — Build Qdrant fallback
File: `backend/rag/vector_store.py`
```python
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct
from FlagEmbedding import BGEM3FlagModel

# Initialize once globally
embedder = None
client = None

def init_qdrant(collection_name="icmr_fallback"):
    global embedder, client
    embedder = BGEM3FlagModel("BAAI/bge-m3", use_fp16=True)
    client = QdrantClient(path="./qdrant_data")  # Local file-based

    if not client.collection_exists(collection_name):
        client.create_collection(
            collection_name=collection_name,
            vectors_config=VectorParams(size=1024, distance=Distance.COSINE)
        )

def index_okf_bundle(bundle_path: str, collection_name="icmr_fallback"):
    """One-time: embed all OKF files into Qdrant as fallback."""
    import os, glob
    init_qdrant(collection_name)
    
    md_files = glob.glob(os.path.join(bundle_path, "**/*.md"), recursive=True)
    points = []
    
    for i, fpath in enumerate(md_files):
        if "index.md" in fpath:
            continue
        with open(fpath, encoding="utf-8") as f:
            content = f.read()
        
        embedding = embedder.encode([content[:2000]])["dense_vecs"][0]
        points.append(PointStruct(
            id=i,
            vector=embedding.tolist(),
            payload={"path": fpath, "content": content[:3000]}
        ))
    
    client.upsert(collection_name=collection_name, points=points)
    print(f"Indexed {len(points)} OKF files into Qdrant")

def search_qdrant(query: str, top_k=3, collection_name="icmr_fallback"):
    """Search Qdrant for relevant documents."""
    if embedder is None:
        init_qdrant(collection_name)
    
    q_vec = embedder.encode([query])["dense_vecs"][0]
    results = client.search(
        collection_name=collection_name,
        query_vector=q_vec.tolist(),
        limit=top_k
    )
    return [{"title": r.payload["path"], "content": r.payload["content"], "depth": 0} for r in results]
```

### Step 4.5 — Index the OKF bundle into Qdrant (run once)
```python
from backend.rag.vector_store import index_okf_bundle
index_okf_bundle("./icmr-knowledge-bundle")
```
✅ **Done when**: `pipeline.run("diabetes diet", profile, aqi)` returns streaming cited response.

---

## PHASE 5: Evaluation

> ⛔ **BLOCKED BY Abhijit Phase 4** — Full pipeline with safety + translation must work E2E before evaluation.

### Step 5.1 — Create 100 gold-standard questions
File: `evaluation/gold_standard.json`
```json
[
  {
    "id": 1,
    "category": "diabetes",
    "question": "What is the first-line treatment for Type 2 Diabetes?",
    "expected_answer": "Lifestyle modification and Metformin 500mg twice daily",
    "source_file": "conditions/diabetes-type2.md",
    "language": "en"
  },
  {
    "id": 2,
    "category": "diabetes",
    "question": "What HbA1c level indicates diabetes?",
    "expected_answer": "HbA1c ≥6.5%",
    "source_file": "conditions/diabetes-type2.md",
    "language": "en"
  }
]
```
Create 20 per category: diabetes, hypertension, respiratory (COPD+asthma), environmental (AQI), general health.

### Step 5.2 — Run RAGAS evaluation
File: `evaluation/run_ragas.py`
```python
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_precision
from datasets import Dataset

# Load gold standard, run pipeline on each question, collect results
# Then: evaluate(dataset, metrics=[faithfulness, answer_relevancy, context_precision])
```
✅ **Done when**: RAGAS report with faithfulness ≥0.80, relevancy ≥0.80, precision ≥0.75.

---
---

# ⚙️ DEV 2: ABHIJIT PATIL — Backend & Integration Engineer

> You own: FastAPI server, Bhashini translation, Semantic Router safety, WAQI/Open-Meteo AQI, Context engineering

---

## PHASE 1: FastAPI Skeleton

### Step 1.1 — Create project structure
```
mkdir backend
mkdir backend/api
mkdir backend/translation
mkdir backend/safety
mkdir backend/context
touch backend/__init__.py
touch backend/api/__init__.py
touch backend/translation/__init__.py
touch backend/safety/__init__.py
touch backend/context/__init__.py
```

### Step 1.2 — Create main.py
File: `backend/main.py`
```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Aarogya Sathi API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Flutter app
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/health")
async def health_check():
    return {"success": True, "data": {"status": "ok", "model": "llama3.1-8b"}}

# Import routes after app creation
from backend.api.routes import router
app.include_router(router, prefix="/api")
```

### Step 1.3 — Create Pydantic models
File: `backend/api/models.py`
```python
from pydantic import BaseModel

class UserProfile(BaseModel):
    age: int | None = None
    gender: str | None = None
    conditions: list[str] = []
    medications: list[str] = []

class ChatRequest(BaseModel):
    query: str
    language: str = "en"  # en, hi, mr
    profile: UserProfile = UserProfile()
    lat: float | None = None
    lon: float | None = None

class AQIResponse(BaseModel):
    success: bool
    data: dict
```

### Step 1.4 — Run and test
```bash
cd backend
uvicorn main:app --reload --port 8000
```
```bash
curl http://localhost:8000/api/health
# Should return: {"success": true, "data": {"status": "ok"}}
```
✅ **Done when**: FastAPI running on port 8000, health endpoint works.

---

## PHASE 2: Translation (Bhashini API)

### Step 2.1 — Register for Bhashini
1. Go to https://bhashini.gov.in/ulca
2. Sign up → get API key and User ID
3. Store in `.env` file (NEVER commit this):
```
BHASHINI_USER_ID=your_user_id
BHASHINI_API_KEY=your_api_key
BHASHINI_PIPELINE_URL=https://dhruva-api.bhashini.gov.in/services/inference/pipeline
```

### Step 2.2 — Build Bhashini wrapper
File: `backend/translation/bhashini.py`
```python
import os
import httpx
from dotenv import load_dotenv

load_dotenv()

BHASHINI_URL = os.getenv("BHASHINI_PIPELINE_URL")
HEADERS = {
    "Content-Type": "application/json",
    "userID": os.getenv("BHASHINI_USER_ID"),
    "ulcaApiKey": os.getenv("BHASHINI_API_KEY"),
}

# Bhashini model IDs for translation
TRANSLATION_MODELS = {
    ("hi", "en"): "ai4bharat/indictrans-v2-all-gpu--t4",
    ("en", "hi"): "ai4bharat/indictrans-v2-all-gpu--t4",
    ("mr", "en"): "ai4bharat/indictrans-v2-all-gpu--t4",
    ("en", "mr"): "ai4bharat/indictrans-v2-all-gpu--t4",
}

async def translate(text: str, source_lang: str, target_lang: str) -> str:
    """Translate text using Bhashini API."""
    if source_lang == target_lang:
        return text

    payload = {
        "pipelineTasks": [{
            "taskType": "translation",
            "config": {
                "language": {
                    "sourceLanguage": source_lang,
                    "targetLanguage": target_lang
                },
                "serviceId": TRANSLATION_MODELS.get((source_lang, target_lang))
            }
        }],
        "inputData": {
            "input": [{"source": text}]
        }
    }

    async with httpx.AsyncClient(timeout=30) as client:
        response = await client.post(BHASHINI_URL, json=payload, headers=HEADERS)
        response.raise_for_status()
        result = response.json()
        return result["pipelineResponse"][0]["output"][0]["target"]
```

### Step 2.3 — Test translation
```python
import asyncio
from backend.translation.bhashini import translate

async def test():
    result = await translate("मला ताप आहे", "mr", "en")
    print(result)  # Should print: "I have a fever"

    result = await translate("I have diabetes", "en", "hi")
    print(result)  # Should print: "मुझे मधुमेह है"

asyncio.run(test())
```
✅ **Done when**: HI↔EN and MR↔EN both work with 10 medical phrases.

---

## PHASE 3: Safety Layer (Semantic Router)

### Step 3.1 — Install semantic-router
```bash
pip install semantic-router
```

### Step 3.2 — Define safety routes
File: `backend/safety/routes.py`
```python
from semantic_router import Route

emergency = Route(
    name="emergency",
    utterances=[
        "I am having a heart attack",
        "I can't breathe",
        "someone is unconscious",
        "chest pain radiating to arm",
        "severe allergic reaction",
        "I think I'm having a stroke",
        "profuse bleeding won't stop",
        "मुझे सांस नहीं आ रही",
        "सीने में दर्द हो रहा है",
        "मला छातीत दुखतंय",
        "मला श्वास घेता येत नाही",
        "कोई बेहोश हो गया है",
        "बहुत खून बह रहा है",
        "heart attack ho raha hai",
        "ambulance bulao",
        "seene mein bahut dard",
        "sans nahi aa rahi",
    ]
)

prescription = Route(
    name="prescription",
    utterances=[
        "prescribe me medicine",
        "which drug should I take",
        "give me medication for diabetes",
        "what medicine should I take for headache",
        "write me a prescription",
        "कौनसी दवाई लेनी चाहिए",
        "मुझे दवाई लिख दो",
        "कोणती गोळी घ्यावी",
        "मला औषध सांगा",
        "dawai batao",
        "tablet konsi leni hai",
        "medicine likh do",
    ]
)

non_medical = Route(
    name="non_medical",
    utterances=[
        "tell me a joke",
        "what's the weather",
        "who is the prime minister",
        "help me with my homework",
        "write me an essay",
        "play a game with me",
        "what's the stock price",
        "मुझे एक कहानी सुनाओ",
        "cricket ka score kya hai",
    ]
)
```

### Step 3.3 — Build the router
File: `backend/safety/router.py`
```python
from semantic_router import RouteLayer
from backend.safety.routes import emergency, prescription, non_medical

EMERGENCY_RESPONSE = (
    "🚨 **EMERGENCY DETECTED** 🚨\n\n"
    "Please call **112** (India Emergency) immediately.\n"
    "If someone is unconscious, start CPR.\n"
    "Do NOT wait for AI advice in emergencies.\n\n"
    "📞 Emergency: 112\n"
    "🏥 Ambulance: 102\n"
    "☠️ Poison Control: 1800-11-6117"
)

PRESCRIPTION_RESPONSE = (
    "I cannot prescribe medication or recommend specific drugs. "
    "Only a licensed doctor can prescribe after examining you.\n\n"
    "Please consult your nearest healthcare provider.\n\n"
    "⚕️ I am an AI health assistant, not a doctor."
)

NON_MEDICAL_RESPONSE = (
    "I'm Aarogya Sathi, a health assistant. I can only help with "
    "health-related questions based on ICMR guidelines.\n\n"
    "Try asking me about:\n"
    "- Managing diabetes, hypertension, or asthma\n"
    "- Exercise advice based on air quality\n"
    "- Diet recommendations for your conditions"
)

# Initialize router (loads embedding model once)
router = RouteLayer(routes=[emergency, prescription, non_medical])

def check_safety(query: str) -> tuple[bool, str | None]:
    """Returns (is_safe, blocked_response). If is_safe=True, continue pipeline."""
    result = router(query)

    if result.name == "emergency":
        return False, EMERGENCY_RESPONSE
    elif result.name == "prescription":
        return False, PRESCRIPTION_RESPONSE
    elif result.name == "non_medical":
        return False, NON_MEDICAL_RESPONSE
    else:
        return True, None  # Safe — continue to RAG pipeline
```

### Step 3.4 — Test safety
```python
from backend.safety.router import check_safety

# Should block:
assert check_safety("I'm having chest pain")[0] == False
assert check_safety("prescribe me medicine")[0] == False
assert check_safety("tell me a joke")[0] == False

# Should pass:
assert check_safety("What diet is good for diabetes?")[0] == True
assert check_safety("Is walking good for hypertension?")[0] == True
print("All safety tests passed ✅")
```
✅ **Done when**: 95%+ accuracy on 50 test queries (20 emergency, 15 prescription, 15 non-medical, 50 valid medical).

---

## PHASE 4: Environmental Data (AQI + Weather)

### Step 4.1 — Get WAQI API token
1. Go to https://aqicn.org/data-platform/token/
2. Register → get token
3. Add to `.env`:
```
WAQI_API_TOKEN=your_token
```

### Step 4.2 — Build AQI wrapper
File: `backend/context/aqi.py`
```python
import os
import httpx
from dotenv import load_dotenv

load_dotenv()
WAQI_TOKEN = os.getenv("WAQI_API_TOKEN")

async def get_aqi(lat: float, lon: float) -> dict:
    """Fetch real-time AQI data from WAQI API."""
    url = f"https://api.waqi.info/feed/geo:{lat};{lon}/?token={WAQI_TOKEN}"

    async with httpx.AsyncClient(timeout=10) as client:
        resp = await client.get(url)
        data = resp.json()

    if data.get("status") != "ok":
        return {"aqi": "N/A", "pm25": "N/A", "error": "WAQI API error"}

    d = data["data"]
    iaqi = d.get("iaqi", {})

    return {
        "aqi": d.get("aqi", "N/A"),
        "pm25": iaqi.get("pm25", {}).get("v", "N/A"),
        "pm10": iaqi.get("pm10", {}).get("v", "N/A"),
        "no2": iaqi.get("no2", {}).get("v", "N/A"),
        "so2": iaqi.get("so2", {}).get("v", "N/A"),
        "o3": iaqi.get("o3", {}).get("v", "N/A"),
        "co": iaqi.get("co", {}).get("v", "N/A"),
        "station": d.get("city", {}).get("name", "Unknown"),
    }
```

### Step 4.3 — Build weather wrapper
File: `backend/context/weather.py`
```python
import httpx

async def get_weather(lat: float, lon: float) -> dict:
    """Fetch weather data from Open-Meteo (NO API key needed)."""
    url = (
        f"https://api.open-meteo.com/v1/forecast"
        f"?latitude={lat}&longitude={lon}"
        f"&current=temperature_2m,relative_humidity_2m,apparent_temperature,"
        f"uv_index,wind_speed_10m,precipitation"
    )

    async with httpx.AsyncClient(timeout=10) as client:
        resp = await client.get(url)
        data = resp.json()

    current = data.get("current", {})
    return {
        "temp": current.get("temperature_2m", "N/A"),
        "humidity": current.get("relative_humidity_2m", "N/A"),
        "feels_like": current.get("apparent_temperature", "N/A"),
        "uv_index": current.get("uv_index", "N/A"),
        "wind_speed": current.get("wind_speed_10m", "N/A"),
        "precipitation": current.get("precipitation", "N/A"),
    }
```

### Step 4.4 — Add AQI endpoint to routes
File: `backend/api/routes.py`
```python
from fastapi import APIRouter, Query
from sse_starlette.sse import EventSourceResponse
from backend.context.aqi import get_aqi
from backend.context.weather import get_weather
from backend.safety.router import check_safety
from backend.translation.bhashini import translate
from backend.api.models import ChatRequest
import json

router = APIRouter()

@router.get("/aqi")
async def aqi_endpoint(lat: float = Query(...), lon: float = Query(...)):
    aqi_data = await get_aqi(lat, lon)
    weather_data = await get_weather(lat, lon)
    return {"success": True, "data": {**aqi_data, **weather_data}}

@router.post("/chat")
async def chat_endpoint(req: ChatRequest):
    # Step 1: Safety check
    is_safe, blocked_response = check_safety(req.query)
    if not is_safe:
        async def blocked_stream():
            yield {"event": "message", "data": json.dumps({"token": blocked_response, "done": True})}
        return EventSourceResponse(blocked_stream())

    # Step 2: Translate if needed
    query_en = req.query
    if req.language != "en":
        query_en = await translate(req.query, req.language, "en")

    # Step 3: Get AQI data
    aqi_data = {}
    if req.lat and req.lon:
        aqi_data = await get_aqi(req.lat, req.lon)
        weather = await get_weather(req.lat, req.lon)
        aqi_data.update(weather)

    # Step 4: Run CRAG pipeline (streaming)
    # ⛔ NEEDS JAYESH'S pipeline.py
    from backend.rag.pipeline import CRAGPipeline
    pipeline = CRAGPipeline("./icmr-knowledge-bundle")

    async def generate():
        full_response = ""
        async for token in pipeline.run(query_en, req.profile.model_dump(), aqi_data):
            full_response += token
            yield {"event": "message", "data": json.dumps({"token": token, "done": False})}

        # Translate response back if needed
        if req.language != "en":
            full_response = await translate(full_response, "en", req.language)
            yield {"event": "message", "data": json.dumps({"token": full_response, "done": True, "translated": True})}
        else:
            yield {"event": "message", "data": json.dumps({"token": "", "done": True})}

    return EventSourceResponse(generate())
```
✅ **Done when**: `/api/aqi?lat=19.07&lon=72.87` returns AQI for Mumbai. `/api/chat` streams responses.

---

## PHASE 5: Full Integration

> ⛔ **BLOCKED BY Jayesh Phase 4** — CRAG Pipeline must be complete before `/api/chat` fully works.

### Step 5.1 — Wire everything together
The `routes.py` above already wires: Safety → Translation → AQI → Pipeline → Translate back.

### Step 5.2 — Test full E2E
```bash
# Terminal 1: Start Ollama
ollama serve

# Terminal 2: Start FastAPI
cd backend && uvicorn main:app --reload --port 8000

# Terminal 3: Test
curl -N -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"query": "मला diabetes आहे, exercise करू शकतो का?", "language": "mr", "lat": 19.07, "lon": 72.87}'
```
✅ **Done when**: Marathi query → English RAG → Marathi response with ICMR citation. Streaming via SSE.

---
---

# 📱 DEV 3: RITESH PAWAR — Mobile & Frontend Engineer

> You own: Flutter app, Health Connect (wearable), SQLite, Chat UI, AQI dashboard, all user-facing screens

---

## PHASE 1: Flutter Project Setup

### Step 1.1 — Create Flutter project
```bash
flutter create aarogya_sathi
cd aarogya_sathi
```

### Step 1.2 — Add dependencies to `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0           # Local SQLite database
  path_provider: ^2.1.0     # File paths for DB
  http: ^1.2.0              # HTTP requests
  flutter_sse: ^1.0.0       # SSE streaming from backend (check pub.dev for latest)
  health: ^10.0.0           # Health Connect / Fitbit via Google Health
  permission_handler: ^11.0.0  # Runtime permissions
  flutter_local_notifications: ^17.0.0  # Medication reminders
  provider: ^6.1.0          # State management
  intl: ^0.19.0             # Date formatting
  geolocator: ^12.0.0       # GPS for AQI location
  flutter_markdown: ^0.7.0  # Render markdown in chat
```
```bash
flutter pub get
```

### Step 1.3 — Create folder structure
```
lib/
├── main.dart
├── config/
│   └── api_config.dart          # Backend URL, constants
├── models/
│   ├── user_profile.dart        # User health profile model
│   ├── chat_message.dart        # Chat message model
│   └── aqi_data.dart            # AQI response model
├── services/
│   ├── api_service.dart         # HTTP + SSE communication
│   ├── db_service.dart          # SQLite operations
│   ├── health_service.dart      # Health Connect (Fitbit/wearable)
│   └── notification_service.dart # Medication reminders
├── screens/
│   ├── home_screen.dart         # Dashboard with AQI card
│   ├── chat_screen.dart         # AI chat with streaming
│   ├── profile_screen.dart      # Health profile form
│   ├── aqi_screen.dart          # Detailed AQI view
│   └── settings_screen.dart     # Language, notifications
└── widgets/
    ├── aqi_card.dart            # AQI summary widget
    ├── message_bubble.dart      # Chat bubble widget
    ├── condition_picker.dart    # Multi-select for conditions
    └── health_data_card.dart    # Wearable data display
```

### Step 1.4 — Create API config
File: `lib/config/api_config.dart`
```dart
class ApiConfig {
  // Change this to your Colab/server URL when deploying
  static const String baseUrl = "http://10.0.2.2:8000"; // Android emulator → localhost
  static const String chatEndpoint = "$baseUrl/api/chat";
  static const String aqiEndpoint = "$baseUrl/api/aqi";
  static const String healthEndpoint = "$baseUrl/api/health";
}
```
✅ **Done when**: `flutter run` shows blank app on emulator with bottom navigation.

---

## PHASE 2: Health Profile + SQLite

### Step 2.1 — Create DB service
File: `lib/services/db_service.dart`
```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'aarogya_sathi.db');
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE user_profile (
          id INTEGER PRIMARY KEY,
          name TEXT,
          age INTEGER,
          gender TEXT,
          conditions TEXT,
          medications TEXT,
          language TEXT DEFAULT 'en'
        )
      ''');
      await db.execute('''
        CREATE TABLE chat_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          query TEXT,
          response TEXT,
          language TEXT,
          timestamp TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE medications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          dose TEXT,
          frequency TEXT,
          reminder_time TEXT
        )
      ''');
    });
  }

  // Profile CRUD
  static Future<void> saveProfile(Map<String, dynamic> profile) async {
    final db = await database;
    await db.insert('user_profile', profile,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;
    final results = await db.query('user_profile', limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  // Chat history
  static Future<void> saveChat(String query, String response, String lang) async {
    final db = await database;
    await db.insert('chat_history', {
      'query': query, 'response': response,
      'language': lang, 'timestamp': DateTime.now().toIso8601String()
    });
  }

  static Future<List<Map<String, dynamic>>> getChatHistory() async {
    final db = await database;
    return db.query('chat_history', orderBy: 'timestamp DESC', limit: 50);
  }
}
```

### Step 2.2 — Build Profile screen
File: `lib/screens/profile_screen.dart`
Build a form with:
- Name (TextField)
- Age (NumberField)
- Gender (Dropdown: Male/Female/Other)
- Conditions (Multi-select chips: Diabetes, Hypertension, Asthma, COPD, Heart Disease, Obesity, Thyroid, CKD)
- Medications (List with Add button, each has: name, dose, frequency, reminder time)
- Language (Radio: English, हिंदी, मराठी)
- Save button → saves to SQLite

✅ **Done when**: Fill profile → close app → reopen → profile still there.

---

## PHASE 3: Health Connect SDK (Wearable / Fitbit / Google Fit)

> ⚠️ Fitbit Web API retired Sept 2026. Use **Health Connect SDK** — Google's unified on-device health hub.
> Health Connect aggregates data from ALL wearables: Fitbit, Google Fit, Samsung Health, Mi Band, Pixel Watch, Garmin, etc.

### Key Facts You Must Know
| Fact | Detail |
|------|--------|
| **What is Health Connect?** | Android's unified health data layer. All wearable apps sync to it. Your app reads from ONE place. |
| **Data history** | Default: 30 days before permission granted. For older data, request `PERMISSION_READ_HEALTH_DATA_HISTORY` |
| **Data types** | 50+ types across 6 categories (see below) |
| **Can we store data?** | ✅ Yes — locally (SQLite) or cloud. But MUST follow Google's **Limited Use policy**: no selling data, no ads/marketing |
| **Can we write data?** | ✅ Yes — use Google's Record schemas (`StepsRecord`, `HeartRateRecord`, etc.) |
| **Reminders?** | ❌ Health Connect has NO reminder support. Use `AlarmManager` + `WorkManager` + `NotificationManager` for medication/activity reminders |
| **Flutter package** | `health: ^10.0.0` on pub.dev — wraps Health Connect SDK |

### All 6 Data Categories (50+ types)

| Category | Data Types We Use | Types We Skip |
|----------|-------------------|---------------|
| **🏃 Activity** | `STEPS`, `ACTIVE_CALORIES_BURNED`, `DISTANCE`, `EXERCISE_SESSION` | Floors, wheelchair pushes |
| **😴 Sleep** | `SLEEP_ASLEEP`, `SLEEP_AWAKE`, `SLEEP_REM`, `SLEEP_DEEP`, `SLEEP_LIGHT`, `SLEEP_SESSION` | — |
| **❤️ Vitals** | `HEART_RATE`, `RESTING_HEART_RATE`, `HEART_RATE_VARIABILITY`, `BLOOD_OXYGEN`, `BLOOD_PRESSURE_SYSTOLIC`, `BLOOD_PRESSURE_DIASTOLIC`, `BODY_TEMPERATURE`, `RESPIRATORY_RATE` | Basal metabolic rate |
| **🩸 Body Metrics** | `BLOOD_GLUCOSE`, `WEIGHT`, `HEIGHT`, `BODY_FAT_PERCENTAGE`, `BMI` | Bone mass, water % |
| **🍎 Nutrition** | `NUTRITION` (calories, macros) | Individual micronutrients |
| **♀️ Cycle** | Skip entirely | Not relevant for NCD focus |

### Step 3.1 — Add Health Connect permissions
File: `android/app/src/main/AndroidManifest.xml` — add inside `<manifest>`:
```xml
<!-- Health Connect read permissions (Activity) -->
<uses-permission android:name="android.permission.health.READ_STEPS" />
<uses-permission android:name="android.permission.health.READ_DISTANCE" />
<uses-permission android:name="android.permission.health.READ_ACTIVE_CALORIES_BURNED" />
<uses-permission android:name="android.permission.health.READ_EXERCISE" />

<!-- Health Connect read permissions (Sleep) -->
<uses-permission android:name="android.permission.health.READ_SLEEP" />

<!-- Health Connect read permissions (Vitals) -->
<uses-permission android:name="android.permission.health.READ_HEART_RATE" />
<uses-permission android:name="android.permission.health.READ_RESTING_HEART_RATE" />
<uses-permission android:name="android.permission.health.READ_HEART_RATE_VARIABILITY" />
<uses-permission android:name="android.permission.health.READ_OXYGEN_SATURATION" />
<uses-permission android:name="android.permission.health.READ_BLOOD_PRESSURE" />
<uses-permission android:name="android.permission.health.READ_BODY_TEMPERATURE" />
<uses-permission android:name="android.permission.health.READ_RESPIRATORY_RATE" />

<!-- Health Connect read permissions (Body Metrics) -->
<uses-permission android:name="android.permission.health.READ_BLOOD_GLUCOSE" />
<uses-permission android:name="android.permission.health.READ_WEIGHT" />
<uses-permission android:name="android.permission.health.READ_HEIGHT" />
<uses-permission android:name="android.permission.health.READ_BODY_FAT" />

<!-- Health Connect read permissions (Nutrition) -->
<uses-permission android:name="android.permission.health.READ_NUTRITION" />

<!-- Historical data access (older than 30 days) -->
<uses-permission android:name="android.permission.health.READ_HEALTH_DATA_HISTORY" />

<!-- Write permissions (to log user's manual entries back to Health Connect) -->
<uses-permission android:name="android.permission.health.WRITE_STEPS" />
<uses-permission android:name="android.permission.health.WRITE_BLOOD_GLUCOSE" />
<uses-permission android:name="android.permission.health.WRITE_BLOOD_PRESSURE" />
<uses-permission android:name="android.permission.health.WRITE_WEIGHT" />
```

Also add the Health Connect intent filter in `<application>` to show your app in Health Connect's connected apps:
```xml
<activity ...>
  <intent-filter>
    <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" />
  </intent-filter>
  <meta-data
    android:name="health_permissions"
    android:resource="@array/health_permissions" />
</activity>
```

### Step 3.2 — Build comprehensive Health Service
File: `lib/services/health_service.dart`
```dart
import 'package:health/health.dart';

class HealthService {
  static final Health _health = Health();

  // ═══════════════════════════════════════════════════════
  // ALL data types we read from Health Connect
  // ═══════════════════════════════════════════════════════
  static final List<HealthDataType> _readTypes = [
    // Activity
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_CALORIES_BURNED,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.WORKOUT,
    // Sleep
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_SESSION,
    // Vitals
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.RESPIRATORY_RATE,
    // Body Metrics
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    // Nutrition
    HealthDataType.NUTRITION,
  ];

  // Data types we can write back to Health Connect
  static final List<HealthDataType> _writeTypes = [
    HealthDataType.STEPS,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.WEIGHT,
  ];

  // ═══════════════════════════════════════════════════════
  // STEP 1: Request permissions (call on first launch)
  // ═══════════════════════════════════════════════════════
  static Future<bool> requestPermissions() async {
    // Read permissions for all types
    final readPerms = _readTypes.map((t) => HealthDataAccess.READ).toList();
    bool readGranted = await _health.requestAuthorization(
      _readTypes, permissions: readPerms,
    );

    // Write permissions for types we log back
    final writePerms = _writeTypes.map((t) => HealthDataAccess.WRITE).toList();
    bool writeGranted = await _health.requestAuthorization(
      _writeTypes, permissions: writePerms,
    );

    return readGranted && writeGranted;
  }

  // ═══════════════════════════════════════════════════════
  // STEP 2: Get today's full health summary
  // Returns a Map that gets sent to the AI context
  // ═══════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getTodaySummary() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    final data = await _health.getHealthDataFromTypes(
      types: _readTypes,
      startTime: midnight,
      endTime: now,
    );

    // Remove duplicates (Health Connect can return overlapping data from multiple sources)
    final unique = _health.removeDuplicates(data);

    // Aggregate into a clean summary
    int steps = 0;
    double calories = 0;
    double distance = 0;
    double? lastHeartRate;
    double? restingHR;
    double? hrv;
    double? lastGlucose;
    double? bpSystolic;
    double? bpDiastolic;
    double? spo2;
    double? bodyTemp;
    double? respRate;
    double? weight;
    double sleepMinutes = 0;
    double remMinutes = 0;
    double deepMinutes = 0;
    double lightMinutes = 0;

    for (final point in unique) {
      final val = point.value;
      double num = 0;
      if (val is NumericHealthValue) num = val.numericValue.toDouble();

      switch (point.type) {
        // Activity
        case HealthDataType.STEPS:
          steps += num.toInt();
          break;
        case HealthDataType.ACTIVE_CALORIES_BURNED:
          calories += num;
          break;
        case HealthDataType.DISTANCE_DELTA:
          distance += num;
          break;
        // Vitals
        case HealthDataType.HEART_RATE:
          lastHeartRate = num;
          break;
        case HealthDataType.RESTING_HEART_RATE:
          restingHR = num;
          break;
        case HealthDataType.HEART_RATE_VARIABILITY_SDNN:
          hrv = num;
          break;
        case HealthDataType.BLOOD_OXYGEN:
          spo2 = num;
          break;
        case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
          bpSystolic = num;
          break;
        case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
          bpDiastolic = num;
          break;
        case HealthDataType.BODY_TEMPERATURE:
          bodyTemp = num;
          break;
        case HealthDataType.RESPIRATORY_RATE:
          respRate = num;
          break;
        // Body
        case HealthDataType.BLOOD_GLUCOSE:
          lastGlucose = num;
          break;
        case HealthDataType.WEIGHT:
          weight = num;
          break;
        // Sleep
        case HealthDataType.SLEEP_ASLEEP:
          sleepMinutes += num;
          break;
        case HealthDataType.SLEEP_REM:
          remMinutes += num;
          break;
        case HealthDataType.SLEEP_DEEP:
          deepMinutes += num;
          break;
        case HealthDataType.SLEEP_LIGHT:
          lightMinutes += num;
          break;
        default:
          break;
      }
    }

    return {
      // Activity
      "steps": steps,
      "calories_burned": calories.round(),
      "distance_meters": distance.round(),
      // Vitals
      "heart_rate_bpm": lastHeartRate,
      "resting_heart_rate": restingHR,
      "hrv_sdnn_ms": hrv,
      "spo2_percent": spo2,
      "bp_systolic": bpSystolic,
      "bp_diastolic": bpDiastolic,
      "body_temp_celsius": bodyTemp,
      "respiratory_rate": respRate,
      // Body
      "blood_glucose_mg_dl": lastGlucose,
      "weight_kg": weight,
      // Sleep (last night)
      "sleep_total_hours": sleepMinutes / 60,
      "sleep_rem_hours": remMinutes / 60,
      "sleep_deep_hours": deepMinutes / 60,
      "sleep_light_hours": lightMinutes / 60,
    };
  }

  // ═══════════════════════════════════════════════════════
  // STEP 3: Get 7-day trend (for dashboard charts)
  // ═══════════════════════════════════════════════════════
  static Future<List<Map<String, dynamic>>> getWeeklyTrend() async {
    final now = DateTime.now();
    List<Map<String, dynamic>> trend = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));

      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS, HealthDataType.HEART_RATE,
                HealthDataType.BLOOD_GLUCOSE, HealthDataType.SLEEP_ASLEEP],
        startTime: start, endTime: end,
      );

      int daySteps = 0;
      double? dayGlucose;
      for (final p in _health.removeDuplicates(data)) {
        if (p.type == HealthDataType.STEPS) {
          daySteps += (p.value as NumericHealthValue).numericValue.toInt();
        }
        if (p.type == HealthDataType.BLOOD_GLUCOSE) {
          dayGlucose = (p.value as NumericHealthValue).numericValue.toDouble();
        }
      }

      trend.add({
        "date": "${date.day}/${date.month}",
        "steps": daySteps,
        "glucose": dayGlucose,
      });
    }
    return trend;
  }

  // ═══════════════════════════════════════════════════════
  // STEP 4: Write data BACK to Health Connect
  // (When user manually logs BP, glucose, weight in our app)
  // ═══════════════════════════════════════════════════════
  static Future<bool> writeBloodGlucose(double mgDl) async {
    return await _health.writeHealthData(
      value: mgDl,
      type: HealthDataType.BLOOD_GLUCOSE,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
    );
  }

  static Future<bool> writeBloodPressure(double systolic, double diastolic) async {
    bool s = await _health.writeHealthData(
      value: systolic, type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      startTime: DateTime.now(), endTime: DateTime.now(),
    );
    bool d = await _health.writeHealthData(
      value: diastolic, type: HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      startTime: DateTime.now(), endTime: DateTime.now(),
    );
    return s && d;
  }

  static Future<bool> writeWeight(double kg) async {
    return await _health.writeHealthData(
      value: kg, type: HealthDataType.WEIGHT,
      startTime: DateTime.now(), endTime: DateTime.now(),
    );
  }
}
```

### Step 3.3 — How wearable data flows into the AI

**Full flow: Wearable → Health Connect → Flutter → FastAPI → LLM Context**

```dart
// In chat_screen.dart, before sending each request:
final healthData = await HealthService.getTodaySummary();
final profile = await DbService.getProfile();

final request = {
  "query": userMessage,
  "language": profile?["language"] ?? "en",
  "profile": {
    // Static profile
    "age": profile?["age"],
    "gender": profile?["gender"],
    "conditions": jsonDecode(profile?["conditions"] ?? "[]"),
    "medications": jsonDecode(profile?["medications"] ?? "[]"),

    // Live wearable data (from Health Connect)
    "today_steps": healthData["steps"],
    "calories_burned": healthData["calories_burned"],
    "heart_rate_bpm": healthData["heart_rate_bpm"],
    "resting_heart_rate": healthData["resting_heart_rate"],
    "spo2_percent": healthData["spo2_percent"],
    "blood_glucose_mg_dl": healthData["blood_glucose_mg_dl"],
    "bp": "${healthData['bp_systolic']}/${healthData['bp_diastolic']}",
    "body_temp": healthData["body_temp_celsius"],
    "sleep_hours": healthData["sleep_total_hours"],
    "weight_kg": healthData["weight_kg"],
  },
  "lat": currentPosition.latitude,
  "lon": currentPosition.longitude,
};
```

> ⛔ **BLOCKED BY Abhijit** — Abhijit needs to:
> 1. Update `ChatRequest` Pydantic model to accept all wearable fields
> 2. Update the XML context template to include a `<wearable_data>` section:
> ```xml
> <wearable_data>
> Steps today: {steps} | Calories: {calories}
> Heart Rate: {hr} bpm | Resting HR: {resting_hr} bpm | SpO2: {spo2}%
> Blood Glucose: {glucose} mg/dL | BP: {bp_sys}/{bp_dia} mmHg
> Sleep: {sleep_hours} hrs (Deep: {deep}h, REM: {rem}h, Light: {light}h)
> Weight: {weight} kg | Body Temp: {temp}°C
> </wearable_data>
> ```

### Step 3.4 — Build Health Dashboard widget
File: `lib/widgets/health_data_card.dart`

Show a card on the home screen with wearable data:
- 🚶 Steps (circular progress toward 10,000 goal)
- ❤️ Heart rate with min/max/current
- 🩸 Blood glucose with normal/high/low color coding
- 💤 Sleep breakdown (deep/REM/light as stacked bar)
- 🩺 BP reading with color (green/yellow/red based on range)
- ⚖️ Weight trend (7-day sparkline chart)

### Step 3.5 — Manual data logging
Users may not have a wearable. Build a "Log Reading" button on the health dashboard:
- Blood glucose: NumberField + "mg/dL" label → writes to Health Connect + SQLite
- Blood pressure: Two NumberFields (systolic/diastolic) → writes to Health Connect
- Weight: NumberField + "kg" label → writes to Health Connect

This way, even without a wearable, users can manually log data that gets shared with the AI.

### Step 3.6 — Google Limited Use Policy compliance
> [!IMPORTANT]
> You MUST follow Google's Limited Use policy or your app gets removed from Play Store.

Rules:
1. ✅ Store health data locally in SQLite — **allowed**
2. ✅ Send health data to your backend for AI context — **allowed** (it's core functionality)
3. ❌ NEVER sell health data to third parties
4. ❌ NEVER use health data for advertising
5. ❌ NEVER share health data with analytics tools (no Firebase Analytics on health data)
6. ✅ Display a clear privacy policy explaining what data you collect and why

✅ **Done when**: App reads steps + heart rate + glucose + BP + sleep from Health Connect. Manual logging writes back to Health Connect. Health dashboard displays all metrics.

---

## PHASE 4: Chat Screen with SSE Streaming

> ⛔ **BLOCKED BY Abhijit Phase 1** — Backend must be running on `localhost:8000` to test SSE.
> But you can build the UI first, connect later.

### Step 4.1 — Build API service with SSE
File: `lib/services/api_service.dart`
```dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  /// Send chat query, receive SSE stream of tokens
  static Stream<String> sendChatMessage(Map<String, dynamic> request) async* {
    final client = http.Client();
    try {
      final req = http.Request('POST', Uri.parse(ApiConfig.chatEndpoint));
      req.headers['Content-Type'] = 'application/json';
      req.body = jsonEncode(request);

      final response = await client.send(req);

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        // Parse SSE format: "data: {...}\n\n"
        for (final line in chunk.split('\n')) {
          if (line.startsWith('data: ')) {
            final data = jsonDecode(line.substring(6));
            yield data['token'] as String;
            if (data['done'] == true) return;
          }
        }
      }
    } finally {
      client.close();
    }
  }

  /// Get AQI data for location
  static Future<Map<String, dynamic>> getAqi(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.aqiEndpoint}?lat=$lat&lon=$lon'),
    );
    return jsonDecode(response.body)['data'];
  }
}
```

### Step 4.2 — Build Chat screen
File: `lib/screens/chat_screen.dart`

Build a screen with:
- `ListView` of message bubbles (user on right, bot on left)
- `TextField` at bottom with send button
- On send: call `ApiService.sendChatMessage()` → listen to stream → append tokens to bot message in real-time
- Show typing indicator while streaming
- After stream done, save to chat history via `DbService.saveChat()`
- Display markdown in bot messages using `flutter_markdown`

### Step 4.3 — Build message bubble widget
File: `lib/widgets/message_bubble.dart`
- User messages: right-aligned, blue background
- Bot messages: left-aligned, white background, rendered as markdown
- Bot messages show "Aarogya Sathi" label + ICMR citation at bottom
- Timestamp below each message

✅ **Done when**: Type question → see response streaming word-by-word → rendered as markdown.

---

## PHASE 5: AQI Dashboard

### Step 5.1 — Get user location
```dart
import 'package:geolocator/geolocator.dart';

Future<Position> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) throw Exception('Location services disabled');

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  return await Geolocator.getCurrentPosition();
}
```

### Step 5.2 — Build AQI card widget
File: `lib/widgets/aqi_card.dart`
- Show AQI number with color (Green/Yellow/Orange/Red/Purple based on value)
- Show PM2.5, temperature, humidity
- Show health advisory text based on AQI level:
  - 0-50: "Air quality is good. Safe for outdoor activities."
  - 51-100: "Moderate. Sensitive groups should limit prolonged outdoor exertion."
  - 101-200: "Unhealthy. Reduce outdoor exercise. Wear mask if needed."
  - 201-300: "Very Unhealthy. Avoid outdoor activities."
  - 300+: "Hazardous. Stay indoors. Close windows."

### Step 5.3 — Build full AQI screen
- PM2.5 gauge
- Temperature + humidity
- UV index with sun protection advice
- Wind speed
- 3-day forecast (if available from Open-Meteo)
- Health tips based on user's conditions + current AQI

✅ **Done when**: AQI card on home screen shows real-time data for user's location.

---

## PHASE 6: Medication Reminders

### Step 6.1 — Set up local notifications
File: `lib/services/notification_service.dart`
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
  }

  static Future<void> scheduleMedicationReminder({
    required int id,
    required String medicineName,
    required String dose,
    required TimeOfDay time,
  }) async {
    // Schedule daily notification at the specified time
    await _plugin.zonedSchedule(
      id,
      '💊 Time for $medicineName',
      'Take $dose now',
      _nextInstance(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders', 'Medication Reminders',
          importance: Importance.high, priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
    );
  }
}
```

### Step 6.2 — Medication management UI
In profile screen, add a section:
- List of medications (from SQLite)
- Each shows: name, dose, frequency, reminder time
- "Add Medication" button → dialog with fields
- Swipe to delete
- Toggle reminder on/off for each

✅ **Done when**: Add "Metformin 500mg" → set reminder 8:00 AM → get notification at 8:00 AM daily.

---

## PHASE 7: Final Integration & Polish

> ⛔ **BLOCKED BY Abhijit Phase 5** + **Jayesh Phase 4** — Full backend must be running.

### Step 7.1 — Connect all screens to live backend
- Profile screen → sends profile with `/api/chat` requests
- Chat screen → SSE streaming from live CRAG pipeline
- AQI screen → live data from `/api/aqi`
- Health data → wearable data included in profile

### Step 7.2 — Add language switching
- Settings screen: Language selector (English, हिंदी, मराठी)
- Save to SQLite profile
- Pass `language` field with every chat request
- Bhashini handles translation on backend

### Step 7.3 — UI polish
- App icon and splash screen
- Loading skeletons while data loads
- Pull-to-refresh on AQI
- Dark mode support (optional)
- App name: "Aarogya Sathi" with logo

### Step 7.4 — Build APK
```bash
flutter build apk --release
```
✅ **Done when**: APK installs on Android phone, all features work with live backend.

---
---

# 🔗 Dependency Constraint Map

```
JAYESH                    ABHIJIT                   RITESH
═══════                   ═══════                   ══════

Phase 1: LLM Setup        Phase 1: FastAPI Setup     Phase 1: Flutter Setup
(independent)              (independent)              (independent)
    │                          │                          │
    ▼                          ▼                          ▼
Phase 2: OKF Bundle        Phase 2: Bhashini API      Phase 2: Profile + SQLite
(independent)              (independent)              (independent)
    │                          │                          │
    ▼                          ▼                          ▼
Phase 3: OKF Navigator     Phase 3: Safety Router     Phase 3: Health Connect
(independent)              (independent)              (independent)
    │                          │                          │
    ▼                          ▼                          │
Phase 4: CRAG Pipeline     Phase 4: AQI + Routes      Phase 4: Chat UI + SSE
(independent)              ⛔ NEEDS Jayesh Phase 4     ⛔ NEEDS Abhijit Phase 1
    │                      for /api/chat to work           │
    │                          │                          │
    │                          ▼                          ▼
    │                      Phase 5: Full Integration   Phase 5: AQI Dashboard
    │                      ⛔ NEEDS Jayesh Phase 4     (independent)
    │                          │                          │
    ▼                          │                          ▼
Phase 5: Evaluation            │                      Phase 6: Med Reminders
⛔ NEEDS Abhijit Phase 5       │                      (independent)
for full E2E                   │                          │
    │                          │                          ▼
    │                          │                      Phase 7: Integration
    │                          │                      ⛔ NEEDS Both Others
    ▼                          ▼                          ▼
    └──────────────────────────┴──────────────────────────┘
                    ALL DONE → Report + Demo
```

### What can happen in parallel:
- **ALL THREE** can work on Phase 1, 2, 3 simultaneously (zero dependencies)
- **Jayesh Phase 4** unlocks Abhijit Phase 4-5 and Ritesh Phase 4
- **Everything before Phase 4** is fully parallel
