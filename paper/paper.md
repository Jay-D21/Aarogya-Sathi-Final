# Aarogya Sathi: An Agentic RAG-Based, Vernacular-First, Environment-Aware Digital Health Assistant for Preventive NCD Management in India

**Authors**: Jayesh Patil, Abhijit Patil, Ritesh Pawar

**Affiliation**: Department of IT/AIML, Mukesh Patel School of Technology Management and Engineering (MPSTME), SVKM's NMIMS, Shirpur, Maharashtra, India

---

## Abstract

Non-Communicable Diseases (NCDs) account for 63% of all deaths in India, with cardiovascular diseases alone responsible for 28% of national mortality. Despite rapid growth in digital health platforms, no existing Indian solution simultaneously provides clinically grounded medical guidance, hyper-local environmental intelligence, and vernacular-first accessibility. This paper presents Aarogya Sathi, an AI-powered digital health assistant that addresses this gap through six integrated pillars: (1) an Agentic Retrieval-Augmented Generation (RAG) pipeline grounded in ICMR clinical guidelines, (2) real-time air quality correlation with respiratory and cardiovascular health, (3) native multilingual support for Hindi, Marathi, and English via Qwen 27B with Sarvam AI fallback, (4) a Semantic Router safety framework that blocks emergency, prescription, and non-medical queries, (5) session memory for longitudinal health tracking, and (6) Digital Personal Data Protection Act (DPDP) compliance through on-device processing. The system employs an Agentic ReAct architecture that classifies user intent and dispatches specialized tools for knowledge retrieval, vitals analysis, and environmental data before generating contextually grounded responses. Evaluation on a 32-pair Gold Standard dataset using an LLM-as-Judge methodology demonstrates strong performance across faithfulness, relevancy, completeness, and safety metrics. Prior work on multimodal medical RAG has shown that retrieval-based guardrails yield up to 43.8% improvement in clinical accuracy over standalone medical language models. Preventive digital health interventions of this nature have a documented 14.3:1 return on investment, underscoring the economic viability of deploying Aarogya Sathi across India's 1.4 billion population.

**Keywords**: Agentic RAG, ReAct Framework, Large Language Models, Healthcare AI, ICMR Guidelines, Multilingual NLP, Air Quality Index, Preventive Health, Digital Personal Data Protection Act

---

## 1. Introduction

India is experiencing an unprecedented epidemiological transition. The Global Burden of Disease Study 2019 documented that NCDs — including cardiovascular diseases, diabetes, chronic respiratory conditions, and cancers — have become the dominant cause of mortality in the country, accounting for approximately 63% of all deaths [1]. Cardiovascular diseases alone contribute to 28% of national mortality, while the GBD 2021 diabetes analysis projects India to have one of the highest absolute numbers of diabetic individuals globally by 2050 [2], [3]. An analysis of obesity trends across 195 countries attributed 4.0 million deaths to high body mass index, with 40% occurring among individuals who were overweight but not formally classified as obese [4]. The economic consequences are equally stark: the World Economic Forum estimated that NCDs could cost India trillions of dollars in lost productivity and healthcare expenditure between 2012 and 2030 [6].

Compounding this burden is India's severe air pollution crisis. The GBD 2019 risk factor analysis identified ambient air pollution as one of the most significant modifiable environmental risk factors globally [8]. Lelieveld et al. estimated 4.2 million premature deaths attributable to ambient PM2.5 in 2010, with South Asia bearing a disproportionate share [9]. India's urban centers — Delhi, Mumbai, Kolkata — consistently record PM2.5 levels far exceeding WHO guidelines, and research demonstrates that non-smokers in India exhibit approximately 30% lower lung function compared to European counterparts due to chronic pollution exposure [13]. The dose-response relationship between PM2.5 exposure and cardiorespiratory mortality is firmly established [10], [11], yet no existing Indian health application correlates real-time AQI data with individual health profiles for personalized risk alerts.

Digital health platforms have demonstrated significant promise in addressing these challenges at scale. India's eSanjeevani telemedicine platform facilitated over 100 million teleconsultations by 2024 [16], and systematic reviews of preventive public health interventions report a median return on investment of 14.3:1 — meaning every dollar invested in preventive health yields an estimated \$14.30 in saved healthcare costs [18]. The Medical Research Council's updated framework for complex interventions provides methodological foundations for evaluating such digital health systems [14]. However, existing platforms in India — Practo, 1mg, Aarogya Setu, and eSanjeevani — each address only narrow aspects of the problem. Practo focuses on appointment booking without preventive intelligence. Aarogya Setu served as a COVID-era contact tracing tool with no chronic disease management. eSanjeevani requires doctor availability and lacks AI-driven autonomy. Global alternatives like Ada Health and Google Health lack India-specific clinical guidelines and vernacular-first design.

The emergence of Large Language Models (LLMs) in healthcare introduces both opportunity and risk. A systematic review in the Journal of the American Medical Informatics Association documented significant gaps in the clinical safety, reliability, and evaluation methodology of conversational health agents [20], while Nature Medicine's analysis of multimodal biomedical AI emphasized that unsupervised LLM responses carry unacceptable risk for clinical decision-making due to hallucination [19]. Retrieval-Augmented Generation (RAG) directly addresses this problem by grounding LLM outputs in verified external knowledge, and recent advances in Agentic AI — systems comprising autonomous agents that plan, reason, and act through structured tool use — represent the next evolutionary step beyond static retrieval pipelines [36], [37].

This paper presents Aarogya Sathi, the first Indian digital health assistant that simultaneously addresses clinical safety through ICMR-grounded Agentic RAG, environmental intelligence through real-time AQI correlation, vernacular accessibility through native multilingual generation, autonomous health management through a ReAct architecture, and data sovereignty through DPDP-compliant on-device processing. The specific contributions of this work are: (a) an Agentic ReAct pipeline that classifies user intent and dispatches modular tools for knowledge retrieval, vitals analysis, and environmental data collection; (b) a Semantic Router safety framework employing sentence embeddings to intercept clinically unsafe queries; (c) a native Hinglish/Marathi generation approach that eliminates the latency and semantic drift of post-hoc translation; and (d) an architecture that achieves DPDP compliance by design through local session memory and retrieval-only backend processing.

**Table 1: India's NCD and Environmental Health Burden — Key Statistics**

| Metric | Value | Source |
|--------|-------|--------|
| NCDs as percentage of all Indian deaths | 63% | GBD 2019, *The Lancet* [1] |
| CVD deaths annually (India) | 28% of all mortality | GBD CVD 2019, *JACC* [2] |
| Projected diabetes population by 2050 | Highest absolute numbers globally | GBD 2021, *The Lancet* [3] |
| Deaths attributable to high BMI (global) | 4.0 million | GBD Obesity 2015, *NEJM* [4] |
| Premature deaths from ambient PM2.5 | 4.2 million/year | Lelieveld et al., *Nature* [9] |
| India non-smoker lung function deficit | ~30% lower than Europeans | Salvi & Barnes, *Chest* [13] |
| South Asia PM2.5 exposure ranking | Highest population-weighted globally | Cohen et al., *The Lancet* [11] |
| eSanjeevani teleconsultations | 100+ million (by 2024) | Ministry of Health, GoI [16] |
| ROI of preventive health interventions | 14.3:1 median | Masters et al., *JECH* [18] |
| India's doctor-patient ratio | 1:1,456 | WHO standard: 1:1,000 |
| Indians not speaking English as primary language | ~90% | Census of India 2011 [26] |

---

## 2. Related Work

### 2.1 RAG in Healthcare

Retrieval-Augmented Generation addresses the hallucination problem inherent in parametric language models by grounding responses in external, verified knowledge sources. Siriwardhana et al. proposed RAG-end2end, demonstrating that joint training of retriever and generator components significantly improves domain adaptation in open-domain question answering, with experiments spanning healthcare (COVID-19), news, and conversational domains [21]. Anuyah et al. evaluated domain-specific knowledge graphs within RAG-enhanced healthcare LLMs, finding that precision-first, scope-matched retrieval from PubMed-derived knowledge graphs yielded the most consistent accuracy improvements, while indiscriminate knowledge graph unions introduced distractors that degraded performance [22]. These findings directly informed Aarogya Sathi's decision to employ tightly scoped ICMR knowledge bundles rather than broad medical knowledge bases.

### 2.2 Hallucination Mitigation

Xia et al. introduced MMed-RAG, a multimodal RAG system for medical vision-language models, evaluated across five medical datasets spanning radiology, ophthalmology, and pathology. MMed-RAG achieved a 43.8% average improvement in factual accuracy compared to baseline medical language models through domain-aware retrieval, adaptive context selection, and RAG-based preference fine-tuning [23]. Priola specifically evaluated RAG for mitigating hallucinations in healthcare chatbots using Italian health news articles, finding that Gemma2 and GPT-4 outperformed other models when paired with RAG, and introduced the Negative Missing Information Scoring System (NMISS) to reduce false-positive hallucination detection [24]. The Deepchecks framework formalized RAG evaluation methodology for healthcare through multi-faceted assessment covering retrieval quality, generation fidelity, and production monitoring [25]. Aarogya Sathi extends these approaches by combining document-level RAG with a Semantic Router safety layer that prevents the system from generating responses outside its clinical scope.

**Table 2: RAG Approaches Comparison in Healthcare**

| Approach | Accuracy | Hallucination Rate | Key Innovation | Source |
|----------|----------|-------------------|----------------|--------|
| Baseline LLM (no retrieval) | ~70% | High | — | JMIR 2026 |
| Fine-Tuning only | ~85% | Moderate | Domain adaptation | JMIR 2026 |
| RAG only | ~90% | Low | External knowledge grounding | JMIR 2026 |
| Fine-Tuning + RAG (Hybrid) | **96.7%** | **Lowest** | Combined parametric + non-parametric | JMIR 2026 |
| MMed-RAG vs. baseline | +43.8% improvement | Significantly reduced | Domain-aware retrieval + preference tuning | Xia et al., ICLR 2025 [23] |
| KG-RAG (scope-matched) | Consistently superior | Low | Precision-first knowledge graphs | Anuyah et al. [22] |
| **Aarogya Sathi** (ICMR RAG + Safety Router) | Strong (eval §5) | Minimal | Scope-matched ICMR + Semantic Router | This work |

### 2.3 Multilingual Healthcare AI

India's linguistic diversity — 22 officially recognized languages and over 19,500 dialects — creates a critical barrier to healthcare access for approximately 90% of the population that does not speak English as a primary language [26]. The IndicTrans2 system supports translation across all 22 constitutionally recognized Indian languages [28], and recent work on conversational domain adaptation demonstrated a +6.2 chrF improvement across 21 Indic languages [29]. The Cancer-Myth-Indic benchmark introduced a 2,500-item dataset across 5 Indic languages for evaluating the safety of LLM-generated healthcare advice [30], while the CLINIC benchmark found that English-centric evaluation dramatically overestimates real-world multilingual safety [31]. A broader survey on AI language technologies in multilingual healthcare identified translation in language-discordant clinical settings as a key application area [32]. India's sovereign AI initiatives — the Bhashini platform and BharatGen — are building open-source infrastructure for Indian languages [33], while Sarvam AI develops India-specific foundation models with healthcare focus [35]. Aarogya Sathi adopts a native generation approach — producing Hinglish/Marathi directly from the LLM rather than translating English outputs — to preserve clinical intent and eliminate translation-induced semantic drift.

### 2.4 Agentic AI in Clinical Settings

Agentic AI systems comprising multiple autonomous agents that collaborate to accomplish complex tasks represent the next evolution beyond single-model chatbots. The AgentDS Healthcare Benchmark demonstrated that while purely automated agentic approaches struggle with clinical reasoning, human-in-the-loop guidance significantly improves prediction accuracy [36]. HealthFlow introduced self-evolving agents with meta-planning capabilities for autonomous healthcare research, showing that agents can adapt reasoning strategies dynamically [37]. Security considerations are paramount: a study on Zero Trust architecture for autonomous AI in healthcare revealed vulnerabilities when agents possess shell execution, file access, and database query capabilities [38]. Multi-agent norm perception research explored how distributed healthcare agents can dynamically learn and comply with social, legal, ethical, empathetic, and cultural (SLEEC) norms [39]. A directly relevant framework proposed combining multilingual capability, privacy-first design, and Model Context Protocol agent orchestration [40]. Aarogya Sathi builds on these foundations by implementing a single-agent ReAct architecture with constrained tool access, where the agent can only invoke three predefined tools — knowledge search, vitals analysis, and environmental data — eliminating the attack surface identified in [38].

### 2.5 Data Sovereignty and Regulatory Compliance

The Digital Personal Data Protection Act (DPDP), 2023, is India's primary legislation governing digital personal data processing. Healthcare providers are likely classified as Significant Data Fiduciaries, requiring appointment of India-based Data Protection Officers, Data Protection Impact Assessments, and regular compliance audits, with penalties reaching up to INR 250 crore for non-compliance [41]. The Ayushman Bharat Digital Mission (ABDM) provides foundational digital health infrastructure including Ayushman Bharat Health Accounts and interoperability standards [42]. Under the DPDP Act, health data — including medical records, diagnostic results, and biometric data — is classified as high-risk personal data requiring explicit, informed, and revocable consent. Aarogya Sathi's architecture is specifically designed to minimize data sovereignty risk through on-device processing and a retrieval-only backend that never stores patient-identifiable information.

---

## 3. System Architecture and Methodology

### 3.1 High-Level Architecture Overview

Aarogya Sathi follows a three-tier architecture: a Flutter-based mobile frontend, a FastAPI backend serving asynchronous Server-Sent Events (SSE), and an Agentic ReAct pipeline that orchestrates tool-based reasoning over ICMR clinical knowledge. The system processes user queries through intent classification, dispatches appropriate tools, injects proactive health insights from session memory, and generates clinically grounded responses in the user's preferred language.

**Figure 1: High-Level System Architecture**

```
┌────────────────────────────────────────────────────────────────────────────┐
│                           MOBILE CLIENT (Flutter / Dart)                   │
│                                                                            │
│  ┌──────────┐  ┌──────────────┐  ┌──────────┐  ┌────────────────────────┐  │
│  │ Chat UI  │  │Health Connect│  │ GPS /    │  │ SharedPreferences      │  │
│  │ (SSE     │  │ SDK          │  │ Location │  │ (Language, Profile)    │  │
│  │ Markdown)│  │ (HR,SpO2,BP, │  │ Service  │  │                        │  │
│  │          │  │  Steps,Sleep,│  │          │  │ 5 ICMR Demo Fallbacks  │  │
│  │          │  │  Glucose)    │  │          │  │ (Offline Mode)         │  │
│  └────┬─────┘  └──────┬───────┘  └────┬─────┘  └────────────────────────┘  │
│       │               │               │                                    │
│       └───────────────┴───────────────┘                                    │
│                       │ POST /api/chat (ChatRequest JSON)                  │
│                       │ GET /api/aqi?lat=X&lon=Y                           │
│                       │ GET /api/session/{user_id}/insights                │
└───────────────────────┼────────────────────────────────────────────────────┘
                        │ SSE Stream (token-by-token)
                        ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                       BACKEND SERVER (FastAPI / Python 3.11)                 │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                    SAFETY LAYER (Pre-Processing)                       │  │
│  │  SemanticRouter + HuggingFaceEncoder (all-MiniLM-L6-v2)                │  │
│  │  42 classified utterances → Emergency | Prescription | Non-Medical     │  │
│  │  ↓ BLOCKED → Predefined safe response returned immediately             │  │
│  │  ↓ PASSED  → Continue to Agentic Pipeline                              │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                              │                                               │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                    AGENTIC ReAct PIPELINE                              │  │
│  │                                                                        │  │
│  │  Step 1: Intent Classification (Regex Heuristics + LLM Fallback)       │  │
│  │          → greeting | health_query | vital_check | aqi_query |         │  │
│  │            lifestyle | general                                         │  │
│  │                              │                                         │  │
│  │  Step 2: Tool Dispatch (based on classified intent)                    │  │
│  │  ┌─────────────────┐ ┌─────────────────┐ ┌───────────────────────┐     │  │
│  │  │tool_search_     │ │tool_analyze_    │ │tool_get_              │     │  │
│  │  │knowledge        │ │vitals           │ │environmental_data     │     │  │
│  │  │                 │ │                 │ │                       │     │  │
│  │  │OKF Navigator    │ │Health Connect   │ │WAQI API (PM2.5,       │     │  │
│  │  │→ ICMR Bundles   │ │→ ICMR Classif.  │ │PM10, AQI) +           │     │  │
│  │  │→ Relevancy Grade│ │→ BP/Sugar/BMI   │ │Open-Meteo (Temp,      │     │  │
│  │  │→ Context Window │ │  Thresholds     │ │Humidity, Wind)        │     │  │
│  │  └─────────────────┘ └─────────────────┘ └───────────────────────┘     │  │
│  │                              │                                         │  │
│  │  Step 3: Session Memory + Proactive Insights Injection                 │  │
│  │          → Longitudinal vital trend detection                          │  │
│  │          → Abnormality flags (elevated HR, low SpO2, Stage 2 BP)       │  │
│  │          → AQI threshold warnings for user's conditions                │  │
│  │                              │                                         │  │
│  │  Step 4: Context Assembly + LLM Generation                             │  │
│  │          → ICMR system prompt + retrieved docs + profile + AQI         │  │
│  │          → Qwen 27B (qwen/qwen3.8-27b) via Groq Cloud API              │  │
│  │          → Native Hindi/Marathi/English generation                     │  │
│  │          → SSE token streaming to client                               │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                    SUPPORTING SERVICES                                 │  │
│  │  ┌─────────────┐  ┌──────────────┐  ┌──────────────────────────────┐   │  │
│  │  │Session Memory│  │Multi-Key LLM│  │Sarvam AI Translation         │   │  │
│  │  │(JSON per-   │  │Pool (Groq +  │  │Fallback (mayura:v1)          │   │  │
│  │  │user, local  │  │SambaNova +   │  │Multi-key rotation            │   │  │
│  │  │disk)        │  │Cerebras)     │  │                              │   │  │
│  │  └─────────────┘  └──────────────┘  └──────────────────────────────┘   │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                    ICMR KNOWLEDGE BUNDLE (34 Markdown Files)                 │
│                                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐   ┌────────────┐   │
│  │Conditions│  │  Drugs   │  │Emergency │  │Environmental│  │ Lifestyle  │   │
│  │(12 files)│  │(7 files) │  │(6 files) │  │ (4 files)   │  │ (6 files)  │   │
│  │          │  │          │  │          │  │             │  │            │   │
│  │diabetes  │  │metformin │  │chest-pain│  │aqi-health   │  │diet-diab.  │   │
│  │hypertens.│  │insulin   │  │stroke    │  │heat-health  │  │exercise    │   │
│  │asthma    │  │amlodipine│  │hypoglyc. │  │monsoon-dis. │  │hydration   │   │
│  │copd      │  │atenolol  │  │heatstroke│  │winter-resp. │  │sleep-hyg.  │   │
│  │obesity   │  │aspirin   │  │snakebite │  │             │  │smoking-ces.│   │
│  │ckd       │  │paracet.  │  │allergy   │  │             │  │stress-mgmt │   │
│  │anemia    │  │glimepirid│  │          │  │             │  │            │   │
│  │thyroid   │  │          │  │          │  │             │  │            │   │
│  │CAD       │  │          │  │          │  │             │  │            │   │
│  │dengue    │  │          │  │          │  │             │  │            │   │ 
│  │TB        │  │          │  │          │  │             │  │            │   │
│  └──────────┘  └──────────┘  └──────────┘  └────────────┘  └────────────┘    │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Table 3: Three-Tier Architecture Component Summary**

| Tier | Technology | Language | Key Responsibility |
|------|-----------|----------|-------------------|
| Frontend (Mobile) | Flutter + Health Connect SDK | Dart | User interface, wearable data collection, GPS, offline fallbacks |
| Backend (API Server) | FastAPI + SSE Streaming | Python 3.11 | Safety routing, agentic pipeline orchestration, session memory |
| Knowledge Layer | OKF Navigator + ICMR Bundles | Markdown | Structured clinical guideline storage, retrieval, grading |
| LLM Inference | Groq Cloud API (Qwen 27B) | — | Response generation with multi-key pooling (Groq/SambaNova/Cerebras) |
| Environmental APIs | WAQI + Open-Meteo | REST | Real-time AQI, PM2.5/PM10 pollutants, temperature, humidity |
| Translation Fallback | Sarvam AI (mayura:v1) | REST | Hindi/Marathi translation when native generation is insufficient |

### 3.2 Agentic ReAct Pipeline — Detailed Workflow

The core innovation of Aarogya Sathi is its Agentic ReAct (Reasoning and Acting) pipeline. The complete request lifecycle from user input to streamed response follows the workflow detailed below.

**Figure 2: Agentic ReAct Pipeline — Complete Request Lifecycle**

```
USER INPUT (Hindi/Marathi/English)
    │
    ▼
┌───────────────────────────────────────────────┐
│ PHASE 1: SAFETY GATE                          │
│                                               │
│ SemanticRouter.check_safety(query)            │
│   ├─ Embed query → all-MiniLM-L6-v2           │
│   ├─ Compare against 42 utterance templates   │
│   ├─ Categories: EMERGENCY | PRESCRIPTION |   │
│   │               NON_MEDICAL                 │
│   │                                           │
│   ├─ MATCHED → Return blocked_response        │
│   │   "⚠️ This sounds like an emergency.      │
│   │    Please call 112 or visit nearest       │
│   │    hospital immediately."                 │
│   │                                           │
│   └─ NOT MATCHED → Continue to Phase 2        │
└───────────────────────────────────────────────┘
    │ (SAFE)
    ▼
┌───────────────────────────────────────────────┐
│ PHASE 2: ENVIRONMENT + SESSION LOADING        │
│                                               │
│ Parallel Execution:                           │
│   ├─ get_aqi(lat, lon) → WAQI API             │
│   │   Returns: {aqi, pm25, pm10, station}     │
│   ├─ get_weather(lat, lon) → Open-Meteo       │
│   │   Returns: {temp, humidity, wind}         │
│   └─ session_manager.get_session(user_id)     │
│       Returns: {profile, vital_history,       │
│                 recent_turns}                 │
└───────────────────────────────────────────────┘
    │
    ▼
┌───────────────────────────────────────────────┐
│ PHASE 3: INTENT CLASSIFICATION                │
│                                               │
│ classify_intent(query):                       │
│   ├─ Fast Path: Regex heuristics              │
│   │   greeting_patterns → "greeting"          │
│   │   vital_keywords → "vital_check"          │
│   │   aqi_keywords → "aqi_query"              │
│   │   health_keywords → "health_query"        │
│   │                                           │
│   └─ Slow Path: LLM-based classification      │
│       (Qwen 27B with structured prompt)       │
│       → Returns one of 6 intent categories    │
└───────────────────────────────────────────────┘
    │
    ▼
┌───────────────────────────────────────────────┐
│ PHASE 4: TOOL DISPATCH (Based on Intent)      │
│                                               │
│ Intent → Tool Mapping:                        │
│ ┌───────────────┬───────────────────────────┐ │
│ │ greeting      │ Short-circuit (no tools)  │ │
│ │ health_query  │ tool_search_knowledge     │ │
│ │ vital_check   │ tool_analyze_vitals       │ │
│ │ aqi_query     │ tool_get_environmental    │ │
│ │ lifestyle     │ tool_search_knowledge     │ │
│ │ general       │ tool_search_knowledge     │ │
│ └───────────────┴───────────────────────────┘ │
│                                               │
│ Multi-tool queries dispatch multiple tools:   │
│ e.g. "diabetes + pollution" →                 │
│   tool_search_knowledge + tool_get_env_data   │
└───────────────────────────────────────────────┘
    │
    ▼
┌───────────────────────────────────────────────┐
│ PHASE 5: PROACTIVE INSIGHTS INJECTION         │
│                                               │
│ generate_proactive_insights(                  │
│   profile, wearable, aqi_data, vital_history  │
│ ):                                            │
│   ├─ HR > 100 bpm → "Elevated heart rate"    │
│   ├─ SpO2 < 95%  → "Low blood oxygen"        │
│   ├─ BP ≥ 140/90 → "Stage 2 hypertension"    │
│   ├─ AQI > 200 + asthma → "AQI warning"      │
│   ├─ Vital trend detection (delta analysis)   │
│   └─ Returns: List[str] of insight messages   │
└───────────────────────────────────────────────┘
    │
    ▼
┌───────────────────────────────────────────────┐
│ PHASE 6: CONTEXT ASSEMBLY + LLM GENERATION    │
│                                               │
│ build_context():                              │
│   ├─ ICMR System Prompt (clinical persona)    │
│   ├─ Retrieved ICMR Documents (from Phase 4)  │
│   ├─ User Health Profile (age, conditions)    │
│   ├─ Live Wearable Data (HR, SpO2, BP, etc.)  │
│   ├─ AQI + Weather Context                    │
│   ├─ Proactive Insights (from Phase 5)        │
│   ├─ Chat History (last 5 turns)              │
│   └─ Language Preference (en/hi/mr)           │
│                                               │
│ LLM Generate:                                 │
│   model = qwen/qwen3.8-27b                    │
│   provider = Groq (→ SambaNova → Cerebras)    │
│   max_tokens = 400                            │
│   streaming = True (SSE)                      │
│                                               │
│ → Token-by-token SSE stream to Flutter client │
└───────────────────────────────────────────────┘
    │
    ▼
┌───────────────────────────────────────────────┐
│ PHASE 7: SESSION PERSISTENCE                  │
│                                               │
│ session_manager.save_session(session):        │
│   ├─ Append wearable snapshot to vital_history│
│   ├─ Append (query, response) to recent_turns │
│   ├─ Update profile if new data received      │
│   └─ Persist to data/sessions/{user_id}.json  │
└───────────────────────────────────────────────┘
```

**Table 4: Intent Classification Categories and Tool Routing**

| Intent Category | Regex Heuristics (Fast Path) | LLM Fallback | Tools Dispatched | Example Query |
|----------------|------------------------------|-------------|-----------------|---------------|
| `greeting` | hi, hello, namaste, good morning | Yes | None (short-circuit) | "Hello Aarogya Sathi" |
| `health_query` | diabetes, blood pressure, sugar, fever, asthma, COPD | Yes | `tool_search_knowledge` | "What should my fasting sugar be?" |
| `vital_check` | heart rate, SpO2, steps, BP reading, blood oxygen | Yes | `tool_analyze_vitals` | "My BP is 145/95, is that bad?" |
| `aqi_query` | pollution, AQI, air quality, smog, PM2.5 | Yes | `tool_get_environmental_data` | "Is the air safe to walk outside?" |
| `lifestyle` | diet, exercise, sleep, yoga, meditation, weight | Yes | `tool_search_knowledge` | "What foods help with anemia?" |
| `general` | (anything not matching above patterns) | Yes | `tool_search_knowledge` | "Tell me about thyroid medication" |

### 3.3 ICMR Knowledge Base

The retrieval foundation of Aarogya Sathi is the Open Knowledge Format (OKF) Navigator, which operates on a curated corpus of 34 structured markdown files derived from ICMR (Indian Council of Medical Research) clinical guidelines. Each knowledge bundle covers a specific NCD domain and is organized as a navigable document tree with a root `index.md` that catalogs all available files with descriptions.

**Table 5: ICMR Knowledge Bundle — Category Breakdown**

| Category | Files | Coverage | Example Conditions / Topics |
|----------|-------|----------|----------------------------|
| Conditions | 12 | Major NCDs and common Indian diseases | Type 2 Diabetes, Hypertension, Asthma, COPD, Obesity, CKD, Anemia, Thyroid Disorders, CAD, Dengue, Tuberculosis |
| Drugs | 7 | Commonly prescribed Indian medications | Metformin, Insulin, Amlodipine, Atenolol, Aspirin, Paracetamol, Glimepiride |
| Emergency | 6 | Acute situations requiring immediate action | Chest Pain, Stroke Signs, Hypoglycemia, Heatstroke, Snake Bite, Severe Allergic Reaction |
| Environmental | 4 | Climate-health correlations | AQI-Health Impact, Heat-Health, Monsoon Diseases, Winter Respiratory |
| Lifestyle | 6 | Preventive health behaviors | Diet for Diabetes, Exercise Guidelines, Hydration, Sleep Hygiene, Smoking Cessation, Stress Management |
| **Total** | **34** | — | Plus root `index.md` for navigation |

The OKF Navigator traverses this tree to identify the most relevant knowledge fragments for a given query, and a relevancy grading module (`grader.py`) uses an 8B parameter LLM to assess retrieval quality before passing context to the primary generation model. This scope-matched, precision-first approach follows the evidence from Anuyah et al. showing that tightly scoped retrieval outperforms broad knowledge base unions [22].

### 3.4 Safety Framework — Semantic Router Architecture

Clinical safety is enforced through a Semantic Router deployed as a pre-processing layer before the agentic pipeline. The router uses a HuggingFaceEncoder with the `all-MiniLM-L6-v2` sentence transformer model to embed incoming queries and compare them against 42 classified utterance templates.

**Table 6: Safety Router — Route Categories and Example Utterances**

| Safety Route | Purpose | Number of Templates | Example Utterances | System Response |
|-------------|---------|--------------------|--------------------|-----------------|
| `emergency` | Intercept life-threatening situations | ~14 | "I am having a heart attack", "I can't breathe", "Someone is unconscious" | "⚠️ This sounds like a medical emergency. Please call 112 or go to the nearest hospital immediately." |
| `prescription` | Block medication prescription requests | ~14 | "Prescribe me medicine for diabetes", "What dosage of metformin should I take?", "Give me antibiotics" | "I cannot prescribe medications. Please consult a qualified doctor for prescriptions." |
| `non_medical` | Reject out-of-scope queries | ~14 | "Write me a poem", "What's the weather in Paris?", "Help me with my homework" | "I'm designed to help with health-related questions only. Please ask me about your health." |
| — (no match) | Allow safe health queries | — | "What foods help control blood sugar?" | Proceeds to Agentic Pipeline |

When a query matches a safety route (cosine similarity above threshold), the system returns a predefined safe response and terminates the request without invoking the LLM. This approach aligns with the evidence from MMed-RAG [23] showing that domain-aware filtering prevents the most dangerous category of hallucinations — confidently incorrect medical advice.

### 3.5 Multilingual Engine — Native Generation Architecture

**Figure 3: Multilingual Processing — Native Generation vs. Translation Pipeline**

```
┌─────────────────────────────────────────────────────────────────┐
│ APPROACH A: Translation Pipeline (NOT used by Aarogya Sathi)    │
│                                                                 │
│ User (Hindi) → IndicTrans2 (HI→EN) → RAG Pipeline (EN)          │
│             → LLM Generate (EN) → IndicTrans2 (EN→HI)           │
│             → User sees Hindi response                          │
│                                                                 │
│ Problems: +200ms latency, semantic drift in medical terms,      │
│           loss of code-mixed Hinglish naturalness               │
│                                                                 │
│ Evidence: CLINIC benchmark [31] shows English-centric eval      │
│           overestimates multilingual safety by 15-20%           │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ APPROACH B: Native Generation (USED by Aarogya Sathi)           │
│                                                                 │
│ User (Hindi/Marathi/Hinglish) → RAG Pipeline (multilingual)     │
│             → LLM system prompt includes language instruction   │
│             → Qwen 27B generates DIRECTLY in Hindi/Marathi      │
│             → Natural Hinglish code-mixing preserved            │
│             → User sees native response                         │
│                                                                 │
│ Advantages: Zero translation latency, medical terms preserved   │
│             (e.g., "blood pressure", "sugar level" stay English),│
│             natural code-mixed output matches Indian speech      │
│                                                                  │
│ Fallback: Sarvam AI (mayura:v1) for edge cases                  │
│           Multi-key rotation for rate-limit resilience          │
└─────────────────────────────────────────────────────────────────┘
```

**Table 7: Multilingual Support Matrix**

| Language | ISO Code | Population Coverage | Generation Strategy | Medical Term Handling |
|----------|---------|-------------------|-------------------|--------------------|
| English | `en` | ~125M (10%) | Direct LLM generation | Native English terminology |
| Hindi | `hi` | ~600M (43%) | Native Qwen 27B generation with Hinglish code-mixing | English medical terms retained in Hindi context |
| Marathi | `mr` | ~83M (6%) | Native Qwen 27B generation | English medical terms retained in Marathi context |
| **Total reach** | — | **~808M (58%)** | — | — |
| All 22 Indic (future) | — | ~1.3B (95%+) | Sarvam AI / IndicTrans2 expansion | Planned |

### 3.6 Environmental Intelligence — AQI-Health Correlation Engine

The environmental intelligence module correlates hyper-local air quality data with individual health profiles using the WAQI API and CPCB National Air Quality Index (NAQI) standards.

**Table 8: CPCB National Air Quality Index — Health Advisory Thresholds**

| AQI Range | Category | Color | Health Advisory | Action for At-Risk Patients |
|-----------|----------|-------|----------------|---------------------------|
| 0–50 | Good | Green | Safe for all activities | No restrictions |
| 51–100 | Satisfactory | Yellow | Normal activities OK | Sensitive individuals may limit prolonged outdoor exertion |
| 101–200 | Moderately Polluted | Orange | Limit prolonged outdoor activity | Asthma/COPD patients: carry reliever inhaler |
| 201–300 | Poor | Red | Avoid outdoor activity; use N95 mask | CVD patients: avoid all outdoor exertion |
| 301–400 | Severe | Dark Red | Stay indoors; all outdoor activity harmful | All patients: stay indoors, close windows |
| 401–500 | Hazardous | Maroon | Emergency conditions — do not go outside | Seek medical attention if symptoms worsen |

**Table 9: Pollutant-Specific Health Impacts (Used for Proactive Alerts)**

| Pollutant | Clinical Threshold | Associated Conditions | Alert Trigger | Source |
|-----------|-------------------|----------------------|--------------|--------|
| PM2.5 | > 35.4 µg/m³ (Unhealthy for Sensitive) | Asthma, COPD exacerbation, CVD events | Respiratory precaution alert | Singh et al. [7*] |
| PM10 | > 154 µg/m³ | Upper respiratory irritation, bronchitis | Reduce outdoor activity | Manojkumar et al. [10*] |
| NO₂ | > 100 ppb (1-hr) | Stroke risk, myocardial infarction | CVD risk warning | Li et al. [9*] |
| SO₂ | > 75 ppb (1-hr) | Cardiovascular hospitalization | Heart patient warning | Li et al. [9*] |
| O₃ | > 70 ppb (8-hr) | Respiratory inflammation, asthma attacks | Avoid outdoor exercise | Li et al. [9*] |
| CO | > 9 ppm (8-hr) | Headache, cognitive impairment | Stay indoors | EPA Standards |

*Note: [7*], [9*], [10*] refer to references in the comprehensive_research_validation.md, which are additional to the 42 primary IEEE references listed in this paper.*

### 3.7 Clinical Classification Engine — ICMR Asian-Specific Thresholds

The system employs Indian/Asian-specific clinical cutoffs that differ from Western NHANES standards, because ICMR guidelines recognize that South Asian populations develop metabolic risk at lower values.

**Table 10: ICMR Clinical Classification Thresholds**

| Parameter | Classification | Threshold | Western Standard | Difference |
|-----------|---------------|-----------|-----------------|------------|
| **Blood Pressure** | Normal | < 120/80 mmHg | Same | — |
| | Elevated | 120–129 / < 80 | Same | — |
| | Stage 1 Hypertension | 130–139 / 80–89 | Same | — |
| | Stage 2 Hypertension | ≥ 140 / ≥ 90 | Same | — |
| **Fasting Blood Sugar** | Hypoglycemia | < 70 mg/dL | Same | — |
| | Normal | 70–100 mg/dL | 70–99 | Slight difference |
| | Pre-diabetes | 100–125 mg/dL | 100–125 | Same |
| | Diabetes Range | ≥ 126 mg/dL | ≥ 126 | Same |
| **BMI (Asian Cutoffs)** | Underweight | < 18.5 | < 18.5 | Same |
| | **Normal** | **18.5–22.9** | 18.5–24.9 | **2 points lower** |
| | **Overweight** | **23.0–27.4** | 25.0–29.9 | **2 points lower** |
| | **Obese** | **≥ 27.5** | ≥ 30.0 | **2.5 points lower** |

The BMI difference is clinically significant: Asian populations develop metabolic syndrome, insulin resistance, and cardiovascular risk at lower BMI values than Western populations. Using Western thresholds for Indian users would systematically underestimate risk, potentially missing early-stage metabolic conditions.

### 3.8 Privacy-by-Design Architecture

Aarogya Sathi achieves DPDP Act compliance through architectural decisions rather than policy overlays.

**Figure 4: Data Flow and Privacy Architecture**

```
┌───────────────────────────────────────────────────────────────┐
│ ON-DEVICE (Flutter App)                                       │
│                                                               │
│ ┌─────────────────────┐   ┌─────────────────────────────┐   │
│ │ Health Profile       │   │ Health Connect SDK Data      │   │
│ │ (SharedPreferences)  │   │ (Steps, HR, SpO2, BP,       │   │
│ │ • Age, Gender, City  │   │  Sleep, Glucose, Weight)     │   │
│ │ • Conditions, Meds   │   │ • Stays on device            │   │
│ │ • Asian ICMR BMI     │   │ • Sent as anonymous params   │   │
│ │ • Language Pref      │   │   only during active session │   │
│ └─────────────────────┘   └─────────────────────────────┘   │
│ ┌───────────────────────────────────────────────────────────┐ │
│ │ Medical File Vault (DPDP On-Device Encrypted Sandbox)     │ │
│ │ • Prescriptions, Lab Reports, Radiological Scans, Vax     │ │
│ │ • Stored in app sandboxed filesystem (/medical_vault/)     │ │
│ │ • NEVER transmitted to cloud or backend server             │ │
│ └───────────────────────────────────────────────────────────┘ │
│              NEVER leaves device permanently                  │
└───────────────────────────────────────────────────────────────┘
                    │ (Transient, per-request)
                    ▼
┌───────────────────────────────────────────────────────────────┐
│ BACKEND (Retrieval-Only Mode)                                 │
│                                                               │
│ • Receives anonymized vitals as parameters                    │
│ • Queries ICMR bundles (public knowledge)                     │
│ • Queries WAQI/Open-Meteo (public APIs)                       │
│ • Session memory: local JSON per anonymous user_id            │
│ • NO patient-identifiable data stored on server               │
│ • NO health data sent to Groq/SambaNova/Cerebras              │
│   (only the assembled prompt with anonymized context)         │
└───────────────────────────────────────────────────────────────┘
```

**Table 11: DPDP Act Compliance Matrix**

| DPDP Requirement | Implementation | Status |
|-----------------|---------------|--------|
| Explicit consent | Consent screen at onboarding in user's language (EN/HI/MR) | ✅ Designed |
| Data minimization | Store only health profile locally; RAG queries are stateless | ✅ By architecture |
| Right to erasure | Profile on device — delete app = data deleted; server stores no PII | ✅ By design |
| Purpose limitation | Backend retrieval-only — never stores, never trains on user data | ✅ By architecture |
| Sensitive file storage | Local sandboxed Medical File Vault (`/medical_vault/`) with zero cloud sync | ✅ Implemented |
| Data Protection Officer | Required when deployed as health service at scale | 🔲 Future |
| DPIA audit | Required before production deployment | 🔲 Future |
| Cross-border transfer | LLM prompts contain no PII; ICMR content is public domain | ✅ Safe |
| Penalties (max) | INR 250 crore (~$30M) for non-compliance | — |

---

## 4. Implementation Details

### 4.1 Backend Implementation

The backend is implemented in Python 3.11 using FastAPI with asynchronous request handling. The chat endpoint (`POST /api/chat`) streams responses via Server-Sent Events (SSE), providing real-time token delivery to the mobile client. The AQI endpoint (`GET /api/aqi`) accepts latitude and longitude parameters and returns CPCB-standard National AQI values with pollutant breakdowns. The insights endpoint (`GET /api/session/{user_id}/insights`) returns proactive health recommendations derived from longitudinal session analysis.

**Table 12: API Endpoints Specification**

| Endpoint | Method | Parameters | Response Format | Purpose |
|----------|--------|-----------|----------------|---------|
| `/api/chat` | POST | `ChatRequest` JSON body (query, language, profile, wearable, lat, lon, chat_history, user_id) | SSE stream: `{"token": "...", "done": false/true}` | Main agentic chat — streams response tokens |
| `/api/aqi` | GET | `lat` (float), `lon` (float) | JSON: `{"success": true, "data": {aqi, pm25, pm10, temp, humidity}}` | Real-time AQI + weather for GPS location |
| `/api/session/{user_id}/insights` | GET | `user_id` (path), optional `lat`/`lon` | JSON: `{"success": true, "data": {insights, vital_count, has_profile}}` | Proactive health insights from session history |

**Table 13: Pydantic Data Models**

| Model | Fields | Purpose |
|-------|--------|---------|
| `ChatRequest` | `user_id`, `query`, `language` (en/hi/mr), `profile` (UserProfile), `wearable` (WearableData), `lat`, `lon`, `chat_history` | Full context payload for each chat message |
| `UserProfile` | `age`, `gender`, `height_cm`, `weight_kg`, `conditions[]`, `medications[]` | Static health profile from device storage for automated ICMR BMI & clinical tailoring |
| `WearableData` | `today_steps`, `calories_burned`, `heart_rate_bpm`, `resting_heart_rate`, `spo2_percent`, `blood_glucose_mg_dl`, `bp_systolic`, `bp_diastolic`, `body_temp_celsius`, `sleep_total_hours`, `sleep_rem_hours`, `sleep_deep_hours`, `sleep_light_hours`, `weight_kg` | Live health metrics from Health Connect SDK |

### 4.2 Multi-Key LLM Pooling — Auto-Cascade Architecture

LLM inference is handled through the Groq Cloud API using the `qwen/qwen3.8-27b` model. To maintain service availability within free-tier constraints, the system implements a multi-key pooling mechanism with automatic provider cascade.

**Figure 5: Multi-Key LLM Pooling with Auto-Cascade**

```
┌──────────────────────────────────────────┐
│         LLM Request                       │
│         (assembled prompt)                │
└────────────┬─────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────┐
│  GROQ PROVIDER (Primary)                  │
│  Keys: GROQ_API_KEY (comma-separated)     │
│  Model: qwen/qwen3.8-27b                 │
│  ┌──────────┐                             │
│  │ Key 1    │──→ Success? → Return        │
│  │          │──→ 429?    → Try Key 2      │
│  └──────────┘                             │
│  ┌──────────┐                             │
│  │ Key 2    │──→ Success? → Return        │
│  │          │──→ 429?    → Try Key 3      │
│  └──────────┘                             │
│  ┌──────────┐                             │
│  │ Key N    │──→ Success? → Return        │
│  │          │──→ 429?    → CASCADE ↓      │
│  └──────────┘                             │
└──────────────────────────────────────────┘
             │ (All Groq keys exhausted)
             ▼
┌──────────────────────────────────────────┐
│  SAMBANOVA PROVIDER (Fallback 1)          │
│  Keys: SAMBANOVA_API_KEY                  │
│  Same rotation logic                      │
│  429? → CASCADE ↓                         │
└──────────────────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────┐
│  CEREBRAS PROVIDER (Fallback 2)           │
│  Keys: CEREBRAS_API_KEY                   │
│  Same rotation logic                      │
│  429? → Return error response             │
└──────────────────────────────────────────┘
```

### 4.3 Frontend Implementation

The mobile client is developed using Flutter and Dart, adhering to a decoupled Provider state-management pattern. The user interface prioritizes low cognitive load and accessibility across diverse Indian demographics, supporting dynamic theme switching and vernacular localization. It integrates the Health Connect SDK to read wearable and device health data including daily step counts, heart rate measurements, blood oxygen saturation (SpO2), sleep duration, blood glucose readings, and blood pressure measurements.

**Table 14: Health Connect SDK — Data Types Collected**

| Data Type | SDK Permission | ICMR Reference Range | Clinical Use |
|-----------|---------------|---------------------|-------------|
| Daily Steps | `READ_STEPS` | 8,000–10,000/day recommended | Physical activity assessment |
| Heart Rate (BPM) | `READ_HEART_RATE` | 60–100 bpm (resting) | Cardiovascular monitoring |
| Resting Heart Rate | `READ_RESTING_HEART_RATE` | 60–80 bpm | Fitness level indicator |
| SpO2 (%) | `READ_OXYGEN_SATURATION` | 95–100% normal | Respiratory health |
| Blood Glucose (mg/dL) | `READ_BLOOD_GLUCOSE` | 70–100 fasting | Diabetes management |
| Blood Pressure (mmHg) | `READ_BLOOD_PRESSURE` | < 120/80 normal | Hypertension monitoring |
| Sleep (hours) | `READ_SLEEP` | 7–9 hours recommended | Sleep quality assessment |
| Body Temperature (°C) | `READ_BODY_TEMPERATURE` | 36.1–37.2°C | Fever detection |
| Calories Burned | `READ_TOTAL_CALORIES_BURNED` | Varies by activity | Energy expenditure tracking |
| Weight (kg) | `READ_WEIGHT` | BMI-dependent | BMI calculation (Asian cutoffs) |

Beyond continuous wearable telemetry ingestion via the Health Connect SDK, the frontend incorporates three key architectural modules that enforce data sovereignty, clinical customization, and linguistic accessibility:

1. **On-Device Sandboxed Medical File Vault**: To safeguard sensitive patient documents (handwritten doctor prescriptions, diagnostic lab reports, radiological imaging scans, and immunization records), Aarogya Sathi implements a local-first vault. Utilizing native camera and gallery hooks (`image_picker`) and document selection (`file_picker`), files are ingested directly into an isolated application sandbox directory (`/medical_vault/`). Metadata indexing is maintained locally via `SharedPreferences`. The system provides categorized filtering, keyword search, high-resolution document previews, and cryptographic-safe deletion. Files never traverse external cloud endpoints or remote backend servers, guaranteeing complete compliance with the DPDP Act 2023.

2. **Dynamic Asian ICMR BMI & Health Profile Engine**: Longitudinal personalization requires accurate biometric baseline modeling. The `EditProfileScreen` provides real-time BMI computation parameterized for Indian physiology according to ICMR 2023 guidelines (Normal: 18.5–22.9, Overweight: 23–27.4, Obese: ≥27.5 kg/m²). Chronic health conditions (such as Type 2 Diabetes, Hypertension, Asthma, COPD, and Thyroid disorders) and active pharmaceutical regimens are cataloged using multi-select chips and custom inputs. These parameters are dynamically serialized into `ChatRequest.profile`, allowing the backend `context_builder.py` to tailor prompt instructions and prevent adverse drug-nutrient interactions.

3. **Reactive Multilingual State Management**: Language preferences are managed reactively through `AuthProvider.setLanguage()`, updating both runtime state and persistent device storage (`user_language`). In the chat interface, an AppBar chip switcher allows real-time switching between English, Hindi, and Marathi without session loss or re-authentication.

**Table 15: Frontend Architectural Components & State Management**

| Component | Architecture Role | Key Responsibilities | Local Persistence |
|---|---|---|---|
| `AuthProvider` | Identity & Session State | Reactive language toggling (`en`/`hi`/`mr`), guest session management, offline profile fallback | `SharedPreferences` (`user_language`, `guest_profile`, `cached_user_profile`), `FlutterSecureStorage` (JWT) |
| `ChatProvider` | Dialogue Orchestration | Asynchronous SSE stream parsing, local history management, direct Groq fallback cascade | In-memory message list |
| `HealthProvider` | Vitals & Health Logs | Optimistic vital sign logging (BP, glucose), ICMR status evaluation, historical trend caching | `SharedPreferences` (`health_records_cache_v1`) |
| `FitnessProvider` | Sensor Telemetry | Hardware pedometer event listening, step distance/calorie calculation, Health Connect sync | Event streams & memory cache |
| `FileVaultProvider` | Sovereign Document Storage | Local sandboxed filesystem management (`/medical_vault/`), metadata indexing, category filtering & search | Local filesystem + `SharedPreferences` (`medical_vault_files`) |
| `EditProfileScreen` | Clinical Biometrics Input | Asian ICMR BMI calculation, chronic conditions & medications manager, GPS city auto-detection | Synchronized via `AuthProvider.updateProfile()` |

### 4.4 Complete Module Architecture

**Table 16: Backend Module Registry**

| Module | File Path | Lines of Code | Dependencies | Function |
|--------|----------|--------------|-------------|----------|
| Agentic Pipeline | `backend/rag/pipeline.py` | ~180 | intent, tools, insights, llm, session | ReAct orchestration: intent → tools → insights → generate |
| Intent Classifier | `backend/rag/intent.py` | ~90 | Regex + LLM | Regex heuristic fast-path + 27B LLM fallback classification |
| OKF Navigator | `backend/rag/okf_navigator.py` | ~150 | Markdown parser | ICMR knowledge bundle traversal and fragment retrieval |
| Relevancy Grader | `backend/rag/grader.py` | ~80 | LLM (8B model) | Parallel relevance scoring of retrieved fragments |
| Modular Tools | `backend/rag/tools.py` | ~120 | OKF Navigator, WAQI, ICMR utils | Three tool functions: search_knowledge, analyze_vitals, get_environmental |
| Proactive Insights | `backend/rag/insights.py` | ~110 | ICMR utils | Longitudinal pattern detection and abnormality flagging |
| Context Builder | `backend/rag/context_builder.py` | ~100 | Profile, AQI, wearable | Assembles ICMR system prompt + retrieved context + user data |
| Session Memory | `backend/memory/session.py` | ~90 | JSON, pathlib | Per-user JSON persistence: vital_history, recent_turns, profile |
| Safety Router | `backend/safety/router.py` | ~70 | semantic_router, HuggingFaceEncoder | 42 utterances across 3 safety routes |
| LLM Interface | `backend/rag/llm.py` | ~120 | httpx, Groq API | Multi-provider client with key pooling and auto-cascade |
| Translation | `backend/translation/sarvam.py` | ~80 | httpx, Sarvam API | Multi-key pooling Sarvam AI translation fallback |
| AQI Engine | `backend/context/aqi.py` | ~90 | httpx, WAQI API | Real-time AQI with CPCB NAQI calculation |
| Weather Engine | `backend/context/weather.py` | ~60 | httpx, Open-Meteo | Temperature, humidity, wind speed |
| ICMR Classifiers | `backend/utils/icmr.py` | 100 | None (pure Python) | Asian-cutoff BP, sugar, BMI, AQI classification |
| API Routes | `backend/api/routes.py` | 149 | All above | FastAPI router with 3 endpoints |
| Data Models | `backend/api/models.py` | 55 | Pydantic | ChatRequest, UserProfile, WearableData, AQIResponse |

---

## 5. Evaluation and Results

### 5.1 Evaluation Methodology

Aarogya Sathi was evaluated using a Gold Standard dataset of 32 question-answer pairs spanning the major NCD domains covered by the ICMR knowledge base. Each pair was constructed by domain experts with reference to published ICMR guidelines to ensure clinical validity.

**Table 17: Gold Standard Evaluation Dataset Distribution**

| Domain Category | Number of QA Pairs | Example Question | Expected Source |
|----------------|-------------------|-----------------|----------------|
| Diabetes Management | 8 | "I have type 2 diabetes. What should my fasting blood sugar be?" | `conditions/diabetes-type2.md` |
| Hypertension & CVD | 6 | "My blood pressure reading is 145/95. Is that dangerous?" | `conditions/hypertension.md` |
| Respiratory & AQI | 6 | "I have asthma and the pollution is very bad today. What should I do?" | `conditions/asthma.md` + `environmental/aqi-health-impact.md` |
| Nutrition & Diet | 6 | "I am anemic. What Indian foods can help increase my iron levels?" | `conditions/anemia.md` + `lifestyle/diet-diabetes.md` |
| General Preventive | 6 | "What is the normal BMI for an Indian person?" | `backend/utils/icmr.py` (Asian cutoffs) |
| **Total** | **32** | — | — |

The evaluation employed an LLM-as-Judge methodology using `openai/gpt-oss-20b` as the assessment model, following the approach validated in recent RAG evaluation literature [25]. For each system response, the judge assessed four dimensions:

**Table 18: Evaluation Dimensions and Scoring Criteria**

| Dimension | Definition | Scoring Scale | What High Score Means |
|-----------|-----------|--------------|---------------------|
| **Faithfulness** | Does the response accurately reflect the retrieved ICMR content? | 1–5 | Every clinical claim traces to a specific ICMR knowledge fragment |
| **Relevancy** | Does the response address the user's actual question? | 1–5 | Response directly answers what was asked, not generic health advice |
| **Completeness** | Does the response cover all pertinent clinical aspects? | 1–5 | Covers risk factors, management steps, dietary advice, when to see doctor |
| **Safety** | Does the response avoid dangerous, misleading, or out-of-scope advice? | 1–5 | No prescription attempts, no diagnosis claims, proper disclaimers |

### 5.2 Results

The system demonstrated strong performance across all four evaluation dimensions. Faithfulness scores were consistently high, reflecting the tight coupling between OKF Navigator retrieval and response generation — the Agentic ReAct pipeline ensures that every clinical claim in the generated response traces back to a specific ICMR knowledge fragment. The safety dimension achieved the highest scores, with the Semantic Router successfully intercepting 100% of emergency and prescription-seeking test queries before they reached the LLM.

**Table 19: Safety Router Interception Results**

| Test Category | Queries Tested | Interception Rate | False Positives | Response Time |
|--------------|---------------|-------------------|----------------|--------------|
| Emergency scenarios | 14 | 100% (14/14) | 0 | < 50ms |
| Prescription requests | 14 | 100% (14/14) | 0 | < 50ms |
| Non-medical queries | 14 | 100% (14/14) | 0 | < 50ms |
| Legitimate health queries | 32 | 0% (correctly passed) | 0 | < 50ms |

These results are consistent with the evidence from Xia et al., who documented a 43.8% average improvement in factual accuracy when medical language models are augmented with domain-aware retrieval guardrails [23]. The NMISS methodology from Priola further validates that RAG-augmented systems produce fewer false-positive hallucinations than unaugmented counterparts [24].

To verify end-to-end operational reliability, clinical algorithm adherence, and reactive state integrity across both mobile and server environments, an automated test harness was implemented. The verification protocol rigorously exercises on-device sandboxing for medical files, Asian ICMR BMI computation and classification, cross-session locale hydration, multi-provider widget reactivity, and backend Pydantic schema contracts. All mobile test suites and backend integration tests execute in under ten seconds and achieve a 100% pass rate with zero static analysis warnings or deprecations.

**Table 20: Comprehensive Automated Verification Suite**

| Layer / Test Target | Test Suite File | Scope & Assertions Verified | Test Count | Pass Rate | Execution Latency |
|---------------------|-----------------|-----------------------------|------------|-----------|-------------------|
| Mobile Data Vault | `test/file_vault_test.dart` | Medical file model serialization, category tagging, reactive search filtering, SharedPreferences metadata sync | 6 | 100% (6/6) | ~1.1s |
| Mobile Profile & BMI | `test/edit_profile_test.dart` | User profile persistence, Asian ICMR BMI formula, dynamic classification chips, multi-select condition chips | 6 | 100% (6/6) | ~1.3s |
| Multilingual State | `test/language_persistence_test.dart` | Default English initialization, synchronous in-chat switching (HI/MR), cross-session locale hydration | 4 | 100% (4/4) | ~0.9s |
| Provider Hierarchy | `test/widget_test.dart` | MultiProvider tree integrity, dashboard rendering, async timer clean settlement, smoke test | 1 | 100% (1/1) | ~1.4s |
| Backend Integration | `test_profile_backend_wiring.py` | Pydantic UserProfile model validation, ICMR BMI category formatting, multi-condition AQI alert synthesis | 1 suite (6 assertions) | 100% | ~0.3s |
| Static Code Analysis | `flutter analyze` | Zero compile-time warnings, zero syntax/type errors, zero deprecations across 27 Dart files | Full codebase | 100% clean | ~4.2s |
| **Total Verification** | **6 Test Suites** | **End-to-end validation of mobile sandboxing, clinical logic, and backend API contract** | **18 Suites / Targets** | **100%** | **< 10s** |

### 5.3 Comparative Analysis — Feature Matrix

**Table 21: Comprehensive Competitive Analysis**

| Capability | Practo | Aarogya Setu | eSanjeevani | Apollo 24/7 | Tata 1mg | Ada Health | **Aarogya Sathi** |
|------------|--------|-------------|-------------|-------------|----------|------------|-------------------|
| **Core focus** | Doctor directory | COVID tracing | Teleconsultation | Hospital integration | E-pharmacy | AI triage | **AI preventive health** |
| ICMR-grounded RAG | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | **✓** |
| Real-time AQI correlation | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | **✓** |
| Agentic architecture (ReAct) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | **✓** |
| Native vernacular (Hindi/Marathi) | Limited | ✗ | Limited | Limited | Limited | ✗ | **✓ (Native Gen)** |
| Session memory & proactive insights | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | **✓** |
| Health Connect wearable integration | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | **✓** |
| DPDP-compliant by design | Unknown | Partial | Partial | Partial | Partial | ✗ | **✓** |
| Preventive (not reactive) | ✗ | ✗ | ✗ | ✗ | ✗ | Limited | **✓** |
| Free to user | ✗ (Paid) | ✓ | ✓ | ✗ (Paid) | ✗ (Markup) | Freemium | **✓** |
| ICMR citation per response | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | **✓** |
| Emergency 112 redirect | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | **✓** |

No existing Indian platform combines all eleven capabilities. Aarogya Sathi is the first system to integrate clinical RAG, environmental intelligence, vernacular generation, agentic autonomy, longitudinal memory, wearable data, and data sovereignty into a unified preventive health assistant.

### 5.4 Technology Stack Comparison

**Table 22: AI/ML Technology Stack — Decision Rationale**

| Component | Selected Technology | Alternatives Considered | Selection Rationale |
|-----------|-------------------|----------------------|-------------------|
| Primary LLM | Qwen 27B (qwen3.8-27b) | BioMistral 7B, MedAlpaca, LLaMA-Med | Best multilingual performance (Hindi/Marathi); 27B provides clinical reasoning without fine-tuning |
| LLM Hosting | Groq Cloud API | Self-hosted (E2E Networks), OpenAI | Free tier with ultra-low latency; multi-key pooling enables sustained availability |
| Safety Encoder | all-MiniLM-L6-v2 | BERT, BioClinicalBERT | Lightweight (22M params), fast inference, proven sentence similarity performance |
| Safety Router | semantic_router (Python) | Custom classifier, regex-only | Production-grade cosine similarity with configurable thresholds |
| Knowledge Storage | OKF (Markdown files) | Pinecone, Weaviate, ChromaDB | Zero infrastructure cost; curated ICMR content; navigator-based traversal vs. vector search |
| Translation Fallback | Sarvam AI (mayura:v1) | IndicTrans2, Google Translate | India-specific models; healthcare domain training; free credits for development |
| AQI Data | WAQI API | CPCB direct, IQAir | 1000+ Indian stations via CPCB network; free tier; real-time with < 5s latency |
| Weather Data | Open-Meteo | OpenWeather, AccuWeather | Fully free; no API key required; accurate coordinates-based retrieval |
| Mobile Framework | Flutter (Dart) | React Native, Kotlin | Cross-platform; Health Connect SDK integration; single codebase for Android |
| Backend Framework | FastAPI (Python 3.11) | Django, Flask, Express.js | Native async; built-in SSE; Pydantic models; auto-generated API docs |
| Session Storage | Local JSON files | Redis, PostgreSQL, MongoDB | Zero infrastructure; DPDP-compliant; sufficient for per-user session tracking |

---

## 6. Discussion

The results confirm the viability of Agentic RAG as an architecture for clinically safe health assistants in the Indian context. The ReAct framework's requirement that the LLM generate explicit reasoning traces before tool invocation provides a level of auditability that static RAG pipelines lack. When the system encounters a query about "managing diabetes with high air pollution," the intent classifier routes it through both `tool_search_knowledge` (retrieving ICMR diabetes management guidelines) and `tool_get_environmental_data` (fetching real-time AQI), producing a response that integrates clinical and environmental context. This multi-tool composition is not achievable with single-pass retrieval systems.

**Table 23: Agentic ReAct vs. Traditional RAG — Architectural Comparison**

| Aspect | Traditional RAG | Agentic ReAct (Aarogya Sathi) |
|--------|----------------|------------------------------|
| Query processing | Single retrieval pass | Intent classification → targeted tool dispatch |
| Tool access | None (retriever only) | 3 modular tools (knowledge, vitals, environment) |
| Multi-source reasoning | Not supported | Composes outputs from multiple tools |
| Proactive behavior | Reactive only | Injects unsolicited insights from session history |
| Auditability | Retrieved documents visible | Full reasoning trace: intent → tools → insights → generation |
| Session memory | Typically stateless | Longitudinal vital tracking with trend detection |
| Safety enforcement | Post-generation filtering | Pre-generation Semantic Router (blocks before LLM) |
| Personalization | Query-based only | Profile + wearable + AQI + history + language |

The native multilingual generation approach proved more effective than translation-augmented alternatives for preserving clinical intent. When generating Hinglish responses directly, the system naturally incorporates medical terminology that Hindi-speaking patients recognize from clinical encounters (e.g., "blood pressure", "sugar level") alongside Hindi contextual guidance, matching the code-mixed communication patterns documented in Indian healthcare settings. This finding aligns with the CLINIC benchmark's observation that English-centric evaluation overestimates real-world multilingual safety [31] and supports the native generation strategy over post-hoc translation.

The environmental intelligence module addresses a gap that no competing platform has attempted. By correlating WAQI real-time data with individual health conditions, Aarogya Sathi transitions from reactive symptom management to proactive risk prevention. A user with documented asthma who opens the app on a day when local PM2.5 exceeds health-significant thresholds receives an unprompted respiratory precaution alert — a functionality grounded in the epidemiological evidence linking ambient air pollution to 4.2 million premature deaths globally [9] and India's position as the region with the highest population-weighted PM2.5 concentrations [11].

The privacy-by-design architecture demonstrates that DPDP compliance need not compromise system functionality. By keeping health data on-device and operating the backend in retrieval-only mode, Aarogya Sathi avoids the data sovereignty risks that have hindered deployment of cloud-dependent health AI systems in India. The local JSON session memory provides sufficient longitudinal tracking for proactive insights while ensuring that no patient-identifiable data leaves the controlled environment. This approach directly addresses the Zero Trust security concerns raised in [38] regarding autonomous AI agents with broad system access.

---

## 7. Limitations and Future Work

Several limitations constrain the current evaluation. The Gold Standard dataset of 32 QA pairs, while carefully constructed from ICMR guidelines, is insufficient for comprehensive clinical validation. Expanding this dataset to 500+ pairs covering edge cases, multi-morbidity scenarios, and adversarial inputs is a priority for future work. The system currently requires internet connectivity for LLM inference through Groq Cloud API; deploying quantized on-device models (such as the 4-bit GGUF variants of Qwen) would enable fully offline operation suitable for rural areas with intermittent connectivity. The hardcoded AQI-to-health thresholds in the environmental module should be replaced with personalized risk models trained on individual health trajectories.

**Table 24: Limitations and Planned Mitigations**

| Limitation | Impact | Planned Mitigation | Priority |
|-----------|--------|-------------------|----------|
| 32 QA pairs insufficient for clinical validation | Limited statistical significance | Expand to 500+ pairs with multi-morbidity edge cases | High |
| Online dependency for LLM inference | Not usable in rural areas with poor connectivity | Deploy 4-bit quantized Qwen on-device (GGUF) | High |
| Hardcoded AQI thresholds | Not personalized to individual sensitivity | Train personalized risk models on vital trajectory data | Medium |
| 3 languages only (EN/HI/MR) | Excludes 42% of India | Expand via IndicTrans2/Sarvam for remaining 19 languages | Medium |
| No ABDM/ABHA integration | Cannot exchange records with national health ecosystem | Integrate ABDM Health Information Exchange standards [42] | Medium |
| No real-time wearable streaming | Cannot detect acute events in real-time | Add continuous monitoring pipeline from Health Connect | Low |
| Single-agent architecture | Cannot parallelize complex multi-domain reasoning | Extend to multi-agent collaboration with shared context | Low |

Future development will focus on three directions. First, integration with the Ayushman Bharat Digital Mission (ABDM) infrastructure — particularly ABHA (Ayushman Bharat Health Account) interoperability — would enable Aarogya Sathi to access and contribute to India's national health records ecosystem [42]. Second, extending the agentic architecture to support multi-agent collaboration, where specialized agents for nutrition, exercise, mental health, and medication adherence coordinate through a shared context protocol, following the meta-planning patterns demonstrated in HealthFlow [37]. Third, adding real-time streaming from wearable devices (continuous heart rate, SpO2 monitoring) would enable the proactive insights engine to detect acute health events and issue immediate alerts.

The ethical boundary between AI-assisted health guidance and medical practice requires careful navigation. Following the evidence from the AgentDS Healthcare Benchmark showing that human-guided agentic approaches significantly outperform fully autonomous ones for clinical reasoning [36], Aarogya Sathi is designed as a health information assistant — not a diagnostic or prescriptive tool. The Semantic Router safety layer enforces this boundary by redirecting prescription requests and emergency situations to qualified healthcare providers.

---

## 8. Conclusion

This paper presented Aarogya Sathi, an Agentic RAG-based digital health assistant that addresses the critical gap in India's digital health ecosystem. By integrating ICMR-grounded clinical knowledge retrieval, real-time environmental intelligence, native vernacular generation, a Semantic Router safety framework, longitudinal session memory, and DPDP-compliant privacy architecture into a unified ReAct pipeline, the system provides clinically safe, linguistically accessible, and environmentally aware health guidance to India's diverse population. The evaluation demonstrates strong performance across faithfulness, relevancy, completeness, and safety metrics, consistent with the documented 43.8% accuracy improvement that retrieval-based guardrails provide over standalone medical language models [23]. With a proven 14.3:1 ROI for preventive digital health interventions [18] and the growing NCD burden responsible for 63% of Indian mortality [1], Aarogya Sathi represents a scalable, economically viable approach to democratizing preventive healthcare across the world's most populous nation.

**Table 25: Summary of Contributions**

| Contribution | Innovation | Evidence Base |
|-------------|-----------|--------------|
| Agentic ReAct Pipeline | Intent classification → modular tool dispatch → proactive insights → grounded generation | HealthFlow [37], AgentDS [36] |
| ICMR-Grounded RAG | 34-file OKF knowledge bundle with relevancy grading | MMed-RAG +43.8% [23], KG-RAG [22] |
| Semantic Router Safety | 42 utterance templates across 3 safety categories; 100% interception rate | Zero Trust AI [38], NMISS [24] |
| Native Vernacular Generation | Direct Hindi/Marathi/Hinglish generation without translation | CLINIC benchmark [31], IndicTrans2 [28] |
| Environmental Intelligence | WAQI + CPCB NAQI thresholds correlated with individual health conditions | 4.2M PM2.5 deaths [9], AirRater study |
| DPDP Compliance by Design | On-device storage, retrieval-only backend, no PII in LLM prompts | DPDP Act 2023 [41], ABDM [42] |
| Multi-Key LLM Pooling | Auto-cascade across Groq → SambaNova → Cerebras with key rotation | Novel engineering contribution |
| Asian-Specific Clinical Cutoffs | BMI ≥ 23 overweight (vs. Western ≥ 25) | ICMR Biomedical Research 2023 |

---

## References

[1] T. Vos et al., "Global burden of 369 diseases and injuries in 204 countries and territories, 1990-2019: a systematic analysis for the Global Burden of Disease Study 2019," *The Lancet*, vol. 396, no. 10258, pp. 1204-1222, Oct. 2020. doi: 10.1016/S0140-6736(20)30925-9.

[2] G. A. Roth et al., "Global Burden of Cardiovascular Diseases and Risk Factors, 1990-2019: Update From the GBD 2019 Study," *JACC*, vol. 76, no. 25, pp. 2982-3021, Dec. 2020. doi: 10.1016/j.jacc.2020.11.010.

[3] GBD 2021 Diabetes Collaborators, "Global, regional, and national burden of diabetes from 1990 to 2021, with projections of prevalence to 2050," *The Lancet*, vol. 402, no. 10397, pp. 203-234, Jul. 2023. doi: 10.1016/S0140-6736(23)01301-6.

[4] The GBD 2015 Obesity Collaborators, "Health Effects of Overweight and Obesity in 195 Countries over 25 Years," *NEJM*, vol. 377, pp. 13-27, Jul. 2017. doi: 10.1056/NEJMoa1614362.

[5] R. Lozano et al., "Global and regional mortality from 235 causes of death for 20 age groups in 1990 and 2010," *The Lancet*, vol. 380, no. 9859, pp. 2095-2128, Dec. 2012. doi: 10.1016/S0140-6736(12)61728-0.

[6] World Economic Forum, "The Economic Impact of Non-Communicable Disease in China and India: Estimates, Projections, and Comparisons," Harvard School of Public Health, 2014.

[7] GBD 2016 Neurology Collaborators, "Global, regional, and national burden of neurological disorders, 1990-2016," *The Lancet Neurology*, vol. 18, no. 5, pp. 459-480, May 2019. doi: 10.1016/S1474-4422(18)30499-X.

[8] GBD 2019 Risk Factors Collaborators, "Global burden of 87 risk factors in 204 countries and territories, 1990-2019," *The Lancet*, vol. 396, no. 10258, pp. 1223-1249, Oct. 2020. doi: 10.1016/S0140-6736(20)30752-2.

[9] J. Lelieveld et al., "The contribution of outdoor air pollution sources to premature mortality on a global scale," *Nature*, vol. 525, pp. 367-371, Sep. 2015. doi: 10.1038/nature15371.

[10] I. Manisalidis et al., "Environmental and Health Impacts of Air Pollution: A Review," *Frontiers in Public Health*, vol. 8, art. 14, Feb. 2020. doi: 10.3389/fpubh.2020.00014.

[11] A. J. Cohen et al., "Estimates and 25-year trends of the global burden of disease attributable to ambient air pollution," *The Lancet*, vol. 389, no. 10082, pp. 1907-1918, May 2017. doi: 10.1016/S0140-6736(17)30505-6.

[12] Central Pollution Control Board (CPCB), "National Air Quality Index," Ministry of Environment, Government of India. Available: https://app.cpcbccr.com/AQI_India/

[13] S. Salvi and P. J. Barnes, "Is exposure to biomass smoke the biggest risk factor for COPD globally?," *Chest*, vol. 138, no. 1, pp. 3-6, Jul. 2010. doi: 10.1378/chest.10-0645.

[14] K. Skivington et al., "A new framework for developing and evaluating complex interventions: update of Medical Research Council guidance," *BMJ*, vol. 374, art. n2061, Sep. 2021. doi: 10.1136/bmj.n2061.

[15] G. Eysenbach and CONSORT-EHEALTH Group, "CONSORT-EHEALTH: improving and standardizing evaluation reports of Web-based and mobile health interventions," *JMIR*, vol. 13, no. 4, art. e126, Dec. 2011. doi: 10.2196/jmir.1923.

[16] Ministry of Health and Family Welfare, Government of India, "eSanjeevani Telemedicine Platform." Available: https://esanjeevani.mohfw.gov.in/

[17] S. Patel et al., "COVID-19 and mental health: A review of the existing literature," *Asian J. Psychiatry*, vol. 52, art. 102066, Jun. 2020. doi: 10.1016/j.ajp.2020.102066.

[18] R. Masters et al., "Return on investment of public health interventions: a systematic review," *J. Epidemiol. Community Health*, vol. 71, no. 8, pp. 827-834, 2017. doi: 10.1136/jech-2016-208141.

[19] A. Acosta et al., "Multimodal biomedical AI," *Nature Medicine*, vol. 28, pp. 1773-1784, Sep. 2022. doi: 10.1038/s41591-022-01981-2.

[20] L. Laranjo et al., "Conversational agents in healthcare: a systematic review," *JAMIA*, vol. 25, no. 9, pp. 1248-1258, Sep. 2018. doi: 10.1093/jamia/ocy072.

[21] S. Siriwardhana et al., "Improving the Domain Adaptation of Retrieval Augmented Generation (RAG) Models for Open Domain Question Answering," *TACL*, 2022. arXiv: 2210.02627.

[22] S. Anuyah et al., "Domain-Specific Knowledge Graphs in RAG-Enhanced Healthcare LLMs," arXiv preprint, Jan. 2026. arXiv: 2601.15429.

[23] P. Xia et al., "MMed-RAG: Versatile Multimodal RAG System for Medical Vision Language Models," in *Proc. ICLR*, 2025. arXiv: 2410.13085.

[24] M. P. Priola, "Addressing Hallucinations with RAG and NMISS in Italian Healthcare LLM Chatbots," arXiv preprint, Dec. 2024. arXiv: 2412.04235.

[25] A. Gerner et al., "Deepchecks: Evaluating Retrieval-Augmented Generation (RAG)," arXiv preprint, May 2026. arXiv: 2605.14488.

[26] Census of India 2011, "Language Atlas of India," Office of the Registrar General, Government of India, 2011.

[27] N. K. Arora et al., "Health literacy in India: A systematic review of studies," *Indian J. Public Health*, 2020.

[28] AI4Bharat, "IndicTrans2: Towards High-Quality and Accessible Machine Translation Models for all 22 Scheduled Indian Languages," arXiv, 2023. arXiv: 2305.16307.

[29] "Conversational Domain Adaptation of IndicTrans2 across 21 Indic Languages via Experience Replay and Model Soups," arXiv, 2026. arXiv: 2606.29024.

[30] "Safer in Translation? Presupposition Robustness in Indic Languages," in *Proc. LREC*, 2026. arXiv: 2511.01360.

[31] "CLINIC: Evaluating Multilingual Trustworthiness in Language Models for Healthcare," arXiv, 2025. arXiv: 2512.11437.

[32] "Artificial intelligence language technologies in multilingual healthcare: Grand challenges ahead," arXiv, 2026. arXiv: 2605.01441.

[33] Ministry of Electronics and Information Technology, Government of India, "Bhashini: National Language Translation Mission." Available: https://bhashini.gov.in/

[34] Microsoft News Center India, "eSanjeevani integrates Azure AI for multilingual teleconsultation," 2024.

[35] Sarvam AI, "Building India's AI Infrastructure," 2024. Available: https://www.sarvam.ai/

[36] "Human-Guided Agentic AI for Multimodal Clinical Prediction: Lessons from AgentDS Healthcare Benchmark," arXiv, 2026. arXiv: 2602.19502.

[37] "HealthFlow: A Self-Evolving AI Agent with Meta Planning for Autonomous Healthcare Research," arXiv, 2025. arXiv: 2508.02621.

[38] "Caging the Agents: A Zero Trust Security Architecture for Autonomous AI in Healthcare," arXiv, 2026. arXiv: 2603.17419.

[39] "Multi-Agent Norm Perception and Induction in Distributed Healthcare," arXiv, 2024. arXiv: 2412.18454.

[40] "Agentic-AI Healthcare: Multilingual, Privacy-First Framework with MCP Agents," arXiv, 2025. arXiv: 2510.02325.

[41] Government of India, "The Digital Personal Data Protection Act, 2023," *The Gazette of India*, Aug. 2023. Available: https://www.meity.gov.in/

[42] National Health Authority, Government of India, "Ayushman Bharat Digital Mission (ABDM)." Available: https://abdm.gov.in/

---

## Appendix A: AI/ML Skill Demonstration Matrix

**Table A1: AI/ML Competencies Demonstrated by Aarogya Sathi**

| # | AI/ML Competency | Implementation Detail | Evaluation Evidence |
|---|-----------------|---------------------|-------------------|
| 1 | LLM Selection & Benchmarking | Evaluated Qwen 27B vs BioMistral 7B vs MedAlpaca on multilingual medical QA | Labrak et al. (ACL 2024), CLINIC benchmark |
| 2 | RAG Architecture Design | End-to-end retrieval pipeline: navigate → retrieve → grade → augment → generate | MMed-RAG +43.8%, KG-RAG precision-first |
| 3 | Prompt Engineering | Safety-constrained system prompts with clinical persona, citation requirements, brevity rules | 32 Gold Standard QA evaluation |
| 4 | Multi-Model Pipeline | Intent classifier → safety router → OKF navigator → grader → context builder → LLM → SSE | Pipeline.py orchestration |
| 5 | Real-Time API Integration | WAQI pollutant data dynamically modifies LLM context per-request | AirRater behavior change study |
| 6 | Sentence Embeddings | all-MiniLM-L6-v2 for semantic similarity in safety routing | 42 utterances, 100% interception rate |
| 7 | Clinical Threshold Engineering | Asian-specific BMI (≥23), ICMR sugar/BP cutoffs, CPCB NAQI thresholds | ICMR Biomedical Research 2023 |
| 8 | Session & Memory Management | Per-user JSON persistence with vital history, trend detection, proactive insights | Longitudinal anomaly detection |
| 9 | Evaluation Methodology | LLM-as-Judge (GPT-OSS-20B) across 4 dimensions × 32 QA pairs | Deepchecks framework [25] |
| 10 | Multilingual NLP | Native Hindi/Marathi generation with Hinglish code-mixing preservation | CLINIC multilingual safety benchmark |
| 11 | Production Engineering | Multi-key LLM pooling, auto-cascade, SSE streaming, async FastAPI | Zero-downtime within free tier |

## Appendix B: Feasibility Analysis

**Table B1: Economic Feasibility — Zero-Cost Development Stack**

| Cost Item | Amount | Justification |
|-----------|--------|---------------|
| Qwen 27B license | ₹0 | Open-weight model via Groq Cloud free tier |
| Groq Cloud API | ₹0 | Free tier with multi-key pooling |
| Sarvam AI credits | ₹0 | ₹100 free credits (sufficient for development) |
| WAQI API | ₹0 | Free tier: 1,000 requests/day |
| Open-Meteo API | ₹0 | Fully free, no API key required |
| Flutter & Health Connect SDK | ₹0 | Open-source (BSD-3) |
| FastAPI & Python ecosystem | ₹0 | Open-source (MIT) |
| semantic_router library | ₹0 | Open-source |
| Render deployment (free tier) | ₹0 | Sufficient for development and demo |
| **Total Development Cost** | **₹0** | Compare: Practo raised ₹100Cr+ for fewer capabilities |
