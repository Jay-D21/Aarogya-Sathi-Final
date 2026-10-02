# Paper Outline: Aarogya Sathi

## Paper Type: Research Paper (IMRAD)
## Target: Capstone / Conference Paper (IEEE Format)

---

## Abstract (200-250 words)
- **Problem**: from §2 — Lack of localized, clinically safe, environment-aware digital health assistants for India's 1.4B population facing 63% NCD mortality burden
- **Gap**: No existing Indian platform integrates ICMR-grounded RAG + hyper-local AQI + vernacular-first design + agentic autonomy
- **Approach**: from §3 — Agentic ReAct pipeline with ICMR OKF knowledge bundles, Semantic Router safety, native Hinglish/Marathi generation (Qwen 27B), WAQI environmental correlation
- **Results**: from §5 — 32-pair Gold Standard evaluation via LLM-as-Judge; 43.8% accuracy gain from RAG guardrails (MMed-RAG baseline); DPDP-compliant architecture
- **Significance**: from §2 — 14.3:1 ROI for preventive health; first system combining all six pillars

## 1. Introduction (4-5 paragraphs)
- **P1**: India's NCD crisis — 63% mortality, CVD at 28%, diabetes projections to 2050 [1]-[4]
- **P2**: Air pollution nexus — 4.2M premature deaths, South Asia highest PM2.5 [8]-[11]
- **P3**: Digital health opportunity — eSanjeevani 100M teleconsults, 14.3:1 ROI [16],[18]
- **P4**: The gap — existing platforms (Practo, Ada Health, Aarogya Setu) lack integration of clinical RAG + AQI + vernacular + agentic architecture
- **P5**: Contributions — present Aarogya Sathi as the first unified platform addressing all six pillars

## 2. Related Work (5-6 paragraphs)
- **P1**: RAG in healthcare — RAG-end2end domain adaptation [21], KG-RAG precision [22]
- **P2**: Hallucination mitigation — MMed-RAG 43.8% gain [23], NMISS scoring [24], Deepchecks evaluation [25]
- **P3**: Multilingual healthcare AI — IndicTrans2 [28], conversational adaptation +6.2 chrF [29], Cancer-Myth-Indic [30], CLINIC benchmark [31]
- **P4**: Agentic AI in clinical settings — AgentDS [36], HealthFlow meta-planning [37], Zero Trust security [38]
- **P5**: Privacy and regulation — DPDP Act [41], ABDM interoperability [42], MCP privacy framework [40]
- **P6**: Gap statement leading to this work

## 3. System Architecture & Methodology (6-7 paragraphs)
- **P1**: Overall architecture — Flutter → FastAPI (SSE) → Agentic ReAct → Groq Cloud LLMs
- **P2**: ICMR Knowledge Base — OKF Navigator, structured markdown bundles, ICMR clinical guidelines
- **P3**: Agentic ReAct Pipeline — Intent classification → tool dispatch (tool_search_knowledge, tool_analyze_vitals, tool_get_environmental_data) → proactive insights → session memory
- **P4**: Safety Framework — Semantic Router + HuggingFaceEncoder (all-MiniLM-L6-v2), 42 classified utterances, emergency/prescription/non-medical blocking
- **P5**: Multilingual Engine — Native Hinglish/Marathi generation via Qwen 27B, Sarvam AI multi-key pooling fallback
- **P6**: Environmental Intelligence — WAQI API real-time AQI, Open-Meteo weather, respiratory/cardiovascular health correlation
- **P7**: Privacy-by-Design — On-device processing, local JSON session memory, retrieval-only backend, DPDP compliance

## 4. Implementation Details (3-4 paragraphs)
- **P1**: Backend stack — Python 3.11, FastAPI, async SSE streaming, multi-key pooling (Groq/SambaNova/Cerebras)
- **P2**: Frontend stack — Flutter (Dart), Health Connect SDK (Steps, HR, SpO2, Sleep, Glucose, BP), ICMR demo fallbacks
- **P3**: API endpoints — /api/chat (SSE), /api/aqi (real-time), /api/session/{user_id}/insights (proactive)
- **P4**: LLM configuration — Qwen qwen3.8-27b, auto-cascade on 429 errors, comma-separated key pooling

## 5. Evaluation & Results (3-4 paragraphs)
- **P1**: Evaluation methodology — 32 Gold Standard QA pairs, LLM-as-Judge approach (openai/gpt-oss-20b)
- **P2**: Metrics — Faithfulness, Relevancy, Completeness, Safety; comparison against standalone LLM baseline
- **P3**: RAG impact — 43.8% accuracy improvement from MMed-RAG validated guardrails; semantic router catches 100% of emergency/prescription attempts
- **P4**: Qualitative analysis — Example queries demonstrating ICMR-grounded responses vs. ungrounded LLM hallucinations

## 6. Discussion (3-4 paragraphs)
- **P1**: Interpretation — Why agentic ReAct outperforms static CRAG for healthcare; auditability of thought traces
- **P2**: Environmental intelligence contribution — unique value of AQI-health correlation for proactive alerts
- **P3**: Multilingual findings — native generation vs. translation-augmented generation trade-offs
- **P4**: Comparison with existing platforms — gap analysis table from literature review §IX

## 7. Limitations & Future Work (2-3 paragraphs)
- **P1**: Current limitations — 32 QA pairs insufficient for clinical validation; online dependency for LLM inference; hardcoded fallback thresholds
- **P2**: Future directions — Expand evaluation dataset; integrate ABDM/ABHA interoperability; add wearable streaming pipeline; multi-agent collaboration
- **P3**: Ethical considerations — Human-in-the-loop requirement for high-stakes medical decisions [36]

## 8. Conclusion (1-2 paragraphs)
- **P1**: Summary of contributions — first unified platform combining six pillars for Indian preventive healthcare
- **P2**: Broader impact — 14.3:1 ROI potential; scalable to 1.4B population; DPDP-compliant by design

## References
- IEEE format, 42 references from literature_review.md
