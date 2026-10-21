# Aarogya Sathi: An Agentic RAG-Based, Vernacular-First, Environment-Aware Digital Health Assistant for Preventive NCD Management in India

**Authors**: Jayesh Patil, Abhijit Patil, Ritesh Pawar

**Guide**: Dr. Atul V. Dusane

**Affiliation**: Department of IT/AIML, Mukesh Patel School of Technology Management and Engineering (MPSTME), SVKM's NMIMS, Shirpur, Maharashtra, India

**Academic Year**: 2026–27

---

## Abstract

Non-Communicable Diseases (NCDs) account for 63% of all deaths in India, with cardiovascular diseases alone responsible for 28% of national mortality. Despite India's rapidly expanding digital health infrastructure — exemplified by over 100 million teleconsultations on the eSanjeevani platform — no existing solution simultaneously provides clinically grounded medical guidance, hyper-local environmental intelligence, and vernacular-first accessibility. This paper presents Aarogya Sathi, an AI-powered preventive health assistant designed to bridge this gap through six integrated pillars: an Agentic Retrieval-Augmented Generation (RAG) pipeline grounded in Indian Council of Medical Research (ICMR) clinical guidelines; real-time air quality correlation with respiratory and cardiovascular health; native multilingual support for Hindi, Marathi, and English via Qwen 27B; a Semantic Router safety framework employing sentence embeddings to block emergency, prescription, and non-medical queries before they reach the language model; session memory for longitudinal health tracking; and Digital Personal Data Protection Act (DPDP) 2023 compliance through on-device processing. The system was evaluated on a 32-pair Gold Standard dataset using an LLM-as-Judge methodology, achieving a composite score of 4.60 out of 5.00 across faithfulness, relevancy, completeness, and safety dimensions. The Semantic Router achieved a 100% interception rate on unsafe queries with zero false positives. Prior work on multimodal medical RAG has demonstrated that retrieval-based guardrails yield up to 43.8% improvement in clinical accuracy over standalone language models, and preventive digital health interventions exhibit a documented 14.3:1 return on investment, underscoring the economic viability of deploying such systems across India's 1.4 billion population.

**Keywords**: Agentic RAG, ReAct Framework, Large Language Models, Healthcare AI, ICMR Guidelines, Multilingual NLP, Air Quality Index, Preventive Health, DPDP Act 2023

---

## 1. Introduction

India is experiencing an unprecedented epidemiological transition in which Non-Communicable Diseases have become the dominant cause of mortality. The Global Burden of Disease Study 2019 documented that NCDs — including cardiovascular diseases, diabetes, chronic respiratory conditions, and cancers — account for approximately 63% of all deaths in the country [1]. Cardiovascular diseases alone contribute to 28% of national mortality [2], while the GBD 2021 diabetes analysis projects India to have one of the highest absolute numbers of diabetic individuals globally by 2050 [3]. An analysis of obesity trends across 195 countries attributed 4.0 million deaths to high body mass index, with 40% occurring among individuals who were overweight but not formally classified as obese [4]. The World Economic Forum estimated that NCDs could cost India trillions of dollars in lost productivity and healthcare expenditure between 2012 and 2030 [6], establishing the urgency for scalable preventive interventions.

Compounding this burden is India's severe air pollution crisis. The GBD 2019 risk factor analysis identified ambient air pollution as one of the most significant modifiable environmental risk factors globally [8]. Lelieveld et al. estimated 4.2 million premature deaths attributable to ambient PM2.5 in 2015, with South Asia bearing a disproportionate share of this mortality [9]. India's urban centres — Delhi, Mumbai, Kolkata — consistently record PM2.5 levels far exceeding WHO guidelines, and research demonstrates that non-smokers in India exhibit approximately 30% lower lung function compared to European counterparts due to chronic pollution exposure [13]. The dose-response relationship between PM2.5 exposure and cardiorespiratory mortality is firmly established in the epidemiological literature [10], [11], yet no existing Indian health application correlates real-time Air Quality Index (AQI) data with individual health profiles for personalized risk alerts.

Digital health platforms have demonstrated significant promise in addressing these challenges at scale. India's eSanjeevani telemedicine platform facilitated over 100 million teleconsultations by 2024 [16], and systematic reviews of preventive public health interventions report a median return on investment of 14.3:1 [18]. However, existing platforms in India each address only narrow aspects of the problem. Practo focuses on appointment booking without preventive intelligence; Aarogya Setu served as a COVID-era contact tracing tool with no chronic disease management capability; eSanjeevani requires doctor availability and lacks AI-driven autonomy; and global alternatives like Ada Health lack India-specific clinical guidelines and vernacular-first design. Table 1 provides a systematic gap analysis across these platforms. The emergence of Large Language Models (LLMs) in healthcare introduces both opportunity and risk. A systematic review in the Journal of the American Medical Informatics Association documented significant gaps in clinical safety, reliability, and evaluation methodology of conversational health agents [20], while Nature Medicine's analysis of multimodal biomedical AI emphasized that unsupervised LLM responses carry unacceptable risk for clinical decision-making due to hallucination [19]. Retrieval-Augmented Generation (RAG) directly addresses this problem by grounding LLM outputs in verified external knowledge, and recent advances in Agentic AI — systems comprising autonomous agents that plan, reason, and act through structured tool use — represent the next evolutionary step beyond static retrieval pipelines [36], [37].

**Table 1: Gap Analysis — Existing Digital Health Platforms vs. Aarogya Sathi**

| Capability | Practo | Aarogya Setu | eSanjeevani | Ada Health | **Aarogya Sathi** |
|------------|--------|-------------|-------------|------------|-------------------|
| AI/ML pipeline (Agentic RAG) | ✗ | ✗ | ✗ | Basic | **✓** |
| ICMR clinical grounding | ✗ | ✗ | ✗ | ✗ | **✓** |
| Real-time AQI health correlation | ✗ | ✗ | ✗ | ✗ | **✓** |
| Native vernacular generation (HI/MR) | Limited | ✗ | Limited | ✗ | **✓** |
| Preventive (not reactive) approach | ✗ | ✗ | ✗ | Limited | **✓** |
| DPDP Act 2023 compliant by design | Partial | Partial | Partial | ✗ | **✓** |
| Longitudinal session memory | ✗ | ✗ | ✗ | ✗ | **✓** |
| Health Connect wearable integration | ✗ | ✗ | ✗ | ✗ | **✓** |
| Free and open to users | ✗ | ✓ | ✓ | Freemium | **✓** |

This paper presents Aarogya Sathi, the first Indian digital health assistant that simultaneously addresses clinical safety through ICMR-grounded Agentic RAG, environmental intelligence through real-time AQI correlation, vernacular accessibility through native multilingual generation, and data sovereignty through DPDP-compliant on-device processing. The specific contributions of this work are fourfold. First, an Agentic ReAct pipeline is proposed that classifies user intent and dispatches modular tools for knowledge retrieval, vitals analysis, and environmental data collection, enabling multi-source clinical reasoning within a single architecture. Second, a Semantic Router safety framework is developed that employs sentence embeddings to intercept clinically unsafe queries before they reach the language model, achieving a 100% interception rate with zero false positives. Third, a native Hinglish and Marathi generation approach is implemented that eliminates translation-induced semantic drift in medical terminology by generating directly in the user's language. Fourth, a privacy-by-design architecture is demonstrated that achieves DPDP Act 2023 compliance through on-device health data storage and a retrieval-only backend, without compromising clinical functionality. The research objectives guiding this work are: (O1) design and implement an Agentic RAG pipeline grounded in ICMR clinical guidelines for evidence-based health guidance; (O2) integrate real-time air quality data with individual health profiles for proactive environmental health alerts; (O3) enable native multilingual health communication in Hindi, Marathi, and English without post-hoc translation; (O4) achieve DPDP Act 2023 compliance through architectural design rather than policy overlays; and (O5) evaluate the system's clinical accuracy, safety, and relevancy using a Gold Standard dataset with LLM-as-Judge methodology.

---

## 2. Related Work

### 2.1 RAG in Healthcare

Retrieval-Augmented Generation addresses the hallucination problem inherent in parametric language models by grounding responses in external, verified knowledge sources. Siriwardhana et al. proposed RAG-end2end, demonstrating that joint training of retriever and generator components significantly improves domain adaptation in open-domain question answering, with experiments spanning healthcare, news, and conversational domains [21]. Anuyah et al. evaluated domain-specific knowledge graphs within RAG-enhanced healthcare LLMs and found that precision-first, scope-matched retrieval from PubMed-derived knowledge graphs yielded the most consistent accuracy improvements, while indiscriminate knowledge graph unions introduced distractor documents that degraded performance [22]. These findings directly informed the design decision in Aarogya Sathi to employ tightly scoped ICMR knowledge bundles rather than broad medical knowledge bases.

### 2.2 Hallucination Mitigation

Xia et al. introduced MMed-RAG, a multimodal RAG system for medical vision-language models evaluated across five medical datasets spanning radiology, ophthalmology, and pathology, achieving a 43.8% average improvement in factual accuracy compared to baseline medical language models through domain-aware retrieval, adaptive context selection, and RAG-based preference fine-tuning [23]. Priola specifically evaluated RAG for mitigating hallucinations in healthcare chatbots using Italian health news articles and introduced the Negative Missing Information Scoring System (NMISS) to reduce false-positive hallucination detection [24]. The Deepchecks framework formalized RAG evaluation methodology for healthcare through multi-faceted assessment covering retrieval quality, generation fidelity, and production monitoring [25]. Aarogya Sathi extends these approaches by combining document-level RAG with a Semantic Router safety layer that prevents the system from generating responses outside its clinical scope, providing a defence-in-depth strategy against both hallucination and scope violation.

**Table 2: Comparison of RAG Approaches in Healthcare**

| Approach | Accuracy Gain | Key Innovation | Source |
|----------|--------------|----------------|--------|
| Baseline LLM (no retrieval) | — | Parametric knowledge only | JMIR 2026 |
| RAG with external knowledge | ~+20% over baseline | Document-grounded generation | JMIR 2026 |
| Fine-Tuning + RAG (Hybrid) | ~+27% over baseline | Combined parametric and non-parametric | JMIR 2026 |
| MMed-RAG (multimodal) | **+43.8%** over baseline | Domain-aware retrieval with preference tuning | Xia et al. [23] |
| KG-RAG (scope-matched) | Consistently superior | Precision-first knowledge graphs | Anuyah et al. [22] |
| **Aarogya Sathi** | 4.60/5.00 composite | ICMR-scoped RAG with Semantic Router safety | This work |

### 2.3 Multilingual Healthcare AI

India's linguistic diversity — 22 officially recognized languages and over 19,500 dialects — creates a critical barrier to healthcare access for approximately 90% of the population that does not speak English as a primary language [26]. The IndicTrans2 system supports translation across all 22 constitutionally recognized Indian languages [28], and recent work on conversational domain adaptation demonstrated a +6.2 chrF improvement across 21 Indic languages [29]. The CLINIC benchmark introduced a multilingual evaluation framework for healthcare language models and found that English-centric evaluation dramatically overestimates real-world multilingual safety by 15–20% [31], motivating the development of native generation approaches rather than translation-augmented pipelines. A broader survey on AI language technologies in multilingual healthcare identified translation in language-discordant clinical settings as a key application area with substantial unmet need [32]. These findings collectively support Aarogya Sathi's adoption of a native generation strategy — producing Hindi, Marathi, and Hinglish responses directly from the LLM rather than translating English outputs — to preserve clinical intent and eliminate translation-induced semantic drift.

### 2.4 Agentic AI in Clinical Settings

Agentic AI systems comprising multiple autonomous agents that collaborate to accomplish complex tasks represent the next evolution beyond single-model chatbots in healthcare. The AgentDS Healthcare Benchmark demonstrated that while purely automated agentic approaches struggle with clinical reasoning, human-in-the-loop guidance significantly improves prediction accuracy [36]. HealthFlow introduced self-evolving agents with meta-planning capabilities for autonomous healthcare research, showing that agents can adapt reasoning strategies dynamically across domains [37]. Security considerations are paramount in this context: a study on Zero Trust architecture for autonomous AI in healthcare revealed significant vulnerabilities when agents possess unrestricted shell execution, file access, and database query capabilities [38]. Multi-agent norm perception research further explored how distributed healthcare agents can dynamically learn and comply with social, legal, ethical, empathetic, and cultural (SLEEC) norms [39]. A directly relevant framework proposed combining multilingual capability, privacy-first design, and Model Context Protocol (MCP) agent orchestration for healthcare applications [40].

### 2.5 Data Sovereignty and Regulatory Compliance

The Digital Personal Data Protection Act (DPDP), 2023, is India's primary legislation governing digital personal data processing. Healthcare providers are likely to be classified as Significant Data Fiduciaries, requiring appointment of India-based Data Protection Officers, Data Protection Impact Assessments, and regular compliance audits, with penalties reaching up to INR 250 crore for non-compliance [41]. The Ayushman Bharat Digital Mission (ABDM) provides foundational digital health infrastructure including Ayushman Bharat Health Accounts (ABHA) and interoperability standards for national health records exchange [42].

Despite the substantial progress documented above, a critical gap persists: no existing digital health platform combines ICMR-grounded clinical retrieval, real-time environmental intelligence, native vernacular generation, agentic reasoning with tool dispatch, longitudinal session memory, and DPDP-compliant architecture into a unified system. Aarogya Sathi is designed to address precisely this gap.

---

## 3. System Architecture and Methodology

### 3.1 High-Level Architecture

Aarogya Sathi employs a three-tier architecture comprising a Flutter-based mobile frontend, a FastAPI backend serving asynchronous Server-Sent Events (SSE), and an Agentic ReAct pipeline that orchestrates tool-based reasoning over ICMR clinical knowledge. The mobile tier handles user interaction, Health Connect SDK integration for wearable data collection, GPS-based location services, and on-device health profile storage. The backend tier manages safety routing, intent classification, tool dispatch, proactive insight generation, context assembly, and LLM-based response generation. The knowledge tier provides a curated corpus of 34 structured markdown files derived from ICMR clinical guidelines, organized through an Open Knowledge Format (OKF) Navigator. Fig. 1 illustrates the overall system architecture.

![Fig. 1. Three-tier system architecture: Flutter mobile client with Health Connect SDK integration, FastAPI backend with Safety Router and Agentic ReAct pipeline, and ICMR Knowledge Bundle comprising 34 structured markdown files across five clinical categories.](../docs/diagrams/images/figure_3_1_overall_system_architecture.png)

### 3.2 Agentic ReAct Pipeline

The core innovation of this work is the Agentic ReAct (Reasoning and Acting) pipeline, which extends traditional single-pass RAG by introducing intent-driven tool dispatch and proactive insight injection. Unlike conventional retrieval-augmented systems that perform a single retrieval pass for every query, the ReAct pipeline first classifies user intent into one of five categories — greeting, health_query, vital_check, aqi_query, or lifestyle — using a two-tier classification strategy. The fast tier employs compiled regular expression heuristics for common patterns (e.g., greetings in Hindi, Marathi, and English; vital sign keywords; pollution-related terms), while ambiguous queries fall through to an LLM-based classifier using Qwen 27B with a structured prompt. Based on the classified intent, the pipeline dispatches one or more specialized tools: `tool_search_knowledge` for ICMR guideline retrieval, `tool_analyze_vitals` for Health Connect data interpretation using ICMR Asian-specific thresholds, and `tool_get_environmental_data` for real-time AQI and weather data from the WAQI and Open-Meteo APIs. Multi-domain queries such as "I have diabetes and the pollution is bad today" trigger parallel dispatch of both knowledge retrieval and environmental data tools, enabling integrated clinical-environmental reasoning. Fig. 2 presents the complete seven-phase ReAct pipeline as a state machine.

![Fig. 2. Agentic ReAct pipeline state machine: Phase 1 (Safety Gate), Phase 2 (Environment and Session Loading), Phase 3 (Intent Classification), Phase 4 (Tool Dispatch), Phase 5 (Proactive Insights Injection), Phase 6 (Context Assembly and LLM Generation via Qwen 27B), Phase 7 (Session Persistence).](../docs/diagrams/images/figure_3_2_react_loop_state_machine.png)

Following tool execution, the pipeline injects proactive health insights derived from longitudinal session memory. The insights engine analyses the user's vital history for clinically significant patterns — elevated heart rate above 100 bpm, blood oxygen saturation below 95%, Stage 2 hypertension readings at or above 140/90 mmHg, and AQI threshold warnings for users with documented respiratory conditions. These unsolicited insights are injected into the LLM context alongside retrieved documents, user profile data, wearable telemetry, and environmental conditions, enabling the generation of contextually grounded and proactively informative responses.

### 3.3 Safety Framework

Clinical safety is enforced through a Semantic Router deployed as a pre-processing layer before the agentic pipeline. The router uses a HuggingFace sentence transformer encoder (`all-MiniLM-L6-v2`, 22 million parameters) to embed incoming queries and compare them against 42 classified utterance templates via cosine similarity. Three safety routes are defined: emergency (14 templates intercepting life-threatening situations with 112 redirect), prescription (14 templates blocking medication dosage requests), and non-medical (14 templates rejecting out-of-scope queries such as homework help or creative writing). When a query matches a safety route above the configured similarity threshold, the system returns a predefined safe response and terminates the request without invoking the LLM, ensuring that clinically dangerous queries are handled in under 50 milliseconds. Fig. 3 illustrates the safety router architecture and clinical triage flow.

![Fig. 3. Semantic Router architecture: incoming queries are embedded using all-MiniLM-L6-v2 and compared via cosine similarity against 42 classified utterance templates spanning emergency, prescription, and non-medical categories. Matched queries receive immediate safe responses; unmatched queries proceed to the Agentic Pipeline.](../docs/diagrams/images/figure_4_3_safety_router_clinical_triage.png)

### 3.4 ICMR Knowledge Base

The retrieval foundation of Aarogya Sathi is the Open Knowledge Format (OKF) Navigator, which operates on a curated corpus of 34 structured markdown files derived from ICMR clinical guidelines. The corpus is organized into five categories: Conditions (12 files covering Type 2 Diabetes, Hypertension, Asthma, COPD, Obesity, Chronic Kidney Disease, Anemia, Thyroid Disorders, Coronary Artery Disease, Dengue, and Tuberculosis), Drugs (7 files for commonly prescribed Indian medications), Emergency (6 files for acute situations), Environmental (4 files for climate-health correlations), and Lifestyle (6 files for preventive health behaviours). A relevancy grading module employs an 8B parameter LLM to assess retrieval quality through parallel relevance scoring before passing context to the primary 27B generation model. This scope-matched, precision-first approach follows the evidence from Anuyah et al. showing that tightly scoped retrieval outperforms broad knowledge base unions [22]. Fig. 4 illustrates the ICMR knowledge graph structure.

![Fig. 4. ICMR Knowledge Graph: five-category OKF bundle structure with 34 curated markdown files covering Conditions (12), Drugs (7), Emergency (6), Environmental (4), and Lifestyle (6) clinical domains, navigated through a root index with description-based routing.](../docs/diagrams/images/figure_4_5_icmr_knowledge_graph.png)

### 3.5 Environmental Intelligence

The environmental intelligence module correlates hyper-local air quality data with individual health profiles to enable proactive risk prevention. Real-time pollutant data — PM2.5, PM10, NO₂, SO₂, O₃, and CO — is fetched from the World Air Quality Index (WAQI) API, which provides coverage across 1,000+ Indian stations via the Central Pollution Control Board (CPCB) network. The system processes this data through CPCB National Air Quality Index (NAQI) thresholds to generate condition-specific health advisories. For instance, a user with documented asthma who opens the application on a day when local PM2.5 exceeds the "Moderately Polluted" threshold (AQI 101–200) receives an unprompted respiratory precaution alert advising them to carry a reliever inhaler. The system employs ICMR Asian-specific clinical cutoffs that differ from Western standards — notably, BMI thresholds are set two points lower for Indian populations (Normal: 18.5–22.9, Overweight: ≥23.0, Obese: ≥27.5 kg/m²) because South Asian populations develop metabolic syndrome and insulin resistance at lower BMI values. Fig. 5 presents the CPCB NAQI calculation pipeline.

![Fig. 5. CPCB NAQI Calculation Pipeline: WAQI API pollutant data is processed through six pollutant-specific sub-indices (PM2.5, PM10, NO₂, SO₂, O₃, CO), with the maximum sub-index determining the overall NAQI value and its corresponding health advisory category.](../docs/diagrams/images/figure_4_4_cpcb_naqi_calculation.png)

### 3.6 Multilingual Engine

Aarogya Sathi adopts a native generation approach, producing Hindi, Marathi, and Hinglish responses directly from Qwen 27B rather than translating English outputs through a post-hoc pipeline. This design decision is motivated by the CLINIC benchmark finding that English-centric evaluation overestimates multilingual safety by 15–20% [31], and by the observation that medical terminology used in Indian clinical settings naturally follows a code-mixed pattern (e.g., "blood pressure" and "sugar level" remain in English within Hindi conversational contexts). The native generation approach eliminates the +200ms latency overhead and semantic drift inherent in translation pipelines such as IndicTrans2, while preserving the natural code-mixing patterns that Indian patients encounter in healthcare interactions. A Sarvam AI (mayura:v1) translation fallback with multi-key rotation handles edge cases where native generation is insufficient. The combined linguistic reach of the three supported languages covers approximately 808 million speakers, representing 58% of India's population.

### 3.7 Privacy-by-Design Architecture

The system achieves DPDP Act 2023 compliance through architectural decisions rather than policy overlays. Health profile data is stored exclusively on-device via Flutter `SharedPreferences`. Medical documents — handwritten prescriptions, diagnostic lab reports, radiological scans, and immunization records — are ingested into an isolated sandboxed directory (`/medical_vault/`) that never synchronizes to any cloud endpoint. Session memory is maintained as local JSON files per anonymous `user_id`, and the backend operates in a retrieval-only mode that queries public ICMR knowledge bundles and environmental APIs without storing any patient-identifiable information. LLM prompts are assembled with anonymized context, ensuring that no personal health data is transmitted to third-party inference providers (Groq, SambaNova, or Cerebras). Deletion of the application erases all personal data, satisfying the right-to-erasure provision. Fig. 6 illustrates the DPDP privacy boundary architecture.

![Fig. 6. DPDP Privacy Boundary: health profile, wearable telemetry, and medical vault documents remain on-device (left boundary). The backend (right boundary) operates in retrieval-only mode, querying public ICMR knowledge and environmental APIs. LLM prompts contain only anonymized clinical context.](../docs/diagrams/images/figure_3_3_dpdp_privacy_boundary.png)

---

## 4. Implementation

### 4.1 Technology Stack

The technology stack was selected to optimize for clinical accuracy, operational reliability within free-tier constraints, and regulatory compliance. Table 3 summarizes the major components and selection rationale.

**Table 3: Technology Stack and Selection Rationale**

| Component | Technology | Selection Rationale |
|-----------|-----------|-------------------|
| Primary LLM | Qwen 27B (qwen3.8-27b) | Superior multilingual performance in Hindi and Marathi; clinical reasoning without fine-tuning |
| LLM Hosting | Groq Cloud API | Free-tier with ultra-low latency; multi-key pooling enables sustained availability |
| Safety Encoder | all-MiniLM-L6-v2 (22M params) | Lightweight, fast cosine similarity inference for real-time safety routing |
| Knowledge Storage | OKF Markdown (34 files) | Zero infrastructure cost; curated ICMR content with navigator-based traversal |
| Translation Fallback | Sarvam AI (mayura:v1) | India-specific healthcare domain training; free development credits |
| Environmental APIs | WAQI + Open-Meteo | 1,000+ Indian CPCB stations; fully free with <5s latency |
| Mobile Framework | Flutter + Health Connect SDK | Cross-platform; native wearable data integration; single Dart codebase |
| Backend Framework | FastAPI (Python 3.11) | Native async support; built-in SSE streaming; Pydantic model validation |

### 4.2 Backend Architecture

The backend was implemented in Python 3.11 using FastAPI with asynchronous request handling and exposes three RESTful endpoints. The primary chat endpoint (`POST /api/chat`) accepts a JSON payload containing the user query, language preference, health profile, wearable data, GPS coordinates, and conversation history, and streams the response via Server-Sent Events with token-by-token delivery at 15ms intervals. The AQI endpoint (`GET /api/aqi`) returns CPCB-standard NAQI values with pollutant breakdowns for given coordinates. The insights endpoint (`GET /api/session/{user_id}/insights`) returns proactive health recommendations derived from longitudinal session analysis.

LLM inference was handled through a multi-key pooling mechanism with automatic provider cascade. When a Groq API key encounters rate limiting (HTTP 429), the system rotates to the next available key within the comma-separated key pool. If all Groq keys are exhausted, the system cascades sequentially to SambaNova and then Cerebras providers, implementing the same rotation logic at each tier. This architecture maintains zero-downtime operation within free-tier constraints — a critical requirement for a system designed to be accessible without cost barriers. The backend comprises 14 modules totalling approximately 1,500 lines of Python.

### 4.3 Frontend Architecture

The mobile client was developed using Flutter and Dart, employing a decoupled Provider state-management pattern with six reactive providers managing identity and language state, dialogue orchestration, vital sign logging with ICMR classification, sensor telemetry from the Health Connect SDK, sovereign document storage in the on-device medical vault, and clinical biometrics input including Asian ICMR BMI computation. The Health Connect SDK integration collects ten biometric data types — daily steps, heart rate, resting heart rate, SpO2, blood glucose, blood pressure, sleep duration, body temperature, calories burned, and weight — providing comprehensive wearable-derived health context for personalized clinical guidance. The user interface supports dynamic theme switching and real-time language switching between English, Hindi, and Marathi without session loss.

---

## 5. Evaluation and Results

### 5.1 Evaluation Methodology

Aarogya Sathi was evaluated using a Gold Standard dataset of 32 question-answer pairs spanning the major NCD domains covered by the ICMR knowledge base. Each pair was constructed by the development team with reference to published ICMR guidelines to ensure clinical validity. The dataset was distributed across five categories: Diabetes Management (8 pairs), Hypertension and CVD (6 pairs), Respiratory and AQI (6 pairs), Nutrition and Diet (6 pairs), and General Preventive Health (6 pairs). The evaluation employed an LLM-as-Judge methodology using `openai/gpt-oss-20b` as the assessment model, following the approach validated in recent RAG evaluation literature [25]. For each system response, the judge model assessed four dimensions on a 1–5 scale: Faithfulness (accuracy of clinical claims relative to retrieved ICMR content), Relevancy (alignment with the user's specific question), Completeness (coverage of pertinent clinical aspects including risk factors, management steps, and referral advice), and Safety (absence of dangerous, misleading, or out-of-scope advice).

### 5.2 Results

The system demonstrated strong performance across all four evaluation dimensions, as presented in Table 4. Faithfulness scores were consistently high, reflecting the tight coupling between OKF Navigator retrieval and response generation. The safety dimension achieved the highest mean score (4.72/5.00), attributable to the Semantic Router's pre-generation interception of unsafe queries.

**Table 4: Evaluation Results — LLM-as-Judge Scoring (N = 32)**

| Dimension | Mean (1–5) | Min | Max | Std Dev |
|-----------|-----------|-----|-----|---------|
| Faithfulness | 4.56 | 3.5 | 5.0 | 0.38 |
| Relevancy | 4.63 | 3.5 | 5.0 | 0.35 |
| Completeness | 4.50 | 3.0 | 5.0 | 0.42 |
| Safety | 4.72 | 4.0 | 5.0 | 0.28 |
| **Composite** | **4.60** | — | — | **0.36** |

The Semantic Router was tested independently against a separate set of 42 adversarial queries spanning emergency scenarios (14), prescription requests (14), and non-medical queries (14). The router achieved a 100% interception rate across all three categories with zero false positives and a response latency consistently below 50 milliseconds. These results are consistent with the evidence from Xia et al., who documented a 43.8% average improvement in factual accuracy when medical language models are augmented with domain-aware retrieval guardrails [23], and with the NMISS methodology from Priola validating that RAG-augmented systems produce fewer false-positive hallucinations than unaugmented counterparts [24].

Automated verification further confirmed end-to-end operational reliability through six test suites exercising medical file vault serialization (6 tests), Asian ICMR BMI computation and classification (6 tests), multilingual state persistence across sessions (4 tests), Provider widget hierarchy integrity (1 test), backend Pydantic schema contracts (6 assertions), and full static code analysis across 27 Dart source files. All 23 tests passed at a 100% rate with zero static analysis warnings, executing in aggregate in under 10 seconds.

---

## 6. Discussion

The evaluation results confirm the viability of Agentic RAG as an architecture for clinically safe health assistants in the Indian context. The ReAct framework's requirement that the system generate explicit reasoning traces before tool invocation provides a level of auditability that traditional single-pass RAG pipelines lack. When the system encounters a query about "managing diabetes with high air pollution," the intent classifier routes the query through both `tool_search_knowledge` (retrieving ICMR diabetes management guidelines) and `tool_get_environmental_data` (fetching real-time AQI for the user's GPS coordinates), producing a response that integrates clinical and environmental context. This multi-tool composition is fundamentally not achievable with single-pass retrieval systems, which must select a single retrieval strategy at query time. Table 5 presents a systematic comparison of the Agentic ReAct architecture against traditional RAG approaches.

**Table 5: Architectural Comparison — Agentic ReAct vs. Traditional RAG**

| Aspect | Traditional RAG | Agentic ReAct (This Work) |
|--------|----------------|--------------------------|
| Query processing | Single retrieval pass | Intent classification followed by targeted tool dispatch |
| Tool access | Retriever only | Three modular tools (knowledge, vitals, environment) |
| Multi-source reasoning | Not supported | Parallel tool composition across clinical and environmental domains |
| Proactive behaviour | Reactive only | Unsolicited insight injection from longitudinal session memory |
| Auditability | Retrieved documents visible | Full reasoning trace: intent → tools → insights → generation |
| Safety enforcement | Post-generation filtering | Pre-generation Semantic Router blocking (< 50ms) |
| Personalization | Query-based retrieval only | Integrated profile, wearable, AQI, history, and language context |

The native multilingual generation approach proved more effective than translation-augmented alternatives for preserving clinical intent. When generating Hinglish responses directly, the system naturally incorporated medical terminology that Hindi-speaking patients recognize from clinical encounters (e.g., "blood pressure," "sugar level") alongside Hindi contextual guidance, matching the code-mixed communication patterns documented in Indian healthcare settings. This finding aligns with the CLINIC benchmark's observation that English-centric evaluation overestimates real-world multilingual safety [31] and supports the native generation strategy over post-hoc translation.

The environmental intelligence module addresses a gap that no competing platform has attempted to fill. By correlating WAQI real-time data with individual health conditions, Aarogya Sathi transitions from reactive symptom management to proactive risk prevention — a functionality grounded in the epidemiological evidence linking ambient air pollution to 4.2 million premature deaths globally [9] and India's position as the region with the highest population-weighted PM2.5 concentrations [11]. The privacy-by-design architecture further demonstrates that DPDP compliance need not compromise system functionality, directly addressing the Zero Trust security concerns raised in [38] regarding autonomous AI agents with broad system access.

---

## 7. Limitations and Future Work

Several limitations constrain the current evaluation and should be acknowledged. The Gold Standard dataset of 32 question-answer pairs, while carefully constructed from ICMR guidelines, is insufficient for comprehensive clinical validation and lacks the statistical power to make definitive claims about performance across the full range of NCD queries. Expanding this dataset to 500 or more pairs covering multi-morbidity scenarios, edge cases, and adversarial inputs is a priority for future work. The system currently requires internet connectivity for LLM inference through the Groq Cloud API, rendering it unsuitable for deployment in rural areas with intermittent connectivity. Deploying quantized on-device models, such as 4-bit GGUF variants of Qwen, would enable fully offline operation. The current language support covers English, Hindi, and Marathi, representing approximately 58% of India's population; expansion via IndicTrans2 and Sarvam AI to the remaining 19 scheduled Indian languages would significantly broaden accessibility. The hardcoded AQI-to-health thresholds should be replaced with personalized risk models trained on individual health trajectories, and no integration with the Ayushman Bharat Digital Mission (ABDM) infrastructure currently exists for national health records exchange [42].

Future development will focus on three directions. First, ABDM and ABHA interoperability will enable Aarogya Sathi to access and contribute to India's national health records ecosystem. Second, the agentic architecture will be extended to support multi-agent collaboration with specialized agents for nutrition, exercise, mental health, and medication adherence coordinating through a shared context protocol, following the meta-planning patterns demonstrated in HealthFlow [37]. Third, continuous wearable streaming will be integrated to enable real-time acute event detection from Health Connect data. Throughout this evolution, Aarogya Sathi will remain positioned as a health information assistant — not a diagnostic or prescriptive tool — following the evidence from the AgentDS Healthcare Benchmark showing that human-guided agentic approaches significantly outperform fully autonomous ones for clinical reasoning [36].

---

## 8. Project Timeline and Team Contributions

The development of Aarogya Sathi followed a structured six-phase timeline aligned with the NMIMS capstone project calendar. Table 6 presents the milestone schedule and work distribution across the team.

**Table 6: Project Milestones and Work Distribution**

| Phase | Timeline | Deliverables | Contributors |
|-------|----------|-------------|-------------|
| Research and System Design | Jul–Aug 2026 | Literature review (42 IEEE sources), system architecture design, ICMR knowledge curation | All members |
| Backend Core Development | Aug–Sep 2026 | Agentic RAG pipeline, Semantic Router, multi-key LLM pooling, API endpoints | Jayesh Patil |
| Frontend and UX Development | Sep–Oct 2026 | Flutter application, Health Connect SDK, Medical File Vault, Profile Engine | Abhijit Patil, Ritesh Pawar |
| Integration and Testing | Oct 2026 | End-to-end integration, Gold Standard evaluation (32 QA pairs), automated test suite (23 tests) | All members |
| Documentation and Reporting | Oct–Nov 2026 | Research paper, interim report (Review 2), system architecture diagrams | All members |
| Final Submission and Deployment | Dec 2026 | Final capstone report, viva preparation, Play Store deployment | All members |

---

## 9. Conclusion

This paper presented Aarogya Sathi, an Agentic RAG-based digital health assistant that addresses the critical gap in India's digital health ecosystem by integrating six complementary pillars into a unified preventive health platform. The ICMR-grounded knowledge retrieval pipeline ensures clinical accuracy through scope-matched document retrieval and relevancy grading. The Agentic ReAct architecture enables multi-source clinical reasoning through intent-driven tool dispatch, surpassing the capabilities of traditional single-pass RAG systems. The Semantic Router safety framework provides a defence-in-depth layer achieving 100% interception of unsafe queries with zero false positives and sub-50ms response times. Native vernacular generation in Hindi, Marathi, and Hinglish preserves clinical intent while reaching 58% of India's population without translation overhead. Real-time environmental intelligence correlates WAQI air quality data with individual health profiles for proactive risk prevention. The privacy-by-design architecture achieves DPDP Act 2023 compliance through on-device data storage and a retrieval-only backend.

Evaluation on a 32-pair Gold Standard dataset yielded a composite score of 4.60 out of 5.00 across faithfulness, relevancy, completeness, and safety dimensions. With a documented 14.3:1 return on investment for preventive digital health interventions [18] and the growing NCD burden responsible for 63% of Indian mortality [1], Aarogya Sathi represents a scalable, economically viable, and legally compliant approach to democratizing preventive healthcare across the world's most populous nation.

---

## References

[1] T. Vos et al., "Global burden of 369 diseases and injuries in 204 countries and territories, 1990–2019: a systematic analysis for the Global Burden of Disease Study 2019," *The Lancet*, vol. 396, no. 10258, pp. 1204–1222, Oct. 2020. doi: 10.1016/S0140-6736(20)30925-9.

[2] G. A. Roth et al., "Global Burden of Cardiovascular Diseases and Risk Factors, 1990–2019: Update From the GBD 2019 Study," *J. Am. Coll. Cardiol.*, vol. 76, no. 25, pp. 2982–3021, Dec. 2020. doi: 10.1016/j.jacc.2020.11.010.

[3] GBD 2021 Diabetes Collaborators, "Global, regional, and national burden of diabetes from 1990 to 2021, with projections of prevalence to 2050," *The Lancet*, vol. 402, no. 10397, pp. 203–234, Jul. 2023. doi: 10.1016/S0140-6736(23)01301-6.

[4] The GBD 2015 Obesity Collaborators, "Health Effects of Overweight and Obesity in 195 Countries over 25 Years," *N. Engl. J. Med.*, vol. 377, pp. 13–27, Jul. 2017. doi: 10.1056/NEJMoa1614362.

[6] World Economic Forum, "The Economic Impact of Non-Communicable Disease in China and India: Estimates, Projections, and Comparisons," Harvard School of Public Health, 2014.

[8] GBD 2019 Risk Factors Collaborators, "Global burden of 87 risk factors in 204 countries and territories, 1990–2019," *The Lancet*, vol. 396, no. 10258, pp. 1223–1249, Oct. 2020. doi: 10.1016/S0140-6736(20)30752-2.

[9] J. Lelieveld, J. S. Evans, M. Fnais, D. Giannadaki, and A. Pozzer, "The contribution of outdoor air pollution sources to premature mortality on a global scale," *Nature*, vol. 525, pp. 367–371, Sep. 2015. doi: 10.1038/nature15371.

[10] I. Manisalidis, E. Stavropoulou, A. Stavropoulos, and E. Bezirtzoglou, "Environmental and Health Impacts of Air Pollution: A Review," *Front. Public Health*, vol. 8, art. 14, Feb. 2020. doi: 10.3389/fpubh.2020.00014.

[11] A. J. Cohen et al., "Estimates and 25-year trends of the global burden of disease attributable to ambient air pollution," *The Lancet*, vol. 389, no. 10082, pp. 1907–1918, May 2017. doi: 10.1016/S0140-6736(17)30505-6.

[13] S. Salvi and P. J. Barnes, "Is exposure to biomass smoke the biggest risk factor for COPD globally?," *Chest*, vol. 138, no. 1, pp. 3–6, Jul. 2010. doi: 10.1378/chest.10-0645.

[16] Ministry of Health and Family Welfare, Government of India, "eSanjeevani Telemedicine Platform." [Online]. Available: https://esanjeevani.mohfw.gov.in/

[18] R. Masters, E. Anwar, B. Collins, R. Cookson, and S. Capewell, "Return on investment of public health interventions: a systematic review," *J. Epidemiol. Community Health*, vol. 71, no. 8, pp. 827–834, 2017. doi: 10.1136/jech-2016-208141.

[19] A. Acosta et al., "Multimodal biomedical AI," *Nat. Med.*, vol. 28, pp. 1773–1784, Sep. 2022. doi: 10.1038/s41591-022-01981-2.

[20] L. Laranjo et al., "Conversational agents in healthcare: a systematic review," *J. Am. Med. Inform. Assoc.*, vol. 25, no. 9, pp. 1248–1258, Sep. 2018. doi: 10.1093/jamia/ocy072.

[21] S. Siriwardhana, R. Weerasekera, E. Wen, T. Kaluarachchi, R. Rana, and S. Nanayakkara, "Improving the Domain Adaptation of Retrieval Augmented Generation (RAG) Models for Open Domain Question Answering," *Trans. Assoc. Comput. Linguist.*, 2022. arXiv: 2210.02627.

[22] S. Anuyah et al., "Domain-Specific Knowledge Graphs in RAG-Enhanced Healthcare LLMs," arXiv preprint, Jan. 2026. arXiv: 2601.15429.

[23] P. Xia et al., "MMed-RAG: Versatile Multimodal RAG System for Medical Vision Language Models," in *Proc. Int. Conf. Learn. Represent. (ICLR)*, 2025. arXiv: 2410.13085.

[24] M. P. Priola, "Addressing Hallucinations with RAG and NMISS in Italian Healthcare LLM Chatbots," arXiv preprint, Dec. 2024. arXiv: 2412.04235.

[25] A. Gerner et al., "Deepchecks: Evaluating Retrieval-Augmented Generation (RAG)," arXiv preprint, May 2026. arXiv: 2605.14488.

[26] Census of India 2011, "Language Atlas of India," Office of the Registrar General, Government of India, 2011.

[28] AI4Bharat, "IndicTrans2: Towards High-Quality and Accessible Machine Translation Models for all 22 Scheduled Indian Languages," arXiv, 2023. arXiv: 2305.16307.

[29] "Conversational Domain Adaptation of IndicTrans2 across 21 Indic Languages via Experience Replay and Model Soups," arXiv, 2026. arXiv: 2606.29024.

[31] "CLINIC: Evaluating Multilingual Trustworthiness in Language Models for Healthcare," arXiv, 2025. arXiv: 2512.11437.

[32] "Artificial intelligence language technologies in multilingual healthcare: Grand challenges ahead," arXiv, 2026. arXiv: 2605.01441.

[36] "Human-Guided Agentic AI for Multimodal Clinical Prediction: Lessons from AgentDS Healthcare Benchmark," arXiv, 2026. arXiv: 2602.19502.

[37] "HealthFlow: A Self-Evolving AI Agent with Meta Planning for Autonomous Healthcare Research," arXiv, 2025. arXiv: 2508.02621.

[38] "Caging the Agents: A Zero Trust Security Architecture for Autonomous AI in Healthcare," arXiv, 2026. arXiv: 2603.17419.

[39] "Multi-Agent Norm Perception and Induction in Distributed Healthcare," arXiv, 2024. arXiv: 2412.18454.

[40] "Agentic-AI Healthcare: Multilingual, Privacy-First Framework with MCP Agents," arXiv, 2025. arXiv: 2510.02325.

[41] Government of India, "The Digital Personal Data Protection Act, 2023," *The Gazette of India*, Aug. 2023. [Online]. Available: https://www.meity.gov.in/

[42] National Health Authority, Government of India, "Ayushman Bharat Digital Mission (ABDM)." [Online]. Available: https://abdm.gov.in/
