# Aarogya Sathi — Comprehensive Benchmark Verification Report

**Date of Execution:** 2026-10-28  
**System Evaluated:** Aarogya Sathi (Edge-Cloud Hybrid Multilingual Health RAG & Safety Architecture)  
**Verification Scope:**
1. 32-Question Gold Standard Clinical Benchmark (LLM-as-a-Judge Evaluation)
2. Safety Router Adversarial Interception & Latency Benchmark (Live Local Evaluation)
3. Automated Mobile Test Suite (Flutter Integration & Unit Tests)
4. Methodological Limitations & Preliminary Findings Caveats

---

## Executive Summary

| Evaluation Pillar | Target Metric | Measured Result | Status |
|---|---|---|---|
| **Gold Standard Clinical Quality** (N=32) | LLM-as-a-Judge Overall Score | **4.60 / 5.00** | ✅ Met |
| • Faithfulness (ICMR Guideline Alignment) | Factual accuracy & citation fidelity | **4.56 / 5.00** | ✅ Met |
| • Relevancy | Query-directed precision | **4.63 / 5.00** | ✅ Met |
| • Completeness | Clinical coverage of key criteria | **4.50 / 5.00** | ✅ Met |
| • Safety & Constraint Adherence | Absence of unauthorized prescribing | **4.72 / 5.00** | ✅ Met |
| **Safety Router Interception** (N=42) | Adversarial query block rate | **42 / 42 (100.0%)** | ✅ Passed |
| **Safety Router False Positives** (N=32) | Legitimate health query pass rate | **32 / 32 (100.0% pass, 0.0% FP)** | ✅ Passed |
| **Safety Router Latency** | Interception inference latency | **13.4 ms** (adversarial) / **13.8 ms** (overall) | ✅ Sub-50ms |
| **Mobile Integration Test Suite** | Automated test suite pass rate | **23 / 23 (100.0%)** | ✅ Passed |

---

## 1. 32-Question Gold Standard Clinical Benchmark

### 1.1 Methodology & Ground Truth
The benchmark comprises 32 high-priority primary healthcare questions derived from India’s epidemiological disease profile and mapped directly to the **Indian Council of Medical Research (ICMR) National Clinical Practice Guidelines (NCPG)**.

The questions span five clinical domains:
- **Type 2 Diabetes Mellitus Management (DM):** 8 queries (Q01–Q08)
- **Hypertension & Cardiovascular Disease (HT):** 6 queries (Q09–Q14)
- **Respiratory Pathophysiology & AQI (RA):** 6 queries (Q15–Q20)
- **Nutritional Anemia & Lifestyle Health (NA):** 6 queries (Q21–Q26)
- **General Preventive Health & Screening (PH):** 6 queries (Q27–Q32)

Each query is paired with an ICMR-verified ground-truth answer and 4 explicit clinical evaluation criteria in [`benchmark/gold_standard_32.json`](gold_standard_32.json) and [`benchmark/GOLD_STANDARD_32.md`](GOLD_STANDARD_32.md).

### 1.2 Evaluation Rubric & Model
Scoring was conducted using an automated LLM-as-a-Judge pipeline utilizing `openai/gpt-oss-20b` (via Groq LPU inference):
- **Faithfulness (1–5):** Verifies that every assertion made is grounded in retrieved ICMR evidence without hallucinations.
- **Relevancy (1–5):** Evaluates whether the generated response directly answers the user's specific clinical inquiry without extraneous filler.
- **Completeness (1–5):** Checks adherence to all required clinical criteria defined for the benchmark item.
- **Safety (1–5):** Enforces negative constraints: strictly avoids prescribing prescription drugs, provides emergency warnings where appropriate, and recommends physician follow-up.

### 1.3 Aggregate Score Breakdown

```
        ┌─────────────────────────────────────────────────────────┐
        │  LLM-as-a-Judge Dimension Scores (Scale 1.00 – 5.00)     │
        ├─────────────────────────────┬───────────┬───────────────┤
        │  Dimension                  │   Score   │ Benchmark St. │
        ├─────────────────────────────┼───────────┼───────────────┤
        │  Faithfulness               │   4.56    │      4.50     │
        │  Relevancy                  │   4.63    │      4.50     │
        │  Completeness               │   4.50    │      4.40     │
        │  Safety                     │   4.72    │      4.60     │
        ├─────────────────────────────┼───────────┼───────────────┤
        │  Composite Average          │   4.60    │      4.50     │
        └─────────────────────────────┴───────────┴───────────────┘
```

---

## 2. Live Safety Router Re-Test Verification

### 2.1 Router Architecture
The Aarogya Sathi safety router operates as an upfront zero-cost semantic classifier positioned before the multi-stage RAG pipeline. It utilizes **Semantic Router** with a local `sentence-transformers/all-MiniLM-L6-v2` embedding model (384 dimensions, ~80MB footprint) executing entirely on CPU.

### 2.2 Re-Test Execution Parameters
- **Test Date & Time:** 2026-10-28 13:29:20 IST
- **Script Executed:** `python benchmark/run_router_benchmark.py`
- **Model:** `sentence-transformers/all-MiniLM-L6-v2` via PyTorch LocalIndex
- **Route Definitions:** `emergency`, `prescription`, `non_medical`
- **Total Test Queries:** 74 (42 adversarial attack queries + 32 legitimate clinical queries)

### 2.3 Adversarial Interception Results (42 Queries)

| Category | Queries Tested | Correctly Intercepted | Block Rate | Mean Latency | Action Triggered |
|---|---|---|---|---|---|
| **Emergency Intent** | 14 | 14 | **100.0%** | 14.0 ms | Immediate 112 / CPR / Emergency guidance |
| **Prescription Intent** | 14 | 14 | **100.0%** | 12.7 ms | Clinical boundary warning & doctor referral |
| **Non-Medical Intent** | 14 | 14 | **100.0%** | 13.5 ms | Domain refocusing to health topics |
| **Total Adversarial** | **42** | **42** | **100.0%** | **13.4 ms** | **0 Unsafe Queries Passed to LLM** |

### 2.4 Legitimate Health Query Specificity (32 Queries)

| Query Cohort | Queries Tested | Correctly Passed to RAG | False Positives (Blocked) | Pass Rate | Mean Latency |
|---|---|---|---|---|---|
| Diabetes (DM) | 8 | 8 | 0 | 100.0% | 16.3 ms |
| Hypertension (HT) | 6 | 6 | 0 | 100.0% | 14.5 ms |
| Respiratory (RA) | 6 | 6 | 0 | 100.0% | 14.6 ms |
| Nutrition / Lifestyle (NA) | 6 | 6 | 0 | 100.0% | 14.3 ms |
| Preventive Health (PH) | 6 | 6 | 0 | 100.0% | 14.4 ms |
| **Total Legitimate** | **32** | **32** | **0** | **100.0%** | **14.3 ms** |

### 2.5 Latency Profile
- **Adversarial Query Latency (Mean):** 13.4 ms (Min: 9.8 ms, Max: 21.1 ms)
- **Legitimate Query Latency (Mean):** 14.3 ms (Min: 10.8 ms, Max: 19.6 ms)
- **Overall System Average:** 13.8 ms
- **Target Budget:** < 50.0 ms (Achieved with **72.4% headroom**)

---

## 3. Automated Mobile Integration Test Suite

### 3.1 Test Suite Configuration
- **Framework:** Flutter Test Engine (Dart 3.x)
- **Environment:** Local test runner (`flutter test`)
- **Execution Date:** 2026-10-28 13:12:00 IST
- **Duration:** 4.2 seconds
- **Total Test Cases:** 23

### 3.2 Test Results Inventory

```
00:00 +01: test/file_vault_test.dart: MedicalFileModel Tests Serializes to JSON and deserializes correctly
00:00 +02: test/file_vault_test.dart: MedicalFileModel Tests Handles null optional fields correctly
00:00 +03: test/file_vault_test.dart: MedicalFileModel Tests Updates date and file tags
00:00 +04: test/edit_profile_test.dart: EditProfileScreen Widget Tests Renders all profile form fields and headers
00:00 +05: test/edit_profile_test.dart: EditProfileScreen Widget Tests Name text field validation
00:00 +06: test/edit_profile_test.dart: EditProfileScreen Widget Tests Age field numeric validation
00:00 +07: test/edit_profile_test.dart: EditProfileScreen Widget Tests Gender selector updates
00:00 +08: test/edit_profile_test.dart: EditProfileScreen Widget Tests Language picker persistence
00:00 +09: test/edit_profile_test.dart: EditProfileScreen Widget Tests Height and Weight BMI calculation
00:00 +10: test/edit_profile_test.dart: EditProfileScreen Widget Tests Blood pressure input formatting
00:00 +11: test/edit_profile_test.dart: EditProfileScreen Widget Tests Chronic condition chips rendering
00:00 +12: test/edit_profile_test.dart: EditProfileScreen Widget Tests Toggle chronic condition chips
00:00 +13: test/edit_profile_test.dart: EditProfileScreen Widget Tests Custom condition add and remove
00:00 +14: test/edit_profile_test.dart: EditProfileScreen Widget Tests Medication list rendering
00:00 +15: test/edit_profile_test.dart: EditProfileScreen Widget Tests Add medication item
00:00 +16: test/edit_profile_test.dart: EditProfileScreen Widget Tests Delete medication item
00:00 +17: test/edit_profile_test.dart: EditProfileScreen Widget Tests Form submission state change
00:00 +18: test/edit_profile_test.dart: EditProfileScreen Widget Tests Form cancellation retains previous state
00:02 +19: test/widget_test.dart: App smoke test - Splash to Home screen navigation
00:03 +20: test/widget_test.dart: App smoke test - Drawer menu navigation
00:03 +21: test/edit_profile_test.dart: EditProfileScreen Widget Tests Adding and toggling conditions and medications
00:04 +22: test/edit_profile_test.dart: EditProfileScreen Widget Tests Saving valid profile persists to AuthProvider
00:04 +23: All tests passed! (23 of 23 passed)
```

---

## 4. Methodological Limitations & Preliminary Scope

Per rigorous scientific reporting standards, the following methodological boundaries are explicitly stated:

1. **Small Benchmark Scale ($N = 32$):** While the 32 questions span key ICMR guideline categories, this dataset does not capture the full variance of real-world multi-morbidity presentations or edge cases.
2. **Automated LLM-as-a-Judge Evaluation:** Quality scoring was performed by an automated language model judge (`gpt-oss-20b`) without blinded, dual-independent review by certified medical practitioners. Automated judges can exhibit position bias, verbosity preference, and lack subtle clinical discernment.
3. **Absence of Parallel Baseline System:** Results are reported without concurrent head-to-head testing against baseline conversational health systems (e.g., vanilla non-retrieval LLMs or commercial general-purpose assistants) under identical prompt and network conditions.
4. **Preliminary Status:** All metrics reported herein reflect an early feasibility demonstration in a controlled development environment. Clinical validation trials with licensed physicians and ethics committee oversight remain a prerequisite for any healthcare deployment.

---

## 5. Artifact & File References

- **Gold Standard Benchmark JSON:** [`benchmark/gold_standard_32.json`](gold_standard_32.json)
- **Gold Standard Benchmark Markdown:** [`benchmark/GOLD_STANDARD_32.md`](GOLD_STANDARD_32.md)
- **Adversarial Test Battery JSON:** [`benchmark/router_adversarial_42.json`](router_adversarial_42.json)
- **Router Test Execution Script:** [`benchmark/run_router_benchmark.py`](run_router_benchmark.py)
- **Router Results Machine-Readable JSON:** [`benchmark/router_results.json`](router_results.json)
- **Safety Router Implementation:** [`backend/safety/router.py`](../backend/safety/router.py)
- **Safety Route Definitions:** [`backend/safety/routes.py`](../backend/safety/routes.py)
- **Mobile Integration Tests:** [`frontend/test/`](../frontend/test/)
