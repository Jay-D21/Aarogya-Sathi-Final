# Aarogya Sathi — System Architecture Diagrams

This document contains the complete set of 7 capstone architecture diagrams for the **Aarogya Sathi** platform. Each diagram is rendered in standard Mermaid syntax and accurately reflects the production implementation across `frontend/`, `backend/`, and `icmr-knowledge-bundle/`.

---

## Diagram 1: Overall System Architecture

High-level architecture showing the Flutter client, FastAPI backend on Render, RAG components, knowledge retrieval, and LLM inference cascade.

```mermaid
flowchart TD
    subgraph ClientTier["Client Tier (Android / Flutter 3.x)"]
        UI["UI Screens<br/>(Home, Chat, Health, Profile)"]
        Providers["State Management (Provider)<br/>AuthProvider, ChatProvider, FitnessProvider"]
        HCS["HealthConnectService<br/>(Fitbit, Google Fit)"]
        Pedo["Hardware Pedometer<br/>(Sensor Stream Fallback)"]
        Loc["LocationService<br/>(GPS + Geocoding)"]
        LocalStore["Local Storage<br/>(SharedPreferences + SecureStorage)"]
    end

    subgraph APITier["API Tier (FastAPI on Render)"]
        Routes["API Endpoints<br/>POST /api/chat (SSE)<br/>GET /api/aqi<br/>GET /api/session/{id}/insights"]
        CORS["CORS & Auth Middleware"]
    end

    subgraph SafetyTier["Safety & Triage Tier"]
        SR["Semantic Router<br/>(sentence-transformers/all-MiniLM-L6-v2)"]
        SRUtter["42 Multilingual Utterances<br/>(Hindi, Marathi, English)"]
        KeyFallback["Regex / Keyword Safety Fallback"]
        Emerg["Emergency Interception<br/>(🚨 Instant 112 / 102 Advisory)"]
    end

    subgraph PipelineTier["Agentic CRAG Pipeline (Python)"]
        Intent["Intent Classifier<br/>(greeting, health_query, vital_check, aqi_query, lifestyle)"]
        Memory["Session Memory Manager<br/>(data/sessions/{user_id}.json)"]
        Insights["Proactive Insights Engine<br/>(Vital thresholds + AQI alerts)"]
        Tools["Agentic Tools<br/>(tool_search_knowledge, tool_analyze_vitals, tool_get_env)"]
        ContextBuild["Context Builder<br/>(XML Schema: docs, profile, env, vitals)"]
    end

    subgraph KnowledgeTier["ICMR Knowledge Tier (OKF)"]
        OKFNav["OKF Navigator<br/>(Wiki-style Hyperlink Graph)"]
        Bundle["34 Structured Concept Files<br/>conditions/, drugs/, lifestyle/, emergency/, environmental/"]
        Grader["CRAG Relevance Grader<br/>(Binary Relevance Filter)"]
    end

    subgraph ExternalServices["External APIs & Foundation Models"]
        WAQI["WAQI & Open-Meteo APIs<br/>(Real-time AQI & Weather)"]
        Sarvam["Sarvam AI (Mayura v1)<br/>(Indic Translation)"]
        Groq["Groq Cloud LPU<br/>qwen/qwen3.8-27b (Chat)<br/>openai/gpt-oss-20b (Grading)"]
        Samba["SambaNova Cloud<br/>(Meta-Llama-3.3-70B)"]
        Cerebras["Cerebras Cloud<br/>(llama-3.3-70b)"]
    end

    %% Flow connections
    UI --> Providers
    Providers --> HCS
    Providers --> Pedo
    Providers --> Loc
    Providers --> LocalStore
    Providers --"POST /api/chat (JSON Payload)"--> Routes

    Routes --> CORS
    CORS --> SR
    SR -.-> SRUtter
    SR --"Emergency"--> Emerg
    Emerg --"Instant SSE"--> UI
    SR --"Safe Query"--> Intent
    SR -.-> KeyFallback

    Intent --> Memory
    Intent --> Insights
    Insights --> Tools
    Tools --> OKFNav
    OKFNav <--> Bundle
    OKFNav --> Grader
    Grader --> ContextBuild

    Routes <--> WAQI
    ContextBuild <--> Sarvam
    ContextBuild --"OpenAI Messages Payload"--> Groq
    Groq -.->|"429 Rate Limit"| Samba
    Samba -.->|"Fallback"| Cerebras
    Groq --"Word-by-word SSE Stream"--> Routes
    Routes --"EventSource Stream"--> UI
```

---

## Diagram 2: Agentic ReAct Loop State Machine

Represents the state transitions during a single turn of the `CRAGPipeline.run()` execution flow.

```mermaid
stateDiagram-v2
    [*] --> Idle: User Enters Query

    Idle --> SafetyEvaluation: POST /api/chat received
    
    state SafetyEvaluation {
        [*] --> SemanticRouterCheck
        SemanticRouterCheck --> EmergencyTrigger: Cosine sim >= threshold
        SemanticRouterCheck --> SafeQuery: No violation
        EmergencyTrigger --> FastEmergencyResponse: Bypass RAG
    }

    FastEmergencyResponse --> [*]: Return 112 Emergency Banner

    SafeQuery --> IntentClassification: Fast Heuristics / LLM
    
    state IntentClassification {
        [*] --> CheckRegexRules
        CheckRegexRules --> GreetingIntent: Match 'hi', 'namaste', etc.
        CheckRegexRules --> VitalIntent: Match 'my bp', 'sugar', etc.
        CheckRegexRules --> AQIIntent: Match 'aqi', 'pollution', etc.
        CheckRegexRules --> AmbiguousQuery: No pattern match
        AmbiguousQuery --> LLMIntentFallback: Single-token 70B prompt
        LLMIntentFallback --> HealthQueryIntent: Clinical / Symptom query
    }

    GreetingIntent --> StreamGreeting: Localized greeting (Hi/Mr/En)
    StreamGreeting --> UpdateMemory

    VitalIntent --> ExecuteVitalAnalysis: tool_analyze_vitals()
    AQIIntent --> ExecuteEnvironmentalSearch: tool_search_knowledge(AQI)
    HealthQueryIntent --> ExecuteOKFSearch: tool_search_knowledge(Clinical)

    state ExecuteOKFSearch {
        [*] --> ReadRootIndex
        ReadRootIndex --> LLMFilePick: Select 2-3 concept files
        LLMFilePick --> TraverseLinks: Follow Markdown Links (depth <= 2)
        TraverseLinks --> CRAGDocumentGrading: Yes/No relevance check
    }

    ExecuteVitalAnalysis --> SynthesizeObservations
    ExecuteEnvironmentalSearch --> SynthesizeObservations
    CRAGDocumentGrading --> SynthesizeObservations

    state SynthesizeObservations {
        [*] --> CheckICMRThresholds: BP, Sugar, BMI ranges
        CheckICMRThresholds --> CheckEnvironmentalAdvisory: AQI > 200 alert
        CheckEnvironmentalAdvisory --> CheckLongitudinalDelta: Vital shift vs prior session
    }

    SynthesizeObservations --> AssemblePromptContext: build_context()
    AssemblePromptContext --> LLMGeneration: call_llm(size='70b', temp=0.3)
    LLMGeneration --> StreamTokens: SSE Word-by-Word Chunks
    StreamTokens --> UpdateMemory: session.add_turn()
    UpdateMemory --> DiskPersistence: session_manager.save_session()
    DiskPersistence --> [*]: End of Turn
```

---

## Diagram 3: DPDP Act 2023 Compliance & Privacy Boundary

Illustrates the zero-storage session architecture, on-device data sovereignty, and compliance boundaries under the Digital Personal Data Protection Act (DPDP Act, 2023).

```mermaid
flowchart LR
    subgraph DeviceBoundary["User Device (Data Principal Control Boundary)"]
        UI_Dev["Flutter Mobile Client"]
        Local_DB["On-Device Local Storage<br/>- Encrypted Tokens (FlutterSecureStorage)<br/>- Daily Step Counter (SharedPreferences)<br/>- Water & Sleep Logs"]
        Sensors["Device Biometrics<br/>- Hardware Step Sensor<br/>- GPS Coordinates<br/>- Health Connect Records"]
        Consent["Informed Consent Engine<br/>- Explicit opt-in per sensor<br/>- Granular data permission switches"]
    end

    subgraph TransitLayer["Secure Ephemeral Transit Layer"]
        TLS["HTTPS / TLS 1.3 Encryption<br/>No Intermediate Caching"]
    end

    subgraph CloudBoundary["Aarogya Sathi Backend (Data Fiduciary Boundary)"]
        API_Route["FastAPI Ingestion Endpoint"]
        MemSession["Ephemeral Session State<br/>(In-Memory UserSession)"]
        DiskSession["Local JSON Session Store<br/>(data/sessions/{user_id}.json)<br/>- Pseudonymous UUID Only<br/>- No Name, Phone, or Aadhaar<br/>- Capped to 20 Vital Snapshots<br/>- Auto-rotation / Session Reset"]
    end

    subgraph ExternalLLMBoundary["Stateless Inference Boundary"]
        LLM_Cloud["Groq Cloud / SambaNova<br/>- Zero Data Retention Policy<br/>- No Training on Health Payloads<br/>- Context Cleared Immediately"]
    end

    %% Relationships
    Sensors --> Consent
    Consent --> Local_DB
    Local_DB <--> UI_Dev
    UI_Dev --"Anonymized Query + Ephemeral Vitals"--> TLS
    TLS --> API_Route
    API_Route --> MemSession
    MemSession <--> DiskSession
    API_Route --"Redacted Prompt (No PII)"--> LLM_Cloud
    LLM_Cloud --"Generated Tokens"--> API_Route
    API_Route --"SSE Response"--> TLS
    TLS --"Decrypted On-Device"--> UI_Dev

    %% Styling Boundaries
    style DeviceBoundary fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px
    style CloudBoundary fill:#E3F2FD,stroke:#1565C0,stroke-width:2px
    style ExternalLLMBoundary fill:#FFF3E0,stroke:#E65100,stroke-width:2px
```

---

## Diagram 4: Wearable & Sensor Synchronization Pipeline

Details how wearable metrics from Fitbit, Google Fit, and Samsung Health flow through Android Health Connect into the Flutter app, featuring smart deduplication and pedometer fallback.

```mermaid
flowchart TD
    subgraph WearableSources["Wearable Hardware & Ecosystems"]
        Fitbit["Fitbit Tracker / Smartwatch"]
        GoogleFit["Google Fit Ecosystem"]
        Samsung["Samsung Health"]
        PhoneSensor["Phone Accelerometer / Step Counter"]
    end

    subgraph AndroidOS["Android OS Subsystem"]
        HC_SDK["Android Health Connect SDK<br/>(androidx.health.connect.client)"]
        Perms["User Permission Sheet<br/>(16 Health Data Types)"]
    end

    subgraph FlutterApp["Flutter Application (`HealthConnectService` & `FitnessProvider`)"]
        Init["App Startup / HomeScreen Init"]
        AuthCheck["hasPermissions() Check"]
        Fetch["fetchTodayData()<br/>36-Hour Lookback Window"]
        
        subgraph AggregationLogic["Smart Aggregation & Deduplication"]
            StepQuery["Query Steps: getTotalStepsInInterval()<br/>Fallback: Deduped Step Points"]
            CalQuery["Query Calories: ACTIVE + TOTAL<br/>Group by SourceName → Pick Minimum (Google Fit Authoritative)"]
            VitalQuery["Query Vitals: Latest HR, Resting HR, SpO2,<br/>Systolic/Diastolic BP, Glucose, Temp"]
            SleepQuery["Query Sleep: SLEEP_SESSION or<br/>Sum(Deep + Light + REM + Asleep)"]
        end

        Model["Construct WearableDataModel"]
        AuthoritativeSync["Set _isHealthConnectSynced = true<br/>Persist to SharedPreferences"]
        PedoFallback["Hardware Pedometer Fallback<br/>(Cumulative Offset Tracking)"]
    end

    subgraph BackendSync["Backend Context Dispatch"]
        PostChat["Inject into ChatRequest.wearable"]
        PostFitness["Background API Sync /fitness/steps (every 500 steps)"]
    end

    %% Data Flow
    Fitbit --> HC_SDK
    GoogleFit --> HC_SDK
    Samsung --> HC_SDK
    PhoneSensor --> HC_SDK

    Init --> AuthCheck
    AuthCheck --"Granted"--> Fetch
    AuthCheck --"Not Granted"--> PedoFallback

    Fetch --> StepQuery
    Fetch --> CalQuery
    Fetch --> VitalQuery
    Fetch --> SleepQuery

    StepQuery --> Model
    CalQuery --> Model
    VitalQuery --> Model
    SleepQuery --> Model

    Model --> AuthoritativeSync
    AuthoritativeSync --"Wearable Active"--> PostChat
    AuthoritativeSync --"If No Wearable Steps"--> PedoFallback
    PedoFallback --> PostFitness
    AuthoritativeSync --> PostFitness
```

---

## Diagram 5: Multi-Key Pooling & Multi-Provider Failover Waterfall

Depicts how the system guarantees 100% uptime during demonstrations and evaluations by cascading across multiple free-tier LLM accounts and providers.

```mermaid
flowchart TD
    Req["RAG Pipeline Requests LLM Inference<br/>(call_llm, size='70b')"]

    subgraph GroqCascade["Tier 1: Groq Cloud LPU Cascade (Fastest Inference ~500 tok/s)"]
        G_Init["Select Provider: Groq<br/>Models: Qwen 27B / GPT-OSS-20B"]
        G_K1["Try Groq Key 1 (Round-Robin)"]
        G_K2["Try Groq Key 2 (Account 2)"]
        G_K3["Try Groq Key 3 (Account 3)"]
    end

    subgraph SambaCascade["Tier 2: SambaNova Cloud Fallback (High Daily RPD)"]
        S_Init["Select Provider: SambaNova<br/>Model: Meta-Llama-3.3-70B-Instruct"]
        S_K1["Try SambaNova Key 1"]
        S_K2["Try SambaNova Key 2"]
    end

    subgraph CerebrasCascade["Tier 3: Cerebras Cloud Fallback (Highest Token Quota)"]
        C_Init["Select Provider: Cerebras<br/>Model: llama-3.3-70b"]
        C_K1["Try Cerebras Key 1"]
    end

    subgraph ClientFallback["Tier 4: Frontend Client 3-Tier Redundancy"]
        F_Direct["Direct Groq Call from App<br/>(llama-3.1-8b-instant)"]
        F_Demo["Hardcoded ICMR Fallbacks<br/>(Diabetes, BP, Fever, AQI, Diet)"]
        F_Error["Emergency Contact Screen<br/>(🚨 Call 108 Immediately)"]
    end

    Success["Return Response Tokens / SSE Stream"]

    %% Flow
    Req --> G_Init
    G_Init --> G_K1
    G_K1 --"200 OK"--> Success
    G_K1 --"429 Rate Limit"--> G_K2
    G_K2 --"200 OK"--> Success
    G_K2 --"429 Rate Limit"--> G_K3
    G_K3 --"200 OK"--> Success
    G_K3 --"All Groq Keys Exhausted / Provider Error"--> S_Init

    S_Init --> S_K1
    S_K1 --"200 OK"--> Success
    S_K1 --"429 / Error"--> S_K2
    S_K2 --"200 OK"--> Success
    S_K2 --"All SambaNova Keys Exhausted"--> C_Init

    C_Init --> C_K1
    C_K1 --"200 OK"--> Success
    C_K1 --"Failed"--> F_Direct

    F_Direct --"200 OK"--> Success
    F_Direct --"Failed / Offline"--> F_Demo
    F_Demo --"Match Keyword"--> Success
    F_Demo --"No Match"--> F_Error
```

---

## Diagram 6: Safety Router & Clinical Triage Pipeline

Illustrates sub-100ms query classification using Semantic Router and MiniLM sentence embeddings, separating critical emergencies from clinical questions.

```mermaid
flowchart TD
    Input["User Query Arrives<br/>e.g. 'सीने में तेज दर्द हो रहा है' or 'what should my fasting sugar be?'"]

    CheckInit{"Semantic Router<br/>Loaded in Memory?"}

    subgraph SemanticRouterEngine["Semantic Router Vector Classification (<100ms)"]
        MiniLM["HuggingFaceEncoder<br/>(sentence-transformers/all-MiniLM-L6-v2)"]
        Embed["Generate Query Dense Embedding"]
        Sim["Cosine Similarity Search against<br/>Pre-indexed Route Vectors"]
    end

    subgraph KeywordEngine["Heuristic Fallback Engine"]
        KW_Emerg["Check Emergency Keywords<br/>(chest pain, sans nahi, heart attack, unconscious)"]
        KW_Presc["Check Prescription Keywords<br/>(prescribe, dawai likho, dosage, konsi goli)"]
        KW_Off["Check Non-Medical Keywords<br/>(cricket, joke, essay, homework)"]
    end

    subgraph TriageDecision["Triage & Interception Logic"]
        RouteEmerg["Route: emergency"]
        RoutePresc["Route: prescription"]
        RouteOff["Route: non_medical"]
        RouteSafe["Route: None (Safe Query)"]
    end

    subgraph ActionResponses["Output Generation"]
        Resp112["🚨 EMERGENCY DETECTED<br/>- Immediate Call 112 / 102 Banner<br/>- CPR Instructions<br/>- Bypass RAG Pipeline"]
        RespDoc["⚕️ PRESCRIPTION REFUSAL<br/>- ICMR Compliance Disclaimer<br/>- Advise Consulting Registered Doctor"]
        RespRedir["ℹ️ REDIRECTION NOTICE<br/>- Friendly Health Assistant Boundary<br/>- Suggest ICMR Health Topics"]
        ProceedRAG["Forward Query to Agentic Pipeline<br/>(Intent Classification → OKF Navigator)"]
    end

    Input --> CheckInit
    CheckInit --"Yes"--> MiniLM
    MiniLM --> Embed --> Sim
    Sim --> RouteEmerg
    Sim --> RoutePresc
    Sim --> RouteOff
    Sim --> RouteSafe

    CheckInit --"No / Failed"--> KW_Emerg
    KW_Emerg --"Match"--> RouteEmerg
    KW_Emerg --"No Match"--> KW_Presc
    KW_Presc --"Match"--> RoutePresc
    KW_Presc --"No Match"--> KW_Off
    KW_Off --"Match"--> RouteOff
    KW_Off --"No Match"--> RouteSafe

    RouteEmerg --> Resp112
    RoutePresc --> RespDoc
    RouteOff --> RespRedir
    RouteSafe --> ProceedRAG
```

---

## Diagram 7: Environmental NAQI Calculation & Clinical Alerting Pipeline

Shows how GPS coordinates are converted into real-time National Air Quality Index (NAQI) values, evaluated against CPCB breakpoints, and converted into clinical preventive advice.

```mermaid
flowchart TD
    GPS["Device LocationService<br/>(Latitude, Longitude)"]

    subgraph EnvironmentalFetch["Real-Time Meteorological Data Fetching"]
        WAQI_API["WAQI Geo Endpoint<br/>feed/geo:lat;lon/?token=..."]
        OpenMeteo["Open-Meteo Weather API<br/>Temp, Humidity, Wind, UV"]
    end

    subgraph SubIndexCalculation["CPCB NAQI Sub-Index Engine (`backend/utils/icmr.py`)"]
        ExtractPollutants["Extract Individual Pollutant Concentrations<br/>PM2.5, PM10, NO2, SO2, CO, O3"]
        Formula["Linear Interpolation Formula:<br/>Ip = ((I_hi - I_lo) / (B_hi - B_lo)) * (Cp - B_lo) + I_lo"]
        MaxIndex["Overall NAQI = Max(I_PM2.5, I_PM10, I_NO2, I_SO2, I_CO, I_O3)"]
    end

    subgraph CategoryClassification["CPCB Category Classification"]
        C_Good["0 - 50: Good (Minimal impact)"]
        C_Sat["51 - 100: Satisfactory (Minor breathing discomfort to sensitive people)"]
        C_Mod["101 - 200: Moderate (Discomfort to people with lungs/asthma/heart diseases)"]
        C_Poor["201 - 300: Poor (Breathing discomfort to most people on prolonged exposure)"]
        C_VPoor["301 - 400: Very Poor (Respiratory illness on prolonged exposure)"]
        C_Sev["401 - 500: Severe (Affects healthy people and seriously impacts those with existing diseases)"]
    end

    subgraph ClinicalCorrelation["Profile Correlation & Actionable Advisory"]
        CheckCond["Match Against User Profile Conditions<br/>(Asthma, COPD, Hypertension, Diabetes)"]
        Advisory["Generate Clinical Recommendations:<br/>- AQI >= 201: N95 Mask mandatory outdoors<br/>- AQI >= 150: Shift morning walk to indoor yoga<br/>- Asthmatics: Keep reliever inhaler on hand<br/>- COPD: Close windows during morning smog peaks"]
    end

    %% Flow
    GPS --> WAQI_API
    GPS --> OpenMeteo
    WAQI_API --> ExtractPollutants
    ExtractPollutants --> Formula
    Formula --> MaxIndex

    MaxIndex --> C_Good
    MaxIndex --> C_Sat
    MaxIndex --> C_Mod
    MaxIndex --> C_Poor
    MaxIndex --> C_VPoor
    MaxIndex --> C_Sev

    C_Mod --> CheckCond
    C_Poor --> CheckCond
    C_VPoor --> CheckCond
    C_Sev --> CheckCond

    CheckCond --> Advisory
    Advisory --> BuildPrompt["Inject into XML &lt;environment&gt; Block<br/>for LLM Response Synthesis"]
```
