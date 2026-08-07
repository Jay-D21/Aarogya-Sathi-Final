# Aarogya Sathi — Product Validation & Feasibility Analysis
### Capstone 1st Review | MPSTME, NMIMS | August 2026
### Team: Jayesh Patil | Abhijit Patil | Ritesh Pawar

---

## 1. Problem → Solution Traceability Matrix

> Every problem maps to a specific feature, which maps to a specific technology, which maps to a specific dataset, which maps to peer-reviewed evidence.

### Problem 1: India's NCD Crisis (63% of Deaths)

| Layer | Detail |
|-------|--------|
| **Problem** | NCDs (diabetes, hypertension, heart disease, COPD, asthma) cause 63% of all deaths in India. Patients lack daily preventive guidance — they only visit doctors when already sick. |
| **Our Solution** | Aarogya Sathi provides **daily personalized preventive health guidance** grounded in ICMR clinical guidelines via a RAG pipeline. |
| **How It Works on Mobile** | User creates a health profile (age, conditions, medications, diet preferences) → System stores profile locally → Every query is augmented with profile context → BioMistral generates **personalized** advice (e.g., "Given your Type 2 diabetes and today's high PM2.5, avoid outdoor exercise and monitor glucose after meals") |
| **Dataset Used** | ICMR Clinical Guidelines corpus (NCD management, dietary guidelines, treatment protocols) — chunked, embedded, and indexed in Pinecone |
| **Evidence** | GBD 2019 (*The Lancet*, doi: 10.1016/S0140-6736(20)30925-9); Mahapatra et al. (*PLOS ONE*, 2021, doi: 10.1371/journal.pone.0261184) |
| **Validation Metric** | Compare RAG responses against ICMR guideline gold standard; target ≥90% clinical accuracy (benchmark: JMIR 2026 study achieved 96.7% with FT+RAG) |

---

### Problem 2: Air Pollution Kills 4.2M+ People/Year — No Health App Accounts for This

| Layer | Detail |
|-------|--------|
| **Problem** | PM2.5 exposure causes 127,000+ deaths in Indian cities alone. Different pollutants trigger different conditions (PM2.5 → COPD; NO2/O3 → stroke). Yet **zero** existing health apps integrate real-time AQI into medical advice. |
| **Our Solution** | Aarogya Sathi fetches **real-time pollutant-level data** (not just generic AQI) from WAQI API and injects it into the health advice context. |
| **How It Works on Mobile** | App requests user location (GPS) → Fetches nearest WAQI station data → Parses individual pollutants: PM2.5, PM10, NO2, SO2, O3, CO → Injects pollutant context into LLM prompt → BioMistral generates condition-specific advice |
| **Specific Pollutant Factors We Use** | |

| Pollutant | Health Relevance | Clinical Threshold | Source |
|-----------|-----------------|-------------------|--------|
| **PM2.5** | Asthma exacerbation, COPD flare-ups, cardiovascular events | >35.4 μg/m³ (Unhealthy for Sensitive Groups) | Singh et al., 2023 (doi: 10.1016/j.ehb.2023.101278) |
| **PM10** | Upper respiratory irritation, bronchitis | >154 μg/m³ | Manojkumar & Srimuruganandam, 2021 |
| **NO2** | Stroke risk, myocardial infarction | >100 ppb (1-hr) | Li et al., 2019 (doi: 10.1097/MD.0000000000015634) |
| **SO2** | Cardiovascular hospitalization | >75 ppb (1-hr) | Li et al., 2019 |
| **O3** | Respiratory inflammation, asthma attacks | >70 ppb (8-hr) | Li et al., 2019 |
| **CO** | Headache, impaired cognitive function | >9 ppm (8-hr) | EPA Standards |

| Layer | Detail |
|-------|--------|
| **Dataset Used** | WAQI API (https://waqi.info/) — provides real-time data for 1,000+ Indian monitoring stations via CPCB network |
| **Evidence That This Works** | AirRater app study proved users **successfully changed behavior** when given real-time AQI data (Workman et al., 2021, doi: 10.3390/ijerph18073591) |
| **Example Output** | *"⚠️ Today's PM2.5 in your area is 89 μg/m³ (Unhealthy). Given your asthma history, avoid outdoor exercise. Take your prescribed inhaler proactively. Stay indoors with windows closed until AQI drops below 50."* |

---

### Problem 3: 90% of India Doesn't Speak English — Health AI Is English-Only

| Layer | Detail |
|-------|--------|
| **Problem** | 90% of Indians don't speak English as primary language. Existing health AI (Ada Health, WebMD, ChatGPT) is English-only. Even Practo/Apollo 24/7 have limited vernacular support. CLINIC benchmark proves LLMs have **significant safety gaps** in non-English contexts. |
| **Our Solution** | Tri-lingual pipeline: English + Hindi + Marathi using IndicTrans2 for translation + BioMistral for medical reasoning. |
| **How It Works on Mobile** | User speaks/types in Hindi or Marathi → IndicTrans2 translates to English → English query hits RAG pipeline → BioMistral generates English response → IndicTrans2 translates response back to user's language → User sees response in their language with ICMR citation |

```
┌─────────────────┐
│ User Input       │  "मला डोकं दुखतंय आणि ताप आलाय" (Marathi)
│ (Hindi/Marathi)  │
└────────┬────────┘
         ▼
┌─────────────────┐
│ IndicTrans2      │  → "I have a headache and fever"
│ (MR → EN)        │
└────────┬────────┘
         ▼
┌─────────────────┐
│ Query Embedding  │  sentence-transformers/all-MiniLM-L6-v2
│ + Pinecone Search│  → Retrieves ICMR guidelines on fever management
└────────┬────────┘
         ▼
┌─────────────────┐
│ BioMistral 7B    │  Generates response with ICMR context
│ (4-bit quantized)│  + User health profile + Current AQI
└────────┬────────┘
         ▼
┌─────────────────┐
│ IndicTrans2      │  → Translates back to Marathi
│ (EN → MR)        │
└────────┬────────┘
         ▼
┌─────────────────┐
│ User Response    │  "तुमचा ताप आणि डोकेदुखी यासाठी ICMR नुसार..."
│ + ICMR Citation  │  [Source: ICMR Guidelines on Fever Management, Ch. 3]
└─────────────────┘
```

| Layer | Detail |
|-------|--------|
| **Dataset/Model Used** | IndicTrans2 (Gala et al., TACL 2023, arXiv:2305.16307) — trained on health-domain corpora |
| **Why 3 Languages (Not 22)?** | English = base for BioMistral; Hindi = 57% of India; Marathi = team's native language for direct validation. Architecture supports all 22 via IndicTrans2 — expansion is future scope. |
| **Validation** | Test translated medical Q&A against CLINIC benchmark (Ghosh et al., ICML 2025) for safety in Hindi/Marathi |

---

### Problem 4: Doctor Consultations Are Expensive, Inaccessible, and Reactive

| Layer | Detail |
|-------|--------|
| **Problem** | India has 1 doctor per 1,456 people (WHO recommends 1:1,000). Rural areas are worse. Patients can't visit doctors for daily questions like "Can I eat rice with my diabetes medication?" or "Is my headache related to BP?" |
| **Our Solution** | 24/7 AI health assistant that handles **daily health queries** — not replacing doctors, but reducing unnecessary visits for routine questions. |
| **How It Works** | User asks question → RAG retrieves relevant ICMR guideline → BioMistral generates response with citation → If query is high-severity (chest pain, stroke symptoms), system displays **emergency redirect** to nearest hospital/helpline |
| **Safety Guardrail** | System explicitly states: "I am an AI health assistant. For emergencies, contact your doctor or call 112." Every response includes ICMR source citation for traceability. |
| **Evidence** | eSanjeevani 163M+ teleconsultations prove digital health demand at scale (doi: 10.1016/j.hlpt.2024.100845); preventive interventions show 14.3:1 ROI (Masters et al., 2017) |

---

## 2. Complete Dataset & Data Source Registry

| # | Dataset / Source | What It Contains | How We Use It | Access |
|---|-----------------|-----------------|---------------|--------|
| 1 | **ICMR Clinical Guidelines** | NCD management protocols (diabetes, hypertension, COPD, asthma), dietary guidelines, treatment recommendations | RAG knowledge corpus — chunked, embedded, indexed in Pinecone | Public (icmr.nic.in) |
| 2 | **WAQI API** | Real-time AQI data from 1,000+ Indian CPCB stations — PM2.5, PM10, NO2, SO2, O3, CO per station | Live pollutant-level context injection into prompts | Free API (waqi.info) |
| 3 | **BioMistral 7B** | 7B-parameter medical LLM pretrained on PubMed Central | Core reasoning engine, 4-bit quantized | Open-source (HuggingFace) |
| 4 | **IndicTrans2** | NMT model for all 22 Indian languages, trained on health-domain corpora | Hindi/Marathi ↔ English translation | Open-source (AI4Bharat) |
| 5 | **MedQA Dataset** | 12,723 medical questions from USMLE | Evaluation benchmark for medical accuracy | Public (Jin et al., 2021) |
| 6 | **PubMedQA** | 1,000 expert-annotated biomedical QA pairs | Evaluation benchmark for RAG retrieval quality | Public (Jin et al., 2019) |
| 7 | **CLINIC Benchmark** | 15-language, 18-task medical safety evaluation | Multilingual safety testing for Hindi/Marathi outputs | Public (Ghosh et al., ICML 2025) |
| 8 | **sentence-transformers/all-MiniLM-L6-v2** | Lightweight sentence embedding model | Converts queries & ICMR chunks to vectors for Pinecone | Open-source (HuggingFace) |
| 9 | **Pinecone Free Tier** | Managed vector database (100K vectors free) | Stores ICMR guideline embeddings for semantic search | Free tier |
| 10 | **CPCB Air Quality Data** | Historical + real-time pollution data for Indian cities | Cross-validation of WAQI API data accuracy | Public (cpcb.nic.in) |
| 11 | **Synthetic Patient Profiles** | Team-generated test profiles (age, conditions, medications) | End-to-end pipeline testing without real patient data (IRB-safe) | Self-generated |
| 12 | **WHO/NHP Health Facts** | Disease prevalence, risk factors, prevention guidelines | Supplementary knowledge for RAG corpus | Public (WHO, NHP India) |

---

## 3. Mobile App — What Gets Tracked & Why

### 3.1 User Health Profile (One-Time Setup + Updates)

| Data Point | Why We Track It | How It Affects AI Response |
|------------|----------------|---------------------------|
| Age & Gender | NCD risk varies by demographic | Adjusts dietary/exercise recommendations per ICMR age-group guidelines |
| Known Conditions (diabetes, hypertension, asthma, etc.) | Core personalization axis | Triggers condition-specific RAG retrieval; AQI alerts tailored to conditions |
| Current Medications | Drug-diet interactions | Prevents contradictory advice (e.g., "don't recommend high-potassium foods if user takes ACE inhibitors") |
| Dietary Preferences (veg/non-veg/vegan) | Cultural relevance | Generates culturally appropriate dietary advice in vernacular |
| Location (city/pin code) | AQI station matching | Fetches nearest CPCB/WAQI monitoring station data |
| Preferred Language | Vernacular delivery | Routes through appropriate IndicTrans2 translation pair |

### 3.2 Daily Tracking (User-Initiated)

| Feature | What User Does | What System Does |
|---------|---------------|------------------|
| **Symptom Logging** | User describes symptoms in natural language (Hindi/Marathi/English) | RAG retrieves relevant ICMR protocol → generates personalized advice with citation |
| **AQI Check** | Automatic on app open (background GPS) | Fetches real-time pollutant data → alerts if thresholds exceeded for user's conditions |
| **Diet Query** | "Can I eat [food] with my [condition]?" | RAG searches ICMR dietary guidelines → generates yes/no with reasoning |
| **Medication Reminder** | Sets medication schedule | Sends push notifications at scheduled times |

### 3.3 How Mobile Tracking Creates the Personalization Loop

```
┌────────────────────────────────────────────────────────────────────┐
│                    PERSONALIZATION LOOP                             │
│                                                                    │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐     │
│  │ Health    │───▶│ Context  │───▶│ RAG +    │───▶│ Personal │     │
│  │ Profile   │    │ Builder  │    │ BioMistral│    │ Response │     │
│  │ (local)   │    │          │    │          │    │ + Citation│     │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘     │
│       ▲               ▲                                            │
│       │               │                                            │
│  ┌──────────┐    ┌──────────┐                                     │
│  │ User     │    │ WAQI API │                                     │
│  │ Input    │    │ (live)   │                                     │
│  └──────────┘    └──────────┘                                     │
│                                                                    │
│  Context = Health Profile + Current Query + Live AQI + Language    │
│  This makes EVERY response uniquely personalized to the user.      │
└────────────────────────────────────────────────────────────────────┘
```

---

## 4. Feasibility Analysis

### 4.1 Technical Feasibility

| Component | Feasibility Proof | Status |
|-----------|------------------|--------|
| **BioMistral 7B (4-bit)** | Runs on single A100 GPU. Available on E2E Networks India at ₹70/hr. Labrak et al. (ACL 2024) benchmarked multilingual medical QA performance. | ✅ Proven |
| **Pinecone Vector DB** | Free tier supports 100K vectors — sufficient for ICMR guidelines corpus (~5,000 chunks). Mozolevskyi 2024 benchmarked real-world QA performance. | ✅ Free tier available |
| **LangChain Orchestration** | Proven in 2 peer-reviewed medical chatbot publications. Handles our multi-step pipeline (translate→embed→retrieve→generate→translate). | ✅ Proven |
| **IndicTrans2** | Open-source, state-of-the-art for all 22 Indian languages. Trained on health-domain data. (Gala et al., TACL 2023) | ✅ Open-source |
| **WAQI API** | Free tier with 1,000 requests/day. Covers 1,000+ Indian CPCB stations. Real-time data with <5 second latency. | ✅ Free API |
| **RAG Pipeline** | JMIR 2026 study: FT+RAG achieves 96.7% clinical accuracy. MMed-RAG: +43.8% factual improvement. Proven architecture. | ✅ Peer-reviewed |

### 4.2 Economic Feasibility

| Cost Item | Amount | Justification |
|-----------|--------|---------------|
| BioMistral 7B license | **₹0** | Open-source (Apache 2.0) |
| IndicTrans2 license | **₹0** | Open-source (AI4Bharat, MIT License) |
| LangChain license | **₹0** | Open-source (MIT License) |
| Pinecone (free tier) | **₹0** | 100K vectors free — sufficient for prototype |
| WAQI API (free tier) | **₹0** | 1,000 requests/day free |
| E2E Networks A100 (dev/testing) | **~₹2,100** | 30 hours × ₹70/hr for development & testing |
| **Total Project Cost** | **~₹2,100** | Compare: Practo raises ₹100Cr+ for similar features |

**Economic Validation:**
- Preventive health ROI = **14.3:1** (Masters et al., JECH 2017)
- India digital health market = **$372B by 2030** (NITI Aayog)
- eSanjeevani proves demand: **163M+ consultations** on a free platform

### 4.3 Operational Feasibility — Team Skill Mapping

| Team Member | Primary Role | Key Skills | Modules Owned |
|-------------|-------------|------------|---------------|
| **Jayesh Patil** | AI/ML Lead | LLM fine-tuning, RAG architecture, prompt engineering, Python | BioMistral integration, RAG pipeline, Pinecone indexing |
| **Abhijit Patil** | Backend & API Lead | API development, database design, cloud deployment | WAQI API integration, LangChain orchestration, backend services |
| **Ritesh Pawar** | Frontend & Mobile Lead | React Native/Flutter, UI/UX, mobile app development | Mobile app, health profile UI, symptom logging interface |

| Skill Assessment | Status |
|-----------------|--------|
| All core models are **pre-trained** (BioMistral, IndicTrans2) — no training from scratch required | ✅ |
| RAG pipeline is a **proven architecture** — we are implementing, not inventing | ✅ |
| WAQI and Bhashini APIs are **well-documented** with code examples | ✅ |
| Team has completed ML coursework + prior AI project experience | ✅ |

### 4.4 Legal & Regulatory Feasibility

| Requirement | How We Comply | Status |
|-------------|--------------|--------|
| **DPDP Act 2023 — Consent** | Explicit consent screen at onboarding in user's chosen language (EN/HI/MR) | ✅ Designed |
| **DPDP Act 2023 — Data Minimization** | Store only health profile locally on device. RAG queries are stateless — no conversation history stored on server. | ✅ Architecture supports |
| **DPDP Act 2023 — Right to Erasure** | Health profile stored locally → user can delete app = data deleted. Server-side: Pinecone stores only ICMR guideline vectors (no user data). | ✅ By design |
| **Medical Disclaimer** | Every response includes: "I am an AI health assistant, not a doctor. For emergencies, call 112 or visit your nearest hospital." | ✅ Implemented |
| **ICMR Source Citation** | Every medical response includes traceable ICMR guideline reference | ✅ RAG provides source |
| **No Diagnosis / No Prescription** | System provides health information and guidance only — never diagnoses or prescribes medication | ✅ Prompt engineering enforced |

### 4.5 Schedule Feasibility — 12-Week Gantt Chart

| Phase | Weeks | Tasks | Owner | Deliverable |
|-------|-------|-------|-------|-------------|
| **Phase 1: Foundation** | W1–W2 | ICMR guidelines collection, chunking, embedding; Pinecone index setup; BioMistral 4-bit setup | Jayesh | Working RAG prototype (English only) |
| **Phase 2: Core Pipeline** | W3–W4 | LangChain pipeline integration; WAQI API integration; prompt engineering with safety guardrails | Jayesh + Abhijit | End-to-end query pipeline |
| **Phase 3: Vernacular** | W5–W6 | IndicTrans2 integration; Hindi/Marathi translation pipeline; code-mixing handling | Abhijit | Tri-lingual query support |
| **Phase 4: Mobile App** | W4–W7 | Health profile UI; symptom logging; AQI display; medication reminders | Ritesh | Functional mobile app |
| **Phase 5: Integration** | W8–W9 | Mobile ↔ Backend integration; end-to-end testing; performance optimization | All | Integrated system |
| **Phase 6: Evaluation** | W10–W11 | MedQA/PubMedQA benchmarking; CLINIC multilingual safety testing; synthetic patient testing | Jayesh + Abhijit | Evaluation report with metrics |
| **Phase 7: Documentation** | W11–W12 | Final report; presentation; demo preparation | All | Submission-ready deliverables |

---

## 5. How Each Feature Solves a Specific Problem — Evidence Chain

| # | Real-World Problem | Aarogya Sathi Feature | Technical Implementation | Dataset/API | Peer-Reviewed Evidence |
|---|-------------------|----------------------|------------------------|-------------|----------------------|
| 1 | NCDs cause 63% of Indian deaths | Personalized preventive health guidance | BioMistral + ICMR RAG + user health profile | ICMR guidelines corpus | GBD 2019 (*Lancet*) |
| 2 | PM2.5 kills 127K+ Indians/year | Real-time AQI-aware health alerts | WAQI API → pollutant parsing → context injection | WAQI API (1000+ stations) | Singh et al., 2023; Li et al., 2019 |
| 3 | 90% of India non-English | Tri-lingual AI (EN/HI/MR) | IndicTrans2 translation pipeline | IndicTrans2 model | Gala et al., TACL 2023 |
| 4 | LLMs hallucinate medical info | ICMR-grounded RAG with citations | Pinecone vector search → top-K retrieval → cited response | Pinecone + ICMR embeddings | MMed-RAG (+43.8%, ICLR 2025) |
| 5 | Doctors inaccessible (1:1,456 ratio) | 24/7 AI health assistant | Mobile app + BioMistral backend | All integrated | eSanjeevani 163M+ consultations |
| 6 | Health data privacy concerns | DPDP-compliant architecture | Local-first storage; stateless RAG queries | No user data on server | DPDP Act 2023 |
| 7 | No app combines AI+AQI+Vernacular | First-of-its-kind integration | LangChain orchestrating all components | All above | Competitor analysis (Section 5.2) |

---

## 6. What Makes This an AI/ML Capstone (Not Just an App)

> **Critical framing for evaluators:** This is NOT a simple mobile app with an API call. This is a **multi-model AI pipeline** that demonstrates 9 distinct AI/ML competencies.

| # | AI/ML Competency | What We Do | Why It's Non-Trivial |
|---|-----------------|------------|---------------------|
| 1 | **LLM Selection & Benchmarking** | Evaluated BioMistral vs MedAlpaca vs LLaMA-Med on multilingual medical QA | Requires understanding of model architectures, benchmark methodology |
| 2 | **Model Quantization** | 4-bit GPTQ quantization of 7B-parameter model | Balances inference speed vs accuracy; requires understanding of quantization theory |
| 3 | **RAG Architecture** | Designed end-to-end retrieval-augmented generation pipeline | Core ML engineering skill — embedding, retrieval, re-ranking, generation |
| 4 | **Vector Database Design** | Chunking strategy for medical guidelines; embedding model selection; index optimization | Information retrieval + NLP preprocessing |
| 5 | **Prompt Engineering** | Safety-constrained system prompts with citation requirements and hallucination prevention | Applied NLP — prompt design significantly affects output quality |
| 6 | **Multi-Model Pipeline** | Chained IndicTrans2 → BioMistral → IndicTrans2 in sequence | Pipeline orchestration, error handling across models |
| 7 | **Real-Time API Integration** | WAQI pollutant data dynamically modifies LLM context | Feature engineering from live data streams |
| 8 | **Evaluation Methodology** | MedQA + PubMedQA + CLINIC benchmark testing | ML evaluation rigor — precision, recall, safety metrics |
| 9 | **Safety Guardrails** | ICMR grounding prevents hallucination; severity detection triggers emergency redirect | AI safety — critical for healthcare applications |

---

## 7. Novelty Statement

**No existing solution in the Indian digital health market combines all six capabilities:**

| Capability | Practo | Apollo 24/7 | Tata 1mg | mFine | Ada Health | **Aarogya Sathi** |
|-----------|--------|-------------|----------|-------|------------|-------------------|
| AI/ML pipeline (RAG + LLM) | ❌ | ❌ | ❌ | Basic | Basic | **✅ Full RAG** |
| ICMR clinical grounding | ❌ | ❌ | ❌ | ❌ | ❌ | **✅** |
| Real-time AQI integration | ❌ | ❌ | ❌ | ❌ | ❌ | **✅** |
| Vernacular (Hindi + Marathi) | Limited | Limited | Limited | ❌ | ❌ | **✅** |
| Preventive (not reactive) | ❌ | ❌ | ❌ | ❌ | Limited | **✅** |
| DPDP Act compliant | Partial | Partial | Partial | Unknown | ❌ | **✅** |
| Free to user | ❌ | ❌ | ❌ | ❌ | Freemium | **✅** |

**Aarogya Sathi is the first system to combine ICMR-grounded RAG + real-time AQI awareness + vernacular delivery in a single AI pipeline for preventive NCD management in India.**
