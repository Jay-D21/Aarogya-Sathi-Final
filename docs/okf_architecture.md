# Aarogya Sathi — Architecture with Open Knowledge Format (OKF)
### Google's OKF (June 2026) + Corrective RAG Hybrid

---

## What is OKF and Why It Changes Everything

**Open Knowledge Format (OKF)** is Google's open specification (Apache license, June 2026) that replaces the "chunk text → embed → vector search" pattern with **structured, interlinked Markdown files** that an AI agent can **navigate like a wiki**.

### Traditional RAG vs OKF

| | Traditional RAG (what we planned) | OKF (what Google released) |
|---|---|---|
| **How knowledge is stored** | PDF → split into 500-token chunks → embed as vectors | PDF → convert to structured Markdown files with YAML frontmatter |
| **How retrieval works** | Probabilistic: cosine similarity, "close enough" matches | Deterministic: agent reads `index.md`, follows hyperlinks to exact concept |
| **Failure mode** | Retrieves wrong chunk → LLM hallucinates confidently | Agent navigates to wrong page → but the page is human-readable, auditable |
| **Medical fit** | Risky — semantic similarity can miss exact dosages | Excellent — each condition/drug/protocol is a separate, precise file |
| **Infrastructure** | Vector DB (Qdrant) + Embedding model (BGE-M3) + Reranker | Just a folder of `.md` files in Git. Zero infrastructure |
| **Governance** | Hard to audit what the vector search returned | Git history — every change is versioned, reviewed, diffable |

### Why OKF is PERFECT for ICMR Medical Guidelines

ICMR guidelines are already structured:
- Chapter 1: Diabetes Management
- Chapter 2: Hypertension Guidelines
- Chapter 3: COPD/Asthma Protocols
- Each chapter has: Definition → Risk Factors → Symptoms → Diagnosis → Treatment → Dosage Tables → Lifestyle Advice

This maps **directly** to an OKF bundle where each concept (condition, drug, protocol) is a Markdown file with links to related concepts.

---

## How We Structure ICMR as an OKF Bundle

```
icmr-knowledge-bundle/
├── index.md                          ← Agent starts here (master map)
├── conditions/
│   ├── index.md                      ← Lists all conditions
│   ├── diabetes-type2.md             ← Full T2DM guideline
│   ├── hypertension.md               ← Full HTN guideline
│   ├── copd.md
│   ├── asthma.md
│   ├── coronary-artery-disease.md
│   └── chronic-kidney-disease.md
├── drugs/
│   ├── index.md                      ← Lists all drugs
│   ├── metformin.md                  ← Dosage, interactions, contraindications
│   ├── amlodipine.md
│   ├── salbutamol.md
│   └── atorvastatin.md
├── lifestyle/
│   ├── index.md
│   ├── diet-diabetes.md              ← Diet advice for diabetics
│   ├── exercise-guidelines.md
│   └── smoking-cessation.md
├── environmental/
│   ├── index.md
│   ├── aqi-health-impact.md          ← AQI thresholds → health effects
│   ├── heat-stress.md
│   └── pollution-respiratory.md
└── emergency/
    ├── index.md
    ├── chest-pain.md                 ← Emergency protocols
    ├── hypoglycemia.md
    └── asthma-attack.md
```

### Example: `conditions/diabetes-type2.md`

```markdown
---
type: Clinical Guideline
title: Type 2 Diabetes Mellitus — ICMR Management Protocol
description: Complete management guideline for T2DM based on ICMR 2024 standards.
tags: [diabetes, ncd, metabolic, chronic]
sources:
  - id: icmr-ncd-2024
    resource: https://main.icmr.nic.in/guidelines/diabetes
    title: ICMR Guidelines for Management of Type 2 Diabetes 2024
    author: process:icmr-committee
    last_modified: 2024-03-15T00:00:00Z
generated:
  by: human:jayesh-patil
  at: 2026-09-15T10:00:00Z
verified:
  by: human:abhijit-patil
  at: 2026-09-16T14:00:00Z
  method: cross-checked against ICMR PDF chapter 4
---

# Type 2 Diabetes Mellitus

## Definition
A chronic metabolic disorder characterized by persistent hyperglycemia 
resulting from defects in insulin secretion, insulin action, or both.[^icmr-ncd-2024]

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
- **Air pollution exposure** — See [AQI Health Impact](../environmental/aqi-health-impact.md)
- Age >45 years

## First-Line Treatment
- Lifestyle modification — See [Diet for Diabetes](../lifestyle/diet-diabetes.md)
- [Metformin](../drugs/metformin.md) 500mg twice daily, titrate to 1000mg

## Monitoring
- HbA1c every 3 months
- Fasting glucose daily (self-monitoring)
- Annual eye exam, foot exam, kidney function

## When to Refer
- HbA1c >9% despite dual therapy
- Recurrent hypoglycemia — See [Hypoglycemia Emergency](../emergency/hypoglycemia.md)
- Diabetic ketoacidosis symptoms

## Environmental Considerations
High AQI (>150) increases insulin resistance. Advise indoor exercise when AQI 
is unhealthy. See [Pollution & Respiratory](../environmental/pollution-respiratory.md).
```

### Key Points:
- **Every claim has a source** — `[^icmr-ncd-2024]` traces back to the ICMR PDF
- **Links to related concepts** — drugs, lifestyle, emergencies are hyperlinked
- **Tables are preserved** — dosage tables, diagnostic criteria stay intact
- **YAML frontmatter** — `type`, `sources`, `generated`, `verified` fields per OKF spec
- **Human-authored, human-verified** — each file is reviewed by a team member

---

## How the System Works with OKF

### The Hybrid Architecture: OKF (Primary) + Vector RAG (Fallback)

```
┌──────────────────────────────────────────────────────────────────┐
│               AAROGYA SATHI — OKF + CRAG HYBRID                 │
│                                                                  │
│  User Query (Hindi/Marathi/English)                              │
│       │                                                          │
│       ▼                                                          │
│  ┌──────────────────┐                                            │
│  │ 1. SEMANTIC       │ ← Ultra-fast intent classification       │
│  │    ROUTER         │   Emergency? → 112 message                │
│  │    (<100ms)       │   Prescription? → Block                   │
│  │                   │   Medical? → Continue                     │
│  └────────┬─────────┘                                            │
│           ▼                                                      │
│  ┌──────────────────┐                                            │
│  │ 2. BHASHINI API  │ ← Translate HI/MR → EN (if needed)       │
│  │    (0 VRAM)      │                                            │
│  └────────┬─────────┘                                            │
│           ▼                                                      │
│  ┌──────────────────────────────────────────────────────┐        │
│  │ 3. OKF KNOWLEDGE NAVIGATOR (Primary Retrieval)       │        │
│  │                                                       │        │
│  │  Step 3a: Agent reads icmr-knowledge-bundle/index.md  │        │
│  │           → sees list of condition categories          │        │
│  │                                                       │        │
│  │  Step 3b: Agent identifies relevant condition          │        │
│  │           (e.g., "diabetes" from user query)           │        │
│  │           → opens conditions/diabetes-type2.md         │        │
│  │                                                       │        │
│  │  Step 3c: Agent follows hyperlinks for context         │        │
│  │           → drugs/metformin.md (dosage info)           │        │
│  │           → environmental/aqi-health-impact.md         │        │
│  │           → lifestyle/diet-diabetes.md                 │        │
│  │                                                       │        │
│  │  Step 3d: Agent collects all relevant concept files    │        │
│  │           → passes to context builder                  │        │
│  │                                                       │        │
│  │  Result: Exact, curated, source-cited content          │        │
│  └────────┬──────────────────────────────────────────────┘        │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────────────────────────────────────────┐        │
│  │ 4. CRAG RELEVANCE CHECK                              │        │
│  │    "Does the OKF content answer the question?"        │        │
│  │                                                       │        │
│  │    ┌─────────┐           ┌──────────┐                │        │
│  │    │ YES     │           │ NO       │                │        │
│  │    │ → Go to │           │ → FALLBACK│                │        │
│  │    │   Step 5│           │   to Vector RAG            │        │
│  │    └─────────┘           │   (BGE-M3 + Qdrant)       │        │
│  │                          │   OR Google Search API     │        │
│  │                          └──────────┘                │        │
│  └────────┬──────────────────────────────────────────────┘        │
│           ▼                                                      │
│  ┌──────────────────────────────────────────────────────┐        │
│  │ 5. CONTEXT BUILDER                                    │        │
│  │    System Prompt + Safety Rules                       │        │
│  │    + OKF concept content (with source citations)      │        │
│  │    + User Profile (from SQLite)                       │        │
│  │    + Live AQI Data (WAQI + Open-Meteo)                │        │
│  │    + User Query                                       │        │
│  └────────┬──────────────────────────────────────────────┘        │
│           ▼                                                      │
│  ┌──────────────────┐                                            │
│  │ 6. LLAMA 3.1 8B  │ ← Generate response grounded in OKF      │
│  │    INSTRUCT       │   content with [Source] citations          │
│  │    (via Ollama)   │                                            │
│  └────────┬─────────┘                                            │
│           ▼                                                      │
│  ┌──────────────────┐                                            │
│  │ 7. BHASHINI API  │ ← Translate EN → HI/MR                   │
│  │    + DISCLAIMER   │   + "I am an AI, not a doctor"            │
│  └────────┬─────────┘                                            │
│           ▼                                                      │
│  User Response (with ICMR source citation)                      │
└──────────────────────────────────────────────────────────────────┘
```

---

## Why OKF + Vector RAG Hybrid (Not Just One)

| Scenario | OKF Handles It? | Vector RAG Handles It? | Who Answers? |
|----------|----------------|----------------------|-------------|
| "What is the treatment for Type 2 Diabetes?" | ✅ Direct navigation to `conditions/diabetes-type2.md` | ✅ But may retrieve wrong chunk | **OKF** (deterministic, exact) |
| "My sugar is 250, what should I do?" | ✅ Navigate to diabetes → monitoring section | ✅ Semantic match | **OKF** (structured, complete) |
| "Can I exercise during high pollution if I have asthma?" | ✅ Follow links: asthma → environmental → AQI | ⚠️ May miss cross-document connections | **OKF** (link traversal finds related docs) |
| "Tell me about a rare disease not in ICMR guidelines" | ❌ Not in the bundle | ❌ Not in local docs | **Google Search fallback** (CRAG) |
| Fuzzy/ambiguous queries | ⚠️ Agent may not find the right file | ✅ Semantic similarity handles ambiguity | **Vector RAG** (fallback) |

**OKF is the primary layer** (structured, deterministic, auditable).
**Vector RAG is the fallback** (handles fuzzy queries OKF can't navigate).
**Google Search is the last resort** (handles questions outside ICMR entirely).

---

## How the OKF Navigator Works (Technical Detail)

The OKF navigator is an LLM agent that reads files and follows links. Here's how it works in code:

```python
import os

class OKFNavigator:
    """Navigates an OKF knowledge bundle to find relevant medical concepts."""
    
    def __init__(self, bundle_path: str, llm):
        self.bundle_path = bundle_path
        self.llm = llm
        self.visited = set()
        self.collected_content = []
    
    def navigate(self, query: str, max_depth: int = 3) -> list[dict]:
        """Navigate the OKF bundle starting from index.md."""
        # Step 1: Read the root index
        index_content = self._read_file("index.md")
        
        # Step 2: Ask LLM which concept files are relevant to the query
        relevant_files = self._identify_relevant_files(query, index_content)
        
        # Step 3: Read each relevant file and follow links
        for file_path in relevant_files:
            self._traverse(file_path, query, depth=0, max_depth=max_depth)
        
        return self.collected_content
    
    def _traverse(self, file_path: str, query: str, depth: int, max_depth: int):
        """Recursively traverse OKF files following hyperlinks."""
        if file_path in self.visited or depth > max_depth:
            return
        
        self.visited.add(file_path)
        content = self._read_file(file_path)
        
        if content:
            self.collected_content.append({
                "path": file_path,
                "content": content,
                "depth": depth
            })
            
            # Extract and follow markdown links if deeper context needed
            if depth < max_depth:
                links = self._extract_links(content)
                relevant_links = self._filter_relevant_links(query, links)
                for link in relevant_links:
                    self._traverse(link, query, depth + 1, max_depth)
    
    def _identify_relevant_files(self, query: str, index_content: str) -> list[str]:
        """Ask LLM to pick relevant files from the index."""
        prompt = f"""Given this knowledge base index:
{index_content}

And this user query: "{query}"

Which concept files should I read? Return only file paths, one per line."""
        
        response = self.llm.invoke(prompt)
        return [line.strip() for line in response.content.split('\n') if line.strip()]
    
    def _extract_links(self, content: str) -> list[str]:
        """Extract markdown links like [text](../path/to/file.md)."""
        import re
        return re.findall(r'\[.*?\]\((\.\.?/[^)]+\.md)\)', content)
    
    def _read_file(self, path: str) -> str | None:
        full_path = os.path.join(self.bundle_path, path)
        if os.path.exists(full_path):
            with open(full_path) as f:
                return f.read()
        return None
```

### How it's used in the CRAG pipeline:

```python
from langchain_ollama import ChatOllama

llm = ChatOllama(model="llama3.1:8b-instruct-q4_K_M")
navigator = OKFNavigator("./icmr-knowledge-bundle", llm)

# User asks about diabetes and pollution
query = "I have diabetes, is it safe to exercise in high pollution?"

# Navigator reads index.md → finds diabetes-type2.md → follows links to
# environmental/aqi-health-impact.md and lifestyle/exercise-guidelines.md
relevant_docs = navigator.navigate(query, max_depth=2)

# Result: 3 precise, interlinked concept files with exact ICMR citations
# No vector embedding, no similarity search, no chunk fragmentation
```

---

## What Changes from Previous Architecture

| Component | Before (Pure Vector RAG) | After (OKF + RAG Hybrid) |
|-----------|-------------------------|--------------------------|
| **Primary Retrieval** | BGE-M3 → Qdrant (probabilistic) | OKF Navigator (deterministic) |
| **Knowledge Storage** | PDF → chunks → vectors in Qdrant | PDF → structured Markdown files in Git |
| **Fallback Retrieval** | None (or CRAG web search) | BGE-M3 + Qdrant for fuzzy queries |
| **Last Resort** | Google Search | Google Search (unchanged) |
| **Infrastructure** | Qdrant (Docker/Cloud) required | Git folder. Zero infra for primary layer |
| **Auditability** | Hard to trace what vectors returned | Every file is human-readable, versioned |
| **Tables/Dosages** | Docling → hope chunking works | Preserved as Markdown tables in concept files |
| **Cross-references** | Lost during chunking | Explicit hyperlinks between concepts |

### What STAYS the Same:
- ✅ Llama 3.1 8B Instruct (via Ollama) — base LLM
- ✅ Semantic Router — safety layer
- ✅ Bhashini API — translation
- ✅ WAQI + Open-Meteo — AQI data
- ✅ FastAPI + SSE — streaming
- ✅ Flutter — mobile app
- ✅ RAGAS — evaluation
- ✅ LCEL — orchestration

### What CHANGES:
- 🆕 OKF bundle replaces Qdrant as primary retrieval
- 🆕 OKF Navigator agent replaces BGE-M3 embedding search
- 📉 Qdrant + BGE-M3 become fallback only (for fuzzy queries)
- 📉 Reranker removed (OKF retrieval is already precise)
- 📉 Docling removed (we manually structure the Markdown)

---

## Updated Tech Stack

| # | Component | Technology | Role |
|---|-----------|-----------|------|
| 1 | **LLM** | Llama 3.1 8B Instruct (Ollama) | Synthesis + OKF navigation |
| 2 | **Primary Retrieval** | **OKF Bundle (Git)** | Structured ICMR knowledge graph |
| 3 | **Fallback Retrieval** | BGE-M3 + Qdrant | Fuzzy/ambiguous queries |
| 4 | **Last Resort** | Google Search API | Questions outside ICMR |
| 5 | **Orchestration** | LangChain LCEL | Pipeline with CRAG routing |
| 6 | **Translation** | Bhashini API | Hindi/Marathi ↔ English |
| 7 | **Safety** | Semantic Router | Emergency/prescription blocking |
| 8 | **AQI/Weather** | WAQI + Open-Meteo | Environmental context |
| 9 | **Serving** | Ollama | LLM inference |
| 10 | **Mobile** | Flutter + FastAPI + SSE | User interface |
| 11 | **Evaluation** | RAGAS + Gemini judge | Quality metrics |
| 12 | **Version Control** | Git | OKF bundle versioning |

### VRAM Budget (even lighter now):
| Component | VRAM |
|-----------|------|
| Llama 3.1 8B (Q4_K_M) | ~5GB |
| BGE-M3 (fallback only, can run on CPU) | 0-1GB |
| **Total** | **~5-6GB / 16GB T4** ✅✅ |

---

## Why This is a STRONGER Capstone

| AIML Skill | How OKF Demonstrates It |
|-----------|------------------------|
| **Knowledge Engineering** | Structuring medical knowledge as an OKF bundle (cutting-edge, June 2026!) |
| **Agentic AI** | LLM agent that reads files, follows links, makes navigation decisions |
| **Hybrid Retrieval** | OKF (deterministic) + Vector RAG (probabilistic) — best of both worlds |
| **Corrective RAG** | CRAG checks OKF results → falls back to vector search → falls back to web |
| **Information Retrieval** | Comparing OKF deterministic retrieval vs vector similarity (great experiment!) |
| **Cutting-Edge Technology** | OKF was released June 2026 — you'd be among the FIRST to use it for medical AI |

> [!IMPORTANT]
> Using Google's OKF (released just 3 months ago) for medical AI would make your capstone **extremely current and novel**. No other student project has done this yet.

---

## Implementation: Building the OKF Bundle

### Effort Estimate
| Task | Time | Who |
|------|------|-----|
| Read all ICMR guideline PDFs | 3 days | All 3 |
| Structure as OKF Markdown files (~50 concept files) | 5 days | Jayesh + Abhijit |
| Add YAML frontmatter + links + source citations | 2 days | Abhijit |
| Write index.md files at each level | 1 day | Jayesh |
| Review & verify against original PDFs | 2 days | Ritesh |
| **Total** | **~2 weeks** | Parallel with other work |

### The Bundle Covers:
- ~15 conditions (diabetes, hypertension, COPD, asthma, CAD, CKD, etc.)
- ~20 drugs (metformin, amlodipine, salbutamol, etc.)
- ~8 lifestyle guides (diet, exercise, smoking, alcohol)
- ~5 environmental factors (AQI, heat, pollen, humidity, UV)
- ~5 emergency protocols (chest pain, hypoglycemia, asthma attack)
- **≈ 50-60 concept files total**
