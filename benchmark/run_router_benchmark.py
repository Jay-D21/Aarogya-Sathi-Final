"""
Aarogya Sathi - Router Benchmark Runner
========================================
Evaluates the safety router against:
  - 42 adversarial queries (must ALL be blocked)
  - 32 legitimate health queries (must ALL be passed through)

Runs entirely locally - no API keys needed.
The semantic_router library is used if available;
if it fails (e.g., protobuf version mismatch), the keyword fallback is used.

Usage:
    cd c:\\Users\\Abhijit\\Desktop\\Aarogya-Sathi-Final
    python benchmark/run_router_benchmark.py

Output:
    benchmark/router_results.json  (machine-readable)
    Printed summary table           (human-readable)
"""

import json
import sys
import time
import os
import io
from pathlib import Path

# Force UTF-8 stdout so Unicode queries print correctly on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

# ---------------------------------------------------------------------------
# Path setup — allow running from repo root
# ---------------------------------------------------------------------------
REPO_ROOT = Path(__file__).parent.parent.resolve()
sys.path.insert(0, str(REPO_ROOT))

# ---------------------------------------------------------------------------
# Import the safety router — captures any init warnings/fallback state
# ---------------------------------------------------------------------------
import logging
logging.basicConfig(level=logging.WARNING, format="%(levelname)s - %(message)s")

from backend.safety.router import (
    check_safety,
    _use_keyword_fallback,
    _router,
    EMERGENCY_RESPONSE,
    PRESCRIPTION_RESPONSE,
    NON_MEDICAL_RESPONSE,
)

# Determine which mode is active
if _use_keyword_fallback or _router is None:
    ROUTER_MODE = "keyword_fallback"
else:
    ROUTER_MODE = "semantic_router"

# ---------------------------------------------------------------------------
# Load test datasets
# ---------------------------------------------------------------------------
BENCHMARK_DIR = REPO_ROOT / "benchmark"

with open(BENCHMARK_DIR / "router_adversarial_42.json", encoding="utf-8") as f:
    adversarial_data = json.load(f)

adversarial_queries = adversarial_data["adversarial_queries"]
legitimate_queries = adversarial_data["legitimate_queries"]

# ---------------------------------------------------------------------------
# Classify the response returned by check_safety
# ---------------------------------------------------------------------------
def classify_response(response_str: str | None) -> str:
    if response_str is None:
        return "PASS"
    if "112" in response_str or "EMERGENCY" in response_str.upper():
        return "EMERGENCY_RESPONSE"
    if "prescribe" in response_str.lower() or "licensed doctor" in response_str.lower():
        return "PRESCRIPTION_RESPONSE"
    return "NON_MEDICAL_RESPONSE"


# ---------------------------------------------------------------------------
# Run adversarial queries
# ---------------------------------------------------------------------------
print(f"\n{'='*70}")
print("  AAROGYA SATHI — SAFETY ROUTER BENCHMARK")
print(f"  Router mode : {ROUTER_MODE}")
print(f"  Timestamp   : {time.strftime('%Y-%m-%d %H:%M:%S')}")
print(f"{'='*70}\n")

print("[ PHASE 1 ] Running 42 adversarial queries ...\n")

adversarial_results = []
adversarial_latencies = []

for item in adversarial_queries:
    qid = item["id"]
    query = item["query"]
    expected_action = item["expected_action"]       # "BLOCK"
    expected_resp_type = item["expected_response_type"]

    t0 = time.perf_counter()
    is_safe, blocked_response = check_safety(query)
    t1 = time.perf_counter()
    latency_ms = (t1 - t0) * 1000

    actual_action = "PASS" if is_safe else "BLOCK"
    actual_resp_type = classify_response(blocked_response) if not is_safe else "PASS"

    correct = (actual_action == expected_action)

    adversarial_results.append({
        "id": qid,
        "category": item["category"],
        "query": query,
        "expected_action": expected_action,
        "actual_action": actual_action,
        "expected_response_type": expected_resp_type,
        "actual_response_type": actual_resp_type,
        "correct": correct,
        "latency_ms": round(latency_ms, 3),
    })
    adversarial_latencies.append(latency_ms)

    status_icon = "[OK]" if correct else "[FAIL]"
    print(f"  {status_icon} [{qid}] {query[:55]:<55} -> {actual_action} ({latency_ms:.1f}ms)")

adversarial_correct = sum(1 for r in adversarial_results if r["correct"])
adversarial_avg_latency = sum(adversarial_latencies) / len(adversarial_latencies)

# Per-category breakdown
from collections import defaultdict
cat_results = defaultdict(lambda: {"correct": 0, "total": 0, "latencies": []})
for r in adversarial_results:
    cat = r["category"]
    cat_results[cat]["total"] += 1
    cat_results[cat]["latencies"].append(r["latency_ms"])
    if r["correct"]:
        cat_results[cat]["correct"] += 1

print(f"\n  Adversarial summary: {adversarial_correct}/{len(adversarial_queries)} correctly blocked")
print(f"  Average latency (adversarial): {adversarial_avg_latency:.1f} ms")
for cat, data in cat_results.items():
    avg_lat = sum(data["latencies"]) / len(data["latencies"])
    print(f"    {cat:15s}: {data['correct']}/{data['total']} blocked | avg {avg_lat:.1f}ms")

# ---------------------------------------------------------------------------
# Run legitimate queries (false positive test)
# ---------------------------------------------------------------------------
print(f"\n[ PHASE 2 ] Running 32 legitimate health queries ...\n")

legitimate_results = []
legitimate_latencies = []
false_positives = []

for item in legitimate_queries:
    qid = item["id"]
    query = item["query"]
    expected_action = item["expected_action"]   # "PASS"

    t0 = time.perf_counter()
    is_safe, blocked_response = check_safety(query)
    t1 = time.perf_counter()
    latency_ms = (t1 - t0) * 1000

    actual_action = "PASS" if is_safe else "BLOCK"
    correct = (actual_action == expected_action)

    legitimate_results.append({
        "id": qid,
        "source_id": item["source_id"],
        "query": query,
        "expected_action": expected_action,
        "actual_action": actual_action,
        "correct": correct,
        "latency_ms": round(latency_ms, 3),
        "false_positive": not correct,
    })
    legitimate_latencies.append(latency_ms)

    if not correct:
        false_positives.append(item)

    status_icon = "[OK]" if correct else "[FAIL FP]"
    print(f"  {status_icon} [{qid}] {query[:55]:<55} -> {actual_action} ({latency_ms:.1f}ms)")

legitimate_correct = sum(1 for r in legitimate_results if r["correct"])
legitimate_avg_latency = sum(legitimate_latencies) / len(legitimate_latencies)
false_positive_count = len(false_positives)

print(f"\n  Legitimate summary: {legitimate_correct}/{len(legitimate_queries)} correctly passed")
print(f"  False positives: {false_positive_count}")
print(f"  Average latency (legitimate): {legitimate_avg_latency:.1f} ms")

# ---------------------------------------------------------------------------
# Overall statistics
# ---------------------------------------------------------------------------
total_queries = len(adversarial_queries) + len(legitimate_queries)
total_correct = adversarial_correct + legitimate_correct
overall_avg_latency = (sum(adversarial_latencies) + sum(legitimate_latencies)) / total_queries

print(f"\n{'='*70}")
print("  FINAL RESULTS")
print(f"{'='*70}")
print(f"  Router mode              : {ROUTER_MODE}")
print(f"  Total queries            : {total_queries}")
print(f"  Overall accuracy         : {total_correct}/{total_queries} ({100*total_correct/total_queries:.1f}%)")
print(f"  Adversarial block rate   : {adversarial_correct}/{len(adversarial_queries)} ({100*adversarial_correct/len(adversarial_queries):.1f}%)")
print(f"  False positive rate      : {false_positive_count}/{len(legitimate_queries)} ({100*false_positive_count/len(legitimate_queries):.1f}%)")
print(f"  Avg latency (adversarial): {adversarial_avg_latency:.1f} ms")
print(f"  Avg latency (legitimate) : {legitimate_avg_latency:.1f} ms")
print(f"  Avg latency (overall)    : {overall_avg_latency:.1f} ms")
print(f"{'='*70}\n")

if false_positive_count > 0:
    print("  [WARN] FALSE POSITIVES (legitimate queries incorrectly blocked):")
    for fp in false_positives:
        print(f"     * {fp['id']}: {fp['query'][:70]}")
    print()

# ---------------------------------------------------------------------------
# Save machine-readable results
# ---------------------------------------------------------------------------
output = {
    "metadata": {
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S"),
        "router_mode": ROUTER_MODE,
        "total_queries": total_queries,
    },
    "summary": {
        "adversarial_intercepted": adversarial_correct,
        "adversarial_total": len(adversarial_queries),
        "adversarial_intercept_rate": round(adversarial_correct / len(adversarial_queries), 4),
        "false_positives": false_positive_count,
        "legitimate_total": len(legitimate_queries),
        "false_positive_rate": round(false_positive_count / len(legitimate_queries), 4),
        "avg_latency_adversarial_ms": round(adversarial_avg_latency, 3),
        "avg_latency_legitimate_ms": round(legitimate_avg_latency, 3),
        "avg_latency_overall_ms": round(overall_avg_latency, 3),
        "per_category": {
            cat: {
                "correct": data["correct"],
                "total": data["total"],
                "avg_latency_ms": round(sum(data["latencies"]) / len(data["latencies"]), 3)
            }
            for cat, data in cat_results.items()
        }
    },
    "adversarial_results": adversarial_results,
    "legitimate_results": legitimate_results,
    "false_positive_queries": [r for r in legitimate_results if r["false_positive"]],
}

output_path = BENCHMARK_DIR / "router_results.json"
with open(output_path, "w", encoding="utf-8") as f:
    json.dump(output, f, indent=2, ensure_ascii=False)

print(f"  [DONE] Results saved to: {output_path}")
print()
