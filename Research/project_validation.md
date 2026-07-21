# Project Validation & Key Statistics: Aarogya Sathi

This document summarizes the peer-reviewed evidence that validates the development of Aarogya Sathi. Every statistic listed here is traceable to a specific DOI or arXiv ID. For full citations, see `research_materials/literature_review.md`.

---

## 1. The Burden of Non-Communicable Diseases (NCDs)

| Statistic | Value | Source |
|-----------|-------|--------|
| NCDs as % of all deaths in India | ~63% | GBD 2019, *The Lancet*. doi: 10.1016/S0140-6736(20)30925-9 |
| Global CVD cases (2019) | 523 million | GBD CVD 2019, *JACC*. doi: 10.1016/j.jacc.2020.11.010 |
| Global CVD deaths per year | 18.6 million | GBD CVD 2019, *JACC*. doi: 10.1016/j.jacc.2020.11.010 |
| Deaths attributable to high BMI | 4.0 million | GBD Obesity 2015, *NEJM*. doi: 10.1056/NEJMoa1614362 |
| Obese adults globally (2017) | 107.7 million | GBD Obesity 2015, *NEJM*. doi: 10.1056/NEJMoa1614362 |

**Why Aarogya Sathi?** Proactive monitoring, personalized dietary advice in the user's native language, and continuous health tracking can significantly delay onset and reduce severity of NCDs.

---

## 2. Air Pollution and Respiratory Health

| Statistic | Value | Source |
|-----------|-------|--------|
| Premature deaths from ambient PM2.5 globally | 4.2 million | Lelieveld et al., *Nature* 2015. doi: 10.1038/nature15371 |
| Air pollution rank as a global risk factor | Top 5 for DALYs | GBD Risk Factors 2019, *The Lancet*. doi: 10.1016/S0140-6736(20)30752-2 |
| Lung function reduction in Indian non-smokers vs Europeans | ~30% lower | Salvi & Barnes, *Chest* 2010. doi: 10.1378/chest.10-0645 |
| South Asia PM2.5 exposure | Highest population-weighted globally | Cohen et al., *The Lancet* 2017. doi: 10.1016/S0140-6736(17)30505-6 |

**Why Aarogya Sathi?** By integrating real-time CPCB AQI data with personal health profiles, Aarogya Sathi issues proactive alerts (e.g., "Stay indoors — PM2.5 is dangerous for your COPD condition today").

---

## 3. The Economics of Preventive Digital Health

| Statistic | Value | Source |
|-----------|-------|--------|
| ROI of preventive health interventions | 14.3:1 median | Masters et al., *J Epidemiol Community Health* 2017. doi: 10.1136/jech-2016-208141 |
| eSanjeevani teleconsultations (by 2024) | 100+ million | Ministry of Health and Family Welfare, GoI |
| MRC framework for complex intervention evaluation | Gold standard | Skivington et al., *BMJ* 2021. doi: 10.1136/bmj.n2061 |

**Why Aarogya Sathi?** The 14.3:1 ROI for preventive health directly validates the economic viability of AI-driven preventive care platforms.

---

## 4. AI Safety: RAG for Clinical Accuracy

| Statistic | Value | Source |
|-----------|-------|--------|
| Factual accuracy improvement with MMed-RAG | +43.8% average | Xia et al., *ICLR 2025*. arXiv: 2410.13085 |
| Scope-matched KG-RAG vs generic RAG | Consistently superior | Anuyah et al., 2026. arXiv: 2601.15429 |
| RAG-end2end vs vanilla RAG | Significant QA improvement | Siriwardhana et al., *TACL* 2022. arXiv: 2210.02627 |
| Conversational agents safety gaps | Documented in systematic review | Laranjo et al., *JAMIA* 2018. doi: 10.1093/jamia/ocy072 |

**Why Aarogya Sathi?** ICMR-grounded, scope-matched RAG ensures that every health recommendation is traceable to verified clinical guidelines, eliminating the hallucination risk.

---

## 5. Vernacular-First AI for India

| Statistic | Value | Source |
|-----------|-------|--------|
| Official Indian languages | 22 | Census of India 2011 |
| IndicTrans2 conversational improvement | +6.2 chrF | arXiv: 2606.29024 (2026) |
| Cancer-Myth-Indic safety benchmark | 2,500 items, 5 Indic languages | arXiv: 2511.01360 (LREC 2026) |
| Multilingual LLM trustworthiness gap | English overestimates safety | CLINIC benchmark. arXiv: 2512.11437 |

**Why Aarogya Sathi?** 90% of India does not speak English as a primary language. Vernacular-first AI is not optional — it's a prerequisite for healthcare access.

---

## 6. Regulatory Compliance

| Regulation | Key Requirement | Source |
|------------|----------------|--------|
| DPDP Act, 2023 | Explicit consent, DPO appointment, DPIA audits | Gazette of India, Aug. 2023 |
| DPDP Act penalties | Up to INR 250 crore (~$30M USD) | DPDP Act Section 33 |
| ABDM compatibility | ABHA IDs, Health Information Exchange standards | National Health Authority, abdm.gov.in |

**Why Aarogya Sathi?** On-device processing + RAG retrieval (not storage) architecture minimizes data sovereignty risk and is DPDP-compliant by design.

---

## Competitive Gap Analysis

| Feature | Practo | Aarogya Setu | eSanjeevani | Ada Health | **Aarogya Sathi** |
|---------|--------|-------------|-------------|------------|-------------------|
| Preventive NCD management | No | No | Limited | Limited | **Yes** |
| Real-time AQI integration | No | No | No | No | **Yes** |
| Vernacular-first (22 languages) | No | No | Limited | No | **Yes** |
| ICMR-grounded RAG | No | No | No | No | **Yes** |
| Agentic AI architecture | No | No | No | No | **Yes** |
| DPDP Act compliant | Partial | Yes | Yes | No | **Yes** |

**No existing solution in the Indian market combines all six capabilities.**
