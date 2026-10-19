import requests
import base64
from PIL import Image
import io
import time
from pathlib import Path

headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}

diagrams = {
    # 1. Figure 3.1: Overall Architecture (Clean, Modular 4-Tier)
    "figure_3_1_overall_system_architecture.png": """flowchart TD
    classDef client fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px;
    classDef api fill:#E3F2FD,stroke:#1565C0,stroke-width:2px;
    classDef core fill:#FFF3E0,stroke:#E65100,stroke-width:2px;
    classDef ai fill:#F3E5F5,stroke:#7B1FA2,stroke-width:2px;

    subgraph ClientLayer["1. Client Tier (Flutter 3.x Mobile App)"]
        UI["Material 3 User Interface<br>(Chat, Dashboard, Vitals)"]:::client
        HC["Health Connect Sync<br>(Fitbit, Google Fit)"]:::client
        Vault["Local Medical Vault<br>(On-Device Storage)"]:::client
    end

    subgraph APILayer["2. API Gateway (FastAPI / Render)"]
        API["FastAPI Gateway Router<br>HTTPS / TLS 1.3 / SSE Streaming"]:::api
    end

    subgraph CoreLayer["3. Safety & Orchestration Core"]
        Router["Semantic Safety Router<br>(Sub-100ms MiniLM Triage)"]:::core
        CRAG["Agentic CRAG Pipeline<br>(ReAct Decision Engine)"]:::core
        OKF["OKF Navigator Graph<br>(Deterministic File Traversal)"]:::core
    end

    subgraph AILayer["4. Knowledge & Inference Layer"]
        ICMR["ICMR Knowledge Base<br>(34 Structured Monographs)"]:::ai
        AQI["CPCB NAQI Air Quality<br>(Live Environmental Feed)"]:::ai
        LLM["Groq LPU (Qwen 27B)<br>(3-Key Auto Failover)"]:::ai
    end

    UI --> API
    HC --> UI
    Vault <--> UI
    API --> Router
    Router -->|Emergency| UI
    Router -->|Safe Query| CRAG
    CRAG --> OKF
    OKF <--> ICMR
    CRAG <--> AQI
    CRAG --> LLM
    LLM -->|SSE Stream| API
    API -->|Real-Time Tokens| UI
""",

    # 2. Figure 3.2: ReAct Flow (Clean 4-Step Pipeline)
    "figure_3_2_react_loop_state_machine.png": """flowchart TD
    classDef start fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px;
    classDef safety fill:#FFF3E0,stroke:#E65100,stroke-width:2px;
    classDef core fill:#E3F2FD,stroke:#1565C0,stroke-width:2px;
    classDef llm fill:#F3E5F5,stroke:#7B1FA2,stroke-width:2px;
    classDef emerg fill:#FFEBEE,stroke:#C62828,stroke-width:2px;

    Input["User Query (Hindi / Marathi / English)"]:::start

    subgraph Step1["Step 1: Sub-100ms Safety Check"]
        SafeGate{"Semantic Router<br>MiniLM Check"}:::safety
        EmergAlert["🚨 Immediate Call 112 Banner<br>& CPR Instructions (Bypass AI)"]:::emerg
        RxBlock["⚕️ ICMR Prescription Refusal<br>& Doctor Consultation Advice"]:::safety
    end

    subgraph Step2["Step 2: Intent Classification"]
        Classifier{"Classify Intent"}:::core
        Greeting["Fast Greeting Stream"]:::start
        HealthQuery["Clinical Health Inquiry"]:::core
        VitalsCheck["Wearable Vitals Inquiry"]:::core
    end

    subgraph Step3["Step 3: OKF Retrieval & Verification"]
        OKFCrawl["Traverse OKF Concept Graph<br>(index.md -> Disease File)"]:::core
        Grader["CRAG Relevance Grader<br>(Filter Irrelevant Chunks)"]:::core
    end

    subgraph Step4["Step 4: Grounded LLM Generation"]
        Context["Assemble XML Prompt<br>(ICMR Docs + Vitals + AQI)"]:::llm
        Groq["Groq Cloud Qwen 27B LPU<br>Stream SSE Tokens (500 tok/s)"]:::llm
    end

    Input --> SafeGate
    SafeGate -->|Emergency| EmergAlert
    SafeGate -->|Prescription| RxBlock
    SafeGate -->|Safe Query| Classifier
    Classifier -->|Greeting| Greeting
    Classifier -->|Vitals| VitalsCheck --> Context
    Classifier -->|Health| HealthQuery --> OKFCrawl --> Grader --> Context
    Context --> Groq
""",

    # 3. Figure 3.3: DPDP Privacy Boundary (Balanced 2x2 Grid)
    "figure_3_3_dpdp_privacy_boundary.png": """flowchart TD
    classDef dev fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px;
    classDef trans fill:#E1F5FE,stroke:#0288D1,stroke-width:2px;
    classDef cloud fill:#E3F2FD,stroke:#1565C0,stroke-width:2px;
    classDef ext fill:#FFF3E0,stroke:#E65100,stroke-width:2px;

    subgraph Row1["CLIENT & TRANSIT BOUNDARY"]
        direction LR
        subgraph DevBox["1. User Device (Data Principal Sovereignty)"]
            App["Flutter Mobile Client"]:::dev
            SecVault["AES-256 Local Medical Vault<br>No Cloud Upload Required"]:::dev
            Sensors["Health Connect Permissions<br>Explicit User Opt-In"]:::dev
        end

        subgraph TransBox["2. Secure Ephemeral Transit"]
            TLS["HTTPS / TLS 1.3 Transport<br>- Zero Intermediate Caching<br>- Pseudonymous UUID Only"]:::trans
        end
    end

    subgraph Row2["CLOUD & INFERENCE BOUNDARY"]
        direction LR
        subgraph CloudBox["3. Aarogya Sathi Cloud (Data Fiduciary)"]
            Gateway["FastAPI Gateway Router"]:::cloud
            SessionStore["Ephemeral JSON Cache (sessions/)<br>- Capped to 20 Vitals Snapshots<br>- No PII (Name, Phone, Aadhaar)<br>- Right to Erasure Compliant"]:::cloud
        end

        subgraph InfBox["4. Stateless LLM Inference"]
            GroqLPU["Groq Cloud LPU Cluster<br>- Zero Data Retention (ZDR) SLA<br>- Memory Cleared Immediately<br>- No Model Training on User Data"]:::ext
        end
    end

    Sensors --> App
    SecVault <--> App
    App --"Pseudonymous Payload"--> TLS
    TLS --> Gateway
    Gateway <--> SessionStore
    Gateway --"Sanitized Context"--> GroqLPU
    GroqLPU --"SSE Token Stream"--> Gateway
    Gateway --"Decrypted On-Device"--> TLS
    TLS --> App
""",

    # 4. Figure 4.1: Multi-Key LLM Waterfall (Balanced 4-Tier)
    "figure_4_2_multi_key_llm_cascade.png": """flowchart TD
    classDef req fill:#E3F2FD,stroke:#1565C0,stroke-width:2px;
    classDef p1 fill:#FFF8E1,stroke:#FFA000,stroke-width:2px;
    classDef p2 fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px;
    classDef p3 fill:#F3E5F5,stroke:#7B1FA2,stroke-width:2px;
    classDef p4 fill:#FFEBEE,stroke:#C62828,stroke-width:2px;
    classDef ok fill:#E8F5E9,stroke:#388E3C,stroke-width:3px;

    Req["Agentic Pipeline Requests Inference<br>call_llm(context, size='70b', temp=0.3)"]:::req

    T1["Tier 1: Groq Cloud LPU Primary Pool (~500 tok/s)<br>Model: Qwen 27B | 3 API Keys Auto-Rotating"]:::p1
    T2["Tier 2: SambaNova Cloud Secondary Fallback<br>Model: Meta-Llama-3.3-70B-Instruct (High RPD)"]:::p2
    T3["Tier 3: Cerebras Cloud Tertiary Fallback<br>Model: llama-3.3-70b (High Token Quota)"]:::p3
    T4["Tier 4: Client Offline Redundancy<br>Local ICMR Cache -> Emergency 108 Screen"]:::p4

    Success["Word-by-Word SSE Token Stream (200 OK)"]:::ok

    Req --> T1
    T1 -->|200 OK| Success
    T1 -->|429 Rate Limit| T2
    T2 -->|200 OK| Success
    T2 -->|All Keys Depleted| T3
    T3 -->|200 OK| Success
    T3 -->|Cloud Outage| T4
    T4 -->|Offline Hit| Success
""",

    # 5. Figure 4.2: Safety Router (Clean 3-Path Triage)
    "figure_4_3_safety_router_clinical_triage.png": """flowchart TD
    classDef inp fill:#E3F2FD,stroke:#1565C0,stroke-width:2px;
    classDef vec fill:#FFF8E1,stroke:#FFA000,stroke-width:2px;
    classDef emerg fill:#FFEBEE,stroke:#C62828,stroke-width:2px;
    classDef rx fill:#FFF3E0,stroke:#E65100,stroke-width:2px;
    classDef safe fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px;

    Query["User Query Ingestion (Hindi / Marathi / English)<br>e.g. 'सीने में भारीपन' or 'what is normal fasting sugar?'"]:::inp

    Triage{"Semantic Router Vector Classification<br>(MiniLM-L6-v2 | Cosine Cutoff: 0.82)"}:::vec

    R1["🚨 Emergency Detected:<br>- Sub-100ms Immediate Return<br>- Call 112 / 102 Banner & CPR Steps<br>- Generative LLM Bypassed"]:::emerg
    R2["⚕️ Prescription Refusal:<br>- ICMR Non-Prescription Disclaimer<br>- Explains AI Cannot Prescribe<br>- Recommends Registered Doctor"]:::rx
    R3["✅ Safe Clinical Query:<br>- Forward to Agentic CRAG Pipeline<br>- OKF Knowledge Retrieval & Response"]:::safe

    Query --> Triage
    Triage -->|Emergency Intent| R1
    Triage -->|Prescription Intent| R2
    Triage -->|Safe Health Inquiry| R3
""",

    # 6. Figure 4.3: Environmental NAQI Pipeline (Balanced 2-Row Flow)
    "figure_4_4_cpcb_naqi_calculation.png": """flowchart TD
    classDef gps fill:#E1F5FE,stroke:#0288D1,stroke-width:2px;
    classDef calc fill:#F3E5F5,stroke:#7B1FA2,stroke-width:2px;
    classDef cat fill:#ECEFF1,stroke:#455A64,stroke-width:2px;
    classDef adv fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px;

    subgraph Ingest["1. Meteorological Telemetry Ingestion"]
        GPS["Device LocationService<br>(Latitude, Longitude)"]:::gps
        WAQI["Nearest CAAQMS Station Data<br>(PM2.5, PM10, NO2, SO2, CO, O3)"]:::gps
    end

    subgraph Calc["2. CPCB Linear Sub-Index Calculation"]
        Formula["Linear Interpolation Formula:<br>Ip = ((I_hi - I_lo)/(B_hi - B_lo))*(Cp - B_lo) + I_lo"]:::calc
        MaxIndex["Overall NAQI = Max(I_pollutants)<br>Governed by Dominant Pollutant (PM2.5)"]:::calc
    end

    subgraph Scale["3. CPCB Risk Categories & Clinical Advisory"]
        ScaleBox["Categories: 0-50 Good | 51-100 Satisfactory | 101-200 Moderate<br>201-300 Poor | 301-400 Very Poor | 401-500 Severe"]:::cat
        Advisory["Clinical Correlation & Actionable Advice:<br>• AQI >= 201: Mandatory N95 Mask Outdoors<br>• AQI >= 150: Reschedule morning walk to indoor Yoga<br>• Asthmatics: Carry Short-Acting Beta-Agonist Inhaler<br>• Injected into XML prompt for AI Chat"]:::adv
    end

    GPS --> WAQI --> Formula --> MaxIndex --> ScaleBox --> Advisory
""",

    # 7. Figure 4.4: Wearable Health Connect Pipeline (Balanced 2-Row)
    "figure_4_1_wearable_health_connect_pipeline.png": """flowchart TD
    classDef src fill:#E0F7FA,stroke:#00838F,stroke-width:2px;
    classDef hc fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px;
    classDef dedup fill:#FFF8E1,stroke:#FFA000,stroke-width:2px;
    classDef out fill:#F3E5F5,stroke:#7B1FA2,stroke-width:2px;

    subgraph Sources["1. Wearable Sources & Platform SDK"]
        Trackers["Smartwatch Ecosystems<br>(Fitbit, Google Fit, Samsung Health)"]:::src
        HCSDK["Android Health Connect Client v1.1.0<br>(36-Hour Rolling Lookback Window)"]:::hc
    end

    subgraph Processing["2. Smart Aggregation & Deduplication Logic"]
        Dedup["Active Energy Deduplication:<br>Group by Source, Select Minimum to Prevent Double Counting"]:::dedup
        Vitals["Biometric Metric Extraction:<br>Heart Rate, SpO2, Blood Pressure, Glucose, Sleep Stages"]:::dedup
        Fallback["StepFilterService (Pedometer Fallback):<br>Hysteresis Filter to Reject Stationary Arm Shakes"]:::dedup
    end

    subgraph Output["3. Context Dispatch & AI Injection"]
        Model["Construct WearableDataModel"]:::out
        Dispatch["• Persist to SharedPreferences Cache<br>• Periodic Sync /fitness/steps (Every 500 Steps)<br>• Inject into ChatRequest.wearable for RAG Response"]:::out
    end

    Trackers --> HCSDK
    HCSDK --> Dedup
    HCSDK --> Vitals
    HCSDK --> Fallback
    Dedup --> Model
    Vitals --> Model
    Fallback --> Model
    Model --> Dispatch
""",

    # 8. Figure 4.5: ICMR Knowledge Bundle OKF Graph
    "figure_4_5_icmr_knowledge_graph.png": """flowchart TD
    classDef root fill:#E3F2FD,stroke:#1565C0,stroke-width:2px;
    classDef cat fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px;

    Root["Master Catalog: index.md<br>(34 Structured ICMR Medical Concept Files)"]:::root

    C1["Conditions (11 Files)<br>Diabetes, Hypertension, COPD, CAD"]:::cat
    C2["Drugs (7 Files)<br>Metformin, Amlodipine, Paracetamol"]:::cat
    C3["Lifestyle (6 Files)<br>Diet Guidelines, Exercise, Sleep"]:::cat
    C4["Emergency (6 Files)<br>Chest Pain First-Aid, CPR Protocol"]:::cat
    C5["Environment (4 Files)<br>AQI Guidelines, Heat Stress"]:::cat

    Root --> C1
    Root --> C2
    Root --> C3
    Root --> C4
    Root --> C5

    C1 <-->|Direct Markdown Hyperlinks| C2
    C1 <-->|Direct Markdown Hyperlinks| C3
    C1 <-->|Direct Markdown Hyperlinks| C4
    C1 <-->|Direct Markdown Hyperlinks| C5
"""
}

out_dir = Path("docs/diagrams/images")
out_dir.mkdir(parents=True, exist_ok=True)

print("Rendering 8 perfectly balanced, high-legibility diagrams...", flush=True)

for fname, code in diagrams.items():
    clean_code = code.strip()
    encoded = base64.b64encode(clean_code.encode("utf-8")).decode("ascii")
    url = f"https://mermaid.ink/img/{encoded}"
    out_file = out_dir / fname
    
    # Retry loop up to 3 times
    success = False
    for attempt in range(3):
        try:
            r = requests.get(url, headers=headers, timeout=20)
            if r.status_code == 200 and len(r.content) > 1000:
                with open(out_file, "wb") as f:
                    f.write(r.content)
                img = Image.open(out_file)
                print(f"  [OK] {fname}: {len(r.content)} bytes, size={img.size}")
                success = True
                break
            else:
                print(f"  [RETRY {attempt+1}] {fname} status={r.status_code}")
                time.sleep(1)
        except Exception as e:
            print(f"  [RETRY {attempt+1}] {fname} error={e}")
            time.sleep(1)
            
    if not success:
        print(f"  [FAILED] {fname}")

print("\nAll diagrams rendered!", flush=True)
