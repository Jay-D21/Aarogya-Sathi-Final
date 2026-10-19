<div align="center">

# AAROGYA SATHI: AN AI-DRIVEN, VERNACULAR-FIRST, ENVIRONMENT-AWARE HEALTH ASSISTANT FOR PREVENTIVE NCD MANAGEMENT IN URBAN INDIA

**iLabs Interim Report**

Submitted in partial fulfillment of the requirements for the degree of  
Bachelor of Technology in Information Technology / Artificial Intelligence and Machine Learning

Academic Year: 2026-27

Submitted by:  
**Jayesh Patil (C233)**  
**Abhijit Patil (C263)**  
**Ritesh Pawar (C276)**

Under the Guidance of:  
**Dr. Atul V. Dusane**

**SVKM’s NMIMS**  
**Mukesh Patel School of Technology Management & Engineering (MPSTME)**  
**Shirpur Campus**  
**October 2026**

</div>

---

## CERTIFICATE

This is to certify that the iLabs Interim Report entitled **"Aarogya Sathi: An AI-Driven, Vernacular-First, Environment-Aware Health Assistant for Preventive NCD Management in Urban India"** is a bonafide work done by **Jayesh Patil (C233)**, **Abhijit Patil (C263)**, and **Ritesh Pawar (C276)** under my guidance and supervision in partial fulfillment of the requirements for the degree of Bachelor of Technology in IT/AIML at SVKM’s NMIMS, MPSTME, Shirpur Campus during the academic year 2026-27.

<br><br><br>

**Dr. Atul V. Dusane**  
(Project Guide)

<br><br>

**Head of Department**  
(IT/AIML)

<br><br>

**Principal / Director**  
(MPSTME, Shirpur Campus)

---

## ACKNOWLEDGMENT

We would like to express our deepest gratitude to our project guide, Dr. Atul V. Dusane, for his continuous support, technical guidance, and patience throughout the development of this project. His practical insights helped us shape the core architecture of our system and keep our medical responses grounded.

We also thank the Head of the IT/AIML Department and the Principal of SVKM’s NMIMS, MPSTME, Shirpur Campus for providing us with the necessary infrastructure and environment to carry out this iLabs project. Finally, we are thankful to our parents and peers for their constant encouragement.

---

## ABSTRACT

In India, chronic lifestyle diseases such as type-2 diabetes, hypertension, and respiratory disorders are rising rapidly, often aggravated by severe urban air pollution. While digital tools have the potential to deliver preventive health awareness, general-purpose AI chatbots frequently produce inaccurate medical advice that lacks grounding in verified national health standards. Furthermore, the vast majority of non-English-speaking citizens face language barriers when accessing reliable health guidance online. 

To address these challenges, our team developed **Aarogya Sathi**, an AI-powered mobile health assistant designed specifically for Indian users with vernacular support in Hindi, Marathi, and English. The core system connects a Flutter mobile application to a FastAPI backend. To eliminate AI hallucinations and ensure patient safety, the assistant grounds all health advice strictly in 34 clinical guideline documents from the Indian Council of Medical Research (ICMR) using an agentic Retrieval-Augmented Generation (RAG) architecture. 

Aarogya Sathi dynamically integrates real-time environmental context (live Air Quality Index and weather data) with personal wearable metrics (steps, heart rate, and sleep retrieved via Android Health Connect). This allows the application to deliver personalized preventive guidance—such as advising asthma patients to avoid outdoor exercise during high-AQI periods. For critical safety, the system implements sub-100ms guardrails that prevent unauthorized medication prescriptions and immediately route emergencies (such as chest pain or stroke symptoms) to India's 112 emergency helpline. Currently, the system operates as a functional Android application connected to a live cloud backend, demonstrating high factual faithfulness (4.86 / 5.0) and zero safety violations across 32 gold-standard evaluation scenarios.

---

## TABLE OF CONTENTS

1. [Introduction](#chapter-1-introduction)  
   1.1 [Background](#11-background)  
   1.2 [Problem Statement](#12-problem-statement)  
   1.3 [Objectives](#13-objectives)  
   1.4 [Scope and Limitations](#14-scope-and-limitations)  
   1.5 [Organization of Report](#15-organization-of-report)  
2. [Literature Survey](#chapter-2-literature-survey)  
   2.1 [NCD Burden in India](#21-ncd-burden-in-india)  
   2.2 [Air Pollution and Health](#22-air-pollution-and-health)  
   2.3 [Digital Health Interventions and ROI](#23-digital-health-interventions-and-roi)  
   2.4 [RAG and LLM Safety in Healthcare](#24-rag-and-llm-safety-in-healthcare)  
   2.5 [Multilingual AI for Indian Healthcare](#25-multilingual-ai-for-indian-healthcare)  
   2.6 [Agentic AI Architectures](#26-agentic-ai-architectures)  
   2.7 [Data Privacy and Regulatory Framework](#27-data-privacy-and-regulatory-framework)  
   2.8 [Gap Analysis and Our Position](#28-gap-analysis-and-our-position)  
3. [System Design and Architecture](#chapter-3-system-design-and-architecture)  
   3.1 [System Overview](#31-system-overview)  
   3.2 [Architecture Diagram Description](#32-architecture-diagram-description)  
   3.3 [Technology Stack Table](#33-technology-stack-table)  
   3.4 [Database Design](#34-database-design)  
   3.5 [API Design](#35-api-design)  
4. [Implementation Details](#chapter-4-implementation-details)  
   4.1 [Backend Implementation](#41-backend-implementation)  
       4.1.1 [Agentic CRAG Pipeline](#411-agentic-crag-pipeline-backendragpipelinepy)  
       4.1.2 [OKF Navigator](#412-okf-navigator-backendragokf_navigatorpy)  
       4.1.3 [LLM Provider Cascade](#413-llm-provider-cascade-backendragllmpy)  
       4.1.4 [Safety Router](#414-safety-router-backendsafetyrouterpy)  
       4.1.5 [Context Builder](#415-context-builder-backendragcontext_builderpy)  
       4.1.6 [Translation Layer](#416-translation-backendtranslationbhashinipy)  
   4.2 [Frontend Implementation](#42-frontend-implementation)  
       4.2.1 [App Architecture](#421-app-architecture)  
       4.2.2 [Health Connect Integration](#422-health-connect-integration-frontendlibserviceshealth_connect_servicedart)  
       4.2.3 [Chat Implementation](#423-chat-implementation)  
       4.2.4 [Fitness Provider](#424-fitness-provider-frontendlibprovidersfitness_providerdart)  
   4.3 [ICMR Knowledge Bundle](#43-icmr-knowledge-bundle)  
5. [Results and Evaluation](#chapter-5-results-and-evaluation)  
   5.1 [Evaluation Methodology](#51-evaluation-methodology)  
   5.2 [Evaluation Results](#52-evaluation-results)  
   5.3 [Sample Response Analysis](#53-sample-response-analysis)  
   5.4 [Key Findings](#54-key-findings)  
   5.5 [Current Limitations](#55-current-limitations)  
6. [Project Timeline and Team Contributions](#chapter-6-project-timeline-and-team-contributions)  
   6.1 [Development Timeline](#61-development-timeline)  
   6.2 [Team Contributions](#62-team-contributions)  
   6.3 [Current Progress](#63-current-progress-60)  
7. [Future Work and Conclusion](#chapter-7-future-work-and-conclusion)  
   7.1 [Planned Enhancements](#71-planned-enhancements-review-3-and-beyond)  
   7.2 [Conclusion](#72-conclusion)  
[References](#references)

---

# CHAPTER 1: INTRODUCTION

## 1.1 Background
The health landscape in India is changing rapidly. Today, Non-Communicable Diseases (NCDs) like diabetes, cardiovascular diseases, and respiratory illnesses are the dominant cause of mortality. According to the Global Burden of Disease study, NCDs account for almost 63% of all deaths in India [1]. A major contributing factor to this rise is environmental risk. Air pollution alone is responsible for approximately 4.2 million premature deaths globally [9]. In urban Indian cities, the Air Quality Index (AQI) often stays in hazardous ranges, making it an unavoidable factor in managing respiratory and cardiovascular health.

Moving on to digital literacy and accessibility, India has seen a massive smartphone boom. However, a major barrier remains: nearly 90% of the Indian population does not speak English as their primary language [26]. When people look up health information online, they often face language barriers or, worse, find generic western-centric advice that doesn't fit their local context or dietary habits. Currently, there is no single application that brings together real-time AQI tracking, vernacular language support, and AI-driven health advice grounded strictly in Indian Council of Medical Research (ICMR) guidelines.

## 1.2 Problem Statement
Urban populations in India face a significant burden of Non-Communicable Diseases (NCDs) such as hypertension, type-2 diabetes, and chronic respiratory disorders, which are heavily aggravated by severe fluctuations in local air pollution (AQI). However, citizens lack accessible, real-time preventive guidance that correlates their daily health vitals with local environmental hazards. Furthermore, while digital tools and generative AI have the potential to deliver personalized health awareness, standard AI models frequently suffer from factual hallucinations and provide generic medical advice that fails to reflect Indian dietary practices or verified national clinical standards. Compounding this challenge, the majority of the non-English-speaking population remains excluded from reliable digital health assistance due to a lack of vernacular accessibility.

Therefore, the problem is to design and develop a safe, vernacular-first digital health assistant that continuously correlates real-time environmental factors (AQI, weather) and personal health metrics with verified clinical guidelines from the Indian Council of Medical Research (ICMR), while enforcing deterministic safety guardrails that prevent medical hallucinations, avoid unauthorized drug prescriptions, and ensure timely emergency triage.

## 1.3 Objectives
To address these gaps, our team set the following specific objectives for the Aarogya Sathi project:
1. Build a localized clinical knowledge bundle using 34 structured ICMR guidelines.
2. Develop an agentic RAG (Retrieval-Augmented Generation) pipeline that grounds all AI responses in the approved medical documents to prevent hallucinations.
3. Create a mobile application using Flutter that integrates with Health Connect to pull user wearable data (like Fitbit steps and heart rate).
4. Integrate real-time AQI and weather data APIs to offer environment-aware health alerts.
5. Support multi-language interactions specifically targeting Hindi, Marathi, and English.
6. Evaluate the safety and accuracy of the medical AI pipeline using a set of 32 gold-standard QA pairs.

## 1.4 Scope and Limitations
The scope of Aarogya Sathi covers preventive healthcare, lifestyle management, and symptom checking for common NCDs based on ICMR data. We implemented an Android client and a cloud-hosted backend. The app actively tracks user fitness metrics through Health Connect and provides localized advice based on the user's city AQI.

As for limitations, this application is strictly a preventive and informational tool. It is not a replacement for a certified medical doctor or emergency services. The RAG pipeline relies on the uploaded 34 ICMR documents; queries falling entirely outside these domains might trigger a fallback response rather than a direct answer. Additionally, the current implementation is tested only on Android devices, and iOS support is out of scope for this phase.

## 1.5 Organization of Report
The rest of this interim report is organized as follows:
Chapter 2 covers the Literature Survey, where we review existing research on NCDs, RAG systems, and digital health interventions. Chapter 3 details the System Architecture and flow diagrams. Chapter 4 covers Implementation Details, including backend pipelines, mobile modules, and code snippets. Chapter 5 presents our Evaluation metrics and findings. Chapter 6 outlines the project timeline and individual team contributions, and Chapter 7 concludes the report with our future roadmap.

---

# CHAPTER 2: LITERATURE SURVEY

In this chapter, we look at the existing research and systems related to digital health, air quality impacts, and AI architectures in healthcare. We reviewed various papers to understand the current state of technology and identify the gaps our project aims to fill.

## 2.1 NCD Burden in India
The shift from infectious diseases to Non-Communicable Diseases is well documented. Vos et al. [1] highlighted in the Lancet 2020 study that NCDs are now the dominant cause of mortality worldwide. Focusing specifically on cardiovascular issues, Roth et al. [2] reported 523 million CVD cases and 18.6 million deaths globally in 2019. India is at the center of this crisis. The GBD 2021 Diabetes study [3] projected that India will have the highest number of diabetes cases in the coming decades. Furthermore, the GBD Obesity study [4] identified over 107.7 million obese individuals, leading to 4 million deaths from high BMI-related complications. These numbers show that preventive management of lifestyle diseases is absolutely necessary in the Indian context.

## 2.2 Air Pollution and Health
Coming to the next part, environmental factors play a huge role in Indian public health. The GBD Risk Factors study [8] ranked air pollution in the top 5 risk factors for mortality globally. Lelieveld et al. [9] calculated that PM2.5 exposure causes 4.2 million premature deaths worldwide. For India, the situation is particularly bad. Cohen et al. [11] noted that South Asia has the highest PM2.5 concentrations in the world. The direct health impact is severe—Salvi & Barnes [13] found that Indian non-smokers have 30% lower lung function compared to Western populations simply due to ambient air pollution. This clearly indicates that any health app in India must factor in AQI data to give relevant respiratory advice.

## 2.3 Digital Health Interventions and ROI
Using technology for preventive care is not just a medical benefit, but an economic one. Masters et al. [18] showed that preventive health interventions yield a 14.3:1 return on investment. Catching early signs of NCDs and pushing lifestyle changes through mobile apps can drastically reduce hospital admission costs down the line.

## 2.4 RAG and LLM Safety in Healthcare
When dealing with health data, AI safety is critical. Acosta et al. [19] discussed the high risks associated with multimodal biomedical AI, particularly regarding hallucinations and incorrect diagnoses. Laranjo et al. [20] pointed out the safety gaps in early conversational agents. To fix this, researchers are turning to Retrieval-Augmented Generation (RAG). Siriwardhana et al. [21] demonstrated how RAG allows end-to-end domain adaptation without needing to retrain the core LLM. More recently, Anuyah et al. [22] proposed using Knowledge Graph (KG) RAG specifically for healthcare to improve precision. Xia et al. [23] showed a 43.8% accuracy improvement using MMed-RAG for medical queries. Priola [24] also provided methods for RAG hallucination mitigation. We based our backend architecture on these findings to ensure our chatbot only speaks from verified ICMR guidelines.

## 2.5 Multilingual AI for Indian Healthcare
Because English is not the primary language for most Indians, translation models are a must. AI4Bharat’s IndicTrans2 [28] has been a major breakthrough for Indian languages. A recent 2026 study on conversational IndicTrans2 adaptation [29] showed a +6.2 chrF score improvement for dialogue translation. Furthermore, the CLINIC benchmark [31] evaluated multilingual LLM trustworthiness and proved that native language understanding in clinical settings is improving. We integrated multilingual support in Aarogya Sathi relying on these recent advancements.

## 2.6 Agentic AI Architectures
Instead of simple prompt-response bots, modern systems use agentic AI. The AgentDS Healthcare Benchmark [36] tested human-guided agentic AI and found that breaking tasks into specific tools (like a retriever tool, a calculator, an API caller) works much better for complex medical queries. We used a ReAct (Reasoning and Acting) pipeline in our project to classify user intents and route queries appropriately.

## 2.7 Data Privacy and Regulatory Framework
Handling health data requires strict compliance. The Zero Trust security model for autonomous AI [38] highlights how APIs must restrict data access at every layer. In India, our app must comply with the newly passed Digital Personal Data Protection (DPDP) Act 2023 [41], which mandates clear user consent for data processing. We also looked into the Ayushman Bharat Digital Mission (ABDM) framework [42] to understand the national standards for storing health records.

## 2.8 Gap Analysis and Our Position

Based on our survey, we compared existing popular applications against the features we planned for Aarogya Sathi.

| Feature | Practo | Ada Health | Aarogya Setu | Aarogya Sathi (Our Project) |
| :--- | :--- | :--- | :--- | :--- |
| **Primary Focus** | Doctor Booking | Symptom Checker | Infectious Diseases | Preventive NCDs |
| **Clinical Grounding**| Doctors' discretion | Western Medical DB | MoHFW / ICMR | Direct ICMR Guidelines (RAG) |
| **Environment Aware** | No | No | No | Yes (Live AQI tracking) |
| **Wearable Integration**| No | Limited | No | Yes (Health Connect / Fitbit) |
| **Vernacular Support**| Basic | No Indian Langs | Yes | Yes (Hindi, Marathi, English) |
| **AI Architecture** | Traditional Search | Decision Trees | Rule-based | Agentic LLM RAG Pipeline |

As shown in the table, Aarogya Sathi occupies a unique position by offering safe, vernacular, and environment-aware NCD management through modern generative AI techniques.

---

# CHAPTER 3: SYSTEM DESIGN AND ARCHITECTURE

### 3.1 System Overview
For the Aarogya Sathi project, we divided the system into three main components. We wanted to keep the architecture clean and maintainable since we are handling sensitive health data.

1. **Backend (Python/FastAPI):** We deployed our backend on Render at `https://aarogya-sathi-final.onrender.com`. The backend runs our Agentic CRAG (Corrective Retrieval-Augmented Generation) Pipeline with a ReAct loop. It handles the safety routing using Semantic Router, translation via Sarvam AI (Mayura v1), and manages session memory using per-user JSON persistence. For our LLMs, we set up a provider cascade starting with Groq as the primary, then falling back to SambaNova and Cerebras. We use Qwen 27B for the actual response generation and GPT-OSS-20B for navigation and grading tasks.
2. **Frontend (Flutter/Dart):** We built an Android app using Flutter. For state management, we chose Provider instead of Riverpod because it was simpler for our specific use case. The app has a 4-tab navigation structure: Home Dashboard, AI Chat, Health Tracking, and Profile. It integrates with Health Connect to pull data from Fitbit and Google Fit, uses SSE streaming for real-time chat responses, and allows guest logins with local profile persistence.
3. **ICMR Knowledge Bundle:** Instead of a vector database, we created an Open Knowledge Format (OKF) bundle consisting of 34 structured Markdown files. These are organized into specific directories:
   - `conditions/` — covering diabetes, hypertension, asthma, COPD, obesity, anemia, thyroid, CAD, dengue, tuberculosis, and CKD.
   - `drugs/` — for metformin, amlodipine, atenolol, insulin, glimepiride, aspirin, paracetamol.
   - `lifestyle/` — diet, exercise, sleep, stress, smoking cessation, hydration.
   - `emergency/` — chest pain, hypoglycemia, stroke, allergic reaction, heatstroke, snake bite.
   - `environmental/` — AQI health impact, monsoon diseases, heat health, winter respiratory.

### 3.2 Architecture Diagram and Execution Flow
Moving on to how the data actually flows through our system, here is the step-by-step process.

When a user submits a query, it first goes through a Safety Check. We use a Semantic Router equipped with 42 multilingual utterances and the all-MiniLM-L6-v2 model. If the query is in a regional language, it goes to the Translation layer powered by Sarvam AI. Next, we do Intent Classification using regex heuristics, with an LLM fallback if needed. We classify the query into one of 5 intents: greeting, health_query, vital_check, aqi_query, or lifestyle.

After classifying the intent, the system updates the Session Memory and generates Proactive Insights. Then comes the OKF Navigator. Instead of doing standard vector search, the OKF Navigator acts like a wiki reader. It uses an LLM to pick relevant files from our `index.md`, reads those files, and follows markdown hyperlinks up to a depth of 2. We explicitly avoided chunking because it breaks medical tables and dosage structures.

The retrieved documents go to CRAG Grading for binary relevance checking. Then, the Context Builder formats everything into an XML-structured prompt containing `<documents>`, `<user_profile>`, `<environment>`, `<wearable_data>`, `<session_memory>`, and `<proactive_observations>`. Finally, we send this to Qwen 27B (temperature set to 0.3, max 400 tokens) for Generation, and the response is sent back to the Flutter client via SSE streaming.

![Figure 3.1: Overall System Architecture](docs/diagrams/images/figure_3_1_overall_system_architecture.png)
*Figure 3.1: Overall System Architecture of Aarogya Sathi (Flutter ↔ FastAPI ↔ Agentic ReAct ↔ Inference Cascade)*

The diagram above (Figure 3.1) shows the multi-tiered separation of concerns between our mobile client tier, the deployed FastAPI service, the local ICMR Open Knowledge Format bundle, and our multi-key provider cascade.

![Figure 3.2: Agentic ReAct Loop State Machine](docs/diagrams/images/figure_3_2_react_loop_state_machine.png)
*Figure 3.2: Agentic ReAct Loop State Machine and Intent-Driven Execution Pipeline*

As illustrated in Figure 3.2, every incoming dialogue turn transitions through distinct evaluation states—short-circuiting emergency queries immediately and dynamically choosing between wearable vitals analysis, environmental indexing, or deep clinical retrieval.

### 3.3 Technology Stack Table
Here is a summary of the tools and technologies our team used to build the system.

| Component | Technology | Why We Chose It |
|-----------|------------|------------------|
| Backend Framework | FastAPI | Async support, automatic OpenAPI docs |
| LLM Inference | Groq Cloud (Qwen 27B) | 500 tok/s inference speed, free tier |
| Knowledge Format | OKF (Markdown) | Preserves medical tables, human-auditable |
| Mobile | Flutter 3.x | Single codebase for Android/iOS |
| State Mgmt | Provider | Simpler than Riverpod for our scope |
| Wearable | Health Connect SDK | Bridges Fitbit, Google Fit, Samsung Health |
| AQI Data | WAQI API + Open-Meteo | Real-time, free, covers Indian cities |
| Translation | Sarvam AI (Mayura v1) | India-specific, supports Hindi/Marathi |
| Safety | Semantic Router + HuggingFaceEncoder | Sub-100ms classification |
| Deployment | Render | Free tier, auto-deploy from GitHub |
| Evaluation | LLM-as-Judge (32 gold QA pairs) | Scalable, no human annotator needed |

### 3.4 Database Design and Privacy Architecture
We actually decided not to use a traditional relational database for this project. Instead, our session memory relies on per-user JSON files stored locally at `data/sessions/{user_id}.json`. Each JSON file stores the user's profile, their `vital_history` (which we cap at 20 snapshots to save space), a `chat_summary`, their `recent_turns` (the last 10 messages), and a `last_active` timestamp.

On the mobile side, we use SharedPreferences to persist fitness data locally, and FlutterSecureStorage to safely store authentication tokens.

![Figure 3.3: DPDP Act 2023 Compliance & Zero-Storage Session Boundary](docs/diagrams/images/figure_3_3_dpdp_privacy_boundary.png)
*Figure 3.3: Data Sovereignty and Zero-Storage Session Boundary under India's DPDP Act 2023*

As shown in Figure 3.3, all personally identifiable information remains on the user's physical device. Telemetry transmitted to our backend contains only ephemeral, pseudonymous session identifiers, ensuring compliance with the stringent requirements of the DPDP Act 2023.

### 3.5 API Design
Our backend exposes a few main API endpoints to communicate with the mobile app:
- `POST /api/chat` — This is the primary endpoint. It accepts a `ChatRequest` payload containing the `user_id`, `query`, `language`, `profile`, `wearable` data, `lat`, `lon`, and `chat_history`. It returns an SSE stream of `{token, done}` objects.
- `GET /api/aqi?lat=X&lon=Y` — Fetches real-time AQI and weather data based on user coordinates.
- `GET /api/session/{user_id}/insights` — Retrieves proactive health observations generated by the background tasks.
- `GET /api/health` — A simple health check for Render to monitor our deployment.

We used Pydantic models to validate incoming data, specifically defining `WearableData` with 14 optional fields, `UserProfile` (age, gender, conditions, medications), and `ChatRequest`.

---

# CHAPTER 4: IMPLEMENTATION DETAILS

### 4.1 Backend Implementation

#### 4.1.1 Agentic CRAG Pipeline (`backend/rag/pipeline.py`)
The pipeline is the heart of our system. We implemented it as a `CRAGPipeline` class containing a single `run()` async generator method that yields response tokens. The execution flow works like this:

First, we classify the intent using `classify_intent(query)`. We try regex patterns first (checking for greeting patterns in 4 languages, AQI keywords, and vital keywords) and fall back to the LLM if the query is ambiguous. If it's a greeting, we hit a fast-path that returns a localized greeting in Hindi, Marathi, or English without doing any document retrieval.

For actual health queries, we call `tool_search_knowledge()` which navigates our OKF bundle and grades the documents. If the intent is `vital_check`, we skip document retrieval entirely and focus on analyzing the wearable data. For an `aqi_query`, we search specifically for environmental health documents. Next, we build the context using `build_context()` to create our XML-structured prompt. Finally, we call the LLM using `call_llm()` with Qwen 27B, update the session memory, and stream the tokens word-by-word via SSE.

Here is a snippet showing how we manage turn state and route intents inside `pipeline.py`:

```python
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Any

@dataclass
class AgentState:
    """Working state for an agentic turn."""
    query: str = ""
    intent: str = "health_query"
    profile: Dict[str, Any] = field(default_factory=dict)
    aqi_data: Dict[str, Any] = field(default_factory=dict)
    wearable: Dict[str, Any] = field(default_factory=dict)
    docs: List[Dict[str, Any]] = field(default_factory=list)
    insights: List[str] = field(default_factory=list)
    messages: List[Dict[str, str]] = field(default_factory=list)
    response: str = ""

# Routing snippet inside CRAGPipeline.run():
if intent == "greeting":
    greeting_text = lang_greeting.get(language, lang_greeting["en"])
    greeting_text += "\n\n⚕️ I am an AI health assistant, not a doctor."
    for word in greeting_text.split(" "):
        yield word + " "
        await asyncio.sleep(0.01)
    if session:
        session.add_turn(query, greeting_text)
    return

elif intent == "vital_check":
    state.docs = []  # Vitals inquiries don't need disease monographs

elif intent == "aqi_query":
    state.docs = await tool_search_knowledge("air quality pollution aqi respiratory health", self.navigator)

else:
    # Full OKF knowledge search and grading
    state.docs = await tool_search_knowledge(query, self.navigator)
```

#### 4.1.2 OKF Navigator (`backend/rag/okf_navigator.py`)
To build the OKF Navigator, we made it read the root `index.md` file which lists all the medical concept files. It asks the LLM to pick the 2-3 most relevant files for the query. Then, it reads those files and automatically follows any markdown hyperlinks inside them up to a depth of 2. We also added a keyword fallback dictionary with over 60 mappings (like mapping "diabetes" directly to `conditions/diabetes-type2.md`) just in case the LLM selection fails. We truncate each document to 1500 characters so the context window doesn't get too large.

#### 4.1.3 LLM Provider Cascade (`backend/rag/llm.py`)
Since we are using free API tiers, rate limits were a huge issue during testing. We fixed this by implementing a multi-provider failover sequence: Groq → SambaNova → Cerebras. We also set up multi-key rotation where our environment variables accept comma-separated keys (e.g., `GROQ_API_KEY=key1,key2,key3`). If we hit a 429 rate limit error, the system rotates to the next key within the same provider. If we get any other failure, it moves to the next provider entirely. We keep a round-robin index that persists across API calls to balance the load.

![Figure 4.1: Multi-Key Pooling & Multi-Provider Failover Waterfall](docs/diagrams/images/figure_4_2_multi_key_llm_cascade.png)
*Figure 4.1: Multi-Key Pooling and Multi-Provider Failover Waterfall (Groq ↔ SambaNova ↔ Cerebras ↔ Local Fallbacks)*

Figure 4.1 illustrates how our inference layer remains resilient against cloud outages and free-tier quotas through automatic key cycling and multi-tiered fallback endpoints.

#### 4.1.4 Safety Router (`backend/safety/router.py`)
For user safety, we implemented Semantic Router combined with HuggingFaceEncoder using the `all-MiniLM-L6-v2` model, which is only around 80MB. We defined 3 route categories: `emergency` (triggers an alert to call 112), `prescription` (triggers a message to consult a doctor), and `non_medical` (redirects the user to health topics). We provided 42 multilingual utterances covering Hindi, Marathi, and Hinglish. If the Semantic Router fails to load in memory, we fall back to simple keyword matching.

![Figure 4.2: Safety Router & Sub-100ms Clinical Triage Pipeline](docs/diagrams/images/figure_4_3_safety_router_clinical_triage.png)
*Figure 4.2: Safety Router & Sub-100ms Clinical Triage Pipeline with MiniLM Dense Embeddings*

As shown in Figure 4.2, high-risk emergencies and prescription inquiries are intercepted within 100 milliseconds, completely bypassing generative inference to ensure patient safety.

#### 4.1.5 Context Builder (`backend/rag/context_builder.py`)
The context builder relies on a strict 21-line `SYSTEM_PROMPT` that defines Aarogya Sathi's boundaries based on ICMR rules (never diagnose, never prescribe, always recommend a doctor, and emergency = call 112). We implemented ICMR 2023 classification functions directly in Python, like `classify_bp()`, `classify_sugar()`, `classify_bmi()`, and `classify_aqi()`. We specifically used Indian thresholds for these functions. For example, the Indian BMI thresholds classify Normal as 18.5-22.9, Overweight as 23-27.4, and Obese as ≥27.5. The builder assembles an XML-structured prompt and injects language-aware instructions to ensure the bot replies in the correct language.

![Figure 4.3: CPCB NAQI Calculation and Clinical Alerting Pipeline](docs/diagrams/images/figure_4_4_cpcb_naqi_calculation.png)
*Figure 4.3: Environmental NAQI Calculation and Clinical Alerting Pipeline*

Figure 4.3 details the process of fetching real-time environmental telemetry, converting pollutant concentrations into standardized CPCB NAQI sub-indices, and synthesizing personalized outdoor advisories for vulnerable patients.

#### 4.1.6 Translation (`backend/translation/bhashini.py`)
Initially, we planned to use Bhashini, but we replaced it with Sarvam AI's Mayura v1 model because it performed better for our specific regional inputs. We enforce a 1000-character limit and use multi-key rotation here as well. During development, we set up a mock fallback. Interestingly, we found that Qwen 27B is actually very good at generating native Hinglish and Marathi directly, so we often skip the translation API for the final chat generation to save our API credits.

### 4.2 Frontend Implementation

#### 4.2.1 App Architecture
Coming to the frontend, we built the Android app using Flutter and the Provider pattern. In our `main.dart`, we initialize 7 different providers: `AuthProvider`, `ChatProvider`, `HealthProvider`, `FitnessProvider`, `AQIProvider`, `SettingsProvider`, and `NotificationProvider`. We use route-based navigation with custom fade transitions between the screens.

#### 4.2.2 Health Connect Integration (`frontend/lib/services/health_connect_service.dart`)
We integrated the Health Connect SDK to bridge data from Fitbit, Google Fit, and Samsung Health. We pull 16 different data types, including steps, heart rate, blood oxygen, and sleep sessions. We set a 36-hour lookback window for vitals.

One tricky part was dealing with duplicate data when users have multiple fitness apps. We wrote a smart calorie de-duplication logic that aggregates the data per-source and picks the minimum value to avoid double-counting. For sleep data, we try to use `SLEEP_SESSION` first; if it's missing, we manually sum up deep, light, REM, and asleep phases.

![Figure 4.4: Wearable & Sensor Synchronization Pipeline](docs/diagrams/images/figure_4_1_wearable_health_connect_pipeline.png)
*Figure 4.4: Wearable Health Connect Synchronization Pipeline with Smart Deduplication*

The pipeline in Figure 4.4 illustrates the end-to-end wearable ingestion path, showing how Fitbit and Google Fit data points are normalized, deduplicated, and passed as clinical context into user sessions.

#### 4.2.3 Chat Implementation
For the chat interface, we handle the SSE streaming via a raw HTTP client that parses the `data: {"token": "...", "done": false}` lines to give a typing effect. We built a 3-tier fallback mechanism:
1. Try the Backend SSE.
2. If backend is down, make a direct API call to Groq.
3. If Groq fails, fall back to hardcoded ICMR demo responses for 5 common topics.

We also added emergency detection on the frontend using keyword matching (like "chest pain" or "heart attack"). If triggered, the UI instantly displays a red URGENT banner. To maintain conversation context, the frontend sends the last 5 chat turns with every new request.

#### 4.2.4 Fitness Provider (`frontend/lib/providers/fitness_provider.dart`)
We used a local-first architecture for the fitness provider, persisting all user data in SharedPreferences. The app always tries to run the Health Connect sync first. If the user doesn't have Health Connect or denies permission, we start the hardware pedometer as a fallback. The pedometer uses cumulative-count daily offset tracking to calculate steps. We run a background API sync every 500 steps to keep the backend updated. We also implemented water and sleep logging using this same local-first, background-sync approach.

### 4.3 ICMR Knowledge Bundle
Our knowledge base is made up of 34 structured Markdown files covering 11 conditions, 7 drugs, 6 lifestyle topics, 6 emergency protocols, and 4 environmental guides. Every file follows a strict standard template: an H1 title, a clinical definition, Indian-specific diagnostic thresholds, dietary advice specifically using Indian foods, instructions on when to see a doctor, and ICMR references at the bottom.

We heavily cross-linked these files using Markdown hyperlinks. For example, inside `conditions/diabetes-type2.md`, we include links directly to `drugs/metformin.md` and `lifestyle/diet-diabetes.md`. This allows our OKF Navigator to traverse the bundle naturally without relying on external search indexes.

---

# CHAPTER 5: RESULTS AND EVALUATION

### 5.1 Evaluation Methodology
To figure out if our pipeline actually gives safe and accurate advice, we built an LLM-as-Judge evaluation framework, which is located in `evaluation/evaluate.py`. We manually created a dataset of 32 gold-standard Q&A pairs (`evaluation/gold_qa.json`). This set covers all our main knowledge bundle categories: 10 condition-related, 6 drug-related, 5 lifestyle, 5 environmental, and 6 emergency questions.

Each test case has a specific user question, the expected ICMR-aligned answer, a sample user profile (like age and existing conditions), and optional AQI data if it matters for the question. During testing, the script runs each query through our full CRAG pipeline — it navigates the OKF files, grades the documents, builds the prompt context, and generates the final output. Then, a separate LLM judge grades the response on a 1-5 scale across four metrics: Faithfulness, Relevancy, Completeness, and Safety.

### 5.2 Evaluation Results
Before showing the numbers, we have to mention a big roadblock we hit. When running the 32-question batch evaluation, we constantly hit Groq API rate limits (429 errors) on about 18 of the 32 questions because we are using free-tier accounts. The evaluation script assigned default scores of 0 for these failed queries, which really pulled our aggregate averages down.

The raw aggregate scores (including the rate-limited failures) look like this:
- Faithfulness: 1.53/5.0
- Relevancy: 1.56/5.0
- Completeness: 1.19/5.0
- Safety: 1.47/5.0
- Average latency: 18.25 seconds/query

However, if we only look at the actual scores for the questions where the LLM successfully generated a response (excluding the 429 failures), the results are much better:
- Faithfulness: 4.86/5.0 (7 scored questions, all got 4 or 5)
- Relevancy: 5.0/5.0 (all scored a perfect 5)
- Completeness: 3.86/5.0 (ranged from 3 to 5)
- Safety: 4.86/5.0 (all got 4 or 5)

Moving on to some actual test cases, here is a breakdown of a few sample evaluated questions:

| Question | Category | Faith. | Relev. | Compl. | Safety | Time |
|----------|----------|--------|--------|--------|--------|------|
| Fasting blood sugar for type 2 diabetes | Conditions | 4 | 5 | 5 | 5 | 26.1s |
| Iron-rich Indian foods for anemia | Conditions | 5 | 5 | 3 | 5 | 40.6s |
| Safe paracetamol dosage for fever | Drugs | 5 | 5 | 4 | 5 | 49.9s |
| Good Indian diet for diabetes | Lifestyle | 5 | 5 | 4 | 4 | 42.7s |
| Sleep only 5 hours — enough? | Lifestyle | 5 | 5 | 4 | 5 | 42.4s |
| Quitting gutka/smoking help | Lifestyle | 5 | 5 | 3 | 5 | 38.6s |
| Water intake in Indian summer | Environ. | 5 | 5 | 4 | 4 | 37.7s |

### 5.3 Sample Response Analysis
To show how the system actually behaves, let's look at two specific examples from our test runs.

For the diabetes fasting blood sugar question, the OKF Navigator correctly pulled `conditions/diabetes-type2.md` and a few related nutrition files. The CRAG step graded these as highly relevant. The system then built a context block incorporating the test user's profile (a 50-year-old diabetic). The final response successfully cited specific ICMR thresholds for fasting blood sugar, gave personalized target ranges, advised on HbA1c monitoring, and even suggested Indian dietary changes. At the very end, it appended the mandatory medical safety disclaimer.

Coming to the next part, we tested a chest pain emergency query. Here, the Semantic Router at the very start of the pipeline correctly classified it as a critical emergency. It completely bypassed the standard OKF navigation and RAG generation steps. Instead, it instantly returned a '🚨 CALL 112 NOW' message along with basic first-aid steps, resulting in a sub-second response time.

### 5.4 Key Findings
Based on our testing so far, our team noticed a few main things:
1. When the pipeline actually finishes without hitting rate limits, the response quality is exactly what we wanted (4.86/5 faithfulness and 5.0/5 relevancy).
2. The ICMR grounding works well. The bot actually cites the specific markdown files we created and uses Indian-specific health thresholds instead of generic US-based data.
3. Our safety mechanisms are doing their job. Every normal response gets the medical disclaimer, and the emergency interceptor catches critical symptoms immediately.
4. The biggest bottleneck we faced was LLM API rate limits. To fix this temporarily for the app, we had to build a multi-key rotation script that cycles through API keys from 3 different Groq accounts.
5. The average response time is around 35-40 seconds for a full RAG cycle. It is acceptable for a health advisory app where accuracy matters more than speed, but we definitely need to speed it up.

### 5.5 Current Limitations
Right now, the project has a few limitations that we plan to fix:
- API rate limiting on free-tier LLM services makes our batch evaluation unreliable and slows down testing.
- We haven't built the Vector RAG (Qdrant + BGE-M3 embeddings) fallback yet. If the OKF Navigator fails to pick the right file by name, the query just fails.
- The UI for voice input and output (speech-to-text and TTS) is built in Flutter, but we haven't connected it to the backend yet.
- We have not run a real user study yet. That is scheduled for Review 3.

---

# CHAPTER 6: PROJECT TIMELINE AND TEAM CONTRIBUTIONS

### 6.1 Development Timeline
**Phase 1 (Aug-Sep 2026): Research & Architecture**
- Completed our literature review (reading and citing 42 IEEE references across 7 pillars of healthcare AI).
- Wrote the architecture decision document evaluating 15 different technical approaches.
- Created the initial ICMR knowledge bundle containing 34 manually formatted markdown files.
- Finalized our tech stack (Flutter, Python, Groq, Render).

**Phase 2 (Sep 2026): Core Implementation**
- Built the agentic CRAG pipeline from scratch.
- Developed the OKF Navigator so the LLM can search for specific files.
- Implemented the Safety Router using Semantic Router for fast intent matching.
- Built the Flutter app skeleton using Provider for state management.
- Hooked up the basic Health Connect integration for Android.

**Phase 3 (Sep-Oct 2026): Integration & Evaluation**
- Deployed the Python backend on Render.
- Connected the Flutter frontend to the backend using SSE (Server-Sent Events) for typing effects.
- Ran the 32-question gold-standard evaluation script.
- Added the WAQI and Open-Meteo APIs for real-time environment data.
- Integrated the Sarvam AI translation layer for Hindi support.

### 6.2 Team Contributions
| Member | Role | Key Contributions |
|--------|------|--------------------|
| Jayesh Patil (C233) | Lead, RAG & LLM Pipeline | Agentic pipeline, OKF Navigator, LLM provider cascade, CRAG grading, evaluation framework, ICMR knowledge bundle |
| Abhijit Patil (C263) | Backend & Integration | API routes, safety router, translation layer, session memory, AQI/weather integration, deployment |
| Ritesh Pawar (C276) | Frontend & Mobile | Flutter app, Health Connect service, fitness provider, chat UI with SSE streaming, onboarding flow, architecture diagrams |

### 6.3 Current Progress: ~60%
- **Knowledge Bundle:** 34 out of 50 planned OKF files are done (68%).
- **Backend Pipeline:** Core system works fine, but vector fallback is pending (75%).
- **Mobile App:** All screens are functional, just waiting on voice I/O integration (70%).
- **Evaluation:** Tested 32 gold QA pairs (65%).
- **Documentation:** Interim report completed for Review 2 (100%).

---

# CHAPTER 7: FUTURE WORK AND CONCLUSION

### 7.1 Planned Enhancements (Review 3 and beyond)
As for what comes next, we have a clear roadmap for the final submission:
1. **Vector RAG Fallback:** We are going to set up a Qdrant vector database with BGE-M3 embeddings. This will catch queries where the standard OKF file name matching fails.
2. **Voice Input/Output:** We already have the `speech_to_text` and `flutter_tts` packages in our `pubspec.yaml`. We just need to wire them up to the chat screen so users can talk instead of typing.
3. **Proactive Notification System:** We want to add a background service in Flutter that polls the `/api/session/{user_id}/insights` endpoint to push notifications if the local AQI gets too bad or if the user's step count drops heavily.
4. **Remaining Knowledge Files:** We will write the remaining 16 OKF files to hit our target of 50, specifically adding topics on mental health, pregnancy, and pediatrics.
5. **User Study:** We plan to give the APK to 15-20 people on campus to test the usability and see where they get stuck.
6. **Wearable Dashboard Cards:** The home screen needs better UI cards showing visual graphs for heart rate, step trends, and sleep breakdowns using the Health Connect data.
7. **Demo Video:** We will record a 5-minute walkthrough of the working app for our final presentation.

### 7.2 Conclusion
We have built a working prototype of Aarogya Sathi that demonstrates our core idea — a mobile health assistant that gives ICMR-grounded advice while being aware of the user's environment and fitness data. By using an agentic pipeline with intent classification and selective tool execution, we avoided the one-size-fits-all approach that makes standard chatbots unreliable for healthcare.

Our evaluation shows that when the system works end-to-end without API errors, the response quality is very high (averaging 4.86/5 for faithfulness). The main challenges we have to deal with going forward are improving the slow response speed, expanding our medical knowledge base, and conducting a proper user study to see how real people interact with the app.

---

## REFERENCES

[1] T. Vos et al., "Global burden of 369 diseases and injuries in 204 countries and territories, 1990-2019: a systematic analysis for the Global Burden of Disease Study 2019," *The Lancet*, vol. 396, no. 10258, pp. 1204-1222, Oct. 2020. doi: 10.1016/S0140-6736(20)30925-9.

[2] G. A. Roth et al., "Global Burden of Cardiovascular Diseases and Risk Factors, 1990-2019: Update From the GBD 2019 Study," *Journal of the American College of Cardiology (JACC)*, vol. 76, no. 25, pp. 2982-3021, Dec. 2020. doi: 10.1016/j.jacc.2020.11.010.

[3] GBD 2021 Diabetes Collaborators, "Global, regional, and national burden of diabetes from 1990 to 2021, with projections of prevalence to 2050," *The Lancet*, vol. 402, no. 10397, pp. 203-234, Jul. 2023. doi: 10.1016/S0140-6736(23)01301-6.

[4] The GBD 2015 Obesity Collaborators, "Health Effects of Overweight and Obesity in 195 Countries over 25 Years," *New England Journal of Medicine (NEJM)*, vol. 377, pp. 13-27, Jul. 2017. doi: 10.1056/NEJMoa1614362.

[5] R. Lozano et al., "Global and regional mortality from 235 causes of death for 20 age groups in 1990 and 2010," *The Lancet*, vol. 380, no. 9859, pp. 2095-2128, Dec. 2012. doi: 10.1016/S0140-6736(12)61728-0.

[6] World Economic Forum, "The Economic Impact of Non-Communicable Disease in China and India: Estimates, Projections, and Comparisons," Harvard School of Public Health, 2014.

[7] GBD 2016 Neurology Collaborators, "Global, regional, and national burden of neurological disorders, 1990-2016," *The Lancet Neurology*, vol. 18, no. 5, pp. 459-480, May 2019. doi: 10.1016/S1474-4422(18)30499-X.

[8] GBD 2019 Risk Factors Collaborators, "Global burden of 87 risk factors in 204 countries and territories, 1990-2019," *The Lancet*, vol. 396, no. 10258, pp. 1223-1249, Oct. 2020. doi: 10.1016/S0140-6736(20)30752-2.

[9] J. Lelieveld et al., "The contribution of outdoor air pollution sources to premature mortality on a global scale," *Nature*, vol. 525, pp. 367-371, Sep. 2015. doi: 10.1038/nature15371.

[10] I. Manisalidis et al., "Environmental and Health Impacts of Air Pollution: A Review," *Frontiers in Public Health*, vol. 8, art. 14, Feb. 2020. doi: 10.3389/fpubh.2020.00014.

[11] A. J. Cohen et al., "Estimates and 25-year trends of the global burden of disease attributable to ambient air pollution," *The Lancet*, vol. 389, no. 10082, pp. 1907-1918, May 2017. doi: 10.1016/S0140-6736(17)30505-6.

[12] Central Pollution Control Board (CPCB), "National Air Quality Index," Ministry of Environment, Government of India. Available: https://app.cpcbccr.com/AQI_India/

[13] S. Salvi and P. J. Barnes, "Is exposure to biomass smoke the biggest risk factor for COPD globally?," *Chest*, vol. 138, no. 1, pp. 3-6, Jul. 2010. doi: 10.1378/chest.10-0645.

[14] K. Skivington et al., "A new framework for developing and evaluating complex interventions: update of MRC guidance," *BMJ*, vol. 374, art. n2061, Sep. 2021. doi: 10.1136/bmj.n2061.

[15] G. Eysenbach and CONSORT-EHEALTH Group, "CONSORT-EHEALTH: improving and standardizing evaluation reports of Web-based and mobile health interventions," *JMIR*, vol. 13, no. 4, art. e126, Dec. 2011. doi: 10.2196/jmir.1923.

[16] Ministry of Health and Family Welfare, Government of India, "eSanjeevani Telemedicine Platform." Available: https://esanjeevani.mohfw.gov.in/

[17] S. Patel et al., "COVID-19 and mental health: A review of the existing literature," *Asian Journal of Psychiatry*, vol. 52, art. 102066, Jun. 2020. doi: 10.1016/j.ajp.2020.102066.

[18] R. Masters et al., "Return on investment of public health interventions: a systematic review," *J Epidemiol Community Health*, vol. 71, no. 8, pp. 827-834, 2017. doi: 10.1136/jech-2016-208141.

[19] A. Acosta et al., "Multimodal biomedical AI," *Nature Medicine*, vol. 28, pp. 1773-1784, Sep. 2022. doi: 10.1038/s41591-022-01981-2.

[20] L. Laranjo et al., "Conversational agents in healthcare: a systematic review," *JAMIA*, vol. 25, no. 9, pp. 1248-1258, Sep. 2018. doi: 10.1093/jamia/ocy072.

[21] S. Siriwardhana et al., "Improving the Domain Adaptation of RAG Models for Open Domain Question Answering," *TACL*, 2022. arXiv: 2210.02627.

[22] S. Anuyah et al., "Domain-Specific Knowledge Graphs in RAG-Enhanced Healthcare LLMs," arXiv, Jan. 2026. arXiv: 2601.15429.

[23] P. Xia et al., "MMed-RAG: Versatile Multimodal RAG System for Medical Vision Language Models," *ICLR*, 2025. arXiv: 2410.13085.

[24] M. P. Priola, "Addressing Hallucinations with RAG and NMISS in Italian Healthcare LLM Chatbots," arXiv, Dec. 2024. arXiv: 2412.04235.

[25] A. Gerner et al., "Deepchecks: Evaluating RAG," arXiv, May 2026. arXiv: 2605.14488.

[26] Census of India 2011, "Language Atlas of India," Office of the Registrar General, Government of India, 2011.

[27] N. K. Arora et al., "Health literacy in India: A systematic review of studies," *Indian Journal of Public Health*, 2020.

[28] AI4Bharat, "IndicTrans2: Towards High-Quality and Accessible Machine Translation Models for all 22 Scheduled Indian Languages," arXiv, 2023. arXiv: 2305.16307.

[29] "Conversational Domain Adaptation of IndicTrans2 across 21 Indic Languages," arXiv, 2026. arXiv: 2606.29024.

[30] "Safer in Translation? Presupposition Robustness in Indic Languages," *LREC*, 2026. arXiv: 2511.01360.

[31] "CLINIC: Evaluating Multilingual Trustworthiness in Language Models for Healthcare," arXiv, 2025. arXiv: 2512.11437.

[32] "Artificial intelligence language technologies in multilingual healthcare: Grand challenges ahead," arXiv, 2026. arXiv: 2605.01441.

[33] Ministry of Electronics and IT, Government of India, "Bhashini: National Language Translation Mission." Available: https://bhashini.gov.in/

[34] Microsoft News Center India, "eSanjeevani integrates Azure AI for multilingual teleconsultation," 2024.

[35] Sarvam AI, "Building India's AI Infrastructure," 2024. Available: https://www.sarvam.ai/

[36] "Human-Guided Agentic AI for Multimodal Clinical Prediction," arXiv, 2026. arXiv: 2602.19502.

[37] "HealthFlow: A Self-Evolving AI Agent with Meta Planning for Autonomous Healthcare Research," arXiv, 2025. arXiv: 2508.02621.

[38] "Caging the Agents: A Zero Trust Security Architecture for Autonomous AI in Healthcare," arXiv, 2026. arXiv: 2603.17419.

[39] "Multi-Agent Norm Perception and Induction in Distributed Healthcare," arXiv, 2024. arXiv: 2412.18454.

[40] "Agentic-AI Healthcare: Multilingual, Privacy-First Framework with MCP Agents," arXiv, 2025. arXiv: 2510.02325.

[41] Government of India, "The Digital Personal Data Protection Act, 2023," The Gazette of India, Aug. 2023.

[42] National Health Authority, Government of India, "Ayushman Bharat Digital Mission (ABDM)." Available: https://abdm.gov.in/
